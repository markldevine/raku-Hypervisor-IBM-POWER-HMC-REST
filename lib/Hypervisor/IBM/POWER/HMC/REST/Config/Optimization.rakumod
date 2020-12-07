unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Optimization:api<1>:auth<Mark Devine (mark@markdevine.com)>;

has     Bool    $.auto-load = True;

method optimization-init-load {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
#
#   decide if .init() should proceed to .load()
#
    return self.auto-load;
}

method set-init-load (Bool:D $auto-load) {
    $!auto-load = $auto-load;
}

=finish
