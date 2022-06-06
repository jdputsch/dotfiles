;;; init-99-customize.el --- Manage customizations

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 15 Nov 2018

;; Keywords: customization UI
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:

;; Configure customization interaface here. We load this last to
;; mimic Emacs' native behavior: customization code is, by default,
;; stored at the end of the init.el file.
;;
;; We store this in a per-version file, and load it last.

;;; Code:

(cond 
 ((< emacs-major-version 22)
  (setq custom-file (jdp/joindirs user-emacs-directory "customize-21.el")))
 ((and (= emacs-major-version 22) (< emacs-minor-version 3))
    ;; Emacs 22 customization, before version 22.3.
  (setq custom-file (jdp/joindirs user-emacs-directory "customize-22.el")))
 (t ;; Default, Emacs >= 22.3
  (cond
   ((jdp/on-osx t)
    (setq custom-file (jdp/joindirs user-emacs-directory "customize-osx.el")))
   ((jdp/on-wsl t)
    (setq custom-file (jdp/joindirs user-emacs-directory "customize-wsl.el")))
   ((jdp/on-gnu/linux t)
    (setq custom-file (jdp/joindirs user-emacs-directory "customize-linux.el")))
   (t
    (setq custom-file (jdp/joindirs user-emacs-directory "customize.el"))))))

(load custom-file)

;;; init-99-customize.el ends here
