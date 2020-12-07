need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemCapabilities:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.ActiveLogicalPartitionMobilityCapable;
has     Str                                         $.ActiveLogicalPartitionSharedIdeProcessorsCapable;
has     Str                                         $.ActiveMemoryDeduplicationCapable;
has     Str                                         $.ActiveMemoryExpansionCapable;
has     Str                                         $.ActiveMemoryMirroringCapable;
has     Str                                         $.ActiveMemorySharingCapable;
has     Str                                         $.AddressBroadcastPolicyCapable;
has     Str                                         $.AIXCapable;
has     Str                                         $.AutorecoveryPowerOnCapable;
has     Str                                         $.BarrierSynchronizationRegisterCapable;
has     Str                                         $.CapacityOnDemandMemoryCapable;
has     Str                                         $.CapacityOnDemandProcessorCapable;
has     Str                                         $.CAPICapable;
has     Str                                         $.CustomLogicalPartitionPlacementCapable;
has     Str                                         $.ElectronicErrorReportingCapable;
has     Str                                         $.ExternalIntrusionDetectionCapable;
has     Str                                         $.FirmwarePowerSaverCapable;
has     Str                                         $.HardwareDiscoveryCapable;
has     Str                                         $.HardwareMemoryCompressionCapable;
has     Str                                         $.HardwareMemoryEncryptionCapable;
has     Str                                         $.HardwarePowerSaverCapable;
has     Str                                         $.HostChannelAdapterCapable;
has     Str                                         $.HugePageMemoryCapable;
has     Str                                         $.HugePageMemoryOverrideCapable;
has     Str                                         $.IBMiCapable;
has     Str                                         $.IBMiLogicalPartitionMobilityCapable;
has     Str                                         $.IBMiLogicalPartitionSuspendCapable;
has     Str                                         $.IBMiNetworkInstallCapable;
has     Str                                         $.IBMiRestrictedIOModeCapable;
has     Str                                         $.IBMiNetworkInstallVlanCapable;
has     Str                                         $.InactiveLogicalPartitionMobilityCapable;
has     Str                                         $.IntelligentPlatformManagementInterfaceCapable;
has     Str                                         $.LinuxCapable;
has     Str                                         $.LogicalHostEthernetAdapterCapable;
has     Str                                         $.LogicalPartitionAffinityGroupCapable;
has     Str                                         $.LogicalPartitionAvailabilityPriorityCapable;
has     Str                                         $.LogicalPartitionEnergyManagementCapable;
has     Str                                         $.LogicalPartitionProcessorCompatibilityModeCapable;
has     Str                                         $.LogicalPartitionRemoteRestartCapable;
has     Str                                         $.LogicalPartitionSuspendCapable;
has     Str                                         $.MemoryMirroringCapable;
has     Str                                         $.MicroLogicalPartitionCapable;
has     Str                                         $.PowerVMLogicalPartitionSimplifiedRemoteRestartCapable;
has     Str                                         $.RedundantErrorPathReportingCapable;
has     Str                                         $.RemoteRestartToggleCapable;
has     Str                                         $.ServiceProcessorConcurrentMaintenanceCapable;
has     Str                                         $.ServiceProcessorFailoverCapable;
has     Str                                         $.ServiceProcessorAutonomicIPLCapable;
has     Str                                         $.SharedEthernetFailoverCapable;
has     Str                                         $.SharedProcessorPoolCapable;
has     Str                                         $.SRIOVCapable;
has     Str                                         $.SRIOVRoCECapable;
has     Str                                         $.SwitchNetworkInterfaceMessagePassingCapable;
has     Str                                         $.SystemPartitionProcessorLimitCapable;
has     Str                                         $.Telnet5250ApplicationCapable;
has     Str                                         $.TurboCoreCapable;
has     Str                                         $.VirtualEthernetAdapterDynamicLogicalPartitionCapable;
has     Str                                         $.VirtualEthernetQualityOfServiceCapable;
has     Str                                         $.VirtualFiberChannelCapable;
has     Str                                         $.VirtualIOServerCapable;
has     Str                                         $.VirtualizationEngineTechnologiesActivationCapable;
has     Str                                         $.VirtualServerNetworkingPhase2Capable;
has     Str                                         $.VirtualSwitchCapable;
has     Str                                         $.VirtualTrustedPlatformModuleCapable;
has     Str                                         $.VLANStatisticsCapable;
has     Str                                         $.VirtualEthernetCustomMACAddressCapable;
has     Str                                         $.ManagementVLANForControlChannelCapable;
has     Str                                         $.VirtualNICDedicatedSRIOVCapable;
has     Str                                         $.VirtualNICSharedSRIOVCapable;
has     Str                                         $.DynamicPlatformOptimizationCapable;
has     Str                                         $.VirtualNICFailOverCapable;
has     Str                                         $.AdvancedBootListSupportCapable;
has     Str                                         $.DynamicSimplifiedRemoteRestartToggleCapable;
has     Str                                         $.IBMiNativeIOCapable;
has     Str                                         $.CustomPhysicalPageTableRatioCapable;
has     Str                                         $.HardwareAcceleratorCapable;
has     Str                                         $.PlatformMemoryMirroringCapableIfLicensed;
has     Str                                         $.PlatformMemoryMirroringLicensed;
has     Str                                         $.PlatformMemoryMirroringCapabilityKnown;
has     Str                                         $.PartitionSecureBootCapable;
has     Str                                         $.DedicatedProcessorPartitionCapable;

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
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    self.load               if self.config.optimization-init-load;
    self;
}

