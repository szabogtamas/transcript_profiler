---
jupyter:
  jupytext:
    formats: md,ipynb
    text_representation:
      extension: .md
      format_name: markdown
      format_version: '1.3'
      jupytext_version: 1.13.0
  kernelspec:
    display_name: Python 3 (ipykernel)
    language: python
    name: python3
---

# Tissue expression of transcripts

## Setup

```python
### Tools to be used
import matplotlib
from matplotlib import pyplot as plt

import numpy as np
import pandas as pd
```

```python
### Specify paths to GTEX data

xena_hub = "https://toil.xenahubs.net"
phenotype_data = "GTEX_phenotype"
gex_data = "gtex_RSEM_gene_fpkm"
```

```python
### Download GTEX sample metadata

!wget -P work/ {xena_hub}/download/{phenotype_data}.gz
!gunzip -c work/{phenotype_data}.gz > work/{phenotype_data}.txt
```

```python
pheno = pd.read_csv("work/"+phenotype_data+".txt", sep="\t")
pheno.head()
```

```python
### Download gene expression as FPKM

geneSym, geneEns = piddSym, piddEns
samples = pheno["Sample"].tolist()
# samples = xena.dataset_samples(xena_hub, gex_data, None)
mat = xena.dataset_gene_probe_avg(xena_hub, gex_data, samples, [geneSym])
fpkm = mat[0]["scores"][0]
pheno[geneSym] = fpkm
pheno[geneSym] = pheno[geneSym].astype(float)
pheno["Tissue"] = pheno["_primary_site"]
pheno["Neural"] = pheno["Tissue"].isin(['Brain', 'Nerve', 'Pituitary'])
pheno.head()
```

```python
### Check percentiles for PIDD1

gex_matrix_file = "work/" + gex_data + ".tsv"

!wget -P work/ {xena_hub}/download/{gex_data}.gz
!gunzip -c work/{gex_data}.gz > {gex_matrix_file}

df = pd.read_csv(gex_matrix_file, sep = "\t")
df = df.set_index("sample")
df = df.loc[df.median(axis=1) > 2,:]
df = df.transform(lambda x: x.rank(pct=True))
genePrc = geneSym + "_perc"
pheno = pheno.merge(df.loc[geneEns], left_on="Sample", right_index=True)
pheno[genePrc] = pheno[geneEns]
```