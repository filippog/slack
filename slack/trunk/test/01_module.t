#!/usr/bin/perl -w

use strict;
use Test::More tests => 35;

BEGIN {
    chdir 'test' if -d 'test';
    unshift @INC, '../src';
    use_ok("Slack");
}

my $test_config_file = './slack.conf';
my %test_config = (
    'role-list' => './roles.conf',
    'source' => './testsource',
    'cache' => './tmp/cache',
    'stage' => './tmp/stage',
    'root' => './tmp/root',
    'backup-dir' => './tmp/backups',
    'verbose' => 0,
);

# Make sure all the expected funtions are there
can_ok("Slack", qw(default_usage read_config check_system_exit get_options));

# default_usage()
{
    my $usage = Slack::default_usage("qwxle");
    like($usage, qr/\AUsage: qwxle\n/, "Usage statement");
}


# read_config()
{
    my $opt = Slack::read_config(
        file => $test_config_file,
    );

    is_deeply(\%test_config, $opt, "read_config keys");
}

# check_system_exit()
{
    # clear variables
    $! = 0;
    $? = 0;

    system('/bin/true');
    eval "Slack::check_system_exit('');";
    like($@, qr#Unknown error#, "check_system_exit exit true");

    system('/bin/false');
    eval "Slack::check_system_exit('');";
    like($@, qr#'' returned 1\b#, "check_system_exit exit false");

    system('kill -TERM $$');
    eval "Slack::check_system_exit('');";
    like($@, qr#'' caught sig 15\b#, "check_system_exit signal");

    SKIP: {
        # see if we can set core limit
        skip "can't set ulimit -c", 1
            unless (system("ulimit -c 1024 2> /dev/null") == 0);

        my $coresdir = "./tmp/cores";
        if (not -d $coresdir) {
            (system("mkdir", "-p", $coresdir) == 0)
                or skip "Could not mkdir $coresdir", 1;
        }
        system("cd $coresdir ; ulimit -c 1024 ; kill -SEGV \$\$");
        eval "Slack::check_system_exit('');";
        system("rm -rf $coresdir");
        like($@, qr#'' dumped core\b#, "check_system_exit coredump");
    };
}

# get_options()
{
    my $e = 1; # a counter -- we check for exceptions a lot
    my $opt; # a place to store the options hashref
    my $cl_opt; # likewise for command like hash
    # We require hostname to be set, as get_options does
    # (I suppose we could skip this whole section if we can't get hostname,
    #  since get_options will just throw an exception)
    require Sys::Hostname;
    my $hostname = Sys::Hostname::hostname;

    # First, we check the setting of options and defaults in the absence
    # of a config file.
    eval {
        local @ARGV = (
            '--config=/dev/null',
            "--source=/foo/bar.$$",
        );
        $opt = Slack::get_options();
    };
    is($@, '', "get_options exception ".$e++);
    is($opt->{verbose}, 0, "get_options default verbosity");
    is($opt->{source}, "/foo/bar.$$", "get_options command line source");
    is($opt->{hostname}, $hostname, "get_options hostname");

    eval {
        local @ARGV = (
            '--config=/dev/null',
            '-vv',
        );
        $opt = Slack::get_options();
    };
    is($@, '', "get_options exception ".$e++);
    is($opt->{verbose}, 2, "get_options verbosity increments");

    eval {
        local @ARGV = (
            '--config=/dev/null',
            '-vv', '--quiet', '-v',
        );
        $opt = Slack::get_options();
    };
    is($@, '', "get_options exception ".$e++);
    is($opt->{verbose}, 1, "get_options --quiet");

    # Make sure it works if you pass in $opt, instead of getting return
    eval {
        $opt = {};
        local @ARGV = (
            '--config=/dev/null',
            '-vv',
        );
        Slack::get_options(
            opthash => $opt,
        );
    };
    is($@, '', "get_options exception ".$e++);
    is($opt->{verbose}, 2, "get_options pass in opthash");

    # Next, we check config file parsing.
    eval {
        local @ARGV = (
            "--config=$test_config_file",
        );
        $opt = Slack::get_options();
    };
    is($@, '', "get_options exception ".$e++);
    # A few extra things should be set
    local $test_config{config} = $test_config_file;
    local $test_config{hostname} = $hostname;

    is_deeply(\%test_config, $opt, "get_options config keys");

    eval {
        $cl_opt = {};
        local @ARGV = (
            "--config=$test_config_file",
            "--source=/foo/bar.$$",
        );
        $opt = Slack::get_options(
            command_line_hash => $cl_opt,
        );
    };
    is($@, '', "get_options exception ".$e++);
    is($opt->{source}, "/foo/bar.$$",
        "get_options command line overrides config file");
    is($cl_opt->{source}, $opt->{source},
        "get_options command_line_hash source set");
    is($cl_opt->{config}, $test_config_file,
        "get_options command_line_hash config set");
    is(scalar keys %{$cl_opt}, 2,
        "get_options command_line_hash not over-set");

    # Next, non-standard option parsing
    eval {
        local @ARGV = (
            '--config=/dev/null',
            "--foo=$$",
            "--bar=a.$$",
            '--baz',
        );
        $opt = Slack::get_options(
            command_line_options => [
                'foo=i',
                'bar=s',
                'baz',
            ],
        );
    };
    is($@, '', "get_options exception ".$e++);
    is($opt->{foo}, $$, "get_options extra options (int)");
    is($opt->{bar}, "a.$$", "get_options extra options (string)");
    ok($opt->{baz}, "get_options extra options (boolean)");

    # Next, required options
    #   first, when everything should be OK
    eval {
        local @ARGV = (
            "--config=$test_config_file",
            "--foo=$$",
        );
        $opt = Slack::get_options(
            command_line_options => [
                'foo=i',
            ],
            required_options => [qw(foo source)],
        );
    };
    is($@, '', "get_options exception ".$e++);

    #   second, when we should throw an exception because a
    #      required option is missing.
    eval {
        local @ARGV = (
            '--config=/dev/null',
            "--foo=$$",
        );
        $opt = Slack::get_options(
            command_line_options => [
                'foo=i',
            ],
            required_options => [qw(foo source)],
        );
    };
    like($@, qr/Required option/, "get_options required options");

    # test --help with:
    {
        my $helptext = `perl -I$INC[0] -MSlack -e 'Slack::get_options' -- --help`;
        is($?, 0, "get_options --help exit code");
        like($helptext, qr/^Usage: /m, "get_options --help output");
    }

    # test --usage with:
    {
        my $helptext = `perl -I$INC[0] -MSlack -e 'Slack::get_options' -- --invalid 2>&1`;
        isnt($?, 0, "get_options usage exit code");
        like($helptext, qr/^Usage: /m, "get_options usage output");
    }
}

