;;; eglot-config-test.el --- ERT tests for eglot config -*- lexical-binding: t; -*-

(require 'ert)

(defconst my/test--repo-root
  (file-name-directory
   (directory-file-name
    (file-name-directory (or load-file-name buffer-file-name)))))

(defun my/test--init-contents ()
  (with-temp-buffer
    (insert-file-contents (expand-file-name "init.el" my/test--repo-root))
    (buffer-string)))

(ert-deftest my/init-uses-eglot ()
  (let ((text (my/test--init-contents)))
    (should (string-match-p "(use-package eglot" text))
    (should (string-match-p "eglot-ensure" text))
    (should-not (string-match-p "(use-package lsp-mode" text))
  ))

(ert-deftest my/init-has-eglot-server-programs ()
  (let ((text (my/test--init-contents)))
    (should (string-match-p "eglot-server-programs" text))
    (should (string-match-p "python-ts-mode \\. my/eglot-python-server" text))
    (should (string-match-p "typescript-ts-mode" text))
    (should (string-match-p "rass" text))
  ))

(ert-deftest my/init-uses-flymake ()
  (let ((text (my/test--init-contents)))
    (should (string-match-p "(use-package flymake" text))
    (should-not (string-match-p "flycheck" text))
    (should (string-match-p "my/cfn-lint-flymake" text))
  ))

(provide 'eglot-config-test)
;;; eglot-config-test.el ends here
