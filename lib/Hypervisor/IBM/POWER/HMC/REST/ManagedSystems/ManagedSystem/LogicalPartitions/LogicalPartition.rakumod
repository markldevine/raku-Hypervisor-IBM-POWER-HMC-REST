need    Hypervisor::IBM::POWER::HMC::REST::Atom;
need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionCapabilities;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionIOConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionMemoryConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::HostEthernetAdapterLogicalPorts;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::HardwareAcceleratorQoS;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::BootListInformation;
use     URI;
use     LibXML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                    $names-checked = False;
my      Bool                                                                                                                                    $analyzed = False;
my      Lock                                                                                                                                    $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Atom                                                                                                 $.atom;
has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                               $.config is required;
has     Bool                                                                                                                                    $.initialized = False;
has     Bool                                                                                                                                    $.loaded = False;
has     Str                                                                                                                                     $.id;
has     DateTime                                                                                                                                $.published;
has     Str                                                                                                                                     $.AllowPerformanceDataCollection;
has     URI                                                                                                                                     $.AssociatedPartitionProfile;
has     Str                                                                                                                                     $.AvailabilityPriority;
has     Str                                                                                                                                     $.CurrentProcessorCompatibilityMode;
has     Str                                                                                                                                     $.CurrentProfileSync;
has     Str                                                                                                                                     $.IsBootable;
has     Str                                                                                                                                     $.IsConnectionMonitoringEnabled;
has     Str                                                                                                                                     $.IsOperationInProgress;
has     Str                                                                                                                                     $.IsRedundantErrorPathReportingEnabled;
has     Str                                                                                                                                     $.IsTimeReferencePartition;
has     Str                                                                                                                                     $.IsVirtualServiceAttentionLEDOn;
has     Str                                                                                                                                     $.IsVirtualTrustedPlatformModuleEnabled;
has     Str                                                                                                                                     $.KeylockPosition;
has     Str                                                                                                                                     $.LogicalSerialNumber;
has     Str                                                                                                                                     $.OperatingSystemVersion;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionCapabilities            $.PartitionCapabilities;
has     Str                                                                                                                                     $.PartitionID;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionIOConfiguration         $.PartitionIOConfiguration;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionMemoryConfiguration     $.PartitionMemoryConfiguration;
has     Str                                                                                                                                     $.PartitionName;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration  $.PartitionProcessorConfiguration;
has     URI                                                                                                                                     @.PartitionProfiles;
has     Str                                                                                                                                     $.PartitionState;
has     Str                                                                                                                                     $.PartitionType;
has     Str                                                                                                                                     $.PartitionUUID;
has     Str                                                                                                                                     $.PendingProcessorCompatibilityMode;
has     URI                                                                                                                                     $.ProcessorPool;
has     Str                                                                                                                                     $.ProgressPartitionDataRemaining;
has     Str                                                                                                                                     $.ProgressPartitionDataTotal;
has     Str                                                                                                                                     $.ProgressState;
has     Str                                                                                                                                     $.ResourceMonitoringControlState;
has     Str                                                                                                                                     $.ResourceMonitoringIPAddress;
has     URI                                                                                                                                     $.AssociatedManagedSystem;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::HostEthernetAdapterLogicalPorts  $.HostEthernetAdapterLogicalPorts;
has     Str                                                                                                                                     $.MACAddressPrefix;
has     Str                                                                                                                                     $.IsServicePartition;
has     Str                                                                                                                                     $.PowerVMManagementCapable;
has     Str                                                                                                                                     $.ReferenceCode;
has     Str                                                                                                                                     $.AssignAllResources;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::HardwareAcceleratorQoS           $.HardwareAcceleratorQoS;
has     Str                                                                                                                                     $.LastActivatedProfile;
has     Str                                                                                                                                     $.HasPhysicalIO;
has     Str                                                                                                                                     $.OperatingSystemType;
has     Str                                                                                                                                     $.PendingSecureBoot;
has     Str                                                                                                                                     $.CurrentSecureBoot;
has     Str                                                                                                                                     $.PowerOnWithHypervisor;
has     Str                                                                                                                                     $.RemoteRestartCapable;
has     Str                                                                                                                                     $.SimplifiedRemoteRestartCapable;
has     Str                                                                                                                                     $.HasDedicatedProcessorsForMigration;
has     Str                                                                                                                                     $.SuspendCapable;
has     Str                                                                                                                                     $.MigrationDisable;
has     Str                                                                                                                                     $.MigrationState;
has     Str                                                                                                                                     $.RemoteRestartState;
has     URI                                                                                                                                     @.VirtualFibreChannelClientAdapters;
has     URI                                                                                                                                     @.DedicatedVirtualNICs;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::BootListInformation              $.BootListInformation;

