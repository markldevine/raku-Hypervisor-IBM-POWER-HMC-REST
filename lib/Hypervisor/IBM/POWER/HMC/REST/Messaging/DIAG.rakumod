need    Hypervisor::IBM::POWER::HMC::REST::Config::Options;
need    MessageStream::Message;
need    MessageStream;
use     Terminal::ANSIColor;
unit    class Hypervisor::IBM::POWER::HMC::REST::Messaging::DIAG:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does MessageStream;

my      \DIAG-COLORS    = 'black on_white';
my      \ADDED-PAD      = 4;

has     Hypervisor::IBM::POWER::HMC::REST::Config::Options    $.options   is required;

method DIAG-TTY-receive (MessageStream::Message:D $message) {
    $*ERR.put: colored($message.payload.Str, DIAG-COLORS) if $message.payload;
}

=finish
