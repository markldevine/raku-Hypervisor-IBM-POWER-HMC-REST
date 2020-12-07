need    Hypervisor::IBM::POWER::HMC::REST::Atom;
need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedIPLConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemCapabilities;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemMemoryConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemProcessorConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemSecurity;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::MachineTypeModelAndSerialNumber;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::SystemMigrationInformation;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers;
use     URI;
use     LibXML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                        $names-checked = False;
my      Bool                                                                                                        $analyzed = False;
my      Lock                                                                                                        $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Atom                                                                     $.atom;
has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                   $.config is required;
has     Bool                                                                                                        $.loaded = False;
has     Bool                                                                                                        $.initialized = False;
has     Str                                                                                                         $.id;
has     DateTime                                                                                                    $.published;
has     Str                                                                                                         $.ActivatedLevel;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedIPLConfiguration                $.AssociatedIPLConfiguration;
has     URI                                                                                                         @.AssociatedLogicalPartitions;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemCapabilities              $.AssociatedSystemCapabilities;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration           $.AssociatedSystemIOConfiguration;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemMemoryConfiguration       $.AssociatedSystemMemoryConfiguration;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemProcessorConfiguration    $.AssociatedSystemProcessorConfiguration;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemSecurity                  $.AssociatedSystemSecurity;
has     URI                                                                                                         @.AssociatedVirtualIOServers;
has     Str                                                                                                         $.DetailedState;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::MachineTypeModelAndSerialNumber           $.MachineTypeModelAndSerialNumber;
has     Str                                                                                                         $.ManufacturingDefaultConfigurationEnabled;
has     Str                                                                                                         $.MaximumPartitions;
has     Str                                                                                                         $.MaximumPowerControlPartitions;
has     Str                                                                                                         $.MaximumRemoteRestartPartitions;
has     Str                                                                                                         $.MaximumSharedProcessorCapablePartitionID;
has     Str                                                                                                         $.MaximumSuspendablePartitions;
has     Str                                                                                                         $.MaximumBackingDevicesPerVNIC;
has     Str                                                                                                         $.PhysicalSystemAttentionLEDState;
has     Str                                                                                                         $.PrimaryIPAddress;
has     Str                                                                                                         $.Hostname;
has     Str                                                                                                         $.ServiceProcessorFailoverEnabled;
has     Str                                                                                                         $.ServiceProcessorFailoverReason;
has     Str                                                                                                         $.ServiceProcessorFailoverState;
has     Str                                                                                                         $.ServiceProcessorVersion;
has     Str                                                                                                         $.State;
has     Str                                                                                                         $.SystemName;
has     DateTime                                                                                                    $.SystemTime;
has     Str                                                                                                         $.VirtualSystemAttentionLEDState;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::SystemMigrationInformation                $.SystemMigrationInformation;
has     Str                                                                                                         $.ReferenceCode;
has     Str                                                                                                         $.MergedReferenceCode;
has     Str                                                                                                         $.SystemFirmware;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration             $.EnergyManagementConfiguration;
has     Str                                                                                                         $.IsPowerVMManagementMaster;
has     Str                                                                                                         $.IsClassicHMCManagement;
has     Str                                                                                                         $.IsPowerVMManagementWithoutMaster;
has     Str                                                                                                         $.IsManagementPartitionPowerVMManagementMaster;
has     Str                                                                                                         $.IsHMCPowerVMManagementMaster;
has     Str                                                                                                         $.IsNotPowerVMManagementMaster;
has     Str                                                                                                         $.IsPowerVMManagementNormalMaster;
has     Str                                                                                                         $.IsPowerVMManagementPersistentMaster;
has     Str                                                                                                         $.IsPowerVMManagementTemporaryMaster;
has     Str                                                                                                         $.IsPowerVMManagementPartitionEnabled;
has     Str                                                                                                         $.SystemType;
has     Str                                                                                                         $.ProcessorThrottling;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions                         $.LogicalPartitions;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers                          $.VirtualIOServers;

