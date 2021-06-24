# Base image https://hub.docker.com/u/rocker/
FROM rocker/shiny:latest
LABEL Author="Roozbeh Valavi" Email="rvalavi@cesaraustralia.com"

# RUN commands are executed inside the containers
# system libraries of general use
## install debian packages
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    # dependency
    libmysqlclient-dev \
#    libmariadb-dev \
#    libmariadbd-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    libgit2-dev \
# the goespatial packages
    libgdal-dev \
    libgeos-dev \
    libgeotiff-dev \
    libjpeg-dev \
    libicu-dev \
    libproj-dev \ 
    libudunits2-dev
# libcurl4-gnutls-dev


## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean


# clone shiny apps from github
#RUN mkdir -p /srv/shiny-server
#RUN git clone git@github.com:cesaraustralia/daragrub.git /srv/shiny-server/daragrub

# copy necessary files
## app folder
#COPY /home/rvalavi/Projects/daragrub/ /srv/shiny-server
## renv.lock file
#COPY /example-app/renv.lock ./renv.lock

# install R packages
## install renv & restore packages
#RUN Rscript -e 'install.packages("renv")'
#RUN Rscript -e 'renv::consent(provided = TRUE)'
#RUN Rscript -e 'renv::restore()'
RUN Rscript -e 'install.packages(c("shiny","shinydashboard","shinythemes"))'
RUN Rscript -e 'install.packages(c("tidyverse","data.table","viridis","lubridate","plotly","DT","reshape2","ggmap","dbplyr","doParallel","rvest","cowplot"))'
RUN Rscript -e 'install.packages(c("rgdal","rgeos","sf","terra","tmap","maptools","leaflet"))'

# expose port
EXPOSE 3838

# run app on container start
#CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host = '0.0.0.0', port = 3838)"]
