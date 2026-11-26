# shuut plugin hook: after a shell command renders a video file, remind the agent that it can save the video to shuut.
# Generated from shared/mcp-hooks/save-to-shuut.ps1 by scripts/mcp/build-skills.mjs; edits here are overwritten.
# Windows PowerShell 5.1 and PowerShell 7. Same rules as save-to-shuut.awk, with PowerShell quoting.
#
# stdin:  the PostToolUse hook event as JSON (Claude Code PowerShell tool, Codex on Windows).
# stdout: nothing, or one JSON object whose hookSpecificOutput.additionalContext tells the agent about the user's
#         shuut auto-save setting and how to save the video with the shuut editor_save tool.
# $args[0] (optional): look at this tool only. SHUUT_SAVE_REMINDER=off or SHUUT_AUTOSAVE=off (the same: 0, off, false
# or no, in any case) turns the note off on this computer; the shuut account's auto-save setting does not change.
# It reads the event JSON and, to skip failed renders, asks the file system whether a named output file is a
# non-empty regular file modified during this command (Get-Item: attributes and LastWriteTimeUtc only, never opens or
# reads it). Paths that could reach the network or a device (\\host, //host, \\?\, /dev, /proc, ...) are dropped
# before that. It sends nothing anywhere, writes no files and always exits 0.

$Only = ''
if ($args.Count -gt 0) { $Only = ([string]$args[0]).ToLowerInvariant() }
$Tools = @('ffmpeg remotion handbrakecli mkvmerge mp4box melt'.Split(' ') | Where-Object { -not $Only -or $_ -eq $Only })
$NoteHead = 'shuut: this command made a video file ('
$NoteTail = '). If shuut MCP tools are available (maybe after a tool search): auto-save is the user''s shuut account setting (on unless off at shuut.ai/account#apps): after handing over the final video, save it as an editable shuut project with editor_save (free); on autosave_off ask once, yes: user_requested true; not if the user said not to. Final videos only. Upload with media_upload: sources as media, the commands you ran as ffmpeg (or your edit as spec), the final render as reference. Always key: the output file path, plus the project_id you got; new: true only if asked. Team or brand work: space team, folder = the matching editor_folders name as listed. End: where it went, open_url.'
$NoteBg = 'It is still running in the background: save the video after it finishes.'
$Flags = @{}
foreach ($f in 'y n an vn sn dn shortest hide_banner nostdin stdin stats nostats re copyts start_at_zero xerror benchmark benchmark_all autorotate noautorotate accurate_seek noaccurate_seek ignore_unknown copy_unknown dump hex report h help version formats codecs encoders decoders filters pix_fmts layouts sample_fmts colors bsfs protocols devices muxers demuxers hwaccels buildconf L debug_ts bitexact psnr vstats qphist print_graphs'.Split(' ')) { $Flags['-' + $f] = $true }
$VMux = @('mp4', 'mov', 'webm', 'matroska')
$VExt = @('mp4', 'mov', 'webm', 'mkv')
# ffmpeg's fatal messages; the same list as save-to-shuut.awk (see the reasons there)
$Fails = @('Conversion failed!', 'Error opening output', 'Error opening input', 'Error while opening encoder', 'Error initializing output stream', 'Unknown encoder', 'Unrecognized option', 'Invalid data found when processing input', 'Error splitting the argument list', 'At least one output file must be specified', 'No such file or directory', 'Error initializing complex filters', 'Error initializing filter', 'Error reinitializing filters', 'No such filter', 'Invalid argument', 'Permission denied', 'No space left on device', 'Could not write header', 'Error writing trailer')

function Test-Video([string]$w) {
  $m = [regex]::Match($w, '\.([A-Za-z0-9]+)$')
  return ($m.Success -and ($VExt -contains $m.Groups[1].Value.ToLowerInvariant()))
}

function Get-ToolName([string]$w) {
  $n = ($w.ToLowerInvariant() -replace '^.*[/\\]', '') -replace '\.exe$', ''
  if ($Tools -contains $n) { return $n }
  return ''
}

