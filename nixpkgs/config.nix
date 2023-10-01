{pkgs, ... }:

let linux_only_packages =  if pkgs.system == "x86_64-linux"
			   then [
			    pkgs.xorg.xinput
			    pkgs.xorg.xrandr
			    pkgs.picom
			    pkgs.feh
			    pkgs.xss-lock
			    ]
			   else [];
in
# Install these manually
let not_working_packages = [ 
	pkgs.kitty 
	pkgs.rofi
	];
in
{
	packageOverrides = pkgs: with pkgs; {
		myPackages = pkgs.buildEnv {
			name = "my-packages";
			paths = [
				vim
				neovim
				starship
				eza
				tmux
				fzf
				ripgrep
				bat
				emacs28NativeComp
				cmake
				ninja
				ranger
                nodejs
                libvterm
                # lean4
                fstar
                opam
                rustup
                gh
                yarn
                gnumake
			] ++ linux_only_packages;
		};
	};
}
