#!/bin/bash
#
# A script to make qmdmd plots using output.dat from qmdmd files qm_opt_energies.dat, bb_rmsd.dat, and guide_rmsd.dat.
# Runs domakepdb.sh on the qmdmd directory is rmsd files are not found.
# Aborts if qm_opt_energies.dat file is not found.
#
# By Sean Nedd
#
echo "Making qmdmd plots showing energies and rmsd values."
echo "First run makepdb.sh on your qmdmd directory to generate the rmsd files (bb_rmsd.dat and guide_rmsd.dat)"
echo ""\$1" is your qmdmd directory. Currently $1"
echo ""\$2" if set to 1 will redo your rmsds. Currently $2"
echo ""\$3" if set to 1 will redo your output.dat file. Currently $3"
echo ""\$4" chooses which format of is your qmdmd directory. Currently $4"
#
redormsds=$2
redooutput=$3
gnuplotformat=$4

if [ "$redormsds" = '' ]; then redormsds=0; fi
if [ "$redooutput" = '' ]; then redooutput=0; fi
if [ "$gnuplotformat" = '' ]; then gnuplotformat=0; fi

if [ "$1" = 'plots' ]; then echo "plots directory present"; exit; fi
if [ ! -f $1/qm_opt_energies.dat -a ! -f $1/output.dat ]; then
 echo "No qm_opt_energies.dat or output.dat file present. Probably not a complete qmdmd run ... aborting..."
 exit
fi 
if [ ! -f $1/pdb/bb_rmsd.dat -o ! -f $1/pdb/bb_rmsd.dat -o "$redormsds" = '1' ]; then
 echo "An rmsd file is not present or we need to re-make rmsds."
 echo "Fixing by running domakepdb.sh $1"
 domakepdb.sh $1
fi
echo "Generating output.dat for gnuplot."
if [ -f $1/output.dat ]; then cp $1/output.dat $1/output.dat.save; fi
if [ ! -f $1/output.dat -o "$redooutput" = '1' ]; then qmdmdplots.pl $1; fi
#
cd $1
echo "Running options for gnuplot in plotscript"
# set the format of the gnuplot output; version 0
if [ "$gnuplotformat" = '0' ]; then
echo "
set ylabel \"Energy (kcal/mol)\"
set grid
set term png size 1600,1200
set key font \",7\"
set xtics font \",7\"
set ytics font \",7\"
set xlabel font \",8\"
set ylabel font \",8\"
set output \"egraph.png\"

set multiplot layout 2,2 title \"$1\"

set size .65,.56
set origin 0,.4
set key right top
set notitle
set ylabel \"Energy\"
set ytics font \",6\"
set y2tics font \",6\"
plot \"output.dat\" using 1:2 every ::1 with lines title \"QM(au)\" axes x1y1 ,\\
 \"output.dat\" using 1:3 every::1 with lines title \"DMD(kcal.mol)\"  axes x1y2

set size .35,.45
set origin .64,.45
set key center top
set ylabel \"Energy (kcal/mol)\"
set notitle
set ytics font \",7\"
set noy2tics
plot \"output.dat\" using 1:4 every ::1 with lines title \"QM rel. energies\" ,\\
 \"output.dat\" using 1:5 every ::1 with lines title \"DMD rel. energies\"

set size .5,.4
set origin 0,0
set xlabel \"Iteration #\"
set ylabel \"RMSD\"
plot \"output.dat\" using 1:6 with lines title \"Backbone RMSD\"

set size .5,.4
set origin 0.5,0
set noylabel
plot \"output.dat\" using 1:7 with lines title \"QM Region RMSD\"

unset multiplot

set term x11
" > plotscript
fi
# set the format of the gnuplot output; version 1
if [ "$gnuplotformat" = '1' ]; then
echo "
set ylabel \"Energy (kcal/mol)\"
set grid
set term png size 1024,960
set key font \",7\"
set xtics font \",7\"
set ytics font \",7\"
set xlabel font \",8\"
set ylabel font \",8\"
set output \"egraph.png\"

set multiplot layout 1,1

set size 1,1
set origin 0,0
set key left bottom
set xlabel \"Iteration #\"
set ylabel \"Energy (kcal/mol)\"
set notitle
#set ytics font \",7\"
set noy2tics
plot \"output.dat\" using 1:4 every ::1 with lines title \"QM rel. energies\" ,\\
 \"output.dat\" using 1:5 every ::1 with lines title \"DMD rel. energies\"

set size 1,1
set origin 0,0
set key right bottom
set xlabel \"Iteration #\"
set ylabel \"Energy (kcal/mol)\"
set noytics
set y2tics font \",7\"
set y2label \"RMSD\"
plot \"output.dat\" using 1:6 with lines title \"Backbone RMSD\" ,\\
 \"output.dat\" using 1:7 with lines title \"QM Region RMSD\"

#set size 1,1
#set origin 0,0
#set noylabel
#plot \"output.dat\" using 1:7 with lines title \"QM Region RMSD\"

unset multiplot

set term x11
" > plotscript
fi
#
gnuplot -e "filename='output.dat'" plotscript
mv egraph.png $1.png
if [ ! -d ../plots ]; then mkdir ../plots; fi
cp $1.png ../plots

cd .. 
