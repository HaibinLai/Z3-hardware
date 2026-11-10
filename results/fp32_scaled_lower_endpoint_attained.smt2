; benchmark generated from python API
(set-info :status unknown)
(declare-fun s_bits () (_ BitVec 32))
(assert
 (let ((?x6055 ((_ extract 31 31) s_bits)))
 (= ?x6055 (_ bv0 1))))
(assert
 (let ((?x7302 ((_ extract 30 23) s_bits)))
 (bvuge ?x7302 (_ bv97 8))))
(assert
 (let ((?x7302 ((_ extract 30 23) s_bits)))
 (bvule ?x7302 (_ bv103 8))))
(assert
 (let ((?x2297 ((_ extract 22 0) s_bits)))
 (let (($x5474 (= ?x2297 (_ bv0 23))))
 (=> (= (_ bv103 8) ((_ extract 30 23) s_bits)) $x5474))))
(assert
 (let ((?x5489 (bvshl ((_ zero_extend 40) (concat (_ bv1 1) ((_ extract 22 0) s_bits))) (bvsub ((_ zero_extend 56) ((_ extract 30 23) s_bits)) (_ bv97 64)))))
(= (_ bv8388608 64) ?x5489)))
(check-sat)
