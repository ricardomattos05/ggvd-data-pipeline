{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "athena:StartQueryExecution",
          "athena:GetQueryExecution",
          "athena:GetQueryResults",
          "athena:GetWorkGroup",
          "athena:ListNamedQueries",
          "athena:ListQueryExecutions",
          "athena:GetNamedQuery",
          "athena:CreateNamedQuery",
          "athena:DeleteNamedQuery",
          "athena:StopQueryExecution"
        ],
        "Resource": [
          "arn:aws:athena:eu-central-1:473178649040:workgroup/wg_uffic_dev",
          "arn:aws:athena:eu-central-1:473178649040:workgroup/primary",
          "arn:aws:athena:eu-central-1:473178649040:workgroup/wg_uffic_dev/*",
          "arn:aws:athena:eu-central-1:473178649040:database/uffic_silver_db",
          "arn:aws:athena:eu-central-1:473178649040:database/uffic_silver_db/*",
          "arn:aws:s3:::uffic-athena-eucentral1-473178649040-dev",
          "arn:aws:s3:::uffic-athena-eucentral1-473178649040-dev/*"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "glue:GetDatabase",
          "glue:GetDatabases",
          "glue:GetTable",
          "glue:GetTables",
          "glue:GetPartitions"
        ],
        "Resource": [
          "arn:aws:glue:eu-central-1:473178649040:catalog",
          "arn:aws:glue:eu-central-1:473178649040:database/uffic_silver_db",
          "arn:aws:glue:eu-central-1:473178649040:database/uffic_silver_db/*",
          "arn:aws:glue:eu-central-1:473178649040:table/uffic_silver_db/*"
        ]
      }
    ]
  }
