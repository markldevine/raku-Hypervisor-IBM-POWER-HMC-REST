need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::ConvergedEthernetPhysicalPorts;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::EthernetLogicalPorts;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::UnconfiguredLogicalPorts;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                                                                                                                                                             $.AdapterID;
has     Str                                                                                                                                                                             $.Description;
has     Str                                                                                                                                                                             $.PhysicalLocation;
has     Str                                                                                                                                                                             $.SRIOVAdapterID;
has     Str                                                                                                                                                                             $.AdapterState;
has     Str                                                                                                                                                                             $.AdapterMode;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::ConvergedEthernetPhysicalPorts $.ConvergedEthernetPhysicalPorts;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::EthernetLogicalPorts           $.EthernetLogicalPorts;
has     Str                                                                                                                                                                             $.IsFunctional;
has     Str                                                                                                                                                                             $.MaximumHugeDMALogicalPorts;
has     Str                                                                                                                                                                             $.MaximumLogicalPortsSupported;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::UnconfiguredLogicalPorts       $.UnconfiguredLogicalPorts;
has     Str                                                                                                                                                                             $.Personality;

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
    return self                         if $!initialized;
    self.config.diag.post:              self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!ConvergedEthernetPhysicalPorts    = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::ConvergedEthernetPhysicalPorts.new(:$!config, :xml(self.etl-branch(:TAG<ConvergedEthernetPhysicalPorts>, :$!xml, :optional)));
    $!EthernetLogicalPorts              = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::EthernetLogicalPorts.new(:$!config, :xml(self.etl-branch(:TAG<EthernetLogicalPorts>, :$!xml, :optional)));
    $!UnconfiguredLogicalPorts          = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters::IOAdapterChoice::SRIOVAdapter::UnconfiguredLogicalPorts.new(:$!config, :xml(self.etl-branch(:TAG<UnconfiguredLogicalPorts>, :$!xml, :optional)));
    self.load                           if self.config.optimization-init-load;
    $!initialized                       = True;
    self;
}

method load () {
    return self                         if $!loaded;
    self.config.diag.post:              self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!ConvergedEthernetPhysicalPorts.load;
    $!EthernetLogicalPorts.load;
    $!UnconfiguredLogicalPorts.load;
    $!AdapterID                         = self.etl-text(:TAG<AdapterID>,                    :$!xml);
    $!Description                       = self.etl-text(:TAG<Description>,                  :$!xml);
    $!PhysicalLocation                  = self.etl-text(:TAG<PhysicalLocation>,             :$!xml);
    $!SRIOVAdapterID                    = self.etl-text(:TAG<SRIOVAdapterID>,               :$!xml, :optional);
    $!AdapterState                      = self.etl-text(:TAG<AdapterState>,                 :$!xml);
    $!AdapterMode                       = self.etl-text(:TAG<AdapterMode>,                  :$!xml);
    $!IsFunctional                      = self.etl-text(:TAG<IsFunctional>,                 :$!xml);
    $!MaximumHugeDMALogicalPorts        = self.etl-text(:TAG<MaximumHugeDMALogicalPorts>,   :$!xml, :optional);
    $!MaximumLogicalPortsSupported      = self.etl-text(:TAG<MaximumLogicalPortsSupported>, :$!xml, :optional);
    $!Personality                       = self.etl-text(:TAG<Personality>,                  :$!xml, :optional);
    $!xml                               = Nil;
    $!loaded                            = True;
    self;
}

=finish
