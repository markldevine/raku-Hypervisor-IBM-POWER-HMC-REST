need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedIPLConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.CurrentManufacturingDefaulConfigurationtBootMode;
has     Str                                         $.CurrentPowerOnSide;
has     Str                                         $.CurrentSystemKeylock;
has     Str                                         $.MajorBootType;
has     Str                                         $.MinorBootType;
has     Str                                         $.PendingManufacturingDefaulConfigurationtBootMode;
has     Str                                         $.PendingPowerOnSide;
has     Str                                         $.PendingSystemKeylock;
has     Str                                         $.PowerOnLogicalPartitionStartPolicy;
has     Str                                         $.PowerOnOption;
has     Str                                         $.PowerOnSpeed;
has     Str                                         $.PowerOnSpeedOverride;
has     Str                                         $.PowerOffWhenLastLogicalPartitionIsShutdown;
has     Str                                         $.CurrentManufacturingDefaultConfigurationSource;
has     Str                                         $.PendingManufacturingDefaultConfigurationSource;
has     Str                                         $.PendingPowerOnLogicalPartitionStartPolicy;
has     Str                                         $.PowerOnSource;

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
    return self                                         if $!loaded;
    self.config.diag.post:                              self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!CurrentManufacturingDefaulConfigurationtBootMode  = self.etl-text(:TAG<CurrentManufacturingDefaulConfigurationtBootMode>, :$!xml);
    $!CurrentPowerOnSide                                = self.etl-text(:TAG<CurrentPowerOnSide>,                               :$!xml);
    $!CurrentSystemKeylock                              = self.etl-text(:TAG<CurrentSystemKeylock>,                             :$!xml);
    $!MajorBootType                                     = self.etl-text(:TAG<MajorBootType>,                                    :$!xml);
    $!MinorBootType                                     = self.etl-text(:TAG<MinorBootType>,                                    :$!xml);
    $!PendingManufacturingDefaulConfigurationtBootMode  = self.etl-text(:TAG<PendingManufacturingDefaulConfigurationtBootMode>, :$!xml);
    $!PendingPowerOnSide                                = self.etl-text(:TAG<PendingPowerOnSide>,                               :$!xml);
    $!PendingSystemKeylock                              = self.etl-text(:TAG<PendingSystemKeylock>,                             :$!xml);
    $!PowerOnLogicalPartitionStartPolicy                = self.etl-text(:TAG<PowerOnLogicalPartitionStartPolicy>,               :$!xml);
    $!PowerOnOption                                     = self.etl-text(:TAG<PowerOnOption>,                                    :$!xml);
    $!PowerOnSpeed                                      = self.etl-text(:TAG<PowerOnSpeed>,                                     :$!xml);
    $!PowerOnSpeedOverride                              = self.etl-text(:TAG<PowerOnSpeedOverride>,                             :$!xml);
    $!PowerOffWhenLastLogicalPartitionIsShutdown        = self.etl-text(:TAG<PowerOffWhenLastLogicalPartitionIsShutdown>,       :$!xml);
    $!CurrentManufacturingDefaultConfigurationSource    = self.etl-text(:TAG<CurrentManufacturingDefaultConfigurationSource>,   :$!xml);
    $!PendingManufacturingDefaultConfigurationSource    = self.etl-text(:TAG<PendingManufacturingDefaultConfigurationSource>,   :$!xml);
    $!PendingPowerOnLogicalPartitionStartPolicy         = self.etl-text(:TAG<PendingPowerOnLogicalPartitionStartPolicy>,        :$!xml);
    $!PowerOnSource                                     = self.etl-text(:TAG<PowerOnSource>,                                    :$!xml);
    $!xml                                               = Nil;
    $!loaded                                            = True;
    self;
}

=finish
