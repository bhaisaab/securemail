# DevOps automation using Fabric and Puppet

Install Fabric:

    pip install fabric

Initialize and bootstrap puppet repository and keys, deploy for the first time
on a node:

    fab -R <role> -H <host> init

Check changes on server:

    fab -R baagi noop

Push eventual changes on server:

    fab -R baagi deploy

Upgrading packages:

    fab -R baagi upgrade
