#!/bin/sh
# zsh configuration installer          
# https://github.com/c0mpile/ 

#########################
# Environment variables #
#########################
PATH="$HOME/.local/bin:$HOME/bin:$HOME/.cargo/bin:$PATH" 
ZDOTDIR="$HOME/.config/zsh"
ZPLUGINDIR="${ZPLUGINDIR:-${ZDOTDIR:-$HOME/.config/zsh}/plugins}"
ZSH_CACHE_DIR="${ZSH_CACHE_DIR:-${ZDOTDIR:-$HOME/.config/zsh}/cache}"

#################
# Bootstrapping #
#################
# Create necessary directories
if [[ ! -d "$ZDOTDIR" ]]; then
  print -r "Creating configuration directory: $ZDOTDIR"
  mkdir -p "$ZDOTDIR" || {
    print -ru2 "Error creating configuration directory: $?"
    return 1
  }
fi

if [[ ! -d "$ZPLUGINDIR" ]]; then
  print -r "Creating plugin directory: $ZPLUGINDIR"
  mkdir -p "$ZPLUGINDIR" || {
    print -ru2 "Error creating plugin directory: $?"
    return 1
  }
fi

if [[ ! -d "$ZSH_CACHE_DIR" ]]; then
  print -r "Creating cache directory: $ZSH_CACHE_DIR"
  mkdir -p "$ZSH_CACHE_DIR" || {
    print -ru2 "Error creating cache directory: $?"
    return 1
  }
fi

if [[ ! -d "$ZSH_CACHE_DIR/completions" ]]; then
  print -r "Creating completion cache directory: $ZSH_CACHE_DIR/completions"
  mkdir -p "$ZSH_CACHE_DIR/completions" || {
    print -ru2 "Error creating completion cache directory: $?"
    return 1
  }
fi

# Check if chezmoi is in PATH
if ! command -v chezmoi &> /dev/null; then
  print -r "chezmoi not found in PATH. Attempting installation..."

  # Create .local/bin if it doesn't exist
  mkdir -p "$HOME/.local/bin"

  print -r "Installing chezmoi using get.chezmoi.io..."

  # Install chezmoi with the provided command
  if sh -c "$(curl -fsLS get.chezmoi.io)" -- -b "$HOME/.local/bin" &> /dev/null; then
    print -r "chezmoi installed successfully to $HOME/.local/bin"
  else
    print -ru2 "Error installing chezmoi."
    return 1
  fi
fi

# Verify chezmoi installation after potential installation
if ! command -v chezmoi &> /dev/null; then
  print -ru2 "chezmoi installation failed. Not found in PATH after attempt."
  return 1
fi

# Function to generate completions, handling potential errors
generate_completion() {
  local command="$1"
  local output_file="$2"
  local completion_command="$3"

  if [[ ! -f "$output_file" ]]; then
    print -r "Generating completions for $command..."
    eval "$completion_command" > "$output_file" 2>/dev/null || { # Redirect stderr to avoid clutter
      print -ru2 "Error generating completions for $command: $?"
      return 1
    }
  fi
}

# Generate completions
generate_completion "gh" "$ZSH_CACHE_DIR/completions/_gh" "gh completion -s zsh"
generate_completion "docker" "$ZSH_CACHE_DIR/completions/_docker" "docker completion zsh"
generate_completion "docker-compose" "$ZSH_CACHE_DIR/completions/_docker-compose" "curl -L https://raw.githubusercontent.com/docker/compose/master/contrib/completion/zsh/_docker-compose > $ZSH_CACHE_DIR/completions/_docker-compose"
generate_completion "podman" "$ZSH_CACHE_DIR/completions/_podman" "podman completion zsh"
generate_completion "rust" "$ZSH_CACHE_DIR/completions/_rust" "rustup completions zsh"
generate_completion "cargo" "$ZSH_CACHE_DIR/completions/_cargo" "rustup completions zsh cargo"
generate_completion "python" "$ZSH_CACHE_DIR/completions/_python" "python -m pip completion --zsh"
generate_completion "chezmoi" "$ZSH_CACHE_DIR/completions/_chezmoi" "chezmoi completion zsh"

