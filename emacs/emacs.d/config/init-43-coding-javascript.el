;;; init-43-coding-javascript.el --- Code for general programming

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 30 Mar 2019

;; Keywords: configuration, javascript (CDS javascript-like language)
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:
;; Simply load js-mode.el if it is available in ~/.emacs.d
;; Basic js-mode configuration

;;; Code
(require 'use-package)

;; js-mode for JSON files...
(add-to-list 'auto-mode-alist '("\\.json$" . js-mode))

(setq-default js-indent-level 2)
(setq-default js-indent-align-list-continuation nil)

;; js2-mode for JavaScript files...
;; (use-package js2-mode
;;   :ensure t
;;   :init
;;   (setq js-basic-indent 2)
;;   (setq-default js2-basic-indent 2
;;                 js2-basic-offset 2
;;                 js2-auto-indent-p t
;;                 js2-cleanup-whitespace t
;;                 js2-enter-indents-newline t
;;                 js2-indent-on-enter-key t)
;;   (add-to-list 'auto-mode-alist '("\\.js$" . js2-mode)))


;;; init-43-coding-javascript.el ends here


