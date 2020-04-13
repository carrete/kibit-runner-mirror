(ns kibit-runner.cmdline
  (:gen-class)
  (:require
    [clojure.tools.cli :as tools-cli]
    #_[foobar.unused :as unused]
    [kibit-runner.utils :refer [exit parse-paths printseq validate-paths]]
    [kibit.driver :as kibit]))

(set! *warn-on-reflection* true)

#_(+ 1 1)

(def cli-options
  [["-p" "--paths PATH1,PATH2,..." "File or directory paths to be scanned (default is: .)"
    :default (parse-paths ".")
    :parse-fn parse-paths
    :validate [validate-paths "Paths must exist"]]
   ["-h" "--help"]])

(defn -main
  [& args]
  (let [{:keys [options arguments summary errors]} (tools-cli/parse-opts args cli-options)]
    (cond
      (:help options)
      (do
        (println summary)
        (exit 0))
      errors
      (do
        (printseq (into errors [summary]))
        (exit 1)))
    (apply (partial kibit/external-run (:paths options) nil) arguments)))
