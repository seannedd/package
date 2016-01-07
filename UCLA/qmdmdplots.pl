#!/usr/bin/perl
#
# Script to make a file for QMDMD plots.
# Plots include QM and DMD energies. Also, rmsd data for backbone and active sites.
# by Sean Nedd
#
# Under your QMDMD directory:
# Opens the files qm_opt_energies.dat, ..pdb/guide_rmsd.dat, and ..pdb/bb_rmsd.dat. 
# Copies columns into qmdmdplot.dat

use strict;
use warnings;
 
my($QMDMD_dir);
my($bb_file);
my($guide_file);
my($qmdmd_file);
my($output);
my($i);
my($j);
my($k);
my($m);
my(@iteration);
my(@qm);
my(@dmd);
my(@delta_qm);
my(@delta_dmd);
my(@bbrmsd);
my(@guidermsd);

$i=0;
$j=0;
$k=0;
$m=0;

$QMDMD_dir=$ARGV[0];
$bb_file="$QMDMD_dir/pdb/bb_rmsd.dat";
$guide_file="$QMDMD_dir/pdb/guide_rmsd.dat";
$qmdmd_file="$QMDMD_dir/qm_opt_energies.dat";
if ( -f "$QMDMD_dir/output.dat" ) {
system("cat $QMDMD_dir/output.dat >> $QMDMD_dir/output1.dat"); 
system("rm $QMDMD_dir/output.dat"); 
} else {
system("touch $QMDMD_dir/output.dat");
}
$output="$QMDMD_dir/output.dat";

open(QMDMD, "<$qmdmd_file") || die("Could not open qm_opt_energies.dat!");
open(BB, "<$bb_file") || die("Could not open pdb/bb_rmsd.dat!");
open(GUIDE, "<$guide_file") || die("Could not open pdb/guide_rmsd.dat!");

while (<QMDMD>) {
  chomp($_);
  if (/(\d)\s+(-\d+.\d+)\s+(\d+.\d+)/ || /(\d+)\s+(-\d+.\d+)\s+(-\d+.\d+)/) {
   $iteration[$i]=$1;
   $qm[$i]=$2;
   $dmd[$i]=$3;
   if( $i > 0 ) {
    $delta_qm[$i]=($qm[$i] - $qm[1])*627.5095;
    $delta_dmd[$i]=$dmd[$i] - $dmd[1];
   }else{
    $delta_qm[0]=0.000;
    $delta_dmd[0]=0.000;
   } 
   $i++; 
   }
}
close (QMDMD);

while (<BB>) {
  chomp($_);
  if (/(\d+)\s+(\d+.\d+)/) {
  $bbrmsd[$j]=$2; 
  }
  $j++;
}
close (BB);

while (<GUIDE>) {
  chomp($_);
  if (/(\d+)\s+(\d+.\d+)/) {
  $guidermsd[$k]=$2; 
  }
  $k++;
}
close (GUIDE);

open(OUT, "+>>$output") || die("could not open output.dat!");
for ( $m=0; $m<$i; $m++ ) {
 print OUT "$iteration[$m] $qm[$m] $dmd[$m] $delta_qm[$m] $delta_dmd[$m] $bbrmsd[$m] $guidermsd[$m] \n";
}
close (OUT);
