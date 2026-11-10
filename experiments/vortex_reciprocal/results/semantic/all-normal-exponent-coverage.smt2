; benchmark generated from python API
(set-info :status unknown)
(declare-fun x () (_ BitVec 32))
(assert
 (let ((?x6 ((_ extract 30 23) x)))
 (and (distinct ?x6 (_ bv0 8)) true)))
(assert
 (let ((?x6 ((_ extract 30 23) x)))
 (and (distinct ?x6 (_ bv255 8)) true)))
(assert
 (let ((?x6 ((_ extract 30 23) x)))
(let (($x3389 (= ?x6 (_ bv254 8))))
(not (or (and (bvuge ?x6 (_ bv1 8)) (bvule ?x6 (_ bv252 8))) (= ?x6 (_ bv253 8)) $x3389)))))
(check-sat)
