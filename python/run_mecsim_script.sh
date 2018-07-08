#!/bin/bash
i=1
imax=10
echo '$Ezero,$kzero,$DiffB,S' > results.txt
while [ $i -le $imax ]
do
  i=$((i+1))
  cp script/Master.sk ./Master.inp
    x=$(python python/ReturnRandomExpFormat.py -0.1 0.1 False)
    sed -i 's/$Ezero/'$x'/g' ./Master.inp
    echo '$Ezero' $x
    paraString=$x
    x=$(python python/ReturnRandomExpFormat.py 0.01 10000.0 True)
    sed -i 's/$kzero/'$x'/g' ./Master.inp
    echo '$kzero' $x
    paraString=$paraString,$x
    x=$(python python/ReturnRandomExpFormat.py 1e-06 2e-05 False)
    sed -i 's/$DiffB/'$x'/g' ./Master.inp
    echo '$DiffB' $x
    paraString=$paraString,$x
    ./MECSim.exe 2>errors.txt
    mv log.txt output/log_$i.txt
    python python/HarmonicSplitter.py
    z=$(python python/CompareSmoothed.py)
    echo $paraString,$z >> results.txt
done
cp results.txt output/
python python/BayesianAnalysis.py results.txt
cp bayesian_plot.* output/
cp posterior.txt opt_parameters.txt output/
