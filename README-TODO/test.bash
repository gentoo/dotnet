#!/bin/bash

# Given an absolute path such as /lib/fhfghf/./..////.//, sanitise_absolute_path
# will produce the sanitised version: /lib
# It is assumed that all path elements are directories.

sanitise_absolute_path() {
	set -f
	local new_p element finished i saved savedp="$1/"
	local -a __path
	if [[ "${savedp:0:1}" != "/" ]]
	then
		die "${FUNCNAME[1]} passed a non-absolute path to ${FUNCNAME[0]}" >> 1.e
	fi

	for ((i=0 ; i<=${#savedp} ; i++))
	do
		if [[ "${savedp:$i:1}" = "/" ]]
		then
			if [[ "$saved" ]]
			then
				__path=( "${__path[@]}" "${saved}" )
				unset saved
			fi
		else
			saved="${saved}${savedp:$i:1}"
		fi
	done
	until [[ $finished = true ]]
	do
		unset finished
		__path=( "${__path[@]}" )
		local i=0
		for element in "${__path[@]}"
		do
			if [[ "$element" = ".." ]]
			then
				if [[ $i != 0 ]]
				then
					unset __path[$i]
					unset __path[$(( $i -1 ))]
					finished=false
					break
				else
					#Do we want to die here? Parsing has brought us below /
					#*loki_val chokes whoever decided that .. when in /
					#should be allowed*
					unset __path[$i]
					finished=false
					break
				fi
			elif [[ "$element" = "." ]]
			then
				unset __path[$i]
				finished=false
				break
			fi
			__path[$i]="/${__path[$i]#/}"
			i=$(($i + 1))
		done
		[[ $finished = false ]] || finished=true
	done
	echo '__path='"${__path[@]}" >> 1.e
	echo '#__path='"${#__path[@]}" >> 1.e

	[[ "${#__path[@]}" = "0" ]] && new_p="/"

	for ((i=0 ; i<=$(( ${#__path[@]} -1 )) ; i++))
	do
		new_p="$new_p${__path[$i]}"
	done
	echo "$new_p" >> 1.e
	echo "$new_p"
}

# Takes two arguments, path $1 and path $2, both of which must be directories,
# and produces the relative path between them. The paths may be 'dirty'.
# For example: "/usr/lib32/./snark/../herring/red" "/usr/lib64///.//scotch/../rocks/../soda"
# Produces: ../../../lib64/soda

get_relative_path_from_to() {
	local -a frompath topath
	local relpath
	local saved i var

	#All paths must end in /, since that's the delimiter in our parsing loop.
	tmpfrompath="$(sanitise_absolute_path "$1")/"
	tmptopath="$(sanitise_absolute_path "$2")/"

	echo ${tmptopath[@]} >> 1.e

	#Early escape for the unhandled case.
	if [[ "${tmpfrompath}" = "//" ]]
	then
		tmptopath="${tmptopath:1}"
		echo "${tmptopath%/}"
		return 0
	fi

	#DRAGONS. They be here. Eval foo to avoid repeating this giant-ass loop.
	#
	for var in tmpfrompath tmptopath
	do
		unset saved i
		arrname=${var:3}
		for ((i=0 ; i<=$( eval echo '${#'${var}'}' ) ; i++))
		do
			if [[ "$( eval echo '${'${var}':$i:1}' )" = "/" ]]
			then
				if [[ -n "$saved" ]]
				then
					eval ${arrname}'=( "${'${arrname}'[@]}" "${saved}" )'
					unset saved
				fi
			else
				eval 'saved="${saved}${'${var}':$i:1}"'
			fi
		done
	done

	#Iterative loop, compares each element in ${frompath[@]} and ${topath[@]}.
	#When we reach a point of divergence, the relative path is found and
	#we then break from the loop.
	echo ${topath[@]} >> 1.e
	for (( i=0; i<=$(( ${#frompath[@]} - 1 )) ; i++))
	do
		if [[ "${topath[$i]}" != "${frompath[$i]}" ]]
		then
			savei=$i
			for (( loop1=$i; loop1<=$(( ${#frompath[@]} - 1 )); loop1++ ))
			do
				relpath="${relpath}../"
			done
			relpath=${relpath%/}

			while [[ ${#topath[@]} -ge ${savei} ]]
			do
				echo ${topath[@]} >> 1.e
				relpath="$relpath/${topath[$savei]}"
				savei=$(($savei + 1))
			done
			break
		fi
		shift
	done
	echo "${relpath%/}"
}

if [[ "$1" = "test" ]]
then
	declare answer
	declare -a test1 test2 result
	test1[1]='/usr/lib/957'
	test2[1]='/var/home/standard'
	result[1]='../../../var/home/standard'

	test1[2]='/usr/lib/957'
	test2[2]='/var/snort/../home/standard'
	result[2]='../../../var/home/standard'

	test1[3]='/ /usr/lib/957'
	test2[3]='/ /var/snort/../home/standard'
	result[3]='../../../var/home/standard'

	test1[4]='/'
	test2[4]='/ /var/snort/../home/standard'
	result[4]=' /var/home/standard'

	test1[5]='//////usr/include///.//../libexec/../'
	test2[5]='///home/pa/.config/../../../etc/../lib64/../home/pa/.config/banshee'
	result[5]='../home/pa/.config/banshee'

	test1[6]='/usr/lib32/./snark/../herring/red'
	test2[6]='/usr/lib64///.//scotch/../rocks/../soda'
	result[6]='../../../lib64/soda'

	test1[7]='/                          / /'
	test2[7]='/usr/'
	result[7]='../../usr'

	for ((i=1 ; i<=${#test1[@]} ; i++))
	do
		answer="$(get_relative_path_from_to "${test1[$i]}" "${test2[$i]}")"
		echo "From directory: ${test1[$i]}"
		echo "To Directory: ${test2[$i]}"
		echo "answer to test $i was '${answer}'"
		echo "correct answer was '${result[$i]}'"
		if [[ "${result[$i]}" = "${answer}" ]]
		then
			echo "Answer was correct"
		else
			echo "Answer was wrong. Testsuite failed."
		fi
	done
else
	get_relative_path_from_to "$1" "$2"
fi

