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

;; ── Theme ──────────────────────────────────────────────────────────
(load-theme 'modus-vivendi t)
;; (use-package autothemer)
;; (straight-use-package
;;   '(rose-pine-emacs
;;     :host github
;;     :repo "thongpv87/rose-pine-emacs"
;;     :branch "master"))
;; (load-theme 'rose-pine-color t)

;; ── Modern completion ──────────────────────────────────────────────
(use-package vertico :init (vertico-mode 1))
(use-package orderless :custom (completion-styles '(orderless basic)))
(use-package marginalia :init (marginalia-mode 1))
(use-package consult
  :bind (("C-c r" . consult-ripgrep) ("C-c f" . consult-find)
         ("C-c l" . consult-line) ("M-y" . consult-yank-pop)))
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
  :hook ((typescript-mode . eglot-ensure)
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
         (sly-mrepl-mode  . paredit-mode)))

(use-package rainbow-delimiters
  :hook ((lisp-mode       . rainbow-delimiters-mode)
         (emacs-lisp-mode . rainbow-delimiters-mode)
         (sly-mrepl-mode  . rainbow-delimiters-mode)))

;; ── LSP with Eglot ─────────────────────────────────────────────────
(use-package eglot
  :hook ((rust-mode . eglot-ensure) (rust-ts-mode . eglot-ensure))
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
  :custom (corfu-auto t))

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
(recentf-mode 1)
(save-place-mode 1)
(column-number-mode 1)
(tool-bar-mode -1)(menu-bar-mode -1)(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(fullscreen . maximized))

;; ── Discoverability ────────────────────────────────────────────────
(use-package which-key :config (which-key-mode 1))

;; ── Server ─────────────────────────────────────────────────────────
(server-start)
