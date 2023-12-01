gentoo-dotnet old overlay
==============================

note that this overlay is community driven, any help is very welcome, since so it could be unstable

[![Build Status](https://travis-ci.com/gentoo/dotnet.svg?branch=master)](https://travis-ci.com/gentoo/dotnet)
[![Gentoo discord server](https://img.shields.io/discord/249111029668249601.svg?style=flat-square&label=Gentoo%20Linux)](https://discord.gg/Gentoo)

Overlay Installation
--------------------

Use the [eselect repository module](https://wiki.gentoo.org/wiki/Eselect/Repository) 
to enable this overlay (or repository):

 - `eselect repository enable dotnet`

Then sync either everything using `emerge --sync` or just this overlay using `emaint -r dotnet sync`. 
Finally add the following USE flags if relevant.

- add `DOTNET_TARGETS="net45 net40"` to `make.conf`

<hr/>


Github way
--------------------

 - Join #gentoo-dotnet channel on Freenode
 - Open issues here https://github.com/gentoo/dotnet
 - Try to fix upstream issues
 - Fork & Contribute & Pull Request
 - Add dotnet@gentoo.org to Watching on https://bugs.gentoo.org/userprefs.cgi?tab=email
 - Open requests on https://bugs.gentoo.org with solutions from this overlay

 - some unofficial docs: http://arsenshnurkov.github.io/gentoo-mono-handbook/index.htm

<hr/>

Gentoo way
--------------------

https://wiki.gentoo.org/wiki/Project:Dotnet
git clone git+ssh://git@git.gentoo.org/repo/proj/dotnet.git
git remote add gentoo-mirror https://github.com/gentoo-mirror/dotnet.git

https://gitweb.gentoo.org/repo/proj/dotnet.git/tree/

You push everything to git.gentoo.org, and then GH will be updated.
The sync is one direction only, anything that happens on GH is overwritten.
You can use [app-portage/pram](https://packages.gentoo.org/packages/app-portage/pram) to merge PRs easily
(see https://wiki.gentoo.org/wiki/GitHub_Pull_Requests ).

