FROM python:3.9.7-alpine3.14

WORKDIR /deploy

COPY . .

RUN apk add --no-cache bash jq zip \
    && pip3 install awscli boto3
