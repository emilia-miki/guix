(define-module (home emacs)
  #:use-module (gnu home services)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages emacs-xyz)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%emacs-services))

(define-public %emacs-services
  (list
   (simple-service 'emacs-packages
                   home-profile-service-type
                   (list
                    emacs-pgtk
                    emacs-pdf-tools
                    ;; Standard library source for rust-analyzer goto-definition
                    (list rust "rust-src")
                    ;; Tree-sitter grammars
                    tree-sitter-rust
                    tree-sitter-go
                    tree-sitter-javascript
                    tree-sitter-python
                    tree-sitter-bash
                    tree-sitter-markdown
                    tree-sitter-json
                    tree-sitter-toml
                    tree-sitter-typescript
                    tree-sitter-yaml))

   (simple-service 'emacs-init-symlink
                   home-activation-service-type
                   #~(let* ((home   (getenv "HOME"))
                            (link   (string-append home "/.config/emacs/init.el"))
                            (target (string-append home "/Projects/guix-system/home/files/emacs-init.el")))
                       (mkdir-p (string-append home "/.config/emacs"))
                       (when (file-exists? link)
                         (delete-file link))
                       (symlink target link)))))
