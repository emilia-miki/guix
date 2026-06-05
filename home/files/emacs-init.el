;;; init.el -*- lexical-binding: t -*-

(add-to-list 'load-path
  (expand-file-name "~/.guix-home/profile/share/emacs/site-lisp/pdf-tools-1.3.0"))

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

;; ── Theme ──────────────────────────────────────────────────────────
(load-theme 'modus-vivendi t)

;; ── Modern completion ──────────────────────────────────────────────
(use-package vertico :init (vertico-mode 1))
(use-package orderless :custom (completion-styles '(orderless basic)))
(use-package marginalia :init (marginalia-mode 1))
(use-package consult
  :bind (("C-c r" . consult-ripgrep) ("C-c f" . consult-find)
         ("C-c l" . consult-line) ("M-y" . consult-yank-pop)
         ("C-x b" . consult-buffer)))
(use-package embark
  :bind (("C-." . embark-act) ("M-." . embark-dwim))
  :init (setq prefix-help-command #'embark-prefix-help-command))
(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ── Git ────────────────────────────────────────────────────────────
(use-package diff-hl
  :hook ((dired-mode . diff-hl-dired-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config (global-diff-hl-mode 1))
(use-package magit :bind ("C-x g" . magit-status))

;; ── Language modes ─────────────────────────────────────────────────
(use-package go-mode :mode "\\.go\\'"
  :hook ((go-mode . eglot-ensure) (go-ts-mode . eglot-ensure))
  :config
  (add-hook 'go-mode-hook    (lambda () (setq-local indent-tabs-mode t)))
  (add-hook 'go-ts-mode-hook (lambda () (setq-local indent-tabs-mode t))))

(use-package markdown-mode :mode "\\.\\(md\\|markdown\\)\\'"
  :hook (markdown-mode . eglot-ensure))

(use-package python-mode :mode "\\.py\\'"
  :hook ((python-mode . eglot-ensure) (python-ts-mode . eglot-ensure)))

(use-package typescript-mode :mode "\\.\\(ts\\|tsx\\)\\'"
  :hook ((typescript-mode    . eglot-ensure)
         (typescript-ts-mode . eglot-ensure)
         (js-mode . eglot-ensure) (js-ts-mode . eglot-ensure)))

(use-package json-mode :mode "\\.json\\'")
(use-package yaml-mode :mode "\\.\\(yaml\\|yml\\)\\'")
(use-package lua-mode :mode "\\.lua\\'")
(use-package toml-mode :mode "\\.toml\\'")

;; ── Common Lisp ────────────────────────────────────────────────────
(use-package sly
  :config (setq inferior-lisp-program "sbcl"))

(use-package paredit
  :hook ((lisp-mode       . paredit-mode)
         (emacs-lisp-mode . paredit-mode)
         (sly-mrepl-mode  . paredit-mode)
         (scheme-mode     . paredit-mode)
         ;; paredit handles pairing; electric-pair would double-insert
         (lisp-mode       . (lambda () (electric-pair-local-mode -1)))
         (emacs-lisp-mode . (lambda () (electric-pair-local-mode -1)))
         (sly-mrepl-mode  . (lambda () (electric-pair-local-mode -1)))
         (scheme-mode     . (lambda () (electric-pair-local-mode -1)))))

(use-package rainbow-delimiters
  :hook ((lisp-mode       . rainbow-delimiters-mode)
         (emacs-lisp-mode . rainbow-delimiters-mode)
         (sly-mrepl-mode  . rainbow-delimiters-mode)
         (scheme-mode     . rainbow-delimiters-mode)))

;; ── Scheme / Guile ────────────────────────────────────────────────
(use-package geiser-guile
  :hook (scheme-mode . geiser-mode))

;; ── LSP with Eglot ─────────────────────────────────────────────────
(use-package eglot
  :hook ((rust-mode . eglot-ensure) (rust-ts-mode . eglot-ensure))
  :bind (("C-c a" . eglot-code-actions)
         ("C-c n" . eglot-rename)
         ("C-c =" . eglot-format-buffer)
         ("C-c d" . flymake-show-buffer-diagnostics))
  :config
  (setq eglot-autoshutdown t)
  (let* ((sysroot (or (getenv "RUST_SYSROOT")
                      (cl-find-if (lambda (p)
                                    (file-exists-p (expand-file-name "lib/rustlib/src" p)))
                                  (list (expand-file-name "~/.guix-home/profile")
                                        (expand-file-name "~/.guix-profile")
                                        "/run/current-system/profile"))))
         (ra (executable-find "rust-analyzer")))
    (add-to-list 'eglot-server-programs
                 `((rust-mode rust-ts-mode)
                   . ("rust-analyzer"
                      :initializationOptions
                      (:cargo (:sysroot ,sysroot
                               :sysroot-src ,(expand-file-name "lib/rustlib/src/rust/library" sysroot))
                       :procMacro (:server
                                   ,(when ra
                                      (expand-file-name
                                       "libexec/rust-analyzer-proc-macro-srv"
                                       (file-name-directory
                                        (directory-file-name
                                         (file-name-directory ra))))))))))))

;; ── In-buffer completion ───────────────────────────────────────────
(use-package corfu
  :init (global-corfu-mode 1)
  :custom (corfu-auto t)
  :config (corfu-popupinfo-mode 1))

(use-package cape
  :hook (prog-mode . (lambda ()
                       (add-hook 'completion-at-point-functions #'cape-file nil t)
                       (add-hook 'completion-at-point-functions #'cape-dabbrev nil t))))

;; ── Treesit (tree-sitter grammars from guix) ──────────────────────
(when (and (fboundp 'treesit-available-p) (treesit-available-p))
  (dolist (profile (list (getenv "GUIX_PROFILE")
                         (expand-file-name "~/.guix-home/profile")
                         "/run/current-system/profile"))
    (when profile
      (let ((ts-lib (expand-file-name "lib/tree-sitter" profile)))
        (when (file-directory-p ts-lib)
          (add-to-list 'treesit-extra-load-path ts-lib)))))
  (setq major-mode-remap-alist
        '((bash-mode   . bash-ts-mode)
          (go-mode     . go-ts-mode)
          (js-mode     . js-ts-mode)
          (json-mode   . json-ts-mode)
          (python-mode . python-ts-mode)
          (rust-mode       . rust-ts-mode)
          (typescript-mode . typescript-ts-mode)
          (markdown-mode   . markdown-ts-mode)
          (yaml-mode       . yaml-ts-mode)))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode)))

;; ── Structural editing / selection ────────────────────────────────
(use-package expreg
  :bind (("C-=" . expreg-expand)
         ("C--" . expreg-contract)))

(use-package combobulate
  :hook ((go-ts-mode     . combobulate-mode)
         (rust-ts-mode   . combobulate-mode)
         (python-ts-mode . combobulate-mode)
         (js-ts-mode     . combobulate-mode)
         (json-ts-mode   . combobulate-mode)
         (yaml-ts-mode        . combobulate-mode)
         (bash-ts-mode        . combobulate-mode)
         (typescript-ts-mode  . combobulate-mode)))

;; ── Navigation ────────────────────────────────────────────────────
(use-package avy
  :bind (("C-c j" . avy-goto-char-2)   ;; type 2 chars → jump (like Helix f/t)
         ("M-g g" . avy-goto-line)))    ;; jump to visible line; digits fall back to goto-line

;; ── Undo / Redo ───────────────────────────────────────────────────
(use-package undo-fu
  :bind (("C-/" . undo-fu-only-undo)
         ("C-?" . undo-fu-only-redo)))

;; ── Search result editing ─────────────────────────────────────────
(use-package wgrep)   ;; press e in any grep/consult-ripgrep buffer to edit in place

;; ── Terminal emulator/shell stuff ──────────────────────────────────
(use-package eat)

;; ── Dired stuff ──────────────────────────────────
(use-package dired-preview
  :hook (dired-mode . dired-preview-mode)
        (dired-preview . (lambda ()
                           (dired-preview-with-window
                             (when (eq major-mode 'image-mode)
                               (image-transform-fit-to-window)))))
  :config (setq dired-preview-delay 0)
          (setq dired-preview-max-size 104057600)
          (setq dired-preview-ignored-extensions-regexp
                (replace-regexp-in-string "\\\\|pdf" ""
                                          (replace-regexp-in-string "\\\\|epub" "" dired-preview-ignored-extensions-regexp))))

(use-package pdf-tools
  :straight nil
  :ensure t
  :config (pdf-tools-install))

(use-package nov
  :config
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

(use-package djvu
  :config
  (add-to-list 'auto-mode-alist '("\\.djvu\\'" . djvu-read-mode))
  :hook (djvu-read-mode . djvu-image-mode))

;; (use-package pdf-tools
;; :straight nil
;; :config (pdf-tools-install))

;; ── Editor basics ──────────────────────────────────────────────────
(setq-default indent-tabs-mode nil tab-width 4 truncate-lines t)
(set-face-attribute 'default nil :height 180)
(setq ring-bell-function 'ignore use-short-answers t
      make-backup-files nil auto-save-default nil create-lockfiles nil)
(global-auto-revert-mode 1)
(electric-pair-mode 1)
(pixel-scroll-precision-mode 1)
(setq pixel-scroll-precision-interpolate-page t)
(recentf-mode 1)
(save-place-mode 1)
(column-number-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; copy/paste via wl-clipboard so that clipboard works in terminals
(when (executable-find "wl-copy")
  (defun wl-copy (text)
    (let ((proc (make-process :name "wl-copy"
                              :buffer nil
                              :command '("wl-copy" "-f" "-n")
                              :connection-type 'pipe
                              :noquery t)))
      (process-send-string proc text)
      (process-send-eof proc)))
  (defun wl-paste ()
    (shell-command-to-string "wl-paste -n | tr -d \r"))
  (add-hook 'after-init-hook
            (lambda ()
              (setq interprogram-cut-function #'wl-copy)
              (setq interprogram-paste-function #'wl-paste))))

;; ── Discoverability ────────────────────────────────────────────────
(use-package which-key :config (which-key-mode 1))

;; ── Server ─────────────────────────────────────────────────────────
(unless (bound-and-true-p server-process)
  (server-start))
