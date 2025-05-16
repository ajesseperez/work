# =============================================================================
# SETUP FUNCTION - Run this to install all dependencies
# =============================================================================
function zsh_setup_everything() {
  echo "🚀 Setting up your ZSH environment with all dependencies..."
  
  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo "📦 Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "✅ Homebrew already installed"
  fi
  
  # Install essential tools with Homebrew
  echo "📦 Installing core tools with Homebrew..."
  brew install fzf jq wget curl ripgrep fd
  
  # Install fzf key bindings and fuzzy completion
  echo "🔧 Setting up fzf key bindings and completion..."
  $(brew --prefix)/opt/fzf/install --all
  
  # Check if Oh-My-Zsh is installed
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "📦 Installing Oh-My-Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  else
    echo "✅ Oh-My-Zsh already installed"
  fi
  
  # Create custom plugins directory
  echo "🔧 Setting up custom plugins directories..."
  mkdir -p ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins
  mkdir -p ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes
  
  # Install zsh-autosuggestions
  if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    echo "📦 Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  else
    echo "✅ zsh-autosuggestions already installed"
  fi
  
  # Install zsh-syntax-highlighting
  if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    echo "📦 Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  else
    echo "✅ zsh-syntax-highlighting already installed"
  fi
  
  # Set up Python with uv
  echo "🐍 Setting up Python environment with uv..."
  if ! command -v uv &> /dev/null; then
    echo "📦 Installing uv..."
    curl -fsSL https://raw.githubusercontent.com/astral-sh/uv/main/install.sh | bash
  else
    echo "✅ uv already installed"
  fi
  
  # Configure uv defaults
  mkdir -p ~/.config/uv
  cat > ~/.config/uv/config.toml << EOF
[python]
# Use the system Python by default
# You can override this with UV_PYTHON_PATH environment variable
python-path = "$(which python3)"

[virtualenv]
# Where to store virtual environments by default
virtualenv-path = "~/.venvs"
EOF

  echo "✅ uv configured successfully"
  
  # Check if kubectl is installed
  if ! command -v kubectl &> /dev/null; then
    echo "📦 Installing kubectl..."
    brew install kubectl
  else
    echo "✅ kubectl already installed"
  fi
  
  # Check if terraform is installed
  if ! command -v terraform &> /dev/null; then
    echo "📦 Installing terraform..."
    brew install terraform
  else
    echo "✅ terraform already installed"
  fi
  
  # Check if podman is installed
  if ! command -v podman &> /dev/null; then
    echo "📦 Installing podman..."
    brew install podman
  else
    echo "✅ podman already installed"
  fi
  
  # Enable the plugins in .zshrc
  echo "🔧 Updating plugins in .zshrc..."
  sed -i '' 's/# zsh-autosuggestions/zsh-autosuggestions/' $HOME/.zshrc
  sed -i '' 's/# zsh-syntax-highlighting/zsh-syntax-highlighting/' $HOME/.zshrc
  sed -i '' 's/# fzf/fzf/' $HOME/.zshrc
  
  echo "✨ Setup complete! Please restart your terminal or run 'source ~/.zshrc' to apply changes."
}

# Disable EOL mark and set prompt behavior
setopt PROMPT_CR
setopt PROMPT_SP
export PROMPT_EOL_MARK=""

# History configuration
HISTSIZE=50000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt EXTENDED_HISTORY       # Save command timestamp
setopt HIST_EXPIRE_DUPS_FIRST # Delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt HIST_IGNORE_DUPS       # Don't record duplicated commands
setopt HIST_IGNORE_SPACE      # Don't record commands starting with space
setopt HIST_VERIFY            # Show command with history expansion before running it
setopt SHARE_HISTORY          # Share history between sessions
setopt APPEND_HISTORY         # Append to history instead of overwriting

