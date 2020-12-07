need    Hypervisor::IBM::POWER::HMC::REST::Config::Options;
need    MessageStream::Message;
need    MessageStream;
use     Terminal::ANSIColor;
unit    class Hypervisor::IBM::POWER::HMC::REST::Messaging::DUMP:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does MessageStream;

has     Hypervisor::IBM::POWER::HMC::REST::Config::Options    $.options   is required;

method DUMP-TTY-receive (MessageStream::Message:D $message) {
    my $column          = 0;
    $column             = $message.options<column> if $message.options<column>:exists;
    $column             = $message.options<header>.chars + 1 if $message.options<header> && !$column;
    my $shift           = 0;
    $shift              = $message.options<shift> if $message.options<shift>;

    if $message.payload ~~ Positional {
        if $message.options<header> {
            $*OUT.print: ' ' x ($shift * self.options.tab-stop) if $shift;
            if self.options.DUMP-TTY-header-markup {
                $*OUT.put: colored($message.options<header>, self.options.DUMP-TTY-header-markup ~ ' bold underline');
            }
            else {
                $*OUT.put: $message.options<header>;
            }
        }
        for $message.payload.list -> $record {
            if $record.chars > self.options.screen-width - ($shift * self.options.tab-stop) {
                $shift = 1 unless $shift;
                my @records = $record.comb(self.options.screen-width - ($shift * self.options.tab-stop) - 1, :partial);
                for @records -> $rcd {
                    $*OUT.print: ' ' x ($shift * self.options.tab-stop) + self.options.tab-stop;
                    $*OUT.put: colored($rcd, self.options.DUMP-TTY-payload-markup);
                }
            }
            else {
                $*OUT.print: ' ' x ($shift * self.options.tab-stop) + self.options.tab-stop;
                $*OUT.put: colored($record, self.options.DUMP-TTY-payload-markup);
            }
        }
    }
    else {
        if $message.options<banner> {
            $*OUT.print: ' ' x ($shift * self.options.tab-stop) if $shift;
            if self.options.DUMP-TTY-header-markup {
                $*OUT.put: colored($message.options<banner>, self.options.DUMP-TTY-header-markup ~ ' bold underline');
            }
            else {
                $*OUT.put: $message.options<banner>;
            }
        }
        elsif $message.options<header> {
            $*OUT.print: ' ' x ($shift * self.options.tab-stop) if $shift;
            with $message.payload {
                if self.options.DUMP-TTY-header-markup {
                    $*OUT.print: colored($message.options<header>, self.options.DUMP-TTY-header-markup ~ ' bold');
                }
                else {
                    $*OUT.print: $message.options<header>;
                }
            }
            else {
                $*OUT.print: colored('THIS SHOULD NEVER APPEAR', 'white on_black') ~ 'header = ' ~ $message.options<header>;                                               # %%%
            }
            if $message.payload {
                my $pad-size = $column - $message.options<header>.chars - ($shift * self.options.tab-stop);
                if $message.payload.chars > (self.options.screen-width - $column) {
                    my $comb = self.options.screen-width - $column;
                    my @payload = $message.payload.comb($comb, :partial);
                    for @payload -> $payload {
                        $*OUT.put: ' ' x $pad-size ~ colored($payload, self.options.DUMP-TTY-payload-markup);
                        $pad-size = $column;
                    }
                }
                else {
                    $*OUT.put: ' ' x $pad-size ~ colored($message.payload, self.options.DUMP-TTY-payload-markup);
                }
            }
            else {
                $*OUT.put: '';
            }
        }
        else {
            $*OUT.put: ' ' x $column ~ colored($message.payload, self.options.DUMP-TTY-payload-markup) if $message.payload;
        }
    }
}

=finish
