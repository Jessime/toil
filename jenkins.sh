# This file is sourced by Jenkins during a CI build for both PRs and master/release branches.
# A PR may *temporarily* modify this file but a PR will only be merged if this file is identical
# between the PR branch and the target branch. The make_targets variable will contain a space-
# separated list of Makefile targets to invoke.

# Passing --system-site-packages ensures that mesos.native and mesos.interface are included
virtualenv --system-site-packages --never-download venv
. venv/bin/activate

# Install build requirements 
make prepare

# Install Toil and its runtime requirements
make develop extras=[aws,mesos,azure,encryption,cwl]

# Required for running Mesos master and slave daemons as part of the tests
export LIBPROCESS_IP=127.0.0.1

# Needed for integrative provisioner tests
export CGCLOUD_ME=jenkins@jenkins-master

TMPDIR=/mnt/ephemeral/tmp
rm -rf $TMPDIR
mkdir $TMPDIR
# Check that we have enough free space for running the tests
python -c "
min_free_in_GiB = 20
import os, sys
s=os.statvfs('$TMPDIR')
f=s.f_frsize * s.f_bavail
sys.exit(1 if f < min_free_in_GiB << 30 else 0)
"
export TMPDIR
make $make_targets
rm -rf $TMPDIR
