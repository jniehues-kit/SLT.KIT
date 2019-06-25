#!/bin/bash

if [ -z "$SLTKITDIR" ]; then
    SLTKITDIR=/opt/SLT.KIT
fi

$SLTKITDIR/systems/smallTED/Download.sh
$SLTKITDIR/systems/ctc-tedlium2/Download.sh
