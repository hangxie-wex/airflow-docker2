# rp-expedia-recon

This repository contains the code for the DAGs as well as the custom code to ingest files, calculate audits, reconcile payments by transaction, and create reports for the full Expedia Reconciliation Process. This file describe the steps to setup the local development environment. The development env consists of the following docker containers: Airflow, MS SQL Server, sftp server and LocalStack which is used to simulate the AWS services such as S3, Secret Manager, etc.

## Prerequisites

Install the following applications

- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- SQL Client (e.g.: [DBeaver](https://dbeaver.io/download/))
- [awscli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
- [awslocal](https://docs.localstack.cloud/aws/integrations/aws-native-tools/aws-cli/#localstack-aws-cli-awslocal)

### For Windows

If you downloaded the AWSCLIV2.msi installer and the setup requires admin privileges to install, run the following command in the folder where you downloaded it:

```
msiexec /a %USERPROFILE%\Downloads\AWSCLIV2.msi /qb TARGETDIR=%USERPROFILE%\awscli
```

Then add the following path to your PATH environment variable:

`%USERPROFILE%\awscli\Amazon\AWSCLIV2`

### For Macbook

Use homebrew to install awslocal and awscli by running the following commands:   

```
brew update
brew install awscli
brew install awscli-local
```

## Bring up local containers

There are two ways to bring up all the containers.

### Method 1

In the project directory, run the following command to build images for services:

`./local-setup.sh`

### Method 2

 Following the procedure
* In the project directory, run the following command to build images for services:

`docker-compose build --no-cache > build_output.log 2>&1`

If the command failed, remove `--no-cache` and re-run the command.

* Start all the services defined in docker-compose.yaml file:

`docker compose up -d`

* Verify all the services are up and running:

`docker ps -a`

## Local Development Environment

The setup should bring up the following services: 

* an Apache Airflow service. The Web UI can be launched at: `http://127.0.0.1:8090` with credential `airflow/airflow`.
* MS SQL Server.  It can be accessed with a SQL Client (such DBeaver)
```
Host: localhost
Port: 1433
Database/Schema: master
Authentication: SQL Server Authentication
Username: SA
Password: WexAdmin1!
```
* A sftp server. We can ssh to the sftp server: 
```
sftp -P 2222 sftpuser@127.0.0.1
```
using the password: `password`

* A local aws service(LocalStack). 

It also executed the scripts `./scripts/init-localstack.sh`  and created the following objects:

1. a S3 bucket `s3://expedia-recon`

2. Three Secret Manager objects: `local/RiskPlatform/expedia_s3_conn` to connect to local S3, `local/RiskPlatform/expedia-sftp-conn` and `local/RiskPlatform/wex-sftp-conn` to connect to local sftp servers, and `local/RiskPlatform/srsvc_db_conn` to connect to local MS SQL server.


## Local S3 operations

* Create a bucket in LocalStack:

`awslocal s3 mb s3://expedia-recon`

* Upload a test file to your local S3 bucket:

`echo "Hello from LocalStack S3!" > test_file.txt`

`awslocal s3 cp test_file.txt s3://expedia-recon/test_file.txt`

* Verify the file is in your local S3 bucket:

`awslocal s3 ls s3://expedia-recon/`

## Airflow connection setup

This section is optional. It is not needed if we use AWS Secret Manager to manager the crendentials.
 Login to `http://127.0.0.1:8090` and  click Admin then connections. The follwoing connections should be added. 
* MS SQL Server Connection:
```
Connection ID: mssql_conn
Connection Type: mssql
Host: sql_server_test
Login: sa
Password:  WexAdmin1!
Port: 1433
Schema: master
```
* AWS Connection
```
Connection ID: aws_default
Connection Type: aws
Access Key Id: test
Secret Access Key: test
region_name:  us-east-1
endpoint_url: http://localstack:4566
Extra Fields JSON: { "region_name": "us-east-1", "endpoint_url": "http://localstack:4566"}
```
## Rebuild

In case rebuild is needed, then run the following command to clean up: 
```
docker compose down -v
```
and then rerun the following command to build images for services:
```
docker-compose build --no-cache > build_output.log 2>&1
```
## Workaround

* If the http to airflow webpage, db connection to MS SQL or sftp request got hung, restart the apiserver container, MS SQL server container, or sftp container
1. find the container ID
```
docker ps -a 
```

2. Restart the container
```
docker restart <containerId>
```
* If sftp command got rejected, run the following commands to clear the local key and force to regenerate the key in the next request and then run sfto command
```
ssh-keygen -R "[127.0.0.1]:2222"
```

* If webserver and scheduler cannot be up complaining DB already initialized, remove the folder postgres in project directory to force the airflow to reinitialize the DB

```
rm -rf postgres
```

## Troubleshooting

* Check the DAG list or the import errors. Find the container id of appserver and run the following command: 
```
docker exec -it 1a88d73406a6 airflow dags list-import-errors
docker exec -it 71ed1ffcd163 airflow dags list
```
* Check if the package is properly installed. Find the container of appserver or schedule and run the following commands:
```
docker exec -it 627f56d9d5bd bash
pip freeze | grep apache-airflow-providers-microsoft-mssql
```