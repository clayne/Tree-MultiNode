# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..6\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tree::MultiNode;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

$debug = 0;
$test = 1;

if( $debug ) {
  $Tree::MultiNode::debug = 1;
}

++$test;
my $tree   = new Tree::MultiNode();
my $handle = new Tree::MultiNode::Handle($tree);
if( $tree && $handle ) {
  print "ok ", $test, "\n";
}
else {
  print "not ok ", $test, "\n";
}

++$test;
$handle->add_child("a",1);
$handle->add_child("b",1);
$handle->add_child("c",1);

$handle->remove_child(1);
my %pairs = $handle->kv_pairs();
print "[$0] Pairs: ", join(',',%pairs), "\n" if $debug;
if( !defined($pairs{"b"}) && defined($pairs{"a"}) && defined($pairs{"c"}) ) {
  print "ok ", $test, "\n";
}
else {
  print "not ok ", $test, "\n";
}


#
# test traverse...
#
print "testing traverse...\n" if $debug;
$tree   = new Tree::MultiNode();
$handle = new Tree::MultiNode::Handle($tree);
$handle->set_key('1');
$handle->set_value('foo');
  $handle->add_child('1:1','bar');
  $handle->down(0);
    $handle->add_child('1:1:1','baz');
    $handle->add_child('1:1:2','boz');
    $handle->up();
  $handle->add_child('1:2','qux');
  $handle->down(1);
    $handle->add_child('1:2:1','qaz');
    $handle->add_child('1:2:2','qoz');

$handle->top();
my $count = 0;
$handle->traverse(sub {
    my $h = pop;
    printf "%sk: %- 5s v: %s\n",('  'x$handle->depth()),$h->get_data() 
      if $debug;
    ++$count;
    die "error with arguments and traverse\n" unless 1 == $_[0];
    die "error with arguments and traverse\n" unless 2 == $_[1];
    die "error with arguments and traverse\n" unless 3 == $_[2];
  },
  1,
  2,
  3
);


# test select...
$handle->top();
#print "Children: ",join(', ',$handle->child_keys()),"\n";
my $rv = $handle->select('1:2') or die "Error, select() failed: $rv\n";
$handle->down();
if( 'qux' ne $handle->get_value()) {
  die "Error, select('1:2') did not position the handle on the child: ",
    $handle->get_value(),',',$handle->get_key(),"\n";
}
print "ok 4\n";

die "Error calling traverse, should have had 7 count, but had: $count\n"
  unless 7 == $count;
print "ok 5\n";

# test storing '0' as a child key
$handle->add_child('zero','foo');
$handle->last();
$handle->down();
$handle->set_key(0);
unless( 0 == $handle->get_key() ) {
  die "Error, can't store 0 as a key!\n";
}
print "ok 6\n";

