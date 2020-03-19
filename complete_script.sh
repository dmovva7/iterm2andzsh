# install iTerm2
#brew cask install iterm2

# install zsh
#brew install zsh

# install oh my zsh
curl -L http://install.ohmyz.sh | sh

# add syntax highlighting
cd ~/.oh-my-zsh && git clone git://github.com/zsh-users/zsh-syntax-highlighting.git
echo 'source ~/.oh-my-zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh' >> ~/.zshrc

#add plugins
echo 'plugins=(git colorize bundler)' >> ~/.zshrc

# install powerlevel9k theme
git clone https://github.com/bhilburn/powerlevel9k.git ~/powerlevel9k
echo 'source  ~/powerlevel9k/powerlevel9k.zsh-theme' >> ~/.zshrc

# install nerd-fonts
cd ~/Library/Fonts && curl -fLo "Droid Sans Mono for Powerline Nerd Font Complete.otf" https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/DroidSansMono/complete/Droid%20Sans%20Mono%20Nerd%20Font%20Complete.otf

# reset the terminal
source ~/.zshrc
