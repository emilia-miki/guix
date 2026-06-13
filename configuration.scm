(define-module (configuration)
  #:use-module (srfi srfi-1)
  #:use-module (guix build-system trivial)
  #:use-module (guix gexp)
  #:use-module (guix packages)
  #:use-module (gnu)
  #:use-module (gnu packages)
  #:use-module (gnu packages dns)
  #:use-module (gnu packages file)
  #:use-module (gnu packages fonts)
  #:use-module (gnu packages freedesktop)
  #:use-module (gnu packages gnome)
  #:use-module (gnu packages ncurses)
  #:use-module (gnu packages networking)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages vpn)
  #:use-module (gnu services)
  #:use-module (gnu services cups)
  #:use-module (gnu services desktop)
  #:use-module (gnu services guix)
  #:use-module (gnu services networking)
  #:use-module (gnu services sddm)
  #:use-module (gnu system)
  #:use-module (gnu system locale)
  #:use-module (asahi guix packages linux)
  #:use-module (asahi guix systems sway)
  #:use-module (btv tailscale)
  #:use-module (local))

(define sysconf-script
  (package
   (name "sysconf")
   (version "1.0")
   (source #f)
   (build-system trivial-build-system)
   (arguments
    `(#:modules ((guix build utils))
      #:builder
      (begin
        (use-modules (guix build utils))
        (let ((out (assoc-ref %outputs "out")))
          (mkdir-p (string-append out "/bin"))
          (let ((script (string-append out "/bin/sysconf")))
            (call-with-output-file script
              (lambda (port)
                (display "\
#!/bin/sh
GUIX_DIR=\"$HOME/Projects/guix-system\"
sudo guix system reconfigure -L \"$GUIX_DIR\" \"$GUIX_DIR/configuration.scm\" && \\
guix home reconfigure -L \"$GUIX_DIR\" \"$GUIX_DIR/guix-home-config.scm\" && \\
guix describe -f channels > \"$GUIX_DIR/channels.lock.scm\"
" port)))
            (chmod script #o755))))))
   (synopsis "System reconfigure script")
   (description "Reconfigures Guix system and home.")
   (license #f)
   (home-page "")))

(define %nm-vpn-tailscale-script
  (let ((src (plain-file "10-vpn-tailscale-route"
                         (string-append
                          "#!/bin/sh\n"
                          "[ \"$2\" = \"vpn-up\" ] || exit 0\n"
                          "[ \"$CONNECTION_ID\" = \"" %ovpn-connection-id "\" ] || exit 0\n"
                          "/run/current-system/profile/sbin/ip route add "
                          %thinkcentre-ssh-hostname
                          "/32 dev tailscale0 2>/dev/null || true\n"))))
    (computed-file "10-vpn-tailscale-route"
                   #~(begin
                       (copy-file #$src #$output)
                       (chmod #$output #o755)))))

(operating-system
 (inherit asahi-sway-os)
 ;; Rose Pine main palette for the virtual console, active from boot
 ;; (including the login prompt). Colors 0-7 = normal, 8-15 = bright.
 (kernel-arguments
  (append (operating-system-user-kernel-arguments asahi-sway-os)
          '("vt.default_red=25,38,49,246,156,196,235,224,82,235,49,246,156,196,235,224"
            "vt.default_grn=23,35,116,193,207,167,188,222,79,111,116,193,207,167,188,222"
            "vt.default_blu=36,58,143,119,216,231,186,244,103,146,143,119,216,231,186,244")))
 (timezone "Europe/Kyiv")
 (locale "en_DK.UTF-8")
 (locale-definitions
  (cons* (locale-definition (name "en_DK.UTF-8") (source "en_DK"))
         (locale-definition (name "en_IE.UTF-8") (source "en_IE"))
         %default-locale-definitions))
 (users
  (cons* (user-account
          (name "miki")
          (group "users")
          (supplementary-groups '("wheel" "audio" "video" "input" "netdev"))
          (home-directory "/home/miki"))
         %base-user-accounts))
 (services
  (cons* (simple-service 'nm-connections
                         activation-service-type
                         #~(begin
                             ;; CA cert for the OpenVPN connection
                             (mkdir-p "/etc/NetworkManager/certs")
                             (let ((cert (string-append "/etc/NetworkManager/certs/"
                                                        #$%ovpn-connection-id "-ca.pem")))
                               (call-with-output-file cert
                                 (lambda (port) (display #$%vpn-ca-cert port)))
                               (chmod cert #o600))
                             ;; Connection files
                             (for-each
                              (lambda (id content)
                                (let ((path (string-append
                                             "/etc/NetworkManager/system-connections/"
                                             id ".nmconnection")))
                                  (call-with-output-file path
                                    (lambda (port) (display content port)))
                                  (chmod path #o600)))
                              (list #$%wifi-connection-id #$%ovpn-connection-id)
                              (list #$%wifi-nmconnection #$%nmconnection))
                             (system* #$(file-append network-manager "/bin/nmcli")
                                      "connection" "reload")))
         (extra-special-file
          "/etc/NetworkManager/dispatcher.d/10-vpn-tailscale-route"
          %nm-vpn-tailscale-script)
         (service tailscale-service-type)
         (service bluetooth-service-type
                  (bluetooth-configuration
                   (auto-enable? #t)))
         (service cups-service-type)
         (simple-service 'extra-hosts
                         hosts-service-type
                         %local-hosts)
         (modify-services (operating-system-user-services asahi-sway-os)
                          (delete guix-home-service-type)
                          (guix-service-type config =>
                                             (guix-configuration
                                              (inherit config)
                                              (substitute-urls
                                               (append (list "https://substitutes.nonguix.org")
                                                       %default-substitute-urls))
                                              (authorized-keys
                                               (append (list (plain-file "non-guix.pub"
                                                                         "(public-key (ecc (curve Ed25519) (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                                       %default-authorized-guix-keys))))
                          (network-manager-service-type config =>
                                                        (network-manager-configuration
                                                         (inherit config)
                                                         (vpn-plugins (list network-manager-openvpn))))
                          (delete sddm-service-type)
                          (console-font-service-type _ =>
                                                     (map (lambda (tty)
                                                            (cons tty (file-append font-terminus
                                                                                   "/share/consolefonts/ter-124b.psf.gz")))
                                                          '("tty1" "tty2" "tty3" "tty4" "tty5" "tty6")))
                          (elogind-service-type config =>
                                                (elogind-configuration
                                                 (inherit config)
                                                 (handle-lid-switch 'ignore)
                                                 (handle-lid-switch-external-power 'ignore)
                                                 (handle-suspend-key 'ignore)
                                                 (handle-hibernate-key 'ignore))))))
 (packages
  (cons*
   ;; system utilities
   file
   ncurses
   xdg-utils
   sysconf-script
   font-terminus

   ;; VPN / network management plugins
   openvpn
   network-manager-openvpn
   openresolv
   tailscale

   ;; Qt Wayland platform plugin (system-level for display server context)
   qtwayland

   (remove (lambda (p) (equal? "kitty" (package-name p)))
           (operating-system-packages asahi-sway-os))))
 (file-systems
  (cons* (file-system
          (device (uuid "848E-1AEE" 'fat32))
          (mount-point "/boot/efi")
          (needed-for-boot? #t)
          (type "vfat"))
         (file-system
          (device (file-system-label "asahi-guix-root"))
          (mount-point "/")
          (needed-for-boot? #t)
          (type "btrfs"))
         (file-system
          (device (file-system-label "asahi-guix-root"))
          (mount-point "/swap")
          (type "btrfs")
          (options "subvol=swap,nodatacow")
          (needed-for-boot? #f))
         %base-file-systems))
 (swap-devices
  (list (swap-space (target "/swap/swapfile")))))
