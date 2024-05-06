import mdfconfluence 
import wiki
import uploader
import os
import json


confluence = mdfconfluence.MdfConfluence(
    url=os.environ['WIKI_URL'],
    username=os.environ['ACCESS_TOKEN'],
    password=os.environ['SECRET_TOKEN'],
    api_version="cloud"
)

efs_mount_path=os.environ['EFS_MOUNT_PATH']
destination_bucket_name=os.environ['KNOWLEDGE_BASE_BUCKET']

def lambda_handler(event, _):
    """
    Lambda function main entry point. 
    Will download a given confluence page locally, 
    and then upload them to an S3 bucket
    """
    confluence.get_content_history
    for message in event['Records']:
        body = json.loads(message['body'])
        page = json.loads(body.get("Message"))

        page_id = page.get("page_id")
        page_title = page.get("page_title")
        page_space = page.get("page_space")

        # Download file locally from export
        local_destination_dir = efs_mount_path + "/"
    
        print(page)
        local_file_path = wiki.download_file(confluence, int(page_id), page_title, local_destination_dir)

        # Upload file to S3
        s3_destination_name = destination_bucket_name
        s3_file_name = page_space + "/" + page_id + ".pdf"
        uploader.upload_file_to_s3(s3_destination_name, local_file_path, s3_file_name)

    print("Processor completely successfully")
