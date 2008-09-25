(defmodule trace
  (export (start 0)))

(defun args-formatted-string
  ((()) '" ")				;List of arguments!
  (((a . as))				;List of arguments!
   (: lists concat
     (list '" " a '"=~p" (args-formatted-string as)))))

(defmacro print-fun-start (name2 args2)	;No matching of arguments!
  `(progn
     (: io format
       (: lists concat
	 (list '"IN [ "
	       ,name2
	       '","
	       (args-formatted-string ',args2)
	       '"]~n"))
       (list . ,args2))))

(defmacro print-fun-result (name2 args2 res2) ;No matching of arguments!
  `(progn
     (: io format
       (: lists concat
	 (list '"OUT[ "
	       ,name2
	       '","
	       (args-formatted-string ',args2)
	       '"=> "
	       '"~p "
	       '"]~n"))
       (: lists concat (list (list . ,args2)
			     (list ,res2))))))

(defmacro trace
  ((('define . ((name . args) . body)) . '())
   `(define (,name . ,args)
      (print-fun-start ',name ,args)
      (let ((res . ,body))
	(print-fun-result ',name ,args res)
	res)))
  ((('defun . (name . (args . body))) . '())
   `(define (,name . ,args)
      (print-fun-start ',name ,args)
      (let ((res . ,body))
	(print-fun-result ',name ,args res)
	res))))

(trace
 (defun myfunc (x)
   (if (>= x 3)
     0
     (myfunc (+ 1 x)))))

(defun start ()
  (myfunc 0))
