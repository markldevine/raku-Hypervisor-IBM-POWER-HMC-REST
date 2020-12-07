need    Hypervisor::IBM::POWER::HMC::REST::Atom;
need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::MachineTypeModelAndSerialNumber;
need    Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::MemConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::NetworkInterfaces;
need    Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::ProcConfiguration;
need    Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::VersionInfo;
use     URI;
use     LibXML;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagementConsole:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                    $names-checked = False;
my      Bool                                                                                    $analyzed = False;
my      Lock                                                                                    $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Atom                                                 $.atom;
has     Hypervisor::IBM::POWER::HMC::REST::Config                                               $.config is required;
has     Bool                                                                                    $.initialized = False;
has     Bool                                                                                    $.loaded = False;
has     Str                                                                                     $.id;
has     Str                                                                                     @.AuthorizedKeysValue;
has     Str                                                                                     $.BaseVersion;
has     Str                                                                                     $.BIOS;
has     Str                                                                                     @.IFixDetails;
has     Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::MachineTypeModelAndSerialNumber   $.MachineTypeModelAndSerialNumber;
has     URI                                                                                     @.ManagedSystems;
has     Str                                                                                     $.ManagementConsoleName;
has     Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::MemConfiguration                  $.MemConfiguration;
has     Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::NetworkInterfaces                 $.NetworkInterfaces;
has     Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::ProcConfiguration                 $.ProcConfiguration;
has     Str                                                                                     $.PublicSSHKeyValue;
has     Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::VersionInfo                       $.VersionInfo;

has     LibXML::Element                                                                         $.xml-entry;
has     LibXML::Element                                                                         $.xml-content;
has     LibXML::Element                                                                         $.xml-ManagementConsole;
has     LibXML::Element                                                                         $.xml-AuthorizedKeysValue;
has     LibXML::Element                                                                         $.xml-IFixDetails;
has     LibXML::Element                                                                         $.xml-MachineTypeModelAndSerialNumber;
has     LibXML::Element                                                                         $.xml-ManagedSystems;
has     LibXML::Element                                                                         $.xml-MemConfiguration;
has     LibXML::Element                                                                         $.xml-NetworkInterfaces;
has     LibXML::Element                                                                         $.xml-ProcConfiguration;
has     LibXML::Element                                                                         $.xml-VersionInfo;

method  xml-name-exceptions () { return set <updated link generator entry>; }

submethod TWEAK {
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    my $proceed-with-analyze    = False;
    $lock.protect({
        if !$analyzed           { $proceed-with-analyze    = True; $analyzed      = True; }
    });
    self.analyze                if $proceed-with-analyze;
    self;
}

