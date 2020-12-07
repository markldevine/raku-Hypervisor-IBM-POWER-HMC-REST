need    Hypervisor::IBM::POWER::HMC::REST::Atom;
use     Terminal::ANSIColor;
use     URI;
use     LibXML;
unit    role Hypervisor::IBM::POWER::HMC::REST::ETL::XML:api<0.0.1>:auth<Mark Devine (mark@markdevine.com)>;

has     LibXML::Element $.xml;

###%    Convert etl-parse-string & etl-parse-path to multi-method etl-parse...

#   self.etl-string(:$xml-string);
method etl-parse-string (Str:D :$xml-string is required) {
    my LibXML::Document $dom;
    die 'Unable to read XML from $xml-string' unless $dom = LibXML.parse(:string($xml-string), :!blanks);
    $!xml = $dom.documentElement;
}

#   self.etl-parse(:$xml-path);
method etl-parse-path (Str:D :$xml-path is required) {
    my LibXML::Document $dom;
    die 'Unable to read XML from ' ~ $xml-path unless $dom = LibXML.parse(:location($xml-path), :!blanks);
    $!xml = $dom.documentElement;
}

proto method etl-branches (:$TAG is required, :$xml is required, Bool :$optional --> Array) { * };
multi method etl-branches (Str:D :$TAG is required, LibXML::Document:D :$xml is required, Bool :$optional --> Array) {
    self.config.diag.post: sprintf("%-20s%11s:%12s", &?ROUTINE.name, 'TRANSFORM', 'LibXML::Document -> LibXML::Element') if %*ENV<HIPH_ETL_BRANCHES>;
    my LibXML::Element $root = $xml.documentElement();
    self.etl-branches(:$TAG, :xml($root), :$optional);
}
multi method etl-branches (Str:D :$TAG is required, LibXML::Element:D :$xml is required, Bool :$optional --> Array) {
    my @xml-nodes = $xml.getChildrenByTagName($TAG);
    self.config.diag.post: sprintf("%-20s%11s:%12d elements of <%s>", &?ROUTINE.name, 'GATHER', @xml-nodes.elems, $TAG) if %*ENV<HIPH_ETL_BRANCHES>;
    return @xml-nodes if @xml-nodes.elems;
    return Array.new() if $optional;
    self.config.note.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ': Expected TAG <' ~ $TAG ~ '> not found in xml source';
}
multi method etl-branches (Str:D :$TAG is required, LibXML::Element :$xml is required, Bool :$optional --> Array) {
    return Array.new() if $optional;
    self.config.note.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ': Expected TAG <' ~ $TAG ~ '> not found in empty xml source';
}

proto method etl-branch (:$TAG is required, :$xml is required, Bool :$optional --> LibXML::Element) { * };
multi method etl-branch (Str:D :$TAG is required, LibXML::Document:D :$xml is required, Bool :$optional --> LibXML::Element) {
    self.config.diag.post: sprintf("%-20s%11s:%13s%s", &?ROUTINE.name, 'TRANSFORM', ' ', 'LibXML::Document -> LibXML::Element') if %*ENV<HIPH_ETL_BRANCH>;
    my LibXML::Element $root = $xml.documentElement();
    self.etl-branch(:$TAG, :xml($root), :$optional);
};
multi method etl-branch (Str:D :$TAG is required, LibXML::Element:D :$xml is required, Bool :$optional --> LibXML::Element) {
    my $xml-node = $xml.getChildrenByTagName($TAG).first;
    self.config.diag.post: sprintf("%-20s%11s:%13s%s", &?ROUTINE.name, 'ISOLATE', ' ', $TAG) if %*ENV<HIPH_ETL_BRANCH>;
    return $xml-node if $xml-node;
    return LibXML::Element if $optional;
    self.config.note.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ': Expected TAG <' ~ $TAG ~ '> not found in xml source';
};
multi method etl-branch (Str :$TAG is required, :$xml is required, Bool :$optional --> LibXML::Element) {
    return LibXML::Element if $optional;
    self.config.note.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ': TAG was expected';
}

