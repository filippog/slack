# Introduction #

Subroles in slack are an example of the [inheritance](http://en.wikipedia.org/wiki/Inheritance_(computer_science)) design pattern, applied to a tree of files.

## Synopsis ##

```
.../roles/myrole/files/etc/daemon.conf
.../roles/myrole/files/etc/otherdaemon.conf
.../roles/myrole/files.foo/etc/daemon.conf
.../roles/myrole/files.foo.bar/etc/daemon.conf
.../roles/myrole/files.quux/etc/daemon.conf
```

Slack will install a different `/etc/daemon.conf` when called for `myrole`, `myrole.foo`, `myrole.foo.bar`, or `myrole.quux`, but will install the same `/etc/otherdaemon.conf` every time.

## Features ##

  * Subroles are denoted by dots in a role name passed to slack.
> For example, `myrole.foo` is a subrole of the role `myrole`, whereas `foo`, `myrolefoo`, and `myrole-foo` are completely separate roles.
  * There can be any number of subrole levels.
> For example: `myrole`, `myrole.foo`, `myrole.foo.bar`, and so on.
  * All subroles live entirely within the directory of the base parent role.  They uses `files` directories with the subrole part of the name appended.
> For example, for `myrole`, `myrole.foo`, and `myrole.foo.bar`:
    * The files for `myrole` are in `.../roles/myrole/files`
    * The files for `myrole.foo` are in `.../roles/myrole/files.foo`
    * The files for `myrole.foo.bar` are in `.../roles/myrole/files.foo.bar`

  * Files in `myrole/files.foo` override files in the `myrole/files` directory when the subrole `myrole.foo` is installed.

  * Any files not present in the subrole will get inherited from the parent role.
> For example, `myrole.foo` will get `.../roles/myrole/files/etc/otherdaemon.conf` if `.../roles/myrole/files.foo/etc/otherdaemon.conf` does not exist.
  * New files can be added in a subrole (files that do not exist in a main role).

  * The `files.foo` directory can be empty or nonexistent, in which case it has no effect on the files from the parent role, and passing either `myrole` or `myrole.foo` to slack will do the same thing as far as files are concerned.
    * You can also have a `files.foo.bar` with no `files.foo`, and still use `myrole`, `myrole.foo`, and `myrole.foo.bar`.

  * The overlay of files is done by `slack-stage` in slack's "`STAGE`" directory, before install time, so there is no window where overridden files from the parent role appear in the `ROOT` filesystem.

## Restrictions ##

  * None of the above applies to the `scripts` directory.  This is just about the `files` directory.  Scripts can take different actions for subroles based on the role name passed as the first argument (see Script Example)
  * Files can only be added by subroles, not removed (if want to do this, you should probably refactor).
  * Files in subroles completely replace files in the parent with the same name (there is no provision for patching; if you need to patch, use a script).
  * Subroles can only inherit from one parent role (we only provide single inheritance).


# Examples #

## File Layout Example ##

```
.../roles/myrole/files/etc/commonconfig:
   blah blah
.../roles/myrole/files/etc/daemon.conf:
   GOCRAZY=false
.../roles/myrole/files.foo/etc/daemon.conf:
   GOCRAZY=true
.../roles/myrole/files.bar/etc/daemon.conf:
   GOCRAZY=maybe
.../roles/myrole/files.bar/etc/barconfig:
   blah blah
.../roles/myrole/files.bar.baz/etc/daemon.conf:
   GOCRAZY=false
.../roles/myrole/files.omg.bbq/etc/daemon.conf:
   GOCRAZY=true
   BBQ=delicious
```

In this example, we have many possible roles.  No matter which we install, the contents of `commonconfig` will be the same, because it is inherited from the parent role.  Similarly, both `myrole.bar` and `myrole.bar.baz` will get `barconfig`.

The value of GOCRAZY in `daemon.conf`, however, will vary, depending on what role name we pass to `slack` or put in `roles.conf`:

  1. myrole: false
  1. myrole.foo: true
  1. myrole.bar: maybe
  1. myrole.bar.baz: false
  1. myrole.omg: false
  1. myrole.omg.bbq: true

Note that it's OK that we don't have a `daemon.conf` for the `myrole.omg` role, or even a `files.omg` directory.  It inherits the file from `myrole`.

## Script Example ##

Scripts get the role name passed in as the first argument, and can use that to make decisions.  Obviously, the possibilities are wide open for you here; we're just going to present a simple example.

If you're using shell scripts, you can do something like this:

```
#!/bin/sh

# do some common code here

case $1 in
  myrole)
    # only run for bare parent role
    ;;
  myrole.foo)
    # only run for myrole.foo, not myrole.foo.fred
    ;;
  myrole.bar*)
    # sloppy: catches myrole.bar, myrole.bar.baz, but also myrole.bars
    # Usually not a problem, though
    ;;
  myrole.quux|myrole.quux.*)
    # more precisely matches subroles of myrole.quux
    ;;
esac

# more common code, maybe using some variables assigned in the case statement above
```


## Refactoring Example ##

Note: we're presenting a contrived example here, so we're going to do some stupid things to make the lessons clearer.

Suppose we work for a company in San Francisco that's going to sell pet toys, but (get this), on the Internet!  Awesome!  We're getting paid in stock.

We have a role, let's say for a cluster of generic web servers in our company's HQ:

```
.../roles/webserver/files/etc/httpd/httpd.conf
.../roles/webserver/files/etc/httpd/php.ini
.../roles/webserver/scripts/preinstall
```

For the sake of this example, the content of the website is being managed by some means outside our scope; probably it's all mode 777 on some NFS share, but that's a problem for another day.  Remember, slack is designed to distribute configuration, not content or software.

All is going well, but then we open a new site in Hyderabad, and we want a cluster of webservers there with a slightly different config.


### Refactoring Example: First Take ###

So we make a subrole, and now things look like this:

```
.../roles/webserver/files/etc/httpd/httpd.conf
.../roles/webserver/files/etc/httpd/php.ini
.../roles/webserver/files.hyd/etc/httpd/httpd.conf
.../roles/webserver/scripts/preinstall
```

Now, our roles.conf looks like this:

```
web1.sfo.example.com: webserver
web2.sfo.example.com: webserver
[...]
web1.hyd.example.com: webserver.hyd
web1.hyd.example.com: webserver.hyd
[...]
```

When we run `slack` on `web1.hyd`, it will get the `webserver.hyd` role, and the `httpd.conf` from there.  This is much better than making an entirely separate role, because we get to re-use `php.ini` and our `preinstall` script.

But hold on, we've done something stupid here -- the two sites are only slightly different; most of `httpd.conf` does not vary between the two sites.  Now, when we want to make a change to that invariant portion of the config, we've got to remember to make it in both places.  Someone probably won't remember, so the two files will drift over time, and that will make for sad sysadmins.

### Refactoring Example: Extraction ###

We need to refactor -- instead of having all the config in one file, we should extract the variant configs into smaller files, like so:

```
.../roles/webserver/files/etc/httpd/httpd.conf
.../roles/webserver/files/etc/httpd/site.conf
.../roles/webserver/files/etc/httpd/php.ini
.../roles/webserver/files.hyd/etc/httpd/site.conf
.../roles/webserver/scripts/preinstall
```

Now we can have the big `httpd.conf` include the tiny `site.conf`, and we can re-use the config in `httpd.conf` between the two sites, making for happy sysadmins.

Some programs make this easy to do with their configuration with include functionality or conf.d directories; others don't.  For the latter, it's usually pretty easy to build the config with a script (or `cat`).

Back to our example, it is a little annoying that ("for historical reasons") the Hyderabad subrole is like a second-class citizen compared to the main role for San Francisco.  But read on...

### Refactoring Example: Type Generalization ###

Let's suppose for some reason we've got a files in our main role that don't need to appear in our subrole.  Maybe we've got SSL certs or something that have file names based on the domain name, like so:

```
.../roles/webserver/files/etc/httpd/httpd.conf
.../roles/webserver/files/etc/httpd/site.conf
.../roles/webserver/files/etc/httpd/php.ini
.../roles/webserver/files/etc/httpd/ssl/www.sfo.example.com.crt
.../roles/webserver/files.hyd/etc/httpd/site.conf
.../roles/webserver/files.hyd/etc/httpd/ssl/www.hyd.example.com.crt
.../roles/webserver/scripts/preinstall
```

The `www.sfo` cert is going to get installed on the `www.hyd` servers, even though they don't need it.  Again, a little refactoring comes to the rescue:
```
.../roles/webserver/files/etc/httpd/httpd.conf
.../roles/webserver/files/etc/httpd/php.ini
.../roles/webserver/files.sfo/etc/httpd/site.conf
.../roles/webserver/files.sfo/etc/httpd/ssl/www.sfo.example.com.crt
.../roles/webserver/files.hyd/etc/httpd/site.conf
.../roles/webserver/files.hyd/etc/httpd/ssl/www.hyd.example.com.crt
.../roles/webserver/scripts/preinstall
```

Now, our roles.conf looks like this:

```
web1.sfo.example.com: webserver.sfo
web2.sfo.example.com: webserver.sfo
[...]
web1.hyd.example.com: webserver.hyd
web1.hyd.example.com: webserver.hyd
[...]
```


We now have a generic `webserver` role that's just a stub and isn't used anywhere, but contains all our common config.  We have two peer subroles that each contain only the specific things needed to make each site work.

That's much prettier, and will come in handy as online pet toy ordering really takes off and we add more and more sites around the world.


# Discussion #

## Why the Flat Layout? ##

The basic problem is that we are dealing with inheritance across trees of files, instead of just files.

At first, it was tempting to use subdirectories of the main role directory or the files directory to represent subroles.  In some ways, this would have made implementation easier.  But we decided not to, for two reasons:

  1. It would lead to namespace collisions.  If we used subdirectories of the files directory, you might run into trouble if someone tried to install `myrole.etc`.  If we used subdirectories of the main directory, we'd need to reserve names that conflicted with other directories in there (`files` and `scripts`), or protect those other directories with some special naming convention.
  1. If you have lots of levels of subroles, it makes it hard to see what's going on.

The layout ends up looking a little weird, because, when looking for files, we turn the role name string `myrole.foo.bar` into the directory string `myrole/files.foo.bar`, thus making the first dot kind of special.  However, alternatives have their problems:
  1. Moving the hierarchy up one level and using  `.../roles/myrole/files` and `.../roles/myrole.foo/files` at the same level as `.../roles/otherrole/files` would not fit the way most people use subroles; they tend to think of them as part of one module, and want them to be kept together in a way unrelated roles are not.
  1. Repeating the first role part like `myrole/files.myrole` and `myrole/files.myrole.foo` would make the simple case (no subroles) more complicated.

## Why Only Files and not Scripts? ##

We do this overlay for files because the filesystem doesn't already have this functionality.

The programming languages one can use for scripts, however, have a wealth of ways of providing this functionality, and any attempt on our part to provide it would pale by comparison.  We're also intentionally agnostic about what language the scripts are written in (we just `exec()` them), so we can't do any fancy things to use any one language's features automatically.

For example, suppose we called a `preinstall.subrole` script after the `preinstall` script, and your `preinstall` script called `rm somefile`.  How would you "override" this code in your second script?  The file is already gone.

However, since we pass scripts the full role name, you can use conditionals or OO inheritance in your `preinstall` script to handle this situation, as well as much more complicated ones.

## Why not Multiple Inheritance? ##

Multiple inheritance would make things more complicated, and in most cases the desired results can be accomplished by installing multiple roles instead.