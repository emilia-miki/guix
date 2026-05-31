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
        ("kscreenlockerrc"
         ,(plain-file "kscreenlockerrc"
            "[Greeter][Wallpaper][org.kde.image][General]
Image=file:///home/miki/Pictures/wallpapers/dark-souls-3-kiln-of-the-first-flame-uhd-4k-wallpaper.jpg
PreviewImage=file:///home/miki/Pictures/wallpapers/dark-souls-3-kiln-of-the-first-flame-uhd-4k-wallpaper.jpg
"))
        ("plasmarc"
         ,(plain-file "plasmarc"
            "[Theme]
name=Dexy-Color-Plasma

[Wallpapers]
usersWallpapers=/home/miki/Pictures/wallpapers/dark-souls-3-kiln-of-the-first-flame-uhd-4k-wallpaper.jpg
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
         ,(local-file "files/Breeze.colorscheme"))))))
