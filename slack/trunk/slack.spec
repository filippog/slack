Summary: slack configuration management tool
Name: slack
Version: 0.1
Release: 1
License: GPL
Group: System Environment/Libraries
Buildroot: /tmp/%{name}-root
BuildArch: noarch

%description
configuration management program for lazy admins slack tries to allow
centralized configuration management with a bare minimum of effort.  Usually,
just putting a file in the right place will cause the right thing to be done.
It uses rsync to copy files around, so can use any sort of source (NFS
directory, remote server over SSH, remote server over rsync) that rsync
supports.

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
%{_localstatedir}/lib/slack

%pre

%post

%preun
rm -rf /var/lib/slack/cache

%changelog
* Mon May 24 2004 Alan Sundell <alan@sundell.net> 0.1-1
- initial version
