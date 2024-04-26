from urllib3.util import response
import mdfconfluence 
import wiki
import uploader
import os
import boto3
import json

confluence = mdfconfluence.MdfConfluence(
    url=os.environ['WIKI_URL'],
    username=os.environ['ACCESS_TOKEN'],
    password=os.environ['SECRET_TOKEN']
)

confluence_space=os.environ['WIKI_SPACE']
efs_mount_path=os.environ['EFS_MOUNT_PATH']
destination_bucket_name=os.environ['KNOWLEDGE_BASE_BUCKET']
event_topic_arn=os.environ['WIKI_SNS_TOPIC_ARN']


def lambda_handler(event, context):
    """
    Lambda function main entry point. 
    Will download all page of a specific Confluence Space locally, 
    and then upload them to an S3 bucket
    """
    print(f"Lambda event: {event} | Lambda context: {context}")
    local_destination_dir = efs_mount_path + "/"
    s3_destination_name = destination_bucket_name

    wiki.download_files(confluence, confluence_space, local_destination_dir)
    uploader.upload_to_s3(local_destination_dir, s3_destination_name)

    print("Lambda handler completely successfully")
    

def lambda_handler_v2(event, context):
    """
    Lambda function main entry point, V2.
    Will get a list of all confluence page, and create a related
    SNS event for each. This will allow downstream 
    processor to handle each page at its pace.
    """
    print(f"Lambda event: {event} | Lambda context: {context}")
    sns_client = boto3.client('sns')
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
            "page_title": page.get("title")
        }
        message_str = json.dumps(message)

        response = sns_client.publish(
            TopicArn=event_topic_arn,
            Message=message_str,
            Subject="Confluence Page Process Request"
        )
        print(response)