# PowerShell words. K: w word, s separator, r1 stdout target, r2 other redirect target, r0 input. P: plain path (no $, glob).
function Split-Command([string]$s) {
  $toks = New-Object System.Collections.Generic.List[object]
  $cur = New-Object System.Text.StringBuilder
  $st = @{ inw = $false; pl = $true; pend = '' }
  $flush = {
    if ($st.inw -or $cur.Length -gt 0) {
      $kind = 'w'
      if ($st.pend) { $kind = $st.pend }
      $toks.Add([pscustomobject]@{ W = $cur.ToString(); K = $kind; P = $st.pl })
      $st.pend = ''
    }
    [void]$cur.Clear(); $st.inw = $false; $st.pl = $true
  }
  $sep = {
    $st.pend = ''
    if ($toks.Count -gt 0 -and $toks[$toks.Count - 1].K -ne 's') { $toks.Add([pscustomobject]@{ W = ''; K = 's'; P = $false }) }
  }
  $n = $s.Length; $i = 0
  while ($i -lt $n) {
    $c = [string]$s[$i]
    $d = ''
    if ($i + 1 -lt $n) { $d = [string]$s[$i + 1] }
    if ($c -eq "'") {
      $i++; $st.inw = $true
      while ($i -lt $n) {
        if ($s[$i] -eq "'") {
          if ($i + 1 -lt $n -and $s[$i + 1] -eq "'") { [void]$cur.Append("'"); $i += 2; continue }
          $i++; break
        }
        [void]$cur.Append($s[$i]); $i++
      }
      continue
    }
    if ($c -eq '"') {
      $i++; $st.inw = $true
      while ($i -lt $n) {
        $e = [string]$s[$i]
        if ($e -eq '"') {
          if ($i + 1 -lt $n -and $s[$i + 1] -eq '"') { [void]$cur.Append('"'); $i += 2; continue }
          $i++; break
        }
        if ($e -eq '`' -and $i + 1 -lt $n) {
          $x = [string]$s[$i + 1]
          if ($x -ceq 'n') { [void]$cur.Append("`n") } elseif ($x -ceq 't') { [void]$cur.Append("`t") } elseif ($x -ne "`n") { [void]$cur.Append($x) }
          $i += 2; continue
        }
        if ($e -eq '$') {
          $st.pl = $false
          if ($i + 1 -lt $n -and $s[$i + 1] -eq '(') {
            # $( ... ) inside a string is a command of its own
            $dep = 1; $j = $i + 2
            while ($j -lt $n -and $dep -gt 0) { if ($s[$j] -eq '(') { $dep++ } elseif ($s[$j] -eq ')') { $dep-- }; $j++ }
            Add-Nested $s.Substring($i + 2, [Math]::Max(0, $j - $i - 3))
            [void]$cur.Append($s.Substring($i, $j - $i)); $i = $j; continue
          }
        }
        [void]$cur.Append($e); $i++
      }
      continue
    }
    if ($c -eq '`') {
      if ($d -ne "`n" -and $d -ne "`r" -and $d -ne '') { [void]$cur.Append($d); $st.inw = $true }
      $i += 2
      if ($d -eq "`r" -and $i -lt $n -and $s[$i] -eq "`n") { $i++ }
      continue
    }
    if ($c -eq '#' -and -not $st.inw) {
      $j = $s.IndexOf("`n", $i)
      if ($j -lt 0) { break }
      $i = $j; continue
    }
    if ($c -eq ' ' -or $c -eq "`t" -or $c -eq "`r") { . $flush; $i++; continue }
    if ($c -eq '$' -or $c -eq '@') {
      if ($d -eq '(') { . $flush; . $sep; $i += 2; continue }
      if ($c -eq '$') {
        $st.pl = $false; $st.inw = $true
        if ($d -eq '{') {
          $j = $s.IndexOf('}', $i)
          if ($j -lt 0) { $j = $n - 1 }
          [void]$cur.Append($s.Substring($i, $j - $i + 1)); $i = $j + 1; continue
        }
      }
      [void]$cur.Append($c); $st.inw = $true; $i++; continue
    }
    if ($c -eq '>' -or $c -eq '<') {
      $fd = ''
      if ($st.inw -and $cur.ToString() -match '^[0-9*]+$') { $fd = $cur.ToString(); [void]$cur.Clear(); $st.inw = $false } else { . $flush }
      if ($c -eq '<') { $kind = 'r0' } elseif ($fd -eq '' -or $fd -eq '1') { $kind = 'r1' } else { $kind = 'r2' }
      $i++
      while ($i -lt $n -and $s[$i] -eq '>') { $i++ }
      if ($i -lt $n -and $s[$i] -eq '&') {
        $i++
        while ($i -lt $n -and ([string]$s[$i]) -match '[0-9-]') { $i++ }
        continue
      }
      $st.pend = $kind
      continue
    }
    if ($c -eq "`n" -or $c -eq ';' -or $c -eq '&' -or $c -eq '|' -or $c -eq '(' -or $c -eq ')' -or $c -eq '{' -or $c -eq '}') { . $flush; . $sep; $i++; continue }
    if ($c -eq '*' -or $c -eq '?' -or $c -eq '[') { $st.pl = $false }
    [void]$cur.Append($c); $st.inw = $true; $i++
  }
  . $flush
  return , $toks
}

