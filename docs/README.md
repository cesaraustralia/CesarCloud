# Documentation of the Cesar Cloud Server Configuration
## Overview

Here is an overview of the workflow and major components of the server
and the services provided. Each component will be explained in the
following sections.

<img src="AWS_architecture.jpg" width="700" style="display: block; margin: auto;" />


## AWS services



## Software and learning resources

-   Terraform resource:

-   Ansible resource:

-   Docker resource:

-   GitHub action resouece:

## Terraform configuration

## Ansible configuration
Ansible is used for configuring the Linux server. It's responsible for: installing the Linux libraries and apps; pulling the GitHub repos for the apps; setting up the docker containers for the shiny, Postgres, and API; and creating auto-backup for the database.

The abovementioned tasks are defined by a set of *roles* that are run in sequence. It is important to know which operation to run in order to get the next step successful. The roles are defined (in order) as:
- setup_database
- install_packages
- setup_shinyapps
- setup_containers
- setup_backups

## Docker containers

### Shiny server and apps

### PostgreSQL database

### Database API

To set up all containers and their networks, connections, and volumes we used `docker-compose` file. The docker-compose is simple enough to get everything up and running, but in a more complex setup `Kubernetes` container orchestration might be a better choice.

## GitHub actions
The GitHub action is used to automatically deploy new/updated apps to the server. This is done through SSH and rsync tools when the GitHub action is defined for a repository. The action is triggered by a push/pull-request to the main/master branch. The same thing can be done manually: 1) SSH into the main server 2) go to the `/srv/shiny-server/` 3) pull the repo of the app

Requirements for the GithHub action to work:
 - define the GitHub action in `.github/workflows`
 - make sure the repo has access to the Cesar *GitHub secrets*
 - make sure the R packages (and Linux system libraries) are available in the shiny docker container
