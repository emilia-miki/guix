(define-module (home wallpaper)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:export (%wallpaper))

(define-public %wallpaper
  (origin
    (method url-fetch)
    (uri "https://w.wallhaven.cc/full/x1/wallhaven-x1z2jz.jpg")
    (file-name "dark-souls-3-kiln-of-the-first-flame-uhd-4k-wallpaper.jpg")
    (sha256 (base32 "1150sf8nq23hwl1jhgv8anl29b8zq58pfvwzh6v3dd6zmla6qf2s"))))