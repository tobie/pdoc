PDoc
====

PDoc is an inline comment parser and JavaScript documentation generator written in Ruby. It is designed for documenting [Prototype](http://prototypejs.org) and Prototype-based libraries.

PDoc uses [Treetop](http://treetop.rubyforge.org/), a Ruby-based DSL for text parsing and interpretation, and it's own, ActionView-inspired, ERB-based templating system for HTML generation. Other documentation generators (for example, for DocBook XML) are planned.

Contrary to other inline documentation parser, PDoc does not rely on the JavaScript source code at all: it only parses the comments. This does imply being slightly more verbose when documenting the source code, but makes for a consistent, readable documentation and avoids the usual issues encountered when documenting highly dynamic languages.

