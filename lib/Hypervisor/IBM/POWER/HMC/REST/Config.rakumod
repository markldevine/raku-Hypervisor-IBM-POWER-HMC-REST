use     File::Directory::Tree;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Analysis;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Optimization;
need    Hypervisor::IBM::POWER::HMC::REST::Config::Options;
need    Hypervisor::IBM::POWER::HMC::REST::Logon::X-API-Session;
need    Hypervisor::IBM::POWER::HMC::REST::Messaging::DUMP;
need    Hypervisor::IBM::POWER::HMC::REST::Messaging::DIAG;
need    Hypervisor::IBM::POWER::HMC::REST::Messaging::INFO;
need    Hypervisor::IBM::POWER::HMC::REST::Messaging::NOTE;
use     JSON::Fast;
use     POSIX::getaddrinfo :Get-Addr-Info-IPV4-STREAM-IPAddrs;
use     Term::Choose :choose, :choose-multi;
use     URI::Escape;
unit    class Hypervisor::IBM::POWER::HMC::REST::Config:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::Config::Analysis
            does Hypervisor::IBM::POWER::HMC::REST::Config::Optimization;

has     Hypervisor::IBM::POWER::HMC::REST::Config::Options      $.options is required;
has     Str                                                     $!root-directory;
has     Str                                                     $!cache-directory;
has     Str                                                     $!consumers-directory;
has     Str                                                     $!consumer-active-directory;
has     Str                                                     $!consumer-missing-directory;
has     Str                                                     $!credentials-directory;
#as     Str                                                     $!analysis-path;
has     Str                                                     $!diagnostics-path;
has     Str                                                     $!hmcs-path;
has     Str                                                     $!formats-path;
has     Str                                                     $!maintenance-path;
has     Str                                                     $!messaging-path;
has     Str                                                     $!optimizations-path;
has     Str                                                     $.pid-path;
has     Int                                                     %!diagnostics;
has                                                             %!formats;
has                                                             %!messaging;
has     Hash                                                    %!hmcs;
has                                                             %!optimizations;
has     Str                                                     $!hmc-candidate;
has     Str                                                     $!user-id-candidate;
has     Bool                                                    $!cache;
has     Str                                                     $!hmc;
has     Str                                                     $!user-id;
has     Bool                                                    $.optimize;
has     Hypervisor::IBM::POWER::HMC::REST::Messaging::DUMP      $.dump;
has     Hypervisor::IBM::POWER::HMC::REST::Messaging::DIAG      $.diag;
has     Hypervisor::IBM::POWER::HMC::REST::Messaging::INFO      $.info;
has     Hypervisor::IBM::POWER::HMC::REST::Messaging::NOTE      $.note;
has     Hypervisor::IBM::POWER::HMC::REST::Logon::X-API-Session $.session-manager;

constant SUBDIRNAME     = '.hiph';
constant DIAGNOSTICS    = set < 
                            HIPH_DDT
                            HIPH_ETL_BRANCHES
                            HIPH_ETL_BRANCH
                            HIPH_ETL_TEXT_EXTRACT
                            HIPH_ETL_TEXT_TRANSFORM
                            HIPH_ETL_TEXTS
                            HIPH_ETL_LINKS_URIS
                            HIPH_ETL_HREF
                            HIPH_FETCH
                            HIPH_INIT
                            HIPH_LOAD
                            HIPH_METHOD
                            HIPH_METHOD_PRIVATE
                            HIPH_NYI
                            HIPH_PARSE
                            HIPH_SUBMETHOD
                            HIPH_THREAD_START
                          >;

submethod TWEAK {
    self!resolve-root-directory;
    self!resolve-consumers;
    if self.options.unconfig {
#       note .exception.message without $!analysis-path.IO.unlink;
        note .exception.message without $!formats-path.IO.unlink;
        note .exception.message without $!messaging-path.IO.unlink;
        note .exception.message without $!diagnostics-path.IO.unlink;
        note .exception.message without $!optimizations-path.IO.unlink;
        note .exception.message without $!hmcs-path.IO.unlink;
    }
    self!resolve-pid;
    self!resolve-cache;
#   self!resolve-analysis;
    self!resolve-formats;
    self!resolve-messaging;
    self!resolve-diagnostics;
    self!resolve-optimizations;
    self!resolve-hmcs;
    $!session-manager = Hypervisor::IBM::POWER::HMC::REST::Logon::X-API-Session.new(
        :$!cache,
        :$!cache-directory,
        :$!credentials-directory,
        :hmc($!hmc-candidate),
        :off-line(self.options.off-line),
        :user-id($!user-id-candidate),
    );
    self;
}

