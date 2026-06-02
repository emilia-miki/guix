(define-module (packages lem)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix gexp)
  #:use-module (guix utils)
  #:use-module (guix build-system asdf)
  #:use-module (guix build-system cmake)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages build-tools)
  #:use-module (gnu packages tree-sitter)
  #:use-module (gnu packages cmake)
  #:use-module (gnu packages gtk)
  #:use-module (gnu packages pkg-config)
  #:use-module (gnu packages webkit)
  #:use-module (gnu packages lisp-xyz)
  #:use-module ((gnu packages text-editors) #:select ((lem . upstream-lem))))

(define %lem-commit "803e4922f0965098b0b3ccb9acb95b37cc13a319")
(define %webview-commit "238a0be10c6c37311ce2587ef99142f65abd880a")

;;; Native WebKitGTK webview shared library, built from webview/webview upstream.
;;; The lem-project wrapper's libexample.so exports no symbols; building the
;;; upstream directly with WEBVIEW_BUILD_SHARED_LIBRARY=ON (default) is correct.

(define libwebview
  (package
    (name "libwebview")
    (version "0.12.0")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/webview/webview/archive/0.12.0.tar.gz")
        (sha256 (base32 "1nx1rgr1607f2ygq65baah1hs2qx7dyqni3l81i3xlgwsfzd1j72"))
        (file-name "webview-c-0.12.0.tar.gz")))
    (build-system cmake-build-system)
    (arguments
      (list
        #:tests? #f
        #:configure-flags
        #~(list "-DCMAKE_BUILD_TYPE=Release"
                "-DWEBVIEW_BUILD_STATIC_LIBRARY=OFF"
                "-DWEBVIEW_BUILD_TESTS=OFF"
                "-DWEBVIEW_BUILD_EXAMPLES=OFF"
                "-DWEBVIEW_BUILD_DOCS=OFF"
                "-DWEBVIEW_INSTALL_DOCS=OFF"
                (string-append "-DCMAKE_INSTALL_PREFIX=" #$output))
        #:phases
        #~(modify-phases %standard-phases
            (replace 'install
              (lambda* (#:key outputs #:allow-other-keys)
                (let* ((out  (assoc-ref outputs "out"))
                       (lib  (string-append out "/lib")))
                  (mkdir-p lib)
                  ;; Install the shared library and create a plain .so symlink
                  (invoke "cmake" "--install" "." "--prefix" out)
                  ;; Ensure a plain libwebview.so exists for dlopen("libwebview.so")
                  (unless (file-exists? (string-append lib "/libwebview.so"))
                    (system* "ln" "-s"
                             (car (find-files lib "libwebview\\.so\\."))
                             (string-append lib "/libwebview.so")))))))))
    (native-inputs (list cmake ninja pkg-config))
    (inputs (list webkitgtk-for-gtk3 gtk+))
    (home-page "https://github.com/webview/webview")
    (synopsis "WebKitGTK webview shared library")
    (description "Cross-platform webview shared library using WebKitGTK on Linux.")
    (license license:expat)))

;;; Common Lisp bindings for libwebview
;;; Library is found at runtime via LD_LIBRARY_PATH set in lem's wrap-program.

