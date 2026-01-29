# YRSS SMS Spam Shield App 

A hybrid Android–Flask app that detects and blocks SMS spam using a logistic regression model.

## App Features
- Classifies incoming SMS messages as spam or safe
- Uses a trained logistic regression model (`spam_model.pkl`)
- Sends SMS data from Android to Flask backend for analysis
- Works over local network for fast, private processing

## Backend Overview
- Built with **Flask** to serve the ML model
- Uses `vectorizer.pkl` for text preprocessing
- Exposes a local API endpoint for mobile communication

## Setup: Python Virtual Environment & Flask Server

> Use **Command Prompt**, not **Windows PowerShell**

```bash
cd .\python
python -m venv venv
.\venv\Scripts\activate
python -m pip install -r requirements.txt
python -m flask --app spam_logistic_regression_model run
```

## Install APK & Connect Phone
- Install the APK on your Android device
- Connect your phone to the same network where the Flask application is running

## ALTERNATIVELY, Open http://127.0.0.1:5000/ 
