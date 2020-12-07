need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots::ProfileIOSlot::AssociatedIOSlot::RelatedIBMiIOSlot;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots::ProfileIOSlot::AssociatedIOSlot::RelatedIOAdapter;
use     LibXML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots::ProfileIOSlot::AssociatedIOSlot:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                                                                                $names-checked = False;
my      Bool                                                                                                                                                                                                $analyzed = False;
my      Lock                                                                                                                                                                                                $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                                                                                           $.config is required;
has     Bool                                                                                                                                                                                                $.initialized = False;
has     Bool                                                                                                                                                                                                $.loaded = False;
has     Str                                                                                                                                                                                                 $.BusGroupingRequired;
has     Str                                                                                                                                                                                                 $.Description;
has     Str                                                                                                                                                                                                 @.FeatureCodes;
has     Str                                                                                                                                                                                                 $.IOUnitPhysicalLocation;
has     Str                                                                                                                                                                                                 $.PartitionID;
has     Str                                                                                                                                                                                                 $.PartitionName;
has     Str                                                                                                                                                                                                 $.PartitionType;
has     Str                                                                                                                                                                                                 $.PCAdapterID;
has     Str                                                                                                                                                                                                 $.PCIClass;
has     Str                                                                                                                                                                                                 $.PCIDeviceID;
has     Str                                                                                                                                                                                                 $.PCISubsystemDeviceID;
has     Str                                                                                                                                                                                                 $.PCIManufacturerID;
has     Str                                                                                                                                                                                                 $.PCIRevisionID;
has     Str                                                                                                                                                                                                 $.PCIVendorID;
has     Str                                                                                                                                                                                                 $.PCISubsystemVendorID;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots::ProfileIOSlot::AssociatedIOSlot::RelatedIBMiIOSlot   $.RelatedIBMiIOSlot;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots::ProfileIOSlot::AssociatedIOSlot::RelatedIOAdapter    $.RelatedIOAdapter;
has     Str                                                                                                                                                                                                 $.SlotDynamicReconfigurationConnectorIndex;
has     Str                                                                                                                                                                                                 $.SlotDynamicReconfigurationConnectorName;
has     Str                                                                                                                                                                                                 $.SlotPhysicalLocationCode;
has     Str                                                                                                                                                                                                 $.SRIOVCapableDevice;
has     Str                                                                                                                                                                                                 $.SRIOVCapableSlot;
has     Str                                                                                                                                                                                                 $.SRIOVLogicalPortsLimit;

has     LibXML::Element                                                                                                                                                                                     $!xml-RelatedIBMiIOSlot;
has     LibXML::Element                                                                                                                                                                                     $!xml-RelatedIOAdapter;

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
    $!xml-RelatedIBMiIOSlot = self.etl-branch(:TAG<RelatedIBMiIOSlot>,  :$!xml);
    $!xml-RelatedIOAdapter  = self.etl-branch(:TAG<RelatedIOAdapter>,   :$!xml);
    $!RelatedIBMiIOSlot     = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots::ProfileIOSlot::AssociatedIOSlot::RelatedIBMiIOSlot.new(:$!config,    :xml($!xml-RelatedIBMiIOSlot));
    $!RelatedIOAdapter      = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionIOConfiguration::ProfileIOSlots::ProfileIOSlot::AssociatedIOSlot::RelatedIOAdapter.new(:$!config,     :xml($!xml-RelatedIOAdapter));
    self.load               if self.config.optimization-init-load;
    $!initialized           = True;
    self;
}

method load () {
    return self                                 if $!loaded;
    self.config.diag.post:                      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!RelatedIBMiIOSlot.load;
    $!RelatedIOAdapter.load;
    $!BusGroupingRequired                       = self.etl-text(:TAG<BusGroupingRequired>,                      :$!xml);
    $!Description                               = self.etl-text(:TAG<Description>,                              :$!xml);
    @!FeatureCodes                              = self.etl-texts(:TAG<FeatureCodes>,                            :$!xml, :optional);
    $!IOUnitPhysicalLocation                    = self.etl-text(:TAG<IOUnitPhysicalLocation>,                   :$!xml);
    $!PartitionID                               = self.etl-text(:TAG<PartitionID>,                              :$!xml, :optional);
    $!PartitionName                             = self.etl-text(:TAG<PartitionName>,                            :$!xml, :optional);
    $!PartitionType                             = self.etl-text(:TAG<PartitionType>,                            :$!xml, :optional);
    $!PCAdapterID                               = self.etl-text(:TAG<PCAdapterID>,                              :$!xml);
    $!PCIClass                                  = self.etl-text(:TAG<PCIClass>,                                 :$!xml);
    $!PCIDeviceID                               = self.etl-text(:TAG<PCIDeviceID>,                              :$!xml);
    $!PCISubsystemDeviceID                      = self.etl-text(:TAG<PCISubsystemDeviceID>,                     :$!xml);
    $!PCIManufacturerID                         = self.etl-text(:TAG<PCIManufacturerID>,                        :$!xml);
    $!PCIRevisionID                             = self.etl-text(:TAG<PCIRevisionID>,                            :$!xml);
    $!PCIVendorID                               = self.etl-text(:TAG<PCIVendorID>,                              :$!xml);
    $!PCISubsystemVendorID                      = self.etl-text(:TAG<PCISubsystemVendorID>,                     :$!xml);
    $!SlotDynamicReconfigurationConnectorIndex  = self.etl-text(:TAG<SlotDynamicReconfigurationConnectorIndex>, :$!xml);
    $!SlotDynamicReconfigurationConnectorName   = self.etl-text(:TAG<SlotDynamicReconfigurationConnectorName>,  :$!xml);
    $!SlotPhysicalLocationCode                  = self.etl-text(:TAG<SlotPhysicalLocationCode>,                 :$!xml);
    $!SRIOVCapableDevice                        = self.etl-text(:TAG<SRIOVCapableDevice>,                       :$!xml, :optional);
    $!SRIOVCapableSlot                          = self.etl-text(:TAG<SRIOVCapableSlot>,                         :$!xml, :optional);
    $!SRIOVLogicalPortsLimit                    = self.etl-text(:TAG<SRIOVLogicalPortsLimit>,                   :$!xml, :optional);
    $!xml                                       = Nil;
    $!loaded                                    = True;
    self;
}

=finish
