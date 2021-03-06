FROM szabogtamas/jupy_rocker

RUN sudo apt-get update -y && \
    sudo apt-get install -y libxt-dev && \
    sudo apt-get install -y libx11-dev && \
    sudo apt-get install -y libcairo2-dev && \
    sudo apt-get install -y libxml2-dev && \
    sudo apt-get install -y libbz2-dev && \
    sudo apt-get install -y liblzma-dev && \
    sudo apt-get install -y gsl-bin && \
    sudo apt-get install -y tcsh && \
    sudo apt-get install -y libglpk-dev && \
    sudo apt-get install -y r-cran-rgl

RUN sudo apt-get install -y libgsl-dev

RUN pip3 install numpy v==1.20&& \
    pip3 install pandas && \
    pip3 install matplotlib && \
    pip3 install seaborn && \
    pip3 install openpyxl && \
    pip3 install pyBigWig && \
    pip3 install ensembl_rest && \
    pip3 install tspex && \
    pip3 install brokenaxes && \
    pip3 install scanpy

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
RUN R -e "BiocManager::install('EnsDb.Mmusculus.v79')"
RUN R -e "BiocManager::install('TxDb.Dmelanogaster.UCSC.dm6.ensGene')"
RUN R -e "BiocManager::install('TxDb.Drerio.UCSC.danRer11.refGene')"
RUN R -e "BiocManager::install('BSgenome.Hsapiens.UCSC.hg19')"
RUN R -e "BiocManager::install('BSgenome.Mmusculus.UCSC.mm10')"
RUN R -e "BiocManager::install('BSgenome.Dmelanogaster.UCSC.dm6')"
RUN R -e "BiocManager::install('TxDb.Dmelanogaster.UCSC.dm6.ensGene')"
RUN R -e "BiocManager::install('BSgenome.Drerio.UCSC.danRer10')"
RUN R -e "BiocManager::install('TxDb.Drerio.UCSC.danRer10.refGene')"
RUN R -e "BiocManager::install('org.Xl.eg.db')"
RUN R -e "BiocManager::install('ensembldb')"
RUN R -e "BiocManager::install('TFBSTools')"
#RUN R -e "BiocManager::install('Gviz')"
RUN R -e "remotes::install_github('ivanek/Gviz')"
RUN R -e "BiocManager::install('AnnotationHub')"
RUN R -e "BiocManager::install('msa')"
RUN R -e "BiocManager::install('ggmsa')"
RUN R -e "BiocManager::install('seqinr')"
RUN R -e "BiocManager::install('bios2mds')"
RUN R -e "BiocManager::install('seqmagick')"
RUN R -e "BiocManager::install('WGCNA')"
RUN R -e "BiocManager::install('clusterProfiler')"

RUN install2.r --error \
    --deps TRUE \
    homologene \
    ggseqlogo    

ADD ./third_party/CBS /usr/local/lib/third_party/CBS
RUN mkdir -p /usr/cbs/packages && \
  tar -xvzf /usr/local/lib/third_party/CBS/netNglyc-1.0d.Linux.tar.gz -C /usr/cbs/packages && \
  sed -i 's#/usr/cbs/packages/netNglyc/1.0/netNglyc-1.0#/usr/cbs/packages/netNglyc-1.0#g' /usr/cbs/packages/netNglyc-1.0/netNglyc && \
  sed -i 's#/usr/bin/gawk#/usr/bin/awk#g' /usr/cbs/packages/netNglyc-1.0/netNglyc && \
  tar -xvzf /usr/local/lib/third_party/CBS/netOglyc-3.1e.Linux.tar.gz -C /usr/cbs/packages && \
  sed -i 's#/usr/cbs/packages/netOglyc/3.1/netOglyc-3.1d#/usr/cbs/packages/netOglyc-3.1#g' /usr/cbs/packages/netOglyc-3.1/netOglyc && \
  sed -i 's#/usr/bin/gawk#/usr/bin/awk#g' /usr/cbs/packages/netOglyc-3.1/netOglyc && \
  tar -xvzf /usr/local/lib/third_party/CBS/netphos-3.1.Linux.tar.Z -C /usr/cbs/packages && \
  sed -i 's#/usr/cbs/bio/src/ape-1.0#/usr/cbs/packages/ape-1.0#g' /usr/cbs/packages/ape-1.0/ape && \
  sed -i 's#/usr/bin/gawk#/usr/bin/awk#g' /usr/cbs/packages/ape-1.0/ape && \
  sed -i 's#/usr/local/python/bin/python#/usr/bin/python2#g' /usr/cbs/packages/ape-1.0/ape && \
  sudo chmod -R 777 /usr/cbs/packages/

RUN mkdir -p /home/rstudio/data/TwoBit && \
  R -e "library(EnsDb.Hsapiens.v86); library(EnsDb.Mmusculus.v79); AnnotationHub::setAnnotationHubOption('CACHE', '/home/rstudio/data/TwoBit'); ensembldb:::getGenomeTwoBitFile(EnsDb.Hsapiens.v86); ensembldb:::getGenomeTwoBitFile(EnsDb.Mmusculus.v79)"

RUN mkdir -p /home/rstudio/data/GTEx && \
  wget -P /home/rstudio/data/GTEx/ https://toil.xenahubs.net/download/GTEX_phenotype.gz && \
  gunzip -c /home/rstudio/data/GTEx/GTEX_phenotype.gz > /home/rstudio/data/GTEx/GTEX_phenotype.txt &&\
  rm /home/rstudio/data/GTEx/GTEX_phenotype.gz && \
  wget -P /home/rstudio/data/GTEx/ https://toil.xenahubs.net/download/gtex_RSEM_gene_fpkm.gz && \
  gunzip -c /home/rstudio/data/GTEx/gtex_RSEM_gene_fpkm.gz > /home/rstudio/data/GTEx/gtex_RSEM_gene_fpkm.txt &&\
  rm /home/rstudio/data/GTEx/gtex_RSEM_gene_fpkm.gz && \
  wget -P /home/rstudio/data/GTEx/ https://storage.googleapis.com/gtex_analysis_v8/annotations/GTEx_Analysis_v8_Annotations_SampleAttributesDS.txt &&\
  wget -P /home/rstudio/data/GTEx/ https://storage.googleapis.com/gtex_analysis_v8/rna_seq_data/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct.gz && \
  gunzip -c /home/rstudio/data/GTEx/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct.gz > /home/rstudio/data/GTEx/GTEx_v8_tpm.gct &&\
  rm /home/rstudio/data/GTEx/GTEx_Analysis_2017-06-05_v8_RNASeQCv1.1.9_gene_tpm.gct.gz

RUN chmod a+rwx -R /home/rstudio
RUN mkdir -p /scratch && \
  sudo chmod -R 777 /scratch/

ADD ./configs/rstudio-prefs.json /home/rstudio/.config/rstudio/rstudio-prefs.json