# lexical form of an absolute POSIX path: no //, . or .. segments (so /./net and /tmp/../net are seen as /net)
function Get-Norm([string]$p) {
  if (-not $p.StartsWith('/') -or $p.StartsWith('//')) { return $p }
  $d = New-Object System.Collections.Generic.List[string]
  foreach ($s in $p.Split('/')) {
    if ($s -eq '' -or $s -eq '.') { continue }
    if ($s -eq '..') { if ($d.Count -gt 0) { $d.RemoveAt($d.Count - 1) }; continue }
    $d.Add($s)
  }
  return '/' + ($d -join '/')
}

# could this path reach the network, a device or the kernel? (checked on the lexical form, before anything looks at the file system)
function Test-Unsafe([string]$p) {
  $p = Get-Norm $p
  return ($p -match '^[\\/][\\/]' -or $p -cmatch '^/(inet|dev|proc|sys|net|Network|afs)(/|$)')
}

# words that run the next word as the command (with their options), so the tool can come after them
$Wrap = @('nice', 'ionice', 'sudo', 'doas', 'env', 'time', 'timeout', 'nohup', 'stdbuf', 'command', 'exec', 'xargs', 'caffeinate', 'npx', 'bunx', 'pnpm', 'yarn', 'npm', 'bun', 'dlx')
$ValOpt = @('-n', '-s', '-k', '-u', '-g', '-p', '-C', '-o', '-e', '-i')
# shell keywords before the command word of a simple command (for/while ... do X, if ... then X, { X; }, ! X)
$Kw = @('do', 'then', 'else', 'elif', 'if', 'while', 'until', '{', '!')

function Add-Nested([string]$x) {
  if ($script:Queue.Count -ge 8) { return }
  $lx = $x.ToLowerInvariant()
  foreach ($tool in $Tools) { if ($lx.Contains($tool)) { $script:Queue.Add($x); return } }
}

# the same name without leading ./ (so a later -i ./a.mp4 matches an output a.mp4)
function Get-Nrm([string]$w) { while ($w.StartsWith('./')) { $w = $w.Substring(2) }; return $w }

function Add-Out([string]$w, [bool]$plain) {
  $script:Ao++
  if ($w -eq '' -or $script:Seen.ContainsKey($w) -or $w -match '[\t\r\n]' -or (Test-Unsafe $w)) { return }
  $script:Seen[$w] = $true
  $script:Wrote[(Get-Nrm $w)] = $true
  $script:Outs.Add([pscustomobject]@{ W = $w; P = $plain })
}

