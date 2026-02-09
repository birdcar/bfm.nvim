; Inject BFM inline parser into markdown inline content
; Task markers, modifiers, and mentions get parsed within inline nodes
((inline) @injection.content
  (#set! injection.language "bfm_inline")
  (#set! injection.combined))