method !resolve-pid () {
    if $!pid-path.IO.f {
        my $pid;
        given $!pid-path.IO.open(:r) {
            .lock :shared;
            $pid = .slurp;
            .close;
        }
        my $ps          = run 'ps', '-p', $pid, '-o', 'tty,args', :out;
        my @pid-records = $ps.out.slurp(:close).lines;
        if @pid-records.elems <= 1 {
            note .exception.message without $!pid-path.IO.unlink;
        }
        else {
            my @ps-fields = @pid-records[1].split(/\s+/, 2);
            note 'PID ' ~ $pid ~ ' currently using this API on ' ~ @ps-fields[0] ~ " in \n\n\t" ~ @ps-fields[1] ~ "\n\nTry again later...";
            exit 1;
        }
    }
    given $!pid-path.IO.open(:x) {
        .lock;
        .spurt($*PID);
        .close;
    }
    %*ENV<PID-PATH> = $!pid-path;
}

method !resolve-cache () {
    $!cache = self.options.cache;
    $!cache = True if self.options.off-line;
}

#method !resolve-analysis () {
#    self!retrieve-analysis;
#}

#method !retrieve-analysis () {
#    if $!analysis-path.IO.f && ! $!analysis-path.IO.z {
#        given $!analysis-path.IO.open {
#            .lock: :shared;
#            %!analysis = from-json(.slurp);
#            .close;
#        }
#    }
#}

#method !stash-analysis () {
##%%% Add Bool $!analyzed to determine if it is necessary to stash a new analysis
##   if $!analyzed {
#        given $!analysis-path.IO.open(:w) {
#            .lock;
#            .spurt: to-json(%!analysis);
#            .close;
#        }
##   }
#}

method !resolve-formats () {
    %!formats<headers>                                                              = True;
    %!formats<quiet>                                                                = False;
    %!formats<silence>                                                              = False;
    %!formats<tab-stop>                                                             = 1;
    %!formats<verbose>                                                              = False;
    %!formats<DUMP-TTY-header-markup>                                               = '';
    %!formats<DUMP-TTY-payload-markup>                                              = '';
    %!formats = from-json(slurp($!formats-path))                                    if $!formats-path.IO.f;
    self.options.set-headers(%!formats<headers>)                                    without self.options.headers;
    self.options.set-quiet(%!formats<quiet>)                                        without self.options.quiet;
    self.options.set-silence(%!formats<silence>)                                    without self.options.silence;
    self.options.set-tab-stop(%!formats<tab-stop>)                                  without self.options.tab-stop;
    self.options.set-verbose(%!formats<verbose>)                                    without self.options.headers;
    self.options.set-DUMP-TTY-header-markup(%!formats<DUMP-TTY-header-markup>)      without self.options.DUMP-TTY-header-markup;
    self.options.set-DUMP-TTY-payload-markup(%!formats<DUMP-TTY-payload-markup>)    without self.options.DUMP-TTY-payload-markup;
    %!formats<headers>                                                              = self.options.headers;
    %!formats<quiet>                                                                = self.options.quiet;
    %!formats<silence>                                                              = self.options.silence;
    %!formats<tab-stop>                                                             = self.options.tab-stop;
    %!formats<verbose>                                                              = self.options.headers;
    %!formats<DUMP-TTY-header-markup>                                               = self.options.DUMP-TTY-header-markup;
    %!formats<DUMP-TTY-payload-markup>                                              = self.options.DUMP-TTY-payload-markup;
    spurt($!formats-path, to-json(%!formats));
}

method !resolve-messaging () {

#%%%    Use $!messaging-path & %!messaging for persistence...  (NYI)

    $!dump   = Hypervisor::IBM::POWER::HMC::REST::Messaging::DUMP.new(:$!options);
    $!dump.subscribe(:destination<DUMP-TTY>);
    $!diag   = Hypervisor::IBM::POWER::HMC::REST::Messaging::DIAG.new(:$!options);
    $!diag.subscribe(:destination<DIAG-TTY>);
    $!info   = Hypervisor::IBM::POWER::HMC::REST::Messaging::INFO.new(:$!options);
    $!info.subscribe(:destination<INFO-TTY>);
    $!note   = Hypervisor::IBM::POWER::HMC::REST::Messaging::NOTE.new(:$!options);
    $!note.subscribe(:destination<NOTE-TTY>);
}

