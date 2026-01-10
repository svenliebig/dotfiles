# .zshenv is sourced on all invocations of the shell, unless the -f option is set.
# It should contain commands to set the command search path, plus other important environment variables.
# .zshenv' should not contain commands that produce output or assume the shell is attached to a tty.

export XDG_CONFIG_HOME="$HOME/.config"

export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

export DOTFILES="$(dirname "$(dirname "$(dirname "$(readlink -f "${(%):-%N}")")")")"

# directories
export WORKSPACE="$HOME/workspace"
export SOFTWARE="$WORKSPACE/software"
export REPOSITORIES="$WORKSPACE/repositories"
export CACHEDIR="$WORKSPACE/.cache"
export GOPATH="$CACHEDIR/go"
export GRADLE_USER_HOME="$CACHEDIR/gradle"
export SDKMAN_DIR="$CACHEDIR/sdkman"
export NVM_DIR="$HOME/.config/nvm"

# deprecated and replaced with HF_HOME
export TRANSFORMERS_CACHE="$CACHEDIR/transformers"
export HF_HOME="$CACHEDIR/huggingface"
export OLLAMA_MODELS="$CACHEDIR/ollama"

export VIM_TMP="$HOME/.vim-tmp"
# add a config file for ripgrep
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

[[ -d "$CACHEDIR" ]] || mkdir -p "$CACHEDIR"
[[ -d "$VIM_TMP" ]] || mkdir -p "$VIM_TMP"

[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local

fpath=(
    $DOTFILES/config/zsh/functions
    /usr/local/share/zsh/site-functions
    $fpath
)

typeset -aU path

export EDITOR='nvim'
export GIT_EDITOR='nvim'

