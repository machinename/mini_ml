import base64
import os
import pickle
from Crypto.Cipher import AES, PKCS1_OAEP
from Crypto.PublicKey import RSA
from Crypto.Util import Padding
from flask import Flask, jsonify, render_template, request
from io import StringIO
import json
from services import firebase_services, training_services, bucket
from helpers import validation
import pandas as pd
from flask import Flask, jsonify
import pandas as pd

app = Flask(__name__)

# Generate RSA key pair
_server_key = RSA.generate(2048)
    
    
@app.route("/")
def root():
    return render_template("index.html")

@app.route('/fetch_server_public_key', methods=['GET'])
def fetch_server_public_key():
    try:
        is_auth, auth_response, code = firebase_services.authenticate_request()
        if not is_auth:
            return auth_response, code
        
        server_public_key = _server_key.publickey().export_key().decode()
        return jsonify({'server_public_key': server_public_key}), 200
    except Exception as error:
        print(f'Error During Get Public Key Request: {str(error)}')
        return jsonify({'Error During Get Public Key Request': str(error)}), 500
    
@app.route('/fetch_user_storage', methods=['POST'])
def subscriber():
    try:
        is_auth, auth_response, code = firebase_services.authenticate_request()
        if not is_auth:
            return auth_response, code

        request_data = request.get_json()

        encrypted_user_id = base64.b64decode(request_data['user_id'])
        if not encrypted_user_id:
            return jsonify({'Missing Required Parameters'}), 400
    
        # RSA
        cipher_rsa = PKCS1_OAEP.new(_server_key)
        decrypted_user_id = cipher_rsa.decrypt(encrypted_user_id)
        user_id = decrypted_user_id.decode('utf-8')
    
        total_size_bytes = 0
        blobs = bucket.list_blobs(prefix=f'users/{user_id}/')
        subscriber_storage_limit_in_mega_bytes = 100
        print(f'subscriber_storage_limit_in_mega_bytes {subscriber_storage_limit_in_mega_bytes}')
        for blob in blobs:
            total_size_bytes += blob.size
        print(f'total_size_bytes: {total_size_bytes}')

        total_size_in_mega_bytes = total_size_bytes / (1024 * 1024)
        
        print(f'total_size_in_mega_bytes: {total_size_in_mega_bytes}')

        return jsonify({'total_size_in_mega_bytes': total_size_in_mega_bytes}), 200
        
    except Exception as error:
        print(f'{str(error)}')
        return jsonify({'Error Fetching User Storage': str(error)}), 500

@app.route('/subscriber_operation', methods=['POST'])
def subscriber():
    try:
        is_auth, auth_response, code = firebase_services.authenticate_request()
        if not is_auth:
            return auth_response, code

        request_data = request.get_json()
        
        encrypted_subscriber_json = base64.b64decode(request_data['subscriber_json'])
        encrypted_iv = base64.b64decode(request_data['iv'])
        encrypted_key = base64.b64decode(request_data['key'])
        encrypted_user_id = base64.b64decode(request_data['user_id'])
        encrypted_operation = base64.b64decode(request_data['operation'])
        
        if not encrypted_subscriber_json or not encrypted_iv or not encrypted_key or not encrypted_user_id:
            return jsonify({'Missing Required Parameters'}), 400
        
        # RSA
        cipher_rsa = PKCS1_OAEP.new(_server_key)
        decrypted_iv = cipher_rsa.decrypt(encrypted_iv).decode('utf-8')
        decrypted_key = cipher_rsa.decrypt(encrypted_key).decode('utf-8')
        decrypted_user_id = cipher_rsa.decrypt(encrypted_user_id)
        decrypted_operation = cipher_rsa.decrypt(encrypted_operation)
   
        iv = base64.b64decode(decrypted_iv)
        key = base64.b64decode(decrypted_key)
        user_id = decrypted_user_id.decode('utf-8')
        operation = decrypted_operation.decode('utf-8')
        
        # AES
        cipher_aes_json = AES.new(key, AES.MODE_CBC, iv=iv)
        padded_resource_json = cipher_aes_json.decrypt(encrypted_subscriber_json)
        unpadded_json = Padding.unpad(padded_resource_json , AES.block_size)
        decrypted_subscriber_json = unpadded_json
        subscriber_dict = json.loads(decrypted_subscriber_json)
        
        is_success, subscriber_response, code = firebase_services.subscriberOperation(operation=operation, subscriber_dict=subscriber_dict, user_id=user_id)
        if not is_success:
            return subscriber_response, code
        
        return jsonify(), 201
    except Exception as error:
        print(f'Error During Subscriber Operation Request: {str(error)}')
        return jsonify({'Error During Subscriber Operation Request': str(error)}), 500
    
