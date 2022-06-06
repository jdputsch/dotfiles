;;; init-01-jdp-functions.el --- My helper functions

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 14 Aug 2018

;; Keywords: helper functions 
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:

;;; Code:

;; Function that acts like python's os.path.join:
(defun jdp/joindirs (root &rest dirs)
  "Joins a series of directories together, like Python's os.path.join,
  (dotemacs-joindir \"/tmp\" \"a\" \"b\" \"c\") => /tmp/a/b/c"

  (if (not dirs)
      root
    (apply 'jdp/joindirs
           (expand-file-name (car dirs) root)
           (cdr dirs))))

;; Simple functions to detect/use for platform specific choices
;;
(defmacro jdp/on-gnu/linux (statement &rest statements)
  "Evaluate the enclosed body only when run on GNU/Linux."
  `(when (eq system-type 'gnu/linux)
     ,statement
     ,@statements))

(defmacro jdp/on-osx (statement &rest statements)
  "Evaluate the enclosed body only when run on OSX."
  `(when (eq system-type 'darwin)
     ,statement
     ,@statements))

(defmacro jdp/on-gnu/linux-or-osx (statement &rest statements)
  "Evaluate the enclosed body only when run on GNU/Linux or OSX."
  `(when (or (eq system-type 'gnu/linux)
            (eq system-type 'darwin))
     ,statement
     ,@statements))

(defmacro jdp/on-wsl (statement &rest statements)
  "Evaluate the enclosed body only when run on Linux Subystem for Windows."
  `(when (and (eq system-type 'gnu/linux)
              (string-match "Microsoft"
                (with-temp-buffer (shell-command "uname -r" t)
                                  (goto-char (point-max))
                                  (delete-char -1)
                                  (buffer-string))))
     ,statement
     ,@statements))

(defmacro jdp/on-windows (statement &rest statements)
  "Evaluate the enclosed body only when run on Microsoft Windows."
  `(when (eq system-type 'windows-nt)
     ,statement
     ,@statements))

(defmacro jdp/on-gui (statement &rest statements)
  "Evaluate the enclosed body only when run on GUI."
  `(when (display-graphic-p)
     ,statement
     ,@statements))

(defmacro jdp/not-on-gui (statement &rest statements)
  "Evaluate the enclosed body only when run on GUI."
  `(when (not (display-graphic-p))
     ,statement
     ,@statements))

;;
(defun jdp/untabify-buffer ()
  "For untabifying the entire buffer."
  (interactive)
  (untabify (point-min) (point-max)))

(defun jdp/untabify-buffer-hook ()
  "Adds a buffer-local untabify on save hook."
  (interactive)
  (add-hook
   'after-save-hook
   (lambda () (jdp/untabify-buffer))
   nil
   'true))

;; simple hook to start the emacs server if not already running
(defun jdp/server-start-hook ()
  (require 'server)
  (unless (server-running-p)
    (server-start)))

;; init-01-jdp-functions.el ends here
