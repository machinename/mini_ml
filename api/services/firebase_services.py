import datetime
from dotenv import load_dotenv
from firebase_admin import credentials, initialize_app, auth, storage, firestore
from flask import jsonify, request
import datetime
import os

load_dotenv()

firebase_key = os.getenv('FIREBASE_KEY')
storage_bucket_key = os.getenv('STORAGE_BUCKET_KEY')

# Initialize Firebase Admin SDK
cred_firebase = credentials.Certificate(firebase_key)
initialize_app(cred_firebase, {'storageBucket': storage_bucket_key})
firestore_db = firestore.client()
bucket = storage.bucket()

def authenticate_request():
    is_auth, token_or_error = check_auth_header()
    
    if not is_auth:
        return False, token_or_error
    
    decoded_token = verify_id_token(token_or_error)
    if not decoded_token:
        return False, jsonify({'Error': 'Invalid token'}), 401
    return True, None, None

def check_auth_header():
    auth_header = request.headers.get('Authorization')
    if not auth_header or not auth_header.startswith('Bearer '):
        return False, jsonify({'Error': 'Invalid Authorization Header Format'}), 401
    return True, auth_header.split('Bearer ')[1]

def verify_id_token(token):
    try:
        return auth.verify_id_token(token)
    except Exception as error:
        print(f'Error Occured While Verifying Id Token: {str(error)}')
        return None

    
def fetch_resource(user_id: str, project_id: str, resource_id: str, resource_type: str):
    try:
        blob = bucket.blob(f'users/{user_id}/projects/{project_id}/')
        
        if resource_type == 'data':
            blob = bucket.blob(f'users/{user_id}/projects/{project_id}/data/{resource_id}')
            data_file = blob.download_as_string()
            return data_file, None, None
        elif resource_type == 'model':
            blob = bucket.blob(f'users/{user_id}/projects/{project_id}/models/{resource_id}')
            model_file = blob.download_as_bytes
            return model_file, None, None
        else:
            return None, jsonify('Invalid Resource Type'), 400
    except Exception as error:
        print(f'Error Occured While Fetching User Resource: {str(error)}')
        return None, jsonify('Error Occured While Fetching User Resource'), 500
    
def fetch_user_storage(user_id: str, resource_size_bytes: int):
    try:
        total_size_bytes = 0
        blobs = bucket.list_blobs(prefix=f'users/{user_id}/')
        subscriber_storage_limit_in_mega_bytes = 100
        print(f'subscriber_storage_limit_in_mega_bytes {subscriber_storage_limit_in_mega_bytes}')
        for blob in blobs:
            total_size_bytes += blob.size
        print(f'total_size_bytes: {total_size_bytes}')
        proposed_total_size_in_mega_bytes = (total_size_bytes + resource_size_bytes) / (1024 * 1024)
        print(f'total_size_bytes + resource_size_bytes: {total_size_bytes + resource_size_bytes}')
        print(f'proposed_total_size_mb: {proposed_total_size_in_mega_bytes}')
        if proposed_total_size_in_mega_bytes > subscriber_storage_limit_in_mega_bytes:
            return None, jsonify('Not Enough Cloud Storage Available, Delete Some Files To Free Up Space'), 400
        else:
            return proposed_total_size_in_mega_bytes, None, None
    except Exception as error:
        print(f'Error Occured While Checking Cloud Storage: {str(error)}')
        return None, jsonify('Error Occured While Checking Cloud Storage'), 500
    
def create_project(project_dict: dict, user_id: str):
    try:
        project_doc_ref = firestore_db.collection('users').document(user_id).collection('projects').document()
        created_at = datetime.datetime.now()
        
        project_doc_ref.set({
            'created_at': created_at.strftime("%Y-%m-%d %H:%M:%S"),
            'id': project_doc_ref.id,
            'name': project_dict['name'],
            'description': project_dict['description'],
        })
        
        return True, None, None
    except Exception as error:
        print(f'Error Occured While Creating User Project On Database: {str(error)}')
        return False, jsonify('Error Occured While Creating User Project On Database'), 500
    
