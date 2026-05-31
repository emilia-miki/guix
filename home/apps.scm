(define-module (home apps)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%apps-services))

(define-public %apps-services
  (list
    (simple-service 'apps-home-files
      home-files-service-type
      `((".local/share/applications/chrome-kadndpdhfiaigidpmcgmgabmbcjnjbgn-Teams.desktop"
         ,(plain-file "teams.desktop"
            "#!/usr/bin/env xdg-open
[Desktop Entry]
Version=1.0
Terminal=false
Type=Application
Name=Microsoft Teams (PWA)
Exec=/run/current-system/profile/bin/chromium --profile-directory=Teams --app-id=kadndpdhfiaigidpmcgmgabmbcjnjbgn
Icon=chrome-kadndpdhfiaigidpmcgmgabmbcjnjbgn-Teams
StartupWMClass=crx_kadndpdhfiaigidpmcgmgabmbcjnjbgn
"))))))
