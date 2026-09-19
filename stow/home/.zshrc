autoload -Uz compinit
compinit

# sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
plugins=(git z zsh-autosuggestions zsh-completions)

# brew install zsh-autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# brew install zsh-completions
fpath+=/opt/homebrew/share/zsh-completions
autoload -Uz compinit && compinit

. "$HOME/.local/share/../bin/env"
