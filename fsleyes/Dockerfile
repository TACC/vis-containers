FROM continuumio/miniconda3:4.11.0

RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y libxxf86vm-dev \
                       libgl-dev

RUN conda install -c conda-forge fsleyes
