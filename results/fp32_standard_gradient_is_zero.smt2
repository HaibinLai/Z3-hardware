; benchmark generated from python API
(set-info :status unknown)
(declare-fun s () (_ FloatingPoint 8 24))
(assert
 (fp.geq s (fp #b0 #x61 #b00000000000000000000000)))
(assert
 (fp.leq s (fp #b0 #x67 #b00000000000000000000000)))
(assert
 (let ((?x13 (fp.add roundNearestTiesToEven (fp #b0 #x7f #b00000000000000000000000) s)))
(let ((?x14 (fp.div roundNearestTiesToEven (fp #b0 #x7f #b00000000000000000000000) ?x13)))
(let ((?x15 (fp.sub roundNearestTiesToEven ?x14 (fp #b0 #x7f #b00000000000000000000000))))
(not (fp.eq ?x15 (_ +zero 8 24)))))))
(check-sat)
