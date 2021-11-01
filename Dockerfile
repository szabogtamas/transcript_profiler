FROM szabogtamas/jupy_rocker

RUN sudo apt-get update -y && \
    sudo apt-get install -y libxt-dev && \
    sudo apt-get install -y libx11-dev && \
    sudo apt-get install -y libcairo2-dev

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
    readxl

RUN R -e "BiocManager::install('ggbio')"
RUN R -e "BiocManager::install('wiggleplotr')"
RUN R -e "BiocManager::install('EnsDb.Hsapiens.v86')"

RUN chmod a+rwx -R /home/rstudio

ADD ./configs/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json