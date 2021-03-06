#!/bin/bash
#
# usage: sbatch airs_obs_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=airs_obs
# #SBATCH --output=airs_%A_%a.out
# #SBATCH --partition=high_mem
#SBATCH --partition=batch
#SBATCH --constraint=hpcf2009
#SBATCH --qos=medium+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=24000
#SBATCH --oversubscribe
# #SBATCH --array=16-23%3
#SBATCH --array=1-23%4

# bad node list
# #SBATCH --exclude=cnode[007,009]

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2020a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

# srun $MATLAB $MATOPT -r "airs_obs_batch($1); exit"

srun --output=airs_$1_%A_%a.out \
   $MATLAB $MATOPT -r "airs_obs_batch($1); exit"

