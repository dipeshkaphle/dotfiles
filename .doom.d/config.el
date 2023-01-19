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
(setq doom-theme  'doom-gruvbox)
(setq doom-font (font-spec :family "Jetbrains Mono" :size 22))

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
(define-key evil-insert-state-map (kbd "C-c C-c") 'evil-normal-state)
(define-key evil-normal-state-map (kbd "C-c C-c") 'evil-normal-state)
(define-key evil-insert-state-map (kbd "M-c") 'evil-normal-state)
(define-key evil-normal-state-map (kbd "M-c") 'evil-normal-state)

(add-hook 'markdown-mode-hook #'texfrag-mode)
(global-prettify-symbols-mode)

(map! :m  "C-i" #'evil-jump-forward)
;; this messes TAB, must change
(define-key evil-insert-state-map (kbd "TAB") 'indent-for-tab-command)

(xclip-mode 1)


(defun find-hidden ()
  (interactive)
  (+vertico/consult-fd)
  )

(setq cursor-type :box)

;; https://www.reddit.com/r/emacs/comments/hz6ibe/how_to_bind_cc_to_send_ctr_c_in_vtermmode_in/
(map! :after vterm
      :map vterm-mode-map
      :ni "C-c" #'vterm-send-C-c)



;; imap <C-k> <Up>
;; imap <C-j> <Down>
;; imap <C-l> <Right>
;; imap <C-h> <Left>
(define-key evil-insert-state-map (kbd "C-l") 'right-char)
(define-key evil-insert-state-map (kbd "C-h") 'left-char)
(define-key evil-insert-state-map (kbd "C-j") 'next-line)
(define-key evil-insert-state-map (kbd "C-k") 'previous-line)

;; inoremap <C-w> <C-o>W
;; inoremap <C-b> <C-o><C-Left>
;; inoremap <C-f> <C-o>^
;; inoremap <C-e> <C-o>$
;; inoremap <C-t> <C-o>O
;; inoremap <C-d> <C-o>o
(define-key evil-insert-state-map (kbd "C-b") (kbd "C-<left>") )
(define-key evil-insert-state-map (kbd "C-w") (kbd "C-<right>") )
(define-key evil-insert-state-map (kbd "C-f") 'beginning-of-line-text)
(define-key evil-insert-state-map (kbd "C-e") 'end-of-line)
(define-key evil-insert-state-map (kbd "C-t") '+default/newline-above)
(define-key evil-insert-state-map (kbd "C-d") '+default/newline-below)
;; nnoremap <S-j> <C-e>
;; nnoremap <S-k> <C-y>
(define-key evil-normal-state-map (kbd "K") 'evil-scroll-line-up)
(define-key evil-normal-state-map (kbd "J") 'evil-scroll-line-down)



(map! :leader "z" #'comment-or-uncomment-region)

(map!
 :map fstar-mode-map
 :prefix "C-c"
 "C-SPC" #'fstar-subp-company-backend
 )

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

(after! persp-mode
  (setq persp-emacsclient-init-frame-behaviour-override "main")
  )

(evil-ex-define-cmd "!" 'projectile-run-shell-command-in-root)

(global-visual-line-mode)
(global-tree-sitter-mode)
(add-hook 'tree-sitter-after-on-hook #'tree-sitter-hl-mode)
