# Cesar Australia Cloud Infrastructure

Automation of creating and configuring AWS instances as Cesar infrastructure

## Setup

The `Public IPv4` is created manually and attached to the instance by `terraform data`

The `EBS` volume and `S3 bucket` is also created manually and then attached to the instance.

`awscil`
`docker`
`terraform`


## Infrastructure

- EC2
- EBS volume
- ECR
- S3 buckets

## Docker containers

Cesar server on AWS runs docker containers to build desired apps and deliver services.

- Shiny-spatial: a container with configured shiny server and all geospatial package for linux and R
- Postgis: a container runing PostgreSQL relational database with PostGIS extension for spatial data support 

The containers are created by `docker-compose`. The images id/url on the AWS Container Registery are inserted by `awk` shell commands.
