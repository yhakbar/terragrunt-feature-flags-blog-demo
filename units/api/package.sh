#!/usr/bin/env bash

set -euo pipefail

package() {
	local -r src_directory="$1"
	local -r dist_directory="$2"
	local -r architecture="$3"

	pushd "$src_directory" >/dev/null
	GOOS=linux GOARCH="$architecture" go build -o bootstrap
	zip "$dist_directory"/package.zip bootstrap
	popd >/dev/null
}

main() {
	local -r src_directory="$(realpath "$1")"
	local dist_directory="$2"
	local architecture="$3"

	mkdir -p "$dist_directory"
	dist_directory="$(realpath "$dist_directory")"

	# Normalize architecture value
	case "$architecture" in
	"x86_64")
		architecture="amd64"
		;;
	"arm64")
		architecture="arm64"
		;;
	*)
		echo "Unsupported architecture: $architecture"
		exit 1
		;;
	esac

	package "$src_directory" "$dist_directory" "$architecture"
}

: "${1?"Usage: $0 <src_directory> <dist_directory> <architecture>"}"
: "${2?"Usage: $0 <src_directory> <dist_directory> <architecture>"}"
: "${3?"Usage: $0 <src_directory> <dist_directory> <architecture>"}"

main "$@"
