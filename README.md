# Lambda Pipeline Template

This project serves as a template for creating and managing AWS Lambda functions using Python.

## Prerequisites

- [Python 3.8](https://www.python.org/downloads/) or later
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
- [Docker](https://www.docker.com/get-started) (for packaging dependencies and local testing)
- [Make](https://www.gnu.org/software/make/) (for managing tasks with Makefile)


## Project Structure

```
.
├── Makefile
├── README.md
├── configs.ini
├── config.json
├── event.json
├── packaged.yaml
├── requirements.txt
├── src
│   └── bronze
│       ├── source
│       │   ├── table
│       │   │   ├── lambda_function.py
│       │   │   └── requirements.txt
│       │   └── table2
│       │       ├── lambda_function.py
│       │       └── requirements.txt
│       └── utils
│           └── shared.py
│   └── silver
│       ├── ...
│   └── gold
│       ├── ...
└── template.yaml
```


- `src`: Contains the source code of Lambda functions organized in subdirectories.
- `template.yaml`: The AWS SAM template file used for deploying Lambda functions and their dependencies.
- `Makefile`: A file containing a set of tasks to simplify building, packaging, and deploying your Lambda functions.
- `configs.ini`: A configuration file for specifying required Python versions and other settings.

## Setting Up

1. Clone the repository with the project structure and files.
2. Run `make init` to create a virtual environment, install the required Python packages, and set up pre-commit hooks.

## Testing

To run tests, execute the following command:

```bash
make test
```

This command will run the tests located in the tests folder, with each test subfolder corresponding to a Lambda function in the src folder.

## Packaging and Deploying
To package your Lambda function code and its dependencies, set the FUNCTION_DIR variable and run the package command:

```bash
make package FUNCTION_DIR=src/bronze/source/table
```

This command will create a `package.zip` file containing your Lambda function code and a `python.zip` file containing the required dependencies.


## Local Testing
To invoke a Lambda function locally using AWS SAM, run the following command:

```bash
make invoke-local-bronze-endpoint1
```

This command will use the event.json file to simulate an event and execute the specified Lambda function.

## Linting
To apply linters to your code, run the following command:

```bash
make lint
```
