need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
use     URI;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::VirtualFibreChannelMappings::VirtualFibreChannelMapping::ClientAdapter:api<1>:auth<Mark Devine (mark@markdevine.com)>
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

has     Str                                         $.AdapterType;
has     Str                                         $.DynamicReconfigurationConnectorName;
has     Str                                         $.LocationCode;
has     Str                                         $.LocalPartitionID;
has     Str                                         $.RequiredAdapter;
has     Str                                         $.VariedOn;
has     Str                                         $.VirtualSlotNumber;
has     Str                                         $.ConnectingPartitionID;
has     Str                                         $.ConnectingVirtualSlotNumber;
has     Str                                         $.WWPNs;

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
    return self                             if $!loaded;
    self.config.diag.post:                  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!AdapterType                           = self.etl-text(:TAG<AdapterType>,                          :$!xml, :optional);
    $!DynamicReconfigurationConnectorName   = self.etl-text(:TAG<DynamicReconfigurationConnectorName>,  :$!xml, :optional);
    $!LocationCode                          = self.etl-text(:TAG<LocationCode>,                         :$!xml, :optional);
    $!LocalPartitionID                      = self.etl-text(:TAG<LocalPartitionID>,                     :$!xml, :optional);
    $!RequiredAdapter                       = self.etl-text(:TAG<RequiredAdapter>,                      :$!xml, :optional);
    $!VariedOn                              = self.etl-text(:TAG<VariedOn>,                             :$!xml, :optional);
    $!VirtualSlotNumber                     = self.etl-text(:TAG<VirtualSlotNumber>,                    :$!xml, :optional);
    $!ConnectingPartitionID                 = self.etl-text(:TAG<ConnectingPartitionID>,                :$!xml, :optional);
    $!ConnectingVirtualSlotNumber           = self.etl-text(:TAG<ConnectingVirtualSlotNumber>,          :$!xml, :optional);
    $!WWPNs                                 = self.etl-text(:TAG<WWPNs>,                                :$!xml, :optional);
    $!xml                                   = Nil;
    $!loaded                                = True;
    self;
}

=finish
