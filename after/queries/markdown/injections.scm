; Inject BFM block parser into markdown sections
; Targets section nodes which contain block-level content where directives appear
((section) @injection.content
  (#set! injection.language "bfm")
  (#set! injection.combined))
