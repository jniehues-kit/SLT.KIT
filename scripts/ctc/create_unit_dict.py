#!/usr/bin/env python

import argparse
import json

def create_parser():
    parser = argparse.ArgumentParser(
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument(
        '--text',
        help="text file containing units"
    )

    parser.add_argument(
        '--output',
        help="output json file that will contain mapping of ids to units"
    )

    return parser 

if __name__ == "__main__":
    parser = create_parser()
    args = parser.parse_args()
    # print(args)

    units_set = set()    
    
    with open(args.text, mode='r') as f:
       for line in f:
           for word in line.split():
               units_set.add(word)

    units = [x for x in units_set]
    units.insert(0, "<BLANK>")
    output_dir = dict(enumerate(units, start=0))

    j = json.dumps(output_dir)
    with open(args.output, mode='w') as f:
        f.write(j)

