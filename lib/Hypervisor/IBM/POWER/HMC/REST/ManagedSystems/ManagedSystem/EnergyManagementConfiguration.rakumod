need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::DynamicPowerSavingTunables;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::IdlePowerSavingTunables;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                        $names-checked = False;
my      Bool                                                                                                                        $analyzed = False;
my      Lock                                                                                                                        $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                   $.config is required;
has     Bool                                                                                                                        $.initialized = False;
has     Bool                                                                                                                        $.loaded = False;
has     Str                                                                                                                         $.CurrentPowerSavingMode;
has     Str                                                                                                                         $.RequiredPowerSavingMode;
has     Str                                                                                                                         @.SupportedPowerSavingModeTypes;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::DynamicPowerSavingTunables $.DynamicPowerSavingTunables;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::IdlePowerSavingTunables    $.IdlePowerSavingTunables;
has     Str                                                                                                                         $.IdlePowerSaverMode;

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
    return self                     if $!initialized;
    self.config.diag.post:          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!DynamicPowerSavingTunables    = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::DynamicPowerSavingTunables.new(:$!config, :xml(self.etl-branch(:TAG<DynamicPowerSavingTunables>, :$!xml)));
    $!IdlePowerSavingTunables       = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::EnergyManagementConfiguration::IdlePowerSavingTunables.new(:$!config, :xml(self.etl-branch(:TAG<IdlePowerSavingTunables>, :$!xml)));
    self.load                       if self.config.optimization-init-load;
    $!initialized                   = True;
    self;
}

method load () {
    return self                     if $!loaded;
    self.config.diag.post:          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!DynamicPowerSavingTunables.load;
    $!IdlePowerSavingTunables.load;
    $!CurrentPowerSavingMode        = self.etl-text(:TAG<CurrentPowerSavingMode>,           :$!xml);
    $!RequiredPowerSavingMode       = self.etl-text(:TAG<RequiredPowerSavingMode>,          :$!xml);
    @!SupportedPowerSavingModeTypes = self.etl-texts(:TAG<SupportedPowerSavingModeTypes>,   :$!xml);
    $!IdlePowerSaverMode            = self.etl-text(:TAG<IdlePowerSaverMode>,               :$!xml, :optional);
    $!xml                           = Nil;
    $!loaded                        = True;
    self;
}

=finish
