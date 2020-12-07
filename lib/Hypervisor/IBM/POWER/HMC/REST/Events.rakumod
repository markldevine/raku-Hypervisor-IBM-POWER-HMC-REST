need    Hypervisor::IBM::POWER::HMC::REST::Atom;
need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::Events::Event;
use     LibXML;
unit    class Hypervisor::IBM::POWER::HMC::REST::Events:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                $names-checked = False;
my      Bool                                                $analyzed = False;
my      Lock                                                $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config           $.config is required;
has     Bool                                                $.initialized = False;
has     Bool                                                $.loaded = False;

has     Str                                                 $.id;
has     DateTime                                            $.updated;
has     Hypervisor::IBM::POWER::HMC::REST::Events::Event    @.Event;

has     LibXML::Element                                     $!xml-Event;

method  xml-name-exceptions () { return set <link generator entry>; }

submethod TWEAK {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    my $proceed-with-analyze        = False;
    $lock.protect({
        if !$analyzed {
            $proceed-with-analyze   = True;
            $analyzed               = True;
        }
    });
    self.init;
    self.analyze                    if $proceed-with-analyze;
    self;
}

method init () {
    return self                 if $!initialized;
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $init-start              = now;

    my $fetch-start             = now;
    my $xml-path                = self.config.session-manager.fetch('/rest/api/uom/Event', :optional);
    self.config.diag.post: sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'FETCH', sprintf("%.3f", now - $fetch-start)) if %*ENV<HIPH_FETCH>;
    unless $xml-path {
        $!initialized           = True;
        $!loaded                = True;
        return self;
    }

    my $parse-start             = now;
    self.etl-parse-path(:$xml-path);
    my $proceed-with-name-check = False;
    $lock.protect({
        if !$names-checked  {
            $proceed-with-name-check = True;
            $names-checked = True;
        }
    });
    self.etl-node-name-check    if $proceed-with-name-check;
    self.config.diag.post: sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'PARSE', sprintf("%.3f", now - $parse-start)) if %*ENV<HIPH_PARSE>;

    for self.etl-branches(:TAG<entry>, :$!xml) -> $entry {
        @!Event.push: Hypervisor::IBM::POWER::HMC::REST::Events::Event.new(:$!config, :xml($entry));
    }

    $!initialized               = True;
    self.load                   if self.config.optimization-init-load;
    self.config.diag.post: sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'INITIALIZE', sprintf("%.3f", now - $init-start)) if %*ENV<HIPH_INIT>;
    self;
}

method load () {
    return self     if $!loaded;
    self.init       unless $!initialized;
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $load-start  = now;
    $!id            = self.etl-text(:TAG<id>,                   :$!xml);
    $!updated       = DateTime.new(self.etl-text(:TAG<updated>, :$!xml));
    $!xml           = Nil;
    $!loaded        = True;
    self.config.diag.post: sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'LOAD', sprintf("%.3f", now - $load-start)) if %*ENV<HIPH_LOAD>;
    self;
}

=finish
