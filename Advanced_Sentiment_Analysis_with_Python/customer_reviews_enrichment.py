import pandas as pd
import pyodbc
import nltk
from nltk.sentiment.vader import SentimentIntensityAnalyzer

nltk.download('vader_lexicon')

# Connect to SQL Server
conn_str = (
    "Driver={SQL Server};"
    "Server=DESKTOP-O6LSKAG\\SQLEXPRESS2022;"
    "Database=QuickBite_MarketingAnalytics;"
    "Trusted_Connection=yes;"
)

conn = pyodbc.connect(conn_str)

# Get customer reviews
query = """
SELECT ReviewID, CustomerID, ProductID, ReviewDate, Rating, ReviewText
FROM dbo.customer_reviews
"""

df = pd.read_sql(query, conn)
conn.close()

# Sentiment analysis
sia = SentimentIntensityAnalyzer()

df['SentimentScore'] = df['ReviewText'].apply(
    lambda x: sia.polarity_scores(x)['compound']
)

# Sentiment category
def categorize_sentiment(row):
    score = row['SentimentScore']
    rating = row['Rating']

    if score > 0.05:
        if rating >= 4:
            return 'Positive'
        elif rating == 3:
            return 'Mixed Positive'
        else:
            return 'Mixed Negative'

    elif score < -0.05:
        if rating <= 2:
            return 'Negative'
        elif rating == 3:
            return 'Mixed Negative'
        else:
            return 'Mixed Positive'

    else:
        if rating >= 4:
            return 'Positive'
        elif rating <= 2:
            return 'Negative'
        else:
            return 'Neutral'

df['SentimentCategory'] = df.apply(categorize_sentiment, axis=1)

# Sentiment bucket
def sentiment_bucket(score):
    if score >= 0.5:
        return 'Strong Positive'
    elif score >= 0:
        return 'Positive'
    elif score >= -0.5:
        return 'Negative'
    else:
        return 'Strong Negative'

df['SentimentBucket'] = df['SentimentScore'].apply(sentiment_bucket)

# Rating category
def rating_category(rating):
    if rating <= 2:
        return 'Low'
    elif rating == 3:
        return 'Neutral'
    else:
        return 'High'

df['RatingCategory'] = df['Rating'].apply(rating_category)

# Check the result
print(df.head())

# Save for Power BI
df.to_csv('customer_reviews_with_sentiment.csv', index=False)