proto method etl-text (:$TAG is required, :$xml is required, Bool :$optional --> Str) { * };
multi method etl-text (Str:D :$TAG is required, LibXML::Document:D :$xml is required, Bool :$optional --> Str) {
    self.config.diag.post: sprintf("%-20s%11s:%13s%s", &?ROUTINE.name, 'TRANSFORM', ' ', 'LibXML::Document -> LibXML::Element') if %*ENV<HIPH_ETL_TEXT_TRANSFORM>;
    my LibXML::Element $root = $xml.documentElement();
    self.etl-text(:$TAG, :xml($root), :$optional);
};
multi method etl-text (Str:D :$TAG is required, LibXML::Element:D :$xml is required, Bool :$optional --> Str) {
    my $xml-node;
    my $routine-name = &?ROUTINE.name;
    if $xml-node = $xml.getChildrenByTagName($TAG).first {
        if $xml-node.nodes.first.textContent {
            my $text = $xml-node.nodes.first.textContent.trim;
            self.config.diag.post: sprintf("%-20s%11s:%13s<%s> = '%s'", $routine-name, 'EXTRACT', ' ', $TAG, $text) if %*ENV<HIPH_ETL_TEXT_EXTRACT>;
            return $text;
        }
    }
    self.config.note.post: self.^name ~ '::' ~ $routine-name ~ ': Expected TAG <' ~ $TAG ~ '> not found in xml source' unless $optional;
    Nil;
};

multi method etl-text (Str:D :$TAG is required, LibXML::Element :$xml is required, Bool :$optional --> Str) {
    self.config.note.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ': Expected TAG <' ~ $TAG ~ '> not found in empty xml source' unless $optional;
    Nil
};

proto method etl-texts (:$TAG is required, :$xml is required, Bool :$optional --> Str) { * };
multi method etl-texts (Str:D :$TAG is required, LibXML::Document:D :$xml is required, Bool :$optional --> Str) {
    self.config.diag.post: sprintf("%-20s%11s:%13s%s", &?ROUTINE.name, 'TRANSFORM', ' ', 'LibXML::Document -> LibXML::Element') if %*ENV<HIPH_ETL_TEXTS>;
    note colored(sprintf("%-20s %10s: %11s %s", &?ROUTINE.name, 'TRANSFORM', 't' ~ $*THREAD.id, 'LibXML::Document -> LibXML::Element'), 'black on_magenta') if %*ENV<HIPH_ETL_TEXTS>;
    my LibXML::Element $root = $xml.documentElement();
    self.etl-texts(:$TAG, :xml($root), :$optional);
}
multi method etl-texts (Str:D :$TAG is required, LibXML::Element :$xml is required, Bool :$optional --> Array) {
    my @xml-nodes = $xml.getChildrenByTagName($TAG);
    unless @xml-nodes.elems {
        return Array.new() if $optional;
        self.config.note.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ': Expected TAG <' ~ $TAG ~ '> not found in xml source';
    }
    my @texts;
    for @xml-nodes -> $xml-node {
        @texts.push: $xml-node.nodes.first.textContent.trim;
    }
    self.config.diag.post: sprintf("%-20s%11s:%12d of <%s>", &?ROUTINE.name, 'EXTRACT', @texts.elems, $TAG) if %*ENV<HIPH_ETL_TEXTS>;
    return @texts if @texts.elems;
    Nil;
}

proto method etl-links-URIs (:$xml is required --> Array) { * };
multi method etl-links-URIs (LibXML::Element:D :$xml is required --> Array) {
    my @hrefs;
    for $xml.getChildrenByTagName('link') -> $link {
        push @hrefs, URI.new($link.getAttribute('href'));
    }
    self.config.diag.post: sprintf("%-20s%11s:%12d URIs", &?ROUTINE.name, 'EXTRACT', @hrefs.elems) if %*ENV<HIPH_ETL_LINKS_URIS>;
    return @hrefs;
}
multi method etl-links-URIs (LibXML::Element :$xml is required --> Array) {
    return Array.new();
}

proto method etl-href (:$xml is required) { * };
multi method etl-href (LibXML::Element:D :$xml is required --> URI) {
    my $url = $xml.getAttribute('href');
    self.config.diag.post: sprintf("%-20s%11s:%13s<%s>", &?ROUTINE.name, 'EXTRACT', ' ', $url) if %*ENV<HIPH_ETL_HREF>;
    return URI.new($url);
}
multi method etl-href (LibXML::Element :$xml is required) {
    return Nil;
}

method xml-name-exceptions () { ... };

method etl-node-name-check () {
    return unless self.xml.DEFINITE;
    for self.xml.elements -> $element {
        next if self.can($element.name) || $element.name (elem) self.xml-name-exceptions;
        self.config.note.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ': ' ~ $element.name ~ ' not implemented';
    }
}

method etl-atom (:$xml is required) {
    my LibXML::Element $xml-Atom    = self.etl-branch(:TAG<Atom>,       :$xml);
    my              $AtomID         = self.etl-text(:TAG<AtomID>,       :xml($xml-Atom));
    my              $AtomCreated    = self.etl-text(:TAG<AtomCreated>,  :xml($xml-Atom));
    $AtomCreated                    = DateTime.new($AtomCreated / 1000);
    return Hypervisor::IBM::POWER::HMC::REST::Atom.new(:$AtomID, :$AtomCreated);
}

=finish
