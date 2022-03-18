#!/usr/bin/env python

import os
from glob import glob
import argparse


def get_inv_variables():

    return


if __name__ == "__main__":


    parser = argparse.ArgumentParser(description='generate layer profile')
    
    parser.add_argument('--analysis', type=str)

    parser.add_argument('--roi', type=str)
    
    parser.add_argument('--parc', type=str)
    parser.add_argument('--parc_id', type=int)

    args = parser.parse_args()

    analysis = args.analysis


    #if exists()


    """
    if ANALYSIS_DIR not set ... 



    """


