(define-module (home helix)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%helix-services))

(define-public %helix-services
  (list
    (simple-service 'helix-xdg-config
      home-xdg-configuration-files-service-type
      `(("helix/init.scm"
         ,(local-file "files/helix-init.scm"))
("helix/themes/rose_pine.toml"
         ,(local-file "files/helix-rose_pine.toml"))
        ("helix/.helix/languages.toml"
         ,(plain-file "languages.toml"
            "[language-server.steel-language-server]
command = \"steel-language-server\"

[[language]]
name = \"scheme\"
language-servers = [\"steel-language-server\"]
"))))))
