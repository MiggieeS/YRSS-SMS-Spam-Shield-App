import pandas as pd
import string
import nltk
from nltk.corpus import stopwords
from sklearn.feature_extraction.text import TfidfVectorizer
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LogisticRegression
from sklearn.metrics import accuracy_score
import m2cgen as m2c
import sys


column_headers = ["Text Message", "Spam Classification"]

# Read CSV from Google Sheets.
df = pd.read_csv("https://docs.google.com/spreadsheets/d/1sq05T7vcrl-CeSGqVxVVeGQjdYpbaV-uuXbFO92RxgU/export?format=csv", usecols=[0, 1])

# Remove rows with missing data.
df.dropna(subset=column_headers, inplace=True, how="any")

# Use random sample_size*2 rows (for testing purpose).
# Comment out when not testing.
# sample_size = 80
# spam_df = df.query(f'(`{column_headers[1]}` == 1)').sample(sample_size, random_state=0)
# non_spam_df = df.query(f'(`{column_headers[1]}` == 0)').sample(sample_size, random_state=0)
# df = pd.concat([spam_df, non_spam_df], ignore_index=True)

# Preprocess "Text Message" column.
# Download stop words from NLTK.
nltk.download("stopwords")

def preprocess_text_message(text_message):
    # Remove punctuation in text_message.
    text_message = text_message.translate(str.maketrans("", "", string.punctuation))
    # Remove stop words (from NLTK) in text_message.
    text_message = [word for word in text_message.split() if word.lower() not in stopwords.words("english")]
    return " ".join(text_message)

df[column_headers[0]] = df[column_headers[0]].apply(preprocess_text_message)

# Split data into X (independent variable) and Y (dependent variable).
Y = df[column_headers[1]].values
Y = Y.astype("int")  # Convert to values to integer.
X = df[column_headers[0]].values

X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.2, random_state=0)

# Vectorize X_train and X_test.
# Adding stop_words="english" may be redundant.
vectorizer = TfidfVectorizer(stop_words="english")
X_train_vector = vectorizer.fit_transform(X_train)
X_test_vector = vectorizer.transform(X_test)

# Train Logistic Regression Model.
model = LogisticRegression(verbose=1, solver="liblinear", penalty="l1")
model.fit(X_train_vector, Y_train)

# Test the model.
test_results = model.predict(X_test_vector)
print(f"Accuracy = {accuracy_score(Y_test, test_results)}")

# Test model through input.
while True:
    input_text_message = input("\nEnter text message.\nInput 'exit' to stop.\n> ")
    if (input_text_message.lower() == "exit"):
        break
    result = model.predict(vectorizer.transform([preprocess_text_message(input_text_message)]))[0]
    if result == 0:
        print("-------------------\n| It is NOT spam. |\n-------------------")
    elif result == 1:
        print("---------------\n| It is SPAM! |\n---------------")

# Set recursion limit to a higher value (since the default value, 1000, makes m2c fail).
sys.setrecursionlimit(10**4)

# Convert Logistic Regression Model to Dart code.
code = m2c.export_to_dart(model)

# Save Dart code to file.
with open("./spam_logistic_regression_model.dart", "w") as dart_file:
    dart_file.write(code)