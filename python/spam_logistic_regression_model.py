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

# Use random n rows (for testing purpose).
# Comment out when not testing.
# df = df.sample(20)

# Preprocess "Text Message" column.
# Download stop words from NLTK.
nltk.download("stopwords")

def preprocess_text_message(text_message):
    # Remove punctuation in text_message.
    text_message = text_message.translate(str.maketrans("", "", string.punctuation))
    # Remove stop words (from NLTK) in text_message.
    # Can be commented out if you think stop words matter.
    text_message = [word for word in text_message.split() if word.lower() not in stopwords.words("english")]
    return " ".join(text_message)

df[column_headers[0]] = df[column_headers[0]].apply(preprocess_text_message)

# Split data into X (independent variable) and Y (dependent variable).
Y = df[column_headers[1]].values
Y = Y.astype("int")  # Convert to values to integer.
# X = df.drop(labels=[column_headers[1]], axis=1)
X = df[column_headers[0]].values

print(len(Y), len(X))

X_train, X_test, Y_train, Y_test = train_test_split(X, Y, test_size=0.3, random_state=0)

# Vectorize X_train and X_test.
# Adding stop_words="english" may be redundant.
vectorizer = TfidfVectorizer()
X_train_vector = vectorizer.fit_transform(X_train)
X_test_vector = vectorizer.transform(X_test)

# Train Logistic Regression Model.
model = LogisticRegression(verbose=1, solver="liblinear", penalty="l1")
model.fit(X_train_vector, Y_train)

# Test the model.
test_results = model.predict(X_test_vector)
print(f"Accuracy = {accuracy_score(Y_test, test_results)}")

# Set recursion limit to 2000 (since the default value, 1000, makes m2c fail).
# Change 2000 to a higher value if it still raises errors.
sys.setrecursionlimit(2000)

# Convert Logistic Regression Model to Dart code.
code = m2c.export_to_dart(model)

# Save Dart code to file.
with open("./spam_logistic_regression_model.dart", "w") as dart_file:
    dart_file.write(code)