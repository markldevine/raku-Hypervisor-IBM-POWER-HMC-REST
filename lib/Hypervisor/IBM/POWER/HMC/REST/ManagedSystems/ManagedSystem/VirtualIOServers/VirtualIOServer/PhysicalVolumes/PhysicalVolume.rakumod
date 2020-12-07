need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::VirtualIOServers::VirtualIOServer::PhysicalVolumes::PhysicalVolume:api<1>:auth<Mark Devine (mark@markdevine.com)>
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

has     Str                                         $.Description;
has     Str                                         $.LocationCode;
has     Str                                         $.ReservePolicy;
has     Str                                         $.ReservePolicyAlgorithm;
has     Str                                         $.UniqueDeviceID;
has     Str                                         $.AvailableForUsage;
has     Str                                         $.VolumeCapacity;
has     Str                                         $.VolumeName;
has     Str                                         $.VolumeState;
has     Str                                         $.VolumeUniqueID;
has     Str                                         $.IsFibreChannelBacked;
has     Str                                         $.IsISCSIBacked;
has     Str                                         $.StorageLabel;
has     Str                                         $.DescriptorPage83;

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
    return self                 if $!loaded;
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!Description               = self.etl-text(:TAG<Description>, :$!xml);
    $!LocationCode              = self.etl-text(:TAG<LocationCode>, :$!xml);
    $!ReservePolicy             = self.etl-text(:TAG<ReservePolicy>, :$!xml);
    $!ReservePolicyAlgorithm    = self.etl-text(:TAG<ReservePolicyAlgorithm>, :$!xml);
    $!UniqueDeviceID            = self.etl-text(:TAG<UniqueDeviceID>, :$!xml);
    $!AvailableForUsage         = self.etl-text(:TAG<AvailableForUsage>, :$!xml);
    $!VolumeCapacity            = self.etl-text(:TAG<VolumeCapacity>, :$!xml);
    $!VolumeName                = self.etl-text(:TAG<VolumeName>, :$!xml);
    $!VolumeState               = self.etl-text(:TAG<VolumeState>, :$!xml);
    $!VolumeUniqueID            = self.etl-text(:TAG<VolumeUniqueID>, :$!xml);
    $!IsFibreChannelBacked      = self.etl-text(:TAG<IsFibreChannelBacked>, :$!xml);
    $!IsISCSIBacked             = self.etl-text(:TAG<IsISCSIBacked>, :$!xml);
    $!StorageLabel              = self.etl-text(:TAG<StorageLabel>, :$!xml);
    $!DescriptorPage83          = self.etl-text(:TAG<DescriptorPage83>, :$!xml);
    $!xml                       = Nil;
    $!loaded                    = True;
    self;
}

=finish
