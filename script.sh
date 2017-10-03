#!/bin/bash
xmin=0
xmax=2
xdel=1
xext=e-2
ymin=20
ymax=25
ydel=1
yext=e-2
x=$xmin
> results.txt
while [ $x -le $xmax ]
do
  y=$ymin
  while [ $y -le $ymax ]
  do
    cp Master.sk Master.inp
    sed -i 's/$kzero/'$x$xext'/g' Master.inp
    sed -i 's/$Ezero/'$y$yext'/g' Master.inp
    y=$((y+ydel))
  done
  x=$((x+xdel))
done
