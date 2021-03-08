# 一、ZeroEmacs：从零起步搭建你的专属Emacs

当我们从 emacs -Q 启动 vanilla emacs 调试的时候，彷佛如回到了“刀耕火种”的蛮荒之初。

## 01. Emacs -Q 的四个痛点

尤其是四个经常用的功能：

查找文件： C-x C-f file-file 没有任何提示，全凭记忆力

![ZeroEmacs：从零起步搭建你的专属Emacs](images/9b49021d938841dc93bd39ea5d2c17c5)



查找函数：最依赖的 M-x execute-extended-command 同样依靠机械记忆：

![ZeroEmacs：从零起步搭建你的专属Emacs](images/3c7d1e512ca54fda983345d245ffe1da)



必须打出第一个完整的单词的情况下，按键tab才会给出适当的提示。

查找buffer：buffer的操作，只有先调用buffer-list然后再单击进入，因为switch-buffer也不会给提示：

![ZeroEmacs：从零起步搭建你的专属Emacs](images/08cecb71a5b5411e97710de41862049a)



搜索，最后最令人失望的一点是 C-s isearch-forward, 丝毫不能展示出emacs的优势，不能从mini-buffer中显示搜索结果，而只能如其他编辑器一般从正文中一个一个关键词盯着看。

![ZeroEmacs：从零起步搭建你的专属Emacs](images/20a973b1346b4ae5be895ca7413ee819)



基于以上的分析，调试 emacs 的所需的最小化配置，我们需要趁手的 1）查找文件 2）查找函数 3）查找buffer 4）搜索并从mini-buffer中展示关键词。

由此，ZeroEmacs从第一个安装包ivy起步。

## 02.加载个人专属配置

Emacs指定启动过程所调用的配置文件的命令为：

```
emacs -q -l ~/.zeroemacs/config.el
```

其中 -q(quick) 为 --no-init-file 不加载任何初始配置文件， 而核心的 -l 选项则为 -l file, --load-file。

有了 load-file，我们就能有一份专属的个人配置。

## 03.ZeroEmacs起步

首先创建 ~/.zeroemacs/ 目录与config.el 文件，并写入第一行配置:

```
(setq user-emacs-directory "~/.zeroemacs/")
```

然后启动zeroEmacs：

```
emacs -q -l ~/.zeroemacs/config.el
```

调用命令package-install 安装 counsel 包。

> ivy分为三个部分：ivy，swiper和counsel；安装counsel的同时，另外两项将自动加载为依赖包。

安装成功后，将会看到所有的包都安装在~/.zeroemacs/elpa目录下：

![ZeroEmacs：从零起步搭建你的专属Emacs](images/8e7a4d7a3f3e493eb2b8ddc75de29f0d)



之后，将ivy的配置写入confiig.el

```
(setq user-emacs-directory "~/.zeroemacs/")
;; 加载路径
(add-to-list 'load-path "~/.zeroemacs/elpa/ivy-0.13.1/")
(add-to-list 'load-path "~/.zeroemacs/elpa/counsel-0.13.1/")
(add-to-list 'load-path "~/.zeroemacs/elpa/swiper-0.13.1/")

;;分别加载这三个包
(require 'ivy)
(require 'swiper)
(require 'counsel)

(ivy-mode 1)
;;两种方法设置global-set-key
(global-set-key "\C-s" 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key "\C-xb" 'ivy-switch-buffer)

(provide 'config)
;;; config.el ends here
```

如此，ZeroEmacs的迈出最小化配置的第一步。



#  二、ZeroEmacs的中央控制台



在Emacs中，bookmarks是中央控制台，是交通指挥枢纽，是机场的塔台，是Navigation Control Center，是我们随身携带的地图。

应用ZeroEmacs得心应手，如回家一般的熟悉，自己的各种瓶瓶罐罐摆放在何处，应该将bookmarks从doom迁移过来。

```
(setq bookmark-default-file "~/.doom.d/bookmarks")
```

load-file 加载之后，无论在哪种配置上，都稳坐指挥台。

ZeroEmacs目前的所有配置：

```
(setq user-emacs-directory "~/.zeroemacs/")

(add-to-list 'load-path "~/.zeroemacs/elpa/ivy-0.13.1/")
(add-to-list 'load-path "~/.zeroemacs/elpa/counsel-0.13.1/")
(add-to-list 'load-path "~/.zeroemacs/elpa/swiper-0.13.1/")

(require 'ivy)
(require 'swiper)
(require 'counsel)

(ivy-mode 1)

(global-set-key "\C-s" 'swiper-isearch)
(global-set-key (kbd "M-x") 'counsel-M-x)
(global-set-key (kbd "C-x C-f") 'counsel-find-file)
(global-set-key "\C-xb" 'ivy-switch-buffer)

;; Set bookmarks
(setq bookmark-default-file "~/.doom.d/bookmarks")

(provide 'config)
;;; config.el ends here
```



# ZeroEmacs的任务管理

