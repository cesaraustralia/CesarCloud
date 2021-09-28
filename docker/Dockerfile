FROM rocker/shiny:latest
LABEL Maintainer="rvalavi@cesaraustralia.com"

# install libraries of general use
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libxml2-dev \
    libcairo2-dev \
    libsqlite3-dev \
    libmysqlclient-dev \
    libpq-dev \
    libssh2-1-dev \
    unixodbc-dev \
    libcurl4-openssl-dev \
    libssl-dev \
    texlive \
    texlive-latex-extra \
    libgit2-dev \
    git

# install goespatial libraries
RUN apt-get update -qq && apt-get -y --no-install-recommends install \
    libgdal-dev \
    libgeos-dev \
    libgeotiff-dev \
    libjpeg-dev \
    libicu-dev \
    libproj-dev \
    libudunits2-dev \
    libhdf5-dev \
    libnetcdf-dev \
    netcdf-bin

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# install R packages
## install renv & restore packages
#RUN Rscript -e 'install.packages("renv")'
#RUN Rscript -e 'renv::consent(provided = TRUE)'
#RUN Rscript -e 'renv::restore()'
RUN Rscript -e 'install.packages(c("shiny","shinydashboard","shinythemes","shinyWidgets","shinyjs","shinyauthr","tableHTML"))'
RUN Rscript -e 'install.packages(c("tidyverse","data.table","viridis","lubridate","plotly","DT","reshape2","ggmap","ggtext","ggrepel","doParallel","rvest","cowplot"))'
RUN Rscript -e 'install.packages(c("rgdal","rgeos","ncdf4","sf","terra","tmap","maptools","leaflet"),dependencies=TRUE)'
RUN Rscript -e 'install.packages(c("DBI", "RPostgres", "pool", "dbplyr"), dependencies=TRUE)'
# expose port
EXPOSE 3838

# run app on container start
#CMD ["R", "-e", "shiny::runApp('/srv/shiny-server', host = '0.0.0.0', port = 3838)"]
