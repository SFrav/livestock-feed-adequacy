#!/bin/sh
#$ -N Feed_SPAM
#$ -cwd
#$ -l h_rt=6:00:00
#$ -l h_vmem=3G

. /etc/profile.d/modules.sh
module load igmm/apps/R/3.6.3

export R_LIBS=/exports/cmvm/eddie/eb/groups/GAAFS/Rlibrary/3.6
module load igmm/libs/gdal/3.1.3 
module load igmm/libs/proj/7.1.1
module load igmm/apps/sqlite3/3.33.0 

Rscript /exports/eddie/scratch/sfraval/feed-surfaces/SPAM2017_burkina/PrepareSPAM_clip.R
