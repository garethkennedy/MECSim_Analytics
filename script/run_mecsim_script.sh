#!/bin/bash
start=$(date +%s)
cp script/Master.sk script/Master_with_fixed.sk
sed -i 's/$R/'100'/g' script/Master_with_fixed.sk
cp -p script/Master_with_fixed.sk external/script/
sed -i 's/$alpha/'0.5'/g' script/Master_with_fixed.sk
cp -p script/Master_with_fixed.sk external/script/
sed -i 's/$cap0/'0.0'/g' script/Master_with_fixed.sk
cp -p script/Master_with_fixed.sk external/script/
cp script/MECSim_Example.txt output/MECSimOutput_Pot.txt
python python/HarmonicSplitter.py
mv output/Smoothed.txt output/ExpSmoothed.txt 
end=$(date +%s)
seconds=$((end-start))
awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "Time taken converting experimental data: %d:%02d:%02d ", t/3600000, t/60000%60, t/1000%60}'; echo
xmin=100
xmax=2000
xdel=500
xext=e0
ymin=-1
ymax=1
ydel=1
yext=e-1
x=$xmin
counter=1
counter_max=15
counter_output=$((counter_max/10))
echo 
echo '2D Grid method run with n_sim = 15'
echo 
echo '$kzero,$Ezero,S' > output/results.txt
while [ $x -le $xmax ]
do
  y=$ymin
  while [ $y -le $ymax ]
  do
    cp script/Master.sk input/Master.inp
    sed -i 's/$R/'100'/g' input/Master.inp
    sed -i 's/$alpha/'0.5'/g' input/Master.inp
    sed -i 's/$cap0/'0.0'/g' input/Master.inp
    sed -i 's/$kzero/'$x$xext'/g' input/Master.inp
    sed -i 's/$Ezero/'$y$yext'/g' input/Master.inp
    if ((counter==1)); then
      python python/InputChecker.py > checker.txt
      if [ $(grep 'INPUT VALID False' checker.txt | wc -l) -ne 0 ]; then
        cat checker.txt
        cp -p checker.txt input/Master.inp external/output/
        exit
      fi
    fi
    ./MECSim.exe 2>errors.txt
    [ $(grep 'WARNING' output/log.txt | wc -l) != '0' ] && grep 'WARNING' output/log.txt
    if [ $(grep 'ERROR' output//log.txt | wc -l) -ne 0 ]; then
      grep 'ERROR' output/log.txt
      exit
    fi
    python python/HarmonicSplitter.py
    z=$(python python/CompareSmoothed.py)
    echo $x$xext,$y$yext,$z >> output/results.txt
    cp -p input/Master.inp output/
    cp -p output/* external/output/
    if ((counter%counter_output==0)); then
      end=$(date +%s)
      seconds=$((end-start))
      echo 'Completed:' $((100*counter/counter_max))'%' 
      awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "Time taken: %d:%02d:%02d ", t/3600000, t/60000%60, t/1000%60}'; echo
    fi
    counter=$((counter+1))
    y=$((y+ydel))
  done
  x=$((x+xdel))
done

echo 
unix2dos output/*.txt
cp -p output/* external/output/
python python/BayesianAnalysis.py results.txt external/output/ external/script/
python python/OutputBestFit.py
cp -p output/* external/output/
end=$(date +%s)
seconds=$((end-start))
awk -v t=$seconds 'BEGIN{t=int(t*1000); printf "Time taken: %d:%02d:%02d ", t/3600000, t/60000%60, t/1000%60}'; echo

