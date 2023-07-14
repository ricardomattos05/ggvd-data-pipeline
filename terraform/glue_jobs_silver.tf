#### ROLE AND POLICIE FOR GLUE JOBS

module "iam_policy_glue" {
  source  = "cloudposse/iam-policy/aws"
  version = "0.4.0"

  iam_policy_statements = {
    GlueFullAccess = {
      effect    = "Allow"
      actions   = ["glue:*"]
      resources = ["*"]
    }
    S3Access = {
      effect    = "Allow"
      actions   = ["s3:*", "s3-object-lambda:*"]
      resources = ["*"]
    }
  }
}

data "aws_iam_policy_document" "assume_role_glue" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "AWSGlueServiceRole" {
  name               = "AWSGlueServiceRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role_glue.json

  inline_policy {
    name   = "glue_policy"
    policy = module.iam_policy_glue.json
  }
}

#### Job Movies Metadata Table
resource "aws_s3_object" "object" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/metadata_processing.py"
  source = "../data_pipeline/silver/imdb/metadata_processing.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_movies_metadata" {
  source = "./modules/glue"

  glue_job_name     = "silver_metadata_processing_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_silver_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object.key}"
  glue_version      = "3.0"
  timeout           = 10
  worker_type       = "G.1X"
  number_of_workers = 3
  max_retries       = 0
}

#### Job Reviews Table
resource "aws_s3_object" "object_reviews" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/reviews_processing.py"
  source = "../data_pipeline/silver/imdb/reviews_processing.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_reviews" {
  source = "./modules/glue"

  glue_job_name     = "silver_reviews_processing_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_silver_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object_reviews.key}"
  glue_version      = "3.0"
  timeout           = 20
  worker_type       = "G.1X"
  number_of_workers = 5
  max_retries       = 0
}

#### Job Tags Table
resource "aws_s3_object" "object_tags" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/tags_processing.py"
  source = "../data_pipeline/silver/movie_lens/tags_processing.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_tags" {
  source = "./modules/glue"

  glue_job_name     = "silver_tags_processing_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_silver_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object_tags.key}"
  glue_version      = "3.0"
  timeout           = 10
  worker_type       = "G.1X"
  number_of_workers = 2
  max_retries       = 0
}

#### Job Tags Count Table
resource "aws_s3_object" "object_tag_count" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/tag_count_processing.py"
  source = "../data_pipeline/silver/movie_lens/tag_count_processing.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_tag_count" {
  source = "./modules/glue"

  glue_job_name     = "silver_tag_count_processing_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_silver_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object_tag_count.key}"
  glue_version      = "3.0"
  timeout           = 10
  worker_type       = "G.1X"
  number_of_workers = 2
  max_retries       = 0
}

#### Job Ratings Table
resource "aws_s3_object" "object_ratings" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/ratings_processing.py"
  source = "../data_pipeline/silver/movie_lens/ratings_processing.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_ratings" {
  source = "./modules/glue"

  glue_job_name     = "silver_ratings_processing_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_silver_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object_ratings.key}"
  glue_version      = "3.0"
  timeout           = 10
  worker_type       = "G.1X"
  number_of_workers = 5
  max_retries       = 0
}
