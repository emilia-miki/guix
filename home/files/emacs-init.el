;;; init.el -*- lexical-binding: t -*-

;; Disable package.el — elpaca manages packages instead
(setq package-enable-at-startup nil)

(add-to-list 'load-path
  (expand-file-name "~/.guix-home/profile/share/emacs/site-lisp/pdf-tools-1.3.0"))

;; ── elpaca bootstrap ───────────────────────────────────────────────
(defvar elpaca-installer-version 0.12)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-sources-directory (expand-file-name "sources/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
                              :ref nil :depth 1 :inherit ignore
                              :files (:defaults "elpaca-test.el" (:exclude "extensions"))
                              :build (:not elpaca-activate)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-sources-directory))
       (build (expand-file-name "elpaca/" elpaca-builds-directory))
       (order (cdr elpaca-order))
       (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (<= emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
        (if-let* ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
                  ((zerop (apply #'call-process `("git" nil ,buffer t "clone"
                                                  ,@(when-let* ((depth (plist-get order :depth)))
                                                      (list (format "--depth=%d" depth) "--no-single-branch"))
                                                  ,(plist-get order :repo) ,repo))))
                  ((zerop (call-process "git" nil buffer t "checkout"
                                        (or (plist-get order :ref) "--"))))
                  (emacs (concat invocation-directory invocation-name))
                  ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
                                        "--eval" "(byte-recompile-directory \".\" 0 'force)")))
                  ((require 'elpaca))
                  ((elpaca-generate-autoloads "elpaca" repo)))
            (progn (message "%s" (buffer-string)) (kill-buffer buffer))
          (error "%s" (with-current-buffer buffer (buffer-string))))
      ((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (let ((load-source-file-function nil)) (load "./elpaca-autoloads"))))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; ── use-package via elpaca ─────────────────────────────────────────
(elpaca elpaca-use-package
  (elpaca-use-package-mode))

;; Block until elpaca-use-package-mode is active before using use-package
(elpaca-wait)

(setq use-package-always-ensure t)

;; Install compat from source — ELPA's version (30.x) is too old for current packages
(use-package compat
  :ensure (:host github :repo "emacs-compat/compat"))

;; transient bundled with Emacs (0.7.x) is too old for current magit (needs 0.13+)
(use-package transient
  :ensure (:host github :repo "magit/transient"))

;; ── Theme ──────────────────────────────────────────────────────────
(load-theme 'modus-vivendi t)

;; ── Modern completion ──────────────────────────────────────────────
(use-package vertico :config (vertico-mode 1))
(use-package orderless :custom (completion-styles '(orderless basic)))
(use-package marginalia :config (marginalia-mode 1))
(use-package consult
  :bind (("C-c r" . consult-ripgrep) ("C-c f" . consult-find)
         ("C-c l" . consult-line) ("M-y" . consult-yank-pop)
         ("C-x b" . consult-buffer)))
(use-package embark
  :bind (("C-." . embark-act) ("C-;" . embark-dwim))
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
  :ensure nil
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
  :custom (corfu-auto t)
  :config (global-corfu-mode 1) (corfu-popupinfo-mode 1))

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
;;          (markdown-mode   . markdown-ts-mode)
          (yaml-mode       . yaml-ts-mode)))
  (add-to-list 'auto-mode-alist '("\\.rs\\'" . rust-ts-mode)))

;; ── Structural editing / selection ────────────────────────────────
(use-package expreg
  :bind (("C-=" . expreg-expand)
         ("C--" . expreg-contract)))

