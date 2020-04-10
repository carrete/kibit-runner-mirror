(ns kibit-runner.utils
  (:require
    [clojure.data.csv :as csv]
    [clojure.java.io :as java-io]
    [clojure.spec.alpha :as spec])
  (:import
    java.io.File))

(defn parse-paths
  [paths]
  (if paths
    (let [split-paths (or (first (csv/read-csv paths)) [""])]
      (map java-io/file split-paths))
    []))

(spec/fdef parse-paths
           :args (spec/cat :paths string?)
           :ret (spec/coll-of #(instance? File %) :kind seq? :min-count 0))

(defn validate-paths
  [paths]
  (every? true? (for [path paths] (.exists path))))

(defn fseq
  [f seq]
  (doseq [x seq]
    (f x)))

(def printseq (partial fseq println))

(defn exit
  [rc]
  (System/exit rc))
