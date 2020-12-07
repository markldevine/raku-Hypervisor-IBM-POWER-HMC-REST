NAME
====

Hypervisor::IBM::POWER::HMC::REST

AUTHOR
======
Mark Devine <mark@markdevine.com>

TITLE
=====
IBM POWER HMC REST API

DEPLOY
======

 - use this before submission to the ecosystem

hiph-git-clone
--------------
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-Atom.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Atom
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-ETL.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ETL
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-Logon.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Logon
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-Config.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Config
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-Cluster.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Cluster
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-Events.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Events
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems-LogicalPartitions.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems-LogicalPartitions
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems-VirtualIOServers.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems-VirtualIOServers
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-ManagementConsole.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagementConsole
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-PowerEnterprisePool.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-PowerEnterprisePool
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST-SystemTemplate.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-SystemTemplate
git clone https://github.com/markldevine/raku-Hypervisor-IBM-POWER-HMC-REST.git ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST


hiph-deploy
-----------
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Atom && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ETL && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Logon && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Config && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Cluster && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-Events && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems-VirtualIOServers && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems-LogicalPartitions && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagedSystems && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-ManagementConsole && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-PowerEnterprisePool && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST-SystemTemplate && zef install . && \
cd ~/github.com/raku-Hypervisor-IBM-POWER-HMC-REST && zef install . && cd ~/github.com
zef list --installed 2> /dev/null | grep Hypervisor::IBM::POWER::HMC::REST | sort
