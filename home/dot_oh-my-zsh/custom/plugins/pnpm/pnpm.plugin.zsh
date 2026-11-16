if (( ! $+commands[pnpm] )); then
  return
fi

# `pnpm completion zsh` prints a static stub that delegates to `pnpm completion-server` on
# every <Tab>, so it only needs regenerating when the pnpm binary changes. mise installs each
# version under its own path, so stamp the file with it (binary mtimes are upstream build dates).
() {
  local file="$ZSH_CACHE_DIR/completions/_pnpm"
  local stamp="# pnpm: $commands[pnpm]"
  [[ -f "$file" && "$(<$file)" == *"$stamp"* ]] && return

  typeset -g -A _comps
  autoload -Uz _pnpm
  _comps[pnpm]=_pnpm

  # pnpm (Node) restores the tty state it saw at startup when it exits. Detach it from the
  # terminal, or it resets the tty to cooked mode under ZLE and breaks the first prompt.
  { pnpm completion zsh; print -r -- "$stamp" } </dev/null 2>/dev/null >| "$file" &|
}
