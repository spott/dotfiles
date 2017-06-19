;;; packages.el --- C/C++ Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2016 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(defconst pio-packages
      '(
        (platformio-mode :toggle (configuration-layer/package-usedp 'projectile))
        ))

(defun pio/init-platformio-mode ()
  (use-package platformio-mode
    :defer t
    :init
    (progn
      (autoload 'platformio-conditionally-enable "platformio-mode" "conditionally enable platformio-mode" nil nil)
      (autoload 'platformio-setup-compile-buffer "platformio-mode" "setup compile buffer" t nil)
      (autoload 'platformio-build "platformio-mode" "platformio build" t nil)
      (autoload 'platformio-upload "platformio-mode" "platformio upload" t nil)
      (autoload 'platformio-programmer-upload "platformio-mode" "platformio upload" t nil)
      (autoload 'platformio-spiffs-upload "platformio-mode" "platformio upload" t nil)
      (autoload 'platformio-clean "platformio-mode" "platformio upload" t nil)
      (autoload 'platformio-update "platformio-mode" "platformio upload" t nil)
      (add-hook 'c++-mode-hook (lambda () (platformio-conditionally-enable)))
      (add-hook 'c-mode-hook (lambda () (platformio-conditionally-enable)))
      )
    :config
    (progn
      ;;(platformio-setup-compile-buffer)
      (spacemacs/set-leader-keys-for-major-mode 'c++-mode
        "pb" 'platformio-build
        "pu" 'platformio-upload
        "pp" 'platformio-programmer-upload
        "ps" 'platformio-spiffs-upload
        "pc" 'platformio-clean
        "pd" 'platformio-update
        )
    )))

;; (defun pio/post-init-projectile ()
;;   (progn

;;     (add-hook 'c++-mode-hook (lambda () (platformio-conditionally-enable)))
;;     (add-hook 'c-mode-hook (lambda () (platformio-conditionally-enable)))
;;   )
;; )
