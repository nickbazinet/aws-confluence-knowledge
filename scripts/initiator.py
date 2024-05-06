import mdfconfluence 
import os
import boto3
import json

sns_client = boto3.client('sns')

confluence = mdfconfluence.MdfConfluence(
    url=os.environ['WIKI_URL'],
    username=os.environ['ACCESS_TOKEN'],
    password=os.environ['SECRET_TOKEN']
)

confluence_spaces=os.environ['WIKI_SPACE'].replace(" ","").split(",")
efs_mount_path=os.environ['EFS_MOUNT_PATH']
destination_bucket_name=os.environ['KNOWLEDGE_BASE_BUCKET']
event_topic_arn=os.environ['WIKI_SNS_TOPIC_ARN']


def lambda_handler(event, context):
    """
    Lambda function main entry point.
    Will get a list of all confluence page, and create a related
    SNS event for each. This will allow downstream 
    processor to handle each page at its pace.
    """
    for confluence_space in confluence_spaces:
        pgs = confluence.get_all_pages_from_space(
            confluence_space,
            0,
            limit=2000,
            status="current",
            content_type="page",
        )

        for page in pgs:
            message = {
                "page_id": page.get("id"),
                "page_title": page.get("title"),
                "page_space": confluence_space
            }
            message_str = json.dumps(message)

            response = sns_client.publish(
                TopicArn=event_topic_arn,
                Message=message_str,
                Subject="Confluence Page Process Request"
            )
            print(response)


