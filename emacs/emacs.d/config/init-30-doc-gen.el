;;; init-30-doc-gen.el --- Code for general document editing

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 28 Jul 2018

;; Keywords: configuration, markdown, tex, latex, auctex
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:
;; Use either org or markdown by default in text buffers.
;; 2018-07-28 -- Markdown by default for now

;;; Code:
(require 'use-package)

;; == Markdown ==
;; My WSL install has OpenSUSE Leap 42.3, which has Emacs 24.3
;; until that is updated we have to pull markdown from git using el-get
;; 
(use-package markdown-mode
  :ensure t
  :defer t
  :mode (("\\.text\\'" . markdown-mode)
	 ("\\.markdown\\'" . markdown-mode)
	 ("\\.md\\'" . markdown-mode)))

(use-package flyspell
  :defer t
  :diminish (flyspell-mode . " φ"))

;; == LaTex / AucTeX ==
;; TODO:

;;; init-20-text-modes.el ends here
