Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

inherit mono-env

DESCRIPTION="The F# Compiler"
HOMEPAGE="https://github.com/fsharp/fsharp"
SRC_URI="https://github.com/fsharp/fsharp/archive/${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="Apache-2.0"
SLOT="0"
#Broken: Microsoft.FSharp.Targets(129,9): error MSB4127: The "CreateFSharpManifestResourceName" task could not be instantiated from the assembly "/var/tmp/portage/dev-lang/fsharp-10.2.1/work/fsharp-10.2.1/packages/FSharp.Compiler.Tools.4.1.27/tools/FSharp.Build.dll". Please verify the task assembly has been built using the same version of the Microsoft.Build.Framework assembly as the one installed on your computer and that your host application is not missing a binding redirect for Microsoft.Build.Framework. Specified cast is not valid. [/var/tmp/portage/dev-lang/fsharp-10.2.1/work/fsharp-10.2.1/src/fsharp/FSharp.Core/FSharp.Core.fsproj]
#KEYWORDS="~x86 ~amd64"
IUSE=""

MAKEOPTS+=" -j1" #nowarn
DEPEND=">=dev-lang/mono-5
	dev-util/msbuild"
RDEPEND="${DEPEND}"

# try to sync certificates
# deprecated way: mozroots --import --sync --machine
pkg_setup() {
	#this is horrible, I know
	addwrite "/usr/share/.mono/keypairs"
	addwrite "/etc/ssl/certs/ca-certificates.crt"
	addwrite "/etc/mono/registry"
	cert-sync /etc/ssl/certs/ca-certificates.crt
}