@app.route('/create_project', methods=['POST'])
def create_project():
    try:
        is_auth, auth_response, code = firebase_services.authenticate_request()
        if not is_auth:
            return auth_response, code

        request_data = request.get_json()
        
        encrypted_project_json = base64.b64decode(request_data['project_json'])
        encrypted_iv = base64.b64decode(request_data['iv'])
        encrypted_key = base64.b64decode(request_data['key'])
        encrypted_user_id = base64.b64decode(request_data['user_id'])
        
        if not encrypted_project_json or not encrypted_iv or not encrypted_key or not encrypted_user_id:
            return jsonify({'Missing Required Parameters'}), 400
        
        # RSA
        cipher_rsa = PKCS1_OAEP.new(_server_key)
        decrypted_iv = cipher_rsa.decrypt(encrypted_iv).decode('utf-8')
        decrypted_key = cipher_rsa.decrypt(encrypted_key).decode('utf-8')
        decrypted_user_id = cipher_rsa.decrypt(encrypted_user_id)
   
        iv = base64.b64decode(decrypted_iv)
        key = base64.b64decode(decrypted_key)
        user_id = decrypted_user_id.decode('utf-8')
        
        # AES
        cipher_aes_json = AES.new(key, AES.MODE_CBC, iv=iv)
        padded_resource_json = cipher_aes_json.decrypt(encrypted_project_json)
        unpadded_json = Padding.unpad(padded_resource_json , AES.block_size)
        decrypted_project_json = unpadded_json
        decrypted_project_dict = json.loads(decrypted_project_json)
        
        is_created, created_response, code = firebase_services.create_project(user_id=user_id, project_dict=decrypted_project_dict)
        if not is_created:
            return created_response, code
    
        return jsonify(), 201
    except Exception as error:
        print(f'Error During Create Project Request: {str(error)}')
        return jsonify({'Error During Create Project Request': str(error)}), 500
    
