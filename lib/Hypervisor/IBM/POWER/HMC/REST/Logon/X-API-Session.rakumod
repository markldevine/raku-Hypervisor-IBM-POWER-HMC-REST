use     OO::Monitors;
use     HTTP::UserAgent;
use     HTTP::Request::Common;
need    Hypervisor::IBM::POWER::HMC::REST::ETL::XML;
use     KHPH;
use     URI;
unit    monitor Hypervisor::IBM::POWER::HMC::REST::Logon::X-API-Session:api<1>:auth<Mark Devine (mark@markdevine.com)>
            does Hypervisor::IBM::POWER::HMC::REST::ETL::XML;

has     Bool:D                              $.cache                     is required;
has     Str:D                               $.cache-directory           is required;
has     Str:D                               $.credentials-directory     is required;
has     Str:D                               $.hmc                       is required;
has     Bool:D                              $.off-line                  is required;
has     Str:D                               $.user-id                   is required;
has     Str                                 $.password-secure-at;
has     Str                                 $.session-token-secure-at;
has     HTTP::UserAgent                     $.ua;
has     Int                                 $.ua-timeout                = 180;
has     Str                                 $.useragent                 = 'Rakudo HTTP::UserAgent';
has     Str                                 $.X-API-Session;

class Cache-Endpoint {
    has Str     $.xml-path;
    has URI     $.uri;
    has Bool    $.valid is rw;
}

method fetch (Str:D $uri-segments-str, Bool :$retry = True, Bool :$optional --> Str:D) {
    my $cache-entry = self!get-cache-entry($uri-segments-str);
    return $cache-entry.xml-path if self.cache && $cache-entry.valid;
    self.init unless $!ua.DEFINITE;
    my %headers;
    %headers<X-API-Session> = self.X-API-Session;
    %headers<Accept> = 'application/atom+xml';
    my $response = self.ua.get($cache-entry.uri, |%headers);
    given $response.code {
        when 200 {
            given $cache-entry.xml-path.IO.open(:w) {
                .lock;
                .spurt: $response.content;
                .close;
            }
            $cache-entry.xml-path.IO.chmod(0o600);
            return $cache-entry.xml-path;
        }
        when 401|403 {
            if $retry {
                self!DELETE;
                self!PUT;
                self.fetch($uri-segments-str, :!retry);
            }
            else {
                note .exception.message without self!password-stash-path.IO.unlink;
                note .exception.message without self!session-token-stash-path.IO.unlink;
                die "Unable to update stale credentials!";
            }
        }
        default {
            return Nil if $optional;
            note $response;
            die;
        }
    }
}

method init () {
    $!ua = HTTP::UserAgent.new(:$!useragent, :10timeout);
    $!ua.timeout    = self.ua-timeout;
    $!X-API-Session = Nil;
    if self!session-token-stash-path.IO.e {
        my $credentials = KHPH.new(:stash-path(self!session-token-stash-path)).expose;
        $!X-API-Session = $credentials if $credentials;
    }
    self!PUT without $!X-API-Session;
    self;
}

### PUT https://https://{hmc}:12443/rest/api/web/Logon
### curl --insecure --request PUT --header 'Content-Type: application/vnd.ibm.powervm.web+xml' --data-binary '<?xml version="1.0" encoding="UTF-8" standalone="yes"?><LogonRequest xmlns="http://www.ibm.com/xmlns/systems/power/firmware/web/mc/2012_10/" schemaVersion="V1_1_0"> <Metadata><Atom/></Metadata><UserID kb="CUR" kxe="false">hscroot</UserID><Password kb="CUR" kxe="false">xXxXxXx</Password></LogonRequest>' https://10.11.101.72:12443/rest/api/web/Logon

