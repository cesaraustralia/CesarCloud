FROM rocker/shiny:4.2.0
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
    libproj-dev \
    libgdal-dev \
    libgeos-dev \
    libgeotiff-dev \
    libjpeg-dev \
    libicu-dev \
    libudunits2-dev \
    libhdf5-dev \
    netcdf-bin \
    libnetcdf-dev \
    libjq-dev # for googleway

## update system libraries
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get clean

# install R packages
## install renv & restore packages
#RUN Rscript -e 'install.packages("renv")'
#RUN Rscript -e 'renv::consent(provided = TRUE)'
#RUN Rscript -e 'renv::restore()'
RUN Rscript -e 'install.packages(c("shiny","shinydashboard","shinythemes","shinyWidgets","shinyjs","shinyauthr","tableHTML","shinycssloaders","leafsync"))'
RUN Rscript -e 'install.packages(c("devtools","tidyverse","data.table","viridis","lubridate","plotly","DT","reshape2","ggmap","ggtext","ggrepel","doParallel","rvest","cowplot"))'
RUN Rscript -e 'install.packages(c("rgdal","rgeos","ncdf4","sf","raster","tmap","maptools","leaflet","rasterVis"),dependencies=TRUE)'
RUN Rscript -e 'install.packages(c("DBI", "RPostgres", "pool", "dbplyr"), dependencies=TRUE)'
RUN Rscript -e 'devtools::install_github("rspatial/terra")'
# RUN Rscript -e 'install.packages(c("googleway"), dependencies=TRUE)'
# expose port
EXPOSE 3838