method init () {
    return self                             if $!initialized;
    self.config.diag.post:                  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $init-start                          = now;
    my $fetch-start                         = now;
    my $xml-path                            = self.config.session-manager.fetch('/rest/api/uom/ManagementConsole');
    self.config.diag.post:                  sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'FETCH', sprintf("%.3f", now - $fetch-start)) if %*ENV<HIPH_FETCH>;
    my $parse-start                         = now;
    self.etl-parse-path(:$xml-path);
    my $proceed-with-name-check             = False;
    $lock.protect({
        if !$names-checked  { $proceed-with-name-check = True; $names-checked = True; }
    });
    self.etl-node-name-check                if $proceed-with-name-check;
    self.config.diag.post:                  sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'PARSE', sprintf("%.3f", now - $parse-start)) if %*ENV<HIPH_PARSE>;
    $!xml-entry                             = self.etl-branch(:TAG<entry>,                                  :$!xml);
    $!xml-content                           = self.etl-branch(:TAG<content>,                                :xml($!xml-entry));
    $!xml-ManagementConsole                 = self.etl-branch(:TAG<ManagementConsole:ManagementConsole>,    :xml($!xml-content));
    $!atom                                  = self.etl-atom(:xml(self.etl-branch(:TAG<Metadata>,            :xml($!xml-ManagementConsole))));
    $!xml-AuthorizedKeysValue               = self.etl-branch(:TAG<AuthorizedKeysValue>,                    :xml($!xml-ManagementConsole));
    $!xml-IFixDetails                       = self.etl-branch(:TAG<IFixDetails>,                            :xml($!xml-ManagementConsole));
    $!xml-MachineTypeModelAndSerialNumber   = self.etl-branch(:TAG<MachineTypeModelAndSerialNumber>,        :xml($!xml-ManagementConsole));
    $!xml-ManagedSystems                    = self.etl-branch(:TAG<ManagedSystems>,                         :xml($!xml-ManagementConsole));
    $!xml-MemConfiguration                  = self.etl-branch(:TAG<MemConfiguration>,                       :xml($!xml-ManagementConsole));
    $!xml-NetworkInterfaces                 = self.etl-branch(:TAG<NetworkInterfaces>,                      :xml($!xml-ManagementConsole));
    $!xml-ProcConfiguration                 = self.etl-branch(:TAG<ProcConfiguration>,                      :xml($!xml-ManagementConsole));
    $!xml-VersionInfo                       = self.etl-branch(:TAG<VersionInfo>,                            :xml($!xml-ManagementConsole));
    $!MachineTypeModelAndSerialNumber       = Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::MachineTypeModelAndSerialNumber.new(:$!config, :xml($!xml-MachineTypeModelAndSerialNumber));
    $!MemConfiguration                      = Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::MemConfiguration.new(:$!config, :xml($!xml-MemConfiguration));
    $!NetworkInterfaces                     = Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::NetworkInterfaces.new(:$!config, :xml($!xml-NetworkInterfaces)).init;
    $!ProcConfiguration                     = Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::ProcConfiguration.new(:$!config, :xml($!xml-ProcConfiguration));
    $!VersionInfo                           = Hypervisor::IBM::POWER::HMC::REST::ManagementConsole::VersionInfo.new(:$!config, :xml($!xml-VersionInfo));
    $!initialized                           = True;
    self.load                               if self.config.optimization-init-load;
    self.config.diag.post:                  sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'INITIALIZE', sprintf("%.3f", now - $init-start)) if %*ENV<HIPH_INIT>;
    self;
}

method load () {
    return self             if $!loaded;
    self.init               unless $!initialized;
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $load-start          = now;
    self.MachineTypeModelAndSerialNumber.load;
    self.MemConfiguration.load;
    self.NetworkInterfaces.load;
    self.ProcConfiguration.load;
    self.VersionInfo.load;
    @!AuthorizedKeysValue   = self.etl-texts(:TAG<AuthorizedKey>,           :xml($!xml-AuthorizedKeysValue));
    $!BaseVersion           = self.etl-text(:TAG<BaseVersion>,              :xml($!xml-ManagementConsole));
    $!BIOS                  = self.etl-text(:TAG<BIOS>,                     :xml($!xml-ManagementConsole));
    for self.etl-branches(:TAG<IFixDetail>, :xml($!xml-IFixDetails)) -> $xml-IFixDetail {
        @.IFixDetails.push: self.etl-text(:TAG<IFix>, :xml($xml-IFixDetail));
    }
    $!id                    = self.etl-text(:TAG<id>,                       :xml($!xml-entry));
    @!ManagedSystems        = self.etl-links-URIs(                          :xml($!xml-ManagedSystems));
    $!ManagementConsoleName = self.etl-text(:TAG<ManagementConsoleName>,    :xml($!xml-ManagementConsole));
    $!PublicSSHKeyValue     = self.etl-text(:TAG<PublicSSHKeyValue>,        :xml($!xml-ManagementConsole));
    $!xml                   = Nil;
    $!loaded                = True;
    self.config.diag.post:  sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'LOAD', sprintf("%.3f", now - $load-start)) if %*ENV<HIPH_LOAD>;
    self;
}

method Managed-System-Ids () {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    self.load;
    my @managed-system-ids;
    for self.ManagedSystems -> $ms-url {
        @managed-system-ids.push: $ms-url.segments[* - 1];
    }
    return @managed-system-ids;
}

=finish
