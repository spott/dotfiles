;; Prettify and Pretty mode.
;; From: https://ekaschalk.github.io/post/prettify-mode/
;; and : https://gist.github.com/mordocai/50783defab3c3d1650e068b4d1c91495
;; and : https://github.com/akatov/pretty-mode



(defconst font-ligatures-packages
  '(pretty-mode
    )
  )

(defun font-ligatures/init-pretty-mode ()
  (use-package pretty-mode
    :defer t
    :init
    (add-hook 'python-mode-hook 'turn-on-pretty-mode)
    (add-hook 'python-mode-hook 'prettify-symbols-mode)
    (add-hook 'python-mode-hook 'replace-keywords-python)
    (add-hook 'python-mode-hook 'add-fira-code-symbol-keywords))
  ;;:config
  ;; (replace-keywords-python)
  ;; (add-fira-code-symbol-keywords)
  )

(defun font-ligatures/post-init-pretty-mode ()
  (set-fontset-font t '(#Xe100 . #Xe16f) "Fira Code Symbol")
  (pretty-deactivate-groups
   '(:equality :ordering :ordering-double :ordering-triple
               :arrows :arrows-twoheaded :punctuation
               :logic :sets))
  (pretty-activate-groups
   '(:sub-and-superscripts :greek :arithmetic-nary))
  )


(defun add-fira-code-symbol-keywords ()
  (font-lock-add-keywords nil fira-code-font-lock-keywords-alist))

(defun replace-keywords-python ()
  (mapc (lambda (pair) (push pair prettify-symbols-alist))
        '(;; Syntax
          ("def" .      #x2131)
          ("not" .      #x2757)
          ("in" .       #x2208)
          ("not in" .   #x2209)
          ("return" .   #x27fc)
          ("yield" .    #x27fb)
          ("for" .      #x2200)
          ;; Base Types
          ("int" .      #x2124)
          ("float" .    #x211d)
          ("str" .      #x1d54a)
          ("True" .     #x1d54b)
          ("False" .    #x1d53d)
          ;; Mypy
          ("Dict" .     #x1d507)
          ("List" .     #x2112)
          ("Tuple" .    #x2a02)
          ("Set" .      #x2126)
          ("Iterable" . #x1d50a)
          ("Any" .      #x2754)
          ("Union" .    #x22c3))))
;;(add-hook 'haskell-mode-hook 'turn-on-pretty-mode)
