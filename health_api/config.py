from dotenv import load_dotenv
import os

load_dotenv()

CREDENTIALS_FILE = os.getenv("CREDENTIALS_FILE", "credentials.json")
