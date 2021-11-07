FROM szabogtamas/jupy_rocker

RUN sudo apt-get update -y && \
    sudo apt-get install -y libxt-dev && \
    sudo apt-get install -y libx11-dev && \
    sudo apt-get install -y libcairo2-dev && \
    sudo apt-get install -y libxml2-dev && \
    sudo apt-get install -y libbz2-dev && \
    sudo apt-get install -y liblzma-dev && \
    sudo apt-get install -y gsl-bin

RUN sudo apt-get install -y libgsl-dev

RUN pip3 install numpy && \
    pip3 install pandas && \
    pip3 install matplotlib && \
    pip3 install seaborn && \
    pip3 install openpyxl && \
    pip3 install pyBigWig

ENV PATH=/usr/local/bin:$PATH

RUN install2.r --error \
    --deps TRUE \
    devtools \
    rlang \
    RColorBrewer \
    ggsci \
    ggridges \
    plotly \
    openxlsx \
    readxl \
    homologene

RUN R -e "BiocManager::install('ggbio')"
RUN R -e "BiocManager::install('wiggleplotr')"
RUN R -e "BiocManager::install('EnsDb.Hsapiens.v86')"
RUN R -e "BiocManager::install('EnsDb.Mmusculus.v79')"
RUN R -e "BiocManager::install('TxDb.Dmelanogaster.UCSC.dm6.ensGene')"
RUN R -e "BiocManager::install('TxDb.Drerio.UCSC.danRer11.refGene')"
RUN R -e "BiocManager::install('BSgenome.Hsapiens.UCSC.hg19')"
RUN R -e "BiocManager::install('BSgenome.Mmusculus.UCSC.mm10')"
RUN R -e "BiocManager::install('BSgenome.Dmelanogaster.UCSC.dm6')"
RUN R -e "BiocManager::install('BSgenome.Drerio.UCSC.danRer10')"
RUN R -e "BiocManager::install('ensembldb')"
RUN R -e "BiocManager::install('TFBSTools')"
#RUN R -e "BiocManager::install('Gviz')"
RUN R -e "remotes::install_github('ivanek/Gviz')"

RUN chmod a+rwx -R /home/rstudio

ADD ./configs/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json