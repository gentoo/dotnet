gentoo-dotnet official overlay
==============================

note that this overlay is community driven, any help is very welcome, since so it could be unstable

[![Build Status](https://travis-ci.org/gentoo/dotnet.png?branch=master)](https://travis-ci.org/gentoo/dotnet)
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

 - some unofficial docs: http://arsenshnurkov.github.io/gentoo-mono-handbook/index.htm

<hr/>

 - Join #gentoo-dotnet channel on Freenode
 - Open issues here https://github.com/gentoo/dotnet
 - Add dotnet@gentoo.org to Watching on https://bugs.gentoo.org/userprefs.cgi?tab=email
 - Try to fix upstream issues
 - Fork & Contribute & Pull Request
 - Open requests on https://bugs.gentoo.org with solutions from this overlay

Dotnet Core
-----------

For using dotnet core see

 - [Dotnet Core Binary packages](Documentation/DotnetCore-Bin.md)
 - [Dotnet Core Source Build Notes](Documentation/DotnetCore-Src.md)

