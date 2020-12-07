need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemMemoryConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         @.AllowedHardwarePageTableRations;
has     Str                                         $.AllowedMemoryDeduplicationTableRatios;
has     Str                                         $.AllowedMemoryRegionSize;
has     Str                                         $.ConfigurableHugePages;
has     Str                                         $.ConfigurableSystemMemory;
has     Str                                         $.ConfiguredMirroredMemory;
has     Str                                         $.CurrentAvailableHugePages;
has     Str                                         $.CurrentAvailableMirroredMemory;
has     Str                                         $.CurrentAvailableSystemMemory;
has     Str                                         $.CurrentLogicalMemoryBlockSize;
has     Str                                         $.CurrentMemoryMirroringMode;
has     Str                                         $.CurrentMirroredMemory;
has     Str                                         $.DeconfiguredSystemMemory;
has     Str                                         $.DefaultHardwarePageTableRatio;
has     Str                                         $.DefaultHardwarePagingTableRatioForDedicatedMemoryPartition;
has     Str                                         $.DefaultMemoryDeduplicationTableRatio;
has     Str                                         $.HugePageCount;
has     Str                                         $.HugePageSize;
has     Str                                         $.InstalledSystemMemory;
has     Str                                         $.MaximumHugePages;
has     Str                                         $.MaximumMemoryPoolCount;
has     Str                                         $.MaximumMirroredMemoryDefragmented;
has     Str                                         $.MaximumPagingVirtualIOServersPerSharedMemoryPool;
has     Str                                         $.MemoryDefragmentationState;
has     Str                                         $.MemoryMirroringState;
has     Str                                         $.MemoryRegionSize;
has     Str                                         $.MemoryUsedByHypervisor;
has     Str                                         $.MirrorableMemoryWithDefragmentation;
has     Str                                         $.MirrorableMemoryWithoutDefragmentation;
has     Str                                         $.MirroredMemoryUsedByHypervisor;
has     Str                                         $.PendingAvailableHugePages;
has     Str                                         $.PendingAvailableSystemMemory;
has     Str                                         $.PendingLogicalMemoryBlockSize;
has     Str                                         $.PendingMemoryMirroringMode;
has     Str                                         $.PendingMemoryRegionSize;
has     Str                                         $.RequestedHugePages;
has     Str                                         $.TemporaryMemoryForLogicalPartitionMobilityInUse;
has     Str                                         $.DefaultPhysicalPageTableRatio;
has     Str                                         @.AllowedPhysicalPageTableRatios;

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
    return self                                                     if $!loaded;
    self.config.diag.post:                                          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    @!AllowedHardwarePageTableRations                               = self.etl-texts(:TAG<AllowedHardwarePageTableRations>,                             :$!xml);
    $!AllowedMemoryDeduplicationTableRatios                         = self.etl-text(:TAG<AllowedMemoryDeduplicationTableRatios>,                        :$!xml);
    $!AllowedMemoryRegionSize                                       = self.etl-text(:TAG<AllowedMemoryRegionSize>,                                      :$!xml);
    $!ConfigurableHugePages                                         = self.etl-text(:TAG<ConfigurableHugePages>,                                        :$!xml);
    $!ConfigurableSystemMemory                                      = self.etl-text(:TAG<ConfigurableSystemMemory>,                                     :$!xml);
    $!ConfiguredMirroredMemory                                      = self.etl-text(:TAG<ConfiguredMirroredMemory>,                                     :$!xml);
    $!CurrentAvailableHugePages                                     = self.etl-text(:TAG<CurrentAvailableHugePages>,                                    :$!xml);
    $!CurrentAvailableMirroredMemory                                = self.etl-text(:TAG<CurrentAvailableMirroredMemory>,                               :$!xml);
    $!CurrentAvailableSystemMemory                                  = self.etl-text(:TAG<CurrentAvailableSystemMemory>,                                 :$!xml);
    $!CurrentLogicalMemoryBlockSize                                 = self.etl-text(:TAG<CurrentLogicalMemoryBlockSize>,                                :$!xml);
    $!CurrentMemoryMirroringMode                                    = self.etl-text(:TAG<CurrentMemoryMirroringMode>,                                   :$!xml);
    $!CurrentMirroredMemory                                         = self.etl-text(:TAG<CurrentMirroredMemory>,                                        :$!xml);
    $!DeconfiguredSystemMemory                                      = self.etl-text(:TAG<DeconfiguredSystemMemory>,                                     :$!xml);
    $!DefaultHardwarePageTableRatio                                 = self.etl-text(:TAG<DefaultHardwarePageTableRatio>,                                :$!xml);
    $!DefaultHardwarePagingTableRatioForDedicatedMemoryPartition    = self.etl-text(:TAG<DefaultHardwarePagingTableRatioForDedicatedMemoryPartition>,   :$!xml);
    $!DefaultMemoryDeduplicationTableRatio                          = self.etl-text(:TAG<DefaultMemoryDeduplicationTableRatio>,                         :$!xml);
    $!HugePageCount                                                 = self.etl-text(:TAG<HugePageCount>,                                                :$!xml);
    $!HugePageSize                                                  = self.etl-text(:TAG<HugePageSize>,                                                 :$!xml);
    $!InstalledSystemMemory                                         = self.etl-text(:TAG<InstalledSystemMemory>,                                        :$!xml);
    $!MaximumHugePages                                              = self.etl-text(:TAG<MaximumHugePages>,                                             :$!xml);
    $!MaximumMemoryPoolCount                                        = self.etl-text(:TAG<MaximumMemoryPoolCount>,                                       :$!xml);
    $!MaximumMirroredMemoryDefragmented                             = self.etl-text(:TAG<MaximumMirroredMemoryDefragmented>,                            :$!xml);
    $!MaximumPagingVirtualIOServersPerSharedMemoryPool              = self.etl-text(:TAG<MaximumPagingVirtualIOServersPerSharedMemoryPool>,             :$!xml);
    $!MemoryDefragmentationState                                    = self.etl-text(:TAG<MemoryDefragmentationState>,                                   :$!xml);
    $!MemoryMirroringState                                          = self.etl-text(:TAG<MemoryMirroringState>,                                         :$!xml);
    $!MemoryRegionSize                                              = self.etl-text(:TAG<MemoryRegionSize>,                                             :$!xml);
    $!MemoryUsedByHypervisor                                        = self.etl-text(:TAG<MemoryUsedByHypervisor>,                                       :$!xml);
    $!MirrorableMemoryWithDefragmentation                           = self.etl-text(:TAG<MirrorableMemoryWithDefragmentation>,                          :$!xml);
    $!MirrorableMemoryWithoutDefragmentation                        = self.etl-text(:TAG<MirrorableMemoryWithoutDefragmentation>,                       :$!xml);
    $!MirroredMemoryUsedByHypervisor                                = self.etl-text(:TAG<MirroredMemoryUsedByHypervisor>,                               :$!xml);
    $!PendingAvailableHugePages                                     = self.etl-text(:TAG<PendingAvailableHugePages>,                                    :$!xml);
    $!PendingAvailableSystemMemory                                  = self.etl-text(:TAG<PendingAvailableSystemMemory>,                                 :$!xml);
    $!PendingLogicalMemoryBlockSize                                 = self.etl-text(:TAG<PendingLogicalMemoryBlockSize>,                                :$!xml);
    $!PendingMemoryMirroringMode                                    = self.etl-text(:TAG<PendingMemoryMirroringMode>,                                   :$!xml);
    $!PendingMemoryRegionSize                                       = self.etl-text(:TAG<PendingMemoryRegionSize>,                                      :$!xml);
    $!RequestedHugePages                                            = self.etl-text(:TAG<RequestedHugePages>,                                           :$!xml);
    $!TemporaryMemoryForLogicalPartitionMobilityInUse               = self.etl-text(:TAG<TemporaryMemoryForLogicalPartitionMobilityInUse>,              :$!xml);
    $!DefaultPhysicalPageTableRatio                                 = self.etl-text(:TAG<DefaultPhysicalPageTableRatio>,                                :$!xml);
    @!AllowedPhysicalPageTableRatios                                = self.etl-texts(:TAG<AllowedPhysicalPageTableRatios>,                              :$!xml);
    $!xml                                                           = Nil;
    $!loaded                                                        = True;
    self;
}

=finish
