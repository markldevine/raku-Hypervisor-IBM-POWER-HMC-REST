need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                $names-checked = False;
my      Bool                                                                $analyzed = False;
my      Lock                                                                $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                           $.config is required;
has     Bool                                                                $.loaded = False;
has     Bool                                                                $.initialized = False;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem    %.Managed-Systems;
has     Str                                                                 @.Managed-Systems-Ids;
has     Str                                                                 @.Managed-Systems-Names;
has                                                                         %.Managed-System-SystemName-to-Id;
has                                                                         %.Managed-System-Id-to-SystemName;

method  xml-name-exceptions () { return set (); }

submethod TWEAK {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    my $proceed-with-analyze    = False;
    $lock.protect({
        if !$analyzed           { $proceed-with-analyze    = True; $analyzed      = True; }
    });
    self.analyze                if $proceed-with-analyze;
    self;
}

method init () {
    return self                 if $!initialized;
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $init-start              = now;
    my $fetch-start             = now;
    my $xml-path                = self.config.session-manager.fetch('/rest/api/uom/ManagedSystem');
    my $proceed-with-name-check = False;
    $lock.protect({
        if !$names-checked { $proceed-with-name-check = True; $names-checked = True; }
    });
    self.etl-node-name-check    if $proceed-with-name-check;
    self.config.diag.post:      sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'FETCH', sprintf("%.3f", now - $fetch-start)) if %*ENV<HIPH_FETCH>;
    my $parse-start             = now;
    self.etl-parse-path(:$xml-path);
    self.config.diag.post:      sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'PARSE', sprintf("%.3f", now - $parse-start)) if %*ENV<HIPH_PARSE>;
    my @promises;
    for self.etl-branches(:TAG<entry>, :$!xml) -> $entry {
        my $Managed-System-Id = self.etl-text(:TAG<id>, :xml($entry));
        @!Managed-Systems-Ids.push: $Managed-System-Id;
        @promises.push: start {
            Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem.new(:$!config, :xml($entry));
        }
    }
    unless await Promise.allof(@promises).then({ so all(@promises>>.result) }) {
        die 'ManagedSystems.init: Not all promises were Kept!';
    }
    for @promises -> $promise {
        my $result = $promise.result;
        my $id = $result.id;
        %!Managed-Systems{$id} = $result;
        my $SystemName = %!Managed-Systems{$id}.SystemName;
        %!Managed-System-SystemName-to-Id{$SystemName} = $id;
        %!Managed-System-Id-to-SystemName{$id} = $SystemName;
    }
    @!Managed-Systems-Names     = %!Managed-System-SystemName-to-Id.keys.sort;
    $!initialized               = True;
    self.load                   if self.config.optimization-init-load;
    self.config.diag.post:      sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'INITIALIZE', sprintf("%.3f", now - $init-start)) if %*ENV<HIPH_INIT>;
    self;
}

method load () {
    return self             if $!loaded;
    self.init               unless $!initialized;
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $load-start          = now;
    my @promises;
    for @!Managed-Systems-Ids -> $id {
        @promises.push: start {
            %!Managed-Systems{$id}.load;
        }
    }
    unless await Promise.allof(@promises).then({ so all(@promises>>.result) }) {
        die 'ManagedSystems.load: Not all promises were Kept!';
    }
    $!xml                   = Nil;
    $!loaded                = True;
    self.config.diag.post:  sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'LOAD', sprintf("%.3f", now - $load-start)) if %*ENV<HIPH_LOAD>;
    self;
}

method Initialize-Logical-Partitions () {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    self.load;
    my @promises;
    for self.Managed-Systems-Ids -> $Managed-Systems-Id {
        @promises.push: start {
            self.Managed-System-by-Id($Managed-Systems-Id).load unless self.Managed-System-by-Id($Managed-Systems-Id).loaded;
            self.Managed-System-by-Id($Managed-Systems-Id).LogicalPartitions.init;
        }
    }
    unless await Promise.allof(@promises).then({ so all(@promises>>.result) }) {
        die 'ManagedSystems: Not all LogicalPartition initialization promises were Kept!';
    }
}

method Initialize-Virtual-IO-Servers () {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    self.load;
    my @promises;
    for self.Managed-Systems-Ids -> $Managed-Systems-Id {
        @promises.push: start {
            self.Managed-System-by-Id($Managed-Systems-Id).load unless self.Managed-System-by-Id($Managed-Systems-Id).loaded;
            self.Managed-System-by-Id($Managed-Systems-Id).VirtualIOServers.init;
        };
    }
    unless await Promise.allof(@promises).then({ so all(@promises>>.result) }) {
        die &?ROUTINE.name ~ ': Not all LogicalPartition initialization promises were Kept!';
    }
}

method Managed-System-by-Id (Str:D $id is required) {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    return %!Managed-Systems{$id} if %!Managed-Systems{$id}:exists;
    die 'Unknown Managed System Id <' ~ $id ~ '>';
}

method Managed-System-by-SystemName (Str:D $SystemName is required) {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    die 'Unknown Managed SystemName <' ~ $SystemName ~ '>' unless %!Managed-System-SystemName-to-Id{$SystemName}:exists;
    my $id = %!Managed-System-SystemName-to-Id{$SystemName};
    self.Managed-System-by-Id($id);
}

=finish
