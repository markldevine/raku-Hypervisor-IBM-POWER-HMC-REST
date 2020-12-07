need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::FreeIOAdaptersForLinkAggregation::IOAdapterChoice::IOAdapter:api<1>:auth<Mark Devine (mark@markdevine.com)>
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

has     Str                                         $.AdapterID;
has     Str                                         $.Description;
has     Str                                         $.DeviceName;
has     Str                                         $.DeviceType;
has     Str                                         $.DynamicReconfigurationConnectorName;
has     Str                                         $.PhysicalLocation;
has     Str                                         $.UniqueDeviceID;

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
    $!AdapterID                             = self.etl-text(:TAG<AdapterID>,                            :$!xml);
    $!Description                           = self.etl-text(:TAG<Description>,                          :$!xml);
    $!DeviceName                            = self.etl-text(:TAG<DeviceName>,                           :$!xml);
    $!DeviceType                            = self.etl-text(:TAG<DeviceType>,                           :$!xml);
    $!DynamicReconfigurationConnectorName   = self.etl-text(:TAG<DynamicReconfigurationConnectorName>,  :$!xml);
    $!PhysicalLocation                      = self.etl-text(:TAG<PhysicalLocation>,                     :$!xml);
    $!UniqueDeviceID                        = self.etl-text(:TAG<UniqueDeviceID>,                       :$!xml);
    $!xml                                   = Nil;
    $!loaded                                = True;
    self;
}

=finish
