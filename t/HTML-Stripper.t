# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl HTML-Stripper.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More tests => 7;
BEGIN { use_ok('HTML::Stripper') };

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

my $strip1 = HTML::Stripper->new( skip_cdata => 0, strip_ws => 0 );
ok( defined($strip1) and ref($strip1) eq 'HTML::Stripper' );
ok( $strip1->strip_html('<html>test1</html>') eq 'test1' );

my $strip2 = HTML::Stripper->new( skip_cdata => 0, strip_ws => 1 );
ok( defined($strip2) and ref($strip2) eq 'HTML::Stripper' );
ok( $strip2->strip_html(' <html> test2 </html> ') eq 'test2' );

my $strip3 = HTML::Stripper->new( skip_cdata => 1, strip_ws => 1 );
my $html = <<'END_HTML';
<html>
<script>alert('Hello!');</script>
test3
</html>
END_HTML

ok( defined($strip3) and ref($strip3) eq 'HTML::Stripper' );
ok( $strip3->strip_html($html) eq 'test3' );
