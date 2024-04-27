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

def lambda_handler(event, _):
    """
    Lambda function main entry point. 
    Will download all page of a specific Confluence Space locally, 
    and then upload them to an S3 bucket
    """
    
    for message in event['Records']:
        body = json.loads(message['body'])
        page = json.loads(body.get("Message"))

        # Download file locally from export
        local_destination_dir = efs_mount_path + "/"
    
        print(page)
        wiki.download_file(confluence, int(page.get("page_id")), page.get("page_title"), local_destination_dir)

        # Upload file to S3
        file_path = local_destination_dir + page["page_id"] + ".pdf"
        s3_destination_name = destination_bucket_name
        s3_file_name = confluence_space + "/" + page["page_id"] + ".pdf"
        uploader.upload_file_to_s3(s3_destination_name, file_path, s3_file_name)


    print("Processor completely successfully")
