;;; init-10-face.el --- Customize the look of emacs

;; Copyright (C) 2018 Jeff Putsch

;; Author: Jeff Putsch <jdputsch@gmail.com>
;; Maintainer: Jeff Putsch <jdputsch@gmail.com>
;; Created: 22 Jul 2018

;; Keywords: configuration, solarized
;; Homepage: 
;; License: GNU General Public License (see init.el for details)

;;; Commentary:
;; Solarized theme; default font is set to 'Source Code Pro'

;;; Code:
(require 'use-package)

;; Splash Screen to markdown-mode
(setq inhibit-splash-screen t
      initial-scratch-message nil
      initial-major-mode 'markdown-mode)

;; Default font specified via customize interface...

; Set default fill column
(setq-default fill-column 80)

;; Don't use audible bells, use visual bells
(setq visible-bell +1)
(setq ring-bell-function 'ignore)

;; Scroll bars, tool bars, menu bars:
;; scroll bars are not colorized and I don't use the, turn them off.
;; I don't like the tool bars, therefore turn them off.
;; Leave the menu bar enabled.
(if window-system (scroll-bar-mode -1))
(tool-bar-mode -1)
(menu-bar-mode +1)

;; No Backup Files
(setq make-backup-files nil)

;; initial window
(setq initial-frame-alist
      '((width . 102)   ; characters in a line
        (height . 42)   ; number of lines
        (background-mode . dark)))
;        (ns-appearance . dark)

;; sebsequent frame
(setq default-frame-alist
      '((width . 100)   ; characters in a line
        (height . 40)   ; number of lines
        (background-mode . dark)))
;        (ns-appearance . dark)

;; == Load Custom Theme ==
;; Solarized
; (use-package color-theme :ensure t)
(use-package color-theme-solarized
  :ensure t
  :init
  (set-frame-parameter nil 'background-mode 'dark)
  (load-theme 'solarized t))

;;
;; Emacs >= 26 needs to turn off double buffering on Windows
(jdp/on-wsl
  (setq default-frame-alist
    (append default-frame-alist '((inhibit-double-buffering . t)))))

;; Diminish extraneous info in the modeline
;; Create macro to diminish modes after they are loaded


;; (defmacro rename-major-mode (package-name mode new-name)
;;   "Renames a major mode."
;;  `(eval-after-load ,package-name
;;    '(defadvice ,mode (after rename-modeline activate)
;;       (setq mode-name ,new-name))))
;; (rename-major-mode "python" python-mode "π")
;; (rename-major-mode "markdown-mode" markdown-mode "Md")
;; (rename-major-mode "shell" shell-mode "σ")
;; (rename-major-mode "org" org-mode "ω")
;; (rename-major-mode "Web" web-mode "w")

;; (add-hook 'web-mode-hook (lambda() (setq mode-name "w")))
;; (add-hook 'emacs-lisp-mode-hook (lambda() (setq mode-name "ελ")))

;;; init-10-face.el ends here
