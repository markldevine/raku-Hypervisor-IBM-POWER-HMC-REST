need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::RelatedIBMiIOSlot;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::RelatedIOAdapter;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::IORDevices;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                    $names-checked = False;
my      Bool                                                                                                                                    $analyzed = False;
my      Lock                                                                                                                                    $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                               $.config is required;
has     Bool                                                                                                                                    $.initialized = False;
has     Bool                                                                                                                                    $.loaded = False;
has     Str                                                                                                                                     $.BusGroupingRequired;
has     Str                                                                                                                                     $.Description;
has     Str                                                                                                                                     @.FeatureCodes;
has     Str                                                                                                                                     $.IOUnitPhysicalLocation;
has     Str                                                                                                                                     $.PartitionID;
has     Str                                                                                                                                     $.PartitionName;
has     Str                                                                                                                                     $.PartitionType;
has     Str                                                                                                                                     $.PCAdapterID;
has     Str                                                                                                                                     $.PCIClass;
has     Str                                                                                                                                     $.PCIDeviceID;
has     Str                                                                                                                                     $.PCISubsystemDeviceID;
has     Str                                                                                                                                     $.PCIManufacturerID;
has     Str                                                                                                                                     $.PCIRevisionID;
has     Str                                                                                                                                     $.PCIVendorID;
has     Str                                                                                                                                     $.PCISubsystemVendorID;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::RelatedIBMiIOSlot   $.RelatedIBMiIOSlot;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::RelatedIOAdapter    $.RelatedIOAdapter;
has     Str                                                                                                                                     $.SlotDynamicReconfigurationConnectorIndex;
has     Str                                                                                                                                     $.SlotDynamicReconfigurationConnectorName;
has     Str                                                                                                                                     $.SlotPhysicalLocationCode;
has     Str                                                                                                                                     $.SRIOVCapableDevice;
has     Str                                                                                                                                     $.SRIOVCapableSlot;
has     Str                                                                                                                                     $.SRIOVLogicalPortsLimit;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::IORDevices          $.IORDevices;

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
    $!RelatedIBMiIOSlot     = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::RelatedIBMiIOSlot.new(:$!config, :xml(self.etl-branch(:TAG<RelatedIBMiIOSlot>, :$!xml)));
    $!RelatedIOAdapter      = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::RelatedIOAdapter.new(:$!config, :xml(self.etl-branch(:TAG<RelatedIOAdapter>, :$!xml)));
    $!IORDevices            = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::IORDevices.new(:$!config, :xml(self.etl-branch(:TAG<IORDevices>, :$!xml, :optional)));
    self.load               if self.config.optimization-init-load;
    $!initialized           = True;
    self;
}

method load () {
    return self                                 if $!loaded;
    self.config.diag.post:                      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!RelatedIBMiIOSlot.load;
    $!RelatedIOAdapter.load;
    $!IORDevices.load;
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
    $!SRIOVCapableDevice                        = self.etl-text(:TAG<SRIOVCapableDevice>,                       :$!xml);
    $!SRIOVCapableSlot                          = self.etl-text(:TAG<SRIOVCapableSlot>,                         :$!xml);
    $!SRIOVLogicalPortsLimit                    = self.etl-text(:TAG<SRIOVLogicalPortsLimit>,                   :$!xml);
    $!xml                                       = Nil;
    $!loaded                                    = True;
    self;
}

=finish
