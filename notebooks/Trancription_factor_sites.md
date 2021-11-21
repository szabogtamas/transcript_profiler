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

from io import StringIO

import numpy as np
import pandas as pd
import seaborn as sns

import ensembl_rest
import pyBigWig
```

```python
gene_symbol = "TP53"
```

## Connect to JASPAR

```python
human_bigbed = "http://expdata.cmmt.ubc.ca/JASPAR/downloads/UCSC_tracks/2022/JASPAR2022_hg38.bb"
```
```python
bb = pyBigWig.open(human_bigbed)
```