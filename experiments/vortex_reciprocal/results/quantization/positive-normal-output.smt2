; benchmark generated from python API
(set-info :status unknown)
(declare-fun output_value () Real)
(assert
 (<= (/ 1.0 85070591730234615865843651857942052864.0) output_value))
(assert
 (let ((?x25 (* 340282285791300048856692911642763067392.0 output_value)))
(let ((?x27 (- ?x25 1.0)))
(>= (/ 9.0 100000000.0) (ite (< ?x27 0.0) (- 1.0 ?x25) ?x27)))))
(check-sat)
