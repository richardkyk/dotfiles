# beginning of .zshrc
# zmodload zsh/zprof

lazy-nvm() {
  unset -f nvm node npm npx
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  nvm use default --silent
}
nvm()  { lazy-nvm; nvm "$@"; }
node() { lazy-nvm; node "$@"; }
npm()  { lazy-nvm; npm "$@"; }
npx()  { lazy-nvm; npx "$@"; }


export CONDA_CHANGEPS1=false

if [ -f "/Users/richard.khaw/miniforge3/etc/profile.d/conda.sh" ]; then
    . "/Users/richard.khaw/miniforge3/etc/profile.d/conda.sh"
else
    export PATH="/Users/richard.khaw/miniforge3/bin:$PATH"
fi
# # >>> conda initialize >>>
# # !! Contents within this block are managed by 'conda init' !!
# __conda_setup="$('/Users/richard.khaw/miniforge3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
# if [ $? -eq 0 ]; then
#     eval "$__conda_setup"
# else
#     if [ -f "/Users/richard.khaw/miniforge3/etc/profile.d/conda.sh" ]; then
#         . "/Users/richard.khaw/miniforge3/etc/profile.d/conda.sh"
#     else
#         export PATH="/Users/richard.khaw/miniforge3/bin:$PATH"
#     fi
# fi
# unset __conda_setup
# # <<< conda initialize <<<

export PATH="/Library/Frameworks/GStreamer.framework/Commands:$PATH"

export LSCOLRS=gxfxcxdxbxegedabagacad
export CLICOLOR=1

eval "$(starship init zsh)"

export PATH="$PATH:/Applications/WezTerm.app/Contents/MacOS"
. ~/.config/wezterm/shell-integration.sh

# end of .zshrc
# zprof
