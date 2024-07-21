import re
from flask import jsonify

def validate_data_set_dict(data_dict: dict):
    try:
        required_keys = ["id", "created_at", "name", "description", "source", "features"]
        
        for key in required_keys:
            if key not in data_dict:
                raise KeyError(f"Data Missing Dictionary Key - `{key}`")
        
        if not isinstance(data_dict["id"], str):
            raise ValueError("Data Id Should Be A String")
        if not isinstance(data_dict["created_at"], str):
            raise ValueError("Data Created At Should Be A String")
        if not isinstance(data_dict["name"], str):
            raise ValueError("Data Name Should Be A String")
        if not (4 <= len(data_dict["name"]) <= 40):
            raise ValueError("Data Name Length Should Be Between 4 And 40 Characters")
        if not re.match("^[a-zA-Z0-9_-]*$", data_dict["name"]):
            raise ValueError("Data Name Should Only Contain Letters, Numbers, Dashes, And Underscores")
        if not isinstance(data_dict["description"], str):
            raise ValueError("Data Description Should Be A String")
        if not isinstance(data_dict["source"], str):
            raise ValueError("Data Source Should Be A String")
        if not isinstance(data_dict["features"], dict):
            raise ValueError("Data Features Should Be A Dictionary")
    
        return True, None, None
    except KeyError as error:
         # Log(error)
        return False, jsonify(f"KeyError: {str(error)}"), 400
    except ValueError as error:
         # Log(error)
        return False, jsonify(f"ValueError: {str(error)}"), 400
    except Exception as error:
         # Log(error)
        return False, jsonify(f"Error Occurred While Validating User Data: {str(error)}"), 500

def validate_job_dict(job_dict: dict):
    try:
        required_keys = ["id", "created_at", "name", "description", "label", "task", "is_trained", "data", "summary"]
        
        for key in required_keys:
            if key not in job_dict:
                raise KeyError(f"Job Missing Dictionary Key - `{key}`")
        
        if not isinstance(job_dict["id"], str):
            raise ValueError("Job Id Should Be A String")
        if not isinstance(job_dict["created_at"], str):
            raise ValueError("Job Created At Should Be A String")
        if not isinstance(job_dict["name"], str):
            raise ValueError("Job Name Should Be A String")
        if not (4 <= len(job_dict["name"]) <= 40):
            raise ValueError("Job Name Length Should Be Between 4 And 40 Characters")
        if not re.match("^[a-zA-Z0-9_-]*$", job_dict["name"]):
            raise ValueError("Job Name Should Only Contain Letters, Numbers, Dashes, And Underscores")
        if not isinstance(job_dict["description"], str):
            raise ValueError("Job Description Should Be A String")
        if not (len(job_dict["description"]) <= 100):
            raise ValueError("Job Description Length Should Not Be Longer Than 100 Characters")
        if not isinstance(job_dict["label"], str):
            raise ValueError("Job Label Should Be A String")
        if not (1 <= len(job_dict["label"]) <= 40):
            raise ValueError("Job Label Length Should Be Between 1 And 40 Characters")
        if not isinstance(job_dict["task"], str):
            raise ValueError("Job Task Should Be A String")
        if job_dict["task"].lower() not in ["regression", "classification"]:
            raise ValueError("Job Task Should Be Regression Or Classification")
        if not isinstance(job_dict["is_trained"], bool):
            raise ValueError("Job Is Trained Should Be A Boolean")
        if not isinstance(job_dict["data"], dict):
            raise ValueError("Job Data Should Be A Dictionary")
        
        is_valid_data, invalid_data_response, code = validate_data_dict(job_dict["data"])
        if not is_valid_data:
            return False, invalid_data_response, code
        
        return True, None, None
    except KeyError as error:
        return False, jsonify(f"KeyError: {str(error)}"), 400
    except ValueError as error:
        return False, jsonify(f"ValueError: {str(error)}"), 400
    except Exception as error:
        return False, jsonify(f"Error Occurred While Validating User Job: {str(error)}"), 500

def validate_model_dict(model_dict: dict):
    try:
        required_keys = ["name", "description", "job"]
        
        for key in required_keys:
            if key not in model_dict:
                raise KeyError(f"Model Missing Dictionary Key - `{key}`")
        
        if not isinstance(model_dict["name"], str):
            raise ValueError("Model Name Should Be A String")
        if not (4 <= len(model_dict["name"]) <= 40):
            raise ValueError("Model Name Length Should Be Between 4 And 40 Characters")
        if not isinstance(model_dict["description"], str):
            raise ValueError("Model Description Should Be A String")
        if not re.match("^[a-zA-Z0-9_-]*$", model_dict["name"]):
            raise ValueError("Model Name Should Only Contain Letters, Numbers, Dashes, And Underscores")
        if not (len(model_dict["description"]) <= 100):
            raise ValueError("Model Description Length Should Be Less Than Or Equal To 100 Characters")
        if not isinstance(model_dict["job"], dict):
            raise ValueError("Model Job Should Be A Dictionary")
        
        is_valid_job, invalid_job_response, code = validate_job_dict(model_dict["job"])
        if not is_valid_job:
            return False, invalid_job_response, code
        
        return True, None, None
    except KeyError as error:
        # Log(error)
        return False, jsonify(f"KeyError: {str(error)}"), 400
    except ValueError as error:
        # Log(error)
        return False, jsonify(f"ValueError: {str(error)}"), 400
    except Exception as error:
        # Log(error)
        return False, jsonify(f"Error Occurred While Validating User Model: {str(error)}"), 500
