;;; init.el --- Summary
;;; Commentary:
;;; my init file of Emacs
;;; Code:

;; 全てのファイルは読み込み専用で開く
(add-hook 'find-file-hook (lambda () (setq buffer-read-only t)))

(setq-default inhibit-startup-screen t)
(setq-default indent-tabs-mode nil)
(setq-default show-trailing-whitespace t)

(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq gc-cons-threshold 100000000)

;; デフォルトのフォントサイズを設定
(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :height 160)
  )

;; バックアップファイルを作成しない
(setq make-backup-files nil)

;; 改行を末尾に挿入する
(setq require-final-newline t)

;; 最終行以降の新しい行をトリミングする
(setq-default delete-trailing-lines t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(defvar user-home-directory (file-name-as-directory (getenv "HOME")))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(eval-when-compile
  (require 'use-package)
  )

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

(use-package julia-mode
  :ensure t
  :mode "\\.jl\\'"
  :interpreter "julia"
  )

(use-package rust-mode
  :ensure t
  :mode "\\.rs\\'"
  :interpreter "rust")

(use-package python-mode
  :ensure t
  :mode "\\.py\\'"
  :interpreter "python"
  :init
  (defun my/python-mode-setup ()
    (add-hook 'before-save-hook
              (lambda ()
                (when (and (eq major-mode 'python-mode)
                           (bound-and-true-p lsp-mode)
                           (lsp-feature? "textDocument/codeAction"))
                  ;; (lsp-format-buffer)
                  (lsp-organize-imports)
                  )
                )
              )
    )
  :hook
  (python-mode . my/python-mode-setup)
  )

(use-package yaml-mode
  :ensure t
  :after lsp-mode
  :mode
  ("\\.yaml\\'" . yaml-mode)
  ("\\.yml\\'" . yaml-mode)
  :interpreter "yaml"
  :hook
  (yaml-mode . lsp))

(use-package web-mode
  :ensure t
  :after lsp-mode reformatter
  :mode
  ("\\.vue\\'" . web-mode)
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-code-indent-offset 2)
  (setq web-mode-script-padding 0)
  (setq web-mode-style-padding 0)
  (setq web-mode-block-padding 0)
  ;; web-modeかつ拡張子が.vueの場合にprettier-vueを実行する
  (add-hook 'web-mode-hook
            (lambda ()
              (lsp)
              (when (and (string= (file-name-extension buffer-file-name) "vue")
                         (string= (file-name-extension (buffer-file-name (buffer-base-buffer))) "vue"))
                (prettier-vue-on-save-mode))))
  )


(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'")

(use-package ivy
  :ensure t
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-c g") 'counsel-git)
  )

(use-package counsel
  :ensure t
  :config
  (counsel-mode 1)
  )

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
  :config
  (setq flycheck-python-ruff-config (cons "~/dotfiles/ruff.toml" flycheck-python-ruff-config))
  (when (eq system-type 'gnu/linux)
    (setf (get 'python-ruff
               (flycheck--checker-property-name 'command))
          (append `("apptainer"
                    "exec"
                    ,(concat user-home-directory
                             "dotfiles/images/python_ruff.sif")
                    "/opt/ruff/bin/ruff")
                  (cdr (flycheck-checker-get 'python-ruff 'command))))
    )
  )

(use-package company
  :ensure t
  :config
  (global-company-mode)
  )

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1)
  )

(use-package lsp-mode
  :ensure t
  :hook
  (f90-mode . lsp)
  (rust-mode . lsp)
  (julia-mode . lsp)
  (tex-mode . lsp)
  (python-mode . lsp)
  :config
  (push 'semgrep-ls lsp-disabled-clients)
  )

;; macos の環境下で実行する

;; Github Copilot
(use-package copilot
  :if (eq system-type 'darwin)
  :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
  :ensure t
  :hook
  (prog-mode . copilot-mode)
  :bind (:map copilot-completion-map
              ("<tab>" . 'copilot-accept-completion)
              ("TAB" . 'copilot-accept-completion)
              ("C-TAB" . 'copilot-accept-completion-by-word)
              ("C-<tab>" . 'copilot-accept-completion-by-word))
  :config
  (add-to-list 'copilot-indentation-alist '(emacs-lisp-mode 2))
  (add-to-list 'copilot-indentation-alist '(lisp-interaction-mode 2))
  )

;; Github Copilot Chat
(use-package copilot-chat
  :if (eq system-type 'darwin)
  :straight (:host github :repo "chep/copilot-chat.el" :files ("*.el"))
  :after (request)
  :custom
  (copilot-chat-frontend 'org)
  )

(use-package flycheck-cfn
  :if (eq system-type 'darwin)
  :ensure t
  :requires flycheck
  :config
  (setf (flycheck-checker-get 'cfn-lint 'command)
        (append `(,(concat user-home-directory
                           ".pyenv/shims/cfn-lint"))
                (cdr (flycheck-checker-get 'cfn-lint 'command))))
  )

(use-package cfn-mode
  :if (eq system-type 'darwin)
  :ensure t
  :after (flycheck-cfn lsp-mode)
  :init
  (defun my-cfn-mode-setup ()
    (flycheck-cfn-setup)
    (when (derived-mode-p 'yaml-mode)
      (setq flycheck-local-checkers
            '((lsp . ((next-checkers . (cfn-lint))))))
      )
    )
  :hook
  (cfn-mode . my-cfn-mode-setup)
  )

(use-package lsp-yaml
  :if (eq system-type 'darwin)
  :after (lsp-mode gv)
  :custom
  (lsp-yaml-validate nil)
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
                         "!Split sequence"
                         )
                        )
  :config
  (require 'lsp-mode)
  (let ((client (copy-lsp--client (gethash 'yamlls lsp-clients))))
    (puthash 'yamlls
             (make-lsp--client
              :language-id (lsp--client-language-id client)
              ;; add-on? は t にする
              :add-on? t
              :new-connection (lsp--client-new-connection client)
              :ignore-regexps (lsp--client-ignore-regexps client)
              :ignore-messages (lsp--client-ignore-messages client)
              :notification-handlers (lsp--client-notification-handlers client)
              :request-handlers (lsp--client-request-handlers client)
              :response-handlers (lsp--client-response-handlers client)
              :prefix-function (lsp--client-prefix-function client)
              :uri-handlers (lsp--client-uri-handlers client)
              :action-handlers (lsp--client-action-handlers client)
              :action-filter (lsp--client-action-filter client)
              :major-modes (lsp--client-major-modes client)
              :activation-fn (lsp--client-activation-fn client)
              :priority (lsp--client-priority client)
              :server-id (lsp--client-server-id client)
              :multi-root (lsp--client-multi-root client)
              :initialization-options (lsp--client-initialization-options client)
              :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides client)
              :custom-capabilities (lsp--client-custom-capabilities client)
              :library-folders-fn (lsp--client-library-folders-fn client)
              :before-file-open-fn (lsp--client-before-file-open-fn client)
              :initialized-fn (lsp--client-initialized-fn client)
              :remote? (lsp--client-remote? client)
              :completion-in-comments? (lsp--client-completion-in-comments? client)
              :path->uri-fn (lsp--client-path->uri-fn client)
              :uri->path-fn (lsp--client-uri->path-fn client)
              :environment-fn (lsp--client-environment-fn client)
              :after-open-fn (lsp--client-after-open-fn client)
              :async-request-handlers (lsp--client-async-request-handlers client)
              :download-server-fn (lsp--client-download-server-fn client)
              :download-in-progress? (lsp--client-download-in-progress? client)
              :buffers (lsp--client-buffers client)
              :synchronize-sections (lsp--client-synchronize-sections client)
              )
             lsp-clients)
    )
  )

(use-package lsp-javascript
  :after lsp-mode
  :preface
  ;; Vue.js のファイルを開いたときにも js-ts lsp server を有効にする
  (defun my/lsp-typescript-javascript-tsx-jsx-activate-p (filename &optional _)
    "Check if the js-ts lsp server should be enabled based on FILENAME."
    (or (string-match-p "\\.[cm]js\\|\\.[jt]sx?\\|\\.vue\\'" filename)
        (and (derived-mode-p 'js-mode 'js-ts-mode 'typescript-mode 'typescript-ts-mode)
             (not (derived-mode-p 'json-mode)))))
  :custom
  (lsp-typescript-locale "ja")
  (lsp-clients-typescript-prefer-use-project-ts-server t)
  (lsp-clients-typescript-plugins
   (vector (list :name "@vue/typescript-plugin"
                 :location (cond ((eq system-type 'darwin)
                                  (concat user-home-directory
                                          "Software/vuejs/language-tools/packages/language-server/node_modules/@vue/typescript-plugin")
                                  )
                                 ((eq system-type 'gnu/linux)
                                  "/opt/language-tools/packages/language-server/node_modules/@vue/typescript-plugin"))
                 :languages (vector "typescript" "javascript" "vue")))
   )
  (lsp-clients-typescript-tls-path (cond ((eq system-type 'gnu/linux)
                                          "apptainer"
                                          )
                                         (t "typescript-language-server")))
  (lsp-clients-typescript-server-args (cond ((eq system-type 'gnu/linux)
                                             `("run"
                                               ,(concat user-home-directory
                                                        "dotfiles/images/typescript_language_server.sif"))
                                             )
                                            (t '("--stdio"))))
  :config
  (puthash
   'typescript
   (remove '(:system "tsserver") (gethash 'typescript lsp--dependencies))
   lsp--dependencies
   )
  (require 'lsp-mode)
  (let ((client (copy-lsp--client (gethash 'ts-ls lsp-clients))))
    (puthash 'ts-ls
             (make-lsp--client
              :language-id (lsp--client-language-id client)
              ;; add-on? は t にする
              :add-on? t
              :new-connection (lsp--client-new-connection client)
              :ignore-regexps (lsp--client-ignore-regexps client)
              :ignore-messages (lsp--client-ignore-messages client)
              :notification-handlers (lsp--client-notification-handlers client)
              :request-handlers (lsp--client-request-handlers client)
              :response-handlers (lsp--client-response-handlers client)
              :prefix-function (lsp--client-prefix-function client)
              :uri-handlers (lsp--client-uri-handlers client)
              :action-handlers (lsp--client-action-handlers client)
              :action-filter (lsp--client-action-filter client)
              :major-modes (lsp--client-major-modes client)
              ;; activation-fn は my/lsp-typescript-javascript-tsx-jsx-activate-p にする
              :activation-fn 'my/lsp-typescript-javascript-tsx-jsx-activate-p
              ;; priority は 0 にする
              :priority 0
              :server-id (lsp--client-server-id client)
              :multi-root (lsp--client-multi-root client)
              :initialization-options (lsp--client-initialization-options client)
              :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides client)
              :custom-capabilities (lsp--client-custom-capabilities client)
              :library-folders-fn (lsp--client-library-folders-fn client)
              :before-file-open-fn (lsp--client-before-file-open-fn client)
              :initialized-fn (lsp--client-initialized-fn client)
              :remote? (lsp--client-remote? client)
              :completion-in-comments? (lsp--client-completion-in-comments? client)
              :path->uri-fn (lsp--client-path->uri-fn client)
              :uri->path-fn (lsp--client-uri->path-fn client)
              :environment-fn (lsp--client-environment-fn client)
              :after-open-fn (lsp--client-after-open-fn client)
              :async-request-handlers (lsp--client-async-request-handlers client)
              :download-server-fn (lsp--client-download-server-fn client)
              :download-in-progress? (lsp--client-download-in-progress? client)
              :buffers (lsp--client-buffers client)
              :synchronize-sections (lsp--client-synchronize-sections client)
              )
             lsp-clients)
    )
  )

(use-package lsp-volar
  :after (lsp-mode lsp-javascript)
  :custom
  (lsp-volar-hybrid-mode t)
  (lsp-volar-take-over-mode nil)
  :config
  (puthash
   'typescript
   (remove '(:system "tsserver") (gethash 'typescript lsp--dependencies))
   lsp--dependencies
   )
  (puthash 'volar-language-server
           `(,`(:system
                ,(cond ((eq system-type 'gnu/linux)
                        "apptainer")
                       ((eq system-type 'darwin)
                        (concat user-home-directory
                                "Software/vuejs/language-tools/packages/language-server/bin/vue-language-server.js")
                        )
                       )))
           lsp--dependencies)
  (require 'lsp-mode)
  (let ((client (copy-lsp--client (gethash 'vue-semantic-server lsp-clients))))
    (puthash 'vue-semantic-server
             (make-lsp--client
              :language-id (lsp--client-language-id client)
              ;; add-on? は t にする
              :add-on? t
              :new-connection (cond ((eq system-type 'gnu/linux)
                                     (lsp-stdio-connection
                                      (lambda ()
                                        `(,(lsp-package-path 'volar-language-server)
                                          "run"
                                          ,(concat user-home-directory
                                                   "dotfiles/images/vue_language_server.sif"))))
                                     )
                                    (t (lsp--client-new-connection client)))
              :ignore-regexps (lsp--client-ignore-regexps client)
              :ignore-messages (lsp--client-ignore-messages client)
              :notification-handlers (lsp--client-notification-handlers client)
              :request-handlers (lsp--client-request-handlers client)
              :response-handlers (lsp--client-response-handlers client)
              :prefix-function (lsp--client-prefix-function client)
              :uri-handlers (lsp--client-uri-handlers client)
              :action-handlers (lsp--client-action-handlers client)
              :action-filter (lsp--client-action-filter client)
              :major-modes (lsp--client-major-modes client)
              :activation-fn (lsp--client-activation-fn client)
              ;; priority は 0 にする
              :priority 0
              :server-id (lsp--client-server-id client)
              :multi-root (lsp--client-multi-root client)
              :initialization-options (lsp--client-initialization-options client)
              :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides client)
              :custom-capabilities (lsp--client-custom-capabilities client)
              :library-folders-fn (lsp--client-library-folders-fn client)
              :before-file-open-fn (lsp--client-before-file-open-fn client)
              :initialized-fn (lsp--client-initialized-fn client)
              :remote? (lsp--client-remote? client)
              :completion-in-comments? (lsp--client-completion-in-comments? client)
              :path->uri-fn (lsp--client-path->uri-fn client)
              :uri->path-fn (lsp--client-uri->path-fn client)
              :environment-fn (lsp--client-environment-fn client)
              :after-open-fn (lsp--client-after-open-fn client)
              :async-request-handlers (lsp--client-async-request-handlers client)
              :download-server-fn (lsp--client-download-server-fn client)
              :download-in-progress? (lsp--client-download-in-progress? client)
              :buffers (lsp--client-buffers client)
              :synchronize-sections (lsp--client-synchronize-sections client)
              )
             lsp-clients)
    )
  )

(use-package lsp-eslint
  :after lsp-mode
  :custom
  (lsp-eslint-server-command
   (cond ((eq system-type 'darwin)
          `("node"
            ,(concat user-home-directory
                     "Software/vscode-eslint/server/out/eslintServer.js")
            "--stdio")
          )
         ((eq system-type 'gnu/linux)
          `("apptainer"
            "run"
            ,(concat user-home-directory
                     "dotfiles/images/eslint_language_server.sif"))
          )
         (t
          `("node"
            "~/server/out/eslintServer.js"
            "--stdio"))
         )
   )
  :config
  (require 'lsp-mode)
  (let ((client (copy-lsp--client (gethash 'eslint lsp-clients))))
    (puthash 'eslint
             (make-lsp--client
              :language-id (lsp--client-language-id client)
              ;; add-on? は t にする
              :add-on? t
              :new-connection (lsp--client-new-connection client)
              :ignore-regexps (lsp--client-ignore-regexps client)
              :ignore-messages (lsp--client-ignore-messages client)
              :notification-handlers (lsp--client-notification-handlers client)
              :request-handlers (lsp--client-request-handlers client)
              :response-handlers (lsp--client-response-handlers client)
              :prefix-function (lsp--client-prefix-function client)
              :uri-handlers (lsp--client-uri-handlers client)
              :action-handlers (lsp--client-action-handlers client)
              :action-filter (lsp--client-action-filter client)
              :major-modes (lsp--client-major-modes client)
              :activation-fn (lsp--client-activation-fn client)
              ;; priority は 0 にする
              :priority 0
              :server-id (lsp--client-server-id client)
              :multi-root (lsp--client-multi-root client)
              :initialization-options (lsp--client-initialization-options client)
              :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides client)
              :custom-capabilities (lsp--client-custom-capabilities client)
              :library-folders-fn (lsp--client-library-folders-fn client)
              :before-file-open-fn (lsp--client-before-file-open-fn client)
              :initialized-fn (lsp--client-initialized-fn client)
              :remote? (lsp--client-remote? client)
              :completion-in-comments? (lsp--client-completion-in-comments? client)
              :path->uri-fn (lsp--client-path->uri-fn client)
              :uri->path-fn (lsp--client-uri->path-fn client)
              :environment-fn (lsp--client-environment-fn client)
              :after-open-fn (lsp--client-after-open-fn client)
              :async-request-handlers (lsp--client-async-request-handlers client)
              :download-server-fn (lsp--client-download-server-fn client)
              :download-in-progress? (lsp--client-download-in-progress? client)
              :buffers (lsp--client-buffers client)
              :synchronize-sections (lsp--client-synchronize-sections client)
              )
             lsp-clients)
    )
  )

(use-package sqlformat
  :if (eq system-type 'darwin)
  :ensure t
  :custom
  (sqlformat-command 'sql-formatter)
  )

;; Linux の環境下で実行する
(use-package lsp-julia
  :after lsp-mode
  :if (eq system-type 'gnu/linux)
  :preface
  (defun my-lsp-julia--rls-command ()
    "The command to lauch the Julia Language Server."
    `(,lsp-julia-command
      ,@lsp-julia-flags
      ,(concat "-e "
               "\"import Pkg; Pkg.instantiate(); "
               "using LanguageServer, LanguageServer.SymbolServer; "
               "server = LanguageServer.LanguageServerInstance("
               "stdin, stdout, "
               "\"" (lsp-julia--get-root) "\", "
               "\"" (lsp-julia--get-depot-path) "\", "
               "\"" (lsp-julia--symbol-server-store-path-to-jl) "\"); "
               "run(server);\""))
    )
  :custom
  (lsp-julia-command "apptainer")
  (lsp-julia-package-dir "/opt/julia")
  (lsp-julia-default-environment "~/.julia/environments/v1.10")
  :config
  (setq lsp-julia-flags `("exec"
                          ,(concat user-home-directory
                                   "dotfiles/images/"
                                   "julia_language_server.sif")
                          "julia"
                          ,@lsp-julia-flags)
        )
  (let ((client (copy-lsp--client (gethash 'julia-ls lsp-clients))))
    (puthash 'julia-ls
             (make-lsp--client
              :language-id (lsp--client-language-id client)
              :add-on? (lsp--client-add-on? client)
              :new-connection (lsp-stdio-connection 'my-lsp-julia--rls-command)
              :ignore-regexps (lsp--client-ignore-regexps client)
              :ignore-messages (lsp--client-ignore-messages client)
              :notification-handlers (lsp--client-notification-handlers client)
              :request-handlers (lsp--client-request-handlers client)
              :response-handlers (lsp--client-response-handlers client)
              :prefix-function (lsp--client-prefix-function client)
              :uri-handlers (lsp--client-uri-handlers client)
              :action-handlers (lsp--client-action-handlers client)
              :action-filter (lsp--client-action-filter client)
              :major-modes (lsp--client-major-modes client)
              :activation-fn (lsp--client-activation-fn client)
              :priority (lsp--client-priority client)
              :server-id (lsp--client-server-id client)
              :multi-root (lsp--client-multi-root client)
              :initialization-options (lsp--client-initialization-options client)
              :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides client)
              :custom-capabilities (lsp--client-custom-capabilities client)
              :library-folders-fn (lsp--client-library-folders-fn client)
              :before-file-open-fn (lsp--client-before-file-open-fn client)
              :initialized-fn (lsp--client-initialized-fn client)
              :remote? (lsp--client-remote? client)
              :completion-in-comments? (lsp--client-completion-in-comments? client)
              :path->uri-fn (lsp--client-path->uri-fn client)
              :uri->path-fn (lsp--client-uri->path-fn client)
              :environment-fn (lsp--client-environment-fn client)
              :after-open-fn (lsp--client-after-open-fn client)
              :async-request-handlers (lsp--client-async-request-handlers client)
              :download-server-fn (lsp--client-download-server-fn client)
              :download-in-progress? (lsp--client-download-in-progress? client)
              :buffers (lsp--client-buffers client)
              :synchronize-sections (lsp--client-synchronize-sections client)
              )
             lsp-clients)
    )
  )


(use-package lsp-tex
  :if (eq system-type 'gnu/linux)
  :init
  (setq lsp-clients-texlab-executable "apptainer")
  (defun lsp-clients-texlab-args ()
    `(,lsp-clients-texlab-executable
      "run"
      ,(concat user-home-directory
               "dotfiles/images/latex_language_server.sif"))
    )
  :config
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection
                                     (lsp-clients-texlab-args))
                    :major-modes '(plain-tex-mode latex-mode)
                    :priority (if (eq lsp-tex-server 'texlab) 1 -1)
                    :server-id 'texlab)
   )
  )

(use-package lsp-rust
  :if (eq system-type 'gnu/linux)
  :custom
  (lsp-rust-analyzer-server-command
   `("apptainer" "run" ,(concat user-home-directory
                                "dotfiles/images/"
                                "rust_language_server.sif")))
  )

(use-package lsp-fortran
  :if (eq system-type 'gnu/linux)
  :init
  (setq lsp-clients-fortls-executable "apptainer")
  (setq lsp-clients-fortls-args `("run"
                                  ,(concat user-home-directory
                                           "dotfiles/images/"
                                           "fortran_language_server.sif")))
  )

(use-package reformatter
  :ensure t
  :config
  (reformatter-define ruff-format
    :program (cond ((eq system-type 'gnu/linux) "apptainer")
                   ((eq system-type 'darwin) "~/Software/ruff_lsp/bin/ruff"))
    :args (cond ((eq system-type 'gnu/linux)
                 `("exec"
                   ,(concat user-home-directory "dotfiles/images/python_ruff.sif")
                   "/opt/ruff/bin/ruff"
                   "format"
                   "--config"
                   "~/dotfiles/ruff.toml"
                   "--stdin-filename"
                   ,buffer-file-name "-"))
                ((eq system-type 'darwin)
                 `("format"
                   "--config"
                   "~/dotfiles/ruff.toml"
                   "--stdin-filename"
                   ,buffer-file-name "-")))
    :lighter " RuffFmt"
    :group 'ruff-format)
  (add-hook 'python-mode-hook 'ruff-format-on-save-mode)

  (reformatter-define prettier-vue
    :program "npx"
    :args `("prettier" "--log-level" "error" "--no-color" "--parser" "vue")
    :lighter " PrettierVue"
    :group 'prettier-vue)
  )

(use-package lsp-ruff-lsp
  :custom
  (lsp-ruff-lsp-server-command (cond ((eq system-type 'gnu/linux)
                                      `("apptainer"
                                        "exec"
                                        ,(concat user-home-directory
                                                 "dotfiles/images/python_ruff.sif")
                                        "/opt/ruff/bin/ruff-lsp"
                                        ))
                                     ((eq system-type 'darwin)
                                      `(,(concat user-home-directory
                                                 "Software/ruff_lsp/bin/ruff-lsp")))
                                      )
                               )
  (lsp-ruff-lsp-ruff-path (cond ((eq system-type 'gnu/linux)
                                 (vector "/opt/ruff/bin/ruff"))
                                ((eq system-type 'darwin)
                                 (vector (concat user-home-directory
                                                 "Software/ruff_lsp/bin/ruff")))
                                )
                          )
  (lsp-ruff-lsp-ruff-args (vector "--config"
                                  "~/dotfiles/ruff.toml"))
  (lsp-ruff-lsp-show-notifications "always")
  )

(use-package lsp-pyright
  :ensure t
  :custom
  (lsp-pyright-diagnostic-mode  "workspace")
  (lsp-pyright-typechecking-mode "strict")
  (lsp-pyright-python-executable-cmd "python3")
  (lsp-pyright-auto-import-completions nil)
  (lsp-pyright-use-library-code-for-types t)
  (lsp-pyright-stub-path (cond ((eq system-type 'gnu/linux)
                                (concat user-home-directory "/opt/python-type-stubs/stubs")
                                )
                               ((eq system-type 'darwin)
                                (concat user-home-directory "Software/python-type-stubs/stubs")
                                )
                               )
                         )
  :config
  (let ((client (copy-lsp--client (gethash 'pyright lsp-clients))))
    (puthash 'pyright
             (make-lsp--client
              :language-id (lsp--client-language-id client)
              ;; add-on? は t にする
              :add-on? t
              :new-connection
              (lsp-stdio-connection (cond ((eq system-type 'gnu/linux)
                                           (lambda ()
                                             (append `("apptainer"
                                                       "exec"
                                                       ,(concat user-home-directory
                                                                "dotfiles/images/python_pyright.sif")
                                                       "/opt/pyright/bin/pyright-langserver")
                                                     lsp-pyright-langserver-command-args
                                                     )
                                             )
                                           )
                                          ((eq system-type 'darwin)
                                           (lambda ()
                                             (cons (concat user-home-directory
                                                           "Software/pyright_lsp/bin/pyright-langserver")
                                                   lsp-pyright-langserver-command-args))
                                           )
                                          ))
              :ignore-regexps (lsp--client-ignore-regexps client)
              :ignore-messages (lsp--client-ignore-messages client)
              :notification-handlers (lsp--client-notification-handlers client)
              :request-handlers (lsp--client-request-handlers client)
              :response-handlers (lsp--client-response-handlers client)
              :prefix-function (lsp--client-prefix-function client)
              :uri-handlers (lsp--client-uri-handlers client)
              :action-handlers (lsp--client-action-handlers client)
              :action-filter (lsp--client-action-filter client)
              :major-modes (lsp--client-major-modes client)
              :activation-fn (lsp--client-activation-fn client)
              ;; priority は -2 にする
              :priority -2
              :server-id (lsp--client-server-id client)
              :multi-root (lsp--client-multi-root client)
              :initialization-options (lsp--client-initialization-options client)
              :semantic-tokens-faces-overrides (lsp--client-semantic-tokens-faces-overrides client)
              :custom-capabilities (lsp--client-custom-capabilities client)
              :library-folders-fn (lsp--client-library-folders-fn client)
              :before-file-open-fn (lsp--client-before-file-open-fn client)
              :initialized-fn (lsp--client-initialized-fn client)
              :remote? (lsp--client-remote? client)
              :completion-in-comments? (lsp--client-completion-in-comments? client)
              :path->uri-fn (lsp--client-path->uri-fn client)
              :uri->path-fn (lsp--client-uri->path-fn client)
              :environment-fn (lsp--client-environment-fn client)
              :after-open-fn (lsp--client-after-open-fn client)
              :async-request-handlers (lsp--client-async-request-handlers client)
              :download-server-fn (lsp--client-download-server-fn client)
              :download-in-progress? (lsp--client-download-in-progress? client)
              :buffers (lsp--client-buffers client)
              :synchronize-sections (lsp--client-synchronize-sections client)
              )
             lsp-clients)
    )
  )

(use-package symbol-overlay
  :ensure t
  :config
  (global-set-key (kbd "M-i") 'symbol-overlay-put)
  (global-set-key (kbd "M-n") 'symbol-overlay-switch-forward)
  (global-set-key (kbd "M-p") 'symbol-overlay-switch-backward)
  (global-set-key (kbd "<f7>") 'symbol-overlay-mode)
  (global-set-key (kbd "<f8>") 'symbol-overlay-remove-all)
  )

(use-package org
  :custom
  (org-highlight-latex-and-related '(latex script entities)))

;; active Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)))

;; docker
(use-package docker
  :bind ("C-c d" . docker))

(column-number-mode 1)

(load-theme 'tango-dark t)

(set-language-environment "UTF-8")

(when (eq system-type 'gnu/linux)
  (require 'mozc)
  (setq default-input-method "japanese-mozc")
  ;; "sudo apt install emacs-mozc-bin"
  )

(setq-default ispell-program-name "aspell")

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(menu-bar-mode nil)
 '(org-agenda-files nil)
 '(package-selected-packages
   '(reformatter lsp-cfn cfn-mode vue-mode js2-mode typescript-mode yaml-mode docker dockerfile-mode python-mode ivy-bibtex org-ref rust-mode lsp-ivy counsel lsp-ui company flycheck lsp-julia lsp-mode pyvenv use-package yasnippet cmake-mode magit julia-mode))
 '(scroll-bar-mode nil)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'init)
;;; init.el ends here