# Directory navigation improvements
setopt AUTO_CD              # Auto cd if only a directory path is entered
setopt AUTO_PUSHD           # Make cd push the old directory onto the directory stack
setopt PUSHD_IGNORE_DUPS    # Don't push multiple copies of the same directory onto the stack
setopt PUSHD_SILENT         # Don't print the directory stack after pushd or popd
setopt PUSHD_TO_HOME        # Push to home directory when no argument is given

# =============================================================================
# OH-MY-ZSH CONFIGURATION
# =============================================================================
# Path to your oh-my-zsh installation
export ZSH="/Users/jesse.perez/.oh-my-zsh"

# Theme configuration
ZSH_THEME="robbyrussell"

# Plugins (add more for increased functionality)
plugins=(
    git
    kubectl
    docker
    terraform
    python
    macos
    brew
    # External plugins - uncomment after installing with zsh_setup_everything:
    # zsh-autosuggestions
    # zsh-syntax-highlighting
    # fzf
    colored-man-pages
)

# Load Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# =============================================================================
# COMMAND EXECUTION TIMER
# =============================================================================
zmodload zsh/datetime

prompt_preexec() {
  prompt_prexec_starttime=$(date +"%I:%M:%S %p")
  prompt_prexec_realtime=${EPOCHREALTIME}
}

prompt_precmd() {
  if (( prompt_prexec_realtime )); then
    local -rF elapsed_realtime=$(( EPOCHREALTIME - prompt_prexec_realtime ))
    local -rF s=$(( elapsed_realtime%60 ))
    local -ri elapsed_s=${elapsed_realtime}
    local -ri m=$(( (elapsed_s/60)%60 ))
    local -ri h=$(( elapsed_s/3600 ))
    if (( h > 0 )); then
      printf -v prompt_elapsed_time '%ih%im' ${h} ${m}
    elif (( m > 0 )); then
      printf -v prompt_elapsed_time '%im%is' ${m} ${s}
    elif (( s >= 10 )); then
      printf -v prompt_elapsed_time '%.2fs' ${s} # 12.34s
    elif (( s >= 1 )); then
      printf -v prompt_elapsed_time '%.3fs' ${s} # 1.234s
    else
      printf -v prompt_elapsed_time '%ims' $(( s*1000 ))
    fi
    unset prompt_prexec_realtime
  else
    # Clear previous result when hitting ENTER with no command to execute
    unset prompt_elapsed_time
  fi

  echo -e "##### ${prompt_prexec_starttime} - ${prompt_elapsed_time} - $(date +'%I:%M:%S %p') #####" | fmt -c -w $COLUMNS
}

autoload -Uz add-zsh-hook
add-zsh-hook preexec prompt_preexec
add-zsh-hook precmd prompt_precmd

# =============================================================================
# PATH CONFIGURATION (consolidated)
# =============================================================================
# Add all path modifications in one place for easier maintenance
path_prepend() {
  if [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]]; then
    PATH="$1:$PATH"
  fi
}

# Add paths in order of precedence
path_prepend "$HOME/bin"
path_prepend "/usr/local/bin"
path_prepend "/usr/local/opt/curl/bin"
path_prepend "/usr/local/opt/python@3.8/bin"

# Python environment configuration
# Add uv to path if installed via the installer script
if [ -d "$HOME/.cargo/bin" ]; then
  path_prepend "$HOME/.cargo/bin"
fi

# Add ~/.local/bin to PATH for Python user installations
path_prepend "$HOME/.local/bin"

# Export final PATH
export PATH

# =============================================================================
# GOOGLE CLOUD SDK CONFIGURATION
# =============================================================================
# Only source Google Cloud SDK if it exists
export USE_GKE_GCLOUD_AUTH_PLUGIN=True
export CLOUDSDK_PYTHON=python3