function Find-Outputs([string]$tool, $toks, [int]$a, [int]$b) {
  $expect = $false; $opt = ''; $fmt = ''; $vn = $false; $a0 = $script:Ao; $inl = New-Object System.Collections.Generic.List[string]
  for ($k = $a; $k -le $b; $k++) {
    $t = $toks[$k]; $w = $t.W
    if ($t.K -eq 'r1') { if (Test-Video $w) { Add-Out $w $t.P }; continue }
    if ($t.K -ne 'w') { continue }
    if ($tool -eq 'ffmpeg') {
      if ($expect) {
        $expect = $false
        if ($opt -ceq '-i') { $fmt = ''; $vn = $false; $nw = Get-Nrm $w; if ($script:Wrote.ContainsKey($nw)) { $inl.Add($nw) } }
        elseif ($opt -ceq '-f') { $fmt = $w.ToLowerInvariant() }
        elseif ($w -notmatch '=' -and (Test-Video $w)) { Add-Out $w $t.P }
        continue
      }
      if ($w -cmatch '^-[^0-9]') {
        $base = $w -replace ':.*$', ''
        if ($base -ceq '-vn') { $vn = $true }
        if (-not $Flags.ContainsKey($base)) { $expect = $true; $opt = $base }
        continue
      }
      if ($w -ne '-' -and $w -notmatch '^pipe:' -and $w -notmatch '^/dev/' -and $fmt -ne 'null' -and -not $vn) {
        if ($fmt -eq '') { $isv = Test-Video $w } else { $isv = $VMux -contains $fmt }
        if ($isv) { Add-Out $w $t.P }
      }
      $fmt = ''; $vn = $false
      continue
    }
    $lw = $w.ToLowerInvariant()
    if ($expect) { $expect = $false; if (Test-Video $w) { Add-Out $w $t.P }; continue }
    if ($lw -eq '-o' -or $lw -eq '--output' -or $lw -eq '-out' -or $lw -eq '-new') { $expect = $true; continue }
    if ($lw -match '^(-o|--output|-out)=') { $v = $w.Substring($w.IndexOf('=') + 1); if (Test-Video $v) { Add-Out $v $t.P }; continue }
    if ($tool -eq 'melt' -and $lw -match '^(avformat:|target=)') { $v = $w.Substring($Matches[1].Length); if (Test-Video $v) { Add-Out $v $t.P }; continue }
    if (($tool -eq 'remotion' -or $tool -eq 'mp4box') -and $k -gt $a -and $toks[$k - 1].W -notmatch '^-' -and (Test-Video $w)) { Add-Out $w $t.P }
  }
  # the inputs of a command that writes a video are intermediate files when an earlier command wrote them; a command that
  # only checks a video (-f null -, a still frame) writes no video, so its input stays the final video
  if ($script:Ao -gt $a0) { foreach ($x in $inl) { $script:Read[$x] = $true } }
}

function Get-ShellKind([string]$w) {
  $b = ($w.ToLowerInvariant() -replace '^.*[/\\]', '') -replace '\.exe$', ''
  if (@('sh', 'bash', 'zsh', 'dash', 'ksh', 'mksh', 'ash', 'fish') -contains $b) { return 'posix' }
  if ($b -eq 'pwsh' -or $b -eq 'powershell') { return 'ps' }
  if ($b -eq 'cmd') { return 'cmd' }
  return ''
}

function Test-ExecFlag([string]$kind, [string]$w) {
  $lw = $w.ToLowerInvariant()
  if ($kind -eq 'posix') { return ($lw -cmatch '^-[a-z]*c[a-z]*$') }
  if ($kind -eq 'ps') { return ($lw.StartsWith('-c') -and '-command'.StartsWith($lw)) }
  return ($lw -eq '/c' -or $lw -eq '/k')
}

# one simple command $toks[a..b]: only its command word counts (after VAR=x and wrappers such as nice, timeout, env, npx
# with their options), so a tool name in Write-Output/echo arguments or a commit message is not a command
function Search-Segment($toks, [int]$a, [int]$b) {
  if ($a -le $b -and $toks[$a].K -eq 'w' -and @('cd', 'pushd', 'chdir', 'set-location', 'sl', 'push-location') -contains $toks[$a].W.ToLowerInvariant()) { $script:Cd = $true }
  $wr = $false; $vo = $false
  for ($k = $a; $k -le $b; $k++) {
    $w = $toks[$k].W
    if ($toks[$k].K -ne 'w') { continue }
    if ($vo) { $vo = $false; continue }
    if ($w -match '^[A-Za-z_][A-Za-z0-9_]*=') { continue }
    if ($Kw -ccontains $w) { continue }
    $bw = ($w.ToLowerInvariant() -replace '^.*[/\\]', '') -replace '\.exe$', ''
    if ($Wrap -contains $bw) { $wr = $true; continue }
    if ($wr -and $w.StartsWith('-')) { $vo = ($ValOpt -ccontains $w); continue }
    if ($wr -and $w -match '^[0-9][0-9.]*[smhd]?$') { continue }
    break
  }
  if ($k -gt $b) { return }
  $w = $toks[$k].W
  # the string a shell runs (sh -c, bash -lc, pwsh -Command, cmd /c) is a command; other quoted text is not
  $sh = Get-ShellKind $w
  if ($sh) {
    for ($j = $k + 1; $j -le $b; $j++) {
      if ($toks[$j].K -ne 'w' -or -not (Test-ExecFlag $sh $toks[$j].W)) { continue }
      $j++
      while ($j -le $b -and $toks[$j].K -ne 'w') { $j++ }
      if ($j -gt $b) { return }
      if ($toks[$j].W -match '[\s;|&]') { Add-Nested $toks[$j].W } else { Search-Segment $toks $j $b }
      return
    }
    return
  }
  $tool = Get-ToolName $w
  if ($tool) { Find-Outputs $tool $toks ($k + 1) $b }
}

