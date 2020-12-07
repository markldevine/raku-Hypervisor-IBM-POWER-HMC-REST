NAME
====

Hypervisor::IBM::POWER::HMC::REST

AUTHOR
======
Mark Devine <mark@markdevine.com>

TITLE
=====
IBM POWER HMC REST API

SUBTITLE
========
* Management Console

* Managed System

  * Logical Partition

Power Enterprise Pool

Virtual Network Management

Template Library

SR-IOV

Host Ethernet Adapter

Virtual Storage Management

Cluster

Jobs

Job status

Events

Performance and Capacity Monitoring

Performance and Capacity Monitoring JSON Specification

Documentation
=============
See the doc/ directory.

ToDo
====
Must implement an exclusive-execution mechanism so that stashes/profiles don't get smashed (root-directory)

Pick up Atoms too...

method init (Bool :disregard-analysis) {} for all except the first threadloop for repetitive/looped instantiations

debug methods*, find efficiencies (I.e. %!analysis exists and authoritative, then don't analyze)

wrap methods for HIPH_METHOD, HIPH_METHOD_PRIVATE, & HIPH_SUBMETHOD instead of explicit diags (9/14 experiments only worked on simplest role>classes - in these modules they failed; bug?)

fail instead of die, catch the note()/diag(), fatal in Config

etl-node-name-check: what about when code expects a single instance under '*Choice' or plural types, but more than one are actually included?  Re-write into arrays of objects...
has     Hypervisor::IBM::POWER::HMC::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::VirtualFibreChannelMappings::VirtualFibreChannelMapping @.VirtualFibreChannelMapping;
    *** should all be changed to ***
has     Hypervisor::IBM::POWER::HMC::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::VirtualFibreChannelMappings::VirtualFibreChannelMapping @.VirtualFibreChannelMappings;

TWEAK { return self unless $!xml.DEFINITE; } ?  Less risk...  Maybe report type object when expecting a DEFINITE...

More subscriptions
------------------
    subscribe to .data (rename to .dump!)
        - text
        - html
        - csv

Profiling
=========
Each app can have their own "profile". Lazy load()s. If user commits to an explicit set of contexts,
only load() self attributes & all relevant children in the context (not ALL children) -- should
greatly reduce unnecessary load() activities.

"--profile" creates map automatically, if doesn't exist. If profile exists (for subsequent runs),
$*PROGRAM-NAME.IO.absolute & $*PROGRAM-NAME.IO.m is the same, use it if '--profile' switch set.

To intercept an attribute's get_value, check if we're profiling, report to profile map if True, use this mechanism:

```raku
#!/usr/bin/env raku
multi trait_mod:<is> (Attribute:D $a, :$xmlattr!) {
    return      unless %*ENV<HIPH_PROFILING>;
    my $mname   = $a.name.substr(2);
#   my &method  = my method { my \val = $a.get_value(self); val; };
    my &method  = my method {
        self.config.profile-update(self.^name);
        $a.get_value(self);
    }
    &method.set_name($mname);
    $a.package.^add_method($mname, &method);
}
class System {
    has Str $.SerialNumber is xmlattr;
    has Bool $.on = False;
}
say System.new(:SerialNumber('ABCDEFG')).SerialNumber;
```

I.e.  SRIOV only needs:

>    .ManagedSystems

>      .ManagedSystem

>       .AssociatedSystemIOConfiguration

>         .SRIOVAdapters

>           .IOAdapterChoice

>             .IOAdapterChoice

>               .SRIOVAdapter

>                 .ConvergedEthernetPhysicalPorts

>                   .SRIOVConvergedNetworkAdapterPhysicalPort

#   when optimized
#       - prohibit any configuration changes (options)
#           --unconfig is allowed
#           --profile is allowed, in which case profiling is performed anew
#       - isolate hmc/userid (menu, if multiple hmcs/userids)
#       - diagnostics are turned off
#       - file outputs are reviewed
#           --dump-csv      # DUMP-CSV-receive
#           --dump-html     # DUMP-HTML-receive
#           --dump-text     # DUMP-TEXT-receive
#       - formatting options are reviewed
#           --headers
#           --tab-stop
#           --quiet         # might want outputs for various dump subscriptions!
#           --silence       # might want outputs for various dump subscriptions!
#           --verbose       # might want outputs for various dump subscriptions!

