need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Options;
need    Hypervisor::IBM::POWER::HMC::REST::ManagementConsole;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems;
#need    Hypervisor::IBM::POWER::HMC::REST::PowerEnterprisePool;
#
need    Hypervisor::IBM::POWER::HMC::REST::SystemTemplate;
#need    Hypervisor::IBM::POWER::HMC::REST::Cluster;
need    Hypervisor::IBM::POWER::HMC::REST::Events;
unit    class Hypervisor::IBM::POWER::HMC::REST::HMC:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;

my      Bool                                                $analyzed = False;
my      Lock                                                $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                 $.config;
has     Bool                                                $.loaded = False;
has     Bool                                                $.initialized = False;
has     Hypervisor::IBM::POWER::HMC::REST::Config::Options        $.options;
has     Hypervisor::IBM::POWER::HMC::REST::ManagementConsole      $.ManagementConsole;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems         $.ManagedSystems;
#has     Hypervisor::IBM::POWER::HMC::REST::PowerEnterprisePool    $.PowerEnterprisePool;
has     Hypervisor::IBM::POWER::HMC::REST::SystemTemplate         $.SystemTemplate;
#has     Hypervisor::IBM::POWER::HMC::REST::Cluster                $.Cluster;
has     Hypervisor::IBM::POWER::HMC::REST::Events                 $.Events;

submethod TWEAK {
    %*ENV<PID-PATH>             = '';
    my $proceed-with-analyze    = False;
    $lock.protect({
        if !$analyzed           { $proceed-with-analyze    = True; $analyzed      = True; }
    });
    self.init;
    self.analyze                if $proceed-with-analyze;
    self.config.diag.post: sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'INITIALIZE', sprintf("%.3f", now - $*INIT-INSTANT)) if %*ENV<HIPH_INIT>;
    self;
}

method init () {
    return self             if $!initialized;
    $!options               = Hypervisor::IBM::POWER::HMC::REST::Config::Options.new without $!options;
    $!config                = Hypervisor::IBM::POWER::HMC::REST::Config.new(:$!options);
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    $!options               = Nil;
    $!ManagementConsole     = Hypervisor::IBM::POWER::HMC::REST::ManagementConsole.new(:$!config);
    $!ManagedSystems        = Hypervisor::IBM::POWER::HMC::REST::ManagedSystems.new(:$!config);
#   $!PowerEnterprisePool   = Hypervisor::IBM::POWER::HMC::REST::PowerEnterprisePool.new(:$!config);
#
#   $!SystemTemplate        = Hypervisor::IBM::POWER::HMC::REST::SystemTemplate.new(:$!config);
#   $!Cluster               = Hypervisor::IBM::POWER::HMC::REST::Cluster.new(:$!config);
#   $!Events                = Hypervisor::IBM::POWER::HMC::REST::Events.new(:$!config);
    self.config.promote-candidates;
    $!initialized           = True;
    self;
}

method load () {
    return self if $!loaded;
    self.init   unless self.initialized;
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
# The following cannot be parallelized due to the cummulative %!analysis commit scheme...
#   $!Events.load;
    $!ManagementConsole.load;
    $!ManagedSystems.load;
    $!loaded    = True;
    self;
}

END {
    if %*ENV<PID-PATH>:exists {
        if %*ENV<PID-PATH>.IO.f {
            note .exception.message without %*ENV<PID-PATH>.IO.unlink;
        }
        %*ENV<PID-PATH>:delete;
    }
}

=finish

# profiling mechanism...
multi trait_mod:<is> (Attribute:D $a, :$xml-text-attr! (LibXML::Element $xml)) {
    my $mname   = $a.name.substr(2);
    my &method  = my method {
        state $fetched = False;
        return $a.get_value(self) if $fetched;
        my $value = self.etl-text(:TAG($mname), :$xml));
        $a.set_value(self, $value);
        $fetched = True;
        return $value;
    }
    &method.set_name($mname);
    $a.package.^add_method($mname, &method);
}
