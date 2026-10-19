# Source custom configuration if it exists
if [[ -f "$HOME/custom.sh" ]]; then
    source "$HOME/custom.sh"
fi

if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(git vi-mode)

source $ZSH/oh-my-zsh.sh

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

INSERT_MODE_INDICATOR="%F{yellow}+%f"

### DynamoDB
alias dynamo='cd ~/dynamodb && java -Djava.library.path=./DynamoDBLocal_lib -jar DynamoDBLocal.jar -sharedDb'

### DynamoDB Admin
alias dynamo-admin='DYNAMO_ENDPOINT=http://localhost:8000 dynamodb-admin'

### Git Shortcuts
alias gl="git log --oneline --graph --decorate --all"
alias gs="git status -u"
alias gd="git diff"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

### Add MySQL to path
export PATH=${PATH}:/usr/local/mysql/bin/

### Add Redis to path
export PATH=${PATH}:~/redis/src/

# Terraform
alias tf=terraform

# Python
alias pip=pip3
alias py=python
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv init -)"

# Golang
[ -d "/usr/local/go/bin" ] && export PATH=$PATH:/usr/local/go/bin

# Docker
alias nuke-docker="docker system prune -af && docker volume prune -f"
alias start-colima="colima start --cpu 4 --memory 8 --disk 60"

# fzf
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
source <(fzf --zsh)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
  --highlight-line \
  --info=inline-right \
  --ansi \
  --layout=reverse \
  --border=none
  --color=bg+:#283457 \
  --color=bg:#16161e \
  --color=border:#27a1b9 \
  --color=fg:#c0caf5 \
  --color=gutter:#16161e \
  --color=header:#ff9e64 \
  --color=hl+:#2ac3de \
  --color=hl:#2ac3de \
  --color=info:#545c7e \
  --color=marker:#ff007c \
  --color=pointer:#ff007c \
  --color=prompt:#2ac3de \
  --color=query:#c0caf5:regular \
  --color=scrollbar:#27a1b9 \
  --color=separator:#ff9e64 \
  --color=spinner:#ff007c \
"

# Syntax highlighting
# Mac
[ -f "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Linux
[ -f "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] && source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Zoxide
eval "$(zoxide init zsh)"
alias cd=z

# LSD
alias ls=lsd
lt() {
  if [[ -z "$1" ]]; then
    lsd -al --tree --depth=2
  else
    lsd -al --tree --depth=$1
  fi
}

# Bat
if command -v batcat &> /dev/null; then
  alias bat=batcat
fi
alias cat=bat
export BAT_THEME="tokyonight_night"
export PATH="/opt/homebrew/opt/mysql/bin:$PATH"

# k9s
alias k9s="k9s --logoless"

# AWS

# Account-based aliases
export AWS_PAGER="" # disables pager for aws cli commands

accounts() {
  # Returns list of known accounts from ~/.aws/config
  opts=$(grep "\[profile " ~/.aws/config | awk '{ print $2; }' | tr -d ']' | tr '\n' ' ')
  COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
}

# Set the session's AWS ACCOUNT ID to be used with the other AWS aliases at the top of this script
# Add the account name to the prompt if possible
account() {
  if [[ $# == 1 ]]; then
    export ACCOUNT=$1
    export AWS_PROFILE=$1
    sso_check
  else
    echo "AWS Account: ${ACCOUNT}"
    sso_check
  fi
}

noaccount() {
  unset ACCOUNT
  unset AWS_PROFILE
  unset SSO_EXPIRES_AT
  echo "Unset AWS account"
}

complete -F accounts account

sso_login() {
  aws sso login
  # Get latest SSO cache file and extract expiration time
  latest_cache=$(ls -t ~/.aws/sso/cache/*.json | head -n 1)
  if [[ -f "$latest_cache" ]]; then
    export SSO_EXPIRES_AT=$(cat "$latest_cache" | jq -r '.expiresAt') # Format: 2024-11-16T03:27:06Z
  else
    unset SSO_EXPIRES_AT
  fi
}

sso_check() {
  # Check if SSO is expired or not set
  if [[ -z "$SSO_EXPIRES_AT" ]] || [[ $(date -u +%Y-%m-%dT%H:%M:%SZ) > "$SSO_EXPIRES_AT" ]]; then
    sso_login
  else
    echo "SSO session expires in $(date -u -j -f "%Y-%m-%dT%H:%M:%SZ" "$SSO_EXPIRES_AT" +'%H:%M:%S')"
  fi
}
