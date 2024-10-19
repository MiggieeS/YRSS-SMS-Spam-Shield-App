# Python Standard Library.
import string

# 3rd Party Packages.
import pandas as pd
import nltk
from nltk.tokenize import word_tokenize
from nltk.corpus import stopwords
from nltk.stem import WordNetLemmatizer
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
from flask import Flask, request, jsonify

# Define column headers.
column_headers = ["Text Message", "Spam Classification"]

# Read CSV from Google Sheets.
df = pd.read_csv("https://docs.google.com/spreadsheets/d/16JprumWE9baoRkWjQ20yrTCMgxFkJ5FJh_yLRRRun9g/export?format=csv", usecols=[0, 1])

# Remove rows with missing data and duplicates.
df.dropna(subset=column_headers, inplace=True, how="any")
df.drop_duplicates(subset=column_headers)

# Make sample size have a 1:1 ratio (equal number of spam and non-spam messages).
spam_df = df.query(f'(`{column_headers[1]}` == 1)')
non_spam_df = df.query(f'(`{column_headers[1]}` == 0)')
sample_size = min(spam_df.shape[0], non_spam_df.shape[0])
df = pd.concat([spam_df.sample(sample_size, random_state=0), non_spam_df.sample(sample_size, random_state=0)], ignore_index=True)

# Preprocess the "Text Message" column.
nltk.download("punkt")
nltk.download("stopwords")
nltk.download("wordnet")
lem = WordNetLemmatizer()

def preprocess_text_message(text_message):
    text_message = word_tokenize(text_message)
    text_message = [word.lower() for word in text_message if word not in string.punctuation and word.lower() not in stopwords.words("english")]
    text_message = [lem.lemmatize(word, 'v') for word in text_message]
    return " ".join(text_message)

df[column_headers[0]] = df[column_headers[0]].apply(preprocess_text_message)

# Split data into X and Y.
Y = df[column_headers[1]].values.astype("int")
X = df[column_headers[0]].values

X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2, random_state=0)

# Vectorize the text messages.
vectorizer = TfidfVectorizer()
X_train_vector = vectorizer.fit_transform(X_train)
X_test_vector = vectorizer.transform(X_test)

# Train Logistic Regression model.
model = LogisticRegression(verbose=1, solver="liblinear", penalty="l1")
model.fit(X_train_vector, Y_train)

# Test the model.
test_results = model.predict(X_test_vector)
print(f"Accuracy = {accuracy_score(Y_test, test_results)}")


# Create Flask app.
app = Flask(__name__)

# Endpoint for making predictions.
@app.route('/predict', methods=['POST'])
def predict():
    try:
        # Get data from request.
        data = request.get_json()
        message = data.get('message', '')

        # Preprocess the message.
        processed_message = preprocess_text_message(message)

        # Vectorize the message.
        vectorized_message = vectorizer.transform([processed_message])

        # Make prediction.
        prediction = model.predict(vectorized_message)[0]
        
        # Return the result.
        return jsonify({'prediction': int(prediction)})  # 0 for Not Spam, 1 for Spam

    except Exception as e:
        return jsonify({'error': str(e)}), 400

# Run Flask app.
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
