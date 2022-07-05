#!/bin/bash
#-----------------------------------------------------------------------------
#
#SBATCH -J tap_jupyter                # Job name
#SBATCH -o jupyter.out                # Name of stdout output file (%j expands to jobId)
#SBATCH -p v100                       # Queue name
#SBATCH -N 1                          # Total number of nodes requested (16 cores/node)
#SBATCH -n 1                          # Total number of mpi tasks requested
#SBATCH -t 04:00:00                   # Run time (hh:mm:ss) - 2 hours

echo "TACC: job $SLURM_JOB_ID execution started at: `date`"

module load tacc-singularity
JUPYTER_DIR="/scratch/projects/jupyter"
JUPYTER_IMG="${JUPYTER_DIR}/jupyter_1.0.0.sif"

#--------------------------------------------------------------------------
# ---- You normally should not need to edit anything below this point -----
#--------------------------------------------------------------------------

TAP_FUNCTIONS="/scratch/projects/share/doc/slurm/tap_functions"
if [ -f ${TAP_FUNCTIONS} ]; then
    . ${TAP_FUNCTIONS}
else
    echo "TACC:"
    echo "TACC: ERROR - could not find TAP functions file: ${TAP_FUNCTIONS}"
    echo "TACC: ERROR - Please submit a consulting ticket at the TACC user portal"
    echo "TACC: ERROR - https://portal.tacc.utexas.edu/tacc-consulting/-/consult/tickets/create"
    echo "TACC:"
    echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"
    exit 1
fi

# gather username from environment
USERNAME=$(whoami)

# gather node name for this job
NODE_HOSTNAME=`hostname -s`
NODE_HOSTNAME_DOMAIN=`hostname -d`

# unload xalt to avoid error messages
module unload xalt

# make .jupyter dir for temp files
JUPYTER_SERVERDIR=$HOME/.jupyter
mkdir -p $JUPYTER_SERVERDIR

JUPYTER_LOGFILE=$JUPYTER_SERVERDIR/$NODE_HOSTNAME.log
echo "TACC: using Jupyter image $JUPYTER_IMG"
echo "TACC: running on node $NODE_HOSTNAME"
echo "TACC: logfile at $JUPYTER_LOGFILE"

# launch jupyter
LOCAL_PORT=8888

echo "TACC: starting Jupyter server in singularity:"
echo ""
echo "singularity run $JUPYTER_IMG"
echo ""

nohup singularity run $JUPYTER_IMG &> $JUPYTER_LOGFILE && rm -f $JUPYTER_SERVERDIR/.jupyter_lock &
JUPYTER_PID=$!
echo "$NODE_HOSTNAME $JUPYTER_PID" > $JUPYTER_SERVERDIR/.jupyter_lock
sleep 30
JUPYTER_TOKEN=`grep -m 1 'token=' $JUPYTER_LOGFILE | cut -d'?' -f 2`

LOGIN_PORT=$(tap_get_port)

# create reverse tunnel port to login nodes (one for each login1 and login2)
for i in `seq 2`; do
    ssh -q -f -g -N -R $LOGIN_PORT:$NODE_HOSTNAME:$LOCAL_PORT login$i
done

echo "TACC: Jupyter launched at $(date)"
echo "TACC: got login node jupyter port $LOGIN_PORT"
echo "TACC: created reverse ports on Longhorn logins"
echo "TACC: Your Jupyter server is now running!"

# provide login instructions
echo ""
echo "Your notebook is now running at http://$NODE_HOSTNAME_DOMAIN:$LOGIN_PORT/lab?$JUPYTER_TOKEN"
echo ""

# spin on .jupyter_lock file to keep job alive
while [ -f $JUPYTER_SERVERDIR/.jupyter_lock ]; do
  sleep 10
done

# wait a brief moment so ipython can clean up after itself
sleep 1
echo "TACC: release port returned: $(tap_release_port ${LOGIN_PORT})"

echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"

