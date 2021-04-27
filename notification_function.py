import json
import boto3
from botocore.vendored import requests

s3 = boto3.client('s3')
BUCKET='YOUR-BUCKET-NAME'
RESULTS='quake-match-results.txt'

TELE_TOKEN='YOUR-TELEGRAM-BOT-TOKEN'
URL = "https://api.telegram.org/bot{}/".format(TELE_TOKEN)
CHAT_ID = 'YOUR-TELEGRAM-GROUP-ID'

def send_message(_CHAT_ID):
    data = s3.get_object(Bucket=BUCKET, Key=RESULTS)
    contents = data['Body'].read().decode('utf-8') 
    
    # delete results file
    s3.delete_object(Bucket=BUCKET, Key=RESULTS)
    
    url = URL + "sendMessage?text={}&chat_id={}".format(contents, _CHAT_ID)
    requests.get(url)

def lambda_handler(event, context):

    send_message(CHAT_ID)
    return {
        'statusCode': 200
    }
