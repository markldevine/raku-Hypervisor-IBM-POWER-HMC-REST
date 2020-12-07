need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionProcessorConfiguration::CurrentSharedProcessorConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                        $names-checked = False;
my      Bool                                        $analyzed = False;
my      Lock                                        $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config   $.config is required;
has     Bool                                        $.initialized = False;
has     Bool                                        $.loaded = False;

has     Str                                         $.AllocatedVirtualProcessors;
has     Str                                         $.CurrentMaximumProcessingUnits;
has     Str                                         $.CurrentMinimumProcessingUnits;
has     Str                                         $.CurrentProcessingUnits;
has     Str                                         $.CurrentSharedProcessorPoolID;
has     Str                                         $.CurrentUncappedWeight;
has     Str                                         $.CurrentMinimumVirtualProcessors;
has     Str                                         $.CurrentMaximumVirtualProcessors;
has     Str                                         $.RuntimeProcessingUnits;
has     Str                                         $.RuntimeUncappedWeight;

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
    self.load               if self.config.optimization-init-load;
    $!initialized           = True;
    self;
}

method load () {
    return self                         if $!loaded;
    self.config.diag.post:              self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!AllocatedVirtualProcessors        = self.etl-text(:TAG<AllocatedVirtualProcessors>,       :$!xml);
    $!CurrentMaximumProcessingUnits     = self.etl-text(:TAG<CurrentMaximumProcessingUnits>,    :$!xml);
    $!CurrentMinimumProcessingUnits     = self.etl-text(:TAG<CurrentMinimumProcessingUnits>,    :$!xml);
    $!CurrentProcessingUnits            = self.etl-text(:TAG<CurrentProcessingUnits>,           :$!xml);
    $!CurrentSharedProcessorPoolID      = self.etl-text(:TAG<CurrentSharedProcessorPoolID>,     :$!xml);
    $!CurrentUncappedWeight             = self.etl-text(:TAG<CurrentUncappedWeight>,            :$!xml);
    $!CurrentMinimumVirtualProcessors   = self.etl-text(:TAG<CurrentMinimumVirtualProcessors>,  :$!xml);
    $!CurrentMaximumVirtualProcessors   = self.etl-text(:TAG<CurrentMaximumVirtualProcessors>,  :$!xml);
    $!RuntimeProcessingUnits            = self.etl-text(:TAG<RuntimeProcessingUnits>,           :$!xml);
    $!RuntimeUncappedWeight             = self.etl-text(:TAG<RuntimeUncappedWeight>,            :$!xml);
    $!xml                               = Nil;
    $!loaded                            = True;
    self;
}

=finish
