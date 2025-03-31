import json
import jwt
import time
import requests

with open('disastermanagementapp-b5d15-firebase-adminsdk-fbsvc-4efc6f9bef.json') as f:
    service_account_info = json.load(f)

scopes = ['https://www.googleapis.com/auth/firebase.messaging']

now = int(time.time())
payload = {
    'iss': service_account_info['client_email'],
    'sub': service_account_info['client_email'],
    'aud': 'https://oauth2.googleapis.com/token',
    'iat': now,
    'exp': now + 3600,
    'scope': ' '.join(scopes)
}
additional_headers = {
    'kid': service_account_info['private_key_id']
}
signed_jwt = jwt.encode(payload, service_account_info['private_key'], headers=additional_headers, algorithm='RS256')

response = requests.post('https://oauth2.googleapis.com/token', data={
    'grant_type': 'urn:ietf:params:oauth:grant-type:jwt-bearer',
    'assertion': signed_jwt
})
access_token = response.json()['access_token']
print(access_token)

fcm_endpoint = 'https://fcm.googleapis.com/v1/projects/disastermanagementapp-b5d15/messages:send'

message_payload = {
    "message": {
        "topic": "news",
        # "token": "ceXIBiDXTq6gqVBBL9q2zQ:APA91bFBhj9rNwl91K66SFSTS-FWCSBPG4zSoOe5YYf0EV0uj3X-hJtYYgt01bQkBxhNO4JLryU-fysPnsx9dtJHpHGyF3_HzaW5AX8sZ84FWZIfUB1BrUk",
        "notification": {
            "title": "new msg fo u",
            "body": "phone nokkal nirth lotte"
        }
    }
}

headers = {
    'Authorization': f'Bearer {access_token}',
    'Content-Type': 'application/json; UTF-8',
}

response = requests.post(fcm_endpoint, headers=headers, json=message_payload)

print("susscess")