function Search-Command($toks) {
  $i = 0
  while ($i -lt $toks.Count) {
    $j = $i
    while ($j -lt $toks.Count -and $toks[$j].K -ne 's') { $j++ }
    Search-Segment $toks $i ($j - 1)
    $i = $j + 1
  }
}

# true if a directory on the way to $q is a link (symlink, junction) to a network or device path, or one we cannot read
function Test-RiskyLink([string]$q) {
  $sep = [char[]]@('/', '\')
  $parts = $q.Split($sep)
  $a = $parts[0]
  for ($n = 1; $n -lt $parts.Count - 1; $n++) {
    if ($parts[$n] -eq '') { continue }
    if ($a -eq '') { $a = '/' + $parts[$n] } else { $a = $a.TrimEnd($sep) + [System.IO.Path]::DirectorySeparatorChar + $parts[$n] }
    $d = Get-Item -LiteralPath $a -Force -ErrorAction Stop
    if (-not ($d.Attributes -band [System.IO.FileAttributes]::ReparsePoint)) { continue }
    $l = @($d.Target)[0]
    if (-not $l) { return $true }
    $l = [string]$l
    if (-not [System.IO.Path]::IsPathRooted($l)) { $l = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($a), $l) }
    if ((Test-Unsafe $l) -or $l -match '(^|[\\/])\.\.?([\\/]|$)') { return $true }
  }
  return $false
}

