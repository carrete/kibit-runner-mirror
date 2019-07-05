(ns kibit-runner.utils-test
  (:require [clojure.string :as string]
            [clojure.test :refer :all]
            [clojure.test.check :as test-check]
            [clojure.test.check.generators :as gen]
            [clojure.test.check.properties :as prop :include-macros true]
            [kibit-runner.utils :as utils]))

(deftest test-parse-paths
  (is (= (utils/parse-paths nil) [])))

(def check-parse-paths
  (prop/for-all [paths (gen/not-empty (gen/vector gen/string-alphanumeric))]
                (= (map #(.getName %) (utils/parse-paths (string/join "," paths))) paths)))

(test-check/quick-check 100 check-parse-paths)