method !PUT () {
    die 'Unable to communicate with the Hardware Management Console in OFF-LINE mode' if self.off-line;
    my URI $uri .= new('https://' ~ $!hmc ~ ':12443/rest/api/web/Logon');
    my %header;
    %header<Content-Type> = 'application/vnd.ibm.powervm.web+xml';
    my $password;
    while !$password {
        unless $password = KHPH.new(
                :herald('Stash credentials for ' ~ self.user-id ~ '@' ~ self.hmc),
                :prompt(self.user-id ~ '@' ~ self.hmc ~ ' password'),
                :stash-path(self!password-stash-path),
                :user-exclusive-at($!password-secure-at),
               ).expose {
            die 'need to remove ' ~ self!password-stash-path;
        }
    }
    my $content = '<?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <LogonRequest xmlns="http://www.ibm.com/xmlns/systems/power/firmware/web/mc/2012_10/" schemaVersion="V1_3_0">
        <Metadata><Atom/></Metadata>
        <UserID kb="CUR" kxe="false">' ~ self.user-id ~ '</UserID>
        <Password kb="CUR" kxe="false">' ~ $password ~ '</Password>
    </LogonRequest>';
    my $response = $!ua.request(PUT $uri, :$content, |%header);
    given $response.code {
        when 200 {
warn 'new self.etl-parse-string';
            self.etl-parse-string(:xml-string($response.content));
            die unless $!X-API-Session = self.etl-text(:TAG<X-API-Session>);
            $ = KHPH.new(
                :secret($!X-API-Session),
                :stash-path(self!session-token-stash-path),
                :user-exclusive-at($!session-token-secure-at),
            );
        }
        default {
            note $response;
            note .exception.message without self!password-stash-path.IO.unlink;
            note .exception.message without self!session-token-stash-path.IO.unlink;
            die "Authentication failed!\n";
        }
    }
    Nil;
}

### DELETE https://{server}/rest/com/vmware/cis/session
method !DELETE () {
    my %header;
    %header<X-API-Session> = $!X-API-Session;
    my $request = HTTP::Request.new: DELETE => 'https://' ~ $!hmc ~ '/rest/api/web/Logon', |%header;
    $ = $!ua.request($request);
    note .exception.message without self!session-token-stash-path.IO.unlink;
    $!ua = HTTP::UserAgent.new(:$!useragent);
    $!X-API-Session = Nil;
}

method !get-cache-entry (Str:D $uri-segments-str) {
    my $uri-str     = 'https://' ~ self.hmc ~ ':12443' ~ $uri-segments-str;
    my URI $uri    .= new($uri-str);
    my @sub-dirs   = $uri.segments[1 .. *];
    my $child       = @sub-dirs.pop;
    my $parent      = @sub-dirs.pop;
    my $base-ext    = $*USER ~ '/' ~ $uri.host ~ '/' ~ @sub-dirs.join('/') ~ '/' ~ $parent;
    my $base        = $!cache-directory ~ '/' ~ $base-ext;
    unless $base.IO.e {
        mkdir($base);
        my @dirs    = $base-ext.split('/');
        my $p;
        for @dirs -> $dir {
            $p ~= '/' ~ $dir;
            my $path = $!cache-directory ~ $p;
            chmod(0o700, $path) unless ~$path.IO.mode == 700;
        }
    }
    my $parent-xml  = $base ~ '.xml';
    my $xml-path    = $base ~ '/' ~ $child ~ '.xml';

################################################################################
################################################################################
#%%%    This logic might not make sense for the HMC REST API - check it...  %%%#
################################################################################
################################################################################

#   If no cache endpoint for this item yet, perform a fresh lookup
    return Cache-Endpoint.new(
        :$xml-path,
        :$uri,
        :valid(False),
    ) unless $xml-path.IO.e;

#   If cache entry for this item is older than its parent (if relevant), perform a fresh lookup
    return Cache-Endpoint.new(
        :$xml-path,
        :$uri,
        :valid(False),
    ) if $parent-xml.IO.e && ($xml-path.IO.changed < $parent-xml.IO.changed);

#   Good cache entry
    return Cache-Endpoint.new(
        :$xml-path,
        :$uri,
        :valid(True),
    );
}

method !password-stash-path () {
    $!password-secure-at = self.credentials-directory ~ '/' ~ $*USER unless $!password-secure-at;
    return(self.password-secure-at ~ '/' ~ self.hmc ~ '/web/Logon/' ~ self.user-id ~ '/' ~ 'password.khph');
}

method !session-token-stash-path () {
    $!session-token-secure-at = self.credentials-directory ~ '/' ~ $*USER unless $!session-token-secure-at;
    return(self.session-token-secure-at ~ '/' ~ self.hmc ~ '/web/Logon/' ~ self.user-id ~ '/' ~ 'session-token.khph');
}

method xml-name-exceptions () { return set (); }

=finish
