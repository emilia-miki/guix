(define-module (home ssh)
  #:use-module (gnu home services)
  #:use-module (gnu home services ssh)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (local)
  #:export (%ssh-services))

(define-public %ssh-services
  (list
    (service home-openssh-service-type
      (home-openssh-configuration
        (hosts
          (list
            (openssh-host
              (name "*")
              (forward-agent? #t)
              (extra-content "\
ControlMaster auto
ControlPath ~/.ssh/master-%h:%p
ControlPersist 10m
ServerAliveInterval 60"))
            (openssh-host
              (name "work")
              (host-name %work-ssh-hostname)
              (user %work-ssh-user)
              (extra-content "\
ForwardX11 yes
ForwardX11Trusted yes"))
            (openssh-host
              (name "github.com")
              (host-name "github.com")
              (user "emilia-miki"))
            (openssh-host
              (name "thinkcentre")
              (host-name %thinkcentre-ssh-hostname)
              (user "miki"))))))

    (simple-service 'ssh-keys-activation
      home-activation-service-type
      #~(begin
          (use-modules (guix build utils))
          (let* ((home (getenv "HOME"))
                 (ssh-dir (string-append home "/.ssh")))
            (mkdir-p ssh-dir)
            (chmod ssh-dir #o700)
            (for-each
              (lambda (path content mode)
                (let ((saved (umask #o177)))
                  (call-with-output-file path
                    (lambda (port) (display content port)))
                  (umask saved))
                (chmod path mode))
              (list (string-append ssh-dir "/id_ed25519")
                    (string-append ssh-dir "/id_ed25519.pub"))
              (list #$%ssh-private-key #$%ssh-public-key)
              (list #o600 #o644)))))))