if [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
fi

if [ -f "$HOME/google-cloud-sdk/completion.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# =============================================================================
# TOOL COMPLETIONS
# =============================================================================
# Bash completion compatibility
autoload -U +X bashcompinit && bashcompinit

# Tool-specific completions
if command -v terraform &> /dev/null; then
  complete -o nospace -C /usr/local/bin/terraform terraform
fi

if command -v kubectl &> /dev/null; then
  source <(kubectl completion zsh)
fi

# 1Password completion
if command -v op &> /dev/null; then
  eval "$(op completion zsh)"
  compdef _op op
fi

# =============================================================================
# ALIASES
# =============================================================================
# =============================================================================
# PYTHON ENVIRONMENT MANAGEMENT
# =============================================================================
# Python aliases and functions
alias python=python3
alias py="python3"
alias pip="uv pip"
alias pipup="uv pip install --upgrade"

# Create a Python virtual environment using uv
function uvenv() {
  local proj_name=${1:-$(basename "$PWD")}
  local venv_path="$HOME/.venvs/$proj_name"
  
  if [ -d "$venv_path" ]; then
    echo "⚠️ Virtual environment already exists: $venv_path"
    echo "Use 'uv pip install' to install packages"
    echo "Use 'UV_VENV=$proj_name command' to run a command in this environment"
    return 0
  fi
  
  echo "🔧 Creating new virtual environment: $proj_name"
  uv venv "$venv_path"
  
  echo "✅ Virtual environment created at $venv_path"
  echo "Use 'uv pip install' to install packages"
  echo "Use 'UV_VENV=$proj_name command' to run a command in this environment"
}

# Project management with uv
function uvproj() {
  local cmd="$1"
  shift
  
  case "$cmd" in
    create)
      local proj_name="$1"
      if [ -z "$proj_name" ]; then
        echo "⚠️ Please provide a project name"
        return 1
      fi
      
      echo "🚀 Creating new Python project: $proj_name"
      mkdir -p "$proj_name"
      cd "$proj_name"
      
      # Create a virtual environment
      uvenv "$proj_name"
      
      # Initialize git
      git init
      echo ".venv/" > .gitignore
      echo "__pycache__/" >> .gitignore
      echo "*.pyc" >> .gitignore
      
      # Create basic project structure
      mkdir -p "$proj_name"
      touch "$proj_name/__init__.py"
      touch README.md
      
      # Create pyproject.toml
      cat > pyproject.toml << EOF
[build-system]
requires = ["hatchling"]
build-backend = "hatchling.build"

[project]
name = "$proj_name"
version = "0.1.0"
description = ""
readme = "README.md"
requires-python = ">=3.8"
license = {text = "MIT"}
dependencies = []

[project.optional-dependencies]
dev = [
    "pytest",
    "black",
    "isort",
    "mypy",
]

[tool.black]
line-length = 88

[tool.isort]
profile = "black"
EOF
      
      echo "✅ Project created successfully"
      ;;
    list)
      echo "🔍 Available virtual environments:"
      ls -1 "$HOME/.venvs" | sort
      ;;
    *)
      echo "Unknown command: $cmd"
      echo "Available commands: create, list"
      ;;
  esac
}

# Run a Python script in a specific virtual environment
function uvrun() {
  local venv_name="$1"
  shift
  
  if [ -z "$venv_name" ]; then
    echo "⚠️ Please specify a virtual environment name"
    echo "Available environments:"
    ls -1 "$HOME/.venvs" | sort
    return 1
  fi
  
  if [ ! -d "$HOME/.venvs/$venv_name" ]; then
    echo "⚠️ Virtual environment not found: $venv_name"
    echo "Use 'uvenv $venv_name' to create it first"
    return 1
  fi
  
  echo "🔧 Running in environment: $venv_name"
  UV_VENV="$venv_name" "$@"
}

# =============================================================================
# CUSTOM FUNCTIONS
# =============================================================================

