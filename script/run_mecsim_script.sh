#!/bin/bash
cp script/MECSim_Example.txt MECSimOutput_Pot.txt
python python/HarmonicSplitter.py
mv Smoothed.txt ExpSmoothed.txt 
i=0
imax=10
echo 
echo 'Random sample run with n_sim = 10'
echo 
echo '$Ezero,$kzero,S' > output/results.txt
while [ $i -le $imax ]
do
  i=$((i+1))
  cp script/Master.sk input/Master.inp
  sed -i 's/$R/'100'/g' input/Master.inp
  sed -i 's/$alpha/'0.5'/g' input/Master.inp
  x=$(python python/ReturnRandomExpFormat.py -0.1 0.1 False)
  sed -i 's/$Ezero/'$x'/g' input/Master.inp
  paraString=$x
  x=$(python python/ReturnRandomExpFormat.py 0.01 0.1 False)
  sed -i 's/$kzero/'$x'/g' input/Master.inp
  paraString=$paraString,$x
  ./MECSim.exe 2>errors.txt
  python python/HarmonicSplitter.py
  z=$(python python/CompareSmoothed.py)
  echo $paraString,$z >> output/results.txt
  cp -p input/Master.inp output/
  cp -p output/* external/output/
done
python python/BayesianAnalysis.py output/results.txt
cp -p bayesian_plot.* output/
cp -p posterior.txt opt_parameters.txt output/
cp -p output/* external/output/
