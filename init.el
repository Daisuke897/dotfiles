;;; init.el --- Summary
;;; Commentary:
;;; my init file of Emacs
;;; Code:

(setq-default inhibit-startup-screen t)
(setq-default indent-tabs-mode nil)
(setq-default show-trailing-whitespace t)

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
  (lsp-julia-flags `("exec"
                     ,(concat user-home-directory "dotfiles/images/julia_language_server.sif")
                     "julia"
                     ,(concat "--project=" lsp-julia-package-dir)
                     "--startup-file=no"
                     "--history-file=no")
                   )
  (lsp-julia-default-environment "~/.julia/environments/v1.9")
  :init
  (defun lsp-julia--rls-command ()
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
               "run(server);\"")))
  :config
  (lsp-consistency-check lsp-julia)
  )

(use-package lsp-mode
  :custom
  (lsp-clients-fortls-executable "apptainer")
  (lsp-clients-fortls-args `("run" ,(concat user-home-directory "dotfiles/images/fortran_language_server.sif")))
  :hook
  (f90-mode . lsp)
  (rust-mode . lsp)
  (julia-mode . lsp)
  (tex-mode . lsp)
  :commands lsp
  )

(use-package lsp-rust
  :custom
  (lsp-rust-analyzer-server-command
   `("apptainer" "run" ,(concat user-home-directory "dotfiles/images/rust_language_server.sif")))
  )

(use-package ivy-bibtex
  :init
  (setq bibtex-completion-additional-search-fields '(keywords)
	bibtex-completion-display-formats
	'((article       . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${journal:40}")
	  (inbook        . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} Chapter ${chapter:32}")
	  (incollection  . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (inproceedings . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*} ${booktitle:40}")
	  (t             . "${=has-pdf=:1}${=has-note=:1} ${year:4} ${author:36} ${title:*}"))
	bibtex-completion-pdf-open-function
	(lambda (fpath)
	  (call-process "open" nil 0 nil fpath))))

(use-package org-ref
  :ensure nil
  :init
  (require 'bibtex)
  (setq bibtex-autokey-year-length 4
	bibtex-autokey-name-year-separator "-"
	bibtex-autokey-year-title-separator "-"
	bibtex-autokey-titleword-separator "-"
	bibtex-autokey-titlewords 2
	bibtex-autokey-titlewords-stretch 1
	bibtex-autokey-titleword-length 5)
  (define-key bibtex-mode-map (kbd "H-b") 'org-ref-bibtex-hydra/body)
  (define-key org-mode-map (kbd "C-c ]") 'org-ref-insert-link)
  (define-key org-mode-map (kbd "s-[") 'org-ref-insert-link-hydra/body)
  (require 'org-ref-ivy)
  (require 'org-ref-arxiv)
  (require 'org-ref-scopus)
  (require 'org-ref-wos))


(use-package org-ref-ivy
  :ensure nil
  :init (setq org-ref-insert-link-function 'org-ref-insert-link-hydra/body
	      org-ref-insert-cite-function 'org-ref-cite-insert-ivy
	      org-ref-insert-label-function 'org-ref-insert-label-link
	      org-ref-insert-ref-function 'org-ref-insert-ref-link
	      org-ref-cite-onclick-function (lambda (_) (org-ref-citation-hydra/body))))

(use-package org
  :custom
  (org-highlight-latex-and-related '(latex script entities)))

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

(setq-default ispell-program-name "aspell")


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(org-agenda-files nil)
 '(package-selected-packages
   '(ivy-bibtex org-ref rust-mode lsp-ivy counsel lsp-ui company flycheck lsp-julia lsp-mode pyvenv use-package yasnippet cmake-mode magit julia-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'init)
;;; init.el ends here
