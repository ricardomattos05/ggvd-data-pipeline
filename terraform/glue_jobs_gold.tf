#### Job Movies With Ratings Table
resource "aws_s3_object" "object_movies_analytics" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/job_movies_analytics.py"
  source = "../data_pipeline/gold/movie_analysis/movies_analytics/job_movies_analytics.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_movies_analytics" {
  source = "./modules/glue"

  glue_job_name     = "gold_movies_analytics_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_gold_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object_movies_analytics.key}"
  glue_version      = "3.0"
  timeout           = 10
  worker_type       = "G.1X"
  number_of_workers = 3
  max_retries       = 0
}


#### Job Popularity Actors and Directors By Decade
resource "aws_s3_object" "object_popularity_decade" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/job_popularity_decade.py"
  source = "../data_pipeline/gold/movie_analysis/popularity_decade/job_popularity_decade.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_popularity_decade" {
  source = "./modules/glue"

  glue_job_name     = "gold_popularity_decade_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_gold_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object_popularity_decade.key}"
  glue_version      = "3.0"
  timeout           = 10
  worker_type       = "G.1X"
  number_of_workers = 3
  max_retries       = 0
}



#### Job Movies With Ratings Table
resource "aws_s3_object" "object_tags_ratings" {
  bucket = module.s3.s3_bucket_name["aws-glue-assets"]
  key    = "glue_scripts/job_tags_ratings.py"
  source = "../data_pipeline/gold/movie_analysis/movies_analytics/job_tags_ratings.py"
  acl    = "private"

  depends_on = [module.s3]
}

module "glue_tags_ratings" {
  source = "./modules/glue"

  glue_job_name     = "gold_tags_ratings_job"
  role              = aws_iam_role.AWSGlueServiceRole.arn
  database_name     = "uffic_gold_db"
  script_location   = "s3://${module.s3.s3_bucket_name["aws-glue-assets"]}/${aws_s3_object.object_tags_ratings.key}"
  glue_version      = "3.0"
  timeout           = 10
  worker_type       = "G.1X"
  number_of_workers = 3
  max_retries       = 0
}
