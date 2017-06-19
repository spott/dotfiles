;; (defun pio/platformio-conditionally-enable ()
;;   "Enable `platformio-mode' only when a `platformio.ini' file is present in project root."
;;   (condition-case nil
;;       (when (projectile-verify-file "platformio.ini")
;;         (platformio-mode 1))
;;     (error nil)))
