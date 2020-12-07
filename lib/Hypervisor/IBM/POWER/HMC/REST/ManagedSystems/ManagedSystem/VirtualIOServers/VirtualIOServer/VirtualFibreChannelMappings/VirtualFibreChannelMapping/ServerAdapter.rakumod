need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::VirtualFibreChannelMappings::VirtualFibreChannelMapping::ServerAdapter::PhysicalPort;
use     URI;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::VirtualFibreChannelMappings::VirtualFibreChannelMapping::ServerAdapter:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                                                                        $names-checked = False;
my      Bool                                                                                                                                                                                        $analyzed = False;
my      Lock                                                                                                                                                                                        $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                                                                                   $.config is required;
has     Bool                                                                                                                                                                                        $.initialized = False;
has     Bool                                                                                                                                                                                        $.loaded = False;

has     Str                                                                                                                                                                                         $.AdapterType;
has     Str                                                                                                                                                                                         $.DynamicReconfigurationConnectorName;
has     Str                                                                                                                                                                                         $.LocationCode;
has     Str                                                                                                                                                                                         $.LocalPartitionID;
has     Str                                                                                                                                                                                         $.RequiredAdapter;
has     Str                                                                                                                                                                                         $.VariedOn;
has     Str                                                                                                                                                                                         $.VirtualSlotNumber;
has     Str                                                                                                                                                                                         $.AdapterName;
has     Str                                                                                                                                                                                         $.ConnectingPartitionID;
has     Str                                                                                                                                                                                         $.ConnectingVirtualSlotNumber;
has     Str                                                                                                                                                                                         $.UniqueDeviceID;
has     Str                                                                                                                                                                                         $.MapPort;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::VirtualFibreChannelMappings::VirtualFibreChannelMapping::ServerAdapter::PhysicalPort   $.PhysicalPort;

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
    $!PhysicalPort          = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::VirtualFibreChannelMappings::VirtualFibreChannelMapping::ServerAdapter::PhysicalPort.new(:$!config, :xml(self.etl-branch(:TAG<PhysicalPort>, :$!xml, :optional)));
    self.load               if self.config.optimization-init-load;
    $!initialized           = True;
    self;
}

method load () {
    return self                             if $!loaded;
    self.config.diag.post:                  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!PhysicalPort.load                     with $!PhysicalPort;
    $!AdapterType                           = self.etl-text(:TAG<AdapterType>,                          :$!xml);
    $!DynamicReconfigurationConnectorName   = self.etl-text(:TAG<DynamicReconfigurationConnectorName>,  :$!xml);
    $!LocationCode                          = self.etl-text(:TAG<LocationCode>,                         :$!xml);
    $!LocalPartitionID                      = self.etl-text(:TAG<LocalPartitionID>,                     :$!xml);
    $!RequiredAdapter                       = self.etl-text(:TAG<RequiredAdapter>,                      :$!xml);
    $!VariedOn                              = self.etl-text(:TAG<VariedOn>,                             :$!xml);
    $!VirtualSlotNumber                     = self.etl-text(:TAG<VirtualSlotNumber>,                    :$!xml);
    $!AdapterName                           = self.etl-text(:TAG<AdapterName>,                          :$!xml);
    $!ConnectingPartitionID                 = self.etl-text(:TAG<ConnectingPartitionID>,                :$!xml);
    $!ConnectingVirtualSlotNumber           = self.etl-text(:TAG<ConnectingVirtualSlotNumber>,          :$!xml);
    $!UniqueDeviceID                        = self.etl-text(:TAG<UniqueDeviceID>,                       :$!xml);
    $!MapPort                               = self.etl-text(:TAG<MapPort>,                              :$!xml, :optional);
    $!xml                                   = Nil;
    $!loaded                                = True;
    self;
}

=finish
