use strict;
use warnings;

use LWP::Simple;
use LWP::UserAgent;
use JSON qw( decode_json );

# Get the sizes of all the subrepos and calculate the percentage of the
# allowed total.

my %repo2size = ();

if (scalar(@ARGV) < 2) {
    printf STDERR "Usage: perl util/check_repo_size.pl username password\n";
    exit 1;
}
my $username = $ARGV[0];
my $password = $ARGV[1];

opendir my $dh, 'texts/' or die "Couldn't open texts/: $!";

while (my $repo = readdir $dh) {
    next if $repo eq '.' || $repo eq '..' || $repo eq '.DS_Store';
    get_repo_json("https://${username}:${password}\@api.bitbucket.org/2.0/repositories/eplib/$repo");
}

for my $repo (sort keys %repo2size) {
    my $size = $repo2size{$repo};
    my $percent_full = $size / (1024 * 1024 * 1024) * 100;
    printf "%s %-12d %3.1f\n", $repo, $size, $percent_full;
}
exit;

sub get_repo_json {

    my $url = shift;
    my $json;

    my $ua = LWP::UserAgent->new( ssl_opts => { verify_hostname => 0 } );
    my $response = $ua->get($url);

    if ( $response->is_success ) {
        $json = $response->decoded_content;
    }
    else {
        die "For $url: " . $response->status_line;
    }
    
    my $decoded_json = decode_json( $json );
    my $name =  $decoded_json->{'name'} || '';
    my $size = $decoded_json->{'size'} || '';

    $repo2size{$name} = $size;
}
