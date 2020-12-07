need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots::IOSlot::IORDevices::IORDevice:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.ParentDynamicReconfigurationConnectorIndex;
has     Str                                         $.ParentName;
has     Str                                         $.PCIDeviceId;
has     Str                                         $.PCIVendorId;
has     Str                                         $.PCISubsystemDeviceId;
has     Str                                         $.PCISubsystemVendorId;
has     Str                                         $.PCIRevisionId;
has     Str                                         $.ProgrammingInterfaceClass;
has     Str                                         $.PCIClassCode;
has     Str                                         $.DeviceType;
has     Str                                         $.PrimaryDeviceFunction;
has     Str                                         $.SerialNumber;
has     Str                                         $.PartNumber;
has     Str                                         $.SlotChildId;
has     Str                                         $.LocationCode;
has     Str                                         $.MacAddressValue;
has     Str                                         $.Description;
has     Str                                         $.CCIN;
has     Str                                         $.FruNumber;
has     Str                                         $.MicroCodeVersion;
has     Str                                         $.NumEnclosureBays;
has     Str                                         $.ParentSlotChildId;
has     Str                                         $.SizeMetric;
has     Str                                         $.Size;
has     Str                                         $.WWNN;
has     Str                                         $.WWPN;

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
    return self                                     if $!loaded;
    self.config.diag.post:                          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!ParentDynamicReconfigurationConnectorIndex    = self.etl-text(:TAG<ParentDynamicReconfigurationConnectorIndex>,   :$!xml, :optional);
    $!ParentName                                    = self.etl-text(:TAG<ParentName>,                                   :$!xml);
    $!PCIDeviceId                                   = self.etl-text(:TAG<PCIDeviceId>,                                  :$!xml, :optional);
    $!PCIVendorId                                   = self.etl-text(:TAG<PCIVendorId>,                                  :$!xml, :optional);
    $!PCISubsystemDeviceId                          = self.etl-text(:TAG<PCISubsystemDeviceId>,                         :$!xml, :optional);
    $!PCISubsystemVendorId                          = self.etl-text(:TAG<PCISubsystemVendorId>,                         :$!xml, :optional);
    $!PCIRevisionId                                 = self.etl-text(:TAG<PCIRevisionId>,                                :$!xml, :optional);
    $!ProgrammingInterfaceClass                     = self.etl-text(:TAG<ProgrammingInterfaceClass>,                    :$!xml, :optional);
    $!PCIClassCode                                  = self.etl-text(:TAG<PCIClassCode>,                                 :$!xml, :optional);
    $!DeviceType                                    = self.etl-text(:TAG<DeviceType>,                                   :$!xml);
    $!PrimaryDeviceFunction                         = self.etl-text(:TAG<PrimaryDeviceFunction>,                        :$!xml, :optional);
    $!SerialNumber                                  = self.etl-text(:TAG<SerialNumber>,                                 :$!xml, :optional);
    $!PartNumber                                    = self.etl-text(:TAG<PartNumber>,                                   :$!xml, :optional);
    $!SlotChildId                                   = self.etl-text(:TAG<SlotChildId>,                                  :$!xml);
    $!LocationCode                                  = self.etl-text(:TAG<LocationCode>,                                 :$!xml);
    $!MacAddressValue                               = self.etl-text(:TAG<MacAddressValue>,                              :$!xml, :optional);
    $!Description                                   = self.etl-text(:TAG<Description>,                                  :$!xml);
    $!CCIN                                          = self.etl-text(:TAG<CCIN>,                                         :$!xml, :optional);
    $!FruNumber                                     = self.etl-text(:TAG<FruNumber>,                                    :$!xml, :optional);
    $!MicroCodeVersion                              = self.etl-text(:TAG<MicroCodeVersion>,                             :$!xml, :optional);
    $!NumEnclosureBays                              = self.etl-text(:TAG<NumEnclosureBays>,                             :$!xml, :optional);
    $!ParentSlotChildId                             = self.etl-text(:TAG<ParentSlotChildId>,                            :$!xml, :optional);
    $!SizeMetric                                    = self.etl-text(:TAG<SizeMetric>,                                   :$!xml, :optional);
    $!Size                                          = self.etl-text(:TAG<Size>,                                         :$!xml, :optional);
    $!WWNN                                          = self.etl-text(:TAG<WWNN>,                                         :$!xml, :optional);
    $!WWPN                                          = self.etl-text(:TAG<WWPN>,                                         :$!xml, :optional);
    $!xml                                           = Nil;
    $!loaded                                        = True;
    self;
}

=finish
