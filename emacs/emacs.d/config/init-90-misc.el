;;; init-90-misc.el --- Miscelaneous emacs packages
;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 28 Jul 2018

;; Keywords: configuration, uuid, world-time-mode
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:
;; 2018-07-28 -- placeholder file. Do I want helm, ido, or what?

;;; Code:
(require 'use-package)

;; UUID
(use-package uuid
  :ensure t)

;; World Time Mode
(use-package world-time-mode
  :ensure t)


;;; init-90-misc.el ends here
