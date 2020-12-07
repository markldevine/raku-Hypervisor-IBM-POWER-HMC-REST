need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::BackingDeviceChoice;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::TrunkAdapters;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::IPInterface;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                                                    $names-checked = False;
my      Bool                                                                                                                                                                    $analyzed = False;
my      Lock                                                                                                                                                                    $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                                                               $.config is required;
has     Bool                                                                                                                                                                    $.initialized = False;
has     Bool                                                                                                                                                                    $.loaded = False;

has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::BackingDeviceChoice $.BackingDeviceChoice;
has     Str                                                                                                                                                                     $.HighAvailabilityMode;
has     Str                                                                                                                                                                     $.DeviceName;
has     Str                                                                                                                                                                     $.JumboFramesEnabled;
has     Str                                                                                                                                                                     $.PortVLANID;
has     Str                                                                                                                                                                     $.QualityOfServiceMode;
has     Str                                                                                                                                                                     $.QueueSize;
has     Str                                                                                                                                                                     $.ThreadModeEnabled;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::TrunkAdapters       $.TrunkAdapters;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::IPInterface         $.IPInterface;
has     Str                                                                                                                                                                     $.UniqueDeviceID;
has     Str                                                                                                                                                                     $.LargeSend;
has     Str                                                                                                                                                                     $.ConfigurationState;

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
    $!BackingDeviceChoice   = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::BackingDeviceChoice.new(:$!config, :xml(self.etl-branch(:TAG<BackingDeviceChoice>, :$!xml)));
    $!TrunkAdapters         = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::TrunkAdapters.new(:$!config, :xml(self.etl-branch(:TAG<TrunkAdapters>, :$!xml)));
    $!IPInterface           = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::IPInterface.new(:$!config, :xml(self.etl-branch(:TAG<IPInterface>, :$!xml)));
    self.load               if self.config.optimization-init-load;
    $!initialized           = True;
    self;
}

method load () {
    return self             if $!loaded;
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!BackingDeviceChoice.load;
    $!TrunkAdapters.load;
    $!IPInterface.load;
    $!HighAvailabilityMode  = self.etl-text(:TAG<HighAvailabilityMode>, :$!xml);
    $!DeviceName            = self.etl-text(:TAG<DeviceName>,           :$!xml);
    $!JumboFramesEnabled    = self.etl-text(:TAG<JumboFramesEnabled>,   :$!xml);
    $!PortVLANID            = self.etl-text(:TAG<PortVLANID>,           :$!xml);
    $!QualityOfServiceMode  = self.etl-text(:TAG<QualityOfServiceMode>, :$!xml);
    $!QueueSize             = self.etl-text(:TAG<QueueSize>,            :$!xml);
    $!ThreadModeEnabled     = self.etl-text(:TAG<ThreadModeEnabled>,    :$!xml);
    $!UniqueDeviceID        = self.etl-text(:TAG<UniqueDeviceID>,       :$!xml);
    $!LargeSend             = self.etl-text(:TAG<LargeSend>,            :$!xml);
    $!ConfigurationState    = self.etl-text(:TAG<ConfigurationState>,   :$!xml);
    $!xml                   = Nil;
    $!loaded                = True;
    self;
}

=finish
