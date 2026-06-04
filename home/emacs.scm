(define-module (home emacs)
  #:use-module (gnu packages emacs)
  #:use-module (gnu packages rust)
  #:use-module (gnu packages tree-sitter)
  #:export (%emacs-packages))

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
   tree-sitter-typescript
   tree-sitter-yaml))
