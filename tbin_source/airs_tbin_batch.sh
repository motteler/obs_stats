#!/bin/bash
#
# usage: sbatch airs_tbin_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=airs_tbin
#SBATCH --output=airs_%A_%a.out
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --array=1-5

# new bad node list
# #SBATCH --exclude=n71,n101,n103,n126,n150

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "airs_tbin_batch($1); exit"

