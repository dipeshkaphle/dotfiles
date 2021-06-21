pushd ~/.config
mkdir kitty
popd
ln -s $(pwd)/theme.conf ~/.config/kitty/theme.conf
rm ~/.config/kitty/kitty.conf
ln -s $(pwd)/kitty.conf ~/.config/kitty/kitty.conf
pushd ~
rm .vimrc
rm .tmux.conf
rm .zshrc
popd
ln -s $(pwd)/.vimrc ~/.vimrc
ln -s $(pwd)/.tmux.conf ~/.tmux.conf
ln -s $(pwd)/.zshrc ~/.zshrc

rm ~/.config/nvim/init.vim
ln -s $(pwd)/init.vim ~/.config/nvim/init.vim

ln -s $(pwd)/autoload ~/.vim/autoload
ln -s $(pwd)/coc-settings.json ~/.vim/coc-settings.json
ln -s $(pwd)/ coc-settings.json ~/.config/nvim/coc-settings.json
mkdir ~/.vim/plugged 
ln -s ~/.vim/plugged ~/.config/nvim/plugged

# setting up the scripts for zsh aliases like lsf and vimm
ln -s $(pwd)/scripts ~/scripts
echo 'Open vimrc and do PlugInstall'

rm -r ~/.config/{polybar,i3,i3status,picom}
pushd ~/.config
mkdir i3
mkdir termite
popd
ln -s $(pwd)/i3config ~/.config/i3/config
ln -s $(pwd)/polybar ~/.config/polybar
ln -s $(pwd)/picom ~/.config/picom
ln -s $(pwd)/termiteConfig ~/.config/termite/config


