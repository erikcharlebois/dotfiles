;;; cl extensions for elisp
(require 'cl-lib)

;;; package system setup
(package-initialize)
(setq package-archives
      '(("melpa" . "http://melpa.milkbox.net/packages/")
        ("gnu" . "http://elpa.gnu.org/packages/")))

;;; default package installation
(let ((packages
       '(elisp-slime-nav      ; Use M-. and M-, to navigate elisp.
         evil                 ; VIM emulation.
         anaphora             ; Anaphoric macros for elisp.
         ido-ubiquitous       ; Use ido-style completion everywhere.
         exec-path-from-shell ; Use $PATH for finding executables.
         smex                 ; ido-style completion for M-x.
         js2-mode             ; Improved JavaScript support.
         scss-mode            ; SCSS editing mode.
         sly                  ; Improved SLIME for Common Lisp.
         ac-sly               ; Autocomplete support for SLY.
         helm                 ; Fuzzy finding system.
         helm-ls-git          ; Fuzzy finding within a version control system.
         helm-cmd-t           ; Fuzzy finding within a version control system.
         flymake-cursor       ; Show compile errors on keyboard cursor hover.
         company              ; Code completion.
         tide                 ; Typescript support.
         web-mode)))          ; Improved HTML support.
  (unless (cl-every #'package-installed-p packages)
    (package-refresh-contents)
    (dolist (p packages)
      (unless (package-installed-p p)
        (package-install p)))))

;;; indentation
(setq standard-indent 2)
(setq-default tab-width standard-indent)
(setq-default indent-tabs-mode nil)

;;; disable backups and revert files changed outside emacs
(setq backup-inhibited t)
(setq create-lockfiles nil)
(setq make-backup-files nil)
(setq auto-save-default nil)
(global-auto-revert-mode)

;;; enable fancy completion at prompts
(ido-mode)
(ido-ubiquitous-mode)
(smex-initialize)

