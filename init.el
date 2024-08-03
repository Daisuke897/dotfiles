;;; init.el --- Summary
;;; Commentary:
;;; my init file of Emacs
;;; Code:

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
  :mode
  ("\\.yaml\\'" . yaml-mode)
  ("\\.yml\\'" . yaml-mode)
  :interpreter "yaml")

(use-package js2-mode
  :ensure t
  :mode "\\.js\\'"
  :interpreter "node")

(use-package typescript-mode
  :ensure t
  :mode "\\.ts\\'")

(use-package vue-mode
  :ensure t
  :mode "\\.vue\\'")

(use-package cfn-mode
  :ensure t)

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
  (yaml-mode . lsp)
  (vue-mode . lsp)
  (typescript-mode . lsp)
  (js2-mode . lsp)
  (lsp-cfn-json-mode . lsp)
  :commands lsp
  )

;; macos の環境下で実行する
(when (eq system-type 'darwin)

  ;; Github Copilot
  (use-package copilot
    :straight (:host github :repo "copilot-emacs/copilot.el" :files ("*.el"))
    :ensure t
    :hook
    (prog-mode . copilot-mode)
    :bind (:map copilot-completion-map
                ("<tab>" . 'copilot-accept-completion)
                ("TAB" . 'copilot-accept-completion)
                ("C-TAB" . 'copilot-accept-completion-by-word)
                ("C-<tab>" . 'copilot-accept-completion-by-word))
    )

  (use-package lsp-yaml
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
    (let ((client (gethash 'yamlls lsp-clients)))
      (setf (lsp--client-add-on? client) t))
    )

  (use-package lsp-cfn
    :ensure t
    :custom
    (lsp-cfn-executable (concat user-home-directory
                                "Software/cfn_lsp/bin/cfn-lsp-extra"))
    :init
    (defun lsp-cfn--rls-command ()
      `(,lsp-cfn-executable)
      )
    :magic (("\\({\n *\\)? *[\"']AWSTemplateFormatVersion" . lsp-cfn-json-mode)
            ;; SAM templates are also supported
            ("\\({\n *\\)? *[\"']Transform[\"']: [\"']AWS::Serverless-2016-10-31" . lsp-cfn-json-mode)
            ("\\(---\n\\)?AWSTemplateFormatVersion:" . lsp-cfn-yaml-mode)
            ("\\(---\n\\)?Transform: AWS::Serverless-2016-10-31" . lsp-cfn-yaml-mode))
    :hook
    (lsp-cfn-yaml-mode . (lambda ()
                           (let ((client (gethash 'yamlls lsp-clients)))
                             (when client
                               (when (not (gethash 'yamlls-cfn lsp-clients nil))
                                 (puthash 'yamlls-cfn (copy-lsp--client client) lsp-clients)
                                 (let ((new-client (gethash 'yamlls-cfn lsp-clients nil)))
                                   (setf (lsp--client-server-id new-client) 'yamlls-cfn)
                                   (setf (lsp--client-add-on? new-client) t)
                                   (setf (lsp--client-priority new-client) 0)
                                   (setf (lsp--client-activation-fn new-client) (lsp-activate-on "cloudformation"))
                                   )
                                 )
                               )
                             )
                           (lsp-deferred)
                           )
                       )
    :config
    (let ((client (gethash 'cfn-extra lsp-clients)))
      (setf (lsp--client-new-connection client)
            (lsp-stdio-connection 'lsp-cfn--rls-command))
      (setf (lsp--client-add-on? client) t)
      (setf (lsp--client-priority client) 0))
    )
  )

(when (eq system-type 'gnu/linux)

  (use-package lsp-julia
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
                 "nothing, "
                 "\"" (lsp-julia--symbol-server-store-path-to-jl) "\"); "
                 "run(server);\""))
      )
    (let ((client (gethash 'julia-ls lsp-clients)))
      (setf
       (lsp--client-new-connection client)
       (lsp-stdio-connection 'my-lsp-julia--rls-command)
       )
      )
    )


  (use-package lsp-tex
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
    :custom
    (lsp-rust-analyzer-server-command
     `("apptainer" "run" ,(concat user-home-directory
                                  "dotfiles/images/"
                                  "rust_language_server.sif")))
    )

  (use-package lsp-fortran
    :init
    (setq lsp-clients-fortls-executable "apptainer")
    (setq lsp-clients-fortls-args `("run"
                                    ,(concat user-home-directory
                                             "dotfiles/images/"
                                             "fortran_language_server.sif")))
    )

  )

(use-package reformatter
  :ensure t
  :config
  (reformatter-define ruff-format
    :program (cond ((eq system-type 'gnu/linux) "apptainer")
                   ((eq system-type 'darwin) "~/Software/ruff_lsp/bin/ruff"))
    :args (cond ((eq system-type 'gnu/linux)
                 (list "exec"
                       (concat user-home-directory "dotfiles/images/python_ruff.sif")
                       "/opt/ruff/bin/ruff"
                       "format"
                       "--config"
                       "~/dotfiles/ruff.toml"
                       "--stdin-filename"
                       (or (buffer-file-name) input-file)))
                ((eq system-type 'darwin)
                 (list "format"
                       "--config"
                       "~/dotfiles/ruff.toml"
                       "--stdin-filename"
                       (or (buffer-file-name) input-file))))
    :lighter " RuffFmt"
    :group 'ruff-format)
  (add-hook 'python-mode-hook 'ruff-format-on-save-mode)
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
  (let ((client (gethash 'pyright lsp-clients)))
    (setf (lsp--client-new-connection client)
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
                                      )))
    (setf (lsp--client-add-on? client) t)
    (setf (lsp--client-priority client) -2))
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
