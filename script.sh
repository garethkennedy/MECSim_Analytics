#!/bin/bash
xmin=0
xmax=2
xdel=1
xext=e-2
ymin=-10
ymax=10
ydel=5
yext=e-2
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
