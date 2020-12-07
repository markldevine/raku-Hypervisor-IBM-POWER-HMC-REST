need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PartitionMemoryConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.ActiveMemoryExpansionEnabled;
has     Str                                         $.ActiveMemorySharingEnabled;
has     Str                                         $.DesiredMemory;
has     Str                                         $.ExpansionFactor;
has     Str                                         $.HardwarePageTableRatio;
has     Str                                         $.MaximumMemory;
has     Str                                         $.MinimumMemory;
has     Str                                         $.CurrentExpansionFactor;
has     Str                                         $.CurrentHardwarePageTableRatio;
has     Str                                         $.CurrentHugePageCount;
has     Str                                         $.CurrentMaximumHugePageCount;
has     Str                                         $.CurrentMaximumMemory;
has     Str                                         $.CurrentMemory;
has     Str                                         $.CurrentMinimumHugePageCount;
has     Str                                         $.CurrentMinimumMemory;
has     Str                                         $.MemoryExpansionHardwareAccessEnabled;
has     Str                                         $.MemoryEncryptionHardwareAccessEnabled;
has     Str                                         $.MemoryExpansionEnabled;
has     Str                                         $.RedundantErrorPathReportingEnabled;
has     Str                                         $.RuntimeHugePageCount;
has     Str                                         $.RuntimeMemory;
has     Str                                         $.RuntimeMinimumMemory;
has     Str                                         $.SharedMemoryEnabled;
has     Str                                         $.PhysicalPageTableRatio;

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
    $!ActiveMemoryExpansionEnabled          = self.etl-text(:TAG<ActiveMemoryExpansionEnabled>,             :$!xml);
    $!ActiveMemorySharingEnabled            = self.etl-text(:TAG<ActiveMemorySharingEnabled>,               :$!xml);
    $!DesiredMemory                         = self.etl-text(:TAG<DesiredMemory>,                            :$!xml);
    $!ExpansionFactor                       = self.etl-text(:TAG<ExpansionFactor>,                          :$!xml);
    $!HardwarePageTableRatio                = self.etl-text(:TAG<HardwarePageTableRatio>,                   :$!xml);
    $!MaximumMemory                         = self.etl-text(:TAG<MaximumMemory>,                            :$!xml);
    $!MinimumMemory                         = self.etl-text(:TAG<MinimumMemory>,                            :$!xml);
    $!CurrentExpansionFactor                = self.etl-text(:TAG<CurrentExpansionFactor>,                   :$!xml);
    $!CurrentHardwarePageTableRatio         = self.etl-text(:TAG<CurrentHardwarePageTableRatio>,            :$!xml);
    $!CurrentHugePageCount                  = self.etl-text(:TAG<CurrentHugePageCount>,                     :$!xml);
    $!CurrentMaximumHugePageCount           = self.etl-text(:TAG<CurrentMaximumHugePageCount>,              :$!xml);
    $!CurrentMaximumMemory                  = self.etl-text(:TAG<CurrentMaximumMemory>,                     :$!xml);
    $!CurrentMemory                         = self.etl-text(:TAG<CurrentMemory>,                            :$!xml);
    $!CurrentMinimumHugePageCount           = self.etl-text(:TAG<CurrentMinimumHugePageCount>,              :$!xml);
    $!CurrentMinimumMemory                  = self.etl-text(:TAG<CurrentMinimumMemory>,                     :$!xml);
    $!MemoryExpansionHardwareAccessEnabled  = self.etl-text(:TAG<MemoryExpansionHardwareAccessEnabled>,     :$!xml);
    $!MemoryEncryptionHardwareAccessEnabled = self.etl-text(:TAG<MemoryEncryptionHardwareAccessEnabled>,    :$!xml);
    $!MemoryExpansionEnabled                = self.etl-text(:TAG<MemoryExpansionEnabled>,                   :$!xml);
    $!RedundantErrorPathReportingEnabled    = self.etl-text(:TAG<RedundantErrorPathReportingEnabled>,       :$!xml);
    $!RuntimeHugePageCount                  = self.etl-text(:TAG<RuntimeHugePageCount>,                     :$!xml);
    $!RuntimeMemory                         = self.etl-text(:TAG<RuntimeMemory>,                            :$!xml);
    $!RuntimeMinimumMemory                  = self.etl-text(:TAG<RuntimeMinimumMemory>,                     :$!xml);
    $!SharedMemoryEnabled                   = self.etl-text(:TAG<SharedMemoryEnabled>,                      :$!xml);
    $!PhysicalPageTableRatio                = self.etl-text(:TAG<PhysicalPageTableRatio>,                   :$!xml);
    $!xml                                   = Nil;
    $!loaded                                = True;
    self;
}

=finish