has     LibXML::Element                                                                                             $!xml-content;
has     LibXML::Element                                                                                             $!xml-ManagedSystem;
has     LibXML::Element                                                                                             $!xml-AssociatedIPLConfiguration;
has     LibXML::Element                                                                                             $!xml-AssociatedLogicalPartitions;
has     LibXML::Element                                                                                             $!xml-AssociatedSystemCapabilities;
has     LibXML::Element                                                                                             $!xml-AssociatedSystemIOConfiguration;
has     LibXML::Element                                                                                             $!xml-AssociatedSystemMemoryConfiguration;
has     LibXML::Element                                                                                             $!xml-AssociatedSystemProcessorConfiguration;
has     LibXML::Element                                                                                             $!xml-AssociatedSystemSecurity;
has     LibXML::Element                                                                                             $!xml-AssociatedVirtualIOServers;
has     LibXML::Element                                                                                             $!xml-MachineTypeModelAndSerialNumber;
has     LibXML::Element                                                                                             $!xml-SystemMigrationInformation;
has     LibXML::Element                                                                                             $!xml-EnergyManagementConfiguration;

method  xml-name-exceptions () { return set <Metadata author content etag:etag link title>; }

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

#%%% <<<Update mechanism>>>
#method init (LibXML::Element $xml?) {
#    with $xml {
#        $!xml = $xml;
#        $!loaded = False;
#    }
method init () {
    return self                                     if $!initialized;
    self.config.diag.post:                          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $init-start                                  = now;
    $!xml-content                                   = self.etl-branch(:TAG<content>,                                :$!xml);
    $!xml-ManagedSystem                             = self.etl-branch(:TAG<ManagedSystem:ManagedSystem>,            :xml($!xml-content));

    $!id                                            = self.etl-text(:TAG<id>,                                       :$!xml);                    # used in parent class as part of instantiation
    $!SystemName                                    = self.etl-text(:TAG<SystemName>,                               :xml($!xml-ManagedSystem)); # used in parent class as part of instantiation
    $!atom                                          = self.etl-atom(:xml(self.etl-branch(:TAG<Metadata>,            :xml($!xml-ManagedSystem))));

    $!xml-AssociatedIPLConfiguration                = self.etl-branch(:TAG<AssociatedIPLConfiguration>,             :xml($!xml-ManagedSystem));
    $!xml-AssociatedLogicalPartitions               = self.etl-branch(:TAG<AssociatedLogicalPartitions>,            :xml($!xml-ManagedSystem));
    $!xml-AssociatedSystemCapabilities              = self.etl-branch(:TAG<AssociatedSystemCapabilities>,           :xml($!xml-ManagedSystem));
    $!xml-AssociatedSystemIOConfiguration           = self.etl-branch(:TAG<AssociatedSystemIOConfiguration>,        :xml($!xml-ManagedSystem));
    $!xml-AssociatedSystemMemoryConfiguration       = self.etl-branch(:TAG<AssociatedSystemMemoryConfiguration>,    :xml($!xml-ManagedSystem));
    $!xml-AssociatedSystemProcessorConfiguration    = self.etl-branch(:TAG<AssociatedSystemProcessorConfiguration>, :xml($!xml-ManagedSystem));
    $!xml-AssociatedSystemSecurity                  = self.etl-branch(:TAG<AssociatedSystemSecurity>,               :xml($!xml-ManagedSystem));
    $!xml-AssociatedVirtualIOServers                = self.etl-branch(:TAG<AssociatedVirtualIOServers>,             :xml($!xml-ManagedSystem));
    $!xml-MachineTypeModelAndSerialNumber           = self.etl-branch(:TAG<MachineTypeModelAndSerialNumber>,        :xml($!xml-ManagedSystem));
    $!xml-SystemMigrationInformation                = self.etl-branch(:TAG<SystemMigrationInformation>,             :xml($!xml-ManagedSystem));
    $!xml-EnergyManagementConfiguration             = self.etl-branch(:TAG<EnergyManagementConfiguration>,          :xml($!xml-ManagedSystem));
    $!AssociatedIPLConfiguration                    = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedIPLConfiguration.new(:$!config, :xml($!xml-AssociatedIPLConfiguration));
    $!AssociatedSystemCapabilities                  = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemCapabilities.new(:$!config, :xml($!xml-AssociatedSystemCapabilities));
    $!AssociatedSystemIOConfiguration               = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration.new(:$!config, :xml($!xml-AssociatedSystemIOConfiguration));
    $!AssociatedSystemMemoryConfiguration           = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemMemoryConfiguration.new(:$!config, :xml($!xml-AssociatedSystemMemoryConfiguration));
    $!AssociatedSystemProcessorConfiguration        = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemProcessorConfiguration.new(:$!config, :xml($!xml-AssociatedSystemProcessorConfiguration));
    $!AssociatedSystemSecurity                      = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemSecurity.new(:$!config, :xml($!xml-AssociatedSystemSecurity));
    $!MachineTypeModelAndSerialNumber               = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::MachineTypeModelAndSerialNumber.new(:$!config, :xml($!xml-MachineTypeModelAndSerialNumber));
    $!SystemMigrationInformation                    = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::SystemMigrationInformation.new(:$!config, :xml($!xml-SystemMigrationInformation));
    $!EnergyManagementConfiguration                 = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration.new(:$!config, :xml($!xml-EnergyManagementConfiguration));
    $!LogicalPartitions                             = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions.new(:$!config, :Managed-System-Id($!id));
    $!VirtualIOServers                              = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers.new(:$!config, :Managed-System-Id($!id));
    $!initialized                                   = True;
    self.load                                       if self.config.optimization-init-load;
    self.config.diag.post:                          sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'INITIALIZE', sprintf("%.3f", now - $init-start)) if %*ENV<HIPH_INIT>;
    self;
}

