FROM public.ecr.aws/sam/build-python3.9:latest-x86_64

RUN yum -y update && yum install -y zip

ARG FUNCTION_DIR
WORKDIR /app

COPY ${FUNCTION_DIR}/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
