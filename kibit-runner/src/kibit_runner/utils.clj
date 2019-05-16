(ns kibit-runner.utils
  (:require [clojure.java.io :as java-io]
            [clojure.string :as string]))

(defn parse-paths
  [paths]
  (map java-io/file (string/split paths #",")))

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
