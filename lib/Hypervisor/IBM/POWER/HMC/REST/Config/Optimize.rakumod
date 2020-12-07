unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Optimize:api<1>:auth<Mark Devine (mark@markdevine.com)>;

method optimize {
#   self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    self.config.diag.post:  self.^name ~ '::' ~ &?ROUTINE.name ~ ' - NYI' if %*ENV<HIPH_NYI>;
#
#   if optimizing, report self.^name to optimizer
#
}

=finish
