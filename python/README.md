
# SETUP PYTHON VIRTUAL ENVIRONMENT

Use ***Command Prompt*** not ***Windows PowerShell***.
1. `cd .\python`
2. `python -m venv venv`
3. `.\venv\Scripts\activate`
4. `python -m pip install -r requirements.txt`
5. `deactivate`

# USE PYTHON VIRTUAL ENVIRONMENT TO RUN FLASK

Use ***Command Prompt*** not ***Windows PowerShell***.
1. `cd .\python`
2. `.\venv\Scripts\activate`
3. `python -m flask --app spam_logistic_regression_model run`
4. `deactivate`