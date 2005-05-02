(require 'ids-find)

(defun decode-url-string (string &optional coding-system)
  (if (> (length string) 0)
      (let ((i 0)
	    dest)
	(while (string-match "%\\([0-9A-F][0-9A-F]\\)" string i)
	  (setq dest (concat dest
			     (substring string i (match-beginning 0))
			     (char-to-string
			      (int-char
			       (string-to-int (match-string 1 string) 16))))
		i (match-end 0)))
	(decode-coding-string
	 (concat dest (substring string i))
	 coding-system))))

(let ((components (car command-line-args-left))
      is ucs)
  (setq command-line-args-left (cdr command-line-args-left))
  (cond
   ((stringp components)
    (if (string-match "^components=" components)
	(setq components (substring components (match-end 0))))
    (setq components
	  (if (> (length components) 0)
	      (decode-url-string components 'utf-8-jp-er)
	    nil))
    )
   (t
    (setq components nil)
    ))
  (princ "Content-Type: text/html; charset=\"UTF-8\"

<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\"
            \"http://www.w3.org/TR/html4/loose.dtd\">
<html lang=\"ja\">
<head>
<title>CHISE IDS Find</title>
</head>

<body>

<h1>")
  (princ (encode-coding-string "CHISE IDS $B4A;z8!:w(B" 'utf-8-jp-er))
  (princ "</h1>
<p>
<form action=\"http://mousai.kanji.zinbun.kyoto-u.ac.jp/ids-find\" method=\"GET\">
")
  (princ (encode-coding-string "$BItIJJ8;zNs(B" 'utf-8-jp-er))
  (princ " <input type=\"text\" name=\"components\" size=\"30\" maxlength=\"30\" value=\"")
  (if (> (length components) 0)
      (princ (encode-coding-string components 'utf-8-er)))
  (princ "\">
<input type=\"submit\" value=\"")
  (princ (encode-coding-string "$B8!:w3+;O(B" 'utf-8-jp-er))
  (princ "\">
</form>

")
  (when components
    ;; (map-char-attribute
    ;;  (lambda (c v)
    ;;    (when (every (lambda (p)
    ;;                   (ideographic-structure-member p v))
    ;;                 components)
    ;;      (princ (encode-coding-string
    ;;              (ids-find-format-line c v)
    ;;              'utf-8-jp-er))
    ;;      (princ "<br>\n")
    ;;      )
    ;;    nil)
    ;;  'ideographic-structure)
    (dolist (c (ideographic-products-find components))
      (setq is (char-feature c 'ideographic-structure))
      ;; to avoid problems caused by wrong indexes
      (when (every (lambda (c)
		     (ideographic-structure-member c is))
		   components)
	(princ
	 (encode-coding-string
	  (format "%c" c)
	  'utf-8-jp-er))
	(princ
	 (or (if (setq ucs (or (char-ucs c)
			       (encode-char c 'ucs)))
		 (format "<a href=\"http://www.unicode.org/cgi-bin/GetUnihanData.pl?codepoint=%X\">%s</a>"
			 ucs
			 (cond ((<= ucs #xFFFF)
				(format "    U+%04X" ucs))
			       ((<= ucs #x10FFFF)
				(format "U-%08X" ucs))))
	       "          ")))
	(princ " ")
	(princ
	 (encode-coding-string
	  (ideographic-structure-to-ids is)
	  'utf-8-jp-er))
	(when (and ucs
		   (with-current-buffer
		       (find-file-noselect
			"~tomo/projects/chise/ids/www/tang-chars.udd")
		     (goto-char (point-min))
		     (re-search-forward (format "^%d$" ucs) nil t)))
	  (princ
	   (format " <a href=\"http://coe21.zinbun.kyoto-u.ac.jp/djvuchar?query=%s\">"
		   (mapconcat
		    (lambda (c)
		      (format "%%%02X" (char-int c)))
		    (encode-coding-string (char-to-string c)
					  'utf-8-jp)
		    "")))
	  (princ (encode-coding-string "$B"M(B[$BEbBeBsK\(B]</a>" 'utf-8-jp-er)))
	(princ "<br>\n")
	))
    )
  (princ "
</body>
</html>
"))
