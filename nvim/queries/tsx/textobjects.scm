(function_declaration) @function
(expression_statement) @expression
(lexical_declaration) @variable
; ... other rules



(jsx_element) @jsx.outer

(jsx_element (jsx_opening_element) . (_) @jsx.inner . (jsx_closing_element))

((jsx_element (jsx_opening_element) . (_) @_start (_) @_end . (jsx_closing_element))
 (#make-range! "jsx.inner" @_start @_end))

((jsx_element (jsx_opening_element (identifier) @_tag) . (_) @jsx.inner . (jsx_closing_element))
 (#match? @_tag "^(html|section|h[0-9]|header|title|head|body|div|span|p)$"))

(jsx_element
  (jsx_self_closing_element) @jsx.self
  (#make-range! "tag.inner" @jsx.self @jsx.self)) @jsx.inner
