git clone --depth 1 https://github.com/dexpota/kitty-themes ~/.config/kitty/kitty-themes
ln -s ~/.config/kitty/kitty-themes/themes/Kibble.conf theme.conf
ln -s theme.conf ~/.config/kitty/theme.conf
rm ~/.config/kitty/kitty.conf
ln -s kitty.conf ~/.config/kitty/kitty.conf
pushd ~
rm .vimrc
rm .tmux.conf
rm .zshrc
popd
ln -s .vimrc ~/.vimrc
ln -s .tmux.conf ~/.tmux.conf
ln -s .zshrc ~/.zshrc

rm ~/.config/nvim/init.vim
ln -s init.vim ~/.config/nvim/init.vim

ln -s autoload ~/.vim/autoload
ln -s coc-settings.json ~/.vim/coc-settings.json
ln -s coc-settings.json ~/.config/nvim/coc-settings.json
mkdir ~/.vim/plugged 
ln -s ~/.vim/plugged ~/.config/nvim/plugged
echo 'Open vimrc and do PlugInstall'

