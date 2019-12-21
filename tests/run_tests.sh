#!/bin/bash

python structure.py -K 3 --input=data/testdata --output=testoutput_simple --full --seed=100

python structure.py -K 3 --input=data/testdata --output=testoutput_logistic --full --seed=100 --prior=logistic