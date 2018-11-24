#!/bin/bash
#
# usage: sbatch npp_obs_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=npp_obs
#SBATCH --output=npp_%A_%a.out
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --array=5-19%4
# #SBATCH --array=1-23%5

# new bad node list
# #SBATCH --exclude=n11,n71

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "npp_obs_batch($1); exit"
