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
import seaborn as sns
```

```python
!pip install xenaPython
```

```python
import xenaPython as xena
```

```python
!pip install tspex
```

```python
import tspex
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

geneSym, geneEns = "TP53", "ENSG00000141510.15"
samples = pheno["Sample"].tolist()
# samples = xena.dataset_samples(xena_hub, gex_data, None)
mat = xena.dataset_gene_probe_avg(xena_hub, gex_data, samples, [geneSym])
```

```python
fpkm = mat[0]["scores"][0]
pheno[geneSym] = fpkm
pheno[geneSym] = pheno[geneSym].astype(float)
pheno["Tissue"] = pheno["_primary_site"]
pheno["Neural"] = pheno["Tissue"].isin(['Brain', 'Nerve', 'Pituitary'])
pheno.head()
```

```python
### Check percentiles

gex_matrix_file = "work/" + gex_data + ".tsv"

!wget -P work/ {xena_hub}/download/{gex_data}.gz
!gunzip -c work/{gex_data}.gz > {gex_matrix_file}
```

```python
pheno = pd.read_csv("work/"+phenotype_data+".txt", sep="\t")
pheno.head()
```

```python
df = pd.read_csv(gex_matrix_file, sep = "\t")
df = df.set_index("sample")
df = df.loc[df.median(axis=1) > 2,:]
perc_mat = df.transform(lambda x: x.rank(pct=True))
perc_mat.head()
```

```python
sample_meta_d = pheno.loc[:,["Sample", "_primary_site"]].set_index("Sample").to_dict()["_primary_site"]
gex_matrix = df.T.reset_index()
gex_matrix["Tissue"] = gex_matrix["index"].map(sample_meta_d)
gex_matrix = gex_matrix.drop(columns=["index"])
gex_matrix = gex_matrix.groupby("Tissue").mean().T + 10
gex_matrix
```

```python
genePrc = geneSym + "_perc"
pheno = pheno.merge(perc_mat.loc[geneEns], left_on="Sample", right_index=True)
pheno[genePrc] = pheno[geneEns]
pheno.head()
```

```python
tissue_order = [
    'Brain',
    'Nerve',
    'Pituitary',
    'Blood',
    'Bone Marrow',
    'Spleen',
    'Adrenal Gland',
    'Kidney',
    'Fallopian Tube',
    'Bladder',
    'Prostate',
    'Testis',
    'Ovary',
    'Uterus',
    'Cervix Uteri',
    'Vagina',
    'Breast',
    'Skin',
    'Adipose Tissue',
    'Muscle',
    'Blood Vessel',
    'Heart',
    'Thyroid',
    'Lung',
    'Esophagus',
    'Stomach',
    'Colon',
    'Small Intestine',
    'Salivary Gland',
    'Pancreas',
    'Liver'
]
```

```python
### Visualize gex percentiles

fig, ax = plt.subplots(figsize = (9.6, 3.2))
fig.subplots_adjust(wspace=0.5, hspace=0.8)
fig.suptitle(geneSym + " expression in tissues according to GTEX")

ax = sns.boxplot(x="_primary_site", y=genePrc, order=tissue_order, color = "w", fliersize=0.5, data=pheno, dodge=False, ax = ax)
ax = sns.stripplot(x="_primary_site", y=genePrc, order=tissue_order, data=pheno, size=2, dodge=False, ax = ax)

ax.set_xticklabels(
    [item.get_text() for item in ax.get_xticklabels()], rotation=30, ha="right"
)
ax.set_ylim(0, 1)
ax.set_ylabel("Gex (Percentile rank)")
plt.setp(ax.artists, edgecolor="k", facecolor="w")
plt.setp(ax.lines, color="k")
plt.tight_layout()
```

```python
tso = tspex.TissueSpecificity(gex_matrix, 'tau')
tso.tissue_specificity.head()
```

```python
sns.barplot(x="Tissue", y=geneEns, data=tso.tissue_specificity.loc[geneEns].to_frame().reset_index(), order=tissue_order)
```

```python
tso = tspex.TissueSpecificity(gex_matrix, 'spm')
tso.tissue_specificity.head()
```

```python
sns.barplot(x="Tissue", y=geneEns, data=tso.tissue_specificity.loc[geneEns].to_frame().reset_index(), order=tissue_order)
```

```python

```
