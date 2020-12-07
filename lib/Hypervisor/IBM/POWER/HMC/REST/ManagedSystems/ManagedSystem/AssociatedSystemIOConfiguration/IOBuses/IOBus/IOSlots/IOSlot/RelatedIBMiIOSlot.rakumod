need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::AssociatedSystemIOConfiguration::IOBuses::IOBus::IOSlots::IOSlot::RelatedIBMiIOSlot:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.AlternateLoadSourceAttached;
has     Str                                         $.ConsoleCapable;
has     Str                                         $.DirectOperationsConsoleCapable;
has     Str                                         $.IOP;
has     Str                                         $.IOPInfoStale;
has     Str                                         $.IOPoolID;
has     Str                                         $.LANConsoleCapable;
has     Str                                         $.LoadSourceAttached;
has     Str                                         $.LoadSourceCapable;
has     Str                                         $.OperationsConsoleAttached;
has     Str                                         $.OperationsConsoleCapable;

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
    return self                         if $!loaded;
    self.config.diag.post:              self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!AlternateLoadSourceAttached       = self.etl-text(:TAG<AlternateLoadSourceAttached>,      :$!xml, :optional);
    $!ConsoleCapable                    = self.etl-text(:TAG<ConsoleCapable>,                   :$!xml, :optional);
    $!DirectOperationsConsoleCapable    = self.etl-text(:TAG<DirectOperationsConsoleCapable>,   :$!xml, :optional);
    $!IOP                               = self.etl-text(:TAG<IOP>,                              :$!xml, :optional);
    $!IOPInfoStale                      = self.etl-text(:TAG<IOPInfoStale>,                     :$!xml, :optional);
    $!IOPoolID                          = self.etl-text(:TAG<IOPoolID>,                         :$!xml, :optional);
    $!LANConsoleCapable                 = self.etl-text(:TAG<LANConsoleCapable>,                :$!xml, :optional);
    $!LoadSourceAttached                = self.etl-text(:TAG<LoadSourceAttached>,               :$!xml, :optional);
    $!LoadSourceCapable                 = self.etl-text(:TAG<LoadSourceCapable>,                :$!xml, :optional);
    $!OperationsConsoleAttached         = self.etl-text(:TAG<OperationsConsoleAttached>,        :$!xml, :optional);
    $!OperationsConsoleCapable          = self.etl-text(:TAG<OperationsConsoleCapable>,         :$!xml, :optional);
    $!xml                               = Nil;
    $!loaded                            = True;
    self;
}

=finish
