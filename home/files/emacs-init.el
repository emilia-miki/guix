;;; init.el -*- lexical-binding: t -*-

;; ── straight.el bootstrap ──────────────────────────────────────────
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

;; ── use-package via straight ───────────────────────────────────────
(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; ── Rose Pine theme ────────────────────────────────────────────────
(use-package autothemer :straight t)
(straight-use-package
  '(rose-pine-emacs
    :host github
    :repo "thongpv87/rose-pine-emacs"
    :branch "master"))
(load-theme 'rose-pine-color t)

;; ── Meow: helix-like modal editing ─────────────────────────────────
;; (use-package meow
;;   :straight t :demand t
;;   :config
;;   (defun meow-setup ()
;;     (setq meow-cheatsheet-layout meow-cheatsheet-layout-qwerty)
;;     (meow-motion-overwrite-define-key
;;      '("j" . meow-next) '("k" . meow-prev) '("h" . meow-left) '("l" . meow-right)
;;      '("<escape>" . ignore))
;;     (meow-leader-define-key
;;      '("?" . meow-cheatsheet) '("j" . "H-j") '("k" . "H-k")
;;      '("SPC" . execute-extended-command) '("f" . find-file) '("b" . switch-to-buffer)
;;      '("w" . save-buffer) '("x" . kill-current-buffer) '("e" . delete-other-windows)
;;      '("v" . split-window-right) '("s" . split-window-below)
;;      '("g" . magit-status) '("G" . magit-dispatch)
;;      '("n" . diff-hl-next-hunk) '("p" . diff-hl-previous-hunk)
;;      '("c" . compile) '("r" . consult-ripgrep))
;;     (meow-normal-define-key
;;      '("0" . meow-expand-0) '("9" . meow-expand-9) '("8" . meow-expand-8)
;;      '("7" . meow-expand-7) '("6" . meow-expand-6) '("5" . meow-expand-5)
;;      '("4" . meow-expand-4) '("3" . meow-expand-3) '("2" . meow-expand-2)
;;      '("1" . meow-expand-1) '("-" . negative-argument)
;;      '(";" . meow-reverse) '("," . meow-inner-of-thing) '("." . meow-bounds-of-thing)
;;      '("[" . meow-beginning-of-thing) '("]" . meow-end-of-thing)
;;      '("a" . meow-append) '("A" . meow-open-below) '("b" . meow-back-word)
;;      '("B" . meow-back-symbol) '("c" . meow-change) '("d" . meow-delete)
;;      '("D" . meow-backward-delete) '("e" . meow-next-word) '("E" . meow-next-symbol)
;;      '("f" . meow-find) '("g" . meow-cancel-selection) '("G" . meow-grab)
;;      '("i" . meow-insert) '("I" . meow-open-above) '("j" . meow-next)
;;      '("J" . meow-next-expand) '("k" . meow-prev) '("K" . meow-prev-expand)
;;      '("m" . meow-join) '("n" . meow-search) '("o" . meow-block)
;;      '("O" . meow-to-block) '("p" . meow-yank) '("P" . meow-yank-pop)
;;      '("q" . meow-quit) '("Q" . meow-goto-line) '("r" . meow-replace)
;;      '("R" . meow-swap-grab) '("s" . meow-kill) '("t" . meow-till)
;;      '("u" . meow-undo) '("U" . meow-undo-in-selection) '("v" . meow-visit)
;;      '("w" . meow-mark-word) '("W" . meow-mark-symbol) '("x" . meow-line)
;;      '("X" . meow-goto-line) '("y" . meow-save) '("Y" . meow-sync-grab)
;;      '("z" . meow-pop-selection) '("'" . repeat)
;;      '("<escape>" . ignore)
;;      '("SPC" . meow-keypad-describe-key) '("+" . meow-keypad-describe-key)))
;;   (meow-setup) (meow-global-mode 1))

;; ── Modern completion ──────────────────────────────────────────────
(use-package vertico :straight t :init (vertico-mode 1))
(use-package orderless :straight t :custom (completion-styles '(orderless basic)))
(use-package marginalia :straight t :init (marginalia-mode 1))
(use-package consult :straight t
  :bind (("C-c r" . consult-ripgrep) ("C-c f" . consult-find)
         ("C-c l" . consult-line) ("M-y" . consult-yank-pop)))
(use-package embark :straight t
  :bind (("C-." . embark-act) ("M-." . embark-dwim))
  :init (setq prefix-help-command #'embark-prefix-help-command))
(use-package embark-consult :straight t
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ── Git ────────────────────────────────────────────────────────────
(use-package diff-hl :straight t
  :hook ((prog-mode . diff-hl-mode) (text-mode . diff-hl-mode)
         (conf-mode . diff-hl-mode) (dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config (global-diff-hl-mode 1))
(use-package magit :straight t :bind ("C-x g" . magit-status))

;; ── Language modes ─────────────────────────────────────────────────
(use-package go-mode :straight t :mode "\\.go\\'"
  :hook ((go-mode . eglot-ensure) (go-ts-mode . eglot-ensure))
  :config
  (add-to-list 'eglot-server-programs '((go-mode go-ts-mode) . ("gopls")))
  (add-hook 'go-mode-hook (lambda () (setq indent-tabs-mode t)))
  (add-hook 'go-ts-mode-hook (lambda () (setq indent-tabs-mode t))))

(use-package markdown-mode :straight t :mode "\\.\\(md\\|markdown\\)\\'"
  :hook (markdown-mode . eglot-ensure)
  :config (add-to-list 'eglot-server-programs '(markdown-mode . ("marksman"))))

(use-package python-mode :straight t :mode "\\.py\\'"
  :hook ((python-mode . eglot-ensure) (python-ts-mode . eglot-ensure))
  :config (add-to-list 'eglot-server-programs
                       '((python-mode python-ts-mode) . ("pyright-langserver" "--stdio"))))

(use-package typescript-mode :straight t :mode "\\.ts\\'"
  :hook ((js-mode . eglot-ensure) (js-ts-mode . eglot-ensure))
  :config (add-to-list 'eglot-server-programs
                       '((js-mode js-ts-mode) . ("typescript-language-server" "--stdio"))))

(use-package json-mode :straight t :mode "\\.json\\'" :interpreter "json")
(use-package yaml-mode :straight t :mode "\\.\\(yaml\\|yml\\)\\'")
(use-package lua-mode :straight t :mode "\\.lua\\'")
(use-package toml-mode :straight t :mode "\\.toml\\'")

;; ── LSP with Eglot ─────────────────────────────────────────────────
(defvar eglot-server-programs nil)
(use-package eglot :straight t
  :hook ((rust-mode . eglot-ensure) (rust-ts-mode . eglot-ensure))
  :config
  (setq eglot-events-buffer-size 0)
  (setq eglot-autoshutdown t)
  (add-to-list 'eglot-server-programs
               `((rust-mode rust-ts-mode)
                 . ("rust-analyzer" :initializationOptions
                    (:cargo (:sysroot
                             ,(or (getenv "RUST_SYSROOT")
                                  (expand-file-name "~/.guix-home/profile"))
                             :sysroot-src
                             ,(expand-file-name
                               "lib/rustlib/src/rust/library"
                               (or (getenv "RUST_SYSROOT")
                                   (expand-file-name "~/.guix-home/profile"))))
                     :procMacro (:server
                                 ,(let ((ra (executable-find "rust-analyzer")))
                                    (when ra
                                      (expand-file-name
                                       "libexec/rust-analyzer-proc-macro-srv"
                                       (file-name-directory
                                        (directory-file-name
                                         (file-name-directory ra))))))))))))

;; ── Company ────────────────────────────────────────────────────────
(use-package company :straight t
  :hook (after-init . global-company-mode)
  :config (setq company-idle-delay 0.2 company-minimum-prefix-length 1))

;; ── Treesit (tree-sitter grammars from guix) ──────────────────────
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  (let ((guix-ts-lib (expand-file-name "lib/tree-sitter"
                       (or (getenv "GUIX_PROFILE")
                           (expand-file-name "~/.guix-home/profile")))))
    (when (file-directory-p guix-ts-lib)
      (add-to-list 'treesit-extra-load-path guix-ts-lib)))
  (setq major-mode-remap-alist
        '((bash-mode   . bash-ts-mode)
          (go-mode     . go-ts-mode)
          (js-mode     . js-ts-mode)
          (json-mode   . json-ts-mode)
          (python-mode . python-ts-mode)
          (rust-mode   . rust-ts-mode)
          (yaml-mode   . yaml-ts-mode)))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode)))

;; ── Editor basics ──────────────────────────────────────────────────
(setq-default indent-tabs-mode nil tab-width 4 truncate-lines t)
(set-face-attribute 'default nil :height 180)
(setq ring-bell-function 'ignore use-short-answers t
      make-backup-files nil auto-save-default nil create-lockfiles nil)
(global-auto-revert-mode 1)
(global-display-line-numbers-mode 1)
(column-number-mode 1)
(tool-bar-mode -1)(menu-bar-mode -1)(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; ── Server ─────────────────────────────────────────────────────────
(server-start)
