(define-module (home tools)
  #:use-module (gnu home services)
  #:use-module (gnu home services mpv)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%tools-services))

(define-public %tools-services
  (list
    (service home-mpv-service-type
      (make-home-mpv-configuration))

    (simple-service 'tools-xdg-config
      home-xdg-configuration-files-service-type
      `(("tmux/tmux.conf"
         ,(local-file "files/tmux.conf"))
        ("git/ignore"
         ,(plain-file "gitignore" "**/.claude/\n"))
        ("git/config"
         ,(plain-file "gitconfig"
            "[user]
\tname = Emilia Miki
\temail = emilia-miki@pm.me

[init]
\tdefaultBranch = main

[core]
\texcludesFile = ~/.config/git/ignore
"))))))
