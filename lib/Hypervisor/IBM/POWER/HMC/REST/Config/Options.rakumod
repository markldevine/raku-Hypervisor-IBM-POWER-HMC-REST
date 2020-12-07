use     Term::Choose :choose, :choose-multi;
use     Terminal::ANSIColor;
unit    class Hypervisor::IBM::POWER::HMC::REST::Config::Options:api<1>:auth<Mark Devine (mark@markdevine.com)>;

subset  HMC     where * ~~ / ^ <alpha> <alnum>+ $ /;
subset  UserId  where * ~~ / ^ <alpha> <alnum>+ $ /;

# Initialization
has     Bool    $.help                  = False;
has     Bool    $.explain               = False;
has     HMC     $.hmc;
has     Bool    $.off-line              = False;
has     Str     $.root-directory;
has     Bool    $.unconfig;
has     UserId  $.user-id;

# Options

#has    Int     $.batch                 = 0;
#%%%
#   $!batch                             = self.options.batch;
#use     Linux::Cpuinfo;
#   my $num-cpus                        = Linux::Cpuinfo.new.num-cpus;
#   $!batch                             = $num-cpus if self.batch && self.batch > $num-cpus;
#   $!batch                             = $num-cpus unless self.batch;

has     Bool    $.cache                 = False;
has     Bool    $.colors                = False;
has     Bool    $.diags                 = False;
has     Bool    $.optimize              = False;

# Format controls

has     Bool    $.headers;
has     Bool    $.quiet;
has     Int     $.screen-width          = 80;
has     Bool    $.silence;
has     Int     $.tab-stop;
has     Bool    $.verbose;

# Color palette

has     Str     $.DUMP-TTY-header-markup;
has     Str     $.DUMP-TTY-payload-markup;

submethod TWEAK {
    my @unknowns;
    for @*ARGS {
        my $switch = m/^ '--' (.+) '=' .+ $ || ^ '--' (.+) $ /;
        @unknowns.push: $switch[0].Str unless self.can($switch[0].Str);
    }
    if @unknowns.elems {
        note colored('Unfamiliar option', 'red') ~ ': ' ~ colored($_, 'red inverse') for @unknowns;
        $!help = True;
    }
    if self.explain {
        put q:to/ENDOFEXPLANATION/;

The purpose of the Hypervisor::IBM::POWER::HMC (client-side) API is to
provide an interface to IBM's POWER REST API (server-side). This client-
side API provides classes/methods which match the structure of the
XML provided by IBM. Composing scripts with these tools is intuitive,
considering the significant amount of data and expansive hierarchy.

At its core, facilities are provided that retrieve individual datum
within the hierarchy. There is also a convenience dump() method at
every level. This method will beautify and align dumps to make it
easier on the human eye. dump() will output all data structures from
the invoking object and all of it's children. For example,

    my $hmc = Hypervisor::IBM::POWER::HMC.new;
    put $hmc.ManagementConsole.ProcConfiguration.dump;
        # Architecture attribute
        # ModelName attribute
        # NumberOfProcessors attribute
    put $hmc.ManagementConsole.dump;
        # ManagementConsole's attributes
        #   MachineTypeModelAndSerialNumber's attributes
        #   MemConfiguration's attributes
        #   NetworkInterfaces' attributes
        #     ManagementConsoleNetworkInterface's attributes
        #   ProcConfiguration's attributes
        #   VersionInfo' attributes

Any script that uses Hypervisor::IBM::POWER::HMC will store it's
configuration settings in the user's home directory. Because
configuration is being written, separation, synchronization & locks
are in place so that one script doesn't smash what another script
saves.

All instances (different scripts) will share a common analysis of the
data tree collected by the API. This helps determining where to set the
column when dumping data at different points in the tree.

Each instance will maintain its own history and customizations. If a
user makes a script called SRIOV-report, which HMC(s) it connects to,
with which user-id(s) for those HMC(s), dump colors, dump tab-stops,
diagnostics, etc. will be preserved and consulted during subsequent
runs. If the user copies the SRIOV-report to SRIOV-hmc2, then SRIOV-hmc2
will create and maintain its own history and customizations. (Don't be
surprised when the copied script starts with defaults.) User's can lock
in behaviors to a particular script (HMC to connect, userid, outputs,
etc.) for multiple scenarios.

ENDOFEXPLANATION
        exit 0;
    }
    usage()         if self.help;
    my $try-width   = try { run('tput', 'cols', :out).out.slurp-rest.trim.Int; }
    $!screen-width  = $try-width if $try-width;

#   if user asked for optimization and no profile exists,
#       %*ENV<HIPH_PROFILING> = 1
#       note 'profile will be constructed now. optimization will be functional on subsequent runs'
#       note 'profile will be constructed now. optimization will be functional on subsequent runs'

### Format controls -- sort out what the user sent 


# these could have been sent by the user -- make sure to mark them as immutable if so
    $!quiet                 = True if self.silence;                                                 # %%%
    $!silence               = False;                                                                # %%%

### if --color-palette, provide an interface
# if user makes selections, make sure that they persist
    self.palette-menu()     if self.colors;
}

