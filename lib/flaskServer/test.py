
#testing if vision api is setup correctly
from google.cloud import vision

client = vision.ImageAnnotatorClient()
print("Google Vision API is set up successfully!")