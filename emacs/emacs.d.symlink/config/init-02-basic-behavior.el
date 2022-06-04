;;; init-02-basic-behavior.el --- Setup some basic behavior

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 22 Jul 2018

;; Keywords: configuration, basic behavior, tramp, customization UI
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:

;; Customization-system (e.g. faces and fonts) are stored in 
;; a customize file (see init-99-customize.el)
;;
;; As much as possible, we do per-package configuration outide the 
;; customize system.

;;; Code:
(require 'use-package)

;; With modern VCS, backup files aren't required.
(setq backup-inhibited 1)

;;
;; Search behavior
;;
;; Let a space in isearch match one or more whitepsace characters:
(setq isearch-lax-whitespace +1)
(setq isearch-regexp-lax-whitespace +1)
;; Make searches case insensitive
(setq-default case-fold-search +1)
;; Use regex searches & replacing by default.
(global-set-key (kbd "C-s") 'isearch-forward-regexp)
(global-set-key (kbd "\C-r") 'isearch-backward-regexp)
(global-set-key (kbd "C-M-s") 'isearch-forward)
(global-set-key (kbd "C-M-r") 'isearch-backward)
;; Default to regexp replacing.
(global-set-key "\M-%" 'query-replace-regexp)


;; Tramp mode configuration
;; TRAMP stands for "Transparent Remote (file) Access, Multiple Protocol". It is
;; really, really beautiful.
(require 'tramp)
(setq tramp-default-user "putsch")
; default to ssh
(setq tramp-default-method "ssh")
; use "plink" when on windows
(jdp/on-windows
 (setq tramp-default-method "plinkx"))

;; I often need to sudo before editing remote files, add some generic support
;; for that:
(add-to-list 'tramp-default-proxies-alist
             '(nil "\\`sepp\\'" "/-:%h:"))
(add-to-list 'tramp-default-proxies-alist
             '(nil "\\`jira\\'" "/-:%h:"))
(add-to-list 'tramp-default-proxies-alist
             '(nil "\\`tekcad\\'" "/-:%h:"))
(add-to-list 'tramp-default-proxies-alist
             '(nil "\\`root\\'" "/-:%h:"))
(add-to-list 'tramp-default-proxies-alist
             '((regexp-quote (system-name)) nil nil))

;; Add post-init hook to start server if not already running
(use-package server
  :hook (after-init . jdp/server-start-hook))

;;; init-02-basic-behavior.el ends here