constant PALETTE-COLORS         = set <black red green yellow blue magenta cyan white>;
constant PALETTE-BACKGROUNDS    = set <on_black on_red on_green on_yellow on_blue on_magenta on_cyan on_white>;
constant PALETTE-EFFECTS        = set <bold italic underline inverse>;

method palette-menu () {
    my $editing                 = True;
    my @palette-backgrounds;
    my $header-markup;
    my $header-color;
    my $header-background;
    my $header-effects;
    my $payload-markup;
    my $payload-color;
    my @payload-effects;
    my $payload-background;
    my &redraw                  = sub {
        $header-markup          = $header-color;
        $header-markup         ~= ' ' ~ $header-background  if $header-background;
        $payload-markup         = $payload-color;
        $payload-markup        ~= ' ' ~ $payload-background  if $payload-background;
        $payload-markup        ~= ' ' ~ @payload-effects.join(' ') if @payload-effects.elems;
        run 'clear';
        print "\n\n" ~ ' ' x 26 ~ colored('COLOR PALETTE', 'black on_white bold underline') ~ "\n\n\n";
        if $header-markup {
            print ' ' x 8  ~ colored('Header String', $header-markup ~ ' bold') ~ '   ' ~ colored('value string', $payload-markup);
            print ' ' x 10  ~ colored('Header String', $header-markup ~ ' bold underline') ~ "\n";
        }
        else {
            print ' ' x 8  ~ 'Header String' ~ '   ' ~ colored('value string', $payload-markup);
            print ' ' x 10  ~ 'Header String' ~ "\n";
        }
        print ' ' x 46 ~ colored('value string 1', $payload-markup) ~ "\n";
        print ' ' x 46 ~ colored('value string 2', $payload-markup) ~ "\n";
        print ' ' x 46 ~ colored('value string 3', $payload-markup) ~ "\n";
        print "\n\n\n";
    }
    while $editing {
        $header-color           = '';
        $header-background      = '';
        $header-effects         = '';
        $payload-color          = '';
        @payload-effects        = [];
        $payload-background     = '';
        my $answer;

        &redraw();
        $answer                 = choose(PALETTE-COLORS.keys.sort, :info(' ' x 24 ~ 'Header Color'), :1layout, :prompt("\n ← → to navigate, ↵ to select highlighted item , 'q' for no change\n"));
        if $answer {
            $header-color       = $answer;
        }
        else {
            $header-color       = ''
        }
        
        &redraw();
        @palette-backgrounds    = PALETTE-BACKGROUNDS.keys.sort.grep: {! / ^ on_"$header-color" $ /};
        $answer                 = choose(@palette-backgrounds, :info(' ' x 24 ~ 'Header Background'), :1layout, :prompt("\n ← → to navigate, ↵ to select highlighted item , 'q' for no change\n"));
        if $answer {
            $header-background  = $answer;
        }
        else {
            $header-background  = '';
        }

        &redraw();
        $answer                 = choose(PALETTE-COLORS.keys.sort, :info(' ' x 24 ~ 'Value Color'), :1layout, :prompt("\n ← → to navigate, ↵ to select highlighted item , 'q' for no change\n"));
        if $answer {
            $payload-color      = $answer;
        }
        else {
            $payload-color      = '';
        }


        &redraw();
        @palette-backgrounds    = PALETTE-BACKGROUNDS.keys.sort.grep: {! / ^ on_"$payload-color" $ /};
        $answer                 = choose(@palette-backgrounds, :info(' ' x 24 ~ 'Value Background'), :1layout, :prompt("\n ← → to navigate, ↵ when selections complete, 'q' for no change\n"));
        if $answer {
            $payload-background = $answer;
        }
        else {
            $payload-background = '';
        }

        &redraw();
        my @answer;
        @answer                 = ();
        @answer                 = choose-multi(PALETTE-EFFECTS.keys.sort, :info(' ' x 24 ~ 'Value Effects'), :1layout, :prompt("\n ← → to navigate, ␣ <Spacebar> on highlighted items to select, ↵ to accept selection(s)\n"));
        if @answer.elems {
            @payload-effects    = @answer;
        }
        else {
            @payload-effects    = ();
        }

        &redraw();
        $answer                 = prompt("\nSatified [y/n (n)] ...? ");
        $editing                = False if $answer ~~ /:i ^ y /;
    }
    self.set-DUMP-TTY-header-markup($header-markup);
    self.set-DUMP-TTY-payload-markup($payload-markup);
}

