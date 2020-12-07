Examples
========

Basic Script Preamble
---------------------

```perl6
use     Hypervisor::IBM::POWER::HMC::Config::Options;
need    Hypervisor::IBM::POWER::HMC;

sub USAGE { Hypervisor::IBM::POWER::HMC::Config::Options::usage(); }
unit sub MAIN (*%options);

my $mc = Hypervisor::IBM::POWER::HMC.new(:options(Hypervisor::IBM::POWER::HMC::Config::Options.new(|Map.new(%options.kv))));
```

Using the API
-------------

The hierarchical structure of classes/methods within this client API mirrors that of IBM's POWER HMC REST API, directly mapping to the hierarchy found in the XML.

In the case of the Management Console, this client API provides an interface to connect to an HMC (authentication & session management), and then provides interfaces to each XML node therein. The REST API provides an XML node for AuthorizedKeys, which is a list. In a script, you can add the following code to the "Basic Script Preamble" above:

```perl6
$mc.ManagementConsole.init();

$mc.config.info: $mc.ManagementConsole.AuthorizedKeysValue,
                 :header('AuthorizedKeysValue'),
                 :4indent;
```
