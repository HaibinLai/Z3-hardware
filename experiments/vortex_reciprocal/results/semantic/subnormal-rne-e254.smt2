; benchmark generated from python API
(set-info :status unknown)
(declare-fun pack_read_0 () (_ BitVec 32))
(declare-fun raw () (_ BitVec 32))
(declare-fun pack_read_1 () (_ BitVec 8))
(declare-fun e () (_ BitVec 8))
(declare-fun pack_read_3 () (_ BitVec 1))
(declare-fun sg () Bool)
(declare-fun pack_read_5 () (_ BitVec 1))
(declare-fun inf () Bool)
(declare-fun pack_read_2 () (_ BitVec 1))
(declare-fun zero () Bool)
(declare-fun pack_read_4 () (_ BitVec 1))
(declare-fun nan () Bool)
(declare-fun packed_h () (_ BitVec 32))
(assert
 (= raw pack_read_0))
(assert
 (= e pack_read_1))
(assert
 (= sg (= ((_ extract 0 0) pack_read_3) (_ bv1 1))))
(assert
 (let (($x12027 (= ((_ extract 0 0) pack_read_5) (_ bv1 1))))
 (= inf $x12027)))
(assert
 (let (($x60096 (= ((_ extract 0 0) pack_read_2) (_ bv1 1))))
 (= zero $x60096)))
(assert
 (let (($x55745 (= ((_ extract 0 0) pack_read_4) (_ bv1 1))))
 (= nan $x55745)))
(assert
 (let ((?x60420 (concat (_ bv0 23) ((_ extract 7 7) (bvsub (concat ((_ extract 30 0) pack_read_0) (_ bv0 1)) (_ bv2147483648 32))))))
 (let ((?x56340 (bvadd ((_ extract 31 8) (bvsub (concat ((_ extract 30 0) pack_read_0) (_ bv0 1)) (_ bv2147483648 32))) ?x60420)))
 (let (($x50313 (= ((_ extract 23 23) ?x56340) (_ bv1 1))))
 (let ((?x61225 (bvsub (_ bv253 8) pack_read_1)))
 (let ((?x52269 (concat (ite $x50313 (bvadd ?x61225 (_ bv1 8)) ?x61225) (ite $x50313 (_ bv0 23) ((_ extract 22 0) ?x56340)))))
 (let (($x5749 (= pack_read_1 (_ bv254 8))))
 (let ((?x54330 (ite $x5749 (concat (_ bv0 1) ((_ extract 31 9) pack_read_0)) ((_ extract 31 8) pack_read_0))))
 (let ((?x25765 (ite $x5749 (ite (and (distinct ((_ extract 7 0) pack_read_0) (_ bv0 8)) true) (_ bv1 1) (_ bv0 1)) (ite (and (distinct ((_ extract 6 0) pack_read_0) (_ bv0 7)) true) (_ bv1 1) (_ bv0 1)))))
 (let (($x51054 (or (or (= ((_ extract 0 0) ?x25765) (_ bv1 1)) false (= ((_ extract 0 0) ?x54330) (_ bv1 1)) false) false)))
 (let (($x15446 (= ((_ extract 0 0) (ite $x5749 ((_ extract 8 8) pack_read_0) ((_ extract 7 7) pack_read_0))) (_ bv1 1))))
 (let ((?x52622 (bvadd (concat (_ bv0 1) ?x54330) (concat (_ bv0 24) (ite (and (or $x15446 false) $x51054) (_ bv1 1) (_ bv0 1))))))
 (let (($x60096 (= ((_ extract 0 0) pack_read_2) (_ bv1 1))))
 (let ((?x99802 (ite $x60096 (_ bv0 31) (ite (bvuge pack_read_1 (_ bv253 8)) (concat (_ bv0 6) ?x52622) ?x52269))))
 (let (($x55745 (= ((_ extract 0 0) pack_read_4) (_ bv1 1))))
 (let (($x12027 (= ((_ extract 0 0) pack_read_5) (_ bv1 1))))
 (= packed_h (ite $x12027 (_ bv2139095039 32) (ite $x55745 (_ bv2143289344 32) (concat pack_read_3 ?x99802))))))))))))))))))))
(assert
 (not inf))
(assert
 (not zero))
(assert
 (not nan))
(assert
 (= e (_ bv254 8)))
(assert
 (let ((?x50054 ((_ zero_extend 33) ((_ extract 30 0) packed_h))))
(let ((?x23819 (bvshl ?x50054 (_ bv9 64))))
(let ((?x26179 ((_ zero_extend 32) raw)))
(let ((?x6997 (ite (bvuge ?x23819 ?x26179) (bvsub ?x23819 ?x26179) (bvsub ?x26179 ?x23819))))
(or (bvugt ?x6997 (_ bv256 64)) (and (= ?x6997 (_ bv256 64)) (and (distinct (bvand ?x50054 (_ bv1 64)) (_ bv0 64)) true)) (and (distinct (= ((_ extract 31 31) packed_h) (_ bv1 1)) sg) true) (= ((_ extract 30 23) packed_h) (_ bv255 8))))))))
(check-sat)
