;;; init-40-coding-gen.el --- Code for general programming

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 23 Jul 2018

;; Keywords: configuration, company, magit, git, flycheck
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:
;; General tools for programming across languages.  This consists of:
;;   Tools to check out:
;;   Company :: used for code completion
;;   Projectile :: used for searching projects
;;   Magit :: used for interfacing with git/github
;;   Flycheck :: code syntax/convention checking

;;; Code:

(use-package p4
  :ensure t
  :config
  (setq p4-follow-symlinks t))

;; === Code Completion ===

;;; init-40-coding-gen.el ends here
