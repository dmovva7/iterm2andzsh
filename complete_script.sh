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


/bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
   26  pwd
   27  /bin/zsh -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
   28  vi .zshrc
   29  source .zshrc
   30  sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
   31  git clone https://github.com/powerline/fonts.git --depth=1\ncd fonts\n./install.sh\ncd ..\nrm -rf fonts
   32  cd fonts
   33  pwd
   34  ls -lrth
   35  git clone https://github.com/powerline/fonts.git --depth=1
   36  cd fonts
   37  ./install.sh
   38  cd ..
   39  rm -rf fonts
   40  https://github.com/mbadolato/iTerm2-Color-Schemes.git
   41  git clone https://github.com/mbadolato/iTerm2-Color-Schemes.git
   42  pwd
   43  clear
   44  git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
   45  vi .zshrc
   46  . .zshrc
   47  . ~/.zshrc
   48  vi .zshrc
   49  . ~/.zshrc
   50  ll
   51  c
   52  vi .zshrc
