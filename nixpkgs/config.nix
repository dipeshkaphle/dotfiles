{pkgs, ... }:

let
    linux_only_packages = if pkgs.system == "x86_64-linux"
			   then [
			    pkgs.xorg.xinput
			    pkgs.xorg.xrandr
			    pkgs.picom
			    pkgs.feh
			    pkgs.xss-lock
                pkgs.xclip
			    ]
			   else [];
    mac_only_packages = if pkgs.system == "aarch64-darwin" || pkgs.system == "x86_64-darwin"
			   then [
			    pkgs.gmp
			    pkgs.gmp.dev
			    pkgs.mpfr
			    pkgs.mpfr.dev
			    pkgs.libmpc
			    pkgs.flex
			    pkgs.bison
			    pkgs.autogen
			    pkgs.dejagnu
			    ]
			   else [];
in
# Install these manually
let not_working_packages = [ 
	pkgs.kitty 
	pkgs.rofi
    pkgs.i3lock
    # pkgs.perf
    # checkinstall
    # pkgs.llvmenv (install from cargo, quite outdated tbh, just build llvm yourself )
	];
in
{
	packageOverrides = pkgs: with pkgs; {
		myPackages = pkgs.buildEnv {
			name = "my-packages";
			paths = [
				texliveFull
				(python3.withPackages (ps: [ ps.pygments ps.libtmux ps.pylatexenc ]))
				vim
				neovim
				starship
				eza
				tmux
				fzf
				ripgrep
				bat
				emacs30
				cmake
				ninja
				ranger
                nodejs
                glib
                # lean4
                elan
                # fstar
                opam
                rustup
                gh
                yarn
                gnumake
                patch
                tree-sitter
                aspell
                aspellDicts.en
                # z3 # build fails on macOS
                # pkgconf (download manually else it messes up paths)
                bear
                zola
                zig
                zls
                ctags
                hyperfine
                # ghcup # Couldn't find ? do it from https://www.haskell.org/ghcup/#
                typst
                jdk21
                gradle
                tinymist
                fish
                direnv
                rclone
                cvc5
                ast-grep
                # dafny
                # dotnet-sdk_9
                # grit-ql # not available in nix for some reason
                fd
                btop
                zoxide
                lazygit
                delta
                difftastic
                uv
                jujutsu
                glow # used by pi agent for file selector
                poppler-utils # used by pi agent for converting pdfs to pngs
                pandoc
                # tuicr (used for pi reviewing)
                tesseract
                duckdb
                sioyek
				(coq.withPackages (ps: with ps; [ stdlib coq-lsp ]))
                d2
			] ++ linux_only_packages ++ mac_only_packages;
          };
	};
}

