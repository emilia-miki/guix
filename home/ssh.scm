(define-module (home ssh)
  #:use-module (gnu home services ssh)
  #:use-module (gnu services)
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
              (user "miki"))))))))
