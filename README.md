# kibit-runner
[![Clojars Project](https://img.shields.io/clojars/v/tvaughan/kibit-runner.svg)](https://clojars.org/tvaughan/kibit-runner)

Quick Start
---

Add:

    :kibit {:extra-deps {tvaughan/kibit-runner {:mvn/version "VERSION"}}
            :main-opts ["-m" "kibit-runner.cmdline"]}

to `:aliases` in `deps.edn`. Use the latest version on Clojars indicated above
in place of `VERSION`.

Run:

    clojure -A:kibit

This will run [kibit](https://github.com/jonase/kibit) over the current
working directory and all of its sub-directories.

To specify one or more different directories, run:

    clojure -A:kibit --paths src,test,resources,some/other/path

To pass options to kibit, add `--` to the end of the command-line and then add
options to kibit. Like:

    clojure -A:kibit -- --reporter markdown

Or:

    clojure -A:kibit --paths src,test -- --replace --interactive

Caveat Emptor
---

I came across https://github.com/jonase/kibit/issues/221 as I was replacing
leiningen with deps.edn and the clojure command-line tools in
[gitlab-api](https://gitlab.com/tvaughan/gitlab-api). While this library
appears to do the trick, it would be better to incorporate it into kibit
itself. Fingers crossed, this library will disappear someday.