def create_resource(resource_dict: dict, user_id: str, project_id: str, resource_temp_path: str):
    try:
        doc_ref = firestore_db.collection('users').document(user_id)
        created_at = datetime.datetime.now()
        
        if resource_dict['resource_type'] == 'data':
            data_doc_ref = doc_ref.collection('projects').document(project_id).collection('data').document()
            blob = bucket.blob(f'users/{user_id}/projects/{project_id}/data/{data_doc_ref.id}')
            
            if resource_dict['data_type'] == 'tabular':
                blob.upload_from_filename(resource_temp_path, content_type='text/csv')
            elif resource_dict['data_type'] == 'image':
                blob.upload_from_filename(resource_temp_path, content_type='image/jpeg')
            elif resource_dict['data_type'] == 'text':
                blob.upload_from_filename(resource_temp_path, content_type='text/plain')
            elif resource_dict['data_type'] == 'video':
                blob.upload_from_filename(resource_temp_path, content_type='video/mp4')
            else:
                return False, jsonify('Invalid Data Set Type'), 400
            
            data_doc_ref.set({
                'created_at': created_at.strftime("%Y-%m-%d %H:%M:%S"),
                'id': data_doc_ref.id,
                'name': resource_dict['name'],
                'description': resource_dict ['description'],
                'data_type': resource_dict['data_type'],
                'variables' : resource_dict['variables'],
                'resource_type': resource_dict['resource_type']
            })
        elif resource_dict['resource_type'] == 'model':
            model_doc_ref = doc_ref.collection('projects').document(project_id).collection('models').document()
            blob = bucket.blob(f'users/{user_id}/projects/{project_id}/models/{model_doc_ref.id}')
            blob.upload_from_filename(resource_temp_path, content_type='application/steam')
            
            if not blob.exists():
                return False, jsonify('Error Occured While Creating User Model'), 500
            
            model_doc_ref.set({
                'created_at': created_at.strftime("%Y-%m-%d %H:%M:%S"),
                'data_id': resource_dict['data_id'],
                'data_name': resource_dict['data_name'],
                'label': resource_dict['label'],
                'evaluation_metrics': resource_dict['evaluation_metrics'], # 'mae', 'mse', 'r2', 'rmse', 'mape', 'evs', 'medae
                'description': resource_dict['description'], # 'description': 'This is a model for predicting house prices based on the number of rooms in the house.        
                'id': model_doc_ref.id,
                'name': resource_dict['name'],
                'model_type': resource_dict['model_type'], # 'model_type': 'classification', 'regression', 'clustering', 'object_detection', 'segmentation', 'anomaly_detection', 'recommendation', 'forecasting', 'reinforcement_learning', 'generative_adversarial_networks', 'transformer', 'bert', 'gpt', 'resnet', 'vgg', 'inception', 'mobilenet', 'efficientnet', 'densenet', 'alexnet', 'squeezenet', 'yolo', 'ssd', 'faster_rcnn', 'mask_rcnn', 'unet', 'fcn', 'deeplab', 'lstm', 'gru', 'rnn', 'transformer', 'bert', 'gpt', 'resnet', 'vgg', 'inception', 'mobilenet', 'efficientnet', 'densenet', 'alexnet', 'squeezenet', 'yolo', 'ssd', 'faster_rcnn', 'mask_rcnn', 'unet', 'fcn', 'deeplab', 'lstm', 'gru', 'rnn'
                'resource_type': resource_dict['resource_type']
            })
        else:
            return False, jsonify('Invalid Resource Type'), 400
        
    
        return True, None, None
    except Exception as error:
        print(f'Error Occured While Creating User Data On Database: {str(error)}')
        return False, jsonify('Error Occured While Creating User Data On Database'), 500
    
