;; Checking that composition distributes over multiplication...
(define f (literal-function 'f))
(define g (literal-function 'g))
(define h (literal-function 'h))

;; looks good! These are the same expression.
((compose (* f g) h) 't)
((* (compose f h) (compose g h)) 't)

;; This is the general form of a path transformation; big surprise, this is very
;; close to the code on page 46. I'm going to keep my version, since I don't
;; want to get too confused, here.
(define ((F->C F) local)
  (let ((t (time local))
        (x (coordinate local))
        (v (velocity local)))
    (up t
        (F t x)
        (+ (((partial 0) F) t x)
           (* (((partial 1) F) t x)
              v)))))

;; here's a literal function we can play with.
(define F*
  (literal-function 'F (-> (X Real Real) Real)))

;; okay, boom, this is the literal function.
(define q-prime
  (literal-function 'q-prime))

;; this is the manual generation of q from q-prime.
(define ((to-q F) qp)
  (lambda (t) (F t (qp t))))

;; We can check that these are now equal. This uses C to get us to q
((compose (F->C F*) (Gamma q-prime)) 't)

;; And this does it by passing in q manually.
((Gamma ((to-q F*) q-prime)) 't)

;; I can convert the proof to code, no problem, by showing that these sides are
;; equal.



;; YES!! the final step of my proof was the note that these are equal. THIS IS
;; HUGE!!!
((compose (lambda (x) (ref x 1)) ((partial 1) (F->C F*)) (Gamma q-prime)) 't)
((compose (lambda (x) (ref x 2)) ((partial 2) (F->C F*)) (Gamma q-prime)) 't)

;; Just for fun, note that this successfully pushes things inside gamma.
(let ((L (literal-function 'L (-> (UP Real Real Real) Real)))
      (C (F->C F*)))
  ((Gamma ((to-q ((partial 1) F*)) q-prime)) 't))

(define (p->r t polar-tuple)
  (let* ((r (ref polar-tuple 0))
         (phi (ref polar-tuple 1))
         (x (* r (cos phi)))
         (y (* r (sin phi))))
    (up x y)))

(literal-function 'q-prime (-> Real (UP Real Real)))((Gamma ((to-q p->r) )) 't)

;; trying again. get a function:
(define q
  ;; time to x y.
  (literal-function 'q (-> Real (UP Real Real))))

(define (C local)
  (up (time local)
     (square (coordinate local))
     (velocity local)))

((compose C (Gamma q)) 't)
#|
(up t (up (q^0 t) (q^1 t)) (up ((D q^0) t) ((D q^1) t)))
|#
