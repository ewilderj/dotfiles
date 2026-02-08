# ghostty-colors.zsh — Auto-tint Ghostty tabs by project or SSH host
#
# Projects under ~/git/ get cool-toned background tints.
# SSH sessions get warm-toned tints. Colors are deterministic:
# the same project/host always gets the same color.
#
# Only activates inside Ghostty.

[[ -z "$GHOSTTY_RESOURCES_DIR" ]] && return

# ---------------------------------------------------------------------------
# Palette — subtle dark tints that pair well with Dracula
# ---------------------------------------------------------------------------

# Cool tones for local projects
typeset -a _GTC_PROJECT_COLORS=(
  "#1e2535"  # slate blue
  "#1e2d2d"  # deep teal
  "#261e35"  # plum
  "#1e3526"  # forest
  "#2d1e2d"  # mauve
  "#1e2d35"  # steel
  "#2d2d1e"  # olive
  "#1e352d"  # sea green
  "#2d1e35"  # violet
  "#1e3535"  # cyan
  "#241e35"  # indigo
  "#1e3530"  # jade
)

# Warm tones for SSH hosts
typeset -a _GTC_SSH_COLORS=(
  "#352222"  # brick
  "#352d1e"  # amber
  "#35261e"  # burnt orange
  "#2d2222"  # rosewood
  "#352c1e"  # golden brown
  "#2d1e1e"  # dark cherry
  "#352d24"  # copper
  "#351e1e"  # deep red
)

_GTC_DEFAULT_BG="#282a36"  # Dracula default

# ---------------------------------------------------------------------------
# Internals
# ---------------------------------------------------------------------------

# Deterministic hash of a string → integer
_gtc_hash() {
  local s="$1" h=0 i
  for (( i=0; i<${#s}; i++ )); do
    h=$(( (h * 31 + $(printf '%d' "'${s:$i:1}")) % 65536 ))
  done
  echo $h
}

# Set background color and tab title via OSC escape sequences
_gtc_set() {
  printf '\033]11;%s\007' "$1"
  printf '\033]2;%s\007' "$2"
}

# Reset to Dracula default
_gtc_reset() {
  printf '\033]11;%s\007' "$_GTC_DEFAULT_BG"
  printf '\033]2;\007'
}

# ---------------------------------------------------------------------------
# Project coloring — fires on every cd
# ---------------------------------------------------------------------------

_gtc_chpwd() {
  if [[ "$PWD" == "$HOME/git/"* ]]; then
    local project="${PWD#$HOME/git/}"
    project="${project%%/*}"
    local idx=$(( $(_gtc_hash "$project") % ${#_GTC_PROJECT_COLORS[@]} + 1 ))
    _gtc_set "${_GTC_PROJECT_COLORS[$idx]}" "📁 $project"
  else
    _gtc_reset
  fi
}

# ---------------------------------------------------------------------------
# SSH coloring — wraps ssh to tint before connect, restore after
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
    local idx=$(( $(_gtc_hash "$short") % ${#_GTC_SSH_COLORS[@]} + 1 ))
    _gtc_set "${_GTC_SSH_COLORS[$idx]}" "🖥 $short"
  fi

  command ssh "$@"
  local ret=$?
  _gtc_chpwd   # restore project color or default
  return $ret
}

# ---------------------------------------------------------------------------
# Hook registration + initial apply
# ---------------------------------------------------------------------------

autoload -Uz add-zsh-hook
add-zsh-hook chpwd _gtc_chpwd
_gtc_chpwd
