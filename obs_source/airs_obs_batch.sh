#!/bin/bash
#
# usage: sbatch airs_obs_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=airs_obs
#SBATCH --output=airs_%A_%a.out
#SBATCH --partition=high_mem
#SBATCH --qos=medium+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --oversubscribe
# #SBATCH --array=1-23%4
#SBATCH --array=1-4

# new bad node list
# #SBATCH --exclude=n11,n71

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2018b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "airs_obs_batch($1); exit"

