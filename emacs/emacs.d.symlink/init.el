;;; init.el --- Initialization code for emacs

;; Copyright (c) 2018 Jeff Putch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 22 Jul 2018

;; Keywords: configuration

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License as
;; published by the Free Software Foundation; either version 2 of
;; the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be
;; useful, but WITHOUT ANY WARRANTY; without even the implied
;; warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
;; PURPOSE.  See the GNU General Public License for more details.

;;; Commentary:
;; Calls my Emacs configuration files after installing use-package, which is
;; necessary for operation.  See also:
;;      http://www.cachestocaches.com/2015/8/getting-started-use-package/
;;
;; Code inspired by:
;;      https://github.com/gjstein/emacs.d
;;      https://swsnr.de/blog/2015/01/06/my-emacs-configuration-with-use-package/
;;      

;;; Code:

;; Check that emacs is new enough:
(if (version< emacs-version "24.4")
    (error
     "Incorrect Emacs runtime: v%s.%s. Version >= 24.4 required."
     (number-to-string emacs-major-version)
     (number-to-string emacs-minor-version)))

;; User Info
(setq user-full-name "jeff Putsch")
(setq user-mail-address "jdputsch@gmail.com")

;; Install use-package if necessary
(require 'package)
(setq package-enable-at-startup nil)
(setq package-archives
      (remove '("gnu" . "http://elpa.gnu.org/packages/")
              package-archives))
(add-to-list 'package-archives
             '("gnu" . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives
             '("melpa" . "https://melpa.org/packages/") t)
(add-to-list 'package-archives
             '("org" . "https://orgmode.org/elpa/") t)
(add-to-list 'package-archives
			 '("marmalade" . "https://marmalade-repo.org/packages/") t)
(add-to-list 'package-archives
			 '("elpy" . "http://jorgenschaefer.github.io/packages/") t)
(package-initialize)

;; Bootstrap `use-package'
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package)) 

;; Enable use-package
(eval-when-compile
  (require 'use-package))

;; Setup a couple of key packages

(use-package diminish
  :ensure t)

(require 'bind-key) ;; if you use any :bind variant

;; Increase garbage collection threshold to 500 MB to ease startup
;; (Don't do this for now!  It was causing my agenda mode to crawl)
;; (setq gc-cons-threshold (* 500 1024 1024))

;; On MacOS/Darwin Set the path variable
(if (eq system-type "darwin")
  (use-package exec-path-from-shell
    :ensure t
    :config (exec-path-from-shell-initialize)))

;; Add my "modes" directory to the load path
(add-to-list 'load-path (expand-file-name "modes" user-emacs-directory))

;; Add el-get so we can use it later when we can only get packages working
;; from sources like git:
;; (use-package el-get :ensure t)

;; common/helper functions
(load-file "~/.emacs.d/config/init-01-jdp-functions.el")

;; Basic behaviors
(load-file "~/.emacs.d/config/init-02-basic-behavior.el")

;; === Face Customization ===
(load-file "~/.emacs.d/config/init-10-face.el")

;; === Interface ===
(load-file "~/.emacs.d/config/init-20-nav-interface.el")

;; === Document Editing ===
(load-file "~/.emacs.d/config/init-30-doc-gen.el")
(load-file "~/.emacs.d/config/init-31-doc-org.el")

;; === JIRA Interface -- in org mode ===
(load-file "~/.emacs.d/config/init-21-jira.el")

;; === Programming/Development Environment ===
(load-file "~/.emacs.d/config/init-40-coding-gen.el")
(load-file "~/.emacs.d/config/init-41-coding-lisp.el")
;; (load-file "~/.emacs.d/config/init-42-coding-skill.el")
(load-file "~/.emacs.d/config/init-43-coding-javascript.el")
;; === Miscellaneous ===
(load-file "~/.emacs.d/config/init-90-misc.el")

;; === Customization System ===
(load-file "~/.emacs.d/config/init-99-customize.el")
