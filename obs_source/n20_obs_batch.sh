#!/bin/bash
#
# usage: sbatch n20_obs_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=n20_obs
#SBATCH --output=n20_%A_%a.out
#SBATCH --partition=high_mem
# #SBATCH --partition=batch
# #SBATCH --constraint=hpcf2009
#SBATCH --constraint=lustre
# #SBATCH --qos=medium+
#SBATCH --qos=normal+
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=24000
#SBATCH --oversubscribe
# #SBATCH --array=1-23%4
#SBATCH --array=1-9%4

# new bad node list
# #SBATCH --exclude=n11,n71

# matlab options
MATLAB=/usr/ebuild/software/MATLAB/2018b/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "n20_obs_batch($1); exit"

