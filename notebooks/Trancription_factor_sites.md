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

```python
gene_features = ensembl_rest.symbol_lookup(species="homo sapiens", symbol=gene_symbol)
```

```python
if gene_features["strand"] < 1:
    reg_start = gene_features["end"] - 500
else:
    reg_start = gene_features["start"] - 5500
reg_end = reg_start + 6000    
```

```python
#sites = ["{}\t{}\t{}".format(*x) for x in bb.entries("chr17", 7661779, 7687538)]
sites = ["{}\t{}\t{}".format(*x) for x in bb.entries("chr"+gene_features["seq_region_name"], reg_start, reg_end)]
tmp_data = StringIO("\n".join(sites))
df = pd.read_csv(tmp_data, sep="\t", names=["start", "end", "TF", "score", "strand"])
df.head()
```

```python
bb.close()
```

## Show top Transcription Factors

```python
df2 = df.loc[df["strand"] == "+", ["start", "TF", "score"]].pivot_table(index="start", columns="TF", values="score")
top_factors = df2.max().sort_values().tail(50)
df2 = df2.loc[:, top_factors.index].dropna(how="all")
df2
```

```python
fontsizes = {"SMALL_SIZE": 6, "MEDIUM_SIZE": 8, "BIGGER_SIZE": 10}
default_style = {
    "figure.titlesize": fontsizes["BIGGER_SIZE"],
    "axes.titlesize": fontsizes["MEDIUM_SIZE"],
    "axes.labelsize": fontsizes["SMALL_SIZE"],
    "xtick.labelsize": fontsizes["SMALL_SIZE"],
    "ytick.labelsize": fontsizes["SMALL_SIZE"],
    "legend.fontsize": fontsizes["MEDIUM_SIZE"],
    "font.size": fontsizes["SMALL_SIZE"],
    "axes.spines.top": False,
    "axes.spines.right": False,
    "legend.frameon": False,
    "savefig.transparent": True,
    "figure.figsize": (4.8, 7.2),
    "figure.dpi": 300,
}
plt.rcParams.update(default_style)
```

```python
fig, ax = plt.subplots()

sns.heatmap(df2.T, cmap="viridis", ax=ax)
ax.set_xlabel("")
ax.set_ylabel("")
ax.set_title("Binding sites of top " + gene_symbol + " transcription factors")
```

```python
fig.savefig("binding_sites.pdf")
```