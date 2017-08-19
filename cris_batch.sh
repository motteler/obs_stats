#!/bin/bash
#
# usage: sbatch cris_batch.sh <year>
#

# sbatch options
#SBATCH --job-name=cris_tbin
#SBATCH --output=cris_%A_%a.out
#SBATCH --partition=batch
#SBATCH --qos=medium_prod
#SBATCH --account=pi_strow
#SBATCH --mem-per-cpu=16000
#SBATCH --array=1-5

# matlab options
MATLAB=/usr/cluster/matlab/2016a/bin/matlab
MATOPT='-nojvm -nodisplay -nosplash'

srun $MATLAB $MATOPT -r "cris_batch($1); exit"