# true = a non-empty regular file modified at most $script:Win seconds ago, or we cannot tell (variables, globs, %d
# patterns, relative path after cd); false = missing, empty, old (left by an earlier run), not a regular file, a link,
# or a path that could reach the network or a device
function Test-Exists([string]$p, [bool]$plain) {
  if (-not $plain -or $p.Contains('%')) { return $true }
  try {
    $q = $p
    if ($q.StartsWith('~/') -or $q.StartsWith('~\')) { $q = Join-Path $HOME $q.Substring(2) }
    elseif (-not [System.IO.Path]::IsPathRooted($q)) {
      if ($script:Cd -or -not $script:Cwd) { return $true }
      $q = Join-Path $script:Cwd $q
    }
    if (Test-Unsafe $q) { return $false }
    if ([System.IO.Path]::DirectorySeparatorChar -eq '\') {
      if ($q -notmatch '^[A-Za-z]:[\\/]') { return $true }
    } elseif (-not $q.StartsWith('/')) { return $true }
    if (Test-RiskyLink $q) { return $false }
    $f = Get-Item -LiteralPath $q -Force -ErrorAction Stop
    if ($f.Attributes -band [System.IO.FileAttributes]::ReparsePoint) { return $false }
    return ($f -is [System.IO.FileInfo] -and $f.Length -gt 0 -and $f.LastWriteTimeUtc -ge [DateTime]::UtcNow.AddSeconds(-$script:Win))
  } catch { return $false }
}

try {
  $ErrorActionPreference = 'Stop'
  $ms = New-Object System.IO.MemoryStream
  [Console]::OpenStandardInput().CopyTo($ms)
  foreach ($v in "$env:SHUUT_SAVE_REMINDER", "$env:SHUUT_AUTOSAVE") { if ($v -imatch '^(0|off|false|no)\z') { exit 0 } }
  $utf8 = New-Object System.Text.UTF8Encoding $false
  $raw = $utf8.GetString($ms.ToArray())
  # cheap gate: no tool name anywhere in the input, nothing to do (most shell commands end here)
  $low = $raw.ToLowerInvariant()
  if (-not @($Tools | Where-Object { $_ -and $low.Contains($_) }).Count) { exit 0 }
  $ev = $raw | ConvertFrom-Json
  if ($ev.hook_event_name -ne 'PostToolUse') { exit 0 }
  $resp = $ev.tool_response
  if ($resp -isnot [string] -and $resp -and $resp.interrupted -eq $true) { exit 0 }
  $script:Cwd = [string]$ev.cwd
  # how recent an output file must be to count as written by this command (the awk "W" line, same reasons): Claude
  # Code's duration_ms rounded up to seconds + 15, else (Codex, background hook) 300 seconds
  $script:Win = 300
  $d = $ev.duration_ms
  if (($d -is [int] -or $d -is [long] -or $d -is [double] -or $d -is [decimal]) -and $d -ge 0) { $script:Win = [Math]::Min([Math]::Ceiling([double]$d / 1000) + 15, 100000000) }
  $script:Cd = $false
  $script:Seen = @{}
  $script:Wrote = @{}
  $script:Read = @{}
  $script:Ao = 0
  $script:Outs = New-Object System.Collections.Generic.List[object]
  $script:Queue = New-Object System.Collections.Generic.List[string]
  $bg = ($ev.tool_input.run_in_background -eq $true)
  $command = $ev.tool_input.command
  if ($command -is [array]) {
    $toks = New-Object System.Collections.Generic.List[object]
    foreach ($a in $command) { $toks.Add([pscustomobject]@{ W = [string]$a; K = 'w'; P = $true }) }
    Search-Command $toks
  } elseif ($command -is [string] -and $command) {
    Search-Command (Split-Command $command)
  }
  for ($q = 0; $q -lt $script:Queue.Count -and $q -lt 8; $q++) { Search-Command (Split-Command $script:Queue[$q]) }
  if ($script:Outs.Count -eq 0) { exit 0 }
  # a failed render that still exited 0 (|| true) or Codex, which also reports failed commands: ffmpeg says so at the end
  if ($resp -is [string]) { $texts = @($resp) }
  elseif ($resp) { $texts = @($resp.PSObject.Properties | Where-Object { $_.Value -is [string] } | ForEach-Object { $_.Value }) }
  else { $texts = @() }
  foreach ($text in $texts) {
    if ($text.Length -gt 16384) { $text = $text.Substring($text.Length - 16384) }
    foreach ($m in $Fails) { if ($text.Contains($m)) { exit 0 } }
  }
  $kept = New-Object System.Collections.Generic.List[string]
  # an output a later command of the same call reads with -i is an intermediate file, not the video to save
  foreach ($o in $script:Outs) { if ($script:Read.ContainsKey((Get-Nrm $o.W))) { continue }; if ($bg -or (Test-Exists $o.W $o.P)) { $kept.Add($o.W) } }
  if ($kept.Count -eq 0) { exit 0 }
  # a file name with a shell variable (out$i.mp4 - a loop's outputs) stands for the files it makes, not one file
  $list = (@($kept | Select-Object -First 3 | ForEach-Object { if (($_ -replace '^.*[/\\]', '').Contains('$')) { $_ + ' (the files it makes)' } else { $_ } }) -join ', ')
  if ($kept.Count -gt 3) { $list += ' and ' + ($kept.Count - 3) + ' more' }
  $note = $NoteHead + $list + $NoteTail
  if ($bg) { $note += ' ' + $NoteBg }
  $json = @{ hookSpecificOutput = [ordered]@{ hookEventName = 'PostToolUse'; additionalContext = $note } } | ConvertTo-Json -Compress -Depth 3
  $bytes = $utf8.GetBytes($json + "`n")
  $out = [Console]::OpenStandardOutput()
  $out.Write($bytes, 0, $bytes.Length)
  $out.Flush()
} catch { }
exit 0
