need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analyze;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Dump;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimize;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
need    Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition;
unit    class Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analyze
            does Hypervisor::IBM::POWER::HMC::REST::Config::Dump
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimize
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

my      Bool                                                                                                    $names-checked = False;
my      Bool                                                                                                    $analyzed = False;
my      Lock                                                                                                    $lock = Lock.new;

has     Hypervisor::IBM::POWER::HMC::REST::Config                                                               $.config is required;
has     Bool                                                                                                    $.initialized = False;
has     Bool                                                                                                    $.loaded = False;
has                                                                                                             $.Managed-System-Id is required;
has     Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition   %.Logical-Partitions;
has                                                                                                             @.Logical-Partition-Ids;
has                                                                                                             @.Logical-Partition-Names;
has                                                                                                             %.Partition-Name-to-Id;
has                                                                                                             %.Id-to-Partition-Name;

method  xml-name-exceptions () { return set (); }

submethod TWEAK {
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    my $proceed-with-name-check = False;
    my $proceed-with-analyze    = False;
    $lock.protect({
        if !$analyzed           { $proceed-with-analyze    = True; $analyzed      = True; }
        if !$names-checked      { $proceed-with-name-check = True; $names-checked = True; }
    });
    self.etl-node-name-check    if $proceed-with-name-check;
#   self.init;
    self.analyze                if $proceed-with-analyze;
    self;
}

method init () {
    return self                 if $!initialized;
    self.config.diag.post:      self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $init-start              = now;
    my $fetch-start             = now;
    my $xml-path                = self.config.session-manager.fetch('/rest/api/uom/ManagedSystem/' ~ $!Managed-System-Id ~ '/LogicalPartition');
    self.config.diag.post:      sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'FETCH', sprintf("%.3f", now - $fetch-start)) if %*ENV<HIPH_FETCH>;
    my $parse-start             = now;
    self.etl-parse-path(:$xml-path);
    self.config.diag.post:      sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'PARSE', sprintf("%.3f", now - $parse-start)) if %*ENV<HIPH_PARSE>;
    my @entries                 = self.etl-branches(:TAG<entry>, :$!xml);
    my @promises;
    for @entries -> $entry {
        my $Logical-Partition-Id = self.etl-text(:TAG<id>, :xml($entry));
        @!Logical-Partition-Ids.push: $Logical-Partition-Id;
        @promises.push: start {
            Hypervisor::IBM::POWER::HMC::REST::ManagedSystems::ManagedSystem::LogicalPartitions::LogicalPartition.new(:$!config, :xml($entry));
        }
    }
    unless await Promise.allof(@promises).then({ so all(@promises>>.result) }) {
        die &?ROUTINE.name ~ ': Not all promises were Kept!';
    }
    my @logical-partition-names;
    for @promises -> $promise {
        my $result = $promise.result;
        my $id = $result.id;
        %!Logical-Partitions{$id} = $result;
        my $Partition-Name = %!Logical-Partitions{$id}.PartitionName;
        @logical-partition-names.push: $Partition-Name;
        %!Partition-Name-to-Id{$Partition-Name} = $id;
        %!Id-to-Partition-Name{$id} = $Partition-Name;
    }
    @!Logical-Partition-Names   = @logical-partition-names.sort;
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
    my @entries             = self.etl-branches(:TAG<entry>, :$!xml);
    my @promises;
    for @!Logical-Partition-Ids -> $id {
        @promises.push: start {
            %!Logical-Partitions{$id}.load;
        }
    }
    unless await Promise.allof(@promises).then({ so all(@promises>>.result) }) {
        die &?ROUTINE.name ~ ': Not all promises were Kept!';
    }
    $!xml                   = Nil;
    $!loaded                = True;
    self.config.diag.post:  sprintf("%-20s %10s: %11s", self.^name.subst(/^.+'::'(.+)$/, {$0}), 'LOAD', sprintf("%.3f", now - $load-start)) if %*ENV<HIPH_LOAD>;
    self;
}

method Logical-Partition-by-Id (Str:D $id is required) {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    return %!Logical-Partitions{$id} if %!Logical-Partitions{$id}:exists;
    die 'Unknown Logical Partition Id <' ~ $id ~ '>';
}

method Logical-Partition-by-Name (Str:D $Name is required) {
    self.config.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    die 'Unknown Logical-Partition Name <' ~ $Name ~ '>' unless %!Partition-Name-to-Id{$Name}:exists;
    self.Logical-Partition-by-Id(%!Partition-Name-to-Id{$Name});
}

=finish
