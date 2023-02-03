(setq-default indent-tabs-mode nil)
(setq-default tab-width 4)

(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(unless (package-installed-p 'julia-mode)
  (package-install 'julia-mode)
  )
(require 'julia-mode)

(unless (package-installed-p 'magit)
  (package-install 'magit)
  )
(require 'magit)

(column-number-mode 1)

(load-theme 'tango-dark t)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages '(cmake-mode magit julia-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(require 'mozc)
(setq default-input-method "japanese-mozc")
;; "sudo apt install emacs-mozc-bin"
