;;; init.el --- description -*- lexical-binding: t; -*-
;;
;; Maintainer: abst.proc.do <abst.proc.do@qq.com>
;; Created: February 28, 2021
;; Modified: February 28, 2021
;; Version: 0.0.1

(setq user-emacs-directory "~/.zeroemacs/")

;; (setq package-archives '(("gnu"   . "http://mirrors.tuna.tsinghua.edu.cn/elpa/gnu/")
;;                          ("org-cn". "http://mirrors.tuna.tsinghua.edu.cn/elpa/org/")
;;                          ("melpa" . "http://mirrors.tuna.tsinghua.edu.cn/elpa/melpa/")))

;;
;;ivy's 3 packages 
(add-to-list 'load-path "~/.zeroemacs/elpa/ivy-0.13.1/")
(add-to-list 'load-path "~/.zeroemacs/elpa/counsel-0.13.1/")
(add-to-list 'load-path "~/.zeroemacs/elpa/swiper-0.13.1/")

(require 'ivy)
(require 'swiper)
(require 'counsel)

(ivy-mode 1)

(setq ivy-count-format "(%d/%d) ") ;;Display line numbers of ivy
(global-set-key "\C-s" 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key "\C-xb" 'ivy-switch-buffer)

;; Set bookmarks
(setq bookmark-default-file "~/Documents/primary.doom.d/bookmarks")

;; Set dired
(add-hook 'dired-mode-hook #'dired-hide-details-mode)

;; Moving Cursor Around 
(defun previous-multilines ()
  "scroll down multiple lines"
  (interactive)
  (scroll-down (/ (window-body-height) 3)))

(defun next-multilines ()
  "scroll up multiple lines"
  (interactive)
  (scroll-up (/ (window-body-height) 3)))

(global-set-key "\M-n" 'next-multilines) ;;custom
(global-set-key "\M-p" 'previous-multilines) ;;custom

;; Buffers
(global-set-key "\C-xp" 'previous-buffer) ;;custom
(global-set-key "\C-xn" 'next-buffer);;custom

;;
;;
;; fill and editing 
(global-visual-line-mode)

;;
;; org note 
;; config all the org noting here
(add-hook 'org-mode-hook 'org-indent-mode)

;;Initial visbility
(setq org-startup-folded 'show2levels)

;;dictionay for reading 
(add-to-list 'load-path "~/.zeroemacs/elpa/bing-dict-20200216.110")
(require 'bing-dict)
(global-set-key "\C-cd" 'bing-dict-brief)

;;
;; org-babel
;; babel-language
;; Execute no query
(setq org-confirm-babel-evaluate nil)
;; Set languages
(require 'ob-js)
;;(add-to-list 'org-babel-load-languages '(js . t))
;;(org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages)
;;(add-to-list 'org-babel-tangle-lang-exts '("js" . "js"))
;; 以上简写为：
(org-babel-do-load-languages 'org-babel-load-languages '((js . t)
                                                         ;; other languages..
                                                         ))
;;;;Beautifly babel src code 
;;;;hide header of source code.

(with-eval-after-load 'org
  (defvar-local
    rasmus/org-at-src-begin
    -1
    "Variable that holds whether last position was a ")
  (defvar rasmus/ob-header-symbol ?☰
    "Symbol used for babel headers")
  (defun rasmus/org-prettify-src--update ()
    (let ((case-fold-search t)
          (re "^[ \t]*#\\+begin_src[ \t]+[^ \f\t\n\r\v]+[ \t]*") found)
      (save-excursion (goto-char (point-min))
                      (while (re-search-forward re nil t)
                        (goto-char (match-end 0))
                        (let ((args (org-trim
                                     (buffer-substring-no-properties
                                      (point)
                                      (line-end-position)))))
                          (when (org-string-nw-p args)
                            (let ((new-cell (cons args rasmus/ob-header-symbol)))
                              (cl-pushnew new-cell prettify-symbols-alist
                                          :test #'equal)
                              (cl-pushnew new-cell found
                                          :test #'equal)))))
                      (setq prettify-symbols-alist (cl-set-difference prettify-symbols-alist
                                                                      (cl-set-difference
                                                                       (cl-remove-if-not (lambda
                                                                                           (elm)
                                                                                           (eq (cdr
                                                                                                elm)
                                                                                               rasmus/ob-header-symbol))
                                                                                         prettify-symbols-alist)
                                                                       found
                                                                       :test #'equal)))
                      ;; Clean up old font-lock-keywords.
                      (font-lock-remove-keywords nil prettify-symbols--keywords)
                      (setq prettify-symbols--keywords (prettify-symbols--make-keywords))
                      (font-lock-add-keywords
                       nil
                       prettify-symbols--keywords)
                      (while (re-search-forward re nil t)
                        (font-lock-flush (line-beginning-position)
                                         (line-end-position))))))
  (defun rasmus/org-prettify-src ()
    "Hide src options via `prettify-symbols-mode'.

  `prettify-symbols-mode' is used because it has uncollpasing. It's
  may not be efficient."
    (let* ((case-fold-search t)
           (at-src-block (save-excursion (beginning-of-line)
                                         (looking-at
                                          "^[ \t]*#\\+begin_src[ \t]+[^ \f\t\n\r\v]+[ \t]*"))))
      ;; Test if we moved out of a block.
      (when (or (and rasmus/
                     org-at-src-begin
                     (not at-src-block))
                ;; File was just opened.
                (eq rasmus/org-at-src-begin -1))
        (rasmus/org-prettify-src--update))
      ;; Remove composition if at line; doesn't work properly.
      ;; (when at-src-block
      ;;   (with-silent-modifications
      ;;     (remove-text-properties (match-end 0)
      ;;                             (1+ (line-end-position))
      ;;                             '(composition))))
      (setq rasmus/org-at-src-begin at-src-block)))
  (defun rasmus/org-prettify-symbols ()
    (mapc (apply-partially 'add-to-list 'prettify-symbols-alist)
          (cl-reduce 'append (mapcar (lambda (x)
                                       (list x (cons (upcase (car x))
                                                     (cdr x))))
                                     `(("#+begin_src" . ?✎) ;; ➤ 🖝 ➟ ➤ ✎
                                       ("#+end_src"   . ?⏃) ;; ⏹
                                       ("#+header:" . rasmus/ob-header-symbol)
                                       ("#+begin_quote" . ?»)
                                       ("#+end_quote" . ?«)))))
    (turn-on-prettify-symbols-mode)
    (add-hook 'post-command-hook 'rasmus/org-prettify-src t t))
  (add-hook 'org-mode-hook #'rasmus/org-prettify-symbols))

;;
;;
;; org-agenda
;;最后只保留Note和Plan两部分。
(global-set-key "\C-cnn" 'org-capture)

(defun my-org-goto-last-note-headline ()
  "Move point to the last headline in file matching \"* Notes\"."
  (end-of-buffer)
  (re-search-backward "\\* Note"))

(defun my-org-goto-last-plan-headline ()
  "Move point to the last he adline in file matching \"* Plans\"."
  (end-of-buffer)
  (re-search-backward "\\* Plan"))


(setq org-capture-templates
      '(("n" "Note" entry
         (file+function "~/Documents/OrgMode/ORG/Master/todo.today.org"
                        my-org-goto-last-note-headline)
         "* %i%? \n%T")
        ("p" "Plan" entry
         (file+function "~/Documents/OrgMode/ORG/Master/todo.today.org"
                        my-org-goto-last-plan-headline)
         "* TODO %i%?")
        ))
;;短评, 此处原来设置的inactive timestamp没有一点儿道理.

;;
;;
;;agenda-time-grid
(setq org-agenda-time-grid (quote ((daily today require-timed)
                                   (300
                                    600
                                    900
                                    1200
                                    1500
                                    1800
                                    2100
                                    2400)
                                   "......"
                                   "-----------------------------------------------------"
                                   )))

;; (setq org-agenda-files '("~/Documents/OrgMode/ORG/Master/" ;;2019-06-18 13:37:12
;;                          "~/Documents/OrgMode/ORG/diary-by-months/" ;; 2020-01-10 10:45:25
;;                          ))
(setq org-agenda-files '("~/Documents/OrgMode/ORG/diary-by-months/" ;; 2020-01-10 10:45:25
                         "~/Documents/OrgMode/ORG/Master/" ;;2019-06-18 13:37:12
                         ))

;;
;; diary in org-agenda-view
(setq org-agenda-include-diary t)
(setq org-agenda-diary-file "~/Documents/OrgMode/ORG/Master/standard-diary")
(setq diary-file "~/Documents/OrgMode/ORG/Master/standard-diary")


;; Sunrise and sunset in agenda
;;Sunrise
;;日出而作, 日落而息
(defun diary-sunrise ()
  (let ((dss (diary-sunrise-sunset)))
    (with-temp-buffer
      (insert dss)
      (goto-char (point-min))
      (while (re-search-forward " ([^)]*)" nil t)
	(replace-match "" nil nil))
      (goto-char (point-min))
      (search-forward ",")
      (buffer-substring (point-min) (match-beginning 0)))))

;; sunset
(defun diary-sunset ()
  (let ((dss (diary-sunrise-sunset))
        start end)
    (with-temp-buffer
      (insert dss)
      (goto-char (point-min))
      (while (re-search-forward " ([^)]*)" nil t)
        (replace-match "" nil nil))
      (goto-char (point-min))
      (search-forward ", ")
      (setq start (match-end 0))
      (search-forward " at")
      (setq end (match-beginning 0))
      (goto-char start)
      (capitalize-word 1)
      (buffer-substring start end))))


;; 村的坐标
(setq calendar-longitude 120.964218) ;;long是经度, 东经
(setq calendar-latitude 36.605436) ;;lat, flat, 北纬


;; 中文的天干地支
(setq calendar-chinese-celestial-stem ["甲" "乙" "丙" "丁" "戊" "己" "庚" "辛" "壬" "癸"])
(setq calendar-chinese-terrestrial-branch ["子" "丑" "寅" "卯" "辰" "巳" "午" "未" "申" "酉" "戌" "亥"])


;; 对呀, 此处便可以理解, long是纵向的线条.
;;设置一周从周一开始.
(setq calendar-week-start-day 1)
;;(require 'calfw)


(add-to-list 'load-path "~/.zeroemacs/elpa/cal-china-x-20200924.1837")
(require 'cal-china-x)

(setq mark-holidays-in-calendar t)
(setq cal-china-x-important-holidays cal-china-x-chinese-holidays)
(setq calendar-holidays
      (append cal-china-x-important-holidays
              cal-china-x-general-holidays
              holiday-general-holidays
              holiday-christian-holidays
              ))
;;中美的节日.


;; My functions
;; newday
(defun newday ()
  (interactive)
  (progn
    (find-file "~/Documents/OrgMode/Org/Master/todo.today.org")
    (goto-char (point-max))
    (insert "*" ?\s (format-time-string "%Y-%m-%d %A") ?\n
            "** Plan\n"
            "** HandsOn\n"
            "** Notes\n"
            "** Review\n"
            )))

;;today
(defun today ()
  (interactive)
  (progn
    (find-file "~/Documents/OrgMode/Org/Master/todo.today.org")
    (goto-char (point-max))
    (re-search-backward "\\* Plan")))

;;wsl-copy
(defun wsl-copy (start end)
  (interactive "r")
  (shell-command-on-region start end "clip.exe")
  (deactivate-mark))

; wsl-paste
(defun wsl-paste ()
  (interactive)
  (let ((clipboard
         (shell-command-to-string "powershell.exe -command 'Get-Clipboard' 2> /dev/null")))
    (setq clipboard (replace-regexp-in-string "\r" "" clipboard)) ; Remove Windows ^M characters
    (setq clipboard (substring clipboard 0 -1)) ; Remove newline added by Powershell
    (insert clipboard)))


;;themes 2021-03-06 11:22 am
(load-theme 'tango-dark t t)


;; Programming
(add-to-list 'load-path "~/.zeroemacs/dash.el/")
(require 'dash)


(provide 'config)
;;; config.el ends here
