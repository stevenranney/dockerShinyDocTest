FROM rocker/verse:3.5.1

MAINTAINER Steven H. Ranney

RUN export ADD=shiny && bash /etc/cont-init.d/add

RUN tlmgr update --self 
RUN tlmgr install beamer translator

RUN R -e "install.packages(c('shiny', 'googleAuthR', 'dplyr', 'googleAnalyticsR', 'knitr', 'rmarkdown', 'jsonlite', 'scales', 'ggplot2', 'reshape2', 'Cairo', 'tinytex'), repos = 'https://cran.rstudio.com/')"

#Copy app dir and them dirs to their respective locations
COPY app /srv/shiny-server/
COPY app/report/themes/SwCustom /opt/TinyTeX/texmf-dist/tex/latex/beamer/

#Force texlive to find my custom beamer thems

RUN texhash

EXPOSE 3838

COPY shiny-server.sh /usr/bin/shiny-server.sh

## Uncomment the line below to include a custom configuration file. You can download the default file at
## https://raw.githubusercontent.com/rstudio/shiny-server/master/config/default.config
## (The line below assumes that you have downloaded the file above to ./shiny-customized.config)
## Documentation on configuration options is available at
## http://docs.rstudio.com/shiny-server/

COPY shiny-customized.config /etc/shiny-server/shiny-server.conf

RUN apt-get update && apt-get install -y dos2unix

RUN dos2unix /usr/bin/shiny-server.sh && apt-get --purge remove -y dos2unix && rm -rf /var/lib/apt/lists/*

CMD ["/usr/bin/shiny-server.sh"]