(use-package combobulate
  :ensure (:host github :repo "mickeynp/combobulate" :branch "development")
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
(use-package eat
  :custom (eat-term-name "xterm-256color")
  :config (ignore-errors (eat-eshell-mode 1))
  :hook ((eat-mode    . (lambda ()
                          (face-remap-add-relative 'default :family "DejaVu Sans Mono")))
         (eshell-mode . (lambda ()
                          (face-remap-add-relative 'default :family "DejaVu Sans Mono")))))
(defun eshell/clear ()
  (let ((inhibit-read-only t))
    (erase-buffer)))

;; ── TRAMP ────────────────────────────────────────
(use-package tramp
  :ensure nil
  :config
  (add-to-list 'tramp-connection-properties
               (list (regexp-quote "/ssh:work:") "session-timeout" nil))
  (setq remote-file-name-inhibit-locks t
        tramp-use-scp-direct-remote-copying t
        remote-file-name-inhibit-auto-save-visited t
        tramp-use-ssh-controlmaster-options nil)
  (setq tramp-copy-size-limit (* 1024 1024) ;; 1MB
      tramp-verbose 2)

  (connection-local-set-profile-variables
   'remote-direct-async-process
   '((tramp-direct-async-process . t)))

  (connection-local-set-profiles
   '(:application tramp :protocol "scp")
   'remote-direct-async-process)

  (setq magit-tramp-pipe-stty-settings 'pty)

  (with-eval-after-load 'tramp
    (with-eval-after-load 'compile
      (remove-hook 'compilation-mode-hook #'tramp-compile-disable-ssh-controlmaster-options)))

  ;; don't show the diff by default in the commit buffer. Use `C-c C-d' to display it
  ;; (setq magit-commit-show-diff nil)

  ;; don't show git variables in magit branch
  ;; (setq magit-branch-direct-configure nil)

  ;; don't automatically refresh the status buffer after running a git command
  ;; (setq magit-refresh-status-buffer nil)

  (defun memoize-remote (key cache orig-fn &rest args)
    "Memoize a value if the key is a remote path."
    (if (and key
             (file-remote-p key))
        (if-let ((current (assoc key (symbol-value cache))))
            (cdr current)
          (let ((current (apply orig-fn args)))
            (set cache (cons (cons key current) (symbol-value cache)))
            current))
      (apply orig-fn args)))

  ;; Memoize current project
  (defvar project-current-cache nil)
  (defun memoize-project-current (orig &optional prompt directory)
    (memoize-remote (or directory
                        project-current-directory-override
                        default-directory)
                    'project-current-cache orig prompt directory))
  (advice-add 'project-current :around #'memoize-project-current)

  ;; Memoize magit top level
  (defvar magit-toplevel-cache nil)
  (defun memoize-magit-toplevel (orig &optional directory)
    (memoize-remote (or directory default-directory)
                    'magit-toplevel-cache orig directory))
  (advice-add 'magit-toplevel :around #'memoize-magit-toplevel)

  ;; memoize vc-git-root
  (defvar vc-git-root-cache nil)
  (defun memoize-vc-git-root (orig file)
    (let ((value (memoize-remote (file-name-directory file) 'vc-git-root-cache orig file)))
      ;; sometimes vc-git-root returns nil even when there is a root there
      (when (null (cdr (car vc-git-root-cache)))
        (setq vc-git-root-cache (cdr vc-git-root-cache)))
      value))
  (advice-add 'vc-git-root :around #'memoize-vc-git-root)

  ;; memoize all git candidates in the current project
  (defvar $counsel-git-cands-cache nil)
  (defun $memoize-counsel-git-cands (orig dir)
    ($memoize-remote (magit-toplevel dir) '$counsel-git-cands-cache orig dir))
  (advice-add 'counsel-git-cands :around #'$memoize-counsel-git-cands))

;; ── Dired stuff ──────────────────────────────────
(defun my/dired-preview-maybe-enable ()
  (if (file-remote-p default-directory)
      (dired-preview-mode -1)
    (dired-preview-mode 1)))

(use-package dired-preview
  :hook (dired-mode . my/dired-preview-maybe-enable)
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
  :config (pdf-tools-install))

(use-package nov
  :config
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode)))

(use-package djvu
  :config
  (add-to-list 'auto-mode-alist '("\\.djvu\\'" . djvu-read-mode))
  :hook (djvu-read-mode . djvu-image-mode))

(use-package inheritenv)

(use-package monet
  :ensure (:host github :repo "stevemolitor/monet"))

(use-package claude-code
  :ensure (:host github :repo "stevemolitor/claude-code.el" :depth 1)
  :config (add-hook 'claude-code-process-environment-functions #'monet-start-server-function)
          (monet-mode 1)
          (claude-code-mode)
  :bind ("C-c c" . claude-code))

;; ── Editor basics ──────────────────────────────────────────────────
(setq-default indent-tabs-mode nil tab-width 4 truncate-lines t)

;;(defvar my/font-name "Fira Code")
(defvar my/font-name "Berkeley Mono")
(defvar my/font-height 140)

(defun my/set-font ()
  (when (find-font (font-spec :name my/font-name))
    (set-face-attribute 'default nil :family my/font-name :height my/font-height :weight 'regular)))

(my/set-font)
(add-hook 'server-after-make-frame-hook #'my/set-font)
(setq ring-bell-function 'ignore use-short-answers t
      make-backup-files nil auto-save-default nil create-lockfiles nil)
(global-auto-revert-mode 1)
(global-visual-line-mode 1)
(electric-pair-mode 1)
(pixel-scroll-precision-mode -1)
(setq pixel-scroll-precision-interpolate-page nil)
(recentf-mode 1)
(save-place-mode 1)
(column-number-mode 1)
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(fullscreen . maximized))
(add-to-list 'default-frame-alist '(alpha-background . 90))

;; copy/paste via wl-clipboard so that clipboard works in terminals
(when-let ((wl-copy-path (executable-find "wl-copy"))
           (wl-paste-path (executable-find "wl-paste")))
  (defun wl-copy (text)
    (let ((proc (make-process :name "wl-copy"
                              :buffer nil
                              :command (list wl-copy-path "-f" "-n")
                              :connection-type 'pipe
                              :noquery t)))
      (process-send-string proc text)
      (process-send-eof proc)))
  (defun wl-paste ()
    (with-temp-buffer
      (call-process wl-paste-path nil t nil "-n")
      (replace-regexp-in-string "\r" "" (buffer-string))))
  (add-hook 'after-init-hook
            (lambda ()
              (setq interprogram-cut-function #'wl-copy)
              (setq interprogram-paste-function #'wl-paste))))

;; ── Code hygiene ───────────────────────────────────────────────────
(use-package indent-bars
  :hook (prog-mode . indent-bars-mode)
  :config (setq indent-bars-treesit-support t
                indent-bars-no-descend-string t
                indent-bars-treesit-ignore-blank-lines-types '("module")))

(use-package whitespace
  :hook (prog-mode . whitespace-mode)
  :config (setq whitespace-style '(face trailing empty)))

;; ── Discoverability ────────────────────────────────────────────────
(use-package which-key :config (which-key-mode 1))

;; ── Server ─────────────────────────────────────────────────────────
(unless (bound-and-true-p server-process)
  (server-start))
