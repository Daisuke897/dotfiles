;;; init.el --- Summary
;;; Commentary:
;;; my init file of Emacs
;;; Code:

;; All files are opened in read-only mode.
(add-hook 'find-file-hook (lambda () (setq buffer-read-only t)))

(setq read-process-output-max (* 1024 1024)) ;; 1mb

;; Default display settings in macOS
(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :height 160)
  (set-frame-parameter nil 'alpha 85))

;; Trim new lines after the final line.
(setq-default delete-trailing-lines t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Get the path of the home directory.
(defvar user-home-directory (file-name-as-directory (getenv "HOME")))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(eval-when-compile
  (require 'use-package))

;; straight.el
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(use-package treesit
  :ensure nil
  :custom
  (treesit-font-lock-level 4)
  :config
  (setq treesit-language-source-alist
        '((python "https://github.com/tree-sitter/tree-sitter-python.git")
          (julia "https://github.com/tree-sitter/tree-sitter-julia.git" "v0.23.1")
          (rust "https://github.com/tree-sitter/tree-sitter-rust.git" "v0.23.3")
          (yaml "https://github.com/ikatyang/tree-sitter-yaml.git")
          (typescript "https://github.com/tree-sitter/tree-sitter-typescript.git" "master" "typescript/src")
          (tsx "https://github.com/tree-sitter/tree-sitter-typescript.git" "master" "tsx/src")
          (vue "https://github.com/ikatyang/tree-sitter-vue.git")
          (markdown "https://github.com/tree-sitter-grammars/tree-sitter-markdown.git" "v0.4.1" "tree-sitter-markdown/src")
          (markdown-inline "https://github.com/tree-sitter-grammars/tree-sitter-markdown.git" "v0.4.1" "tree-sitter-markdown-inline/src")
          (json "https://github.com/tree-sitter/tree-sitter-json.git")
          (css "https://github.com/tree-sitter/tree-sitter-css.git")
          (go "https://github.com/tree-sitter/tree-sitter-go")
          (gomod "https://github.com/camdencheek/tree-sitter-go-mod")
          (bash "https://github.com/tree-sitter/tree-sitter-bash.git" "v0.23.3")
          (toml "https://github.com/ikatyang/tree-sitter-toml.git"))))

(use-package julia-ts-mode
  :ensure t
  :mode "\\.jl\\'")

(use-package rust-ts-mode
  :ensure t
  :mode "\\.rs\\'")

(use-package python-ts-mode
  :mode "\\.py\\'"
  :functions (lsp-feature? lsp-format-buffer lsp-organize-imports)
  :preface
  (defun my/python-mode-setup ()
    (add-hook 'before-save-hook
              (lambda ()
                (when (and (eq major-mode 'python-ts-mode)
                           (bound-and-true-p lsp-mode)
                           (lsp-feature? "textDocument/codeAction"))
                  (lsp-format-buffer)
                  (lsp-organize-imports)))))
  :hook
  (python-ts-mode . my/python-mode-setup))

(use-package yaml-ts-mode
  :ensure t
  :mode
  ("\\.yaml\\'" . yaml-ts-mode)
  ("\\.yml\\'" . yaml-ts-mode))

(use-package bash-ts-mode
  :mode
  ("\\.sh\\'" . bash-ts-mode)
  :init
  (add-to-list 'major-mode-remap-alist '(sh-mode . bash-ts-mode)))

(use-package web-mode
  :ensure t
  :mode
  ("\\.vue\\'" . web-mode)
  ("\\.astro\\'" . web-mode)
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0)
  (setq web-mode-block-padding 0))

(use-package typescript-ts-mode
  :ensure t
  :mode
  ("\\.ts\\'" . typescript-ts-mode)
  ("\\.tsx\\'" . tsx-ts-mode))

(use-package markdown-ts-mode
  :ensure t
  :mode
  ("\\.md\\'" . markdown-ts-mode))

(use-package json-ts-mode
  :mode
  ("\\.json\\'" . json-ts-mode))

(use-package css-ts-mode
  :mode
  ("\\.css\\'" . css-ts-mode))

(use-package go-ts-mode
  :mode
  ("\\.go\\'" . go-ts-mode))

(use-package go-mod-ts-mode
  :mode
  ("go\\.mod\\'" . go-mod-ts-mode))

(use-package toml-ts-mode
  :mode
  ("\\.toml\\'" . toml-ts-mode))

(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-c g") 'counsel-git))

(use-package counsel
  :ensure t
  :config
  (counsel-mode 1))

(use-package magit
  :ensure t)

(use-package flycheck
  :ensure t
  :custom
  (flycheck-gfortran-language-standard "f2018")
  :preface
  (defvar-local flycheck-local-checkers nil)
  (defun my/flycheck-checker-get(fn checker property)
    (or (alist-get property (alist-get checker flycheck-local-checkers))
        (funcall fn checker property)))
  (advice-add 'flycheck-checker-get :around 'my/flycheck-checker-get)
  (advice-add 'flycheck-eslint-config-exists-p :override (lambda() t))
  :init
  (global-flycheck-mode)
  :functions flycheck-checker-get
  :config
  (setq flycheck-python-ruff-config (cons "~/dotfiles/ruff.toml" flycheck-python-ruff-config)))

(use-package company
  :ensure t
  :config
  (global-company-mode))

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package flycheck-cfn
  :ensure t)

(use-package cfn-mode
  :ensure t
  :preface
  (defun my-cfn-mode-setup ()
    (flycheck-cfn-setup)
      (setq flycheck-local-checkers
            '((lsp . ((next-checkers . (cfn-lint)))))))
  :hook
  (cfn-mode . my-cfn-mode-setup))

;; Lsp
(use-package lsp-mode
  :ensure t
  :after
  (lsp-yaml
   lsp-javascript
   lsp-volar
   lsp-eslint
   lsp-julia
   lsp-tex
   lsp-fortran
   lsp-ruff
   lsp-pyright
   lsp-marksman
   lsp-json
   lsp-css
   lsp-astro)
  :hook
  (f90-mode . lsp)
  (rust-ts-mode . lsp)
  (julia-ts-mode . lsp)
  (tex-mode . lsp)
  (python-ts-mode . lsp)
  (web-mode . lsp)
  (yaml-ts-mode . lsp)
  (typescript-ts-mode . lsp)
  (markdown-ts-mode . lsp)
  (json-ts-mode . lsp)
  (css-ts-mode . lsp)
  :config
  (push 'semgrep-ls lsp-disabled-clients)
  (lsp-dependency 'typescript
                  (remove '(:system "tsserver") (gethash 'typescript lsp--dependencies))))

(use-package lsp-yaml
  :custom
  (lsp-yaml-server-command `("apptainer"
                             "run"
                             ,(concat user-home-directory
                                      "dotfiles/images/yaml_language_server.sif")
                             "--stdio"))
  (lsp-yaml-custom-tags (vector
                         "!And"
                         "!If"
                         "!Not"
                         "!Equals"
                         "!Or"
                         "!FindInMap"
                         "!Base64"
                         "!Cidr"
                         "!Ref"
                         "!Sub"
                         "!GetAtt"
                         "!GetAZs"
                         "!ImportValue"
                         "!Select"
                         "!Split"
                         "!Join"
                         "!And sequence"
                         "!If sequence"
                         "!Not sequence"
                         "!Equals sequence"
                         "!Or sequence"
                         "!FindInMap sequence"
                         "!Join sequence"
                         "!Sub sequence"
                         "!ImportValue sequence"
                         "!Select sequence"
                         "!Split sequence"))
  :config
  (let ((yaml-client (copy-lsp--client (gethash 'yamlls lsp-clients))))
    (when yaml-client
      (remhash 'yamlls lsp-clients)
      (puthash 'yamlls
               (make-lsp--client
                :language-id (lsp--client-language-id yaml-client)
                :add-on? t
                :new-connection (lsp--client-new-connection yaml-client)
                :ignore-regexps (lsp--client-ignore-regexps yaml-client)
                :ignore-messages (lsp--client-ignore-messages yaml-client)
                :notification-handlers (lsp--client-notification-handlers yaml-client)
                :request-handlers (lsp--client-request-handlers yaml-client)
                :response-handlers (lsp--client-response-handlers yaml-client)
                :prefix-function (lsp--client-prefix-function yaml-client)
                :uri-handlers (lsp--client-uri-handlers yaml-client)
                :action-handlers (lsp--client-action-handlers yaml-client)
                :action-filter (lsp--client-action-filter yaml-client)
                :major-modes (lsp--client-major-modes yaml-client)
                :activation-fn (lsp--client-activation-fn yaml-client)
                :priority (lsp--client-priority yaml-client)
                :server-id (lsp--client-server-id yaml-client)
                :multi-root (lsp--client-multi-root yaml-client)
                :initialization-options (lsp--client-initialization-options yaml-client)
                :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides yaml-client)
                :custom-capabilities (lsp--client-custom-capabilities yaml-client)
                :library-folders-fn (lsp--client-library-folders-fn yaml-client)
                :before-file-open-fn (lsp--client-before-file-open-fn yaml-client)
                :initialized-fn (lsp--client-initialized-fn yaml-client)
                :remote? (lsp--client-remote? yaml-client)
                :completion-in-comments? (lsp--client-completion-in-comments? yaml-client)
                :path->uri-fn (lsp--client-path->uri-fn yaml-client)
                :uri->path-fn (lsp--client-uri->path-fn yaml-client)
                :environment-fn (lsp--client-environment-fn yaml-client)
                :after-open-fn (lsp--client-after-open-fn yaml-client)
                :async-request-handlers (lsp--client-async-request-handlers yaml-client)
                :download-server-fn (lsp--client-download-server-fn yaml-client)
                :download-in-progress? (lsp--client-download-in-progress? yaml-client)
                :buffers (lsp--client-buffers yaml-client)
                :synchronize-sections (lsp--client-synchronize-sections yaml-client)
                )
               lsp-clients))))

(use-package lsp-javascript
  :preface
  ;; Enable the js-ts LSP server when opening Vue.js files.
  (defun my/lsp-typescript-javascript-tsx-jsx-activate-p (filename &optional _)
    "Check if the js-ts lsp server should be enabled based on FILENAME."
    (or (string-match-p
         "\\(?:\\.cjs\\|\\.mjs\\|\\.js\\|\\.jsx\\|\\.ts\\|\\.tsx\\|\\.vue\\|\\.astro\\)\\'"
         filename)
        (and (derived-mode-p 'js-mode 'js-ts-mode 'typescript-mode 'typescript-ts-mode)
             (not (derived-mode-p 'json-mode)))))
  :custom
  (lsp-clients-typescript-prefer-use-project-ts-server t)
  (lsp-clients-typescript-plugins
   (vector (list :name "@vue/typescript-plugin"
                 :location "/usr/local/lib/node_modules/@vue/typescript-plugin"
                 :languages (vector "typescript" "javascript" "vue"))
           (list :name "@astrojs/ts-plugin"
                 :location "/usr/local/lib/node_modules/@astrojs/ts-plugin"
                 :languages (vector "typescript" "javascript" "astro"))))
  (lsp-clients-typescript-tls-path "apptainer")
  (lsp-clients-typescript-server-args `("run"
                                        ,(concat user-home-directory
                                                 "dotfiles/images/typescript_language_server.sif")
                                        "--stdio"))
  ;; Disable format for ts-ls.
  (lsp-javascript-format-enable nil)
  (lsp-typescript-format-enable nil)
  :config
  (lsp-dependency 'typescript
                  (remove '(:system "tsserver") (gethash 'typescript lsp--dependencies)))
  (let ((js-client (copy-lsp--client (gethash 'ts-ls lsp-clients))))
    (when js-client
      (remhash 'ts-ls lsp-clients)
      (puthash 'ts-ls
               (make-lsp--client
                :language-id (lsp--client-language-id js-client)
                :add-on? t
                :new-connection (lsp--client-new-connection js-client)
                :ignore-regexps (lsp--client-ignore-regexps js-client)
                :ignore-messages (lsp--client-ignore-messages js-client)
                :notification-handlers (lsp--client-notification-handlers js-client)
                :request-handlers (lsp--client-request-handlers js-client)
                :response-handlers (lsp--client-response-handlers js-client)
                :prefix-function (lsp--client-prefix-function js-client)
                :uri-handlers (lsp--client-uri-handlers js-client)
                :action-handlers (lsp--client-action-handlers js-client)
                :action-filter (lsp--client-action-filter js-client)
                :major-modes (lsp--client-major-modes js-client)
                :activation-fn #'my/lsp-typescript-javascript-tsx-jsx-activate-p
                :priority 0
                :server-id (lsp--client-server-id js-client)
                :multi-root (lsp--client-multi-root js-client)
                :initialization-options (lsp--client-initialization-options js-client)
                :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides js-client)
                :custom-capabilities (lsp--client-custom-capabilities js-client)
                :library-folders-fn (lsp--client-library-folders-fn js-client)
                :before-file-open-fn (lsp--client-before-file-open-fn js-client)
                :initialized-fn (lsp--client-initialized-fn js-client)
                :remote? (lsp--client-remote? js-client)
                :completion-in-comments? (lsp--client-completion-in-comments? js-client)
                :path->uri-fn (lsp--client-path->uri-fn js-client)
                :uri->path-fn (lsp--client-uri->path-fn js-client)
                :environment-fn (lsp--client-environment-fn js-client)
                :after-open-fn (lsp--client-after-open-fn js-client)
                :async-request-handlers (lsp--client-async-request-handlers js-client)
                :download-server-fn (lsp--client-download-server-fn js-client)
                :download-in-progress? (lsp--client-download-in-progress? js-client)
                :buffers (lsp--client-buffers js-client)
                :synchronize-sections (lsp--client-synchronize-sections js-client)
                )
               lsp-clients))))

(use-package lsp-volar
  :custom
  (lsp-volar-hybrid-mode t)
  (lsp-volar-take-over-mode nil)
  :config
  (lsp-dependency 'typescript
                  (remove '(:system "tsserver") (gethash 'typescript lsp--dependencies)))
  (remhash 'volar-language-server lsp--dependencies)
  (lsp-dependency 'volar-language-server '(:system "apptainer"))
  (let ((vue-client (copy-lsp--client (gethash 'vue-semantic-server lsp-clients))))
    (when vue-client
      (remhash 'vue-semantic-server lsp-clients)
      (puthash 'vue-semantic-server
               (make-lsp--client
                :language-id (lsp--client-language-id vue-client)
                :add-on? t
                :new-connection
                (lsp-stdio-connection (lambda ()
                                        `(,(lsp-package-path 'volar-language-server)
                                          "run"
                                          ,(concat user-home-directory
                                                   "dotfiles/images/vue_language_server.sif")
                                          "--stdio")))
                :ignore-regexps (lsp--client-ignore-regexps vue-client)
                :ignore-messages (lsp--client-ignore-messages vue-client)
                :notification-handlers (lsp--client-notification-handlers vue-client)
                :request-handlers (lsp--client-request-handlers vue-client)
                :response-handlers (lsp--client-response-handlers vue-client)
                :prefix-function (lsp--client-prefix-function vue-client)
                :uri-handlers (lsp--client-uri-handlers vue-client)
                :action-handlers (lsp--client-action-handlers vue-client)
                :action-filter (lsp--client-action-filter vue-client)
                :major-modes (lsp--client-major-modes vue-client)
                :activation-fn (lsp--client-activation-fn vue-client)
                :priority 0
                :server-id (lsp--client-server-id vue-client)
                :multi-root (lsp--client-multi-root vue-client)
                :initialization-options (lsp--client-initialization-options vue-client)
                :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides vue-client)
                :custom-capabilities (lsp--client-custom-capabilities vue-client)
                :library-folders-fn (lsp--client-library-folders-fn vue-client)
                :before-file-open-fn (lsp--client-before-file-open-fn vue-client)
                :initialized-fn (lsp--client-initialized-fn vue-client)
                :remote? (lsp--client-remote? vue-client)
                :completion-in-comments? (lsp--client-completion-in-comments? vue-client)
                :path->uri-fn (lsp--client-path->uri-fn vue-client)
                :uri->path-fn (lsp--client-uri->path-fn vue-client)
                :environment-fn (lsp--client-environment-fn vue-client)
                :after-open-fn (lsp--client-after-open-fn vue-client)
                :async-request-handlers (lsp--client-async-request-handlers vue-client)
                :download-server-fn (lsp--client-download-server-fn vue-client)
                :download-in-progress? (lsp--client-download-in-progress? vue-client)
                :buffers (lsp--client-buffers vue-client)
                :synchronize-sections (lsp--client-synchronize-sections vue-client)
                )
               lsp-clients))))

(use-package lsp-eslint
  :preface
  (defun my/lsp-eslint-activate-p (filename &optional _)
    (when lsp-eslint-enable
      (or (string-match-p (rx (one-or-more anything) "."
                              (or "ts" "js" "jsx" "tsx" "html" "vue" "svelte" "astro")eos)
                          filename)
          (and (derived-mode-p 'js-mode 'js2-mode 'typescript-mode 'typescript-ts-mode 'html-mode 'svelte-mode)
               (not (string-match-p "\\.json\\'" filename))))))
  :custom
  (lsp-eslint-server-command `("apptainer"
                               "run"
                               ,(concat user-home-directory
                                        "dotfiles/images/eslint_language_server.sif")
                               "--stdio"))
  ;; eslintのformatを無効にする
  (lsp-eslint-format nil)
  :config
  (let ((eslint-client (copy-lsp--client (gethash 'eslint lsp-clients))))
    (when eslint-client
      (remhash 'eslint lsp-clients)
      (puthash 'eslint
               (make-lsp--client
                :language-id (lsp--client-language-id eslint-client)
                :add-on? t
                :new-connection (lsp--client-new-connection eslint-client)
                :ignore-regexps (lsp--client-ignore-regexps eslint-client)
                :ignore-messages (lsp--client-ignore-messages eslint-client)
                :notification-handlers (lsp--client-notification-handlers eslint-client)
                :request-handlers (lsp--client-request-handlers eslint-client)
                :response-handlers (lsp--client-response-handlers eslint-client)
                :prefix-function (lsp--client-prefix-function eslint-client)
                :uri-handlers (lsp--client-uri-handlers eslint-client)
                :action-handlers (lsp--client-action-handlers eslint-client)
                :action-filter (lsp--client-action-filter eslint-client)
                :major-modes (lsp--client-major-modes eslint-client)
                :activation-fn #'my/lsp-eslint-activate-p
                :priority 0
                :server-id (lsp--client-server-id eslint-client)
                :multi-root (lsp--client-multi-root eslint-client)
                :initialization-options (lsp--client-initialization-options eslint-client)
                :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides eslint-client)
                :custom-capabilities (lsp--client-custom-capabilities eslint-client)
                :library-folders-fn (lsp--client-library-folders-fn eslint-client)
                :before-file-open-fn (lsp--client-before-file-open-fn eslint-client)
                :initialized-fn (lsp--client-initialized-fn eslint-client)
                :remote? (lsp--client-remote? eslint-client)
                :completion-in-comments? (lsp--client-completion-in-comments? eslint-client)
                :path->uri-fn (lsp--client-path->uri-fn eslint-client)
                :uri->path-fn (lsp--client-uri->path-fn eslint-client)
                :environment-fn (lsp--client-environment-fn eslint-client)
                :after-open-fn (lsp--client-after-open-fn eslint-client)
                :async-request-handlers (lsp--client-async-request-handlers eslint-client)
                :download-server-fn (lsp--client-download-server-fn eslint-client)
                :download-in-progress? (lsp--client-download-in-progress? eslint-client)
                :buffers (lsp--client-buffers eslint-client)
                :synchronize-sections (lsp--client-synchronize-sections eslint-client)
                )
               lsp-clients))))

(use-package lsp-css
  :config
  (remhash 'css-languageserver lsp--dependencies)
  (lsp-dependency 'css-languageserver '(:system "apptainer"))
  (let ((css-client (copy-lsp--client (gethash 'css-ls lsp-clients))))
    (when css-client
      (remhash 'css-ls lsp-clients)
      (puthash 'css-ls
               (make-lsp--client
                :language-id (lsp--client-language-id css-client)
                :add-on? t
                :new-connection
                (lsp-stdio-connection (lambda ()
                                        (list (lsp-package-path 'css-languageserver)
                                              "run"
                                              (concat user-home-directory
                                                      "dotfiles/images/css_language_server.sif")
                                              "--stdio")))
                :ignore-regexps (lsp--client-ignore-regexps css-client)
                :ignore-messages (lsp--client-ignore-messages css-client)
                :notification-handlers (lsp--client-notification-handlers css-client)
                :request-handlers (lsp--client-request-handlers css-client)
                :response-handlers (lsp--client-response-handlers css-client)
                :prefix-function (lsp--client-prefix-function css-client)
                :uri-handlers (lsp--client-uri-handlers css-client)
                :action-handlers (lsp--client-action-handlers css-client)
                :action-filter (lsp--client-action-filter css-client)
                :major-modes (lsp--client-major-modes css-client)
                :activation-fn (lsp--client-activation-fn css-client)
                :priority 0
                :server-id (lsp--client-server-id css-client)
                :multi-root (lsp--client-multi-root css-client)
                :initialization-options (lsp--client-initialization-options css-client)
                :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides css-client)
                :custom-capabilities (lsp--client-custom-capabilities css-client)
                :library-folders-fn (lsp--client-library-folders-fn css-client)
                :before-file-open-fn (lsp--client-before-file-open-fn css-client)
                :initialized-fn (lsp--client-initialized-fn css-client)
                :remote? (lsp--client-remote? css-client)
                :completion-in-comments? (lsp--client-completion-in-comments? css-client)
                :path->uri-fn (lsp--client-path->uri-fn css-client)
                :uri->path-fn (lsp--client-uri->path-fn css-client)
                :environment-fn (lsp--client-environment-fn css-client)
                :after-open-fn (lsp--client-after-open-fn css-client)
                :async-request-handlers (lsp--client-async-request-handlers css-client)
                :download-server-fn (lsp--client-download-server-fn css-client)
                :download-in-progress? (lsp--client-download-in-progress? css-client)
                :buffers (lsp--client-buffers css-client)
                :synchronize-sections (lsp--client-synchronize-sections css-client)
                )
               lsp-clients))))

(use-package lsp-astro
  :config
  (lsp-dependency 'typescript
                  (remove '(:system "tsserver") (gethash 'typescript lsp--dependencies)))
  (remhash 'astro-language-server lsp--dependencies)
  (lsp-dependency 'astro-language-server '(:system "apptainer"))
  (let ((astro-client (copy-lsp--client (gethash 'astro-ls lsp-clients))))
    (when astro-client
      (remhash 'astro-ls lsp-clients)
      (puthash 'astro-ls
               (make-lsp--client
                :language-id (lsp--client-language-id astro-client)
                :add-on? t
                :new-connection
                (lsp-stdio-connection (lambda ()
                                        (list (lsp-package-path 'astro-language-server)
                                              "run"
                                              (concat user-home-directory
                                                      "dotfiles/images/astro_language_server.sif")
                                              "--stdio")))
                :ignore-regexps (lsp--client-ignore-regexps astro-client)
                :ignore-messages (lsp--client-ignore-messages astro-client)
                :notification-handlers (lsp--client-notification-handlers astro-client)
                :request-handlers (lsp--client-request-handlers astro-client)
                :response-handlers (lsp--client-response-handlers astro-client)
                :prefix-function (lsp--client-prefix-function astro-client)
                :uri-handlers (lsp--client-uri-handlers astro-client)
                :action-handlers (lsp--client-action-handlers astro-client)
                :action-filter (lsp--client-action-filter astro-client)
                :major-modes (lsp--client-major-modes astro-client)
                :activation-fn (lsp--client-activation-fn astro-client)
                :priority 0
                :server-id (lsp--client-server-id astro-client)
                :multi-root (lsp--client-multi-root astro-client)
                :initialization-options (lsp--client-initialization-options astro-client)
                :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides astro-client)
                :custom-capabilities (lsp--client-custom-capabilities astro-client)
                :library-folders-fn (lsp--client-library-folders-fn astro-client)
                :before-file-open-fn (lsp--client-before-file-open-fn astro-client)
                :initialized-fn (lsp--client-initialized-fn astro-client)
                :remote? (lsp--client-remote? astro-client)
                :completion-in-comments? (lsp--client-completion-in-comments? astro-client)
                :path->uri-fn (lsp--client-path->uri-fn astro-client)
                :uri->path-fn (lsp--client-uri->path-fn astro-client)
                :environment-fn (lsp--client-environment-fn astro-client)
                :after-open-fn (lsp--client-after-open-fn astro-client)
                :async-request-handlers (lsp--client-async-request-handlers astro-client)
                :download-server-fn (lsp--client-download-server-fn astro-client)
                :download-in-progress? (lsp--client-download-in-progress? astro-client)
                :buffers (lsp--client-buffers astro-client)
                :synchronize-sections (lsp--client-synchronize-sections astro-client)
                )
               lsp-clients))))

(use-package lsp-julia
  :custom
  (lsp-julia-default-environment "~/.julia/environments/v1.11")
  :config
  (let ((julia-client (gethash 'julia-ls lsp-clients)))
    (when julia-client
      (remhash 'julia-ls lsp-clients)
      (puthash 'julia-ls
               (make-lsp--client
                :language-id (lsp--client-language-id julia-client)
                :add-on? (lsp--client-add-on? julia-client)
                :new-connection
                (lsp-stdio-connection (lambda ()
                                        (append
                                         `("apptainer"
                                           "run"
                                           ,(concat user-home-directory
                                                    "dotfiles/images/julia_language_server.sif"))
                                         (cdr (lsp-julia--rls-command)))))
                :ignore-regexps (lsp--client-ignore-regexps julia-client)
                :ignore-messages (lsp--client-ignore-messages julia-client)
                :notification-handlers (lsp--client-notification-handlers julia-client)
                :request-handlers (lsp--client-request-handlers julia-client)
                :response-handlers (lsp--client-response-handlers julia-client)
                :prefix-function (lsp--client-prefix-function julia-client)
                :uri-handlers (lsp--client-uri-handlers julia-client)
                :action-handlers (lsp--client-action-handlers julia-client)
                :action-filter (lsp--client-action-filter julia-client)
                :major-modes (lsp--client-major-modes julia-client)
                :activation-fn (lsp--client-activation-fn julia-client)
                :priority (lsp--client-priority julia-client)
                :server-id (lsp--client-server-id julia-client)
                :multi-root (lsp--client-multi-root julia-client)
                :initialization-options (lsp--client-initialization-options julia-client)
                :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides julia-client)
                :custom-capabilities (lsp--client-custom-capabilities julia-client)
                :library-folders-fn (lsp--client-library-folders-fn julia-client)
                :before-file-open-fn (lsp--client-before-file-open-fn julia-client)
                :initialized-fn (lsp--client-initialized-fn julia-client)
                :remote? (lsp--client-remote? julia-client)
                :completion-in-comments? (lsp--client-completion-in-comments? julia-client)
                :path->uri-fn (lsp--client-path->uri-fn julia-client)
                :uri->path-fn (lsp--client-uri->path-fn julia-client)
                :environment-fn (lsp--client-environment-fn julia-client)
                :after-open-fn (lsp--client-after-open-fn julia-client)
                :async-request-handlers (lsp--client-async-request-handlers julia-client)
                :download-server-fn (lsp--client-download-server-fn julia-client)
                :download-in-progress? (lsp--client-download-in-progress? julia-client)
                :buffers (lsp--client-buffers julia-client)
                :synchronize-sections (lsp--client-synchronize-sections julia-client)
                )
               lsp-clients))))


(use-package lsp-fortran
  :init
  (setq lsp-clients-fortls-args '("--lowercase_intrinsics")))

(use-package lsp-ruff
  :custom
  (lsp-ruff-show-notifications "always"))

(use-package lsp-pyright
  :ensure t
  :custom
  (lsp-pyright-diagnostic-mode  "workspace")
  (lsp-pyright-python-executable-cmd "python3")
  (lsp-pyright-auto-import-completions nil)
  (lsp-pyright-type-checking-mode "strict"))

  :config

;; Org
(use-package org
  :custom
  (org-highlight-latex-and-related '(latex script entities)))

(use-package org-modern
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda))

;; Active Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)))

;; Formatter
(use-package sqlformat
  :ensure t
  :custom
  (sqlformat-command 'sql-formatter))

(use-package reformatter
  :ensure t
  :hook
  (python-ts-mode . ruff-format-on-save-mode)
  :config
  (reformatter-define ruff-format
    :program "ruff"
    :args '("format"
            "--config"
            "~/dotfiles/ruff.toml"
            "--stdin-filename"
            ,buffer-file-name "-")
    :lighter " RuffFmt"
    :group 'ruff-format)

  (reformatter-define prettier-vue
    :program "npx"
    :args `("prettier" "--log-level" "error" "--no-color" "--parser" "vue")
    :lighter " PrettierVue"
    :group 'prettier-vue)
  ;; Run prettier-vue when in web-mode and the file extension is .vue.
  (add-hook 'web-mode-hook
            (lambda ()
              (when (and (string= (file-name-extension buffer-file-name) "vue")
                         (string= (file-name-extension (buffer-file-name (buffer-base-buffer))) "vue"))
                (prettier-vue-on-save-mode)))))

(column-number-mode 1)

(set-language-environment "UTF-8")

(use-package mozc
  :ensure t
  :if (eq system-type 'gnu/linux)
  :config
  ;; "sudo apt install emacs-mozc-bin"
  (setq default-input-method "japanese-mozc"))

(setq-default ispell-program-name "aspell")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(modus-operandi-tinted))
 '(gc-cons-threshold 100000000)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(make-backup-files nil)
 '(menu-bar-mode nil)
 '(org-agenda-files nil)
 '(package-selected-packages
   '(cfn-mode company counsel flycheck flycheck-cfn ivy-bibtex js2-mode
              julia-mode lsp-cfn lsp-ivy lsp-julia lsp-mode
              lsp-pyright lsp-ui magit org-ref python-mode pyvenv
              reformatter rust-mode simple-httpd sqlformat
              symbol-overlay typescript-mode use-package web-mode
              yaml-mode yasnippet org-modern mozc markdown-ts-mode julia-ts-mode))
 '(require-final-newline t)
 '(scroll-bar-mode nil)
 '(show-trailing-whitespace t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'init)
;;; init.el ends here