@app.route('/create_resource', methods=['POST'])
def create_resource():
    resource_temp_path=""
    try:
        is_auth, auth_response, code = firebase_services.authenticate_request()
        if not is_auth:
            return auth_response, code
        request_data = request.get_json()
        encrypted_resource_json = base64.b64decode(request_data['resource_json'])
        encrypted_iv = base64.b64decode(request_data['iv'])
        encrypted_key = base64.b64decode(request_data['key'])
        encrypted_project_id = base64.b64decode(request_data['project_id'])
        encrypted_user_id = base64.b64decode(request_data['user_id'])
        if not encrypted_resource_json or not encrypted_iv or not encrypted_key or not encrypted_project_id or not encrypted_user_id:
            return jsonify({'Missing Required Parameters'}), 400
        # RSA
        cipher_rsa = PKCS1_OAEP.new(_server_key)
        decrypted_iv = cipher_rsa.decrypt(encrypted_iv).decode('utf-8')
        decrypted_key = cipher_rsa.decrypt(encrypted_key).decode('utf-8')
        decrypted_project_id = cipher_rsa.decrypt(encrypted_project_id)
        decrypted_user_id = cipher_rsa.decrypt(encrypted_user_id)
        iv = base64.b64decode(decrypted_iv)
        key = base64.b64decode(decrypted_key)
        project_id = decrypted_project_id.decode('utf-8')
        user_id = decrypted_user_id.decode('utf-8')
        # AES
        cipher_aes_json = AES.new(key, AES.MODE_CBC, iv=iv)
        padded_resource_json = cipher_aes_json.decrypt(encrypted_resource_json)
        unpadded_json = Padding.unpad(padded_resource_json , AES.block_size)
        decrypted_resource_json = unpadded_json
        decrypted_resource_dict = json.loads(decrypted_resource_json)
        
        if decrypted_resource_dict['resource_type'] == 'data':
            encrypted_data = base64.b64decode(request_data['data'])
            
            if not encrypted_data:
                return jsonify({'Missing Required Parameters'}), 400
            
            cipher_aes_data = AES.new(key, AES.MODE_CBC, iv=iv)
            padded_data = cipher_aes_data.decrypt(encrypted_data)
            unpadded_data = Padding.unpad(padded_data, AES.block_size)
            decrypted_data = unpadded_data.decode('utf-8')
        
            df = pd.read_csv(StringIO(decrypted_data)).dropna()
            
            print(df.head())
            
            resource_temp_path = f'temp_server_files/{user_id}.csv'
            df.to_csv(resource_temp_path, index=False)   
            variables = {}
            
            for column in df.columns:
                dtype = df[column].dtype
                if dtype == 'int64':
                    variables[column] = 'integer'
                elif dtype == 'float64':
                    if (df[column] % 1 == 0).all():
                        variables[column] = 'integer'
                    else:
                        variables[column] = 'float'
                else:
                    variables[column] = 'object'
                    
            num_rows, num_columns = df.shape
            print(f"Number of rows: {num_rows}")
            print(f"Number of columns: {num_columns}")
            decrypted_resource_dict['variables'] = variables
            
        elif decrypted_resource_dict['resource_type'] == 'model':
            data, fetch_response, code = firebase_services.fetch_resource(user_id=user_id, project_id=project_id, resource_id=decrypted_resource_dict['data_id'], resource_type='data')
            if not data:
                return fetch_response, code
            
            df = pd.read_csv(StringIO(data.decode('utf-8'))).dropna()
            
            print(df.head())
            
            print(decrypted_resource_dict)
            model, evaluation_metrics, model_response, code = training_services.regression(df=df, label=decrypted_resource_dict['label'])
            if not model:
                return model_response, code
            
            decrypted_resource_dict['evaluation_metrics'] = evaluation_metrics
            resource_temp_path = f'temp_server_files/{user_id}.pkl'

            with open(resource_temp_path, 'wb') as file:
                pickle.dump(model, file)
                
            if not os.path.exists(resource_temp_path):
                return jsonify({'Error': 'Error Occured While Saving Model'}), 500
    
        else:
            return jsonify({'Invalid Resource Type'}), 400
        
        resource_size_bytes = os.path.getsize(resource_temp_path) 
        
        print(resource_size_bytes)
        
        proposed_total_size_in_mega_bytes, response, code = firebase_services.fetch_user_storage(user_id=user_id, resource_size_bytes=resource_size_bytes)
        if not proposed_total_size_in_mega_bytes:
            return response, code
        
        resource_created, response, code = firebase_services.create_resource(project_id=project_id, user_id=user_id, resource_dict=decrypted_resource_dict, resource_temp_path=resource_temp_path)
        if not resource_created:
            return response, code
        
        return jsonify(), 201
    except Exception as error:
        print(f'Error During Create Data Request: {str(error)}')
        return jsonify({'Error During Create Data Request': str(error)}), 500
    finally:
        if resource_temp_path and os.path.exists(resource_temp_path):
            os.remove(resource_temp_path)
            

# if __name__ == "__main__":
#     app.run(host="127.0.0.1", port=8080, debug=True)
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=True)