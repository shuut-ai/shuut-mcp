#!/bin/sh
# shuut plugin hook (PostToolUse on shell commands, macOS, Linux and Git Bash on Windows).
# Generated from shared/mcp-hooks/save-to-shuut.sh by scripts/mcp/build-skills.mjs; edits here are overwritten.
# $1 (optional): look at this tool only. SHUUT_SAVE_REMINDER=off or SHUUT_AUTOSAVE=off (the same: 0, off, false or no,
# in any case) turns the note off on this computer; the shuut account's auto-save setting does not change.
# save-to-shuut.awk lists the video files the command wrote; this script keeps the ones that are non-empty regular
# files (test -f / -s: a stat, never an open or a read, so pipes and devices are skipped). Links are not followed into
# risky places: the file itself must not be a link, and a directory link on the way must not point to a network or
# device path (checked with lstat and readlink before anything goes through it). awk comes from the standard PATH
# (command -p), not from directories a project may add. Errors are dropped and it always exits 0.
for v in "${SHUUT_SAVE_REMINDER:-}" "${SHUUT_AUTOSAVE:-}"; do
	case $v in
	0 | [Oo][Ff][Ff] | [Ff][Aa][Ll][Ss][Ee] | [Nn][Oo]) cat >/dev/null 2>&1; exit 0 ;;
	esac
done
h=${0%/*}
t=$(printf '\t')

# 0 if $1 (an absolute path, a link target) is a network, device or kernel path, or has . or .. parts we do not resolve
risky() {
	case $1 in
	//* | \\* | /inet | /inet/* | /dev | /dev/* | /proc | /proc/* | /sys | /sys/* | /net | /net/* | /Network | /Network/* | /afs | /afs/*) return 0 ;;
	*/./* | */../* | */. | */.. | ./* | ../*) return 0 ;;
	esac
	return 1
}

# 0 if a directory on the way to $1 is a link to a risky place (each step is an lstat through links already checked).
# sh has no local variables: the names start with _ so they do not touch the loop's $l and $p
via_risky_link() {
	_a=
	_r=${1#/}
	_n=0
	while :; do
		case $_r in */*) ;; *) return 1 ;; esac
		_a=$_a/${_r%%/*}
		_r=${_r#*/}
		_n=$((_n + 1))
		[ "$_n" -le 64 ] || return 0
		if [ -h "$_a" ]; then
			_k=$(command -p readlink -- "$_a" 2>/dev/null) || return 0
			case $_k in /*) ;; *) _k=${_a%/*}/$_k ;; esac
			risky "$_k" && return 0
		fi
	done
}

c=$(LC_ALL=C command -p awk -v only="${1:-}" -f "$h/save-to-shuut.awk" 2>/dev/null) || exit 0
[ -n "$c" ] || exit 0
printf '%s\n' "$c" | while IFS= read -r l; do
	case $l in
	B) echo B ;;
	C*)
		p=${l%%"$t"*}
		p=${p#C}
		case $p in /*) via_risky_link "$p" && continue ;; esac
		if [ ! -h "$p" ] && [ -f "$p" ] && [ -s "$p" ]; then printf 'N%s\n' "${l#*"$t"}"; fi
		;;
	U*) printf 'N%s\n' "${l#*"$t"}" ;;
	esac
done | LC_ALL=C command -p awk -v mode=emit -f "$h/save-to-shuut.awk" 2>/dev/null
exit 0
