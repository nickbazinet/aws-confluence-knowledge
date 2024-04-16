import boto3
import os

s3 = boto3.client('s3')

def upload_to_s3(local_dir: str, bucket_name: str):
    """
    Upload all files inside the local directory to a specific S3 bucket. 
    This function will compare the size of each file locally version inside
    the bucket in order to only upload files that defer
    """
    s3_object_list_response = s3.list_objects_v2(Bucket=bucket_name)
    if s3_object_list_response['KeyCount'] == 0:
        upload_full_directory(local_dir, bucket_name)
    else:
        s3_objects = s3_object_list_response['Contents']
        for root, _, files in os.walk(local_dir):
            for file in files:
                local_file_path = os.path.join(root, file)
                relative_path = os.path.relpath(local_file_path, local_dir)
                existing_file = next((obj for obj in s3_objects if obj['Key'] == relative_path), None)
                if not existing_file or os.path.getsize(local_file_path) != existing_file['Size']:
                    s3.upload_file(local_file_path, bucket_name, relative_path)
                    print(f"Uploaded {local_file_path} to s3://{bucket_name}/{relative_path}")

def upload_full_directory(local_dir: str, bucket_name: str):
  """
  Uploads the contents of a local directory to an S3 bucket.

  Args:
    local_dir: The path to the local directory to upload.
    bucket_name: The name of the S3 bucket to upload to.
  """
  for root, _, files in os.walk(local_dir):
    for file in files:
      local_file_path = os.path.join(root, file)
      relative_path = os.path.relpath(local_file_path, local_dir)
      s3.upload_file(local_file_path, bucket_name, relative_path)
      print(f"Uploaded {local_file_path} to s3://{bucket_name}/{relative_path}")
