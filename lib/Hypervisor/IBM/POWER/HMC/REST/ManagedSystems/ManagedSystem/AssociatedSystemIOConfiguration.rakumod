need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOAdapters;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOBuses;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::AssociatedSystemVirtualNetwork;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                                                $names-checked = False;
my      Bool                                                                                                                                $analyzed = False;
my      Lock                                                                                                                                $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                                                           $.config is required;
has     Bool                                                                                                                                $.initialized = False;
has     Bool                                                                                                                                $.loaded = False;
has     Str                                                                                                                                 $.AvailableWWPNs;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOAdapters                       $.IOAdapters;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOBuses                          $.IOBuses;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots                          $.IOSlots;
has     Str                                                                                                                                 $.MaximumIOPools;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters                    $.SRIOVAdapters;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::AssociatedSystemVirtualNetwork   $.AssociatedSystemVirtualNetwork;
has     Str                                                                                                                                 $.WWPNPrefix;

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
    $!IOAdapters                        = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOAdapters.new(:$!config, :xml(self.etl-branch(:TAG<IOAdapters>, :$!xml)));
    $!IOBuses                           = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOBuses.new(:$!config, :xml(self.etl-branch(:TAG<IOBuses>, :$!xml)));
    $!IOSlots                           = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOSlots.new(:$!config, :xml(self.etl-branch(:TAG<IOSlots>, :$!xml)));
    $!SRIOVAdapters                     = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::SRIOVAdapters.new(:$!config, :xml(self.etl-branch(:TAG<SRIOVAdapters>, :$!xml)));
    $!AssociatedSystemVirtualNetwork    = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::AssociatedSystemVirtualNetwork.new(:$!config, :xml(self.etl-branch(:TAG<AssociatedSystemVirtualNetwork>, :$!xml)));
    self.load                           if self.config.optimization-init-load;
    $!initialized                       = True;
    self;
}

method load () {
    return self             if $!loaded;
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!IOAdapters.load;
    $!IOBuses.load;
    $!IOSlots.load;
    $!SRIOVAdapters.load;
    $!AssociatedSystemVirtualNetwork.load;
    $!AvailableWWPNs        = self.etl-text(:TAG<AvailableWWPNs>,   :$!xml);
    $!MaximumIOPools        = self.etl-text(:TAG<MaximumIOPools>,   :$!xml);
    $!WWPNPrefix            = self.etl-text(:TAG<WWPNPrefix>,       :$!xml);
    $!xml                   = Nil;
    $!loaded                = True;
    self;
}

=finish
