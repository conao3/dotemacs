;;; -*- mode: emacs-lisp; coding: utf-8; -*-
;; Copyright (C) 2008- Liu Xin
;;
;; This code has been released into the Public Domain.
;; You may do whatever you like with it.
;;
;; @file
;; @author Liu Xin <meteor1113@qq.com>
;; @date 2015-12-26
;; @URL http://git.oschina.net/meteor1113/dotemacs

;; artist-mode
(defadvice artist-coord-win-to-buf (before tabbar-mode activate compile)
  "Hack artist-mode's wrong position when tabbar-mode."
  (when tabbar-mode
    (setq coord (cons (car coord) (1- (cdr coord))))))

(provide 'init-artist)