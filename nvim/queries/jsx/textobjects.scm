; extends
; Paired tags
(jsx_element
  open_tag: (_)
  .
  (_) @_start
  (_)* @_end
  .
  close_tag: (_)
  (#make-range! "jsx.inner" @_start @_end)) @jsx.outer


; Self closing tags
(jsx_self_closing_element
  name: (identifier)
  .
  (_) @_start
  (_)* @_end
  .
  (#make-range! "jsx.inner" @_start @_end)) @jsx.outer

(jsx_element) @jsx.outer

(jsx_element (jsx_opening_element) . (_) @jsx.inner . (jsx_closing_element))

((jsx_element (jsx_opening_element) . (_) @_start (_) @_end . (jsx_closing_element))
 (#make-range! "jsx.inner" @_start @_end))

((jsx_element (jsx_opening_element (identifier) @_tag) . (_) @jsx.inner . (jsx_closing_element))
 (#match? @_tag "^(html|section|h[0-9]|header|title|head|body|div|span|p)$"))

(jsx_element
  (jsx_self_closing_element) @jsx.self
  (#make-range! "tag.inner" @jsx.self @jsx.self)) @jsx.inner
