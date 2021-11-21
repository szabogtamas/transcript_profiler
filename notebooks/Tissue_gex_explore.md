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