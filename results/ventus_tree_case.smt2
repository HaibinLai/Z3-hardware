; benchmark generated from python API
(set-info :status unknown)
(assert
 (let ((?x11 (fp.mul roundNearestTiesToEven (fp #b1 #x97 #b00000000000000000000000) (fp #b0 #x7f #b00000000000000000000000))))
(let ((?x9 (fp.mul roundNearestTiesToEven (fp #b0 #x7f #b00000000000000000000000) (fp #b0 #x7f #b00000000000000000000000))))
(let ((?x8 (fp.mul roundNearestTiesToEven (fp #b0 #x97 #b00000000000000000000000) (fp #b0 #x7f #b00000000000000000000000))))
(let ((?x14 (fp.add roundNearestTiesToEven (fp.add roundNearestTiesToEven ?x8 ?x9) (fp.add roundNearestTiesToEven ?x9 ?x11))))
(let ((?x16 (fp.add roundNearestTiesToEven ?x14 (_ +zero 8 24))))
(not (fp.eq ?x16 (fp #b0 #x7f #b00000000000000000000000)))))))))
(check-sat)
