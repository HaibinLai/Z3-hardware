; benchmark generated from python API
(set-info :status unknown)
(declare-fun s () (_ FloatingPoint 8 24))
(assert
 (fp.geq s (fp #b0 #x61 #b00000000000000000000000)))
(assert
 (fp.leq s (fp #b0 #x67 #b00000000000000000000000)))
(assert
 (let ((?x13 (fp.add roundNearestTiesToEven (fp #b0 #x7f #b00000000000000000000000) s)))
(let ((?x17 (fp.div roundNearestTiesToEven (fp.neg s) ?x13)))
(not (fp.lt ?x17 (_ +zero 8 24))))))
(check-sat)
