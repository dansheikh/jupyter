#!/usr/bin/env bash

. activate jupyter
jupyter notebook --ip=0.0.0.0 --port=8888 --no-browser --notebook-dir="/home/jupyter/ipynbs"