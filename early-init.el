;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; ------------------------------------------------------------
;;; Package initialization
;;; ------------------------------------------------------------

(custom-set-variables
 '(package-enable-at-startup nil))

;;; ------------------------------------------------------------
;;; Garbage collection (startup optimization)
;;; ------------------------------------------------------------

(custom-set-variables
 '(gc-cons-threshold most-positive-fixnum)
 '(gc-cons-percentage 0.6))

;;; ------------------------------------------------------------
;;; UI elements (before frame creation)
;;; ------------------------------------------------------------

(custom-set-variables
 '(menu-bar-mode -1)
 '(tool-bar-mode -1)
 '(scroll-bar-mode -1)
 '(frame-inhibit-implied-resize t))

;;; ------------------------------------------------------------
;;; Native compilation (Emacs 29+)
;;; ------------------------------------------------------------

(custom-set-variables
 '(native-comp-async-report-warnings-errors 'silent))

;;; ------------------------------------------------------------
;;; End of early-init.el
;;; ------------------------------------------------------------
(provide 'early-init)
;;; early-init.el ends here
