# Documentation of the Cesar Cloud Server Configuration
## Overview

Here is an overview of the workflow and major components of the server
and the services provided. Each component will be explained in the
following sections.

<img src="AWS_architecture.jpg" width="700" style="display: block; margin: auto;" />

## Software and resources

-   Terraform resource:

-   Ansible resource:

-   Docker resource:

-   GitHub action resouece:

## Terraform configuration

## Ansible configuration

## Docker containers

### Shiny server and apps

### PostgreSQL database

### Database API

## GitHub actions
The GitHub action is used to automatically deploy new/updated apps to the server. This is done through SSH and rsync tools when the GitHub action is defined for a repository. The action is triggered by a push/pull-request to the main/master branch. The same thing can be done manually: 1) SSH into the main server 2) go to the /srv/shiny-server/ 3) pull the repo of the app

Requirements for the GithHub action to work:
 - define the GitHub action in .github/workflows
 - make sure the repo has access to the Cesar secret keys
 - make sure the R packages (and Linux system libraries) are available in the shiny docker container
