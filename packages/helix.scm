(define-module (packages helix)
  #:use-module (guix packages)
  #:use-module (guix git-download)
  #:use-module (guix build-system cargo)
  #:use-module (guix gexp)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (gnu packages bash))

; Steel pulls in ~100 crates not packaged in Guix (cranelift, abi_stable,
; imbl, etc.), so we vendor everything.  Generate the vendor archive once
; from the helix checkout at the pinned commit:
;
;   cd ~/Projects/git/xxx/helix
;   git checkout d32de0548fa11f54283baae806c0458f06ea682e
;   cargo vendor guix-vendor
;   tar czf ~/Projects/guix/packages/files/helix-steel-vendor.tar.gz guix-vendor
;   guix hash ~/Projects/guix/packages/files/helix-steel-vendor.tar.gz

(define helix-steel-vendor
  (local-file "files/helix-steel-vendor.tar.gz"))

(define-public helix-steel
  (package
    (name "helix-steel")
    (version "25.7.1")
    (source
      (origin
        (method git-fetch)
        (uri (git-reference
               (url "https://github.com/mattwparas/helix.git")
               (commit "d32de0548fa11f54283baae806c0458f06ea682e")))
        (file-name (git-file-name name version))
        (sha256
          (base32 "13h3ih7czpvk8adk2lsm5flcv83k2zjxlmzyxbznb76y74zsmari"))))
    (build-system cargo-build-system)
    (arguments
      (list
        #:install-source? #f
        #:tests? #f
        #:cargo-build-flags ''("--release" "--features" "steel,git" "--bin" "hx")
        #:phases
        #~(modify-phases %standard-phases
            (add-after 'unpack 'disable-grammar-build
              (lambda _
                (setenv "HELIX_DISABLE_AUTO_GRAMMAR_BUILD" "1")))
            (add-after 'unpack 'unpack-vendor
              (lambda _
                ; cargo vendor produces a guix-vendor/ directory; the tarball
                ; preserves that as the top-level, so plain extraction works.
                (invoke "tar" "xzf" #$helix-steel-vendor)))
            (add-after 'unpack-vendor 'patch-steel-to-path-deps
              (lambda _
                ; cargo source replacement for git-pinned deps with #rev is
                ; broken in the Guix sandbox.  Rewrite the two git dep
                ; declarations to path deps into guix-vendor, and strip the
                ; git-source lines from Cargo.lock so it stays valid.
                (substitute* "Cargo.toml"
                  (("\\{ git = \"https://github\\.com/mattwparas/steel\\.git\", version = \"0\\.7\\.0\", features = \\[\"anyhow\", \"dylibs\", \"sync\", \"biased\", \"imbl\"\\] \\}")
                   "{ path = \"guix-vendor/steel-core\", features = [\"anyhow\", \"dylibs\", \"sync\", \"biased\", \"imbl\"] }"))
                (substitute* "helix-term/Cargo.toml"
                  (("\\{ git = \"https://github\\.com/mattwparas/steel\\.git\", version = \"0\\.7\\.0\", optional = true \\}")
                   "{ path = \"../guix-vendor/steel-doc\", optional = true }"))
                (substitute* "Cargo.lock"
                  (("source = \"git\\+https://github\\.com/mattwparas/steel\\.git#[0-9a-f]+\"\n")
                   ""))
                ; steel-core has `path = "../quickscope"` but cargo vendor
                ; names the directory after the package: steel-quickscope.
                (symlink "steel-quickscope" "guix-vendor/quickscope")
                ; git2 and cargo-steel-lib are optional deps inside the
                ; steel monorepo not included in the vendor tarball (they're
                ; never compiled since we don't enable those features), but
                ; cargo still needs to validate their manifests during
                ; dependency resolution.  Provide stubs to satisfy it.
                (for-each
                  (lambda (name version extra)
                    (let ((dir (string-append "guix-vendor/" name)))
                      (mkdir-p (string-append dir "/src"))
                      (call-with-output-file (string-append dir "/Cargo.toml")
                        (lambda (port)
                          (format port "[package]\nname = ~s\nversion = ~s\nedition = \"2021\"\n~a"
                                  name version extra)))
                      (call-with-output-file (string-append dir "/src/lib.rs")
                        (lambda (port) (display "" port)))
                      (call-with-output-file (string-append dir "/.cargo-checksum.json")
                        (lambda (port) (display "{\"files\":{}}" port)))))
                  '("cargo-steel-lib" "git2"   "ureq"    "criterion" "proptest" "pretty_assertions")
                  '("0.2.0"          "0.20.2" "3.0.12"  "0.5.1"     "1.1.0"    "1.4.0")
                  (list "" "[features]\nvendored-openssl = []\n" "" "" "" ""))))
            (replace 'install
              (lambda _
                (let* ((bin   (string-append #$output "/bin"))
                       (hx    (string-append bin "/hx"))
                       (share (string-append #$output "/share/helix"))
                       (runtime (string-append share "/runtime")))
                  (install-file "target/release/hx" bin)
                  (copy-recursively "runtime" runtime)
                  (wrap-program hx
                    `("HELIX_RUNTIME" prefix (,runtime)))))))))
    (inputs (list bash-minimal))
    (home-page "https://helix-editor.com/")
    (synopsis "Post-modern modal text editor with Steel scripting")
    (description
      "Helix built from the steel-event-system branch with the Steel Scheme
scripting engine enabled.")
    (license license:mpl2.0)))
