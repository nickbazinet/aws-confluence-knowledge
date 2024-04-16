resource "aws_efs_file_system" "wiki_download" {
  creation_token   = "wiki-upload-efs"
  encrypted        = true
  kms_key_id       = aws_kms_key.encryption_key.arn
  performance_mode = "generalPurpose"

  tags = {
    Name = "wiki-upload-efs"
  }
}

resource "aws_efs_mount_target" "wiki_download_1" {
  file_system_id  = aws_efs_file_system.wiki_download.id
  subnet_id       = data.aws_subnet.private1.id
  security_groups = [aws_security_group.wiki_knowledge_export.id]
}

resource "aws_efs_access_point" "wiki_download" {
  file_system_id = aws_efs_file_system.wiki_download.id

  posix_user {
    gid = 0
    uid = 0
  }

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 0
      owner_uid   = 0
      permissions = "0777"
    }
  }
}
