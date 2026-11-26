# shuut plugin hook: after a shell command renders a video file, remind the agent that it can save the video to shuut.
# Generated from shared/mcp-hooks/save-to-shuut.awk by scripts/mcp/build-skills.mjs; edits here are overwritten.
#
# Two passes, both run by save-to-shuut.sh with LC_ALL=C (byte strings):
#   1. (default) stdin: the PostToolUse hook event as JSON (Claude Code, Codex). stdout: the video files the command
#      wrote, one per line: "W<seconds>" first (how recent a file's modification time must be to count as written by
#      this command, see the END block), then "B" (the command runs in the background), "C<path to check><TAB><name>"
#      or "U<TAB><name>" (cannot be checked: variables, globs, relative path after cd). This pass never opens, reads or
#      stats a file: it has no getline, no redirection and no pipes. Paths that could reach the network or a device
#      (//host, \\host, /inet, /dev, /proc, /sys, /net, /Network, /afs) are dropped here, before anything touches the
#      file system.
#   2. (-v mode=emit) stdin: "B" and "N<name>" lines (the files the sh pass found with test -f / -s and a stat of the
#      modification time, which only stat).
#      stdout: nothing, or one JSON object whose hookSpecificOutput.additionalContext tells the agent about the user's
#      shuut auto-save setting and how to save the video with the shuut editor_save tool.
# -v only=<tool>: look at that tool only (Claude Code runs one handler per tool, so each note is added once).
# POSIX awk only (macOS awk, gawk, mawk, busybox): no length(array), no regex intervals, no gsub on backslashes.
# Work is linear in the input: the JSON is split on its quotes once, and the command is read through a small window.

BEGIN {
	if (mode == "emit") { RS = "\n"; NOTE_HEAD = "shuut: this command made a video file ("; NOTE_TAIL = "). If shuut MCP tools are available (maybe after a tool search): auto-save is the user's shuut account setting (on unless off at shuut.ai/account#apps): after handing over the final video, save it as an editable shuut project with editor_save (free); on autosave_off ask once, yes: user_requested true; not if the user said not to. Final videos only. Upload with media_upload: sources as media, the commands you ran as ffmpeg (or your edit as spec), the final render as reference. Always key: the output file path, plus the project_id you got; new: true only if asked. Team or brand work: space team, folder = the matching editor_folders name as listed. End: where it went, open_url."; NOTE_BG = "It is still running in the background: save the video after it finishes." }
	else RS = "\001"
	n = split("ffmpeg remotion handbrakecli mkvmerge mp4box melt", tl, " ")
	for (i = 1; i <= n; i++) if (only == "" || tl[i] == tolower(only)) TOOL[tl[i]] = 1
	# ffmpeg options that take no value (every other option takes one)
	n = split("y n an vn sn dn shortest hide_banner nostdin stdin stats nostats re copyts start_at_zero xerror benchmark benchmark_all autorotate noautorotate accurate_seek noaccurate_seek ignore_unknown copy_unknown dump hex report h help version formats codecs encoders decoders filters pix_fmts layouts sample_fmts colors bsfs protocols devices muxers demuxers hwaccels buildconf L debug_ts bitexact psnr vstats qphist print_graphs", tl, " ")
	for (i = 1; i <= n; i++) FLAG["-" tl[i]] = 1
	n = split("mp4 mov webm matroska", tl, " ")
	for (i = 1; i <= n; i++) VMUX[tl[i]] = 1
	n = split("mp4 mov webm mkv", tl, " ")
	for (i = 1; i <= n; i++) VEXT[tl[i]] = 1
	# ffmpeg's fatal messages (it prints them as it gives up, so they sit at the end of the output). Only messages that
	# end a run: per-frame warnings that a finished render also prints (deprecated pixel format, "Past duration too
	# large", "non monotonically increasing dts", "Application provided invalid, non monotonically ...") stay out, so a
	# real render is not missed. "Invalid argument" and "Permission denied" are the errno text of a failed open, filter
	# or write; "Error reinitializing filters" ends a run when the input size changes midway.
	NFAIL = split("Conversion failed!|Error opening output|Error opening input|Error while opening encoder|Error initializing output stream|Unknown encoder|Unrecognized option|Invalid data found when processing input|Error splitting the argument list|At least one output file must be specified|No such file or directory|Error initializing complex filters|Error initializing filter|Error reinitializing filters|No such filter|Invalid argument|Permission denied|No space left on device|Could not write header|Error writing trailer", FAIL, "|")
	# words that run the next word as the command (with their options), so the tool can come after them
	n = split("nice ionice sudo doas env time timeout nohup stdbuf command exec xargs caffeinate npx bunx pnpm yarn npm bun dlx", tl, " ")
	for (i = 1; i <= n; i++) WRAP[tl[i]] = 1
	n = split("-n -s -k -u -g -p -C -o -e -i", tl, " ")
	for (i = 1; i <= n; i++) VALOPT[tl[i]] = 1
	# shell keywords before the command word of a simple command (for/while ... do X, if ... then X, { X; }, ! X)
	n = split("do then else elif if while until { !", tl, " ")
	for (i = 1; i <= n; i++) KW[tl[i]] = 1
}

