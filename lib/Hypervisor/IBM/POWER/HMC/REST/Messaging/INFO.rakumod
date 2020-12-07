need    Hypervisor::IBM::POWER::HMC::REST::Config::Options;
need    MessageStream::Message;
need    MessageStream;
use     Terminal::ANSIColor;
unit    class Hypervisor::IBM::POWER::HMC::REST::Messaging::INFO:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does MessageStream;

my      \INFO-COLORS    = 'blue';
my      \ADDED-PAD      = 4;

has     Hypervisor::IBM::POWER::HMC::REST::Config::Options    $.options   is required;

method INFO-TTY-receive (MessageStream::Message:D $message) {
    $*OUT.put: colored($message.payload.Str, INFO-COLORS) if $message.payload;
}

=finish
