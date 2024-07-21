from flask import jsonify
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_absolute_error, mean_squared_error, r2_score, mean_absolute_percentage_error, explained_variance_score, median_absolute_error
from sklearn.model_selection import train_test_split

def regression(df, label: str):
    try:    
        X = df.drop(columns=[label])
        y = df[label]
        
        X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.5,  random_state=42)
        model = LinearRegression()
            
        model.fit(X_train, y_train)
        
        y_pred = model.predict(X_test)
        
        evaluation_metrics = {
            'mae': mean_absolute_error(y_test, y_pred),
            'mse': mean_squared_error(y_test, y_pred),
            'r2': r2_score(y_test, y_pred),
            'rmse': mean_squared_error(y_test, y_pred),
        }

        return model, evaluation_metrics, None, None
    except Exception as e:
        print("Error:", e)
        return None, None, jsonify({'Error': 'Error Occured While Training Model'}), 500
    