; extends

((element
  (start_tag
    (tag_name) @_tag)) @class.outer
  (#match? @_tag "^(html|section|h[0-9]|header|title|head|body|div)$"))

((element
  (start_tag
    (tag_name) @_tag)
  .
  (_) @class.inner
  .
  (end_tag))
  (#match? @_tag "^(html|section|h[0-9]|header|title|head|body|div)$"))

((element
  (start_tag
    (tag_name) @_tag)
  .
  (_) @_start
  (_) @_end
  .
  (end_tag))
  (#match? @_tag "^(html|section|h[0-9]|header|title|head|body|div)$")
  (#make-range! "class.inner" @_start @_end))
