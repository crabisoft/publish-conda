FROM continuumio/miniconda3:latest

RUN conda install -y -c conda-forge anaconda-client conda-build conda-verify numpy

COPY entrypoint.sh /entrypoint.sh

RUN ["chmod", "+x", "/entrypoint.sh"]

ENTRYPOINT ["/entrypoint.sh"]
