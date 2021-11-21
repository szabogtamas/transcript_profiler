#!/usr/bin/env python

from io import StringIO
import pandas as pd
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("input_file")
parser.add_argument("output_file")
args = parser.parse_args()

def parse_netoglyc(fn):
    f = open(fn, "r")
    entries = f.read()
    f.close()
    header = "Name                         S/T   Pos  G-score I-score Y/N  Comment"
    tabular = re.findall(r'(?<=\n)[A-Za-z0-9]+\s+[ST]\s+.*(?=\n)', entries)
    tmp_data = StringIO("\n".join([header] + tabular))
    df = pd.read_fwf(tmp_data)
    return df