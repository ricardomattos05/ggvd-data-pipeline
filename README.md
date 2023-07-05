# GGV Data Pipeline

Este projeto tem como objetivo construir um pipeline de dados para processar e analisar dados de filmes do IMDB e MovieLens. Os dados são extraídos desses sites, transformados e carregados para o Amazon S3.

O pipeline é composta por funções do AWS Lambda e filas do SQS para extração paralelizada, jobs do Glue para o processamento dos dados com Spark, além do uso do Glue para catalogar os dados, tornando-os disponíveis para consulta em SQL através do Athena. Todos os recursos são provisionados usando Terraform.

A arquitetura do pipeline é dividida em três etapas: Bronze, Prata e Ouro. A etapa Bronze lida com a extração de dados, a Prata com a transformação e a Ouro com a análise dos dados. Uma representação geral da arquitetura utilizada:

![Diagrama de Arquitetura](image/ggvd-architecture-image.drawio.svg)

## Pré-requisitos

- [Python 3.8](https://www.python.org/downloads/) or later
- [AWS CLI](https://aws.amazon.com/cli/)
- [AWS SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html) (para execução local da função lambda)
- [Docker](https://www.docker.com/get-started) (empacotar dependencias e executar a função lambda localmente com o mesmo OS do ambiente na AWS)
- [Make](https://www.gnu.org/software/make/) (Gerenciamento de tasks com Makefile)


## Estrutura do Projeto

```
.
├── Dockerfile
├── LICENSE
├── Makefile
├── README.md
├── configs.ini
├── data_pipeline
│   ├── __init__.py
│   ├── bronze
│   │   ├── __init__.py
│   │   ├── movilens
│   │   ├── tmdb
│   │   │   ├── movies
│   │   │   │   ├── __init__.py
│   │   │   │   ├── event.json
│   │   │   │   ├── lambda_function.py
│   │   │   │   ├── package.zip
│   │   │   │   ├── python.zip
│   │   │   │   ├── requirements.txt
│   │   │   │   └── test.py
│   │   │   └── start_extraction
│   │   │       ├── __init__.py
│   │   │       ├── lambda_function.py
│   │   │       └── package.zip
│   │   └── utils
│   │       ├── __init__.py
│   │       └── utils.py
│   ├── gold
│   │   ├── source
│   │   │   └── table
│   │   │       ├── __init__.py
│   │   └── utils
│   │       └── __init__.py
│   └── silver
│       ├── imdb
│       │   ├── __init__.py
│       │   ├── metadata_processing.py
│       │   ├── requirements.txt
│       │   ├── reviews_processing.py
│       │   └── test.py
│       ├── movie_lens
│       │   ├── __init__.py
│       │   ├── ratings_processing.py
│       │   ├── tag_count_processing.py
│       │   └── tags_processing.py
├── image
├── pyproject.toml
├── requirements.txt
├── template.yaml
├── terraform
│   ├── backend.tf
│   ├── glue_jobs.tf
│   ├── lambda_bronze.tf
│   ├── lambda_start.tf
│   ├── main.tf
│   ├── modules
│   │   ├── glue
│   │   ├── iam
│   │   ├── lambda
│   │   ├── lambda_layer
│   │   ├── s3
│   │   └── tags
│   ├── networking.tf
│   ├── sqs.tf
│   ├── terraform.tfvars
│   └── variables.tf
└── tests
```

- `data_pipeline`: Contém os scripts Python para as funções Lambda e os Glue jobs em pyspark.
- `terraform`: Contém os arquivos de configuração do Terraform para a criação da infraestrutura.
- `Dockerfile`: Usado para criar um ambiente de desenvolvimento replicável.
- `Makefile`: Contém comandos úteis para a construção e implantação do projeto.
- `template.yaml`: Template AWS SAM para a função Lambda.
- `configs.ini`: Arquivo de configuração que especifica a versão do python requerida e outras configurações.

Cada módulo de Terraform na pasta terraform/modules corresponde a uma parte da infraestrutura do AWS, incluindo IAM, Lambda, Glue e S3.

## Setting Up

1. Clone o repositório.

```
git clone git@github.com:ricardomattos05/ggvd-data-pipeline.git
```

2. cd ggvd-data-pipeline

3. Run `make init` to create a virtual environment, install the required Python packages, and set up pre-commit hooks.

4. Inicialize o terraform:

```
cd terraform/
terraform init
```

5. Execute o Terraform e faça o deploy dos recursos(AWS CLI e credenciais precisam estar configurados):

```
terraform apply (e digitite yes quando vir o plano de execução)
ou
terraform apply --auto-approve
```

## Processamento de Dados

O processamento de dados é dividido em três estágios: bronze, prata e ouro.

- **bronze**: Os dados são extraídos do IMDB e MovieLens através de funções Lambda disparadas por intervalos de páginas a serem requisitadas pelas filas AWS SQS. Os dados extraídos são armazenados no bucket bronze do S3 em formato JSON.

- TO DO: incluir diagrama dos componentes para a etapa bronze

-  **prata**: Os dados JSON são processados por jobs do AWS Glue, utilizando pyspark. Os jobs do Glue transformam os dados com limpezas basicas como, tratamento de valores faltantes, deduplicação de linhas, criação de novos campos, etc.. para um formato mais fácil de analisar e os armazenam de volta no S3 como tabelas Delta. Aqui também é utilizado o crawler do Glue para mapear as partições, e tabelas do database uffic_silver_db.

- TO DO: incluir diagrama dos componentes para a etapa silver

- **ouro**: Os dados transformados são usados para análises mais detalhadas e prontas para consumo, como:

* TO DO: incluir perguntas e tabelas da camada ouro
