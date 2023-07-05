output "glue_job_name" {
  description = "The name of the Glue Job"
  value       = aws_glue_job.glue_job.name
}
