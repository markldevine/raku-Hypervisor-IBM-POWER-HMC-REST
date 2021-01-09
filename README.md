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

 - use these before submission to the ecosystem

hiph-uninstall
--------------
raku-Hypervisor-IBM-POWER-HMC-REST/distro/hiph-uninstall


hiph-clone
----------
raku-Hypervisor-IBM-POWER-HMC-REST/distro/hiph-clone


hiph-install
-----------
raku-Hypervisor-IBM-POWER-HMC-REST/distro/hiph-install

Note
====

API users must .init() whatever major branches they require:

 - ManagementConsole.init()
 - ManagedSystems.init()
   - ManagedSystems.LogicalVolumes.init()
   - ManagedSystems.VirtualIOServers.init()
