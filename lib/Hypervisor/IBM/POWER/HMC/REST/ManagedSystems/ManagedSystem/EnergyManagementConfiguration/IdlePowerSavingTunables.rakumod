need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::IdlePowerSavingTunables:api<1>:auth<Mark Devine (mark@markdevine.com)>
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

has     Str                                         $.DelayTimeToEnterIdlePower;
has     Str                                         $.DelayTimeToExitIdlePower;
has     Str                                         $.UtilizationThresholdToEnterIdlePower;
has     Str                                         $.UtilizationThresholdToExitIdlePower;
has     Str                                         $.MinimumDelayTimeToEnterIdlePower;
has     Str                                         $.MinimumDelayTimeToExitIdlePower;
has     Str                                         $.MinimumUtilizationThresholdToEnterIdlePower;
has     Str                                         $.MinimumUtilizationThresholdToExitIdlePower;
has     Str                                         $.MaximumDelayTimeToEnterIdlePower;
has     Str                                         $.MaximumDelayTimeToExitIdlePower;
has     Str                                         $.MaximumUtilizationThresholdToEnterIdlePower;
has     Str                                         $.MaximumUtilizationThresholdToExitIdlePower;

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
    $!DelayTimeToEnterIdlePower                     = self.etl-text(:TAG<DelayTimeToEnterIdlePower>,                    :$!xml, :optional);
    $!DelayTimeToExitIdlePower                      = self.etl-text(:TAG<DelayTimeToExitIdlePower>,                     :$!xml, :optional);
    $!UtilizationThresholdToEnterIdlePower          = self.etl-text(:TAG<UtilizationThresholdToEnterIdlePower>,         :$!xml, :optional);
    $!UtilizationThresholdToExitIdlePower           = self.etl-text(:TAG<UtilizationThresholdToExitIdlePower>,          :$!xml, :optional);
    $!MinimumDelayTimeToEnterIdlePower              = self.etl-text(:TAG<MinimumDelayTimeToEnterIdlePower>,             :$!xml, :optional);
    $!MinimumDelayTimeToExitIdlePower               = self.etl-text(:TAG<MinimumDelayTimeToExitIdlePower>,              :$!xml, :optional);
    $!MinimumUtilizationThresholdToEnterIdlePower   = self.etl-text(:TAG<MinimumUtilizationThresholdToEnterIdlePower>,  :$!xml, :optional);
    $!MinimumUtilizationThresholdToExitIdlePower    = self.etl-text(:TAG<MinimumUtilizationThresholdToExitIdlePower>,   :$!xml, :optional);
    $!MaximumDelayTimeToEnterIdlePower              = self.etl-text(:TAG<MaximumDelayTimeToEnterIdlePower>,             :$!xml, :optional);
    $!MaximumDelayTimeToExitIdlePower               = self.etl-text(:TAG<MaximumDelayTimeToExitIdlePower>,              :$!xml, :optional);
    $!MaximumUtilizationThresholdToEnterIdlePower   = self.etl-text(:TAG<MaximumUtilizationThresholdToEnterIdlePower>,  :$!xml, :optional);
    $!MaximumUtilizationThresholdToExitIdlePower    = self.etl-text(:TAG<MaximumUtilizationThresholdToExitIdlePower>,   :$!xml, :optional);
    $!xml                                           = Nil;
    $!loaded                                        = True;
    self;
}

=finish
