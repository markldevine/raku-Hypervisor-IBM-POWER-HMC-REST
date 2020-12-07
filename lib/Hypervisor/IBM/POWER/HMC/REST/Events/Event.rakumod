need    Hypervisor::IBM::POWER::HMC::REST::Atom;
need    Hypervisor::IBM::POWER::HMC::REST::Config;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
use     URI;
unit    class Hypervisor::IBM::POWER::HMC::REST::Events::Event:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

has     Hypervisor::IBM::POWER::HMC::REST::Config   $.config is required;

has     Hypervisor::IBM::POWER::HMC::REST::Atom     $.atom;
has     Str                                         $.id;
has     DateTime                                    $.published;
has     Str                                         $.EventType;
has     Str                                         $.EventID;
has     Str                                         $.EventData;
has     Str                                         $.EventDetail;

method  xml-name-exceptions () { return set <title link author etag:etag>; }

submethod TWEAK {
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_SUBMETHOD>;
    my $xml-content         = self.etl-branch(:TAG<content>,                        :$!xml);
    my $xml-Event           = self.etl-branch(:TAG<Event:Event>,                    :xml($xml-content));
    $!id                    = self.etl-text(:TAG<id>,                               :$!xml);
    $!published             = DateTime.new(self.etl-text(:TAG<published>,           :$!xml));
    $!atom                  = self.etl-atom(:xml(self.etl-branch(:TAG<Metadata>,    :xml($xml-Event))));
    $!EventType             = self.etl-text(:TAG<EventType>,                        :xml($xml-Event));
    $!EventID               = self.etl-text(:TAG<EventID>,                          :xml($xml-Event));
    $!EventData             = self.etl-text(:TAG<EventData>,                        :xml($xml-Event), :optional);
    $!EventDetail           = self.etl-text(:TAG<EventDetail>,                      :xml($xml-Event), :optional);
    self;
}

=finish
