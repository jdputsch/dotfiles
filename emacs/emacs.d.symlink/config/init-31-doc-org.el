;;; init-31-doc-org.el --- Code for initializing org-mode

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 28 Jul 2018

;; Keywords: configuration, org
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:
;; Runs org-mode along with some custom configuration files
;;
;; More information can be found at:
;;    https://orgmode.org
;;    http://doc.norang.ca/org-mode.html

;;; Code:
(require 'use-package)

;; == Org ==
(use-package org
  :ensure org-plus-contrib
  :pin org)

;;; init-31-doc-org.el ends here