has     LibXML::Element                                                                                                                         $!xml-content;
has     LibXML::Element                                                                                                                         $!xml-LogicalPartition;
has     LibXML::Element                                                                                                                         $!xml-PartitionCapabilities;
has     LibXML::Element                                                                                                                         $!xml-PartitionIOConfiguration;
has     LibXML::Element                                                                                                                         $!xml-PartitionMemoryConfiguration;
has     LibXML::Element                                                                                                                         $!xml-PartitionProcessorConfiguration;
has     LibXML::Element                                                                                                                         $!xml-HostEthernetAdapterLogicalPorts;
has     LibXML::Element                                                                                                                         $!xml-PartitionProfiles;
has     LibXML::Element                                                                                                                         $!xml-HardwareAcceleratorQoS;
has     LibXML::Element                                                                                                                         $!xml-VirtualFibreChannelClientAdapters;
has     LibXML::Element                                                                                                                         $!xml-DedicatedVirtualNICs;
has     LibXML::Element                                                                                                                         $!xml-BootListInformation;

method  xml-name-exceptions () { return set <Metadata author etag:etag link title content>; }

submethod TWEAK {
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    self.config.diag.post:      sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'START', 't' ~ $*THREAD.id) if %*ENV<HIPH_THREAD_START>;
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
    return self                             if $!initialized;
    self.config.diag.post:                  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!xml-content                           = self.etl-branch(:TAG<content>,                            :$!xml);
    $!xml-LogicalPartition                  = self.etl-branch(:TAG<LogicalPartition:LogicalPartition>,  :xml($!xml-content));
    $!xml-PartitionCapabilities             = self.etl-branch(:TAG<PartitionCapabilities>,              :xml($!xml-LogicalPartition));
    $!xml-PartitionIOConfiguration          = self.etl-branch(:TAG<PartitionIOConfiguration>,           :xml($!xml-LogicalPartition));
    $!xml-PartitionMemoryConfiguration      = self.etl-branch(:TAG<PartitionMemoryConfiguration>,       :xml($!xml-LogicalPartition));
    $!xml-PartitionProcessorConfiguration   = self.etl-branch(:TAG<PartitionProcessorConfiguration>,    :xml($!xml-LogicalPartition));
    $!xml-HostEthernetAdapterLogicalPorts   = self.etl-branch(:TAG<HostEthernetAdapterLogicalPorts>,    :xml($!xml-LogicalPartition));
    $!xml-PartitionProfiles                 = self.etl-branch(:TAG<PartitionProfiles>,                  :xml($!xml-LogicalPartition));
    $!xml-HardwareAcceleratorQoS            = self.etl-branch(:TAG<HardwareAcceleratorQoS>,             :xml($!xml-LogicalPartition));
    $!xml-VirtualFibreChannelClientAdapters = self.etl-branch(:TAG<VirtualFibreChannelClientAdapters>,  :xml($!xml-LogicalPartition), :optional);
    $!xml-DedicatedVirtualNICs              = self.etl-branch(:TAG<DedicatedVirtualNICs>,               :xml($!xml-LogicalPartition), :optional);
    $!xml-BootListInformation               = self.etl-branch(:TAG<BootListInformation>,                :xml($!xml-LogicalPartition));

    $!id                                    = self.etl-text(:TAG<id>,                                   :$!xml);
    $!PartitionName                         = self.etl-text(:TAG<PartitionName>,                        :xml($!xml-LogicalPartition));
    $!atom                                  = self.etl-atom(:xml(self.etl-branch(:TAG<Metadata>,        :xml($!xml-LogicalPartition))));

    $!PartitionCapabilities                 = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionCapabilities.new(:$!config, :xml($!xml-PartitionCapabilities));
    $!PartitionIOConfiguration              = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionIOConfiguration.new(:$!config, :xml($!xml-PartitionIOConfiguration));
    $!PartitionMemoryConfiguration          = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionMemoryConfiguration.new(:$!config, :xml($!xml-PartitionMemoryConfiguration));
    $!PartitionProcessorConfiguration       = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration.new(:$!config, :xml($!xml-PartitionProcessorConfiguration));
    $!HostEthernetAdapterLogicalPorts       = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::HostEthernetAdapterLogicalPorts.new(:$!config, :xml($!xml-HostEthernetAdapterLogicalPorts));
    $!HardwareAcceleratorQoS                = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::HardwareAcceleratorQoS.new(:$!config, :xml($!xml-HardwareAcceleratorQoS));
    $!BootListInformation                   = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::BootListInformation.new(:$!config, :xml($!xml-BootListInformation));
    self.load                               if self.config.optimization-init-load;
    $!initialized                           = True;
    self;
}

