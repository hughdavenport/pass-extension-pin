#!/usr/bin/env bash
# pass pin - Password Store Extension (https://www.passwordstore.org/)
# Copyright (C) 2017 Hugh Davenport
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
# []

GENERATED_LENGTH=8

cmd_pin_usage() {
	cat <<-_EOF
	Usage:
	    $PROGRAM pin generate [--clip,-c] [--in-place,-i | --force,-f] pass-name [pin-length]
	        Generate an *numeric* pin code of pass-length (or 8 if unspecified)
	        Optionally put it on the clipboard and clear board after $CLIP_TIME seconds.
	        Optionally replace only the first line of an existing file with a new pin.
	_EOF
	exit 0
}

cmd_pin_generate() {
	local opts qrcode=0 clip=0 force=0 characters="$CHARACTER_SET" inplace=0 pass
	opts="$($GETOPT -o qcif -l qrcode,clip,in-place,force -n "$PROGRAM" -- "$@")"
	local err=$?
	eval set -- "$opts"
	while true; do case $1 in
		-q|--qrcode) qrcode=1; shift ;;
		-c|--clip) clip=1; shift ;;
		-f|--force) force=1; shift ;;
		-i|--in-place) inplace=1; shift ;;
		--) shift; break ;;
	esac done

	[[ $err -ne 0 || ( $# -ne 2 && $# -ne 1 ) || ( $force -eq 1 && $inplace -eq 1 ) || ( $qrcode -eq 1 && $clip -eq 1 ) ]] && die "Usage: $PROGRAM $COMMAND generate [--clip,-c] [--qrcode,-q] [--in-place,-i | --force,-f] pass-name [pass-length]"
	local path="$1"
	local length="${2:-$GENERATED_LENGTH}"
	check_sneaky_paths "$path"
	[[ ! $length =~ ^[0-9]+$ ]] && die "Error: pass-length \"$length\" must be a number."
	mkdir -p -v "$PREFIX/$(dirname "$path")"
	set_gpg_recipients "$(dirname "$path")"
	local passfile="$PREFIX/$path.gpg"
	set_git "$passfile"

	[[ $inplace -eq 0 && $force -eq 0 && -e $passfile ]] && yesno "An entry already exists for $path. Overwrite it?"

	read -r -n $length pass < <(LC_ALL=C tr -dc "[:digit:]" < /dev/urandom)
	[[ ${#pass} -eq $length ]] || die "Could not generate password from /dev/urandom."
	if [[ $inplace -eq 0 ]]; then
		$GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile" "${GPG_OPTS[@]}" <<<"$pass" || die "Password encryption aborted."
	else
		local passfile_temp="${passfile}.tmp.${RANDOM}.${RANDOM}.${RANDOM}.${RANDOM}.--"
		if $GPG -d "${GPG_OPTS[@]}" "$passfile" | sed $'1c \\\n'"$(sed 's/[\/&]/\\&/g' <<<"$pass")"$'\n' | $GPG -e "${GPG_RECIPIENT_ARGS[@]}" -o "$passfile_temp" "${GPG_OPTS[@]}"; then
			mv "$passfile_temp" "$passfile"
		else
			rm -f "$passfile_temp"
			die "Could not reencrypt new password."
		fi
	fi
	local verb="Add"
	[[ $inplace -eq 1 ]] && verb="Replace"
	git_add_file "$passfile" "$verb generated password for ${path}."

	if [[ $clip -eq 1 ]]; then
		clip "$pass" "$path"
	elif [[ $qrcode -eq 1 ]]; then
		qrcode "$pass" "$path"
	else
		printf "\e[1m\e[37mThe generated password for \e[4m%s\e[24m is:\e[0m\n\e[1m\e[93m%s\e[0m\n" "$path" "$pass"
	fi
}

case "$1" in
	help|--help|-h) shift;	cmd_pin_usage "$@" ;;
	generate) shift;	cmd_pin_generate "$@" ;;
	*)			cmd_show "$@" ;;
esac
exit 0
