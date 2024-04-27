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

confluence_space=os.environ['WIKI_SPACE']
efs_mount_path=os.environ['EFS_MOUNT_PATH']
destination_bucket_name=os.environ['KNOWLEDGE_BASE_BUCKET']

def lambda_handler(event, context):
    """
    Lambda function main entry point. 
    Will download all page of a specific Confluence Space locally, 
    and then upload them to an S3 bucket
    """
    print(f"Lambda event: {event} | Lambda context: {context}")
    
    for message in event['Records']:
        page = json.load(message['body'])

        # Download file locally from export
        local_destination_dir = efs_mount_path + "/"
    
        wiki.download_file(confluence, page["page_id"], page["page_title"], local_destination_dir)

        # Upload file to S3
        file_path = local_destination_dir + page["page_id"] + ".pdf"
        s3_destination_name = destination_bucket_name
        uploader.upload_file_to_s3(s3_destination_name, file_path, confluence_space + page["page_id"] + ".pdf" )


    print("Lambda handler completely successfully")