method load () {
    return self                                 if $!loaded;
    self.config.diag.post:                      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!PartitionCapabilities.load;
    $!PartitionIOConfiguration.load;
    $!PartitionMemoryConfiguration.load;
    $!PartitionProcessorConfiguration.load;
    $!HostEthernetAdapterLogicalPorts.load;
    $!HardwareAcceleratorQoS.load;
    $!BootListInformation.load;
    $!published                                 = DateTime.new(self.etl-text(:TAG<published>,                           :$!xml));
    $!AllowPerformanceDataCollection            = self.etl-text(:TAG<AllowPerformanceDataCollection>,                   :xml($!xml-LogicalPartition));
    $!AssociatedPartitionProfile                = self.etl-href(:xml(self.etl-branch(:TAG<AssociatedPartitionProfile>,  :xml($!xml-LogicalPartition), :optional)));
    $!AvailabilityPriority                      = self.etl-text(:TAG<AvailabilityPriority>,                             :xml($!xml-LogicalPartition));
    $!CurrentProcessorCompatibilityMode         = self.etl-text(:TAG<CurrentProcessorCompatibilityMode>,                :xml($!xml-LogicalPartition));
    $!CurrentProfileSync                        = self.etl-text(:TAG<CurrentProfileSync>,                               :xml($!xml-LogicalPartition));
    $!IsBootable                                = self.etl-text(:TAG<IsBootable>,                                       :xml($!xml-LogicalPartition));
    $!IsConnectionMonitoringEnabled             = self.etl-text(:TAG<IsConnectionMonitoringEnabled>,                    :xml($!xml-LogicalPartition), :optional);
    $!IsOperationInProgress                     = self.etl-text(:TAG<IsOperationInProgress>,                            :xml($!xml-LogicalPartition));
    $!IsRedundantErrorPathReportingEnabled      = self.etl-text(:TAG<IsRedundantErrorPathReportingEnabled>,             :xml($!xml-LogicalPartition));
    $!IsTimeReferencePartition                  = self.etl-text(:TAG<IsTimeReferencePartition>,                         :xml($!xml-LogicalPartition));
    $!IsVirtualServiceAttentionLEDOn            = self.etl-text(:TAG<IsVirtualServiceAttentionLEDOn>,                   :xml($!xml-LogicalPartition));
    $!IsVirtualTrustedPlatformModuleEnabled     = self.etl-text(:TAG<IsVirtualTrustedPlatformModuleEnabled>,            :xml($!xml-LogicalPartition));
    $!KeylockPosition                           = self.etl-text(:TAG<KeylockPosition>,                                  :xml($!xml-LogicalPartition));
    $!LogicalSerialNumber                       = self.etl-text(:TAG<LogicalSerialNumber>,                              :xml($!xml-LogicalPartition));
    $!OperatingSystemVersion                    = self.etl-text(:TAG<OperatingSystemVersion>,                           :xml($!xml-LogicalPartition));
    $!PartitionID                               = self.etl-text(:TAG<PartitionID>,                                      :xml($!xml-LogicalPartition));
    @!PartitionProfiles                         = self.etl-links-URIs(                                                  :xml($!xml-PartitionProfiles));
    $!PartitionState                            = self.etl-text(:TAG<PartitionState>,                                   :xml($!xml-LogicalPartition));
    $!PartitionType                             = self.etl-text(:TAG<PartitionType>,                                    :xml($!xml-LogicalPartition));
    $!PartitionUUID                             = self.etl-text(:TAG<PartitionUUID>,                                    :xml($!xml-LogicalPartition));
    $!PendingProcessorCompatibilityMode         = self.etl-text(:TAG<PendingProcessorCompatibilityMode>,                :xml($!xml-LogicalPartition));
    $!ProcessorPool                             = self.etl-href(:xml(self.etl-branch(:TAG<ProcessorPool>,               :xml($!xml-LogicalPartition), :optional)));
    $!ProgressPartitionDataRemaining            = self.etl-text(:TAG<ProgressPartitionDataRemaining>,                   :xml($!xml-LogicalPartition));
    $!ProgressPartitionDataTotal                = self.etl-text(:TAG<ProgressPartitionDataTotal>,                       :xml($!xml-LogicalPartition));
    $!ProgressState                             = self.etl-text(:TAG<ProgressState>,                                    :xml($!xml-LogicalPartition), :optional);
    $!ResourceMonitoringControlState            = self.etl-text(:TAG<ResourceMonitoringControlState>,                   :xml($!xml-LogicalPartition));
    $!ResourceMonitoringIPAddress               = self.etl-text(:TAG<ResourceMonitoringIPAddress>,                      :xml($!xml-LogicalPartition), :optional);
    $!AssociatedManagedSystem                   = self.etl-href(:xml(self.etl-branch(:TAG<AssociatedManagedSystem>,     :xml($!xml-LogicalPartition))));
    $!MACAddressPrefix                          = self.etl-text(:TAG<MACAddressPrefix>,                                 :xml($!xml-LogicalPartition), :optional);
    $!IsServicePartition                        = self.etl-text(:TAG<IsServicePartition>,                               :xml($!xml-LogicalPartition));
    $!PowerVMManagementCapable                  = self.etl-text(:TAG<PowerVMManagementCapable>,                         :xml($!xml-LogicalPartition));
    $!ReferenceCode                             = self.etl-text(:TAG<ReferenceCode>,                                    :xml($!xml-LogicalPartition), :optional);
    $!AssignAllResources                        = self.etl-text(:TAG<AssignAllResources>,                               :xml($!xml-LogicalPartition));
    $!LastActivatedProfile                      = self.etl-text(:TAG<LastActivatedProfile>,                             :xml($!xml-LogicalPartition), :optional);
    $!HasPhysicalIO                             = self.etl-text(:TAG<HasPhysicalIO>,                                    :xml($!xml-LogicalPartition));
    $!OperatingSystemType                       = self.etl-text(:TAG<OperatingSystemType>,                              :xml($!xml-LogicalPartition));
    $!PendingSecureBoot                         = self.etl-text(:TAG<PendingSecureBoot>,                                :xml($!xml-LogicalPartition));
    $!CurrentSecureBoot                         = self.etl-text(:TAG<CurrentSecureBoot>,                                :xml($!xml-LogicalPartition));
    $!PowerOnWithHypervisor                     = self.etl-text(:TAG<PowerOnWithHypervisor>,                            :xml($!xml-LogicalPartition));
    $!RemoteRestartCapable                      = self.etl-text(:TAG<RemoteRestartCapable>,                             :xml($!xml-LogicalPartition));
    $!SimplifiedRemoteRestartCapable            = self.etl-text(:TAG<SimplifiedRemoteRestartCapable>,                   :xml($!xml-LogicalPartition));
    $!HasDedicatedProcessorsForMigration        = self.etl-text(:TAG<HasDedicatedProcessorsForMigration>,               :xml($!xml-LogicalPartition));
    $!SuspendCapable                            = self.etl-text(:TAG<SuspendCapable>,                                   :xml($!xml-LogicalPartition));
    $!MigrationDisable                          = self.etl-text(:TAG<MigrationDisable>,                                 :xml($!xml-LogicalPartition));
    $!MigrationState                            = self.etl-text(:TAG<MigrationState>,                                   :xml($!xml-LogicalPartition));
    $!RemoteRestartState                        = self.etl-text(:TAG<RemoteRestartState>,                               :xml($!xml-LogicalPartition));
    @!VirtualFibreChannelClientAdapters         = self.etl-links-URIs(                                                  :xml($!xml-VirtualFibreChannelClientAdapters));
    @!DedicatedVirtualNICs                      = self.etl-links-URIs(                                                  :xml($!xml-DedicatedVirtualNICs));
    $!xml                                       = Nil;
    $!loaded                                    = True;
    self;
}

=finish
