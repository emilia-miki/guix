(define-module (home kde)
  #:use-module (gnu home services)
  #:use-module (gnu services)
  #:use-module (guix gexp)
  #:export (%kde-services))

(define-public %kde-services
  (list
    (simple-service 'kde-xdg-config
      home-xdg-configuration-files-service-type
      `(("kwinrc"
         ,(local-file "files/kwinrc"))
        ("kdeglobals"
         ,(local-file "files/kdeglobals"))
        ("kglobalshortcutsrc"
         ,(local-file "files/kglobalshortcutsrc"))
        ("kxkbrc"
         ,(plain-file "kxkbrc"
            "[Layout]
DisplayNames=
Options=ctrl:hyper_capscontrol
ResetOldOptions=true
VariantList=
LayoutList=us
Use=true
"))
        ("kcminputrc"
         ,(plain-file "kcminputrc"
            "[Libinput][1452][641][Apple SPI Trackpad]
DisableWhileTyping=false
"))
        ("konsolerc"
         ,(plain-file "konsolerc"
            "MenuBar=Disabled

[Desktop Entry]
DefaultProfile=Custom.profile

[General]
ConfigVersion=1

[TabBar]
TabBarVisibility=AlwaysHideTabBar

[UiSettings]
ColorScheme=
"))))

    (simple-service 'kde-home-files
      home-files-service-type
      `((".local/share/konsole/Custom.profile"
         ,(local-file "files/Custom.profile"))
        (".local/share/konsole/Breeze.colorscheme"
         ,(local-file "files/Breeze.colorscheme"))))

    (simple-service 'kde-wallpaper-activation
      home-activation-service-type
      #~(begin
          (let* ((home (getenv "HOME"))
                 (wallpaper (string-append home "/Pictures/wallpapers/"
                              "dark-souls-3-kiln-of-the-first-flame-uhd-4k-wallpaper.jpg"))
                 (config-dir (string-append home "/.config")))
            (define (write-config name content)
              (call-with-output-file (string-append config-dir "/" name)
                (lambda (port) (display content port))))
            (write-config "kscreenlockerrc"
              (string-append
                "[Greeter][Wallpaper][org.kde.image][General]\n"
                "Image=file://" wallpaper "\n"
                "PreviewImage=file://" wallpaper "\n"))
            (write-config "plasmarc"
              (string-append
                "[Theme]\n"
                "name=Dexy-Color-Plasma\n"
                "\n"
                "[Wallpapers]\n"
                "usersWallpapers=" wallpaper "\n")))))))
