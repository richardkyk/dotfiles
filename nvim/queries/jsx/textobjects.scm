; extends
; Paired tags
(jsx_element
  open_tag: (_)
  .
  (_) @_start
  (_)* @_end
  .
  close_tag: (_)
  (#make-range! "jsx_element.inner" @_start @_end)) @jsx_element.outer


; Self closing tags
(jsx_self_closing_element
  name: (identifier)
  .
  (_) @_start
  (_)* @_end
  .
  (#make-range! "jsx_element.inner" @_start @_end)) @jsx_element.outer

