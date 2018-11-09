#!/bin/bash
#
# usage: sbatch cris_obs_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=cris_obs
#SBATCH --output=cris_%A_%a.out
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --array=1-5

# new bad node list
#SBATCH --exclude=n11,n71

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "cris_obs_batch($1); exit"

