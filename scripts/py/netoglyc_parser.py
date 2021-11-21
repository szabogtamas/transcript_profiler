#!/usr/bin/env python

from io import StringIO
import pandas as pd
import re
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("input_file")
parser.add_argument("output_file")
args = parser.parse_args()