method set-headers (Bool:D $headers) {
    $!headers = $headers;
}
method set-quiet (Bool:D $quiet) {
    die '--verbose will not allow --quiet to be set.' if $!verbose;
    $!quiet = $quiet
}
method set-silence (Bool:D $silence) {
    die '--verbose will not allow --silence to be set.' if $!verbose;
    $!silence = $silence;
    self.set-quiet($!silence);
}
method set-verbose (Bool:D $verbose) {
    die 'Neither --silence nor --quiet will allow --verbose to be set.' if $!silence || $!quiet;
    $!verbose = $verbose;
}

method set-DUMP-TTY-header-markup (Str:D $markup is copy) {
    $markup = '' if $markup ~~ / ^ \s+ $ /;
    $!DUMP-TTY-header-markup    = $markup;
}

method set-DUMP-TTY-payload-markup (Str:D $markup is copy) {
    $markup = '' if $markup ~~ / ^ \s+ $ /;

    $!DUMP-TTY-payload-markup   = $markup;
}

method set-tab-stop (Int:D $tab-stop) {
    $!tab-stop = $tab-stop;
}

our sub usage {
    put '';
    put colored('Usage', 'underline');
    put '';
    put ' ' x 2 ~ $*PROGRAM-NAME.IO.basename ~ ' [--switches...] [--help] [--explain]';
    put '';
    put ' ' x 4 ~ '[--hmc=' ~ colored('hostname', 'green italic') ~ ']        resolvable HMC hostname';
    put ' ' x 4 ~ '[--off-line=' ~ colored('False', 'bold') ~ '|' ~ colored('True', 'italic') ~ '] no network connection to the HMC (' ~ colored('implies --cache', 'italic') ~ ')';
#   put ' ' x 4 ~ '[--root-directory=' ~ colored('dir', 'italic') ~ "]  defaults to user's home directory (" ~ colored('rarely altered', 'red italic') ~ ')';
    put ' ' x 4 ~ '[--unconfig=' ~ colored('False', 'bold') ~ '|' ~ colored('True', 'italic') ~ '] erase the configuration file and start with defaults';
    put ' ' x 4 ~ '[--user-id=' ~ colored('userid', 'green italic') ~ ']      HMC account for REST API queries';
    put '';
    put ' ' x 4 ~ '[--headers=' ~ colored('True', 'green bold') ~ '|' ~ colored('False', 'green italic') ~ ']  output headers' ~ ' (' ~ colored('NYI', 'red italic') ~ ')';
    put ' ' x 4 ~ '[--quiet=' ~ colored('False', 'green bold') ~ '|' ~ colored('True', 'green italic') ~ ']    no informational output, only error output' ~ ' (' ~ colored('NYI', 'red italic') ~ ')';
    put ' ' x 4 ~ '[--silence=' ~ colored('False', 'green bold') ~ '|' ~ colored('True', 'green italic') ~ ']  no informational output, no error output' ~ ' (' ~ colored('NYI', 'red italic') ~ ')';
    put ' ' x 4 ~ '[--tab-stop=' ~ colored('1', 'green bold') ~ ']      tab-stop for auto-indentation';
    put ' ' x 4 ~ '[--verbose=' ~ colored('False', 'green bold') ~ '|' ~ colored('True', 'green italic') ~ ']  extra informational output' ~ ' (' ~ colored('NYI', 'red italic') ~ ')';
    put '';
#   put ' ' x 4 ~ '[--batch=' ~ colored('# of cpus', 'green italic') ~']     concurrency control (' ~ colored('currently disabled', 'red italic') ~ ')';
    put ' ' x 4 ~ '[--cache=' ~ colored('False', 'bold') ~ '|' ~ colored('True', 'italic') ~ ']    query cache (if available) instead of HMC (https)';
    put ' ' x 4 ~ '[--colors]              manage ' ~ colored('color palette', 'green');
    put ' ' x 4 ~ '[--diags]               manage ' ~ colored('diagnostics', 'green');
    put ' ' x 4 ~ '[--optimize]            optimize and lock for streamlined execution';
    put '';
    put ' ' x 4 ~ colored('* ', 'italic') ~ colored('green', 'green italic') ~ colored(" indicates that the option's value will persist", 'italic');
#   put ' ' x 4 ~ colored('* ', 'italic') ~ colored('there are ', 'italic') ~ colored('no required', 'white bold italic') ~ colored(' switches', 'italic');
    exit;
}

=finish
