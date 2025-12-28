;;; early-init.el --- Early initialization -*- lexical-binding: t; -*-
;;; Commentary:
;;; Code:

;;; ------------------------------------------------------------
;;; Package initialization
;;; ------------------------------------------------------------

(setq package-enable-at-startup nil)

;;; ------------------------------------------------------------
;;; Garbage collection (startup optimization)
;;; ------------------------------------------------------------

(setq gc-cons-threshold most-positive-fixnum)
(setq gc-cons-percentage 0.6)

;;; ------------------------------------------------------------
;;; UI elements (before frame creation)
;;; ------------------------------------------------------------

(setq menu-bar-mode -1)
(setq tool-bar-mode -1)
(setq scroll-bar-mode -1)
(setq frame-inhibit-implied-resize t)

;;; ------------------------------------------------------------
;;; Native compilation (Emacs 29+)
;;; ------------------------------------------------------------

(setq native-comp-async-report-warnings-errors 'silent)

;;; ------------------------------------------------------------
;;; End of early-init.el
;;; ------------------------------------------------------------
(provide 'early-init)
;;; early-init.el ends here
