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
  (when-let ((nix-grammar-path (getenv "TREE_SITTER_GRAMMAR_PATH")))
    (setq treesit-extra-load-path (list nix-grammar-path))
    (message "Tree-sitter grammars loaded from Nix: %s" nix-grammar-path)))

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

(use-package nix-ts-mode
  :ensure t
  :mode
  ("\\.nix\\'" . nix-ts-mode))

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

(use-package vterm
  :ensure t)

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
  (tex-mode . lsp)
  (python-ts-mode . lsp)
  (web-mode . lsp)
  (yaml-ts-mode . lsp)
  (typescript-ts-mode . lsp)
  (markdown-ts-mode . lsp)
  (json-ts-mode . lsp)
  (css-ts-mode . lsp)
  :config
  (push 'semgrep-ls lsp-disabled-clients))

(defun my/lsp-client-override (id &rest overrides)
  "Create a new lsp client based on ID and apply OVERRIDES."
  (let ((base (gethash id lsp-clients)))
    (when base
      (let ((new-client
             (make-lsp--client
              :language-id (lsp--client-language-id base)
              :add-on? (or (plist-get overrides :add-on?)
                           (lsp--client-add-on? base))
              :new-connection (or (plist-get overrides :new-connection)
                                  (lsp--client-new-connection base))
              :ignore-regexps (lsp--client-ignore-regexps base)
              :ignore-messages (lsp--client-ignore-messages base)
              :notification-handlers (lsp--client-notification-handlers base)
              :request-handlers (lsp--client-request-handlers base)
              :response-handlers (lsp--client-response-handlers base)
              :prefix-function (lsp--client-prefix-function base)
              :uri-handlers (lsp--client-uri-handlers base)
              :action-handlers (lsp--client-action-handlers base)
              :action-filter (lsp--client-action-filter base)
              :major-modes (lsp--client-major-modes base)
              :activation-fn (or (plist-get overrides :activation-fn)
                                 (lsp--client-activation-fn base))
              :priority (or (plist-get overrides :priority)
                            (lsp--client-priority base))
              :server-id (lsp--client-server-id base)
              :multi-root (lsp--client-multi-root base)
              :initialization-options
              (or (plist-get overrides :initialization-options)
                  (lsp--client-initialization-options base))
              :semantic-tokens-faces-overrides
              (lsp--client-semantic-tokens-faces-overrides base)
              :custom-capabilities (lsp--client-custom-capabilities base)
              :library-folders-fn (lsp--client-library-folders-fn base)
              :before-file-open-fn (lsp--client-before-file-open-fn base)
              :initialized-fn (lsp--client-initialized-fn base)
              :remote? (lsp--client-remote? base)
              :completion-in-comments? (lsp--client-completion-in-comments? base)
              :path->uri-fn (lsp--client-path->uri-fn base)
              :uri->path-fn (lsp--client-uri->path-fn base)
              :environment-fn (lsp--client-environment-fn base)
              :after-open-fn (lsp--client-after-open-fn base)
              :async-request-handlers (lsp--client-async-request-handlers base)
              :download-server-fn (lsp--client-download-server-fn base)
              :download-in-progress? (lsp--client-download-in-progress? base)
              :buffers (lsp--client-buffers base)
              :synchronize-sections (lsp--client-synchronize-sections base))))
        (puthash id new-client lsp-clients)
        new-client))))

(use-package lsp-yaml
  :custom
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
  (my/lsp-client-override 'yamlls
                          :add-on? t))

(use-package lsp-javascript
  :preface
  ;; Enable the js-ts LSP server when opening Vue.js fileis.
  (defconst my/js-ts-extensions
      '("cjs" "mjs" "js" "jsx" "ts" "tsx" "vue" "astro"))
  (defun my/lsp-typescript-javascript-tsx-jsx-activate-p (filename &optional _)
    "Check if the js-ts lsp server should be enabled based on FILENAME."
    (or (string-match-p
         (concat "\\." (regexp-opt my/js-ts-extensions) "\\'")
         filename)
        (and (derived-mode-p 'js-mode 'js-ts-mode 'typescript-mode 'typescript-ts-mode)
             (not (derived-mode-p 'json-mode)))))
  :custom
  (lsp-clients-typescript-prefer-use-project-ts-server t)
  ;; Disable format for ts-ls.
  (lsp-javascript-format-enable t)
  (lsp-typescript-format-enable t)
  :config
  (remhash 'ts-ls lsp--dependencies)
  (my/lsp-client-override 'ts-ls
                          :new-connection
                            (lsp-stdio-connection
                             (lambda ()
                               (list (expand-file-name "node_modules/.bin/typescript-language-server"
                                                       (lsp-workspace-root))
                                     "--stdio")))
                          :add-on? t
                          :activation-fn #'my/lsp-typescript-javascript-tsx-jsx-activate-p
                          :priority 0))

(use-package lsp-volar
  :custom
  (lsp-volar-hybrid-mode t)
  (lsp-volar-take-over-mode nil)
  :config
  (my/lsp-client-override 'vue-semantic-server
                          :add-on? t
                          :new-connection (lsp-stdio-connection (lambda () '("vue-lsp" "--stdio")))
                          :priority 0))

(use-package lsp-eslint
  :preface
  (defconst my/eslint-extensions
    '("ts" "js" "jsx" "tsx" "html" "vue" "svelte" "astro"))
  (defun my/lsp-eslint-activate-p (filename &optional _)
    (when lsp-eslint-enable
      (or (string-match-p
           (concat "\\." (regexp-opt my/eslint-extensions) "\\'")
           filename)
          (and (derived-mode-p 'js-mode 'js2-mode 'typescript-mode 'typescript-ts-mode 'html-mode 'svelte-mode)
               (not (string-match-p "\\.json\\'" filename))))))
  :custom
  (lsp-eslint-format t)
  :config
  (my/lsp-client-override 'eslint
                          :new-connection
                          (lsp-stdio-connection
                             (lambda ()
                               (list (expand-file-name "node_modules/.bin/vscode-eslint-language-server"
                                                       (lsp-workspace-root))
                                     "--stdio")))
                          :add-on? t
                          :activation-fn #'my/lsp-eslint-activate-p
                          :priority 0))

(use-package lsp-css
  :config
  (my/lsp-client-override 'css-ls
                          :add-on? t
                          :priority 0))

(use-package lsp-astro
  :preface
  (defconst my/astro-extensions
    '("astro"))
  (defun my/lsp-astro-activate-p (filename &optional _)
    "Check if the astro lsp server should be enabled based on FILENAME."
    (string-match-p
     (concat "\\." (regexp-opt my/astro-extensions) "\\'")
     filename))
  :config
  (remhash 'astro-ls lsp--dependencies)
  (my/lsp-client-override 'astro-ls
                          :new-connection (lsp-stdio-connection
                                           (lambda ()
                                                  (list (expand-file-name "node_modules/.bin/astro-ls"
                                                                          (lsp-workspace-root))
                                                        "--stdio")))
                          :add-on? t
                          :activation-fn #'my/lsp-astro-activate-p
                          :priority 0))

(use-package lsp-tex
  :config
  (my/lsp-client-override 'texlab
                          :add-on? t))

(use-package lsp-rust)

(use-package lsp-fortran
  :custom
  (lsp-clients-fortls-args '("--lowercase_intrinsics")))

(use-package lsp-ruff
  :custom
  (lsp-ruff-show-notifications "always")
  :config
  (my/lsp-client-override 'ruff
                          :add-on? t
                          :priority -2
                          :initialization-options
                          (list :settings
                                (list
                                 :configuration (concat user-home-directory "dotfiles/ruff.toml")
                                 :configurationPreference "filesystemFirst"
                                 :logLevel lsp-ruff-log-level
                                 :showNotifications lsp-ruff-show-notifications
                                 :organizeImports (lsp-json-bool lsp-ruff-advertize-organize-imports)
                                 :fixAll (lsp-json-bool lsp-ruff-advertize-fix-all)
                                 :importStrategy lsp-ruff-import-strategy
                                 :lint `(:ignore ,(vector "ANN401" "BLE" "D" "E501" "EM" "PD002" "PD901"
                                                          "PLC01" "PLR09" "PLR2004" "PTH123" "TCH")
                                                 :select ,(vector "ALL"))
                                 :lineLength 320
                                 :format (list :preview (lsp-json-bool t))))))


(use-package lsp-pyright
  :ensure t
  :custom
  (lsp-pyright-diagnostic-mode  "workspace")
  (lsp-pyright-python-executable-cmd "python3")
  (lsp-pyright-auto-import-completions nil)
  (lsp-pyright-type-checking-mode "strict")
  :config
  (my/lsp-client-override 'pyright
                          :add-on? t
                          :priority -2))

(use-package lsp-marksman)

(use-package lsp-json)

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
              lsp-cfn lsp-ivy lsp-mode
              lsp-pyright lsp-ui magit org-ref python-mode pyvenv
              reformatter rust-mode simple-httpd sqlformat
              symbol-overlay typescript-mode use-package web-mode
              yaml-mode yasnippet org-modern mozc markdown-ts-modei))
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
