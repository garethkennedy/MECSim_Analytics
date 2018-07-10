#!/bin/bash
i=1
imax=10
echo 'class,$Ezero,$kzero,$DiffB,S' > results_ml.txt
while [ $i -le $imax ]
do
  i=$((i+1))
  cp script/Master.sk ./Master.inp
  paraString=E
    x=$(python python/ReturnRandomExpFormat.py -0.1 0.1 False)
    sed -i 's/$Ezero/'$x'/g' ./Master.inp
    echo '$Ezero' $x
    paraString=$paraString,$x
    x=$(python python/ReturnRandomExpFormat.py 0.01 10000.0 True)
    sed -i 's/$kzero/'$x'/g' ./Master.inp
    echo '$kzero' $x
    paraString=$paraString,$x
    x=$(python python/ReturnRandomExpFormat.py 1e-06 2e-05 False)
    sed -i 's/$DiffB/'$x'/g' ./Master.inp
    echo '$DiffB' $x
    paraString=$paraString,$x
    ./MECSim.exe 2>errors.txt
    python python/HarmonicSplitter.py
    python python/ConvertToMLFormat.py Smoothed.txt
    mv ml_format.csv output/ml_format_$i.csv
    echo $paraString,$i >> results_ml.txt
done
cp results_ml.txt output/
