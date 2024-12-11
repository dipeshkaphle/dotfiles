;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
(setq user-full-name "Dipesh Kafle"
      user-mail-address "dipesh.kaphle111@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-unicode-font' -- for unicode glyphs
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
                                        ; (setq doom-theme 'modus-vivendi-tritanopia)
(setq doom-theme 'modus-operandi-tritanopia)
;; (after! modus-themes (modus-themes-load-vivendi))
;; (after! modus-themes (load-theme 'modus-vivendi-tritanopia))
;; (setq doom-theme 'doom-one-light)
;; (setq doom-theme 'doom-gruvbox)

(setq doom-font (font-spec :family "Jetbrains Mono" :size 18))

(setq evil-normal-state-cursor '(box "red")
      evil-insert-state-cursor '(bar "white")
      evil-visual-state-cursor '(hollow "orange"))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type 'relative)
(global-display-line-numbers-mode)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.
;;
(setq select-enable-clipboard t)

(global-prettify-symbols-mode)

(map! :m  "C-i" #'evil-jump-forward)
;; this messes TAB, must change
;; (define-key evil-insert-state-map (kbd "TAB") 'indent-for-tab-command)

(xclip-mode 1)


(defun find-hidden ()
  (interactive)
  (+vertico/consult-fd)
  )

(setq cursor-type :box)

;; https://www.reddit.com/r/emacs/comments/hz6ibe/how_to_bind_cc_to_send_ctr_c_in_vtermmode_in/
;; (map! :after vterm
;;       :map vterm-mode-map
;;       :ni "C-c" #'vterm-send-C-c)

(vterm-mode)


;; imap <C-k> <Up>
;; imap <C-j> <Down>
;; imap <C-l> <Right>
;; imap <C-h> <Left>
;; inoremap <C-w> <C-o>W
;; inoremap <C-b> <C-o><C-Left>
;; inoremap <C-f> <C-o>^
;; inoremap <C-e> <C-o>$
;; inoremap <C-t> <C-o>O
;; inoremap <C-d> <C-o>o
;; nnoremap <S-j> <C-e>
;; nnoremap <S-k> <C-y>
(map!
 :i "C-l" #'right-char
 :i "C-h" #'left-char
 :i "C-j" #'next-line
 :i "C-k" #'previous-line
 :i "C-b" #'evil-backward-word-begin
 :i "C-w" #'evil-forward-word-end
 :i "C-f" #'beginning-of-line-text
 :i "C-e" #'end-of-line
 :i "C-t" #'+default/newline-above
 :i "C-d" #'+default/newline-below
 :n "C-k" #'evil-scroll-line-up
 :n "C-j" #'evil-scroll-line-down
 :i "C-V" #'evil-paste-after
 :n "]n"  #'flycheck-previous-error
 :n "[n"  #'flycheck-next-error
 )

;; map C-V to paste
;; (define-key evil-insert-state-map (kbd "C-V") #'evil-paste-after)

(map!
 :leader "z" #'comment-or-uncomment-region
 :leader "r" #'rotate-layout
 :leader "sf" #'projectile-find-file-in-directory
 )

(map!
 :map fstar-mode-map
 :prefix "C-c"
 "C-SPC" #'fstar-subp-company-backend
 )

;; Mapping C-y to selecting the current auto-complete(same as in my vim config)
(map!
 :map company-active-map
 "C-y" #'company-complete-selection
 )

(map!
 :map lsp-mode-map
 :n "Q" #'flycheck-explain-error-at-point
 )

(use-package! lsp
  :custom
  ((lsp-rust-analyzer-server-display-inlay-hints t)
   (lsp-enable-which-key-integration t)
   )
  )

(add-hook! 'lsp-mode-hook #'lsp-headerline-breadcrumb-mode)
                                        ; (add-hook! 'lsp-mode-hook #'lsp-inlay-hints-mode)

(use-package! ocamlformat
  :custom (ocamlformat-enable 'enable-outside-detected-project)
  :hook (before-save . ocamlformat-before-save)
  )


(map!
 :map company-mode-map
 :i "<tab>"  #'indent-for-tab-command )
(setq tab-width 4)

;; Flycheck settings
(setq flycheck-check-syntax-automatically '(mode-enabled save))
;; (setq flycheck-idle-change-delay 10)
(setq flycheck-idle-buffer-switch-delay 5)
(setq evil-vsplit-window-right t)
(setq evil-split-window-below t)


(defadvice! prompt-for-ex-after-vnew (&rest _)
  :after 'evil-window-vnew (evil-ex))

(defadvice! prompt-for-ex-after-new (&rest _)
  :after 'evil-window-new (evil-ex))

(defadvice! prompt-for-ex-after-tabnew (&rest _)
  :after '+workspace/new (evil-ex))

(evil-ex-define-cmd "be[low]"
                    (lambda ()
                      (interactive)
                      (evil-window-new nil nil)
                      (evil-ex)))

(evil-ex-define-cmd "vert[ical]"
                    (lambda () (interactive)
                      (evil-window-vnew nil nil)
                      (evil-ex)))

;; (after! persp-mode
;;   (setq persp-emacsclient-init-frame-behaviour-override "main")
;;   )

(evil-ex-define-cmd "!" #'projectile-run-shell-command-in-root)


(global-visual-line-mode)
(global-tree-sitter-mode)
(add-hook! 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)

;; Make lsp-mode a bit faster
;; https://emacs-lsp.github.io/lsp-mode/page/performance/
(setq read-process-output-max (* 1024 1024)) ;
(setq gc-cons-threshold (* 4 1024 1024 1024))

;; Use C-SPC in insert mode to get capf, it'll be much faster this way I guess
;; and I learn to write code without being too dependent on autocomplete
(use-package! company
  :config (setq company-idle-delay nil))

;; Source: https://docs.doomemacs.org/v21.12/modules/lang/cc/
;; Making clangd the lsp in C/C++ projects
(setq lsp-clients-clangd-args '("-j=4"
				"--background-index"
				"--clang-tidy"
				"--completion-style=detailed"
				"--header-insertion=never"
				"--header-insertion-decorators=0"))
(after! lsp-clangd (set-lsp-priority! 'clangd 2))

;; Specifying directory in rg search => https://emacs.stackexchange.com/questions/63079/how-to-change-counsel-grep-options-once-activated-counsel-rg-counsel-git-grep
(setq counsel-mode t)
(setq utop-command "opam config exec -- dune utop . -- -emacs")

(add-hook! 'tuareg-mode-hook #'merlin-mode)
(add-hook! 'caml-mode-hook #'merlin-mode)
(which-function-mode 1)

(after! embark
  (setq! prefix-help-command #'which-key-C-h-dispatch)
  )

(with-eval-after-load 'org (global-org-modern-mode))

;; See the README to learn about consult(this has a lot of functionalities)
;; https://github.com/minad/consult
(after! consult
  (consult-customize
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; my/command-wrapping-consult    ;; disable auto previews inside my command
   :preview-key '(:debounce 0.4 any) ;; Option 1: Delay preview
   ;; :preview-key "M-.")            ;; Option 2: Manual preview
   )
  )

;; (https://github.com/vspinu/company-math)
;; works in a scratch buffer and fundamental-mode
;;, doesn't work in other places 
;; (add-to-list 'company-backends 'company-math-symbols-unicode )
;; Just wanted to be fancy


;; Doesn't work for some reason, start company-coq-mode manually
;; (add-hook! 'coq-mode-hook #'company-coq-mode)
;;
(setq company-coq-live-on-the-edge t)


;; Call this once you start the fstar subprocess
(defun enable-fstar-company-mode ()
  "Enable company mode for fstar, have to do this explicitly for some reason"
  (interactive)
  (fstar-setup-company-defaults)
  (fstar-setup-company))


;; this assumes we have a F* installed through opam
(after! fstar-mode
  (setq! fstar-subp-prover-additional-args (list
                                            "--record_hints"
                                            "--already_cached" "'Prims FStar LowStar C Spec.Loops TestLib WasmSupport'"
                                            "--include"
                                            (concat (getenv "OPAM_SWITCH_PREFIX") "/lib/fstar/")
                                            "--include"
                                            (concat (getenv "OPAM_SWITCH_PREFIX") "/lib/fstar/.cache/")
                                            "--include"
                                            (concat (getenv "OPAM_SWITCH_PREFIX") "/lib/krml/")
                                            "--include"
                                            (concat (getenv "OPAM_SWITCH_PREFIX") "/lib/krml/obj")
                                            "--hint_dir"
                                            (concat (getenv "OPAM_SWITCH_PREFIX") "/lib/fstar/.cache/")
                                            "--hint_dir"
                                            (concat (getenv "OPAM_SWITCH_PREFIX") "/lib/krml/obj")
                                            "--hint_dir"
                                            (concat (getenv "OPAM_SWITCH_PREFIX") "/lib/krml/hints")
                                            )
         ))


(add-to-list 'lsp-language-id-configuration '(typst-ts-mode . "typst"))

(lsp-register-client (make-lsp-client
                      :new-connection (lsp-stdio-connection '("tinymist" "lsp"))
                      :activation-fn (lsp-activate-on "typst")
                      :server-id 'typst-lsp))

(defun enable-typst-lsp-mode ()
  (interactive)
  (lsp))
