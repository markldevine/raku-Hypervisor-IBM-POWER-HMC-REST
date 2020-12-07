unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Analyze:api<1>:auth<Mark Devine (mark@markdevine.com)>;

method analyze {
    self.config.diag.post:          self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my $context                     = self.config.current-context(:context(self.^name));
    return                          unless self.config.requires-analysis(:current-context($context));
    my %local-attrs                 = self.^attributes(:local).map({ $_.name => $_.package });
    my $max-local-attr-name-chars   = 0;
    for self.^attributes -> $attr {
        next                        if %local-attrs{$attr.name}:exists && !(%local-attrs{$attr.name} === $attr.package);
        next                        unless $attr.has_accessor;
        next                        unless $attr.type ~~ Str;
        next                        if $attr.type.^name ~~ /^Positional/;
        my $name                    = $attr.name.substr(2);
        $max-local-attr-name-chars  = $name.chars if $name.chars > $max-local-attr-name-chars;
    }
    self.config.analysis-collect-max-local-attr-name-chars(:package($context), :$max-local-attr-name-chars);
    return;
}

=finish
