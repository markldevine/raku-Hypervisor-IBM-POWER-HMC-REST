need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::ConvergedEthernetPhysicalPorts::SRIOVConvergedNetworkAdapterPhysicalPort:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.ConfiguredConnectionSpeed;
has     Str                                         $.ConfiguredMTU;
has     Str                                         @.ConfiguredOptions;
has     Str                                         $.CurrentConnectionSpeed;
has     Str                                         @.CurrentOptions;
has     Str                                         $.Label;
has     Str                                         $.LocationCode;
has     Str                                         $.MaximumDiagnosticsLogicalPorts;
has     Str                                         $.MaximumPromiscuousLogicalPorts;
has     Str                                         $.PhysicalPortID;
has     Str                                         @.PortCapabilities;
has     Str                                         $.PortType;
has     Str                                         $.PortLogicalPortLimit;
has     Str                                         $.SubLabel;
has     Str                                         @.SupportedConnectionSpeeds;
has     Str                                         @.SupportedMTUs;
has     Str                                         @.SupportedOptions;
has     Str                                         $.SupportedPriorityAccessControlList;
has     Str                                         $.LinkStatus;
has     Str                                         $.AllocatedCapacity;
has     Str                                         $.ConfiguredMaxEthernetLogicalPorts;
has     Str                                         $.ConfiguredEthernetLogicalPorts;
has     Str                                         $.MaximumPortVLANID;
has     Str                                         $.MaximumVLANID;
has     Str                                         $.MinimumEthernetCapacityGranularity;
has     Str                                         $.MinimumPortVLANID;
has     Str                                         $.MinimumVLANID;
has     Str                                         $.MaxSupportedEthernetLogicalPorts;
has     Str                                         $.MaximumAllowedEthVLANs;
has     Str                                         $.MaximumAllowedEthMACs;
has     Str                                         $.ConfiguredMaxFiberChannelOverEthernetLogicalPorts;
has     Str                                         $.DefaultFiberChannelTargetsForBackingDevice;
has     Str                                         $.DefaultFiberChannelTargetsForNonBackingDevice;
has     Str                                         $.ConfiguredFiberChannelOverEthernetLogicalPorts;
has     Str                                         $.FiberChannelTargetsRoundingValue;
has     Str                                         $.MaxSupportedFiberChannelOverEthernetLogicalPorts;
has     Str                                         $.MaximumFiberChannelTargets;

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
    return self                                         if $!loaded;
    self.config.diag.post:                              self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!ConfiguredConnectionSpeed                         = self.etl-text(:TAG<ConfiguredConnectionSpeed>,                            :$!xml);
    $!ConfiguredMTU                                     = self.etl-text(:TAG<ConfiguredMTU>,                                        :$!xml);
    @!ConfiguredOptions                                 = self.etl-texts(:TAG<ConfiguredOptions>,                                   :$!xml);
    $!CurrentConnectionSpeed                            = self.etl-text(:TAG<CurrentConnectionSpeed>,                               :$!xml);
    @!CurrentOptions                                    = self.etl-texts(:TAG<CurrentOptions>,                                      :$!xml);
    $!Label                                             = self.etl-text(:TAG<Label>,                                                :$!xml, :optional);
    $!LocationCode                                      = self.etl-text(:TAG<LocationCode>,                                         :$!xml);
    $!MaximumDiagnosticsLogicalPorts                    = self.etl-text(:TAG<MaximumDiagnosticsLogicalPorts>,                       :$!xml);
    $!MaximumPromiscuousLogicalPorts                    = self.etl-text(:TAG<MaximumPromiscuousLogicalPorts>,                       :$!xml);
    $!PhysicalPortID                                    = self.etl-text(:TAG<PhysicalPortID>,                                       :$!xml);
    @!PortCapabilities                                  = self.etl-texts(:TAG<PortCapabilities>,                                    :$!xml);
    $!PortType                                          = self.etl-text(:TAG<PortType>,                                             :$!xml);
    $!PortLogicalPortLimit                              = self.etl-text(:TAG<PortLogicalPortLimit>,                                 :$!xml);
    $!SubLabel                                          = self.etl-text(:TAG<SubLabel>,                                             :$!xml, :optional);
    @!SupportedConnectionSpeeds                         = self.etl-texts(:TAG<SupportedConnectionSpeeds>,                           :$!xml);
    @!SupportedMTUs                                     = self.etl-texts(:TAG<SupportedMTUs>,                                       :$!xml);
    @!SupportedOptions                                  = self.etl-texts(:TAG<SupportedOptions>,                                    :$!xml);
    $!SupportedPriorityAccessControlList                = self.etl-text(:TAG<SupportedPriorityAccessControlList>,                   :$!xml);
    $!LinkStatus                                        = self.etl-text(:TAG<LinkStatus>,                                           :$!xml);
    $!AllocatedCapacity                                 = self.etl-text(:TAG<AllocatedCapacity>,                                    :$!xml);
    $!ConfiguredMaxEthernetLogicalPorts                 = self.etl-text(:TAG<ConfiguredMaxEthernetLogicalPorts>,                    :$!xml);
    $!ConfiguredEthernetLogicalPorts                    = self.etl-text(:TAG<ConfiguredEthernetLogicalPorts>,                       :$!xml);
    $!MaximumPortVLANID                                 = self.etl-text(:TAG<MaximumPortVLANID>,                                    :$!xml);
    $!MaximumVLANID                                     = self.etl-text(:TAG<MaximumVLANID>,                                        :$!xml);
    $!MinimumEthernetCapacityGranularity                = self.etl-text(:TAG<MinimumEthernetCapacityGranularity>,                   :$!xml);
    $!MinimumPortVLANID                                 = self.etl-text(:TAG<MinimumPortVLANID>,                                    :$!xml);
    $!MinimumVLANID                                     = self.etl-text(:TAG<MinimumVLANID>,                                        :$!xml);
    $!MaxSupportedEthernetLogicalPorts                  = self.etl-text(:TAG<MaxSupportedEthernetLogicalPorts>,                     :$!xml);
    $!MaximumAllowedEthVLANs                            = self.etl-text(:TAG<MaximumAllowedEthVLANs>,                               :$!xml);
    $!MaximumAllowedEthMACs                             = self.etl-text(:TAG<MaximumAllowedEthMACs>,                                :$!xml);
    $!ConfiguredMaxFiberChannelOverEthernetLogicalPorts = self.etl-text(:TAG<ConfiguredMaxFiberChannelOverEthernetLogicalPorts>,    :$!xml);
    $!DefaultFiberChannelTargetsForBackingDevice        = self.etl-text(:TAG<DefaultFiberChannelTargetsForBackingDevice>,           :$!xml);
    $!DefaultFiberChannelTargetsForNonBackingDevice     = self.etl-text(:TAG<DefaultFiberChannelTargetsForNonBackingDevice>,        :$!xml);
    $!ConfiguredFiberChannelOverEthernetLogicalPorts    = self.etl-text(:TAG<ConfiguredFiberChannelOverEthernetLogicalPorts>,       :$!xml);
    $!FiberChannelTargetsRoundingValue                  = self.etl-text(:TAG<FiberChannelTargetsRoundingValue>,                     :$!xml);
    $!MaxSupportedFiberChannelOverEthernetLogicalPorts  = self.etl-text(:TAG<MaxSupportedFiberChannelOverEthernetLogicalPorts>,     :$!xml);
    $!MaximumFiberChannelTargets                        = self.etl-text(:TAG<MaximumFiberChannelTargets>,                           :$!xml);
    $!xml                                               = Nil;
    $!loaded                                            = True;
    self;
}

=finish
