# Cesar Australia Cloud Infrastructure

Automation of creating and provisioning AWS instances as Cesar infrastructure

## Setup

The `Public IPv4` is created manually and attached to the instance by `terraform data`. The main `S3 bucket` is also created manually to protect our data from being lost through system failure/upgrade.

System setup is by Terraform open source infrastructure as code (IaC) software tool. All the servises are containerised by Docker.

`terraform`
`docker`
`awscil`


## Infrastructure

- EC2: elastic cloud computing - a linux server
- ECR: elastic container registery - stores Cesar docker images
- S3 buckets: Cesar cloud data centre

## Docker containers

Cesar server on AWS runs docker containers to build desired apps and deliver services.

- Shiny server: a container with configured shiny-server and all geospatial packages for Linux and R
- Rstudio server: accessing RStudio via Cesar server at AWS
- PostGIS: a container running PostgreSQL relational database with PostGIS extension for spatial data support 

The containers are created by `docker-compose`. The images id/URL on the AWS Container Registery are inserted by `awk` shell commands as terraform variables.

## PostgreSQL database
The database is a PostgreSQL running inside a docker container. The database and all data inside are backup every week and stored in the main S3 bucket.
