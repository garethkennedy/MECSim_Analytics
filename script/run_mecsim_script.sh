#!/bin/bash
cp script/Settings.inp ./
cp script/MECSim_Example.txt MECSimOutput_Pot.txt
python python/HarmonicSplitter.py
mv Smoothed.txt ExpSmoothed.txt 
xmin=5
xmax=15
xdel=5
xext=e-3
ymin=19
ymax=23
ydel=1
yext=e-2
x=$xmin
echo '$kzero,$Ezero,S' > results.txt
while [ $x -le $xmax ]
do
  y=$ymin
  while [ $y -le $ymax ]
  do
    cp script/Master.sk ./Master.inp
    sed -i 's/$kzero/'$x$xext'/g' ./Master.inp
    sed -i 's/$Ezero/'$y$yext'/g' ./Master.inp
    ./MECSim.exe
    mv log.txt output/log_$x$xext_$y$yext.txt
    python python/HarmonicSplitter.py
    z=$(python python/CompareSmoothed.py)
    echo $x$xext,$y$yext,$z >> results.txt
    y=$((y+ydel))
  done
  x=$((x+xdel))
done
cp results.txt output/
python python/BayesianAnalysis.py results.txt
cp bayesian_plot.* output/
cp posterior.txt opt_parameters.txt output/
python python/SurfacePlotter.py results.txt
cp surface_plot.* output/
