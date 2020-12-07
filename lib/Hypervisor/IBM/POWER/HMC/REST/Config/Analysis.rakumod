unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Analysis:api<1>:auth<Mark Devine (mark@markdevine.com)>;

my      \CONTEXT-ROOT   = 'Hypervisor::IBM::POWER';

has     %.analysis;

method analysis-commit () {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    self!analysis-calculate-max-branch-attr-name-chars(:branch(%!analysis));
    self!analysis-calculate-max-branch-depth(:branch(%!analysis));
#   self!stash-analysis;
}

method current-context (Str:D :$context!) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    die 'Illegal context <' ~ $context ~ '>' if $context !~~ / ^ $(CONTEXT-ROOT) /;
    return $context.subst(/ ^ $(CONTEXT-ROOT) '::' /, '');
}

method requires-analysis(Str:D :$current-context) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    return True unless self!analysis-fetch-statistic-by-context(:context($current-context), :statistic<max-branch-attr-name-chars>);
    False;
}

method get-depth-by-context (Str:D :$context is copy) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    return Nil unless %!analysis.elems;
    $context = self.current-context(:$context);
    self!analysis-fetch-statistic-by-context(:$context, :statistic<depth>);
}

method get-max-branch-depth-by-context (Str:D :$context is copy) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    return Nil unless %!analysis.elems;
    $context = self.current-context(:$context);
    self!analysis-fetch-statistic-by-context(:$context, :statistic<max-branch-depth>);
}

method get-max-header-chars-by-context (Str:D :$context is copy) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    return Nil unless %!analysis.elems;
    $context = self.current-context(:$context);
    self!analysis-fetch-statistic-by-context(:$context, :statistic<max-branch-attr-name-chars>);
}

method probe-max-header-chars-by-context (Str:D :$context! is copy, Int:D :$depth!) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    return Nil      unless %!analysis.elems;
    $context        = self.current-context(:$context);
    die             unless my @hierarchy = $context.split('::');
    my %tree = %!analysis;
    for @hierarchy -> $branch {
        die unless %tree<CHILDREN>{$branch}:exists;
        %tree = %tree<CHILDREN>{$branch};
    }
    my $column = 0;
    $column = %tree<STATISTICS><max-local-attr-name-chars> if %tree<STATISTICS><max-local-attr-name-chars>:exists;
    return self!analysis-probe-max-local-attr-name-chars(:%tree, :$column, :$depth, :0shift);
}

method !analysis-probe-max-local-attr-name-chars (:%tree!, Int:D :$column! is copy, Int:D :$depth! is copy, Int:D :$shift! is copy) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD_PRIVATE>;
    $depth--;
    my $proposed-column = 0;
    $proposed-column = (%tree<STATISTICS><max-local-attr-name-chars> + ($shift * self.options.tab-stop)) if %tree<STATISTICS><max-local-attr-name-chars>:exists;
    $column = $proposed-column if $proposed-column > $column;
    $shift++;
    if $depth >= 0 {
        for %tree<CHILDREN>.keys -> $child {
            $proposed-column = self!analysis-probe-max-local-attr-name-chars(:tree(%tree<CHILDREN>{$child}), :$column, :$depth, :$shift);
            $column = $proposed-column if $proposed-column > $column;
        }
    }
    return $column;
}

method !analysis-fetch-statistic-by-context (Str:D :$context!, Str:D :$statistic!) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD_PRIVATE>;
    return Nil unless my @hierarchy = $context.split('::');
    self!analysis-fetch-statistic(:tree(%!analysis), :@hierarchy, :$statistic);
}

method !analysis-fetch-statistic (:%tree!, :@hierarchy!, Str:D :$statistic!) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD_PRIVATE>;
    my $branch;
    if @hierarchy.elems {
        $branch  = shift(@hierarchy);
        return Nil unless %tree<CHILDREN>{$branch}:exists;
        return self!analysis-fetch-statistic(:tree(%tree<CHILDREN>{$branch}), :@hierarchy, :$statistic);
    }
    if %tree<STATISTICS>:exists {
        if %tree<STATISTICS>{$statistic}:exists {
            return %tree<STATISTICS>{$statistic};
        }
    }
    return Nil;
}

method !analysis-calculate-max-branch-depth (:%branch) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD_PRIVATE>;
    %branch<STATISTICS><max-branch-depth> = 0 unless %branch<STATISTICS><max-branch-depth>:exists;
    if %branch<STATISTICS><depth>:exists {
        %branch<STATISTICS><max-branch-depth> = %branch<STATISTICS><depth> if %branch<STATISTICS><depth> > %branch<STATISTICS><max-branch-depth>;
    }
    for %branch<CHILDREN>.keys -> $child {
        if my $child-max-branch-depth = self!analysis-calculate-max-branch-depth(:branch(%branch<CHILDREN>{$child})) {
            if $child-max-branch-depth > %branch<STATISTICS><max-branch-depth> {
                %branch<STATISTICS><max-branch-depth> = $child-max-branch-depth;
            }
        }
    }
    return %branch<STATISTICS><max-branch-depth>;
}

method !analysis-calculate-max-branch-attr-name-chars (:%branch) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD_PRIVATE>;
    %branch<STATISTICS><max-branch-attr-name-chars> = 0 unless %branch<STATISTICS><max-branch-attr-name-chars>:exists;
    if %branch<STATISTICS><max-local-attr-name-chars>:exists {
        %branch<STATISTICS><max-branch-attr-name-chars> = %branch<STATISTICS><max-local-attr-name-chars> if %branch<STATISTICS><max-local-attr-name-chars> > %branch<STATISTICS><max-branch-attr-name-chars>;
    }
    for %branch<CHILDREN>.keys -> $child {
        if my $child-max-branch-attr-name-chars = self!analysis-calculate-max-branch-attr-name-chars(:branch(%branch<CHILDREN>{$child})) {
            if $child-max-branch-attr-name-chars > %branch<STATISTICS><max-branch-attr-name-chars> {
                %branch<STATISTICS><max-branch-attr-name-chars> = $child-max-branch-attr-name-chars;
            }
        }
    }
    return %branch<STATISTICS><max-branch-attr-name-chars>;
}

method analysis-collect-max-local-attr-name-chars (Str:D :$package, Int:D :$max-local-attr-name-chars) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD>;
    my @hierarchy   = $package.split('::');
    my $depth       = @hierarchy.elems;
    %!analysis<STATISTICS><depth> = 0                           unless %!analysis<STATISTICS><depth>:exists;
    %!analysis<CHILDREN>{@hierarchy[0]}<STATISTICS><depth> = 1  unless %!analysis<CHILDREN>{@hierarchy[0]}<STATISTICS><depth>:exists;
    self!analysis-insert-max-local-attr-name-chars(:tree(%!analysis), :@hierarchy, :$max-local-attr-name-chars, :$depth);
}

method !analysis-insert-max-local-attr-name-chars (:%tree!, :@hierarchy!, Int:D :$max-local-attr-name-chars!, Int:D :$depth!) {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name if %*ENV<HIPH_METHOD_PRIVATE>;
    if @hierarchy {
        my $current = shift(@hierarchy);
        %tree<CHILDREN>{$current} = Hash.new unless %tree<CHILDREN>{$current}:exists;
        self!analysis-insert-max-local-attr-name-chars(:tree(%tree<CHILDREN>{$current}), :@hierarchy, :$max-local-attr-name-chars, :$depth);
    }
    else {
        %tree<STATISTICS><max-local-attr-name-chars> = $max-local-attr-name-chars;
        %tree<STATISTICS><depth> = $depth;
    }
}

=finish
