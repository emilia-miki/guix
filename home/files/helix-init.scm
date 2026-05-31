(require "helix/configuration.scm")
(require (prefix-in helix. "helix/commands.scm"))
(require (only-in "helix/misc.scm" enqueue-thread-local-callback))
(require (only-in "helix/ext.scm" evalp eval-buffer))

(soft-wrap (sw-enable #t))
(helix.theme "rose_pine")
(enqueue-thread-local-callback (lambda () (helix.theme "rose_pine")))
(true-color #t)

(define-lsp "steel-language-server" (command "steel-language-server") (args '()))
(define-lsp "guile-lsp-server" (command "guile-lsp-server") (args '()))
; (define-language "scheme"
;                  (language-servers '("guile-lsp-server"))
;                  (formatter (command "raco") (args '("fmt" "-i")))
;                  (auto-format #t))
(define-language "nix" (formatter (command "nixfmt") (args '())))
