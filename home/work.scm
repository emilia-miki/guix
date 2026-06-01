(define-module (home work)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:use-module (local)
  #:export (%work-services))

(define update-resolv-conf-script
  (computed-file "update-resolv-conf.sh"
    #~(begin
        (copy-file #$(local-file "files/update-resolv-conf.sh") #$output)
        (chmod #$output #o755))))

(define vpn-route-up-script
  (computed-file "vpn-route-up.sh"
    #~(begin
        (call-with-output-file #$output
          (lambda (port)
            (display
              (string-append "#!/bin/sh\n"
                             "/run/current-system/profile/sbin/ip route add "
                             #$%thinkcentre-ssh-hostname
                             "/32 dev tailscale0\n")
              port)))
        (chmod #$output #o755))))

(define-public %work-services
  (list
    (simple-service 'work-home-files
      home-files-service-type
      `((".local/bin/update-resolv-conf.sh"
         ,update-resolv-conf-script)
        (".local/bin/vpn-route-up.sh"
         ,vpn-route-up-script)
        (".local/share/ca-certificates/rootCA.pem"
         ,(local-file "files/rootCA.pem"))))

    (simple-service 'work-openvpn-activation
      home-activation-service-type
      #~(begin
          (use-modules (guix build utils) (guix utils))
          (let* ((home (getenv "HOME"))
                 (vpn-dir (string-append home "/.config/openvpn")))
            (mkdir-p vpn-dir)
            (chmod vpn-dir #o700)
            (for-each
              (lambda (path content mode)
                (let ((saved (umask #o177)))
                  (call-with-output-file path
                    (lambda (port) (display content port)))
                  (umask saved))
                (chmod path mode))
              (list (string-append vpn-dir #$%ovpn-name)
                    (string-append vpn-dir "/vpn.txt"))
              (list (string-replace-substring #$%ovpn-config "HOME" home)
                    (string-append #$%vpn-username "\n" #$%vpn-password "\n"))
              (list #o600 #o600)))))))
