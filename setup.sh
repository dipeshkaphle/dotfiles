git clone --depth 1 https://github.com/dexpota/kitty-themes ~/.config/kitty/kitty-themes
ln -s ~/.config/kitty/kitty-themes/themes/Kibble.conf theme.conf
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

