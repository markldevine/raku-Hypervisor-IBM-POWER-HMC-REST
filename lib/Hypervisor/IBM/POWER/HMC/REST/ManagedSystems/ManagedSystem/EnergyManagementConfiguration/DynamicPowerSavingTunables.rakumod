need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::DynamicPowerSavingTunables:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.UtilizationThresholdForIncreasingFrequency;
has     Str                                         $.UtilizationThresholdForDecreasingFrequency;
has     Str                                         $.SamplesForComputingUtilzationStatistics;
has     Str                                         $.StepSizeForGoingUpInFrequency;
has     Str                                         $.StepSizeForGoingDownInFrequency;
has     Str                                         $.DeltaPercentageForDeterminingActiveCores;
has     Str                                         $.UtilizationThresholdToDetermineActiveCoresWithSlack;
has     Str                                         $.CoreFrequencyDeltaState;
has     Str                                         $.CoreMaximumDeltaFrequency;
has     Str                                         $.MinimumUtilizationThresholdForIncreasingFrequency;
has     Str                                         $.MinimumUtilizationThresholdForDecreasingFrequency;
has     Str                                         $.MinimumSamplesForComputingUtilzationStatistics;
has     Str                                         $.MinimumStepSizeForGoingUpInFrequency;
has     Str                                         $.MinimumStepSizeForGoingDownInFrequency;
has     Str                                         $.MinimumDeltaPercentageForDeterminingActiveCores;
has     Str                                         $.MinimumUtilizationThresholdToDetermineActiveCoresWithSlack;
has     Str                                         $.MinimumCoreMaximumDeltaFrequency;
has     Str                                         $.MaximumUtilizationThresholdForIncreasingFrequency;
has     Str                                         $.MaximumUtilizationThresholdForDecreasingFrequency;
has     Str                                         $.MaximumSamplesForComputingUtilzationStatistics;
has     Str                                         $.MaximumStepSizeForGoingUpInFrequency;
has     Str                                         $.MaximumStepSizeForGoingDownInFrequency;
has     Str                                         $.MaximumDeltaPercentageForDeterminingActiveCores;
has     Str                                         $.MaximumUtilizationThresholdToDetermineActiveCoresWithSlack;
has     Str                                         $.MaximumCoreMaximumDeltaFrequency;

method xml-name-exceptions () { return set <Metadata>; }

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
    $!UtilizationThresholdForIncreasingFrequency                    = self.etl-text(:TAG<UtilizationThresholdForIncreasingFrequency>,                   :$!xml);
    $!UtilizationThresholdForDecreasingFrequency                    = self.etl-text(:TAG<UtilizationThresholdForDecreasingFrequency>,                   :$!xml);
    $!SamplesForComputingUtilzationStatistics                       = self.etl-text(:TAG<SamplesForComputingUtilzationStatistics>,                      :$!xml);
    $!StepSizeForGoingUpInFrequency                                 = self.etl-text(:TAG<StepSizeForGoingUpInFrequency>,                                :$!xml);
    $!StepSizeForGoingDownInFrequency                               = self.etl-text(:TAG<StepSizeForGoingDownInFrequency>,                              :$!xml);
    $!DeltaPercentageForDeterminingActiveCores                      = self.etl-text(:TAG<DeltaPercentageForDeterminingActiveCores>,                     :$!xml);
    $!UtilizationThresholdToDetermineActiveCoresWithSlack           = self.etl-text(:TAG<UtilizationThresholdToDetermineActiveCoresWithSlack>,          :$!xml);
    $!CoreFrequencyDeltaState                                       = self.etl-text(:TAG<CoreFrequencyDeltaState>,                                      :$!xml);
    $!CoreMaximumDeltaFrequency                                     = self.etl-text(:TAG<CoreMaximumDeltaFrequency>,                                    :$!xml);
    $!MinimumUtilizationThresholdForIncreasingFrequency             = self.etl-text(:TAG<MinimumUtilizationThresholdForIncreasingFrequency>,            :$!xml);
    $!MinimumUtilizationThresholdForDecreasingFrequency             = self.etl-text(:TAG<MinimumUtilizationThresholdForDecreasingFrequency>,            :$!xml);
    $!MinimumSamplesForComputingUtilzationStatistics                = self.etl-text(:TAG<MinimumSamplesForComputingUtilzationStatistics>,               :$!xml);
    $!MinimumStepSizeForGoingUpInFrequency                          = self.etl-text(:TAG<MinimumStepSizeForGoingUpInFrequency>,                         :$!xml);
    $!MinimumStepSizeForGoingDownInFrequency                        = self.etl-text(:TAG<MinimumStepSizeForGoingDownInFrequency>,                       :$!xml);
    $!MinimumDeltaPercentageForDeterminingActiveCores               = self.etl-text(:TAG<MinimumDeltaPercentageForDeterminingActiveCores>,              :$!xml);
    $!MinimumUtilizationThresholdToDetermineActiveCoresWithSlack    = self.etl-text(:TAG<MinimumUtilizationThresholdToDetermineActiveCoresWithSlack>,   :$!xml);
    $!MinimumCoreMaximumDeltaFrequency                              = self.etl-text(:TAG<MinimumCoreMaximumDeltaFrequency>,                             :$!xml);
    $!MaximumUtilizationThresholdForIncreasingFrequency             = self.etl-text(:TAG<MaximumUtilizationThresholdForIncreasingFrequency>,            :$!xml);
    $!MaximumUtilizationThresholdForDecreasingFrequency             = self.etl-text(:TAG<MaximumUtilizationThresholdForDecreasingFrequency>,            :$!xml);
    $!MaximumSamplesForComputingUtilzationStatistics                = self.etl-text(:TAG<MaximumSamplesForComputingUtilzationStatistics>,               :$!xml);
    $!MaximumStepSizeForGoingUpInFrequency                          = self.etl-text(:TAG<MaximumStepSizeForGoingUpInFrequency>,                         :$!xml);
    $!MaximumStepSizeForGoingDownInFrequency                        = self.etl-text(:TAG<MaximumStepSizeForGoingDownInFrequency>,                       :$!xml);
    $!MaximumDeltaPercentageForDeterminingActiveCores               = self.etl-text(:TAG<MaximumDeltaPercentageForDeterminingActiveCores>,              :$!xml);
    $!MaximumUtilizationThresholdToDetermineActiveCoresWithSlack    = self.etl-text(:TAG<MaximumUtilizationThresholdToDetermineActiveCoresWithSlack>,   :$!xml);
    $!MaximumCoreMaximumDeltaFrequency                              = self.etl-text(:TAG<MaximumCoreMaximumDeltaFrequency>,                             :$!xml);
    $!xml                                                           = Nil;
    $!loaded                                                        = True;
    self;
}

=finish
