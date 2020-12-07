need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                            $names-checked = False;
my      Bool                                                                                                                                            $analyzed = False;
my      Lock                                                                                                                                            $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                                       $.config is required;
has     Bool                                                                                                                                            $.initialized = False;
has     Bool                                                                                                                                            $.loaded = False;
has     Str                                                                                                                                             $.MaximumVirtualIOSlots;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots   $.ProfileIOSlots;
has     Str                                                                                                                                             $.CurrentMaximumVirtualIOSlots;

method  xml-name-exceptions () { return set <Metadata>; }

submethod TWEAK {
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    my $proceed-with-name-check = False;
    my $proceed-with-analyze    = False;
    $lock.protect({
        if !$analyzed           { $proceed-with-analyze    = True; $analyzed      = True; }
        if !$names-checked      { $proceed-with-name-check = True; $names-checked = True; }
    });
    self.etl-node-name-check    if $proceed-with-name-check;
    self.init;
    self.analyze                if $proceed-with-analyze;
    self;
}

method init () {
    return self             if $!initialized;
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!ProfileIOSlots        = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots.new(:$!config, :xml(self.etl-branch(:TAG<ProfileIOSlots>, :$!xml)));
    self.load               if self.config.optimization-init-load;
    $!initialized           = True;
    self;
}

method load () {
    return self                     if $!loaded;
    self.config.diag.post:          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!ProfileIOSlots.load;
    $!MaximumVirtualIOSlots         = self.etl-text(:TAG<MaximumVirtualIOSlots>,        :$!xml);
    $!CurrentMaximumVirtualIOSlots  = self.etl-text(:TAG<CurrentMaximumVirtualIOSlots>, :$!xml);
    $!xml                           = Nil;
    $!loaded                        = True;
    self;
}

=finish
