from atlassian import Confluence
import wiki
import uploader
import os

confluence = Confluence(
    url=os.environ['WIKI_URL'],
    username=os.environ['ACCESS_TOKEN'],
    password=os.environ['SECRET_TOKEN']
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
    local_destination_dir = efs_mount_path + "/"
    s3_destination_name = destination_bucket_name

    wiki.download_files(confluence, confluence_space, local_destination_dir)
    uploader.upload_to_s3(local_destination_dir, s3_destination_name)

    print("Lambda handler completely successfully")
    