method !resolve-diagnostics () {
    if self.options.diags {
        note .exception.message without $!diagnostics-path.IO.unlink;
        %!diagnostics = ();
        if my @user-input = choose-multi(DIAGNOSTICS.keys.sort, :info(" ←↑→↓ to navigate\n ␣ to select\n ↵ when complete\n 'q' to quit\n"), :2layout, :prompt('␣ spacebar to select options')) {
            for @user-input -> $list {
                for $list.list -> $d {
                    %!diagnostics{$d} = 1;
                }
            }
        }
    }
    else {
        if $!diagnostics-path.IO.f {
            %!diagnostics = from-json(slurp($!diagnostics-path));
        }
    }
    for DIAGNOSTICS.keys -> $diag {
        if %!diagnostics{$diag}:exists {
            %*ENV{$diag} = 1;
        }
        else {
            %*ENV{$diag} = 0;
        }
    }
    spurt $!diagnostics-path, to-json(%!diagnostics);
}

method !stash-hmcs () {
    spurt($!hmcs-path, to-json(%!hmcs));
}

method !retrieve-hmcs () {
    if $!hmcs-path.IO.f {
        %!hmcs = from-json(slurp($!hmcs-path));
    }
}

method !valid-hmc-candidate (Str $user-input is copy = '') {
    unless $*IN.t && $*OUT.t {
        self.note.post: 'Unable to determine HMC in non-interactive mode';
        exit 1;
    }
    loop {
        while $user-input !~~ / ^ <alpha> <alnum>+ $ / {
            self.note.post: $user-input ~ ' is not a valid HMC name.' if $user-input;
            $user-input = prompt 'Enter HMC hostname> ';
        }
        my @ipaddrs = Get-Addr-Info-IPV4-STREAM-IPAddrs($user-input);
        unless @ipaddrs.elems {
            self.note.post: 'Cannot resolve ' ~ $user-input ~ ' into any IP address.';
            $user-input = '';
            next;
        }
        unless run('ping', '-c', 1, $user-input, :out(False), :err(False)).so {
            self.note.post: 'Ping ' ~ $user-input ~ ' failed!';
            $user-input = '';
            next;
        }
        return $user-input;
    }
}

method !valid-user-id-candidate (Str:D $user-input is copy = '') {
    if ! $user-input && ! ($*IN.t && $*OUT.t) {
        self.note.post: 'Unable to determine userid in non-interactive mode';
        exit 1;
    }
    while $user-input !~~ / ^ <alpha> <alnum>+ $ / {
        put "\n    Shared user account 'hscroot' is always available. The better practice is";
        put '    to use a personal user account registered on the HMC with the appropriate';
        put "    roles assigned.\n\n";
        $user-input = prompt 'Enter user account to connect to HMC ' ~ $!hmc-candidate ~ '> ';
    }
    $!user-id-candidate = $user-input;
}

method !resolve-hmcs () {
    self!retrieve-hmcs;
    if self.options.hmc {
        if %!hmcs{self.options.hmc}:exists {
            $!hmc-candidate = self.options.hmc;
        }
        else {
            $!hmc-candidate = self!valid-hmc-candidate(self.options.hmc);
        }
    }
    else {
        if %!hmcs.elems {
            if %!hmcs.elems == 1 {
                $!hmc-candidate = %!hmcs.keys.Str
            }
            else {
                unless $*IN.t && $*OUT.t {
                    self.note.post: 'Unable to determine HMC in non-interactive mode';
                    exit 1;
                }
                $!hmc-candidate = '';
                while $!hmc-candidate !~~ / ^ <alpha> <alnum>+ $ / {
                    $!hmc-candidate = choose(%!hmcs.keys.sort, :info(''), :2layout, :prompt('Select a previously connected HMC'));
                }
            }
        }
        else {
            $!hmc-candidate = self!valid-hmc-candidate('');
        }
    }
    if self.options.user-id {
        $!user-id-candidate = self!valid-user-id-candidate(self.options.user-id);
    }
    else {
        if %!hmcs{$!hmc-candidate}:exists {
            if %!hmcs{$!hmc-candidate}.elems {
                if %!hmcs{$!hmc-candidate}.elems == 1 {
                    $!user-id-candidate = %!hmcs{$!hmc-candidate}.keys.Str;
                }
                else {
                    unless $*IN.t && $*OUT.t {
                        self.note.post: 'Unable to determine HMC in non-interactive mode';
                        exit 1;
                    }
                    $!user-id-candidate = '';
                    while $!user-id-candidate !~~ / ^ <alpha> <alnum>+ $ / {
                        $!user-id-candidate = choose(%!hmcs{$!hmc-candidate}.keys.sort, :info(''), :2layout, :prompt('Select a previously connected user account'));
                    }
                }
            }
            else {
                $!user-id-candidate = self!valid-user-id-candidate('');
            }
        }
        else {
            $!user-id-candidate = self!valid-user-id-candidate('');
        }
    }
}

