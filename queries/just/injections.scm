; File autogenerated by build-queries-nvim.py; do not edit

; Specify nested languages that live within a `justfile`

; ================ Always applicable ================

((comment) @injection.content
  (#set! injection.language "comment"))

; Highlight the RHS of `=~` as regex
((regex_literal
  (_) @injection.content)
  (#set! injection.language "regex"))

; ================ Global defaults ================

; Default everything to be bash
(recipe_body
  !shebang
  (#set! injection.language "bash")
  (#set! injection.include-children)) @injection.content

(external_command
  (command_body) @injection.content
  (#set! injection.language "bash"))

; ================ Global language specified ================
; Global language is set with something like one of the following:
;
;    set shell := ["bash", "-c", ...]
;    set shell := ["pwsh.exe"]
;
; We can extract the first item of the array, but we can't extract the language
; name from the string with something like regex. So instead we special case
; two things: powershell, which is likely to come with a `.exe` attachment that
; we need to strip, and everything else which hopefully has no extension. We
; separate this with a `#match?`.
;
; Unfortunately, there also isn't a way to allow arbitrary nesting or
; alternatively set "global" capture variables. So we can set this for item-
; level external commands, but not for e.g. external commands within an
; expression without getting _really_ annoying. Should at least look fine since
; they default to bash. Limitations...
; See https://github.com/tree-sitter/tree-sitter/issues/880 for more on that.

(source_file
  (setting "shell" ":=" "[" (string) @_langstr
    (#match? @_langstr ".*(powershell|pwsh|cmd).*")
    (#set! injection.language "powershell"))
  [
    (recipe
      (recipe_body
        !shebang
        (#set! injection.include-children)) @injection.content)

    (assignment
      (expression
        (value
          (external_command
            (command_body) @injection.content))))
  ])

(source_file
  (setting "shell" ":=" "[" (string) @injection.language
    (#not-match? @injection.language ".*(powershell|pwsh|cmd).*"))
  [
    (recipe
      (recipe_body
        !shebang
        (#set! injection.include-children)) @injection.content)

    (assignment
      (expression
        (value
          (external_command
            (command_body) @injection.content))))
  ])

; ================ Recipe language specified ================

; Set highlighting for recipes that specify a language, using the exact name by default
(recipe_body ;
  (shebang ;
    (language) @injection.language)
  (#not-any-of? @injection.language "python3" "nodejs" "node" "uv")
  (#set! injection.include-children)) @injection.content

; Transform some known executables

; python3/uv -> python
(recipe_body
  (shebang
    (language) @_lang)
  (#any-of? @_lang "python3" "uv")
  (#set! injection.language "python")
  (#set! injection.include-children)) @injection.content

; node/nodejs -> javascript
(recipe_body
  (shebang
    (language) @_lang)
  (#any-of? @_lang "node" "nodejs")
  (#set! injection.language "javascript")
  (#set! injection.include-children)) @injection.content
