# DotNet Core Binary Builds


## Binary Packages

The quickest and easiet way to install dotnet core for gentoo is to use one of the binary packages.

Runtime:

  * =dev-dotnet/dotnetcore-runtime-bin-2.0.4
  * =dev-dotnet/dotnetcore-aspnet-bin-2.0.3

SDK:

  * =dev-dotnet/dotnetcore-sdk-bin-2.1.3

The SDK package (2.1.3) already includes the runtime packages (2.0.4) for dotnet core.
The reason for including both is that the SDK is available under x64 platforms but not currently arm32 platforms (such as the Rpi)
So for the Rpi or other arm32 platforms you'll need to use just the runtime packages unless the application your running already has the runtime build in.


## ASP .Net Core

Note currently the required ASP .Net core prebuilt runtimes seem to be unavailable for arm32 / rpi

  * https://github.com/aspnet/Universe/issues/554
  * https://www.devtrends.co.uk/blog/installing-the-asp.net-core-2.0-runtime-store-on-linux


## SDK vs Runtime

The SDK packages allow you to use the dotnet cli tool to compile / build C# Code into Managed Applications.
The runtime packages allow you to use the dotnet cli tool to run pre-compiled applications.

Normally when you compile a dotnet core application, you have one of two options.

  * Compile it as a platform independent .dll file which doesn't include the runtime
  * Compile it as a platform specific executable file which does include the runtime - using a runtime identifier

For platform independent .dll files these require the runtime packages on the host to use the dotnet cli tool to run / call the dll to start them as an application.

  * https://stackoverflow.com/questions/43931827/how-to-run-asp-net-core-on-arm-based-custom-linux

