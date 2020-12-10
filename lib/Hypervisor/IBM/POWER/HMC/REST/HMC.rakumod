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
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
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

#!/usr/bin/env raku

use JSON::Fast;

our              %OPTIMIZE-ATTRIBUTE-get_value          = ();
our              $OPTIMIZE-ATTRIBUTE-get_value-PATH     = '/home/mdevine/dev/ATTRIBUTE-get_value.json';
our              $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS  = 0;
constant         OPTIMIZE-ATTRIBUTE-get_value-PROFILING = 1;
constant         OPTIMIZE-ATTRIBUTE-get_value-PROFILED  = 2;
constant         OPTIMIZE-ATTRIBUTE-get_value-UPDATED   = 4;

multi trait_mod:<is> (Attribute:D \a, :$conditional-initialization-attribute!) {
    my $mname   = a.name.substr(2);
    my &method  = my method (Str $s?) {
        if $s {
            a.set_value(self, $s);
            return $s;
        }
        return a.get_value(self) unless $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS & (OPTIMIZE-ATTRIBUTE-get_value-PROFILING +| OPTIMIZE-ATTRIBUTE-get_value-PROFILED);

        if $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +& OPTIMIZE-ATTRIBUTE-get_value-PROFILED {
            unless %OPTIMIZE-ATTRIBUTE-get_value{self.^name}{a.name.substr(2)}:exists {
                $OPTIMIZE-ATTRIBUTE-get_value-PATH.IO.unlink;
                die 'Optimization map is stale. Restart and optionally re-optimize. Exiting...';
            }
        }
        elsif $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +& OPTIMIZE-ATTRIBUTE-get_value-PROFILING {
            %OPTIMIZE-ATTRIBUTE-get_value{self.^name}{a.name.substr(2)} = 1;
            $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +|= OPTIMIZE-ATTRIBUTE-get_value-UPDATED;
        }
        return a.get_value(self);
    }
    &method.set_name($mname);
    a.package.^add_method($mname, &method);
}

sub slow-feed-a1 { put 'a1 loading...'; sleep 1; 'a1 VALUE' }
sub slow-feed-a2 { put 'a2 loading...'; sleep 4; 'a2 VALUE' }

sub init-check (Str:D $package!, Str:D $name!) {
#   (1) no optimization -- return fastest
    return True unless $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +& OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
#   (2) been profiled, return False as soon as possible
    return False unless %OPTIMIZE-ATTRIBUTE-get_value{$package}{$name}:exists;
#   (3) been profiled, and it's an active attribute
    return True;
}

class TEST::CASE {
    has $.a1 is conditional-initialization-attribute;
    has $.a2 is conditional-initialization-attribute;

    submethod TWEAK {
        $!a1 = slow-feed-a1() if init-check(self.^name, 'a1');
        $!a2 = slow-feed-a2() if init-check(self.^name, 'a2');
    }
}

sub MAIN (Bool :$optimize) {

    if $optimize {
        $OPTIMIZE-ATTRIBUTE-get_value-PATH.IO.unlink if $OPTIMIZE-ATTRIBUTE-get_value-PATH.IO.e;
        $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
        $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +|= OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
    }
    else {
        if $OPTIMIZE-ATTRIBUTE-get_value-PATH.IO.e {
            %OPTIMIZE-ATTRIBUTE-get_value = from-json(slurp($OPTIMIZE-ATTRIBUTE-get_value-PATH));
            if %OPTIMIZE-ATTRIBUTE-get_value.elems {
                $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +|= OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
                $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
            }
            else {
                $OPTIMIZE-ATTRIBUTE-get_value-PATH.IO.unlink;
                $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
                $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
            }
        }
        else {
            $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILED;
            $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +&= +^OPTIMIZE-ATTRIBUTE-get_value-PROFILING;
        }
    }

    my TEST::CASE $tc .= new;
    say $tc.a1;
#   say $tc.a2;

}

END {
    if $OPTIMIZE-ATTRIBUTE-get_value-ACTIONS +& OPTIMIZE-ATTRIBUTE-get_value-UPDATED {
        spurt('ATTRIBUTE-get_value.json', to-json(%OPTIMIZE-ATTRIBUTE-get_value));
    }
}
