#!/bin/bash
xmin=2
xmax=6
xdel=2
xext=e-1
ymin=-1
ymax=1
ydel=1
yext=e-1
x=$xmin
python HarmonicSplitter.py -script -exp
> results.txt
while [ $x -le $xmax ]
do
  y=$ymin
  while [ $y -le $ymax ]
  do
    cp Master.sk Master.inp
    sed -i 's/$kzero/'$x$xext'/g' Master.inp
    sed -i 's/$Ezero/'$y$yext'/g' Master.inp
    ./MECSim > log.txt
    python HarmonicSplitter.py -script
    python CompareSmoothed.py -script $x$xext $y$yext
    y=$((y+ydel))
  done
  x=$((x+xdel))
done