;;; minor modes and tweaks
(setq inhibit-startup-screen t)
(savehist-mode)
(column-number-mode)
(show-paren-mode)
(setq show-paren-delay 0)
(setq recentf-max-saved-items 200)
(setq compilation-scroll-output 'first-error)
(setq compilation-always-kill t)

;;; use $PATH for finding executables
(unless (eq window-system 'w32)
  (exec-path-from-shell-initialize))

;;; don't scroll the cursor to center when scrolling offscreen
(setq scroll-conservatively 101)

;;; hide the cursor in non-selected windows
(setq-default cursor-in-non-selected-windows nil)

;;; use command as an additional meta on osx
(setq ns-command-modifier 'meta)

;;; disable all GUI features
(setq ring-bell-function 'ignore)
(setq use-dialog-box nil)
(menu-bar-mode 0)
(blink-cursor-mode 0)
(tool-bar-mode 0)
(tooltip-mode 0)
(scroll-bar-mode 0)

;;; whitespace
(global-whitespace-mode)
(setq whitespace-line-column 80)
(setq whitespace-style '(face lines-tail trailing))

;;; autofill
(setq comment-auto-fill-only-comments t)

;;; evil
(evil-mode)
(setq-default evil-shift-width standard-indent)
(setq evil-esc-delay 0)
(define-key evil-motion-state-map [?\C-o] nil)
(define-key evil-normal-state-map [?\C-p] nil)
(define-key evil-motion-state-map [?\C-\]] nil)
(define-key evil-normal-state-map [?\M-.] nil)
(define-key evil-motion-state-map [?\C-d] nil)
(define-key evil-motion-state-map [?\C-y] nil)
(define-key evil-motion-state-map [?\t] nil)
(define-key evil-insert-state-map [?\C-g] 'evil-normal-state)

;;; helm
(require 'helm)
(require 'helm-cmd-t)
(require 'helm-buffers)
(require 'helm-ls-git)

(setq helm-idle-delay 0)
(setq helm-input-idle-delay 0)
(setq helm-ff-transformer-show-only-basename nil)
(setq helm-source-buffers-list
      (helm-make-source "Buffers" 'helm-source-buffers))
(setq helm-source-ls-git-list
      (helm-make-source "helm-ls-git" 'helm-ls-git-source))

(defun erikc-helm-quick-open (&optional arg)
  (interactive)
  (helm-other-buffer
   '(helm-source-buffers-list helm-source-ls-git-list helm-source-recentf)
   "*quick open*"))

;   (aif (helm-cmd-t-root-data)
;       `(helm-source-buffers-list
;         ;,(helm-cmd-t-get-create-source it)
;         helm-source-recentf)
;     '(helm-source-buffers-list helm-source-recentf))

;;; theme and font
(set-language-environment "utf-8")
(setq default-frame-alist
      `((font . ,(cl-case window-system
                   (x   "Monospace-10.5")
                   (w32 "Consolas-11")
                   (ns  "Menlo-12")))))

;;; global key bindings
(global-set-key [?\t] (lambda () (interactive)
  (unless (string= "" (buffer-substring-no-properties
                       (line-beginning-position) (line-end-position)))
    (indent-for-tab-command))))
(global-set-key [?\C-l] (lambda () (interactive)
  (beginning-of-line) (insert "\f\n")))
(global-set-key (kbd "RET") 'newline-and-indent)
(global-set-key [?\M-x] 'smex)
(global-set-key [?\M-`] 'other-frame)
(global-set-key [?\C-h] 'ff-get-other-file)
(global-set-key [?\C-o] 'erikc-helm-quick-open)
(global-set-key [?\C-d] 'erikc-git-grep-query-replace)
(global-set-key [?\C-p] 'package-list-packages)
(global-set-key [?\C-s] 'erikc-git-grep)
(global-set-key [?\M-\[] 'previous-error)
(global-set-key [?\M-\]] 'next-error)

;;; html
(add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
(setq web-mode-style-padding 2)
(setq web-mode-script-padding 2)
(setq web-mode-block-padding 2)

;;; css/scss
(setq css-indent-offset standard-indent)
(setq scss-compile-at-save nil)
;; Hack the indentation grammar for CSS and SCSS files so that for:
;;
;; foo, bar, baz {
;;   bif: bop;
;; }
;;
;; bif gets indented like the above, instead of the default below:
;;
;; foo, bar, baz {
;;             bif: bop;
;;           }
(add-hook 'css-mode-hook
          (lambda ()
            (defconst css-smie-grammar
              (smie-prec2->grammar
               (smie-precs->prec2 '((assoc ";") (left ":") (left ",")))))
            (smie-setup css-smie-grammar #'css-smie-rules
                        :forward-token #'css-smie--forward-token
                        :backward-token #'css-smie--backward-token)))

;;; elisp
(setq find-function-C-source-directory "~/Source/emacs/src")
(add-hook 'emacs-lisp-mode-hook
          (lambda ()
            (elisp-slime-nav-mode)
            (quickhelp-mode)
            (define-key emacs-lisp-mode-map (kbd "C-c C-k") 'eval-buffer)
            (define-key emacs-lisp-mode-map (kbd "C-c C-c") 'eval-defun)))

;;; common lisp
(require 'sly-autoloads)
(require 'ac-sly)
(add-hook 'sly-mode-hook 'set-up-sly-ac)
(add-hook 'sly-repl-mode-hook 'set-up-sly-ac)
(eval-after-load "auto-complete" '(add-to-list 'ac-modes 'sly-repl-mode))
(setq inferior-lisp-program "sbcl")

;;; javascript
(add-to-list 'auto-mode-alist '("\\.js\\'" . js2-mode))
(setq-default js2-basic-offset standard-indent
              js2-global-externs '("goog" "Image" "soy" "wishabi"))
(setq js-indent-level 2)

;;; auto-complete
(setq ac-delay 0)
(setq ac-auto-show-menu t)
(setq ac-quick-help-delay 1)

;;; company mode
(setq company-idle-delay 0)

;;; typescript
(setq typescript-indent-level 2)
(setq typescript-expr-indent-offset 2)
(add-hook 'typescript-mode-hook
          (lambda ()
            (tide-setup)
            (flycheck-mode +1)
            (setq flycheck-check-syntax-automatically '(save mode-enabled))
            (eldoc-mode +1)
            (company-mode)))

;; aligns annotation to the right hand side
(setq company-tooltip-align-annotations t)

;; Tide can be used along with web-mode to edit tsx files
(require 'web-mode)
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . web-mode))
(add-hook 'web-mode-hook
          (lambda ()
            (when (string-equal "tsx" (file-name-extension buffer-file-name))
              (tide-setup)
              (flycheck-mode +1)
              (setq flycheck-check-syntax-automatically '(save mode-enabled))
              (eldoc-mode +1)
              (company-mode))))

;;; help
(add-hook 'help-mode-hook (lambda () (setq word-wrap t)))

;;; swift
(setq swift-indent-offset 2)
(setq swift-indent-multiline-statement-offset 4)
(add-hook 'swift-mode-hook
          (lambda ()
            (setq whitespace-line-column 100)))

;;; c/c++
(require 'find-file)
(nconc (cadr (assoc "\\.h\\'" cc-other-file-alist)) '(".m" ".mm"))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(c-add-style "erikc"
  `((c-basic-offset . ,standard-indent)
    (c-backslash-max-column . ,(- whitespace-line-column))
    (c-offsets-alist
     . ((substatement-open     . 0)
        (innamespace           . 0)
        (access-label          . -)
        (inclass               . +)
        (statement-cont        . (c-lineup-assignments +))
        (arglist-cont-nonempty
         . (c-lineup-gcc-asm-reg
            c-lineup-string-cont
            (lambda (langelem)
              (save-excursion
                (when (c-block-in-arglist-dwim
                       (c-langelem-2nd-pos c-syntactic-element))
                  0)))
            c-lineup-arglist))
        (defun-block-intro     . +)
        (statement-block-intro . +)
        (substatement          . +)
        (case-label            . +)
        (statement-case-open   . 0)
        (inextern-lang         . 0)
        (label                 . 0)
        (brace-list-intro      . +)
        (inline-open           . 0)
        (brace-list-open       . 0)
        (func-decl-cont        . 0)
        (statement-case-intro  . +)))))

;;; quickhelp.el -- help pages in another window

;; Copyright (C) 2014 Erik Charlebois

;; Author: Erik Charlebois <erikcharlebois@gmail.com>
;; Keywords: help
;; Start date: Mon Mar 25, 2014, 11:46

;;; Commentary:

;; Utilities for displaying help in a side window.

;;; Customization:

;;;###autoload
(defgroup quickhelp nil
  "Options controlling quickhelp system."
  :group 'quickhelp)

(defcustom quickhelp-idle-delay 0.7
  "Number of seconds of idle time to wait before printing.
If user input arrives before this interval of time has elapsed after the
last input, no documentation will be printed.

If this variable is set to 0, no idle time is required."
  :type 'number
  :group 'quickhelp)

;;; Helper function:
(defvar quickhelp-timer nil "Quickhelp's timer object.")

(defvar quickhelp-current-idle-delay quickhelp-idle-delay
  "Idle time delay currently in use by timer.
This is used to determine if `quickhelp-idle-delay' is changed by the
user.")

(defun quickhelp-show-help ()
  (let ((sym-at-point (symbol-at-point)))
    (when sym-at-point
      (help-xref-interned (intern (symbol-name sym-at-point))))))

(defun quickhelp-show-current-symbol-help ()
  (condition-case err
      (when (and (boundp 'quickhelp-mode) quickhelp-mode)
        (save-window-excursion
          (quickhelp-show-help)))
    (error (message "Quickhelp error: %s" err))))

(defun quickhelp-schedule-timer ()
  (or (and quickhelp-timer
           (memq quickhelp-timer timer-idle-list))
      (setq quickhelp-timer
            (run-with-idle-timer quickhelp-idle-delay t
                                 'quickhelp-show-current-symbol-help)))

  ;; If user has changed the idle delay, update the timer.
  (cond ((not (= quickhelp-idle-delay quickhelp-current-idle-delay))
         (setq quickhelp-current-idle-delay quickhelp-idle-delay)
         (timer-set-idle-time quickhelp-timer quickhelp-idle-delay t))))

;;; Quickhelp mode

(defvar-local quickhelp-mode-string " QH"
  "Modeline indicator for quickhelp-mode")

;;;###autoload
(define-minor-mode quickhelp-mode
  "Toggle Quickhelp mode.
With no argument, this command toggles the mode.
Non-null prefix argument turns on the mode.
Null prefix argument turns off the mode.

When Autohelp mode is enabled, the hlep for thet word is displayed
in another window."
  :init-value nil
  :lighter quickhelp-mode-string
  :group 'quickhelp

  (if quickhelp-mode
      (add-hook 'post-command-hook 'quickhelp-schedule-timer nil t)
    (remove-hook 'post-command-hook 'quickhelp-schedule-timer)))

;;;###autoload
(defun turn-on-quickhelp-mode ()
  "Unequivocally turn on Quickhelp Autohelp mode (see command
`quickhelp-mode')."
  (interactive)
  (quickhelp-mode 1))

(provide 'quickhelp)

;;; quickhelp.el ends here

(require 'dired-aux)

(defun erikc-git-grep (regexp)
  "Use erikc-git-grep for project-specific search."
  (interactive
   (cl-flet ((region-or-symbol-at-point ()
            (if mark-active
                (buffer-substring-no-properties (region-beginning) (region-end))
              (or (symbol-name (symbol-at-point)) ""))))
     (let ((regexp (read-string
                    (format "Grep (default %s): " (region-or-symbol-at-point))
                    nil 'erikc-git-grep (region-or-symbol-at-point))))
       (list regexp))))
  (let ((grep-use-null-device nil)
        (compilation-buffer-name-function (lambda (name-of-mode) "*results*"))
        (default-directory (file-name-directory
                            (locate-dominating-file
                             (buffer-file-name (current-buffer)) ".git"))))
    (grep (format "git --no-pager grep -EInie %s" regexp))))

(defun erikc-git-grep-query-replace (regexp to-string)
  "Use git for project-specific query-replace."
  (interactive
   (let* ((last-regexp (and (boundp 'erikc-git-grep-query-replace-regexp)
                            erikc-git-grep-query-replace-regexp
                            (car erikc-git-grep-query-replace-regexp)))
          (last-to-string (and (boundp 'erikc-git-grep-query-replace-to-string)
                               erikc-git-grep-query-replace-to-string
                               (car erikc-git-grep-query-replace-to-string)))
          (regexp
           (if (and last-regexp last-to-string)
               (read-string
                (format "Query replace (%s -> %s): " last-regexp last-to-string)
                nil 'erikc-git-grep-query-replace-regexp)
             (read-string "Query replace: " nil
                          'erikc-git-grep-query-replace-regexp)))
          (to-string
           (if (and regexp (not (string= "" regexp)))
               (read-string (format "Query replace %s with: " regexp)
                            nil 'erikc-git-grep-query-replace-to-string))))
     (if (and regexp (not (string= "" regexp)))
         (list regexp to-string)
       (list last-regexp last-to-string))))

  (let* ((default-directory (locate-dominating-file
                             (buffer-file-name (current-buffer)) ".git"))
         (buffer-name (concat "*Git Grep Dired " default-directory "*")))
    (switch-to-buffer buffer-name)
    (fundamental-mode)
    (let ((buffer-read-only nil))
      (erase-buffer)
      (call-process-shell-command
       (format "git --no-pager grep -EilIne %s | xargs ls -l | sed -e 's/^/ /g'"
               regexp) nil t)

      (dired-mode)
      (dired-toggle-marks)

      (if (fboundp 'dired-simple-subdir-alist)
          (dired-simple-subdir-alist)
        (set (make-local-variable 'dired-subdir-alist)
             (list (cons default-directory (point-min-marker)))))
      (bury-buffer)
      (with-current-buffer buffer-name
        (dired-do-query-replace-regexp regexp to-string)))))

(deftheme erikc "A theme based on inkpot.")

(let ((vim-cursor '(list "#ff46d7" 'box))
      (emacs-cursor '(list "#0f0" 'box))
      (default
       '((t (:background "#000" :foreground "#ddd"))))
      (region
       '((t (:background "#5f5faf" :foreground "#ddd" :underline nil))))
      (search
       '((t (:background "#ffaf5f" :foreground "#000"))))
      (header
       '((t (:background "#262626" :foreground "#888" :height 1.0 :box nil))))
      (popup
       '((t (:background "#d3d3d3" :foreground "#000"))))
      (prompt
       '((t (:background "#000" :foreground "#708090"))))
      (button
       '((t (:background "#000" :foreground "#00aaff" :underline t))))
      (compilation-info
       '((t (:background "#000" :foreground "#00df5f"))))
      (whitespace-line
       '((t (:background "#a00" :foreground "#ddd"))))
      (font-lock-builtin-face
       '((t (:background "#000" :foreground "#c080d0"))))
      (font-lock-comment-face
       '((t (:background "#000" :foreground "#af5f00"))))
      (font-lock-comment-delimiter-face
       '((t (:background "#000" :foreground "#af5f00"))))
      (font-lock-constant-face
       '((t (:background "#000" :foreground "#ff5f5f"))))
      (font-lock-doc-face
       '((t (:background "#000" :foreground "#cd8b00"))))
      (font-lock-function-name-face
       '((t (:background "#000" :foreground "#97d8f8"))))
      (font-lock-keyword-face
       '((t (:background "#000" :foreground "#00aaff"))))
      (font-lock-negation-char-face
       '((t (:background "#000" :foreground "#ddd"))))
      (font-lock-preprocessor-face
       '((t (:background "#000" :foreground "#00af5f"))))
      (font-lock-string-face
       '((t (:background "#000" :foreground "#ffaf5f"))))
      (font-lock-type-face
       '((t (:background "#000" :foreground "#ff88ff"))))
      (font-lock-variable-name-face
       '((t (:background "#000" :foreground "#008b8b"))))
      (font-lock-warning-face
       '((t (:background "#000" :foreground "#e3606e")))))

  (custom-theme-set-variables
   'erikc
   `(evil-default-cursor ,vim-cursor)
   `(evil-emacs-state-cursor ,emacs-cursor))

  (custom-theme-set-faces
   'erikc
   `(default ,default)
   `(fringe ,default)

   `(popup-tip-face ,popup)
   `(region ,region)
   `(highlight ,region)
   `(show-paren-match ,region)
   `(sp-show-pair-match-face ,region)

   `(match ,search)
   `(isearch ,search)
   `(lazy-highlight ,search)
   `(query-replace ,search)

   `(mode-line ,header)
   `(mode-line-inactive ,header)
   `(header-line ,header)
   `(which-func ,header)
   `(compilation-mode-line-fail ,header)
   `(compilation-mode-line-run ,header)
   `(compilation-mode-line-exit ,header)

   `(minibuffer-prompt ,prompt)
   `(comint-highlight-prompt ,prompt)

   `(link ,font-lock-keyword-face)
   `(link-visited ,font-lock-type-face)
   `(button ,button)

   `(compilation-info ,compilation-info)

   `(font-lock-builtin-face ,font-lock-builtin-face)
   `(font-lock-comment-face ,font-lock-comment-face)
   `(font-lock-comment-delimiter-face ,font-lock-comment-delimiter-face)
   `(font-lock-constant-face ,font-lock-constant-face)
   `(font-lock-doc-face ,font-lock-doc-face)
   `(font-lock-function-name-face ,font-lock-function-name-face)
   `(font-lock-keyword-face ,font-lock-keyword-face)
   `(font-lock-negation-char-face ,font-lock-negation-char-face)
   `(font-lock-preprocessor-face ,font-lock-preprocessor-face)
   `(font-lock-string-face ,font-lock-string-face)
   `(font-lock-type-face ,font-lock-type-face)
   `(font-lock-variable-name-face ,font-lock-variable-name-face)
   `(font-lock-warning-face ,font-lock-warning-face)

   `(js2-jsdoc-tag ,font-lock-keyword-face)
   `(js2-jsdoc-type ,font-lock-type-face)
   `(js2-jsdoc-value ,font-lock-variable-name-face)
   `(js2-function-param ,font-lock-variable-name-face)

   `(erb-exec-face ,default)
   `(erb-out-face ,default)
   `(erb-face ,default)
   `(erb-exec-delim-face ,font-lock-preprocessor-face)
   `(erb-out-delim-face ,font-lock-preprocessor-face)
   `(erb-delim-face ,font-lock-preprocessor-face)
   `(erb-comment-face ,font-lock-comment-face)
   `(erb-comment-delim-face ,font-lock-comment-face)

   `(ido-first-match ,region)
   `(ido-subdir ,font-lock-builtin-face)

   `(whitespace-line ,whitespace-line)
   `(whitespace-trailing ,whitespace-line)

   `(erc-header-line ,header)
   `(erc-timestamp-face ,prompt)
   `(erc-prompt-face ,prompt)
   `(erc-notice-face ,prompt)
   `(erc-direct-msg-face ,region)
   `(erc-input-face ,header)
   `(erc-action-face ,font-lock-builtin-face)
   `(erc-error-face ,font-lock-warning-face)
   `(erc-my-nick-face ,font-lock-keyword-face)
   `(erc-nick-default-face ,font-lock-keyword-face)

   `(helm-source-header ,header)
   `(helm-match ,default)
   `(helm-header ,header)
   `(helm-candidate-number ,header)
   `(helm-selection ,region)
   `(helm-action ,default)
   `(helm-ff-file ,default)
   `(helm-buffer-process ,font-lock-comment-face)
   `(helm-ff-directory ,font-lock-keyword-face)

   `(web-mode-html-tag-face ,font-lock-keyword-face)
   `(web-mode-html-attr-name-face ,font-lock-variable-name-face)
   `(web-mode-doctype-face ,font-lock-keyword-face)
   `(web-mode-symbol-face ,font-lock-constant-face)

   `(company-tooltip ((t :background "lightgray" :foreground "black")))
   `(company-tooltip-selection ((t :background "steelblue" :foreground "white")))
   `(company-tooltip-mouse ((t :background "blue" :foreground "white")))
   `(company-tooltip-common ((t :background "lightgray" :foreground "black")))
   `(company-tooltip-common-selection ((t t :background "lightgray" :foreground "black")))
   `(company-scrollbar-fg ((t :background "black")))
   `(company-scrollbar-bg ((t :background "gray")))
   `(company-preview ((t :background nil :foreround "darkgray")))
   `(company-preview-common ((t :background nil :foreground "darkgray")))

   `(fuel-font-lock-markup-link ,button)
   `(fuel-font-lock-xref-link ,button)
   `(fuel-font-lock-stack-region ,region)

   `(factor-font-lock-comment ,font-lock-comment-face)
   `(factor-font-lock-vocabulary-name ,default)
   `(factor-font-lock-symbol ,default)
   `(factor-font-lock-invalid-syntax ,default)
   `(factor-font-lock-declaration ,font-lock-comment-face)
   `(factor-font-lock-error-form ,font-lock-builtin-face)
   `(factor-font-lock-constructor ,font-lock-builtin-face)
   `(factor-font-lock-getter-word ,font-lock-builtin-face)
   `(factor-font-lock-setter-word ,font-lock-builtin-face)
   `(factor-font-lock-number ,font-lock-constant-face)
   `(factor-font-lock-ratio ,font-lock-constant-face)
   `(factor-font-lock-constant ,font-lock-constant-face)
   `(factor-font-lock-stack-effect ,font-lock-comment-face)
   `(factor-font-lock-string ,font-lock-string-face)
   `(factor-font-lock-word ,font-lock-function-name-face)
   `(factor-font-lock-type-name ,font-lock-builtin-face)
   `(factor-font-lock-parsing-word ,font-lock-keyword-face)))
