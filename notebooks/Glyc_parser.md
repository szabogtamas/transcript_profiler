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
netnglyc_out = "netnglyc_tmp.txt"
```

```python
def parse_netnglyc(fn):
    f = open(fn, "r")
    entries = f.read().split("\nName: ")
    f.close()
    for e in entries[1:]:
        
    return

parse_netnglyc(netnglyc_out)
```

```python
f = open(netnglyc_out, "r")
entries = f.read().split("\nName:")
f.close()
entries
```

```python
e = entries[1]
e.split("\n")
```

```python

```
