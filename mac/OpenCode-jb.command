#!/bin/zsh -l

fail() {
  print -r -- "$1"
  read -r '?Press Enter to close ... '
  exit 1
}

launcher_dir="${0:A:h}"

export PATH="$HOME/.opencode/bin:$HOME/.bun/bin:$HOME/.local/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"
command -v opencode >/dev/null 2>&1 || fail 'OpenCode v2 is not installed or not available on PATH. Please install OpenCode v2: https://opencode.ai'

version=$(opencode --version 2>/dev/null) || fail 'Could not verify OpenCode v2. Please install or repair OpenCode v2: https://opencode.ai'
[[ "$version" =~ '^[[:space:]]*(opencode[[:space:]]+)?v?2\.[0-9]+\.[0-9]+([-+][[:alnum:].-]+)?[[:space:]]*$' ]] || fail "OpenCode v2 is required. Detected: $version. Please install OpenCode v2: https://opencode.ai"
print -r -- "OpenCode v2 detected: $version"
config_dir=$(opencode debug paths | /usr/bin/awk '$1 == "config" {sub(/^[^[:space:]]+[[:space:]]+/, ""); print; exit}')
[[ -n "$config_dir" && "$config_dir" == /* ]] || fail 'Could not locate the OpenCode configuration directory.'

input_mode=$(/usr/bin/osascript <<'APPLESCRIPT'
try
  set answer to display dialog "How would you like to provide the instructions for this workspace?" with title "OpenCode instructions" buttons {"Cancel", "Paste system prompt", "Select AGENTS.md"} default button "Select AGENTS.md" cancel button "Cancel"
  return button returned of answer
on error number -128
  return ""
end try
APPLESCRIPT
) || fail 'Could not open the instructions dialog.'
[[ -n "$input_mode" ]] || exit 0
selected=""
prompt_text=""
if [[ "$input_mode" == 'Paste system prompt' ]]; then
  [[ -r "$launcher_dir/prompt-editor.js" ]] || fail 'Missing prompt-editor.js. Extract the entire ZIP first.'
  prompt_text=$(/usr/bin/osascript -l JavaScript "$launcher_dir/prompt-editor.js") || fail 'Could not open the prompt editor.'
  # Protect trailing newlines from shell command substitution, then remove only our suffix.
  prompt_text="${prompt_text%__OPENCODE_PROMPT_END_9F73__}"
  [[ -n "${prompt_text//[[:space:]]/}" ]] || exit 0
else
selected=$(/usr/bin/osascript <<'APPLESCRIPT'
try
  set chosenFile to choose file with prompt "Find and select your agents.md file."
  return POSIX path of chosenFile
on error number -128
  return ""
end try
APPLESCRIPT
) || fail 'Could not open the file picker.'
[[ -n "$selected" ]] || exit 0
[[ -f "$selected" && -r "$selected" ]] || fail 'The selected file is not readable.'
[[ "${(L)selected:t}" == 'agents.md' ]] || fail 'Select a file named agents.md (case-insensitive).'

fi

# Validate a single portable folder name, never a path.
valid_workspace_name() {
  local name="$1"
  [[ -n "$name" && ${#name} -le 80 && "$name" != .* && "$name" != *[.[:space:]] && "$name" != [[:space:]]* ]] || return 1
  [[ ! "$name" =~ '[<>:"/\\|?*[:cntrl:]]' ]] || return 1
  [[ ! "${(U)name}" =~ '^(CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])([.]|$)' ]] || return 1
}
while true; do
  workspace_name=$(/usr/bin/osascript <<'APPLESCRIPT'
try
  set answer to display dialog "Name this JB workspace. A folder with this name will be used on your Desktop." default answer "jb" with title "OpenCode workspace" buttons {"Cancel", "Continue"} default button "Continue" cancel button "Cancel"
  return text returned of answer
on error number -128
  return ""
end try
APPLESCRIPT
  ) || fail 'Could not open the workspace name dialog.'
  [[ -n "$workspace_name" ]] || exit 0
  valid_workspace_name "$workspace_name" && break
  /usr/bin/osascript -e 'display alert "Invalid folder name" message "Use 1-80 characters, no path separators or reserved characters, no leading dot or whitespace, and no trailing dot or whitespace. Windows device names such as CON are not allowed."' || exit 1
done

desktop=$(/usr/bin/osascript -e 'POSIX path of (path to desktop folder)') || fail 'Could not locate your Desktop folder.'
target="${desktop%/}/$workspace_name"
[[ ! -L "$target" ]] || fail 'The selected workspace must not be a symbolic link.'
mkdir -p "$target" || fail 'Could not create the workspace folder.'
destination="$target/AGENTS.md"
[[ ! -L "$destination" ]] || fail 'AGENTS.md must not be a symbolic link.'
if [[ "$input_mode" == 'Paste system prompt' || ! "$selected" -ef "$destination" ]]; then
  if [[ -e "$destination" ]]; then
    backup=$(mktemp "$target/AGENTS.md.backup.XXXXXX") || fail 'Could not create a backup.'
    cp -p "$destination" "$backup" || fail 'Could not back up the existing AGENTS.md.'
  fi
  if [[ "$input_mode" == 'Paste system prompt' ]]; then
    print -rn -- "$prompt_text" > "$destination" || fail 'Could not save the prompt as AGENTS.md.'
  else
    cp "$selected" "$destination" || fail 'Could not copy the file.'
  fi
fi
plugin_source="$launcher_dir/jb-banner/tui.tsx"
[[ -r "$plugin_source" ]] || fail 'Missing jb-banner/tui.tsx. Extract the entire ZIP first.'
plugin_dir="$config_dir/plugins/jb-launcher-banner"
mkdir -p "$plugin_dir" || fail 'Could not create the UI plugin folder.'
if [[ -e "$plugin_dir/tui.tsx" ]] && ! cmp -s "$plugin_source" "$plugin_dir/tui.tsx"; then
  plugin_backup=$(mktemp "$plugin_dir/tui.tsx.backup.XXXXXX") || fail 'Could not create a plugin backup.'
  cp -p "$plugin_dir/tui.tsx" "$plugin_backup" || fail 'Could not back up the existing UI plugin.'
fi
cp "$plugin_source" "$plugin_dir/tui.tsx" || fail 'Could not install the UI banner.'
# Retire the previous project-local copy to avoid rendering the banner twice.
local_plugin="$target/.opencode/plugins/jb-launcher-banner/tui.tsx"
if [[ -f "$local_plugin" ]] && cmp -s "$plugin_source" "$local_plugin"; then
  retired=$(mktemp "$target/.opencode/jb-banner-retired.XXXXXX") || fail 'Could not preserve the old local plugin.'
  mv "$local_plugin" "$retired" || fail 'Could not retire the old local plugin.'
fi
cd "$target" || fail 'Could not open the workspace folder.'
print -r -- "Starting OpenCode in: $target"
opencode
result=$?
(( result == 0 )) || fail "OpenCode exited with error code $result."