(define sbcl-webview
  (package
    (name "sbcl-webview")
    (version %webview-commit)
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/lem-project/webview/archive/"
                            %webview-commit ".tar.gz"))
        (sha256 (base32 "1l7rhl3ia5ny0m8hr1nl121qa943994b4akw8vbhgfb3sn79r0ak"))
        (file-name "lem-webview-238a0be.tar.gz")))
    (build-system asdf-build-system/sbcl)
    (arguments
      (list
        #:phases
        #~(modify-phases %standard-phases
            (add-before 'build 'expose-libwebview
              (lambda* (#:key inputs #:allow-other-keys)
                (setenv "LD_LIBRARY_PATH"
                        (string-append (assoc-ref inputs "libwebview") "/lib:"
                                       (or (getenv "LD_LIBRARY_PATH") "")))))
            (add-after 'unpack 'fix-library-path
              ;; Mirror the Nix approach: remove :search-path and the versioned
              ;; filename. LD_LIBRARY_PATH (set in lem's wrap-program) provides
              ;; the path at runtime; libwebview input provides it at build time.
              (lambda* (#:key inputs #:allow-other-keys)
                (use-modules (ice-9 textual-ports))
                (let* ((content (call-with-input-file "webview.lisp"
                                  get-string-all))
                       (start   (string-contains content
                                  "(define-foreign-library (libwebview"))
                       (marker  "(t (:default \"libwebview\")))")
                       (end     (+ (string-contains content marker)
                                   (string-length marker)))
                       (new-form
                         (string-append
                           "(define-foreign-library libwebview\n"
                           "  (:os-macosx \"libwebview.dylib\")\n"
                           "  (:unix \"libwebview.so\")\n"
                           "  (:windows \"webview.dll\")\n"
                           "  (t (:default \"libwebview\")))"))
                       (patched (string-append (substring content 0 start)
                                               new-form
                                               (substring content end))))
                  (call-with-output-file "webview.lisp"
                    (lambda (p) (display patched p)))))))))
    (inputs (list sbcl-cffi sbcl-float-features libwebview))
    (home-page "https://github.com/lem-project/webview")
    (synopsis "Common Lisp bindings for native webview")
    (description "CFFI bindings for the native WebKitGTK-based webview library.")
    (license license:expat)))

;;; tree-sitter-cl: CL bindings + C wrapper (by-value struct shim)

(define %tree-sitter-cl-commit "431b572d0e49d64a78320cc5f4b4a90391024ce6")

(define sbcl-tree-sitter-cl
  (package
    (name "sbcl-tree-sitter-cl")
    (version "0.1.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append "https://github.com/lem-project/tree-sitter-cl/archive/"
                            %tree-sitter-cl-commit ".tar.gz"))
        (sha256 (base32 "079gybmkj3zvd4j4cvk0szb28p6na5lx37pkji6l36jyy38yfzzq"))
        (file-name "tree-sitter-cl-431b572.tar.gz")))
    (build-system asdf-build-system/sbcl)
    (arguments
      (list
        #:tests? #f
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'fix-library-paths
              ;; Use short library names; LD_LIBRARY_PATH provides them at runtime.
              (lambda* (#:key inputs #:allow-other-keys)
                (substitute* "src/ffi.lisp"
                  ;; (:or "libtree-sitter.so.0" "libtree-sitter.so") -> short name
                  (("\\(:or \"libtree-sitter\\.so\\.0\" \"libtree-sitter\\.so\"\\)")
                   "\"libtree-sitter.so\"")
                  ;; "libts-wrapper.so" stays as-is (short name is correct)
                  )))
            (add-after 'fix-library-paths 'build-ts-wrapper
              (lambda* (#:key inputs #:allow-other-keys)
                (let ((out-lib (string-append #$output "/lib"))
                      (ts-inc  (string-append (assoc-ref inputs "tree-sitter") "/include"))
                      (ts-lib  (string-append (assoc-ref inputs "tree-sitter") "/lib")))
                  (mkdir-p out-lib)
                  (invoke "gcc" "-shared" "-fPIC"
                          "-o" (string-append out-lib "/libts-wrapper.so")
                          (string-append "-I" ts-inc)
                          "c-wrapper/ts-wrapper.c"
                          (string-append "-L" ts-lib)
                          "-ltree-sitter"))))
            ;; Make libts-wrapper.so findable when ASDF loads this system.
            (add-before 'build 'expose-output-lib
              (lambda* (#:key outputs #:allow-other-keys)
                (setenv "LD_LIBRARY_PATH"
                        (string-append (assoc-ref outputs "out") "/lib:"
                                       (or (getenv "LD_LIBRARY_PATH") ""))))))))
    (inputs (list tree-sitter sbcl-cffi sbcl-alexandria sbcl-trivial-garbage sbcl-babel))
    (home-page "https://github.com/lem-project/tree-sitter-cl")
    (synopsis "Common Lisp bindings for tree-sitter")
    (description "CFFI bindings for the tree-sitter incremental parsing library.")
    (license license:expat)))

;;; frugal-uuid: zero-dependency UUID library (needed by lem-claude-code)

(define sbcl-frugal-uuid
  (package
    (name "sbcl-frugal-uuid")
    (version "0.0.0-91c3cd2")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/ak-coram/cl-frugal-uuid/archive/91c3cd2ca619676f7b1cc2c87a1d370a070844d8.tar.gz")
        (sha256 (base32 "0v59civq8cqdg1zv8b4arwaxa90m8ip65kq91wp3syj3mq6jdhij"))
        (file-name "frugal-uuid-91c3cd2.tar.gz")))
    (build-system asdf-build-system/sbcl)
    (arguments (list #:tests? #f))
    (home-page "https://github.com/ak-coram/cl-frugal-uuid")
    (synopsis "Common Lisp UUID library with zero dependencies")
    (description "UUID generation library for Common Lisp.")
    (license license:expat)))

;;; Updated micros with call-graph system (needed by lem-living-canvas)

(define sbcl-micros-updated
  (package
    (inherit sbcl-micros)
    (version "0.0.0-2ec61c8")
    (source
      (origin
        (method url-fetch)
        (uri "https://github.com/lem-project/micros/archive/2ec61c8d6028d219cc511a0e41d9228761c84251.tar.gz")
        (sha256 (base32 "0l8xh6w3mzrycy67g69d9d1qmzws0qk0bxfdz9fggzlyvndkild2"))
        (file-name "micros-2ec61c8.tar.gz")))))

;;; jsonrpc patched to pre-compile local-domain-socket transport
;;; (needed by lem-server which lem-webview depends on)

(define sbcl-jsonrpc-with-uds
  (package
    (inherit sbcl-jsonrpc)
    (arguments
      (list
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'add-local-domain-socket-dep
              (lambda _
                (substitute* "jsonrpc.asd"
                  (("\"jsonrpc/main\"\\)")
                   "\"jsonrpc/main\"\n               \"jsonrpc/transport/local-domain-socket\")")))))))))

