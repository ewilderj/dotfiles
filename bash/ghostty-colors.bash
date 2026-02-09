# ghostty-colors.bash — Auto-tint Ghostty tabs by project or SSH host
#
# Bash equivalent of ghostty-colors.zsh.
# Projects under ~/git/ get cool-toned background tints.
# SSH sessions get warm-toned tints. Colors are deterministic.
#
# Only activates inside Ghostty.

# Activate in Ghostty (local) or any capable terminal (remote/SSH)
case "$TERM" in
  xterm-ghostty|xterm*|screen*|tmux*) ;;
  *) [[ -z "$GHOSTTY_RESOURCES_DIR" ]] && return ;;
esac

# ---------------------------------------------------------------------------
# Palette — subtle dark tints that pair well with Dracula
# ---------------------------------------------------------------------------

_GTC_PROJECT_COLORS=(
  "#1e2535"  "#1e2d2d"  "#261e35"  "#1e3526"
  "#2d1e2d"  "#1e2d35"  "#2d2d1e"  "#1e352d"
  "#2d1e35"  "#1e3535"  "#241e35"  "#1e3530"
)

_GTC_SSH_COLORS=(
  "#352222"  "#352d1e"  "#35261e"  "#2d2222"
  "#352c1e"  "#2d1e1e"  "#352d24"  "#351e1e"
)

_GTC_PROJECT_DOTS=( 🔵 🟢 🟣 🟤 🟡 🔵 🟢 🟡 🟣 🔵 🟤 🟢 )
_GTC_SSH_DOTS=(    🔴 🟠 🟠 🔴 🟡 🔴 🟠 🔴 )

_GTC_DEFAULT_BG="#282a36"
_GTC_CURRENT_TITLE=""
_GTC_SSH_ACTIVE=""

# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------

_gtc_hash() {
  local s="$1" h=0 i c
  for (( i=0; i<${#s}; i++ )); do
    printf -v c '%d' "'${s:$i:1}"
    h=$(( (h * 31 + c) % 65536 ))
  done
  echo $h
}

_gtc_short_cwd() {
  local cwd="$PWD"
  if [[ "$cwd" == "$HOME/git/"* ]]; then
    echo "${cwd#$HOME/git/}"
  elif [[ "$cwd" == "$HOME"* ]]; then
    echo "~${cwd#$HOME}"
  else
    echo "$cwd"
  fi
}

_gtc_set() {
  printf '\033]11;%s\007' "$1"
  printf '\033]2;%s\007' "$2"
  _GTC_CURRENT_TITLE="$2"
}

# Prefix for tab titles — includes hostname when in an SSH session
if [[ -n "$SSH_CONNECTION" ]]; then
  _GTC_HOST_PREFIX="${HOSTNAME%%.*}: "
else
  _GTC_HOST_PREFIX=""
fi

_gtc_reset() {
  local title="${_GTC_HOST_PREFIX}$(_gtc_short_cwd)"
  printf '\033]11;%s\007' "$_GTC_DEFAULT_BG"
  printf '\033]2;%s\007' "$title"
  _GTC_CURRENT_TITLE="$title"
}

# ---------------------------------------------------------------------------
# Project coloring — called from PROMPT_COMMAND
# ---------------------------------------------------------------------------

_gtc_prompt() {
  [[ -n "$_GTC_SSH_ACTIVE" ]] && return

  if [[ "$PWD" == "$HOME/git/"* ]]; then
    local project="${PWD#$HOME/git/}"
    project="${project%%/*}"
    local subpath
    subpath="$(_gtc_short_cwd)"
    local h idx dot
    h=$(_gtc_hash "$project")
    idx=$(( h % ${#_GTC_PROJECT_COLORS[@]} ))
    dot="${_GTC_PROJECT_DOTS[$idx]}"
    _gtc_set "${_GTC_PROJECT_COLORS[$idx]}" "$dot ${_GTC_HOST_PREFIX}$subpath"
  else
    _gtc_reset
  fi

  # Re-assert title (handles programs that overwrote it)
  [[ -n "$_GTC_CURRENT_TITLE" ]] && printf '\033]2;%s\007' "$_GTC_CURRENT_TITLE"
}

# ---------------------------------------------------------------------------
# SSH coloring — wraps ssh
# ---------------------------------------------------------------------------

ssh() {
  local host="" skip=false arg
  for arg in "$@"; do
    if $skip; then skip=false; continue; fi
    case "$arg" in
      -[bcDEeFIiJLlmOopQRSWw]) skip=true ;;
      -*) ;;
      *@*) host="${arg#*@}"; break ;;
      *)   [[ -z "$host" ]] && host="$arg"; break ;;
    esac
  done

  if [[ -n "$host" ]]; then
    local short="${host%%.*}"
    local h idx dot
    h=$(_gtc_hash "$short")
    idx=$(( h % ${#_GTC_SSH_COLORS[@]} ))
    dot="${_GTC_SSH_DOTS[$idx]}"
    _GTC_SSH_ACTIVE="$short"
    _gtc_set "${_GTC_SSH_COLORS[$idx]}" "$dot $short"
  fi

  command ssh "$@"
  local ret=$?
  _GTC_SSH_ACTIVE=""
  _gtc_prompt
  return $ret
}

# ---------------------------------------------------------------------------
# Hook into PROMPT_COMMAND + initial apply
# ---------------------------------------------------------------------------

if [[ -n "$PROMPT_COMMAND" ]]; then
  PROMPT_COMMAND="_gtc_prompt;$PROMPT_COMMAND"
else
  PROMPT_COMMAND="_gtc_prompt"
fi
_gtc_prompt
