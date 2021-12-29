import os

import requests
from pycrowdsec.client import QueryClient

valid_tokens = set()


def validate_captcha_resp(captcha_resp):
    resp = requests.post(
        url="https://www.google.com/recaptcha/api/siteverify",
        data={
            "secret": os.environ["GOOGLE_CAPTCHA_SECRET"],
            "response": captcha_resp,
        },
    ).json()
    return resp["success"]


def handler(event, context):
    verdict = "Deny"
    cs_client = QueryClient(
        api_key=os.environ["LAPI_KEY"], lapi_url="http://crowdsec.crowdsec.local:8080/"
    )
    incoming_ip = event["requestContext"]["identity"]["sourceIp"]
    action_for_ip = cs_client.get_action_for(incoming_ip)
    if action_for_ip == "captcha":
        if (
            event["headers"].get("x-captcha-token")
            and event["headers"]["x-captcha-token"] not in valid_tokens
        ):
            if validate_captcha_resp(event["headers"]["x-captcha-token"]):
                valid_tokens.add(event["headers"]["x-captcha-token"])
                verdict = "Allow"
            else:
                verdict = "Deny"
        elif event["headers"].get("x-captcha-token") in valid_tokens:
            verdict = "Allow"

    if not action_for_ip:
        verdict = "Allow"

    return {
        "principalId": "my-username",
        "policyDocument": {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Action": "execute-api:Invoke",
                    "Effect": verdict,
                    "Resource": event.get("methodArn"),
                }
            ],
        },
        "context": {
            "org": "my-org",
            "role": "admin",
            "createdAt": "2019-01-03T12:15:42",
        },
    }
