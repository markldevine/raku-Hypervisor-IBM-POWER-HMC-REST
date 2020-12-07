need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::VersionInfo:api<1>:auth<Mark Devine (mark@markdevine.com)>
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
has     Str                                         $.BuildLevel;
has     Str                                         $.Maintenance;
has     Str                                         $.Minor;
has     Str                                         $.Release;
has     Str                                         $.ServicePackName;
has     Str                                         $.Version;

method  xml-name-exceptions () { return set <Metadata>; }

#method new (|c) {
#    note self.^name ~ '::' ~ &?ROUTINE.name ~ ' to wrap methods...';
##   self.load.wrap(|c) { note self.^name ~ '::' ~ &?ROUTINE.name ~ ' from WRAP'; nextsame; }
#
#    my %local-attrs = self.^attributes(:local).map({ $_.name => $_.package });
#    my %accessors = Hash.new;
#    for self.^attributes -> $attr {
##       next if %local-attrs{$attr.name}:exists && !(%local-attrs{$attr.name} === $attr.package);
##       next if $attr.required;
#        next unless $attr.has_accessor;
#        my $name = $attr.name.substr(2);
#        %accessors{$name} = 1;
#    }
#    for self.^method_table.kv -> $mname, $m {
#        next if %accessors{$mname}:exists;
#        say 'Considering: ' ~ $mname;
##       if %mtable{$name}:exists {
##           note 'Found ' ~ $name ~ ' in method table';
##           %mtable{$name}.wrap(method { note 'in method ' ~ $name; callsame; });
##           die unless self.^find_method($name).wrap(method { note 'in method ' ~ $name; nextsame; });
##       }
#    }
#
##   ddt %mtable;
#
#
#    callsame;
#}

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
    return self             if $!loaded;
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!BuildLevel            = self.etl-text(:TAG<BuildLevel>,       :$!xml);
    $!Maintenance           = self.etl-text(:TAG<Maintenance>,      :$!xml);
    $!Minor                 = self.etl-text(:TAG<Minor>,            :$!xml);
    $!Release               = self.etl-text(:TAG<Release>,          :$!xml);
    $!ServicePackName       = self.etl-text(:TAG<ServicePackName>,  :$!xml);
    $!Version               = self.etl-text(:TAG<Version>,          :$!xml);
    $!xml                   = Nil;
    $!loaded                = True;
    self;
}

=finish
