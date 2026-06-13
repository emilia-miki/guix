(define-module (packages preview-app)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix git-download)
  #:use-module (guix gexp)
  #:use-module (guix build-system pyproject)
  #:use-module (gnu packages python)
  #:use-module (gnu packages python-build)
  #:use-module (gnu packages python-xyz)
  #:use-module (gnu packages pdf)
  #:use-module (gnu packages ocr)
  #:use-module (gnu packages qt)
  #:use-module (gnu packages xorg))

(define-public preview-app
  (let ((commit "d2522555b2f8355f1b41a1f729399083c1b0d2fa")
        (revision "0"))
    (package
     (name "preview-app")
     (version (git-version "0.1.0" revision commit))
     (source
      (origin
       (method git-fetch)
       (uri (git-reference
             (url "https://github.com/mahdy-nasr/ocr-and-signer-for-linux")
             (commit commit)))
       (file-name (git-file-name name version))
       (sha256
        (base32
         "1kxyq6i4g03ii6far8dkcjwyraf8rxambwhbj13xairdaf4qnwas"))))
     (build-system pyproject-build-system)
     (arguments
      (list
       #:tests? #f
       #:phases
       #~(modify-phases %standard-phases
                        (delete 'sanity-check)
                        (add-after 'unpack 'fix-resource-path
                                   (lambda _
                                     (substitute* "pyproject.toml"
                                                  (("\\.\\./resources")
                                                   "resources"))
                                     (rename-file "resources" "src/resources")))
                        (add-after 'install 'install-desktop-entry
                                   (lambda _
                                     (let ((apps  (string-append #$output "/share/applications"))
                                           (icons (string-append #$output "/share/icons/hicolor/scalable/apps")))
                                       (mkdir-p apps)
                                       (mkdir-p icons)
                                       (copy-file
                                        "src/resources/icons/preview-app.svg"
                                        (string-append icons "/preview-app.svg"))
                                       (call-with-output-file
                                           (string-append apps "/preview-app.desktop")
                                         (lambda (port)
                                           (display "\
[Desktop Entry]
Name=Preview App
Comment=Image/PDF viewer with OCR text selection and PDF signing
Exec=preview-app %f
Icon=preview-app
Terminal=false
Type=Application
Categories=Graphics;Viewer;
MimeType=application/pdf;image/png;image/jpeg;image/bmp;image/tiff;image/webp;
" port)))))))))
     (propagated-inputs
      (list python-pyqt-6
            python-pyqt6-sip
            python-pymupdf
            python-pillow
            python-pytesseract
            tesseract-ocr))
     (native-inputs
      (list python-setuptools
            python-wheel))
     (inputs
      (list qtbase
            qtwayland
            libxcb
            xcb-util-cursor))
     (home-page "https://github.com/mahdy-nasr/ocr-and-signer-for-linux")
     (synopsis "Image/PDF viewer with OCR text selection and PDF signing")
     (description
      "Preview App is a macOS-Preview-style viewer for Linux.
It supports viewing images and PDFs, selecting text via OCR
(on scanned documents and screenshots), copying regions, and
signing PDFs with drawn or typed signatures.")
     (license license:gpl3+))))
