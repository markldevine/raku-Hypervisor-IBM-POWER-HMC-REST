need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::DedicatedProcessorConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::SharedProcessorConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::CurrentDedicatedProcessorConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::CurrentSharedProcessorConfiguration;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                                                            $names-checked = False;
my      Bool                                                                                                                                                                            $analyzed = False;
my      Lock                                                                                                                                                                            $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                                                                       $.config is required;
has     Bool                                                                                                                                                                            $.initialized = False;
has     Bool                                                                                                                                                                            $.loaded = False;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::DedicatedProcessorConfiguration         $.DedicatedProcessorConfiguration;
has     Str                                                                                                                                                                             $.HasDedicatedProcessors;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::SharedProcessorConfiguration            $.SharedProcessorConfiguration;
has     Str                                                                                                                                                                             $.SharingMode;
has     Str                                                                                                                                                                             $.CurrentHasDedicatedProcessors;
has     Str                                                                                                                                                                             $.CurrentSharingMode;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::CurrentDedicatedProcessorConfiguration  $.CurrentDedicatedProcessorConfiguration;
has     Str                                                                                                                                                                             $.RuntimeHasDedicatedProcessors;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::CurrentSharedProcessorConfiguration     $.CurrentSharedProcessorConfiguration;

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
    return self                                 if $!initialized;
    self.config.diag.post:                      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!DedicatedProcessorConfiguration           = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::DedicatedProcessorConfiguration.new(:$!config, :xml(self.etl-branch(:TAG<DedicatedProcessorConfiguration>, :$!xml, :optional)));
    $!CurrentDedicatedProcessorConfiguration    = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::CurrentDedicatedProcessorConfiguration.new(:$!config, :xml(self.etl-branch(:TAG<CurrentDedicatedProcessorConfiguration>, :$!xml, :optional)));
    $!CurrentSharedProcessorConfiguration       = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::CurrentSharedProcessorConfiguration.new(:$!config, :xml(self.etl-branch(:TAG<CurrentSharedProcessorConfiguration>, :$!xml, :optional)));
    $!SharedProcessorConfiguration              = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition::PartitionProcessorConfiguration::SharedProcessorConfiguration.new(:$!config, :xml(self.etl-branch(:TAG<SharedProcessorConfiguration>, :$!xml, :optional)));
    self.load                                   if self.config.optimization-init-load;
    $!initialized                               = True;
    self;
}

method load () {
    return self                                     if $!loaded;
    self.config.diag.post:                          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!DedicatedProcessorConfiguration.load          if $!DedicatedProcessorConfiguration.DEFINITE;
    $!CurrentDedicatedProcessorConfiguration.load   if $!CurrentDedicatedProcessorConfiguration.DEFINITE;
    $!CurrentSharedProcessorConfiguration.load      if $!CurrentSharedProcessorConfiguration.DEFINITE;
    $!SharedProcessorConfiguration.load             if $!SharedProcessorConfiguration.DEFINITE;
    $!HasDedicatedProcessors                        = self.etl-text(:TAG<HasDedicatedProcessors>,           :$!xml);
    $!SharingMode                                   = self.etl-text(:TAG<SharingMode>,                      :$!xml);
    $!CurrentHasDedicatedProcessors                 = self.etl-text(:TAG<CurrentHasDedicatedProcessors>,    :$!xml);
    $!CurrentSharingMode                            = self.etl-text(:TAG<CurrentSharingMode>,               :$!xml);
    $!RuntimeHasDedicatedProcessors                 = self.etl-text(:TAG<RuntimeHasDedicatedProcessors>,    :$!xml);
    $!xml                                           = Nil;
    $!loaded                                        = True;
    self;
}

=finish