method promote-candidates {
    return if %!hmcs{$!hmc-candidate}{$!user-id-candidate}:exists;
    %!hmcs{$!hmc-candidate}{$!user-id-candidate} = 1;
    self!stash-hmcs;
}

method !resolve-consumers () {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ' - NYI' if %*ENV<HIPH_NYI>;
    my $last-maintenance-instance = now;
    $last-maintenance-instance = slurp($!maintenance-path) if $!maintenance-path.IO.f;
    return if $last-maintenance-instance.Rat >= (now - (24 * 60 * 60)).Rat;

    my $consumer-active-base-directory  = $!consumers-directory ~ '/active';
    my $consumer-missing-base-directory = $!consumers-directory ~ '/missing';

    for $consumer-active-base-directory.IO.dir -> $dir-ent {
        my $encoded-path    = $dir-ent.subst(/ ^ "$consumer-active-base-directory" '/' /, '');
        my $decoded-path    = uri_unescape($encoded-path);
        next        if $decoded-path.IO.e;
        rename($dir-ent, $consumer-missing-base-directory ~ '/' ~ $encoded-path);
    }

    for $consumer-missing-base-directory.IO.dir -> $dir-ent {
        my $encoded-path    = $dir-ent.subst(/ ^ "$consumer-missing-base-directory" '/' /, '');
        my $decoded-path    = uri_unescape($encoded-path);
        if $decoded-path.IO.e {
            if "$consumer-active-base-directory/$encoded-path".IO.d {
                if "$consumer-active-base-directory/$encoded-path".IO.modified > "$consumer-missing-base-directory/$encoded-path".IO.modified {
                    rmtree($dir-ent);
                }
                else {
                    rmtree($consumer-active-base-directory ~ '/' ~ $encoded-path);
                    rename($dir-ent, $consumer-active-base-directory ~ '/' ~ $encoded-path);
                }
            }
            else {
                rename($dir-ent, $consumer-active-base-directory ~ '/' ~ $encoded-path);
            }
        }
        else {
            if $dir-ent.IO.modified < (now - (30 * 24 * 60 * 60)) {
                rmtree($dir-ent);
            }
        }
    }
    spurt($!maintenance-path, now.Rat);
}

method !resolve-optimizations () {
    self.diag.post: self.^name ~ '::' ~ &?ROUTINE.name ~ ' - NYI' if %*ENV<HIPH_NYI>;
    if $!optimizations-path.IO.f {
        %!optimizations = from-json(slurp($!optimizations-path));
    }
#   %*ENV<HIPH_OPTIMIZE>    = 0;                                                # optimizations may only be activated from within (--optimize)
#   maitain %profile<$PROGRAM-NAME.IO.absolute><m>
#   if %profile<$PROGRAM-NAME.IO.absolute><m> < $PROGRAM-NAME.IO.modified, drop profile map & carp
#   if $PROGRAM-NAME.IO.modified > %!profile.modified, drop profile map and carp
}

