need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
use     URI;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemProcessorConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.ConfigurableSystemProcessorUnits;
has     Str                                         $.CurrentAvailableSystemProcessorUnits;
has     Str                                         $.CurrentMaximumProcessorsPerAIXOrLinuxPartition;
has     Str                                         $.CurrentMaximumProcessorsPerIBMiPartition;
has     Str                                         $.CurrentMaximumAllowedProcessorsPerPartition;
has     Str                                         $.CurrentMaximumProcessorsPerVirtualIOServerPartition;
has     Str                                         $.CurrentMaximumVirtualProcessorsPerAIXOrLinuxPartition;
has     Str                                         $.CurrentMaximumVirtualProcessorsPerIBMiPartition;
has     Str                                         $.CurrentMaximumVirtualProcessorsPerVirtualIOServerPartition;
has     Str                                         $.DeconfiguredSystemProcessorUnits;
has     Str                                         $.InstalledSystemProcessorUnits;
has     Str                                         $.MaximumProcessorUnitsPerIBMiPartition;
has     Str                                         $.MaximumAllowedVirtualProcessorsPerPartition;
has     Str                                         $.MinimumProcessorUnitsPerVirtualProcessor;
has     Str                                         $.NumberOfAllOSProcessorUnits;
has     Str                                         $.NumberOfLinuxOnlyProcessorUnits;
has     Str                                         $.NumberOfLinuxOrVIOSOnlyProcessorUnits;
has     Str                                         $.NumberOfVirtualIOServerProcessorUnits;
has     Str                                         $.PendingAvailableSystemProcessorUnits;
has     Str                                         $.SharedProcessorPoolCount;
has     Str                                         @.SupportedPartitionProcessorCompatibilityModes;
has     Str                                         $.TemporaryProcessorUnitsForLogicalPartitionMobilityInUse;
has     URI                                         @.SharedProcessorPool;

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
    $!ConfigurableSystemProcessorUnits                              = self.etl-text(:TAG<ConfigurableSystemProcessorUnits>,                             :$!xml);
    $!CurrentAvailableSystemProcessorUnits                          = self.etl-text(:TAG<CurrentAvailableSystemProcessorUnits>,                         :$!xml);
    $!CurrentMaximumProcessorsPerAIXOrLinuxPartition                = self.etl-text(:TAG<CurrentMaximumProcessorsPerAIXOrLinuxPartition>,               :$!xml);
    $!CurrentMaximumProcessorsPerIBMiPartition                      = self.etl-text(:TAG<CurrentMaximumProcessorsPerIBMiPartition>,                     :$!xml);
    $!CurrentMaximumAllowedProcessorsPerPartition                   = self.etl-text(:TAG<CurrentMaximumAllowedProcessorsPerPartition>,                  :$!xml);
    $!CurrentMaximumProcessorsPerVirtualIOServerPartition           = self.etl-text(:TAG<CurrentMaximumProcessorsPerVirtualIOServerPartition>,          :$!xml);
    $!CurrentMaximumVirtualProcessorsPerAIXOrLinuxPartition         = self.etl-text(:TAG<CurrentMaximumVirtualProcessorsPerAIXOrLinuxPartition>,        :$!xml);
    $!CurrentMaximumVirtualProcessorsPerIBMiPartition               = self.etl-text(:TAG<CurrentMaximumVirtualProcessorsPerIBMiPartition>,              :$!xml);
    $!CurrentMaximumVirtualProcessorsPerVirtualIOServerPartition    = self.etl-text(:TAG<CurrentMaximumVirtualProcessorsPerVirtualIOServerPartition>,   :$!xml);
    $!DeconfiguredSystemProcessorUnits                              = self.etl-text(:TAG<DeconfiguredSystemProcessorUnits>,                             :$!xml);
    $!InstalledSystemProcessorUnits                                 = self.etl-text(:TAG<InstalledSystemProcessorUnits>,                                :$!xml);
    $!MaximumProcessorUnitsPerIBMiPartition                         = self.etl-text(:TAG<MaximumProcessorUnitsPerIBMiPartition>,                        :$!xml);
    $!MaximumAllowedVirtualProcessorsPerPartition                   = self.etl-text(:TAG<MaximumAllowedVirtualProcessorsPerPartition>,                  :$!xml);
    $!MinimumProcessorUnitsPerVirtualProcessor                      = self.etl-text(:TAG<MinimumProcessorUnitsPerVirtualProcessor>,                     :$!xml);
    $!NumberOfAllOSProcessorUnits                                   = self.etl-text(:TAG<NumberOfAllOSProcessorUnits>,                                  :$!xml);
    $!NumberOfLinuxOnlyProcessorUnits                               = self.etl-text(:TAG<NumberOfLinuxOnlyProcessorUnits>,                              :$!xml);
    $!NumberOfLinuxOrVIOSOnlyProcessorUnits                         = self.etl-text(:TAG<NumberOfLinuxOrVIOSOnlyProcessorUnits>,                        :$!xml);
    $!NumberOfVirtualIOServerProcessorUnits                         = self.etl-text(:TAG<NumberOfVirtualIOServerProcessorUnits>,                        :$!xml);
    $!PendingAvailableSystemProcessorUnits                          = self.etl-text(:TAG<PendingAvailableSystemProcessorUnits>,                         :$!xml);
    $!SharedProcessorPoolCount                                      = self.etl-text(:TAG<SharedProcessorPoolCount>,                                     :$!xml);
    @!SupportedPartitionProcessorCompatibilityModes                 = self.etl-texts(:TAG<SupportedPartitionProcessorCompatibilityModes>,               :$!xml);
    $!TemporaryProcessorUnitsForLogicalPartitionMobilityInUse       = self.etl-text(:TAG<TemporaryProcessorUnitsForLogicalPartitionMobilityInUse>,      :$!xml);
    @!SharedProcessorPool                                           = self.etl-links-URIs(:xml(self.etl-branch(:TAG<SharedProcessorPool>,               :$!xml)));
    $!xml                                                           = Nil;
    $!loaded                                                        = True;
    self;
}

=finish
