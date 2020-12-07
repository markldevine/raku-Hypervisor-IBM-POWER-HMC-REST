use     URI;
unit    role Hypervisor::IBM::POWER::HMC::REST::Config::Dump:api<1>:auth<Mark Devine (mark@markdevine.com)>;

method dump (Int :$column is copy, Int:D :$depth is copy = 0, Int :$shift = 0) {
    self.config.analysis-commit;
    my $default-depth               = False;
    $default-depth                  = True unless $depth;
    unless $column {
        my $calculated-depth        = self.config.get-depth-by-context(:context(self.^name));
        my $calculated-max-depth    = self.config.get-max-branch-depth-by-context(:context(self.^name));
        my $relative-depth          = 0;
        with $calculated-max-depth {
            $relative-depth         = $calculated-max-depth - $calculated-depth;
        }
        $relative-depth             = 1 if $relative-depth <= 0;
        $depth                      = $relative-depth if $depth <= 0;
        $depth                      = $relative-depth if $depth > $relative-depth;
        $column                     = self!dump-get-column-by-context(:context(self.^name), :$depth);
        $column++;
    }
    $depth++                        if $default-depth;  # recalibrate now that the column is right for the depth tests below
    self.init                       unless self.initialized;
    self.load                       unless self.loaded;
    self.dump-tree(:$column, :$depth, :$shift);
}

method dump-tree (Int:D :$column!, Int:D :$depth! is copy, Int:D :$shift = 0) {
    my %local-attrs = self.^attributes(:local).map({ $_.name => $_.package });
    for self.^attributes -> $attr {
        next        if %local-attrs{$attr.name}:exists && !(%local-attrs{$attr.name} === $attr.package);
        next        unless $attr.has_accessor;
        my $name    = $attr.name.substr(2);
        given $attr.type {
            when Str {  
                my $v = $attr.get_value(self);
                if $v {
                    self.config.dump.post: $v, :header($name), :$column, :$shift;
                }
            }
            when URI {
                my $v = $attr.get_value(self);
                if $v {
                    self.config.dump.post: $v.Str, :header($name), :$column, :$shift;
                }
            }
            when DateTime {
                my $v = $attr.get_value(self);
                if $v {
                    self.config.dump.post: $v.Str, :header($name), :$column, :$shift;
                }
            }
            when Positional[Str]  {
                self.config.dump.post: $attr.get_value(self), :header($name), :$column, :$shift;
            }
            when Positional[URI]  {
                self.config.dump.post: $attr.get_value(self), :header($name), :$column, :$shift;
            }
            when Positional {
                my @objs = $attr.get_value(self);
                for @objs -> $obj {
                    if $depth >= 1 {
                        if $obj.DEFINITE && $obj.can('dump-tree') {
                            self.config.dump.post: :banner($name), :$column, :$shift;
                            $obj.dump-tree(:$column, :depth($depth - 1), :shift($shift + 1));
                        }
                    }
                }
            }
            when Associative {
                my %objs = $attr.get_value(self);
                given %objs.values.first.WHAT {
                    when Str {
                        self.config.dump.post: :banner($name), :$column, :$shift;
                        for %objs.kv -> $k, $v {
                            self.config.dump.post: $v, :header($k), :$column, :shift($shift + 1);
                        }
                    }
                    when .^name ~~ / ^ 'Hypervisor::IBM::POWER::HMC::REST::' / {
                        if $depth >= 1 {
                            my @object-list = %objs.keys.sort;
                            for  %objs.keys.sort -> $key {
                                self.config.dump.post: :banner(%objs.values.first.^name.subst(/ ^ .+'::' /, '')), :$column, :$shift;
                                my $obj = %objs{$key};
                                if $obj.DEFINITE && $obj.can('dump-tree') {
                                    $obj.dump-tree(:$column, :depth($depth - 1), :shift($shift + 1));
                                }
                            }
                        }
                    }
                }
            }
            when .^name ~~ / ^ 'Hypervisor::IBM::POWER::HMC::REST::' / {
                if $depth >= 1 {
                    my $obj = $attr.get_value(self);
                    if $obj.DEFINITE && $obj.can('dump-tree') {
                        self.config.dump.post: :banner($name), :$column, :$shift;
                        $obj.dump-tree(:$column, :depth($depth - 1), :shift($shift + 1));
                    }
                }
            }
#           default { self.config.dump.post: $name; }
        }
    }
}

method !dump-get-column-by-context (Str :$context, Int:D :$depth!) {
    return self.config.probe-max-header-chars-by-context(:context(self.^name), :$depth);
}

=finish
