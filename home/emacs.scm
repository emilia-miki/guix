(define-module (home emacs)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu home services)
  #:use-module (guix gexp)
  #:export (%emacs-packages
            %emacs-services))

(define %emacs-packages
  (list
   emacs
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
   tree-sitter-yaml))

(define %emacs-services
  (list
   (simple-service 'emacs-xdg-config
     home-xdg-configuration-files-service-type
     `(("emacs/init.el"
        ,(local-file "files/emacs-init.el"))))))
