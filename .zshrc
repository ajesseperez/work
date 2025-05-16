setopt PROMPT_CR
setopt PROMPT_SP
export PROMPT_EOL_MARK=""

#RPROMPT="%{$fg[cyan]%}[%D{%r}]%{$reset_color%}"


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

#setopt nopromptbang prompt{cr,percent,sp,subst}

autoload -Uz add-zsh-hook
add-zsh-hook preexec prompt_preexec
add-zsh-hook precmd prompt_precmd

#RPS1='%F{cyan}${prompt_prexec_starttime} - ${prompt_elapsed_time} - $(date +"%I:%M:%S %p")%F{none}'



# If you come from bash you might have to change your $PATH.
export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/jesse.perez/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /usr/local/bin/terraform terraform

USE_GKE_GCLOUD_AUTH_PLUGIN=True
# The next line updates PATH for the Google Cloud SDK.
if [ -f '/Users/jesse.perez/google-cloud-sdk/path.zsh.inc' ]; then . '/Users/jesse.perez/google-cloud-sdk/path.zsh.inc'; fi

# The next line enables shell command completion for gcloud.
if [ -f '/Users/jesse.perez/google-cloud-sdk/completion.zsh.inc' ]; then . '/Users/jesse.perez/google-cloud-sdk/completion.zsh.inc'; fi
source <(kubectl completion zsh)


# Fix for Gcloud SDK
export PATH="/usr/local/opt/python@3.8/bin:$PATH"
alias python=/usr/local/opt/python@3.8/bin/python3
export CLOUDSDK_PYTHON=python3

function steep {
  brew upgrade
  brew upgrade --cask
  gcloud components update --quiet
}

function killChrome {
   killall "Google Chrome"
   killall "chromedriver"
}

alias whitespace="sed 's/ /·/g;s/\t/￫/g;s/\r/§/g;s/$/¶/g'"
export PATH="/usr/local/opt/curl/bin:$PATH"
alias acurl='curl -sS -o /dev/null -kL -w "\n       Connect To: %{remote_ip}:%{remote_port}\n\n        HTTP Code: %{http_code}\n     HTTP Version: %{http_version}\n    Download Size: %{size_download} bytes\n\n\n   DNS Resolution: %{time_namelookup}\n      TCP Connect: %{time_connect}\n SSL Negiotiation: %{time_appconnect}\n     Pre-Transfer: %{time_pretransfer}\n       First-Byte: %{time_starttransfer}\n--------------------------\n       Total time: %{time_total}\n\n"'

# 1Pass AutoComplete
eval "$(op completion zsh)"; compdef _op op


function jwt_decode(){
    jq -R 'split(".") | .[1] | @base64d | fromjson' <<< "$1"
}
function pr() {
  image="$1"
  gcloud auth print-access-token | podman login -u oauth2accesstoken --password-stdin gcr.io
  podman run -it --user 0 --entrypoint /bin/sh -e TERM=xterm -e COLUMNS=$(tput cols) -e LINES=$(tput lines) "$image" -c "clear; (bash || ash || zsh || sh)"
}
alias python=python3
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init - zsh)"

cdf() {
  local target
  target=$(find ~/Desktop/Repos.nosync -type d -iname "*$1*" 2>/dev/null | fzf)

  if [ -n "$target" ]; then
    cd "$target"
  else
    echo "No matching directory found."
  fi
}

function change_commit_message() {
  if [[ $# -lt 2 ]]; then
    echo "Usage: change_commit_message <commit_hash> \"New commit message\""
    return 1
  fi

  local commit_hash="$1"
  local new_message="$2"

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
