;;; init-40-coding-lisp.el --- Code for general programming

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 23 Jul 2018

;; Keywords: configuration, lisp (CDS lisp-like language)
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:
;; Simply load lisp-mode.el if it is available in ~/.emacs.d

;;; Code
(setq auto-mode-alist
  (append '(
            ("\\.emacs$" . lisp-mode)
            ("\\.lisp$" . lisp-mode)
            ("\\.cl$" . lisp-mode)
            ("\\.il$" . lisp-mode)
            ("\\.ils$" . scheme-mode)
            ("\\.ocn$" . lisp-mode)
            ("\\.cdf$" . lisp-mode)
            ("\\.system$" . lisp-mode)
            ("\\.scm$" . scheme-mode)
            ("\\.ss$" . scheme-mode)
            ("\\.sch$" . scheme-mode)
           ) auto-mode-alist))

(defun jdp/lisp-mode-hook ()
  "Helpful behavior for Lisp (and related languages) buffers."
  ; (turn-on-smartparens-strict-mode)
  (jdp/untabify-buffer)
  (hs-minor-mode 1))

(use-package lisp-mode
  :commands lisp-mode
  :ensure nil
  :hook jdp/lisp-mode-hook)

(use-package emacs-lisp-mode
  :commands emacs-lisp-mode
  :ensure nil
  :hook jdp/lisp-mode-hook)

(use-package scheme-lisp-mode
  :commands scheme-lisp-mode
  :ensure nil
  :hook jdp/lisp-mode-hook)



;; === Load lisp-mode.el ===
; (load-library "lisp-mode.el")
; 
; (setq auto-mode-alist
;       (append '(
; 		("\\.il$" . lisp-mode)
; 		("\\.ils$" . lisp-mode)
; 		("\\.ocn$" . lisp-mode)
; 		("\\.cdf$" . lisp-mode))))

;;; init-40-coding-lisp.el ends here


