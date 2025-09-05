import os
import json
import time
import requests
import boto3
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

SNS_TOPIC_ARN = os.environ.get("SNS_TOPIC_ARN")
SERVICES = [
    "https://example.com",
    "https://api.github.com",
    "https://doesnotexist.abcxyz"
]

sns_client = boto3.client("sns")

def lambda_handler(event, context):
    results = []
    for url in SERVICES:
        start = time.time()
        try:
            resp = requests.get(url, timeout=5)
            latency = (time.time() - start) * 1000
            status = resp.status_code
            ok = status == 200 and latency < 500
        except Exception as e:
            latency = None
            status = None
            ok = False
            logger.error(f"Exception checking {url}: {e}")

        result = {
            "url": url,
            "status": status,
            "latency_ms": latency,
            "ok": ok
        }
        results.append(result)

        if not ok:
            # Log failures (HTTP errors or slow responses)
            logger.warning(f"{url} failed check: status={status}, latency={latency}")
            try:
                sns_client.publish(
                    TopicArn=SNS_TOPIC_ARN,
                    Message=json.dumps(result),
                    Subject=f"ALERT: {url} check failed"
                )
                logger.info(f"SNS alert sent for {url}")
            except Exception as e:
                logger.error(f"SNS publish failed for {url}: {e}")
        else:
            logger.info(f"{url} passed check: status={status}, latency={latency:.2f} ms")

    return {"results": results}

