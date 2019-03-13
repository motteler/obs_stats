#!/bin/bash
#
# usage: sbatch n20_obs_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=n20_obs
#SBATCH --output=n20_%A_%a.out
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=20000
#SBATCH --array=5-20%4

# new bad node list
# #SBATCH --exclude=n11,n71

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "n20_obs_batch($1); exit"

