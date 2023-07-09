resource "aws_glue_job" "glue_job" {
  execution_class = "STANDARD"
  name            = var.glue_job_name
  role_arn        = var.role
  command {
    script_location = var.script_location
    name            = "glueetl"
    python_version  = "3"
  }
  default_arguments = {
    "--job-bookmark-option" = "job-bookmark-disable"
    "--datalake-formats"    = "delta"
    "--enable-auto-scaling" = "true"
    "--enable-job-insights" = "true"
    "--job-language"        = "python"
  }
  //max_capacity      = var.max_capacity
  glue_version      = var.glue_version
  timeout           = var.timeout
  worker_type       = var.worker_type
  number_of_workers = var.number_of_workers
  max_retries       = var.max_retries

}