mode == "emit" {
	# a file name with a shell variable (out$i.mp4 - a loop's outputs) stands for the files it makes, not one file
	if ($0 == "B") EBG = 1
	else if (substr($0, 1, 1) == "N") { NN++; nm = substr($0, 2); fb = nm; sub(/.*\//, "", fb); if (index(fb, "$")) nm = nm " (the files it makes)"; if (NN <= 3) LIST = LIST (NN > 1 ? ", " : "") nm }
	next
}

{ S = S $0 }

END {
	if (mode == "emit") {
		if (NN == 0) exit 0
		if (NN > 3) LIST = LIST " and " (NN - 3) " more"
		note = NOTE_HEAD LIST NOTE_TAIL
		if (EBG) note = note " " NOTE_BG
		printf "{\"hookSpecificOutput\":{\"hookEventName\":\"PostToolUse\",\"additionalContext\":\"%s\"}}\n", jesc(note)
		exit 0
	}
	# cheap gate: no tool name anywhere in the input, nothing to do (most shell commands end here)
	if (!mentions(S)) exit 0
	# split on every double quote once; an escaped quote is a piece ending in an odd run of backslashes (no gsub: it
	# is quadratic in BWK awk when a big output has many quotes)
	# BWK awk's split on a one-character string also splits on newlines (and a regex separator is quadratic there):
	# raw newlines in JSON are only whitespace between tokens (a trailing one, or pretty-printed input), so make them spaces
	if (index(S, "\n")) gsub(/\n/, " ", S)
	NJ = split(S, J, "\"")
	S = ""
	lex()
	TPI = 1
	if (!BAD) pval("", 0)
	if (BAD || EV != "PostToolUse" || INTR) exit 0
	if (NCV > 0) {
		NT = 0
		for (i = 1; i <= NCV; i++) { NT++; TW[NT] = CV[i]; TK[NT] = "w"; TP[NT] = 1 }
		analyze()
	} else if (CMD != "" && mentions(CMD)) {
		tokenize(CMD); analyze()
	}
	# commands passed to a shell as a string (bash -lc "...", pwsh -Command "...", "$(...)"), a few levels at most
	for (q = 1; q <= NNEST && q <= 8; q++) { tokenize(NEST[q]); analyze() }
	if (NO == 0) exit 0
	# a failed render that still exited 0 (|| true) or Codex, which also reports failed commands: ffmpeg says so at the end
	for (k = RA; k < RB; k++) if (TT[k] == "s") {
		r = tail(TA[k], TB[k], 16384)
		for (i = 1; i <= NFAIL; i++) if (index(r, FAIL[i])) exit 0
	}
	# an output a later command of the same call reads with -i is an intermediate file, not the video to save
	for (i = 1; i <= NO; i++) { nm = OUTL[i]; sub(/^[^\t]*\t/, "", nm); if (!(nrm(nm) in READ)) NK++ }
	if (NK == 0) exit 0
	# W: a checked file counts only if its modification time is at most this many seconds before now (the sh pass
	# compares it with a stat, never opening the file), so an old out.mp4 left by an earlier run is not reported after
	# a render that failed without one of the messages above. ffmpeg (and the other tools) rewrite the header or write
	# the trailer as they finish, so a fresh output's modification time is about the end of the command.
	# Claude Code gives the command's run time (duration_ms): the whole call plus 15 s for the hook to start and for
	# whole-second clocks, so a file written early in a long call still counts. Codex gives no run time and runs the
	# hook in the background (async): a fixed 300 s covers that delay and later steps of the same call (the end of the
	# render is what counts, not its start). Capped so the number stays an integer in every awk.
	if (DUR ~ /^[0-9]+(\.[0-9]*)?$/) { WIN = int(DUR / 1000); if (WIN * 1000 < DUR) WIN++; WIN += 15 } else WIN = 300
	if (WIN > 100000000) WIN = 100000000
	printf "W%d\n", WIN
	if (BG) print "B"
	for (i = 1; i <= NO; i++) { nm = OUTL[i]; sub(/^[^\t]*\t/, "", nm); if (!(nrm(nm) in READ)) print OUTL[i] }
	exit 0
}

# ---- JSON: J[] are the pieces between double quotes; a string token is the pieces TA..TB (joined by quotes) ----

# does piece p end in an odd number of backslashes? (counted from the end in 64-byte steps: linear, not a regex per start)
function oddbs(p,   n, c, k, t, i) {
	n = length(p)
	if (substr(p, n, 1) != "\\") return 0
	c = 0
	while (n > 0) {
		k = (n > 64) ? 64 : n
		t = substr(p, n - k + 1, k)
		for (i = k; i >= 1 && substr(t, i, 1) == "\\"; i--) c++
		if (i >= 1) break
		n -= k
	}
	return c % 2
}

function lex(   k, m) {
	k = 1
	while (1) {
		lexseg(J[k])
		if (BAD || k == NJ) return
		m = k + 1
		while (m < NJ && oddbs(J[m])) m++
		if (m >= NJ) { BAD = 1; return }
		NTK++; TT[NTK] = "s"; TA[NTK] = k + 1; TB[NTK] = m
		k = m + 1
	}
}

function lexseg(seg,   j, m, c) {
	m = length(seg); j = 1
	while (j <= m) {
		c = substr(seg, j, 1)
		if (c == " " || c == "\t" || c == "\n" || c == "\r") { j++; continue }
		if (index("{}[]:,", c)) { NTK++; TT[NTK] = c; j++; continue }
		if (match(substr(seg, j, 40), /^(true|false|null|-?[0-9][-+.eE0-9]*)/)) {
			NTK++; TT[NTK] = "l"; TV[NTK] = substr(seg, j, RLENGTH); j += RLENGTH
			continue
		}
		BAD = 1; return
	}
}

# the raw text of string token k (pieces joined by the quotes between them)
function raw(k,   i, out, blk) {
	out = J[TA[k]]; blk = ""
	for (i = TA[k] + 1; i <= TB[k]; i++) {
		blk = blk "\"" J[i]
		if (i % 256 == 0) { out = out blk; blk = "" }
	}
	return out blk
}

# about the last n bytes of the raw string a..b, without joining the whole of a big output
function tail(a, b, n,   t, i) {
	t = J[b]
	for (i = b - 1; i >= a && length(t) < n; i--) t = J[i] "\"" t
	return t
}

function pval(path, depth,   t, k) {
	if (BAD || TPI > NTK || depth > 64) { BAD = 1; return }
	t = TT[TPI]
	if (path == ".tool_response") RA = TPI
	if (t == "{") {
		TPI++
		if (TT[TPI] == "}") TPI++
		else while (!BAD) {
			if (TT[TPI] != "s") { BAD = 1; break }
			k = jdec(raw(TPI)); TPI++
			if (TT[TPI] != ":") { BAD = 1; break }
			TPI++
			pval(path "." k, depth + 1)
			t = TT[TPI]; TPI++
			if (t == "}") break
			if (t != ",") { BAD = 1; break }
		}
	} else if (t == "[") {
		TPI++
		if (TT[TPI] == "]") TPI++
		else while (!BAD) {
			pval(path "[]", depth + 1)
			t = TT[TPI]; TPI++
			if (t == "]") break
			if (t != ",") { BAD = 1; break }
		}
	} else if (t == "s") {
		if (path == ".hook_event_name") EV = jdec(raw(TPI))
		else if (path == ".cwd") CWD = jdec(raw(TPI))
		else if (path == ".tool_input.command") CMD = jdec(raw(TPI))
		else if (path == ".tool_input.command[]") CV[++NCV] = jdec(raw(TPI))
		TPI++
	} else if (t == "l") {
		if (path == ".tool_input.run_in_background") BG = (TV[TPI] == "true")
		else if (path == ".tool_response.interrupted") INTR = (TV[TPI] == "true")
		else if (path == ".duration_ms") DUR = TV[TPI]
		TPI++
	} else BAD = 1
	if (path == ".tool_response") RB = TPI
}

# raw JSON string -> bytes, in one pass over the pieces between backslashes; control characters become spaces
function jdec(r,   n, P, k, p, e, h, lo, out, blk) {
	if (!index(r, "\\")) return r
	n = split(r, P, "\\")
	out = P[1]; blk = ""
	for (k = 2; k <= n; k++) {
		p = P[k]
		if (p == "") {
			# an escaped backslash: the next piece is plain text
			blk = blk "\\" P[k + 1]; k++
		} else {
			e = substr(p, 1, 1)
			if (e == "u") {
				h = hex4(substr(p, 2, 4))
				if (h >= 55296 && h < 56320 && length(p) == 5 && k < n && substr(P[k + 1], 1, 1) == "u") {
					lo = hex4(substr(P[k + 1], 2, 4))
					if (lo >= 56320 && lo < 57344) { h = 65536 + (h - 55296) * 1024 + (lo - 56320); k++; p = P[k] }
				}
				blk = blk utf8(h) substr(p, 6)
			} else {
				if (e == "n") e = "\n"
				else if (e == "t") e = "\t"
				else if (e == "r" || e == "b" || e == "f") e = " "
				blk = blk e substr(p, 2)
			}
		}
		if (k % 256 == 0) { out = out blk; blk = "" }
	}
	return out blk
}

function hex4(s,   i, v, d) {
	v = 0
	for (i = 1; i <= 4; i++) {
		d = index("0123456789abcdef", tolower(substr(s, i, 1))) - 1
		if (d < 0) return 63
		v = v * 16 + d
	}
	return v
}

function utf8(c) {
	if (c < 32) return " "
	if (c < 128) return sprintf("%c", c)
	if (c >= 55296 && c < 57344) return "?"
	if (c < 2048) return sprintf("%c%c", 192 + int(c / 64), 128 + c % 64)
	if (c < 65536) return sprintf("%c%c%c", 224 + int(c / 4096), 128 + int(c / 64) % 64, 128 + c % 64)
	return sprintf("%c%c%c%c", 240 + int(c / 262144), 128 + int(c / 4096) % 64, 128 + int(c / 64) % 64, 128 + c % 64)
}

function jesc(s,   out, i, n, c) {
	out = ""; n = length(s)
	for (i = 1; i <= n; i++) {
		c = substr(s, i, 1)
		if (c == "\\" || c == "\"") out = out "\\" c
		else if (c == "\n") out = out "\\n"
		else if (c < " ") out = out " "
		else out = out c
	}
	return out
}

# ---- reading the command TS (length TN) through a 1 KB window: awk's substr measures its whole string on every call ----

function cc(i) {
	if (i < WB || i >= WB + 1024) { WB = i; WBUF = substr(TS, i, 1024) }
	return substr(WBUF, i - WB + 1, 1)
}

function findc(from, ch,   w, r) {
	w = 1024
	while (from <= TN) {
		r = index(substr(TS, from, w), ch)
		if (r) return from + r - 1
		from += w
		if (w < 262144) w *= 4
	}
	return 0
}

function finddq(from,   w) {
	w = 1024
	while (from <= TN) {
		if (match(substr(TS, from, w), /["\\$`]/)) return from + RSTART - 1
		from += w
		if (w < 262144) w *= 4
	}
	return 0
}

function parenend(i,   d, c) {
	d = 1
	while (i <= TN) {
		c = cc(i)
		if (c == "(") d++
		else if (c == ")" && --d == 0) return i
		i++
	}
	return TN + 1
}

function nest(x) {
	if (NNEST < 8 && mentions(x)) NEST[++NNEST] = x
}

# ---- POSIX shell words: TW (text), TK (w word, s separator, r1 stdout target, r2 other redirect target, r0 input), TP (1 = plain path, no $ ` or glob) ----

function tokenize(s,   i, c, d, j, fd, kind) {
	TS = s; TN = length(s); WB = -TN - 4096
	NT = 0; CUR = ""; INW = 0; PL = 1; PEND = ""; NHD = 0; NLN = 0
	i = 1
	while (i <= TN) {
		c = cc(i)
		if (c == "'") {
			j = findc(i + 1, "'")
			if (j == 0) j = TN + 1
			CUR = CUR substr(TS, i + 1, j - i - 1); i = j + 1; INW = 1
			continue
		}
		if (c == "\"") { INW = 1; i = dquote(i + 1); continue }
		if (c == "\\") {
			d = cc(i + 1); i += 2
			if (d != "\n") { CUR = CUR d; INW = 1 }
			continue
		}
		if (c == "#" && !INW) {
			j = findc(i, "\n")
			if (j == 0) break
			i = j
			continue
		}
		if (c == " " || c == "\t" || c == "\r") { flush(); i++; continue }
		if (c == "$") {
			d = cc(i + 1)
			if (d == "(") { flush(); sep(); i += 2; continue }
			PL = 0; INW = 1
			if (d == "{") {
				j = findc(i, "}")
				if (j == 0) j = TN
				CUR = CUR substr(TS, i, j - i + 1); i = j + 1
				continue
			}
			CUR = CUR c; i++
			continue
		}
		if (c == "&" && cc(i + 1) == ">") { flush(); c = ">"; i++ }
		if (c == ">" || c == "<") {
			fd = ""
			if (INW && CUR ~ /^[0-9]+$/) { fd = CUR; CUR = ""; INW = 0 } else flush()
			if (c == "<" && cc(i + 1) == "<" && cc(i + 2) != "<") {
				# here-document: the next word is the delimiter, the body (from the next line) is data, not commands
				i += 2; PEND = "h"
				if (cc(i) == "-") { PEND = "h-"; i++ }
				continue
			}
			kind = (c == "<") ? "r0" : ((fd == "" || fd == "1") ? "r1" : "r2")
			i++
			while (cc(i) == ">" || cc(i) == "|" || cc(i) == "<") i++
			if (cc(i) == "&") {
				i++
				while (cc(i) ~ /[0-9-]/) i++
				continue
			}
			PEND = kind
			continue
		}
		if (c == "\n") { flush(); sep(); i = heredocs(i + 1); continue }
		if (c == ";" || c == "&" || c == "|" || c == "(" || c == ")" || c == "`") { flush(); sep(); i++; continue }
		if (c == "*" || c == "?" || c == "[" || c == "{") PL = 0
		CUR = CUR c; INW = 1; i++
	}
	flush()
}

# inside "...": \ escapes, $ and ` make it not a plain path, $(...) and `...` are commands of their own
function dquote(i,   j, c, d, e) {
	while (i <= TN) {
		j = finddq(i)
		if (j == 0) { CUR = CUR substr(TS, i); return TN + 1 }
		if (j > i) CUR = CUR substr(TS, i, j - i)
		c = cc(j)
		if (c == "\"") return j + 1
		if (c == "\\") {
			d = cc(j + 1)
			if (d == "\n") { i = j + 2; continue }
			if (d == "\"" || d == "\\" || d == "$" || d == "`") { CUR = CUR d; i = j + 2; continue }
			CUR = CUR c; i = j + 1
			continue
		}
		PL = 0
		if (c == "$" && cc(j + 1) == "(" && cc(j + 2) != "(") {
			e = parenend(j + 2)
			nest(substr(TS, j + 2, e - j - 2))
			CUR = CUR substr(TS, j, e - j + 1); i = e + 1
			continue
		}
		if (c == "`") {
			e = findc(j + 1, "`")
			if (e == 0) e = TN + 1
			nest(substr(TS, j + 1, e - j - 1))
			CUR = CUR substr(TS, j, e - j + 1); i = e + 1
			continue
		}
		CUR = CUR c; i = j + 1
	}
	return i
}

# skip the bodies of the here-documents opened on the line that just ended; returns where the commands go on.
# The command is split into lines once (LN, LAT = line number at each line start), so many here-documents stay linear
function heredocs(p,   k, h, q, line) {
	if (NHD == 0) return p
	if (!NLN) {
		split("", LAT)
		NLN = split(TS, LN, "\n"); q = 1
		for (k = 1; k <= NLN; k++) { LAT[q] = k; q += length(LN[k]) + 1 }
	}
	k = (p in LAT) ? LAT[p] : NLN + 1
	for (h = 1; h <= NHD; h++) {
		while (k <= NLN) {
			line = LN[k]; p += length(line) + 1; k++
			if (HDT[h]) sub(/^\t+/, "", line)
			sub(/\r$/, "", line)
			if (line == HD[h]) break
		}
	}
	NHD = 0
	return p
}

function flush() {
	if (INW || CUR != "") {
		if (PEND == "h" || PEND == "h-") { NHD++; HD[NHD] = CUR; HDT[NHD] = (PEND == "h-") }
		else { NT++; TW[NT] = CUR; TK[NT] = (PEND != "") ? PEND : "w"; TP[NT] = PL }
		PEND = ""
	}
	CUR = ""; INW = 0; PL = 1
}

function sep() {
	if (PEND != "h" && PEND != "h-") PEND = ""
	if (NT > 0 && TK[NT] != "s") { NT++; TW[NT] = ""; TK[NT] = "s"; TP[NT] = 0 }
}

# ---- which words are video files a tool wrote ----

function analyze(   i, j) {
	i = 1
	while (i <= NT) {
		j = i
		while (j <= NT && TK[j] != "s") j++
		segment(i, j - 1)
		i = j + 1
	}
}

# one simple command TW[a..b]: only its command word counts (after VAR=x and wrappers such as nice, timeout, env, npx
# with their options), so a tool name in echo/printf arguments or a commit message is not a command
function segment(a, b,   k, j, w, lw, tool, sh, wr, vo) {
	if (a <= b && TK[a] == "w") {
		lw = tolower(TW[a])
		if (lw == "cd" || lw == "pushd" || lw == "chdir" || lw == "set-location" || lw == "sl" || lw == "push-location") CD = 1
	}
	wr = 0; vo = 0
	for (k = a; k <= b; k++) {
		if (TK[k] != "w") continue
		w = TW[k]
		if (vo) { vo = 0; continue }
		if (w ~ /^[A-Za-z_][A-Za-z0-9_]*=/) continue
		if (w in KW) continue
		if (base(w) in WRAP) { wr = 1; continue }
		if (wr && w ~ /^-/) { vo = (w in VALOPT); continue }
		if (wr && w ~ /^[0-9][0-9.]*[smhd]?$/) continue
		break
	}
	if (k > b) return
	w = TW[k]
	# the string a shell runs (sh -c, bash -lc, pwsh -Command, cmd /c) is a command; other quoted text is not
	sh = shellkind(w)
	if (sh != "") {
		for (j = k + 1; j <= b; j++) {
			if (TK[j] != "w" || !execflag(sh, TW[j])) continue
			for (j++; j <= b && TK[j] != "w"; j++) ;
			if (j > b) return
			if (TW[j] ~ /[ \t\n;|&]/) nest(TW[j])
			else segment(j, b)
			return
		}
		return
	}
	tool = toolname(w)
	if (tool != "") outputs(tool, k + 1, b)
}

function base(w,   lw) {
	lw = tolower(w)
	sub(/^.*[\/\\]/, "", lw)
	sub(/\.exe$/, "", lw)
	return lw
}

function shellkind(w,   b) {
	b = base(w)
	if (b == "sh" || b == "bash" || b == "zsh" || b == "dash" || b == "ksh" || b == "mksh" || b == "ash" || b == "fish") return "posix"
	if (b == "pwsh" || b == "powershell") return "ps"
	if (b == "cmd") return "cmd"
	return ""
}

function execflag(kind, w,   lw) {
	lw = tolower(w)
	if (kind == "posix") return (lw ~ /^-[a-z]*c[a-z]*$/)
	if (kind == "ps") return (lw ~ /^-c/ && index("-command", lw) == 1)
	return (lw == "/c" || lw == "/k")
}

function mentions(w,   lw, x) {
	lw = tolower(w)
	for (x in TOOL) if (index(lw, x)) return 1
	return 0
}

function toolname(w,   b) {
	b = base(w)
	return (b in TOOL) ? b : ""
}

function isvid(w,   e) {
	if (!match(w, /\.[A-Za-z0-9]+$/)) return 0
	e = tolower(substr(w, RSTART + 1))
	return (e in VEXT)
}

# lexical form of an absolute POSIX path: no //, . or .. segments (so /./net, /tmp/../net and cwd/../../net are seen as /net)
function norm(p,   n, P, D, d, i, out) {
	if (p !~ /^\// || p ~ /^\/\//) return p
	n = split(p, P, "/"); d = 0
	for (i = 2; i <= n; i++) {
		if (P[i] == "" || P[i] == ".") continue
		if (P[i] == "..") { if (d > 0) d--; continue }
		D[++d] = P[i]
	}
	out = ""
	for (i = 1; i <= d; i++) out = out "/" D[i]
	return (out == "") ? "/" : out
}

# could this path reach the network, a device or the kernel? (checked on the lexical form, before anything looks at the
# file system; links on the way are checked by the sh pass)
function unsafe(p) {
	p = norm(p)
	return (p ~ /^[\/\\][\/\\]/ || p ~ /^\/(inet|dev|proc|sys|net|Network|afs)(\/|$)/)
}

# one output file: "C<path to stat><TAB><name>", or "U<TAB><name>" when it cannot be checked; risky paths are dropped
function addout(w, plain,   q) {
	AO++
	if (w == "" || (w in SEEN) || w ~ /[\t\n\r]/ || unsafe(w)) return
	SEEN[w] = 1; WROTE[nrm(w)] = 1
	if (BG || !plain || index(w, "%")) { OUTL[++NO] = "U\t" w; return }
	q = w
	if (substr(q, 1, 2) == "~/") {
		if (ENVIRON["HOME"] == "") { OUTL[++NO] = "U\t" w; return }
		q = ENVIRON["HOME"] substr(q, 2)
	} else if (q !~ /^\// && q !~ /^[A-Za-z]:[\/\\]/) {
		if (q ~ /^\\/ || CD || CWD == "") { OUTL[++NO] = "U\t" w; return }
		q = CWD "/" q
	}
	if (unsafe(q) || q ~ /[\t\n\r]/) return
	OUTL[++NO] = "C" q "\t" w
}

# the same name without leading ./ (so a later -i ./a.mp4 matches an output a.mp4)
function nrm(w) {
	while (substr(w, 1, 2) == "./") w = substr(w, 3)
	return w
}

function outputs(tool, a, b,   k, w, lw, kind, expect, opt, fmt, vn, bs, a0, ni, j) {
	expect = 0; fmt = ""; vn = 0; a0 = AO; ni = 0
	for (k = a; k <= b; k++) {
		w = TW[k]; kind = TK[k]
		if (kind == "r1") { if (isvid(w)) addout(w, TP[k]); continue }
		if (kind != "w") continue
		if (tool == "ffmpeg") {
			if (expect) {
				expect = 0
				if (opt == "-i") { fmt = ""; vn = 0; if (nrm(w) in WROTE) INL[++ni] = nrm(w) }
				else if (opt == "-f") fmt = tolower(w)
				else if (w !~ /=/ && isvid(w)) addout(w, TP[k])
				continue
			}
			if (w ~ /^-[^0-9]/) {
				bs = w
				sub(/:.*/, "", bs)
				if (bs == "-vn") vn = 1
				if (!(bs in FLAG)) { expect = 1; opt = bs }
				continue
			}
			if (w != "-" && w !~ /^pipe:/ && w !~ /^\/dev\// && fmt != "null" && !vn) {
				if (fmt == "" ? isvid(w) : (fmt in VMUX)) addout(w, TP[k])
			}
			fmt = ""; vn = 0
			continue
		}
		lw = tolower(w)
		if (expect) { expect = 0; if (isvid(w)) addout(w, TP[k]); continue }
		if (lw == "-o" || lw == "--output" || lw == "-out" || lw == "-new") { expect = 1; continue }
		if (lw ~ /^(-o|--output|-out)=/) { w = substr(w, index(w, "=") + 1); if (isvid(w)) addout(w, TP[k]); continue }
		if (tool == "melt" && lw ~ /^(avformat:|target=)/) { w = substr(w, (lw ~ /^avformat:/) ? 10 : 8); if (isvid(w)) addout(w, TP[k]); continue }
		if ((tool == "remotion" || tool == "mp4box") && k > a && TW[k - 1] !~ /^-/ && isvid(w)) addout(w, TP[k])
	}
	# the inputs of a command that writes a video are intermediate files when an earlier command wrote them; a command that
	# only checks a video (-f null -, a still frame) writes no video, so its input stays the final video
	if (AO > a0) for (j = 1; j <= ni; j++) READ[INL[j]] = 1
}
