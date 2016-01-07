#!/usr/bin/perl
#
# Script to obtain total energies and frequencies from transitions state (f) directories.
# by Sean Nedd
#
# $1 sets the directory from which to pull total energy, frequencies, and chemical potential.
# $2 sets the energy file to pull out total energy.
# Saves into thermo.out.

use strict;
use warnings;
 
print "This script pulls out total energies and frequencies from turbomole directories.\n";
print "\$1 is the thermo directory. Currently \"$ARGV[0]\"\n";
print "\$2 is energy file (ridft.out, job.last). Currently \"$ARGV[1]\"\n";
print "The directory is also checked for convergence (looks for \"converged\" file)\n";
print "The free energy (kcals/mol) is calculated in the output file. The final xyz structure is also calculated.\n"; 
print "by adding the Chem.Pot. (kJ/mol) and the total energy (au).\n";
print "If COSMO run, then the total energy incorporates the COSMO + OC (outlying charge) corrections.";

my($a);
my($dir);
my($num0);
my($num1);
my($num2);
my($energy_file);
my($vib_file);
my($free_file);
my($thermo_out);
my($converge);
my($freeen);

$a=0;
$b=0;
$dir=$ARGV[0];

if ( ! defined $ARGV[1] ) {
 $ARGV[1] = "ridft.out";
}

$energy_file="$dir/$ARGV[1]";
$vib_file="$dir/vibspectrum";
$free_file="$dir/freeh.out";
$thermo_out="thermo_energies.out";
$converge="$dir/converged";

system("makefinal.sh $dir");
system("freehdefine.sh $dir");

open(THERMOOUT, "+>>$thermo_out") || die("Could not open thermo_energies.out!");
if ( ! -s $thermo_out ) {
 print THERMOOUT "Directory                                TotalEnergy(au)        Frequency    Chem.Pot.(kJ/mol)   FreeEnergy(kcal/mol)\n";
}

#Opening ridft.out or job.last
$num0="00000.00000000000";
if ( -s $energy_file ) {
 open(ENE, "<$energy_file") || die("Could not open your total energy file!");
 while (<ENE>) {
  chomp($_);
  if (/\|  total energy      =\s+(-\d+.\d+)/) {
   $num0=$1;
  }
  if (/Total energy \+ OC corr. =\s+(-\d+.\d+)/) {
   $num0=$1;
  }
 }
 close(ENE);
}

#Opening vibspectrum
$num1="00.00"; 
if ( -s $vib_file ){
 open(VIB, "<$vib_file") || die("Could not open your vibspectrum file!");
 while (<VIB>) {
  chomp($_);
  #Searching for negative frequencies
  if ((/\s+\d+\s+a\s+(-\d+.\d+)/) && $a==0) {
   $num1=$1; 
   $a=1;
  }
  #Searching for positive frequencies
  if ((/\s+\d+\s+a\s+(\d+.\d+)/) && $a==0) {
   $num1=$1; 
   $a=1;
  }
  if (/\s+\d+\s+a\s+(-\d+.\d+)/) {
   $b++; 
  }
 }
 close(VIB);
}

#Opening freeh.out
$num2="000.00"; 
if ( -s $free_file ) {
 open(FREE, "<$free_file") || die("Could not open your freeh.out file!");
 while (<FREE>) {
  chomp($_);
  if (/\s+\d+.\d+\s+\d+.\d+\s+\d+.\d+\s+\d+.\d+\s+\d+.\d+\s+(.\d+.\d+)\s+/) {
   $num2=$1;
  }
 }
 close(FREE);
}

#Calculating Free energy
$freeen=($num0*627.5095) + ($num2/4.184);
if ( $freeen==0 ) {
 $freeen="000000.000000000";
}

#Checks for convergence and prints to thermo_energy.out

if ( -s $converge ) { 
 printf THERMOOUT pack("A40", $dir);
 print THERMOOUT "$num0        $num1        $num2               $freeen    #ifreq=$b\n";
#print THERMOOUT "$dir    $num0        $num1        $num2      $freeen\n";
} else {
 printf THERMOOUT pack("A40", $dir);
 print THERMOOUT "$num0        $num1        $num2               $freeen    #ifreq=$b    not converged\n";
#print THERMOOUT "$dir    $num0        $num1        $num2      $freeen        not converged\n";
}

close(THERMOOUT);
