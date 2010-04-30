;;;
;; Copyright (C) 2009 Meteor Liu
;;
;; This code has been released into the Public Domain.
;; You may do whatever you like with it.
;;
;; @file
;; @author Meteor Liu <meteor1113@gmail.com>
;; @date 2008-08-08
;; @URL http://github.com/meteor1113/dotemacs


;; load-path
(let* ((dir (file-name-directory (or load-file-name (buffer-file-name))))
       (lisp-dir (expand-file-name "lisp" dir)))
  (add-to-list 'load-path dir)
  (when (file-exists-p lisp-dir)
    (progn (add-to-list 'load-path lisp-dir)
           (let ((old-dir default-directory))
             (cd lisp-dir)
             (normal-top-level-add-subdirs-to-load-path)
             (cd old-dir)))))

(when (not (fboundp 'define-globalized-minor-mode))
  (defalias 'define-globalized-minor-mode 'define-global-minor-mode))

;; unicad
(require 'unicad nil 'noerror)

;; cursor-chg
(when (and window-system (require 'cursor-chg nil 'noerror))
  (toggle-cursor-type-when-idle 1)
  (change-cursor-mode 1))

;; smart-compile
(autoload 'smart-compile "smart-compile" nil t)
(global-set-key [C-f7] 'smart-compile)

;; tabbar
(when (require 'tabbar nil 'noerror)
  (tabbar-mode t))

;; window-numbering
(when (require 'window-numbering nil 'noerror)
  (window-numbering-mode 1))

;; ascii
(autoload 'ascii-on        "ascii" "Turn on ASCII code display."   t)
(autoload 'ascii-off       "ascii" "Turn off ASCII code display."  t)
(autoload 'ascii-display   "ascii" "Toggle ASCII code display."    t)
(autoload 'ascii-customize "ascii" "Customize ASCII code display." t)

;; recent-jump
(when (require 'recent-jump nil 'noerror)
  (global-set-key (kbd "<M-S-left>") 'recent-jump-jump-backward)
  (global-set-key (kbd "<M-S-right>") 'recent-jump-jump-forward))

;; drag-stuff
(when (require 'drag-stuff nil 'noerror)
  (drag-stuff-global-mode t))

;; highlight-tail
(autoload 'highlight-tail-mode "highlight-tail"
  "Draw a \"tail\" while you're typing." t)
;; (when (and window-system (require 'highlight-tail nil 'noerror))
;;   (highlight-tail-mode 1))

;; highlight-parentheses
(when (require 'highlight-parentheses nil 'noerror)
  (add-hook 'find-file-hooks (lambda () (highlight-parentheses-mode t))))

;; highlight-symbol
(when (require 'highlight-symbol nil 'noerror)
  (defvar disable-hl-s-modes
    '(erc-mode occur-mode w3m-mode)
    "This buffers don't active highlight-symbol-mode.")
  (define-global-minor-mode global-highlight-symbol-mode
    highlight-symbol-mode
    (lambda ()
      (when (not (memq major-mode disable-hl-s-modes))
        (highlight-symbol-mode 1))))
  (when window-system
    (global-highlight-symbol-mode t))
  (setq highlight-symbol-idle-delay 0.05)
  (global-set-key [(meta f3)] 'highlight-symbol-at-point)
  (global-set-key (kbd "ESC <f3>") 'highlight-symbol-at-point) ; putty
  (global-set-key [f3] 'highlight-symbol-next)
  (global-set-key [(shift f3)] 'highlight-symbol-prev)
  (global-set-key [(control f3)] 'highlight-symbol-query-replace))
(defadvice highlight-symbol-mode-post-command
  (around gud-tooltip-advice activate)
  "Hack for gud-tooltip-mode."
  (unless (eq this-command 'gud-tooltip-mouse-motion)
    (let ((symbol (highlight-symbol-get-symbol)))
      (unless (or (equal symbol highlight-symbol)
                  (member symbol highlight-symbol-list))
        ad-do-it))))

;; ifdef
(add-hook 'c-mode-common-hook
          '(lambda ()
             (when (require 'ifdef nil 'noerror)
               (define-key c-mode-base-map [?\C-c ?\C-i] 'mark-ifdef)
               (mark-ifdef))))

;; doc-mode/doxymacs-mode
(add-hook 'c-mode-common-hook
          '(lambda ()
             (if (and (require 'semantic nil 'noerror)
                      (require 'doc-mode nil 'noerror))
                 (doc-mode t)
               (when (require 'doxymacs nil 'noerror)
                 (doxymacs-mode t)
                 (doxymacs-font-lock)))))

;; sourcepair
(when (require 'sourcepair nil 'noerror)
  (define-key c-mode-map [M-f12] 'sourcepair-load)
  (define-key c++-mode-map [M-f12] 'sourcepair-load)
  (define-key objc-mode-map [M-f12] 'sourcepair-load)
  (define-key c-mode-base-map (kbd "ESC <f12>") 'sourcepair-load) ; putty
  (setq sourcepair-source-extensions
        '(".cpp" ".cxx" ".c++" ".CC" ".cc" ".C" ".c" ".mm" ".m"))
  (setq sourcepair-header-extensions
        '(".hpp" ".hxx" ".h++" ".HH" ".hh" ".H" ".h"))
  (setq sourcepair-header-path '("." "include" ".." "../include" "../inc"
                                 "../../include" "../../inc" "../*"))
  (setq sourcepair-source-path '("." "src" ".." "../src" "../*"))
  (setq sourcepair-recurse-ignore '("CVS" ".svn" ".git"
                                    "Obj" "Debug" "Release" "bin" "lib")))

;; yasnippet
(when (or (require 'yasnippet-bundle nil 'noerror)
          (require 'yasnippet nil 'noerror))
  (setq yas/wrap-around-region t)
  (unless (featurep 'yasnippet-bundle)
    (yas/initialize))
  (let* ((dir (file-name-directory (or load-file-name (buffer-file-name))))
         (snippets-dir (expand-file-name "snippets" dir)))
    (when (file-exists-p snippets-dir)
      (yas/load-directory snippets-dir)))
  (when (require 'org nil 'noerror)
    (add-hook 'org-mode-hook
              (let ((original-command (lookup-key org-mode-map [tab])))
                `(lambda ()
                   (setq yas/fallback-behavior
                         '(apply ,original-command))
                   (local-set-key [tab] 'yas/expand))))))

;; auto-complete
(when (and (require 'auto-complete nil 'noerror)
           (require 'auto-complete-config nil 'noerror))
  (add-to-list 'ac-modes 'org-mode)
  (add-to-list 'ac-modes 'change-log-mode)
  (add-to-list 'ac-modes 'fundamental-mode)
  (add-to-list 'ac-modes 'objc-mode)
  (add-to-list 'ac-modes 'jde-mode)
  (let* ((dir (file-name-directory (or load-file-name (buffer-file-name))))
         (dict-dir (expand-file-name "lisp/auto-complete-1.2/dict" dir)))
    (add-to-list 'ac-dictionary-directories dict-dir))
  (global-auto-complete-mode t)
  (ac-config-default)
  (defun ac-semantic-setup ()
    (setq ac-sources (append '(ac-source-semantic) ac-sources)))
  (defun ac-org-mode-setup ()
    (add-to-list 'ac-sources 'ac-source-yasnippet))
  (add-hook 'c-mode-common-hook 'ac-semantic-setup)
  (add-hook 'org-mode-hook 'ac-org-mode-setup))

;; company
(when (require 'company nil 'noerror)
  (global-company-mode t)
  (setq company-idle-delay nil)
  ;; (setq company-idle-delay t
  ;;       company-minimum-prefix-length 1
  ;;       company-begin-commands '(self-insert-command c-electric-lt-gt))
  (define-key company-mode-map (kbd "M-n") 'company-select-next)
  (define-key company-mode-map (kbd "M-p") 'company-select-previous))

;; eim
(when (require 'eim nil 'noerror)
  ;; (setq eim-use-tooltip nil)
  (register-input-method
   "eim-wb" "euc-cn" 'eim-use-package "eim-wb" "eim-wb" "wb.txt")
  (register-input-method
   "eim-py" "euc-cn" 'eim-use-package "eim-py" "eim-py" "py.txt")
  (setq default-input-method "eim-wb"))
(when (require 'eim-extra nil 'noerror)
  (global-set-key ";" 'eim-insert-ascii))


(provide 'init-misc)
