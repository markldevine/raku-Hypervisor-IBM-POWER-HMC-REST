need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::SharedEthernetAdapters::SharedEthernetAdapter::TrunkAdapters::TrunkAdapter:api<1>:auth<Mark Devine (mark@markdevine.com)>
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

has     Str                                         $.DynamicReconfigurationConnectorName;
has     Str                                         $.LocationCode;
has     Str                                         $.RequiredAdapter;
has     Str                                         $.VariedOn;
has     Str                                         $.VirtualSlotNumber;
has     Str                                         $.AllowedOperatingSystemMACAddresses;
has     Str                                         $.MACAddress;
has     Str                                         $.PortVLANID;
has     Str                                         $.QualityOfServicePriorityEnabled;
has     Str                                         $.TaggedVLANSupported;
has     Str                                         $.VirtualSwitchID;
has     Str                                         $.DeviceName;
has     Str                                         $.TrunkPriority;

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
    $!DynamicReconfigurationConnectorName   = self.etl-text(:TAG<DynamicReconfigurationConnectorName>,  :$!xml);
    $!LocationCode                          = self.etl-text(:TAG<LocationCode>,                         :$!xml);
    $!RequiredAdapter                       = self.etl-text(:TAG<RequiredAdapter>,                      :$!xml);
    $!VariedOn                              = self.etl-text(:TAG<VariedOn>,                             :$!xml);
    $!VirtualSlotNumber                     = self.etl-text(:TAG<VirtualSlotNumber>,                    :$!xml);
    $!AllowedOperatingSystemMACAddresses    = self.etl-text(:TAG<AllowedOperatingSystemMACAddresses>,   :$!xml);
    $!MACAddress                            = self.etl-text(:TAG<MACAddress>,                           :$!xml);
    $!PortVLANID                            = self.etl-text(:TAG<PortVLANID>,                           :$!xml);
    $!QualityOfServicePriorityEnabled       = self.etl-text(:TAG<QualityOfServicePriorityEnabled>,      :$!xml);
    $!TaggedVLANSupported                   = self.etl-text(:TAG<TaggedVLANSupported>,                  :$!xml);
    $!VirtualSwitchID                       = self.etl-text(:TAG<VirtualSwitchID>,                      :$!xml);
    $!DeviceName                            = self.etl-text(:TAG<DeviceName>,                           :$!xml);
    $!TrunkPriority                         = self.etl-text(:TAG<TrunkPriority>,                        :$!xml);
    $!xml                                   = Nil;
    $!loaded                                = True;
    self;
}

=finish
