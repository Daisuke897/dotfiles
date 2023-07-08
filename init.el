;;; init.el --- Summary
;;; Commentary:
;;; my init file of Emacs
;;; Code:

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

(use-package pyvenv
  :custom
  (pyvenv-activate "~/software/fortls/")
  :hook
  (f90-mode . pyvenv-mode)
  )

(use-package lsp-mode
  :custom
  (lsp-clients-fortls-executable "~/software/fortls/bin/fortls")
  (lsp-clients-fortls-args '("--hover_signature" "--lowercase_intrinsics"))
  :hook
  (f90-mode . lsp)
  (rust-mode . lsp)
  (julia-mode . lsp-deferred)
  :config
  (add-hook 'lsp-after-open-hook
	    (lambda ()
	      (when (derived-mode-p 'f90-mode)
		(setq-local flycheck-checker 'fortran-gfortran)))
	    )
  )

(use-package lsp-julia
  :custom
  (lsp-julia-package-dir "/opt/julia")
  (lsp-julia-command "apptainer")
  (lsp-julia-flags (if lsp-julia-package-dir
                       `("exec"
			 "/home/daisuke/sif/julia/language_server/julia_language_server.dif"
			 "julia"
			 ,(concat "--project=" lsp-julia-package-dir)
			 "--startup-file=no"
                         "--history-file=no")

		     '("exec"
		       "~/sif/julia/language_server/julia_language_server.dif"
		       "julia "
		       "--startup-file=no"
		       "--history-file=no"))
		   )
  (lsp-julia-default-environment "~/.julia/environments/v1.9")
  :hook
  (julia-mode . lsp-mode)
  ;; :config
  ;; (defun lsp-julia--rls-command ()
  ;; "The command to lauch the Julia Language Server."
  ;; `(,lsp-julia-command
  ;;   ,@lsp-julia-flags
  ;;   ,(concat "-e"
  ;;            "'import Pkg; Pkg.instantiate(); "
  ;;            "using LanguageServer, LanguageServer.SymbolServer;"
  ;;            ;; " Union{Int64, String}(x::String) = x; "
  ;;            " server = LanguageServer.LanguageServerInstance("
  ;;            " stdin, stdout,"
  ;;            (lsp-julia--get-root) ","
  ;;            (lsp-julia--get-depot-path) ","
  ;;            " nothing, "
  ;;            (lsp-julia--symbol-server-store-path-to-jl) ");"
  ;;            " run(server);'")))
  )


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
   '(lsp-ivy counsel lsp-ui company flycheck lsp-julia lsp-mode pyvenv use-package yasnippet cmake-mode magit julia-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(provide 'init)
;;; init.el ends here