method load () {
    return                                                  if $!loaded;
    self.config.diag.post:                                  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!ActiveLogicalPartitionMobilityCapable                 = self.etl-text(:TAG<ActiveLogicalPartitionMobilityCapable>,                    :$!xml);
    $!ActiveLogicalPartitionSharedIdeProcessorsCapable      = self.etl-text(:TAG<ActiveLogicalPartitionSharedIdeProcessorsCapable>,         :$!xml);
    $!ActiveMemoryDeduplicationCapable                      = self.etl-text(:TAG<ActiveMemoryDeduplicationCapable>,                         :$!xml);
    $!ActiveMemoryExpansionCapable                          = self.etl-text(:TAG<ActiveMemoryExpansionCapable>,                             :$!xml);
    $!ActiveMemoryMirroringCapable                          = self.etl-text(:TAG<ActiveMemoryMirroringCapable>,                             :$!xml);
    $!ActiveMemorySharingCapable                            = self.etl-text(:TAG<ActiveMemorySharingCapable>,                               :$!xml);
    $!AddressBroadcastPolicyCapable                         = self.etl-text(:TAG<AddressBroadcastPolicyCapable>,                            :$!xml);
    $!AIXCapable                                            = self.etl-text(:TAG<AIXCapable>,                                               :$!xml);
    $!AutorecoveryPowerOnCapable                            = self.etl-text(:TAG<AutorecoveryPowerOnCapable>,                               :$!xml);
    $!BarrierSynchronizationRegisterCapable                 = self.etl-text(:TAG<BarrierSynchronizationRegisterCapable>,                    :$!xml);
    $!CapacityOnDemandMemoryCapable                         = self.etl-text(:TAG<CapacityOnDemandMemoryCapable>,                            :$!xml);
    $!CapacityOnDemandProcessorCapable                      = self.etl-text(:TAG<CapacityOnDemandProcessorCapable>,                         :$!xml);
    $!CAPICapable                                           = self.etl-text(:TAG<CAPICapable>,                                              :$!xml);
    $!CustomLogicalPartitionPlacementCapable                = self.etl-text(:TAG<CustomLogicalPartitionPlacementCapable>,                   :$!xml);
    $!ElectronicErrorReportingCapable                       = self.etl-text(:TAG<ElectronicErrorReportingCapable>,                          :$!xml);
    $!ExternalIntrusionDetectionCapable                     = self.etl-text(:TAG<ExternalIntrusionDetectionCapable>,                        :$!xml);
    $!FirmwarePowerSaverCapable                             = self.etl-text(:TAG<FirmwarePowerSaverCapable>,                                :$!xml);
    $!HardwareDiscoveryCapable                              = self.etl-text(:TAG<HardwareDiscoveryCapable>,                                 :$!xml);
    $!HardwareMemoryCompressionCapable                      = self.etl-text(:TAG<HardwareMemoryCompressionCapable>,                         :$!xml);
    $!HardwareMemoryEncryptionCapable                       = self.etl-text(:TAG<HardwareMemoryEncryptionCapable>,                          :$!xml);
    $!HardwarePowerSaverCapable                             = self.etl-text(:TAG<HardwarePowerSaverCapable>,                                :$!xml);
    $!HostChannelAdapterCapable                             = self.etl-text(:TAG<HostChannelAdapterCapable>,                                :$!xml);
    $!HugePageMemoryCapable                                 = self.etl-text(:TAG<HugePageMemoryCapable>,                                    :$!xml);
    $!HugePageMemoryOverrideCapable                         = self.etl-text(:TAG<HugePageMemoryOverrideCapable>,                            :$!xml);
    $!IBMiCapable                                           = self.etl-text(:TAG<IBMiCapable>,                                              :$!xml);
    $!IBMiLogicalPartitionMobilityCapable                   = self.etl-text(:TAG<IBMiLogicalPartitionMobilityCapable>,                      :$!xml);
    $!IBMiLogicalPartitionSuspendCapable                    = self.etl-text(:TAG<IBMiLogicalPartitionSuspendCapable>,                       :$!xml);
    $!IBMiNetworkInstallCapable                             = self.etl-text(:TAG<IBMiNetworkInstallCapable>,                                :$!xml);
    $!IBMiRestrictedIOModeCapable                           = self.etl-text(:TAG<IBMiRestrictedIOModeCapable>,                              :$!xml);
    $!IBMiNetworkInstallVlanCapable                         = self.etl-text(:TAG<IBMiNetworkInstallVlanCapable>,                            :$!xml);
    $!InactiveLogicalPartitionMobilityCapable               = self.etl-text(:TAG<InactiveLogicalPartitionMobilityCapable>,                  :$!xml);
    $!IntelligentPlatformManagementInterfaceCapable         = self.etl-text(:TAG<IntelligentPlatformManagementInterfaceCapable>,            :$!xml);
    $!LinuxCapable                                          = self.etl-text(:TAG<LinuxCapable>,                                             :$!xml);
    $!LogicalHostEthernetAdapterCapable                     = self.etl-text(:TAG<LogicalHostEthernetAdapterCapable>,                        :$!xml);
    $!LogicalPartitionAffinityGroupCapable                  = self.etl-text(:TAG<LogicalPartitionAffinityGroupCapable>,                     :$!xml);
    $!LogicalPartitionAvailabilityPriorityCapable           = self.etl-text(:TAG<LogicalPartitionAvailabilityPriorityCapable>,              :$!xml);
    $!LogicalPartitionEnergyManagementCapable               = self.etl-text(:TAG<LogicalPartitionEnergyManagementCapable>,                  :$!xml);
    $!LogicalPartitionProcessorCompatibilityModeCapable     = self.etl-text(:TAG<LogicalPartitionProcessorCompatibilityModeCapable>,        :$!xml);
    $!LogicalPartitionRemoteRestartCapable                  = self.etl-text(:TAG<LogicalPartitionRemoteRestartCapable>,                     :$!xml);
    $!LogicalPartitionSuspendCapable                        = self.etl-text(:TAG<LogicalPartitionSuspendCapable>,                           :$!xml);
    $!MemoryMirroringCapable                                = self.etl-text(:TAG<MemoryMirroringCapable>,                                   :$!xml);
    $!MicroLogicalPartitionCapable                          = self.etl-text(:TAG<MicroLogicalPartitionCapable>,                             :$!xml);
    $!PowerVMLogicalPartitionSimplifiedRemoteRestartCapable = self.etl-text(:TAG<PowerVMLogicalPartitionSimplifiedRemoteRestartCapable>,    :$!xml);
    $!RedundantErrorPathReportingCapable                    = self.etl-text(:TAG<RedundantErrorPathReportingCapable>,                       :$!xml);
    $!RemoteRestartToggleCapable                            = self.etl-text(:TAG<RemoteRestartToggleCapable>,                               :$!xml);
    $!ServiceProcessorConcurrentMaintenanceCapable          = self.etl-text(:TAG<ServiceProcessorConcurrentMaintenanceCapable>,             :$!xml);
    $!ServiceProcessorFailoverCapable                       = self.etl-text(:TAG<ServiceProcessorFailoverCapable>,                          :$!xml);
    $!ServiceProcessorAutonomicIPLCapable                   = self.etl-text(:TAG<ServiceProcessorAutonomicIPLCapable>,                      :$!xml);
    $!SharedEthernetFailoverCapable                         = self.etl-text(:TAG<SharedEthernetFailoverCapable>,                            :$!xml);
    $!SharedProcessorPoolCapable                            = self.etl-text(:TAG<SharedProcessorPoolCapable>,                               :$!xml);
    $!SRIOVCapable                                          = self.etl-text(:TAG<SRIOVCapable>,                                             :$!xml);
    $!SRIOVRoCECapable                                      = self.etl-text(:TAG<SRIOVRoCECapable>,                                         :$!xml);
    $!SwitchNetworkInterfaceMessagePassingCapable           = self.etl-text(:TAG<SwitchNetworkInterfaceMessagePassingCapable>,              :$!xml);
    $!SystemPartitionProcessorLimitCapable                  = self.etl-text(:TAG<SystemPartitionProcessorLimitCapable>,                     :$!xml);
    $!Telnet5250ApplicationCapable                          = self.etl-text(:TAG<Telnet5250ApplicationCapable>,                             :$!xml);
    $!TurboCoreCapable                                      = self.etl-text(:TAG<TurboCoreCapable>,                                         :$!xml);
    $!VirtualEthernetAdapterDynamicLogicalPartitionCapable  = self.etl-text(:TAG<VirtualEthernetAdapterDynamicLogicalPartitionCapable>,     :$!xml);
    $!VirtualEthernetQualityOfServiceCapable                = self.etl-text(:TAG<VirtualEthernetQualityOfServiceCapable>,                   :$!xml);
    $!VirtualFiberChannelCapable                            = self.etl-text(:TAG<VirtualFiberChannelCapable>,                               :$!xml);
    $!VirtualIOServerCapable                                = self.etl-text(:TAG<VirtualIOServerCapable>,                                   :$!xml);
    $!VirtualizationEngineTechnologiesActivationCapable     = self.etl-text(:TAG<VirtualizationEngineTechnologiesActivationCapable>,        :$!xml);
    $!VirtualServerNetworkingPhase2Capable                  = self.etl-text(:TAG<VirtualServerNetworkingPhase2Capable>,                     :$!xml);
    $!VirtualSwitchCapable                                  = self.etl-text(:TAG<VirtualSwitchCapable>,                                     :$!xml);
    $!VirtualTrustedPlatformModuleCapable                   = self.etl-text(:TAG<VirtualTrustedPlatformModuleCapable>,                      :$!xml);
    $!VLANStatisticsCapable                                 = self.etl-text(:TAG<VLANStatisticsCapable>,                                    :$!xml);
    $!VirtualEthernetCustomMACAddressCapable                = self.etl-text(:TAG<VirtualEthernetCustomMACAddressCapable>,                   :$!xml);
    $!ManagementVLANForControlChannelCapable                = self.etl-text(:TAG<ManagementVLANForControlChannelCapable>,                   :$!xml);
    $!VirtualNICDedicatedSRIOVCapable                       = self.etl-text(:TAG<VirtualNICDedicatedSRIOVCapable>,                          :$!xml);
    $!VirtualNICSharedSRIOVCapable                          = self.etl-text(:TAG<VirtualNICSharedSRIOVCapable>,                             :$!xml);
    $!DynamicPlatformOptimizationCapable                    = self.etl-text(:TAG<DynamicPlatformOptimizationCapable>,                       :$!xml);
    $!VirtualNICFailOverCapable                             = self.etl-text(:TAG<VirtualNICFailOverCapable>,                                :$!xml);
    $!AdvancedBootListSupportCapable                        = self.etl-text(:TAG<AdvancedBootListSupportCapable>,                           :$!xml);
    $!DynamicSimplifiedRemoteRestartToggleCapable           = self.etl-text(:TAG<DynamicSimplifiedRemoteRestartToggleCapable>,              :$!xml);
    $!IBMiNativeIOCapable                                   = self.etl-text(:TAG<IBMiNativeIOCapable>,                                      :$!xml);
    $!CustomPhysicalPageTableRatioCapable                   = self.etl-text(:TAG<CustomPhysicalPageTableRatioCapable>,                      :$!xml);
    $!HardwareAcceleratorCapable                            = self.etl-text(:TAG<HardwareAcceleratorCapable>,                               :$!xml);
    $!PlatformMemoryMirroringCapableIfLicensed              = self.etl-text(:TAG<PlatformMemoryMirroringCapableIfLicensed>,                 :$!xml);
    $!PlatformMemoryMirroringLicensed                       = self.etl-text(:TAG<PlatformMemoryMirroringLicensed>,                          :$!xml);
    $!PlatformMemoryMirroringCapabilityKnown                = self.etl-text(:TAG<PlatformMemoryMirroringCapabilityKnown>,                   :$!xml);
    $!PartitionSecureBootCapable                            = self.etl-text(:TAG<PartitionSecureBootCapable>,                               :$!xml);
    $!DedicatedProcessorPartitionCapable                    = self.etl-text(:TAG<DedicatedProcessorPartitionCapable>,                       :$!xml);
    $!xml                                                   = Nil;
    $!loaded                                                = True;
    self;
}

=finish
