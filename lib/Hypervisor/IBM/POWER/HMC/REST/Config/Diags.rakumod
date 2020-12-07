unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Diags:api<1>:auth<Mark Devine (mark@markdevine.com)>;

multi sub trait_mod:<is>(Method \m, :$diag-method!) {
    m.wrap(my method (|) {
#       self.config.diag.post: m.^name ~ '::' ~ m.name if %*ENV<HIPH_METHOD>;
say self.^name ~ '::' ~ m.name ~ ' method';
#note 'WRAP: method ' ~ m.name;
        callsame;
    });
}

multi sub trait_mod:<is>(Method \m, :$diag-method-private!) {
    m.wrap(my method (|) {
#       self.config.diag.post: m.^name ~ '::' ~ m.name if %*ENV<HIPH_METHOD_PRIVATE>;
say self.^name ~ '::' ~ m.name ~ ' method (private)';
#note 'WRAP: method ' ~ m.name;
        callsame;
    });
}

=finish
