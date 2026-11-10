; benchmark generated from python API
(set-info :status unknown)
(declare-fun subnormal_significand () Int)
(assert
 (>= subnormal_significand 0))
(assert
 (< subnormal_significand 8388608))
(assert
 (let ((?x8 (* 16777212 subnormal_significand)))
(let ((?x10 (- ?x8 35184372088832)))
(<= (* (ite (< ?x10 0) (- ?x10) ?x10) 100000000) 316659348799488))))
(check-sat)
