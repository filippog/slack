Summary: slack configuration management tool
Name: slack
Version: 0.12.2
Release: 1
License: GPL
Group: System Environment/Libraries
Buildroot: /tmp/%{name}-root
BuildArch: noarch
Requires: rsync >= 2.6.0

%description
configuration management program for lazy admins

slack tries to allow centralized configuration management with a bare minimum
of effort.  Usually, just putting a file in the right place will cause the
right thing to be done.  It uses rsync to copy files around, so can use any
sort of source (NFS directory, remote server over SSH, remote server over
rsync) that rsync supports.

%prep

%build

%install
[ "$RPM_BUILD_ROOT" != "/" ] && rm -rf $RPM_BUILD_ROOT
cd $RPM_SOURCE_DIR
%makeinstall libexecdir=$RPM_BUILD_ROOT/%{_libdir}

%clean
rm -rf $RPM_BUILD_ROOT

%files
%defattr(-,root,root)
%config /etc/slack.conf
%{_sbindir}
%{_libdir}/slack
%{_mandir}/man5
%{_mandir}/man8
%defattr(0700,root,root)
%{_localstatedir}/lib/slack
%{_localstatedir}/cache/slack

%preun
if [ $1 = 0 ] ; then
    . /etc/slack.conf
    rm -rf "$CACHE"/*
    rm -rf "$STAGE"
fi

%changelog
* Tue Dec 21 2004 Alan Sundell <alan@sundell.net> 0.12.2-1
- new upstream source (see ChangeLog)
    moves functions into common library Slack.pm

* Tue Dec 21 2004 Alan Sundell <alan@sundell.net> 0.12.1-1
- new upstream source (see ChangeLog)
    fixes bug introduced in 0.11-1 that broke backups

* Fri Dec 03 2004 Alan Sundell <alan@sundell.net> 0.12-1
- new upstream source (see ChangeLog)
    swap preinstall and fixfiles in order of operations

* Thu Nov 11 2004 Alan Sundell <alan@sundell.net> 0.11-1
- new upstream source (see ChangeLog)
    add --no-files and --no-scripts options

* Fri Oct 29 2004 Alan Sundell <alan@sundell.net> 0.10.2-1
- new upstream source (see ChangeLog)
    use the full role name in the stage

* Fri Oct 29 2004 Alan Sundell <alan@sundell.net> 0.10.1-1
- new upstream source (see ChangeLog)
    minor code cleanups

* Fri Oct 22 2004 Alan Sundell <alan@sundell.net> 0.10-1
- new upstream source (see ChangeLog)
    adds a new "staging" step, which elimates the need for .keepme~ files

* Fri Aug 13 2004 Alan Sundell <alan@sundell.net> 0.7-1
- new upstream source

* Sun Jul 18 2004 Alan Sundell <alan@sundell.net> 0.6-1
- new upstream source

* Sat Jul 17 2004 Alan Sundell <alan@sundell.net> 0.5-1
- new upstream source

* Thu Jul 01 2004 Alan Sundell <alan@sundell.net> 0.4-1
- new upstream source

* Mon May 24 2004 Alan Sundell <alan@sundell.net> 0.1-1
- initial version
