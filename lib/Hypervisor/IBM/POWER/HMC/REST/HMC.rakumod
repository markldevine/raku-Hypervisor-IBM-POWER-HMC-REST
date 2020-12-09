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

#!/usr/bin/env raku

use Data::Dump::Tree;
use JSON::Fast;

our $*ATTRIBUTE-PROFILE-PATH = 'ATTRIBUTE-get_value.json';
our $*ATTRIBUTE-PROFILING;
our $*ATTRIBUTE-OPTIMIZED;
our %*ATTRIBUTE-get_value;

# profiling mechanism...

multi trait_mod:<is> (Attribute:D $a, :$get-profiled-attribute!) {
    my $mname   = $a.name.substr(2);
    my &method  = my method (Str $s?) {
        if $s {
            $a.set_value(self, $s);
            return $s;
        }
        if $*ATTRIBUTE-OPTIMIZED {
            unless %*ATTRIBUTE-get_value{self.^name}{$a.name.substr(2)}:exists {
                $*ATTRIBUTE-PROFILE-PATH.IO.unlink;
                die 'Process has been previously optimized, but profile is now stale. Restart and optionally re-profile.';
            }
        }
        else {
            %*ATTRIBUTE-get_value{self.^name}{$a.name.substr(2)} = 1 if $*ATTRIBUTE-PROFILING;
        }
        return          $a.get_value(self);
    }
    &method.set_name($mname);
    $a.package.^add_method($mname, &method);
}

class TEST::CASE {
    has $.a1 is get-profiled-attribute;
    has $.a2 is get-profiled-attribute;
}

sub MAIN (Bool :$optimize) {

    if $optimize {
        $*ATTRIBUTE-PROFILE-PATH.IO.unlink if $*ATTRIBUTE-PROFILE-PATH.IO.e;
        $*ATTRIBUTE-PROFILING = True;
        $*ATTRIBUTE-OPTIMIZED = False;
    }
    else {
        if $*ATTRIBUTE-PROFILE-PATH.IO.e {
            %*ATTRIBUTE-get_value = from-json(slurp($*ATTRIBUTE-PROFILE-PATH));
            if %*ATTRIBUTE-get_value.elems {
                $*ATTRIBUTE-PROFILING = False;
                $*ATTRIBUTE-OPTIMIZED = True;
            }
            else {
                $*ATTRIBUTE-PROFILE-PATH.IO.unlink;
                $*ATTRIBUTE-PROFILING = False;
                $*ATTRIBUTE-OPTIMIZED = False;
            }
        }
        else {
            $*ATTRIBUTE-PROFILING = False;
            $*ATTRIBUTE-OPTIMIZED = False;
        }
    }

    my TEST::CASE $tc .= new(a1 => 'FIRST STRING', :a2('SECOND STRING'));
    say $tc.a1;
    say $tc.a2;

    if %*ATTRIBUTE-get_value.elems {
        ddt %*ATTRIBUTE-get_value;
        spurt('ATTRIBUTE-get_value.json', to-json(%*ATTRIBUTE-get_value));
    }
}

=finish