# System aliases
alias whitespace="sed 's/ /·/g;s/\t/￫/g;s/\r/§/g;s/$/¶/g'"
alias ls="ls -G"
alias ll="ls -la"
alias la="ls -a"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# Network aliases
alias acurl='curl -sS -o /dev/null -kL -w "\n       Connect To: %{remote_ip}:%{remote_port}\n\n        HTTP Code: %{http_code}\n     HTTP Version: %{http_version}\n    Download Size: %{size_download} bytes\n\n\n   DNS Resolution: %{time_namelookup}\n      TCP Connect: %{time_connect}\n SSL Negiotiation: %{time_appconnect}\n     Pre-Transfer: %{time_pretransfer}\n       First-Byte: %{time_starttransfer}\n--------------------------\n       Total time: %{time_total}\n\n"'
alias myip="curl -s https://ifconfig.me"
alias localip="ipconfig getifaddr en0"
# Update all tools at once
function steep() {
  echo "Updating Homebrew packages..."
  brew upgrade
  echo "Updating Homebrew casks..."
  brew upgrade --cask
  echo "Updating Google Cloud components..."
  if command -v gcloud &> /dev/null; then
    gcloud components update --quiet
  else
    echo "gcloud not installed, skipping"
  fi
  echo "Update complete!"
}

# Kill Chrome processes
function killChrome() {
  echo "Killing Chrome processes..."
  killall "Google Chrome" 2>/dev/null
  killall "chromedriver" 2>/dev/null
  echo "Done"
}

# JWT decoder
function jwt_decode() {
  jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}

# Container explorer
function pr() {
  if [ -z "$1" ]; then
    echo "Usage: pr <image>"
    return 1
  fi
  
  image="$1"
  echo "Logging into container registry..."
  gcloud auth print-access-token | podman login -u oauth2accesstoken --password-stdin gcr.io
  echo "Running container $image..."
  podman run -it --user 0 --entrypoint /bin/sh -e TERM=xterm -e COLUMNS=$(tput cols) -e LINES=$(tput lines) "$image" -c "clear; (bash || ash || zsh || sh)"
}

# Fuzzy find and cd into repo
function cdf() {
  local target
  target=$(find ~/Desktop/Repos.nosync -type d -iname "*$1*" 2>/dev/null | fzf)

  if [ -n "$target" ]; then
    cd "$target"
    echo "Changed to $target"
  else
    echo "No matching directory found."
  fi
}

# Change git commit message while preserving metadata
function change_commit_message() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: change_commit_message <commit_hash> \"New commit message\""
    return 1
  fi

  local commit_hash="$1"
  local new_message="$2"

  # Check if hash exists
  if ! git rev-parse --verify "$commit_hash" &>/dev/null; then
    echo "Error: Commit hash $commit_hash does not exist"
    return 1
  fi

  # Fetch original author and date
  local author_name=$(git show -s --format='%an' "$commit_hash")
  local author_email=$(git show -s --format='%ae' "$commit_hash")
  local author_date=$(git show -s --format='%aI' "$commit_hash")
  local committer_date=$(git show -s --format='%cI' "$commit_hash")

  # Start rebase
  GIT_SEQUENCE_EDITOR="sed -i '' -e 's/^pick $commit_hash/reword $commit_hash/'" \
    git rebase -i "${commit_hash}^"

  # Amend the commit with new message, preserving dates and author
  GIT_AUTHOR_NAME="$author_name" \
  GIT_AUTHOR_EMAIL="$author_email" \
  GIT_AUTHOR_DATE="$author_date" \
  GIT_COMMITTER_DATE="$committer_date" \
  git commit --amend -m "$new_message"

  echo "✅ Commit message updated and original metadata preserved."
}

# Quick find function - search for files in current directory
function qf() {
  find . -type f -name "*$1*" | grep -v "node_modules\|.git"
}

# =============================================================================
# FINAL SETTINGS & ENVIRONMENT VARIABLES
# =============================================================================
# Set editor preference
export EDITOR='vim'
export VISUAL='vim'

# Enable color support
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad

# Better command history search with up/down arrows
bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward
