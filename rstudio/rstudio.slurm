#!/bin/bash
#-----------------------------------------------------------------------------
#
#SBATCH -J tap_rstudio                # Job name
#SBATCH -o rstudio.out                # Name of stdout output file (%j expands to jobId)
#SBATCH -p v100                       # Queue name
#SBATCH -N 1                          # Total number of nodes requested (16 cores/node)
#SBATCH -n 1                          # Total number of mpi tasks requested
#SBATCH -t 04:00:00                   # Run time (hh:mm:ss) - 2 hours

echo "TACC: job $SLURM_JOB_ID execution started at: `date`"

module load tacc-singularity
RSTUDIO_DIR="/scratch/projects/rstudio"
RSTUDIO_IMG="${RSTUDIO_DIR}/rstudio_1.4.1717.sif"

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

# make .rstudio dir for temp files, clean up after old run
RSTUDIO_SERVERDIR=$HOME/.rstudio
mkdir -p $RSTUDIO_SERVERDIR
rm -f $RSTUDIO_SERVERDIR/.rstudio_address \
      $RSTUDIO_SERVERDIR/.rstudio_port \
      $RSTUDIO_SERVERDIR/.rstudio_status \
      $RSTUDIO_SERVERDIR/.rstudio_job_id \
      $RSTUDIO_SERVERDIR/.rstudio_job_start \
      $RSTUDIO_SERVERDIR/.rstudio_job_duration

# make dirs to bind mount
BIND_ROOT=$HOME/.rstudio/var
mkdir -p $BIND_ROOT/run/rstudio-server 
mkdir -p $BIND_ROOT/lock/rstudio-server
mkdir -p $BIND_ROOT/log/rstudio-server 
mkdir -p $BIND_ROOT/lib/rstudio-server 

echo "TACC: using Rstudio image $RSTUDIO_IMG"
echo "TACC: running on node $NODE_HOSTNAME"
echo "TACC: cleaning temp dir at $HOME/.rstudio"

# launch rstudio
LOCAL_PORT=8787
RSTUDIO_PASSWORD=`uuidgen`
export SINGULARITYENV_PASSWORD=$RSTUDIO_PASSWORD 

echo "TACC: starting Rstudio server in singularity:"
echo ""
echo "singularity exec -B $BIND_ROOT/run/rstudio-server:/var/run/rstudio-server \ "
echo "                 -B $BIND_ROOT/run/rstudio-server:/var/lock/rstudio-server \ "
echo "                 -B $BIND_ROOT/run/rstudio-server:/var/log/rstudio-server \ "
echo "                 -B $BIND_ROOT/run/rstudio-server:/var/lib/rstudio-server \ "
echo "                 $RSTUDIO_IMG rserver \ "
echo "                 --www-address=0.0.0.0 \ "
echo "                 --www-port=${LOCAL_PORT} \ "
echo "                 --auth-none=0 \ "
echo "                 --auth-pam-helper-path=/usr/local/bin/pam-helper >> $RSTUDIO_SERVERDIR/rstudio.log 2>&1 & "
echo ""

nohup singularity exec -B $BIND_ROOT/run/rstudio-server:/var/run/rstudio-server \
                       -B $BIND_ROOT/lock/rstudio-server:/var/lock/rstudio-server \
                       -B $BIND_ROOT/log/rstudio-server:/var/log/rstudio-server \
                       -B $BIND_ROOT/lib/rstudio-server:/var/lib/rstudio-server \
                       $RSTUDIO_IMG rserver \
                       --www-address=0.0.0.0 \
                       --www-port=${LOCAL_PORT} \
                       --auth-none=0 \
                       --auth-pam-helper-path=/usr/local/bin/pam-helper >> $RSTUDIO_SERVERDIR/rstudio.log 2>&1 && rm -f $RSTUDIO_SERVERDIR/.rstudio_lock &
RSTUDIO_PID=$!
echo "$NODE_HOSTNAME $RSTUDIO_PID" > $RSTUDIO_SERVERDIR/.rstudio_lock
sleep 20

# mapping uses node number then rack number for mapping
#LOGIN_PORT=`echo $NODE_HOSTNAME | perl -ne 'print (($2.$1)+50000) if /c\d\d(\d)-\d(\d\d)/;'`
LOGIN_PORT=$(tap_get_port)

# create reverse tunnel port to login nodes (one for each login1 and login2)
for i in `seq 2`; do
    ssh -q -f -g -N -R $LOGIN_PORT:$NODE_HOSTNAME:$LOCAL_PORT login$i
done

echo "TACC: Rstudio launched at $(date)"
echo "TACC: got login node rstudio port $LOGIN_PORT"
echo "TACC: created reverse ports on Longhorn logins"
echo "TACC: Your Rstudio server is now running!"

# provide login instructions
echo ""
echo "Your instance is now running at http://$NODE_HOSTNAME_DOMAIN:$LOGIN_PORT"
echo "After navigating to that address in your local web browser, authenticate using"
echo "your TACC username the password '$RSTUDIO_PASSWORD'"
echo ""

# spin on .rstudio_lockfile to keep job alive
while [ -f $RSTUDIO_SERVERDIR/.rstudio_lock ]; do
  sleep 10
done

# wait a brief moment so ipython can clean up after itself
sleep 1
echo "TACC: release port returned: $(tap_release_port ${LOGIN_PORT})"

echo "TACC: job $SLURM_JOB_ID execution finished at: `date`"

