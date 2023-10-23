;;; perspective-project-bridge.el --- Integration of perspective.el + project.el -*- lexical-binding: t; -*-

;;
;; Author: Arunkumar Vaidyanathan <arunkumarmv1997@gmail.com>
;; Version: 0.1
;; Package-Requires: ((emacs "27.1") (perspective "2.18"))
;; SPDX-License-Identifier: GPL-3.0-or-later
;; Keywords: perspective, project, convenience, frames
;; URL: https://github.com/arunkmv/perspective-project-bridge

;;; License:

;; This file is not part of GNU Emacs.

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with this program; if not, write to the Free Software
;; Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

;;; Commentary:

;; Creates a perspective for each project.el project.  Based on
;; persp-mode-projectile-bridge.
;;
;;; Usage:
;; Example configuration:
;;
;; (with-eval-after-load "perspective-project-bridge-autoloads"
;;   (add-hook 'perspective-project-bridge-mode-hook
;; 	    (lambda ()
;; 	      (if perspective-project-bridge-mode
;; 		  (perspective-project-bridge-find-perspectives-for-all-buffers)
;; 		(perspective-project-bridge-kill-perspectives))))
;;   (add-hook 'after-init-hook
;; 	    (lambda ()
;; 	      (perspective-project-bridge-mode 1))
;; 	    t))
;; 
;; With use-package:
;;
;; (use-package perspective-project-bridge
;;   :hook
;;   (perspective-project-bridge-mode
;;    .
;;    (lambda ()
;;      (if perspective-project-bridge-mode
;; 	 (perspective-project-bridge-find-perspectives-for-all-buffers)
;;        (perspective-project-bridge-kill-perspectives))))
;;   (persp-mode . perspective-project-bridge-mode))

;;; Code:


(require 'perspective)
(require 'project)
(require 'cl-lib)

(defvar perspective-project-bridge-mode nil)

(defgroup perspective-project-bridge nil
  "Perspective project.el integration."
  :group 'perspective
  :group 'project
  :prefix "perspective-project-bridge-")

(defvar perspective-project-bridge-persp nil
  "Indicate if perspective is project-specific.")

(defun perspective-project-bridge-find-perspective-for-buffer (buffer)
  "Find a project-specific perspective for BUFFER.

   If no such perspective exists, a new one is created and the buffer is
   added to it"
  (when (buffer-live-p buffer)
    (with-current-buffer buffer
      (when (and perspective-project-bridge-mode
		 (buffer-name buffer)
		 (project-current))
	(let* ((name (project-name (project-current)))
	       (persp (persp-new name)))
	  (with-perspective (persp-name persp)
	    (setq perspective-project-bridge-persp t)
	    (persp-add-buffer buffer))
	  persp)))))

(defun perspective-project-bridge-find-perspectives-for-all-buffers ()
  "Find project-specific perspectives for all buffers."
  (when perspective-project-bridge-mode
    (mapc #'perspective-project-bridge-find-perspective-for-buffer
          (buffer-list))))

(defun perspective-project-bridge-kill-perspectives ()
  "Kill all project-specific perspectives."
  (mapc #'persp-kill
	(cl-delete-if-not
	 (lambda (p)
	   (with-perspective p
	     perspective-project-bridge-persp))
	 (persp-names))))

(defun perspective-project-bridge (&rest _args)
  "Create/switch to a project perspective for current buffer.

   Provides bridge between perspective and project functions when
   switch between projects.  After switching to a new project, this
   creates a new perspective for that project."
  (let* ((b (current-buffer))
	 (persp (perspective-project-bridge-find-perspective-for-buffer b)))
    (when persp
      (persp-switch (persp-name persp))
      (persp-switch-to-buffer b))))

(defvar perspective-project-bridge-funcs
  (list 'project-find-file 'project-find-regexp 'project-find-dir))

;;;###autoload
(define-minor-mode perspective-project-bridge-mode
  "`perspective' and `project.el' integration.
Creates perspectives for project.el projects."
  :init-value nil
  :global t
  (if perspective-project-bridge-mode
      (if persp-mode
	  (progn
	    ;; Add advices
	    (dolist (func perspective-project-bridge-funcs)
	      (advice-add func :after #'perspective-project-bridge))
	    (persp-make-variable-persp-local 'perspective-project-bridge-persp))
	(message "You can not enable perspective-project-bridge-mode \
unless persp is active.")
	(perspective-project-bridge-mode -1))
    ;; Remove advices
    (dolist (func perspective-project-bridge-funcs)
      (advice-remove func #'perspective-project-bridge))))

(provide 'perspective-project-bridge)

;;; perspective-project-bridge.el ends here