method load () {
    return self                                     if $!loaded;
    self.init                                       unless $!initialized;
    self.config.diag.post:                          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $load-start                                  = now;
    $!AssociatedIPLConfiguration.load;
    $!AssociatedSystemCapabilities.load;
    $!AssociatedSystemIOConfiguration.load;
    $!AssociatedSystemMemoryConfiguration.load;
    $!AssociatedSystemProcessorConfiguration.load;
    $!AssociatedSystemSecurity.load;
    $!MachineTypeModelAndSerialNumber.load;
    $!SystemMigrationInformation.load;
    $!EnergyManagementConfiguration.load;
#   $!LogicalPartitions.load;
#   $!VirtualIOServers.load;
    $!published                                     = DateTime.new(self.etl-text(:TAG<published>,                       :$!xml));
    $!ActivatedLevel                                = self.etl-text(:TAG<ActivatedLevel>,                               :xml($!xml-ManagedSystem));
    @!AssociatedLogicalPartitions                   = self.etl-links-URIs(                                              :xml($!xml-AssociatedLogicalPartitions));
    @!AssociatedVirtualIOServers                    = self.etl-links-URIs(                                              :xml($!xml-AssociatedVirtualIOServers));
    $!DetailedState                                 = self.etl-text(:TAG<DetailedState>,                                :xml($!xml-ManagedSystem));
    $!ManufacturingDefaultConfigurationEnabled      = self.etl-text(:TAG<ManufacturingDefaultConfigurationEnabled>,     :xml($!xml-ManagedSystem));
    $!MaximumPartitions                             = self.etl-text(:TAG<MaximumPartitions>,                            :xml($!xml-ManagedSystem));
    $!MaximumPowerControlPartitions                 = self.etl-text(:TAG<MaximumPowerControlPartitions>,                :xml($!xml-ManagedSystem));
    $!MaximumRemoteRestartPartitions                = self.etl-text(:TAG<MaximumRemoteRestartPartitions>,               :xml($!xml-ManagedSystem));
    $!MaximumSharedProcessorCapablePartitionID      = self.etl-text(:TAG<MaximumSharedProcessorCapablePartitionID>,     :xml($!xml-ManagedSystem));
    $!MaximumSuspendablePartitions                  = self.etl-text(:TAG<MaximumSuspendablePartitions>,                 :xml($!xml-ManagedSystem));
    $!MaximumBackingDevicesPerVNIC                  = self.etl-text(:TAG<MaximumBackingDevicesPerVNIC>,                 :xml($!xml-ManagedSystem));
    $!PhysicalSystemAttentionLEDState               = self.etl-text(:TAG<PhysicalSystemAttentionLEDState>,              :xml($!xml-ManagedSystem));
    $!PrimaryIPAddress                              = self.etl-text(:TAG<PrimaryIPAddress>,                             :xml($!xml-ManagedSystem));
    $!Hostname                                      = self.etl-text(:TAG<Hostname>,                                     :xml($!xml-ManagedSystem));
    $!ServiceProcessorFailoverEnabled               = self.etl-text(:TAG<ServiceProcessorFailoverEnabled>,              :xml($!xml-ManagedSystem));
    $!ServiceProcessorFailoverReason                = self.etl-text(:TAG<ServiceProcessorFailoverReason>,               :xml($!xml-ManagedSystem));
    $!ServiceProcessorFailoverState                 = self.etl-text(:TAG<ServiceProcessorFailoverState>,                :xml($!xml-ManagedSystem));
    $!ServiceProcessorVersion                       = self.etl-text(:TAG<ServiceProcessorVersion>,                      :xml($!xml-ManagedSystem));
    $!State                                         = self.etl-text(:TAG<State>,                                        :xml($!xml-ManagedSystem));
    $!SystemTime                                    = DateTime.new(self.etl-text(:TAG<SystemTime>,                      :xml($!xml-ManagedSystem)).subst(/^(\d**10)(\d**3)$/, {$0 ~ '.' ~ $1}).Num);
    $!VirtualSystemAttentionLEDState                = self.etl-text(:TAG<VirtualSystemAttentionLEDState>,               :xml($!xml-ManagedSystem));
    $!ReferenceCode                                 = self.etl-text(:TAG<ReferenceCode>,                                :xml($!xml-ManagedSystem));
    $!MergedReferenceCode                           = self.etl-text(:TAG<MergedReferenceCode>,                          :xml($!xml-ManagedSystem));
    $!SystemFirmware                                = self.etl-text(:TAG<SystemFirmware>,                               :xml($!xml-ManagedSystem));
    $!IsPowerVMManagementMaster                     = self.etl-text(:TAG<IsPowerVMManagementMaster>,                    :xml($!xml-ManagedSystem));
    $!IsClassicHMCManagement                        = self.etl-text(:TAG<IsClassicHMCManagement>,                       :xml($!xml-ManagedSystem));
    $!IsPowerVMManagementWithoutMaster              = self.etl-text(:TAG<IsPowerVMManagementWithoutMaster>,             :xml($!xml-ManagedSystem));
    $!IsManagementPartitionPowerVMManagementMaster  = self.etl-text(:TAG<IsManagementPartitionPowerVMManagementMaster>, :xml($!xml-ManagedSystem));
    $!IsHMCPowerVMManagementMaster                  = self.etl-text(:TAG<IsHMCPowerVMManagementMaster>,                 :xml($!xml-ManagedSystem));
    $!IsNotPowerVMManagementMaster                  = self.etl-text(:TAG<IsNotPowerVMManagementMaster>,                 :xml($!xml-ManagedSystem));
    $!IsPowerVMManagementNormalMaster               = self.etl-text(:TAG<IsPowerVMManagementNormalMaster>,              :xml($!xml-ManagedSystem));
    $!IsPowerVMManagementPersistentMaster           = self.etl-text(:TAG<IsPowerVMManagementPersistentMaster>,          :xml($!xml-ManagedSystem));
    $!IsPowerVMManagementTemporaryMaster            = self.etl-text(:TAG<IsPowerVMManagementTemporaryMaster>,           :xml($!xml-ManagedSystem));
    $!IsPowerVMManagementPartitionEnabled           = self.etl-text(:TAG<IsPowerVMManagementPartitionEnabled>,          :xml($!xml-ManagedSystem));
    $!SystemType                                    = self.etl-text(:TAG<SystemType>,                                   :xml($!xml-ManagedSystem));
    $!ProcessorThrottling                           = self.etl-text(:TAG<ProcessorThrottling>,                          :xml($!xml-ManagedSystem));
    $!xml                                           = Nil;
    $!loaded                                        = True;
    self.config.diag.post:                          sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'LOAD', sprintf("%.3f", now - $load-start)) if %*ENV<HIPH_LOAD>;
    self;
}

=finish