method !resolve-root-directory () {
    my $rd-set              = False;
    if self.options.root-directory {
        $!root-directory    = self.options.root-directory;
        $rd-set             = True;
    }
    else {
        $!root-directory    = $*HOME ~ '/' ~ SUBDIRNAME;
    }
    my $private-dir     = False;
# incorporate %*ENV{HIPH_ROOT_DIRECTORY} (2nd precedence), if set, unless '--root-directory=...' command-line switch sent (highest precedence)
    if %*ENV<HIPH_ROOT_DIRECTORY>:exists {
        $!root-directory = %*ENV<HIPH_ROOT_DIRECTORY> unless $rd-set;
    }
    unless $!root-directory.ends-with('/' ~ SUBDIRNAME) {
        $!root-directory ~= '/' ~ SUBDIRNAME;
        note "Appending '/' ~ SUBDIRNAME to the specified root-directory. Now: " ~ $!root-directory;
    }
    $private-dir        = True if $!root-directory  ~~ / ^ "$*HOME" /;
    unless $!root-directory.IO.d {
        die 'mkdir ' ~ $!root-directory ~ ' failed!' unless mkdir $!root-directory;
        unless $private-dir {
            note qq:to/ENDOFRECOMMENDATION/;

Recommendation:

    Because you've chosen a non-default location for "--root-directory", you are
    advised to PERSISTENTLY set the "HIPH_ROOT_DIRECTORY" environment variable to:
 
        $!root-directory
 
    in the appropriate shell initialization file(s). This convenience will allow you
    to avoid having to specify the '--root-directory=' switch for every execution
    of Hypervisor::IBM::POWER::HMC scripts.

ENDOFRECOMMENDATION
        }
    }
    if $private-dir {
        if $!root-directory.IO.mode != 0o700 {
            die 'chmod 0o700 ' ~ $!root-directory ~ ' failed!' unless $!root-directory.IO.chmod('0o700');
        }
    }
    else {
        if $!root-directory.IO.mode != 0o3777 {
            die 'chmod 0o3777 ' ~ $!root-directory ~ ' failed!' unless $!root-directory.IO.chmod('0o3777');
        }
    }
# conventional directory structure based on package
    my $middle-path         = 'Hypervisor::IBM::POWER::HMC'.trans('::' => '/', :squash);
    die 'mkdir ' ~ $!root-directory ~ '/' ~ $middle-path ~ ' failed!' unless mkdir $!root-directory ~ '/' ~ $middle-path;
    my @dirs                = $middle-path.split(/\//);
    my $p                   = $!root-directory;
    for @dirs -> $dir {
        $p ~= '/' ~ $dir;
        if $private-dir {
            if $p.IO.mode != 0o700 {
                die 'chmod 0o700 ' ~ $p ~ ' failed!' unless $p.IO.chmod('0o700');
            }
        }
        else {
            if $p.IO.mode != 0o2770 {
                die 'chmod 0o2770 ' ~ $p ~ ' failed!' unless $p.IO.chmod('0o2770');
            }
        }
    }
    $!root-directory       ~= '/' ~ $middle-path;
#   $!analysis-path         = $!root-directory ~ '/' ~ 'analysis.json';
    $!maintenance-path      = $!root-directory ~ '/' ~ '.maintenance';
    $!cache-directory       = $!root-directory ~ '/' ~ '.cache';
    unless $!cache-directory.IO.d {
        die 'mkdir ' ~ $!cache-directory ~ ' failed!' unless mkdir $!cache-directory;
    }
    if $private-dir {
        if $!cache-directory.IO.mode != 0o700 {
            die 'chmod 0o700 ' ~ $!cache-directory ~ ' failed!' unless $!cache-directory.IO.chmod('0o700');
        }
    }
    else {
        if $!cache-directory.IO.mode != 0o2770 {
            die 'chmod 0o2770 ' ~ $!cache-directory ~ ' failed!' unless $!cache-directory.IO.chmod('0o2770');
        }
    }
# consumers
    $!consumers-directory = $!root-directory ~ '/' ~ '.consumers';
    unless $!consumers-directory.IO.d {
        die 'mkdir ' ~ $!consumers-directory ~ ' failed!' unless mkdir $!consumers-directory;
    }
    if $private-dir {
        if $!consumers-directory.IO.mode != 0o700 {
            die 'chmod 0o700 ' ~ $!consumers-directory ~ ' failed!' unless $!consumers-directory.IO.chmod('0o700');
        }
    }
    else {
        if $!consumers-directory.IO.mode != 0o2770 {
            die 'chmod 0o2770 ' ~ $!consumers-directory ~ ' failed!' unless $!consumers-directory.IO.chmod('0o2770');
        }
    }
# active subdirectory
    my $consumer-active-base-directory = $!consumers-directory ~ '/active';
    unless $consumer-active-base-directory.IO.d {
        die 'mkdir ' ~ $consumer-active-base-directory ~ ' failed!' unless mkdir $consumer-active-base-directory;
    }
    if $private-dir {
        if $consumer-active-base-directory.IO.mode != 0o700 {
            die 'chmod 0o700 ' ~ $consumer-active-base-directory ~ ' failed!' unless $consumer-active-base-directory.IO.chmod('0o700');
        }
    }
    else {
        if $consumer-active-base-directory.IO.mode != 0o2770 {
            die 'chmod 0o2770 ' ~ $consumer-active-base-directory ~ ' failed!' unless $consumer-active-base-directory.IO.chmod('0o2770');
        }
    }
    $!consumer-active-directory     = $consumer-active-base-directory ~ '/' ~ uri_escape($*PROGRAM-NAME.IO.absolute.Str);
# missing subdirectory
    my $consumer-missing-base-directory = $!consumers-directory ~ '/missing';
    unless $consumer-missing-base-directory.IO.d {
        die 'mkdir ' ~ $consumer-missing-base-directory ~ ' failed!' unless mkdir $consumer-missing-base-directory;
    }
    if $private-dir {
        if $consumer-missing-base-directory.IO.mode != 0o700 {
            die 'chmod 0o700 ' ~ $consumer-missing-base-directory ~ ' failed!' unless $consumer-missing-base-directory.IO.chmod('0o700');
        }
    }
    else {
        if $consumer-missing-base-directory.IO.mode != 0o2770 {
            die 'chmod 0o2770 ' ~ $consumer-missing-base-directory ~ ' failed!' unless $consumer-missing-base-directory.IO.chmod('0o2770');
        }
    }
    $!consumer-missing-directory     = $consumer-missing-base-directory ~ '/' ~ uri_escape($*PROGRAM-NAME.IO.absolute.Str);
# if has been missing, now it has been found -- restore it
    if $!consumer-missing-directory.IO.d && ! $!consumer-active-directory.IO.e {
        die "rename $!consumer-missing-directory $!consumer-active-directory failed!" unless rename $!consumer-missing-directory, $!consumer-active-directory;
    }
# resume assuring $!consumer-active-directory
    unless $!consumer-active-directory.IO.d {
        die 'mkdir ' ~ $!consumer-active-directory ~ ' failed!' unless mkdir $!consumer-active-directory;
    }
    if $private-dir {
        if $!consumer-active-directory.IO.mode != 0o700 {
            die 'chmod 0o700 ' ~ $!consumer-active-directory ~ ' failed!' unless $!consumer-active-directory.IO.chmod('0o700');
        }
    }
    else {
        if $!consumer-active-directory.IO.mode != 0o2770 {
            die 'chmod 0o2770 ' ~ $!consumer-active-directory ~ ' failed!' unless $!consumer-active-directory.IO.chmod('0o2770');
        }
    }
    $!diagnostics-path      = $!consumer-active-directory ~ '/diagnostics.json';
    $!formats-path          = $!consumer-active-directory ~ '/formats.json';
    $!hmcs-path             = $!consumer-active-directory ~ '/hmcs.json';
    $!messaging-path        = $!consumer-active-directory ~ '/messaging.json';
    $!optimizations-path    = $!consumer-active-directory ~ '/optimizations.json';
# credentials
    $!credentials-directory = $!root-directory ~ '/' ~ '.credentials';
    unless $!credentials-directory.IO.d {
        die 'mkdir ' ~ $!credentials-directory ~ ' failed!' unless mkdir $!credentials-directory;
    }
    if $private-dir {
        if $!credentials-directory.IO.mode != 0o700 {
            die 'chmod 0o700 ' ~ $!credentials-directory ~ ' failed!' unless $!credentials-directory.IO.chmod('0o700');
        }
    }
    else {
        if $!credentials-directory.IO.mode != 0o2770 {
            die 'chmod 0o2770 ' ~ $!credentials-directory ~ ' failed!' unless $!credentials-directory.IO.chmod('0o2770');
        }
    }
# PID
    $!pid-path = $!consumer-active-directory ~ '/pid';
# reconcile sources
    if %*ENV<HIPH_ROOT_DIRECTORY>:exists {
        my $env-var = %*ENV<HIPH_ROOT_DIRECTORY>;
        $env-var   ~= '/' ~ SUBDIRNAME unless $env-var.ends-with('/' ~ SUBDIRNAME);
        if $env-var ne $!root-directory {
            note qq:to/ENDOFROOTMISMATCH/;
 
\%*ENV<HIPH_ROOT_DIRECTORY> $env-var
≠                          ≠
\$!root-directory           $!root-directory
 
Either unset or edit (requires logout/login) the HIPH_ROOT_DIRECTORY environment
variable to resolve this conflict.

ENDOFROOTMISMATCH
            die 'Aborting until resolved';
        }
    }
    $!root-directory;
}

=finish
