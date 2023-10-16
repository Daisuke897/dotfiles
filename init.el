;;; init.el --- Summary
;;; Commentary:
;;; my init file of Emacs
;;; Code:

(setq inhibit-startup-screen t)

(defvar user-home-directory (file-name-as-directory (getenv "HOME")))

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(eval-when-compile
  (require 'use-package)
  )

(use-package julia-mode
  :mode "\\.jl\\'"
  :interpreter "julia"
  )

(use-package rust-mode
  :mode "\\.rs\\'"
  :interpreter "rust")

(use-package ivy
  :config
  (ivy-mode 1)
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (global-set-key "\C-s" 'swiper)
  (global-set-key (kbd "C-x C-f") 'counsel-find-file)
  (global-set-key (kbd "C-c g") 'counsel-git)
  )

(use-package counsel
  :config
  (counsel-mode 1)
  )

(use-package magit)

(use-package flycheck
  :custom
  (flycheck-gfortran-language-standard "f2018")
  :init (global-flycheck-mode)
  )

(use-package company
  :config
  (global-company-mode)
  )

(use-package yasnippet
  :config
  (yas-global-mode 1)
  )

(use-package pyvenv)

(use-package lsp-mode
  :custom
  (lsp-clients-fortls-executable "apptainer")
  (lsp-clients-fortls-args `("run" ,(concat user-home-directory "dotfiles/images/fortran_language_server.sif")))
  :hook
  (f90-mode . lsp)
  (rust-mode . lsp)
  (julia-mode . lsp)
  (tex-mode . lsp)
  :config
  ;; (add-hook 'lsp-after-open-hook
  ;;        (lambda ()
  ;;          (when (derived-mode-p 'f90-mode)
  ;;            (setq-local flycheck-checker 'fortran-gfortran)))
  ;;        )
  )

(use-package lsp-tex
  :custom
  (lsp-clients-texlab-executable "apptainer")
  :config
  (defcustom lsp-clients-texlab-args `("run" ,(concat user-home-directory "dotfiles/images/latex_language_server.sif"))
    "Extra arguments for the texlab executable"
                           :group 'lsp-tex
                           :risky t
                           :type '(repeat string))
  
  (defun lsp-clients--texlab-command ()
    "Generate the language server startup command."
    `(,lsp-clients-texlab-executable
      ,@lsp-clients-texlab-args)
    )
  
  (lsp-register-client
   (make-lsp-client :new-connection (lsp-stdio-connection 'lsp-clients--texlab-command)
                  :major-modes '(plain-tex-mode latex-mode)
                  :priority (if (eq lsp-tex-server 'texlab) 1 -1)
                  :server-id 'texlab)
   )
  (lsp-consistency-check lsp-tex)
  )

(use-package lsp-julia
  :custom
  (lsp-julia-package-dir "/opt/julia")
  (lsp-julia-command "apptainer")
  (lsp-julia-flags (if lsp-julia-package-dir
                       `("exec"
                         ,(concat user-home-directory "dotfiles/images/julia_language_server.sif")
                         "julia"
                         ,(concat "--project=" lsp-julia-package-dir)
                         "--startup-file=no"
                         "--history-file=no")

                     `("exec"
                       ,(concat user-home-directory "dotfiles/images/julia_language_server.sif")
                       "julia "
                       "--startup-file=no"
                       "--history-file=no"))
                   )
  (lsp-julia-default-environment "~/.julia/environments/v1.9")
  :hook
  (julia-mode . lsp-mode)
  )

;; active Babel languages
(org-babel-do-load-languages
 'org-babel-load-languages
 '((python . t)
   (emacs-lisp . t)))

(column-number-mode 1)

(load-theme 'tango-dark t)

(set-language-environment "UTF-8")

(require 'mozc)
(setq default-input-method "japanese-mozc")
;; "sudo apt install emacs-mozc-bin"

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(rust-mode lsp-ivy counsel lsp-ui company flycheck lsp-julia lsp-mode pyvenv use-package yasnippet cmake-mode magit julia-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'mozc)
(setq default-input-method "japanese-mozc")
;; "sudo apt install emacs-mozc-bin"

(setq-default ispell-program-name "aspell")


(provide 'init)
;;; init.el ends here
