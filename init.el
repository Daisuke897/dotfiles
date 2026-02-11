;;; init.el --- Summary
;;; Commentary:
;;; my init file of Emacs
;;; Code:

(add-hook 'find-file-hook (lambda () (setq buffer-read-only t)))

(global-display-line-numbers-mode 1)

(setq read-process-output-max (* 1024 1024))

(setq-default delete-trailing-lines t)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(column-number-mode 1)

(set-language-environment "UTF-8")

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(eval-when-compile
  (require 'use-package))

;; MacOS
(when (eq system-type 'darwin)
  (set-face-attribute 'default nil :height 160)
  (set-frame-parameter nil 'alpha 85))

;; Clipboard integration (macOS / WSL)
(defun my/send-to-clipboard (text)
  "Send TEXT to the OS clipboard using the appropriate backend."
  (cond
   ;; macOS
   ((eq system-type 'darwin)
    (with-temp-buffer
      (insert text)
      (call-process-region (point-min) (point-max)
                           "pbcopy" nil nil nil)))
   ;; WSL (TUI only)
   ((and (not (display-graphic-p))
         (executable-find "clip.exe"))
    (let* ((lf-text (replace-regexp-in-string "\r\n" "\n" text))
           (utf16-text (encode-coding-string lf-text 'utf-16-le)))
      (with-temp-buffer
        (set-buffer-multibyte nil)
        (insert utf16-text)
        (call-process-region (point-min) (point-max)
                             "clip.exe" nil nil nil))))))

;; Always sync kill-ring → OS clipboard
(advice-add 'kill-new :after (lambda (text &rest _args) (my/send-to-clipboard text)))

;; Tab
(tab-bar-mode)                          ; per project, workspace

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

;; Treesit
(use-package treesit
  :ensure nil
  :custom
  (treesit-font-lock-level 4)
  :config
  (when-let ((nix-grammar-path (getenv "TREE_SITTER_GRAMMAR_PATH")))
    (setq treesit-extra-load-path (list nix-grammar-path))))

;; Mode
(use-package rust-ts-mode
  :ensure t
  :mode "\\.rs\\'")

(use-package python-ts-mode
  :ensure nil
  :mode "\\.py\\'"
  :functions (eglot-managed-p eglot-format-buffer eglot-format eglot-code-actions)
  :preface
  (defun my/python-mode-setup ()
    (add-hook 'before-save-hook
              (lambda ()
                (when (and (eq major-mode 'python-ts-mode)
                           (eglot-managed-p))
                  (cond
                   ((fboundp 'eglot-format-buffer)
                    (eglot-format-buffer))
                   ((fboundp 'eglot-format)
                    (eglot-format)))
                  (when (fboundp 'eglot-code-actions)
                    (eglot-code-actions nil nil "source.organizeImports"))))
              nil t))
  :hook
  (python-ts-mode . my/python-mode-setup))

(use-package yaml-ts-mode
  :ensure t
  :mode
  ("\\.yaml\\'" . yaml-ts-mode)
  ("\\.yml\\'" . yaml-ts-mode))

(use-package bash-ts-mode
  :ensure nil
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
  :ensure nil
  :mode
  ("\\.json\\'" . json-ts-mode))

(use-package css-ts-mode
  :ensure nil
  :mode
  ("\\.css\\'" . css-ts-mode))

(use-package go-ts-mode
  :ensure nil
  :mode
  ("\\.go\\'" . go-ts-mode))

(use-package go-mod-ts-mode
  :ensure nil
  :mode
  ("go\\.mod\\'" . go-mod-ts-mode))

(use-package toml-ts-mode
  :ensure nil
  :mode
  ("\\.toml\\'" . toml-ts-mode))

(use-package dockerfile-mode
  :ensure t
  :mode
  ("Dockerfile\'" . dockerfile-mode)
  ("\\.dockerfile\\'" . dockerfile-mode))

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

;; Tool
(use-package vterm
  :ensure t)

(use-package eat
  :straight
  (eat :type git
       :host codeberg
       :repo "akib/emacs-eat"
       :files ("*.el" ("term" "term/*.el") "*.texi"
               "*.ti" ("terminfo/e" "terminfo/e/*")
               ("terminfo/65" "terminfo/65/*")
               ("integration" "integration/*")
               (:exclude ".dir-locals.el" "*-tests.el")))
  :config
  (add-hook 'eshell-first-time-mode-hook #'eat-eshell-mode))

(use-package consult
  :ensure t
  :bind
  (("C-x b" . consult-buffer)
   ("C-s"   . consult-line))
  :commands (consult-line consult-buffer))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides
   '((file (styles basic partial-completion))))
  :config
  (setq orderless-matching-styles
        '(orderless-literal
          orderless-prefixes
          orderless-regexp)))

(use-package vertico
  :ensure t
  :after (orderless)
  :init
  (vertico-mode)
  :custom
  (vertico-cycle t))

(use-package marginalia
  :ensure t
  :after (vertico)
  :init
  (marginalia-mode)
  :config
  (setq marginalia-align 'right))

(use-package which-key
  :ensure t
  :init
  (which-key-mode)
  :custom
  (which-key-idle-delay 1.0))

(use-package magit
  :ensure t
  :commands (magit-status magit-blame))

(use-package flymake
  :ensure nil)

(use-package yasnippet
  :ensure t
  :config
  (yas-global-mode 1))

(use-package cfn-mode
  :ensure t
  :preface
  (defvar-local my/cfn-lint--proc nil)
  (defun my/cfn-lint-flymake (report-fn &rest _args)
    (unless (executable-find "cfn-lint")
      (error "Cannot find cfn-lint"))
    (when (process-live-p my/cfn-lint--proc)
      (kill-process my/cfn-lint--proc))
    (let* ((source (current-buffer))
           (extension (file-name-extension (or (buffer-file-name source) "")))
           (temp-file (make-temp-file "flymake-cfn-" nil
                                      (and extension (concat "." extension)))))
      (save-restriction
        (widen)
        (write-region nil nil temp-file nil 0))
      (setq my/cfn-lint--proc
            (make-process
             :name "cfn-lint-flymake"
             :noquery t
             :connection-type 'pipe
             :buffer (generate-new-buffer " *cfn-lint-flymake*")
             :command (list "cfn-lint" "-f" "parseable" temp-file)
             :sentinel
             (lambda (proc _event)
               (when (memq (process-status proc) '(exit signal))
                 (unwind-protect
                     (if (with-current-buffer source (eq proc my/cfn-lint--proc))
                         (with-current-buffer (process-buffer proc)
                           (goto-char (point-min))
                           (let (diags)
                             (while (re-search-forward
                                     "^\\([^:]+\\):\\([0-9]+\\):\\([0-9]+\\):\\([^:]+\\):\\([^:]+\\):\\(.*\\)$"
                                     nil t)
                               (let* ((lnum (string-to-number (match-string 2)))
                                      (col (string-to-number (match-string 3)))
                                      (level (match-string 4))
                                      (msg (match-string 6))
                                      (pos (flymake-diag-region source lnum col))
                                      (type (pcase level
                                              ("warning" :warning)
                                              ("info" :note)
                                              (_ :error))))
                                 (push (flymake-make-diagnostic
                                        source (car pos) (cdr pos) type msg)
                                       diags)))
                             (funcall report-fn diags)))
                       (flymake-log :warning "Canceling obsolete check %s" proc))
                   (when (buffer-live-p (process-buffer proc))
                     (kill-buffer (process-buffer proc)))
                   (when (file-exists-p temp-file)
                     (delete-file temp-file)))))))))
  (defun my-cfn-mode-setup ()
    (add-hook 'flymake-diagnostic-functions #'my/cfn-lint-flymake nil t)
    (eglot-ensure))
  :hook
  (cfn-mode . my-cfn-mode-setup))

(use-package dired-subtree
  :ensure t
  :bind (:map dired-mode-map
              ("i" . dired-subtree-insert)
              (";" . dired-subtree-remove)
              ("<tab>" . 'dired-subtree-toggle)))

(use-package dired-sidebar
  :bind (("C-x C-n" . dired-sidebar-toggle-sidebar))
  :ensure t
  :commands (dired-sidebar-toggle-sidebar)
  :hook
  (dired-sidebar-mode . auto-revert-mode)
  :custom
  (dired-sidebar-use-term-integration t)
  (dired-sidebar-theme 'nerd-icons))

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :custom
  (corfu-auto nil)
  (corfu-cycle t)
  (corfu-preselect 'prompt)
  (corfu-quit-no-match 'separator))

(use-package corfu-terminal
  :ensure t
  :if (not (display-graphic-p))
  :init (corfu-terminal-mode))

(use-package cape
  :ensure t
  :bind ("C-c p" . cape-prefix-map)
  :init
  (add-to-list 'completion-at-point-functions #'cape-dabbrev)
  (add-to-list 'completion-at-point-functions #'cape-file)
  (add-to-list 'completion-at-point-functions #'cape-keyword))

(use-package embark
  :ensure t
  :commands (embark-act embark-dwim embark-bindings)
  :bind
  (("C-c e" . embark-act)
   ("C-c d" . embark-dwim)
   ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :ensure t
  :after (embark consult)
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

(use-package gcmh
  :ensure t
  :init (gcmh-mode 1))

;; Lsp
(use-package eglot
  :ensure nil
  :demand t
  :preface
  (defconst my/eglot-yaml-custom-tags
    ["!And"
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
     "!Split sequence"])
  (defconst my/eglot-workspace-configuration
    `((:yaml . (:customTags ,my/eglot-yaml-custom-tags))
      (:ty . (:diagnosticMode "workspace"))
      (:ruff . (:configuration ,(expand-file-name "~/dotfiles/ruff.toml")
                :configurationPreference "filesystemFirst"
                :format (:preview t)))
      (:eslint . (:format (:enable t)))))
  (when (boundp 'project-vc-extra-root-markers)
    (add-to-list 'project-vc-extra-root-markers "pyproject.toml"))
  (defun my/eglot-project-root ()
    (or (when-let ((project (project-current nil)))
          (project-root project))
        (locate-dominating-file default-directory ".git")
        default-directory))
  (defun my/eglot-node-bin (bin)
    (let* ((root (my/eglot-project-root))
           (local (and root (expand-file-name (concat "node_modules/.bin/" bin) root))))
      (if (and local (file-executable-p local)) local bin)))
  (defun my/eglot-rass (&rest servers)
    (cons "rass"
          (apply #'append
                 (mapcar (lambda (server)
                           (append '("--") server))
                         servers))))
  (defun my/eglot-typescript-server ()
    (let* ((root (my/eglot-project-root))
           (tsserver (and root (expand-file-name "node_modules/typescript/lib/tsserver.js" root)))
           (cmd (list (my/eglot-node-bin "typescript-language-server") "--stdio")))
      (if (and tsserver (file-exists-p tsserver))
          (append cmd (list "--tsserver-path" tsserver))
        cmd)))
  (defun my/eglot-eslint-server ()
    (list (my/eglot-node-bin "vscode-eslint-language-server") "--stdio"))
  (defun my/eglot-vue-server ()
    (list (my/eglot-node-bin "vue-language-server") "--stdio"))
  (defun my/eglot-astro-server ()
    (list (my/eglot-node-bin "astro-ls") "--stdio"))
  (defun my/eglot-yaml-server (&rest _args)
    (list (my/eglot-node-bin "yaml-language-server") "--stdio"))
  (defun my/eglot-json-server (&rest _args)
    (list (my/eglot-node-bin "vscode-json-language-server") "--stdio"))
  (defun my/eglot-css-server (&rest _args)
    (list (my/eglot-node-bin "vscode-css-language-server") "--stdio"))
  (defun my/eglot-dockerfile-server (&rest _args)
    (list (my/eglot-node-bin "docker-langserver") "--stdio"))
  (defun my/eglot-toml-server (&rest _args)
    (list "taplo" "lsp" "stdio"))
  (defun my/eglot-marksman-server (&rest _args)
    (list "marksman" "server"))
  (defun my/eglot-texlab-server (&rest _args)
    (list "texlab"))
  (defun my/eglot-rust-server (&rest _args)
    (list "rust-analyzer"))
  (defun my/eglot-fortran-server (&rest _args)
    (list "fortls" "--lowercase_intrinsics"))
  (defun my/eglot-ruff-server ()
    (list "ruff" "server"))
  (defun my/eglot-ty-server ()
    (list "ty" "server"))
  (defun my/eglot-python-server (&rest _args)
    (my/eglot-rass
     (my/eglot-ty-server)
     (my/eglot-ruff-server)))
  (defun my/eglot-typescript-rass (&rest _args)
    (my/eglot-rass
     (my/eglot-typescript-server)
     (my/eglot-eslint-server)))
  (defun my/eglot-web-mode-server (&rest _args)
    (let ((ext (file-name-extension (or buffer-file-name ""))))
      (cond
       ((equal ext "vue")
        (my/eglot-rass
         (my/eglot-vue-server)
         (my/eglot-typescript-server)
         (my/eglot-eslint-server)))
       ((equal ext "astro")
        (my/eglot-rass
         (my/eglot-astro-server)
         (my/eglot-typescript-server)
         (my/eglot-eslint-server)))
       (t (my/eglot-typescript-rass)))))
  :init
  (setq eglot-workspace-configuration my/eglot-workspace-configuration)
  :hook
  ((f90-mode . eglot-ensure)
   (rust-ts-mode . eglot-ensure)
   (tex-mode . eglot-ensure)
   (python-ts-mode . eglot-ensure)
   (web-mode . eglot-ensure)
   (yaml-ts-mode . eglot-ensure)
   (toml-ts-mode . eglot-ensure)
   (dockerfile-mode . eglot-ensure)
   (typescript-ts-mode . eglot-ensure)
   (tsx-ts-mode . eglot-ensure)
   (markdown-ts-mode . eglot-ensure)
   (json-ts-mode . eglot-ensure)
   (css-ts-mode . eglot-ensure))
  :config
  (dolist (entry
           '((python-ts-mode . my/eglot-python-server)
             ((typescript-ts-mode tsx-ts-mode) . my/eglot-typescript-rass)
             (web-mode . my/eglot-web-mode-server)
             ((yaml-ts-mode cfn-mode) . my/eglot-yaml-server)
             (toml-ts-mode . my/eglot-toml-server)
             (dockerfile-mode . my/eglot-dockerfile-server)
             (markdown-ts-mode . my/eglot-marksman-server)
             (json-ts-mode . my/eglot-json-server)
             (css-ts-mode . my/eglot-css-server)
             (tex-mode . my/eglot-texlab-server)
             (rust-ts-mode . my/eglot-rust-server)
             (f90-mode . my/eglot-fortran-server)))
    (add-to-list 'eglot-server-programs entry)))

;; Org
(use-package org
  :ensure nil
  :custom
  (org-highlight-latex-and-related '(latex script entities))
  :config
  ;; Active Babel languages
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t)
     (emacs-lisp . t))))

(use-package org-modern
  :ensure t
  :hook
  (org-mode . org-modern-mode)
  (org-agenda-finalize . org-modern-agenda))

;; Formatter
(use-package sqlformat
  :ensure t
  :custom
  (sqlformat-command 'sql-formatter))

;; Mozc
(use-package mozc
  :ensure t
  :if (eq system-type 'gnu/linux)
  :config
  ;; "sudo apt install emacs-mozc-bin"
  (setq default-input-method "japanese-mozc"))

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auth-source-save-behavior nil)
 '(custom-enabled-themes '(modus-vivendi))
 '(gc-cons-threshold 100000000)
 '(indent-tabs-mode nil)
 '(inhibit-startup-screen t)
 '(make-backup-files nil)
 '(org-agenda-files nil)
 '(require-final-newline t)
 '(show-trailing-whitespace t))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 16 1024 1024)
                  gc-cons-percentage 0.1)))

(provide 'init)
;;; init.el ends here
