;;; vterm-posframe.el --- Description -*- lexical-binding: t; -*-
;;
;; Copyright (C) 2023
;;
;; Author:  <gibi@CreeprPC>
;; Maintainer:  <gibi@CreeprPC>
;; Created: December 13, 2023
;; Modified: December 13, 2023
;; Version: 0.0.1
;; Keywords: abbrev bib c calendar comm convenience data docs emulations extensions faces files frames games hardware help hypermedia i18n internal languages lisp local maint mail matching mouse multimedia news outlines processes terminals tex tools unix vc wp
;; Homepage: https://github.com/ghibranalj/vterm-posframe
;; Package-Requires: ((emacs "27.1") (vterm "0.0.2") (posframe "1.0.0"))
;;
;; This file is not part of GNU Emacs.
;;
;;; Commentary:
;;
;;  Description
;;
;;; Code:

(require 'vterm)
(require 'posframe)

(defgroup vterm-posframe nil
  "scratch posframe"
  :prefix "vterm-posframe"
  :group 'convience)

(defvar vterm-posframe--buffer nil)
(defvar vterm-posframe--frame nil)

(defcustom vterm-posframe-buffer-name "posframe-vterm"
  "name of scratch buffer"
  :type 'string
  :group 'vterm-posframe)

(defcustom vterm-posframe-parameters
  '((left-fringe . 8)
    (right-fringe . 8))
  "frame parameters used by vterm-posframe"
  :type 'string
  :group 'vterm-posframe)

(defcustom vterm-posframe-poshandler 'posframe-poshandler-frame-center
  "posframe used by vterm-posframe"
  :type 'symbol
  :group 'vterm-posframe)

(defcustom vterm-posframe-width 160
  "vterm-posframe width"
  :type 'number
  :group 'vterm-posframe)

(defcustom vterm-posframe-height 40
  "vterm-posframe height"
  :type 'number
  :group 'vterm-posframe)

(defcustom vterm-posframe-border-width 2
  "vterm-posframe border width"
  :type 'number
  :group 'vterm-posframe)

(defface vterm-posframe-border
  '((t (:inherit default :background "gray50")))
  "Face used by the vterm-posframe"
  :group 'vterm-posframe)

(defcustom vterm-posframe-vterm-func #'vterm-posframe--create-vterm
  "vterm-posframe vterm function"
  :type 'function
  :group 'vterm-posframe)

(defcustom vterm-posframe-vterm-func-interactive nil
  "vterm-posframe vterm function interactive"
  :type 'boolean
  :group 'vterm-posframe)

(defun vterm-posframe-close ()
  (interactive "")
  (posframe-hide vterm-posframe--buffer)
  (if (fboundp 'evil-force-normal-state)
      (advice-remove 'evil-force-normal-state 'ignore))
  ;; NOTE if you override this function
  ;; you need to set this variable to nil
  (setq  vterm-posframe--frame nil))

(defun vterm-posframe--hide-when-focus-lost ()
  (when (and vterm-posframe--frame
             (or
              (not (frame-live-p vterm-posframe--frame))
              (not (frame-focus-state vterm-posframe--frame))))
    (vterm-posframe-close)
    (remove-hook 'post-command-hook #'vterm-posframe--hide-when-focus-lost)))

(defun vterm-posframe--create-vterm ()
  (let ((buffer (generate-new-buffer vterm-posframe-buffer-name)))
    (with-current-buffer buffer
      (vterm-mode))
    buffer))
;;
(defun vterm-posframe-show (&optional arg)
  (interactive "P")
  (remove-hook 'post-command-hook #'vterm-posframe--hide-when-focus-lost)
  ;; (if scratch-posframe--buffer
  ;;     (posframe-hide scratch-posframe--buffer))

  (let ((buffer (if vterm-posframe-vterm-func-interactive
                    (funcall-interactively vterm-posframe-vterm-func arg)
                  (funcall vterm-posframe-vterm-func)))
        (frame nil))
    (when (get-buffer-window buffer)
      (delete-window (get-buffer-window buffer)))
    (setq frame
          (posframe-show
           buffer
           :poshandler vterm-posframe-poshandler
           :height vterm-posframe-height :min-height vterm-posframe-height
           :width vterm-posframe-width :min-width vterm-posframe-width
           :parameters vterm-posframe-parameters
           :border-color (face-attribute 'vterm-posframe-border :background)
           :hidehandler #'(vterm-posframe--hide-when-focus-lost)
           :cursor t
           :accept-focus t
           :refresh nil
           :border-width vterm-posframe-border-width))

    (setq vterm-posframe--buffer buffer)
    (setq vterm-posframe--frame frame)

    (x-focus-frame frame)
    (set-window-margins (get-buffer-window buffer) 4 4)
    ;; timeout 0.5 seconds
    (if (fboundp 'evil-force-normal-state)
        (advice-add 'evil-force-normal-state :override 'ignore))
    (run-with-timer 0.1 nil #'add-hook 'post-command-hook #'vterm-posframe--hide-when-focus-lost)))

  (defun vterm-posframe-toggle (&optional arg)
    (interactive "P")
    (if vterm-posframe--frame
        (vterm-posframe-close)
      (vterm-posframe-show arg)))

  (provide 'vterm-posframe)
;;; vterm-posframe.el ends here
