#!/bin/bash
#
# usage: sbatch airs_map_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=airs_obs
#SBATCH --output=airs_%A_%a.out
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --array=4,13,14
# #SBATCH --array=5-12%4
# #SBATCH --array=1-23%6

# new bad node list
# #SBATCH --exclude=n11,n71

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "airs_map_batch($1); exit"