;;; Nightly lem: webview-ncurses build with desktop file and LD_LIBRARY_PATH wrapper.
;;; Drops SDL2 (not needed); adds webview frontend and desktop entry.

(define lem-nightly
  (package
    (inherit upstream-lem)
    (version (string-append "2.3.0-" (string-take %lem-commit 7)))
    (source
      (origin
        (inherit (package-source upstream-lem))
        (method url-fetch)
        (uri (string-append "https://github.com/lem-project/lem/archive/"
                            %lem-commit ".tar.gz"))
        (sha256
          (base32 "1bcgy4wmk25afqhfnd0qi1vw6f8ypman5fq6jihfqbbm71xvx28i"))
        (file-name (string-append "lem-" %lem-commit ".tar.gz"))))
    (inputs
      (modify-inputs (package-inputs upstream-lem)
        (delete "sbcl-sdl2" "sbcl-sdl2-image" "sbcl-sdl2-ttf")
        (prepend libwebview sbcl-webview sbcl-float-features
                 sbcl-command-line-arguments sbcl-deploy sbcl-cl-mustache
                 sbcl-lem-extension-manager sbcl-tree-sitter-cl
                 sbcl-frugal-uuid tree-sitter)))
    (arguments
      (substitute-keyword-arguments (package-arguments upstream-lem)
        ((#:phases phases)
         #~(modify-phases #$phases
             (add-before 'build 'expose-foreign-libs
               ;; asdf-build-system sets LIBRARY_PATH but not LD_LIBRARY_PATH;
               ;; CFFI dlopen needs this to find libwebview and libtree-sitter.
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (setenv "LD_LIBRARY_PATH"
                         (string-append
                           (assoc-ref inputs "libwebview") "/lib:"
                           (assoc-ref outputs "out") "/lib:"
                           (assoc-ref inputs "tree-sitter") "/lib:"
                           (assoc-ref inputs "sbcl-tree-sitter-cl") "/lib:"
                           (or (getenv "LD_LIBRARY_PATH") "")))))
             (add-after 'unpack 'default-to-ncurses
               ;; get-default-implementation tries :webview first; swap so the
               ;; plain CLI defaults to ncurses. The desktop entry still passes
               ;; -i webview explicitly.
               (lambda _
                 (substitute* "src/interface.lisp"
                   (("\\(list implementation :webview :ncurses :sdl2\\)")
                    "(list implementation :ncurses :webview :sdl2)"))))
             (add-after 'unpack 'fix-tabbar-ncurses-compat
               ;; tabbar/server calls change-view-to-html unconditionally;
               ;; in ncurses mode the view type doesn't match → crash.
               ;; Guard with a runtime check on the implementation type.
               (lambda _
                 (substitute* "frontends/server/tabbar.lisp"
                   (("\\(lem-server::change-view-to-html window \\(generate-html\\)\\)")
                    "(when (typep (lem-core:implementation) 'lem-server:jsonrpc)
      (lem-server::change-view-to-html window (generate-html)))"))))
             (add-after 'unpack 'fix-zig-mode-alternation
               ;; tokens with '("_") produces (:alternation "_") which
               ;; cl-ppcre rejects. Duplicate entry → valid two-choice alternation.
               (lambda _
                 (substitute* "extensions/zig-mode/zig-mode.lisp"
                   (("'\\(\"_\"\\)\\)")
                    "'(\"_\" \"_\"))"))))
             (replace 'build-program
               (lambda* (#:key outputs #:allow-other-keys)
                 (build-program
                   (string-append (assoc-ref outputs "out") "/bin/lem")
                   outputs
                   #:dependencies '("lem-webview" "lem-ncurses")
                   #:entry-program '((lem:main) 0))))
             (add-after 'build-program 'install-desktop
               (lambda* (#:key outputs #:allow-other-keys)
                 (let* ((out   (assoc-ref outputs "out"))
                        (apps  (string-append out "/share/applications"))
                        (icons (string-append out
                                 "/share/icons/hicolor/scalable/apps")))
                   (mkdir-p apps)
                   (mkdir-p icons)
                   (copy-file "scripts/install/lem.svg"
                              (string-append icons "/lem.svg"))
                   (call-with-output-file (string-append apps "/lem.desktop")
                     (lambda (p)
                       (format p "[Desktop Entry]~%")
                       (format p "Name=Lem~%")
                       (format p "Comment=Common Lisp editor/IDE with high expansibility~%")
                       (format p "Exec=~a -i webview %F~%"
                               (string-append out "/bin/lem"))
                       (format p "MimeType=text/english;text/plain;text/x-makefile;text/x-c++hdr;text/x-c++src;application/x-shellscript;text/x-c;text/x-c++;~%")
                       (format p "Icon=lem~%")
                       (format p "Terminal=false~%")
                       (format p "Type=Application~%")
                       (format p "Categories=Development;TextEditor;~%"))))))
             (add-after 'install-desktop 'wrap-lem
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (let* ((out     (assoc-ref outputs "out"))
                        (webview (assoc-ref inputs "libwebview"))
                        (ts      (assoc-ref inputs "sbcl-tree-sitter-cl"))
                        (tslib   (assoc-ref inputs "tree-sitter")))
                   (wrap-program (string-append out "/bin/lem")
                     `("LD_LIBRARY_PATH" ":" prefix
                       (,(string-append webview "/lib")
                        ,(string-append ts "/lib")
                        ,(string-append tslib "/lib")))))))))))))

(define-public lem
  (let ((rewrite (package-input-rewriting/spec
                   `(("sbcl-jsonrpc" . ,(const sbcl-jsonrpc-with-uds))
                     ("sbcl-micros"  . ,(const sbcl-micros-updated))))))
    (rewrite lem-nightly)))
