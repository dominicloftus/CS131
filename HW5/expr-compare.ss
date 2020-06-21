
#lang racket
(provide (all-defined-out))

(define LAMBDA (string->symbol "\u03BB"))

(define (replace-lambda x y)
  (if(equal? x y)
     x
     LAMBDA))


(define (index vars var i)
  (if (null? vars)
      -1
      (if (equal? (car vars) var)
          i
          (index (cdr vars) var (+ i 1)))))

;tried to implement shadowed lambda variables but couldn't figure it out
#|(define (fix-lists vars bound-vars nvars nbound-vars)
  (if (null? vars)
      '()
      (if (member (car vars) nvars)
          (let (ind (index nvars (car vars) 0))
            (cons (list-ref nbound-vars ind) (fix-lists (cdr vars) (cdr bound-vars) nvars nbound-vars)))
          (cons (car bound-vars) (fix-lists (cdr vars) (cdr bound-vars) nvars nbound-vars)))))

(define (append-no-repeat vars nvars)
  (if (null? nvars)
      vars
      (if (member (car nvars) vars)
          (append-no-repeat vars (cdr nvars))

(define (check-bind bound-vars vars var)
  (let (ind (index vars var 0)
  

(define (bind-body body bound-vars vars)
  (if (null? body)
      '()
  (if (equal? (car body) 'quote)
      (cons (car body) (bind-body (cdr body) |#

(define (bind-vars xvars yvars)
  (if (null? xvars)
      '()
      (if (equal? (car xvars) (car yvars))
          (cons (car xvars) (bind-vars (cdr xvars) (cdr yvars)))
          (cons (string->symbol (string-append (symbol->string (car xvars)) "!"
                                               (symbol->string (car yvars))))
                (bind-vars (cdr xvars) (cdr yvars))))))

(define (check-bind body boundvars vars)
  (let ([ind (index vars body 0)])
    (if (equal? ind -1)
        body
        (list-ref boundvars ind))))

(define (bind-body body boundvars vars)
  (if (and (list? body) (not (null? body)))
      (if (equal? (car body) 'quote)
          (cons (car body) (bind-body (cdr body) boundvars vars))
          (cons (bind-body (car body) boundvars vars) (bind-body (cdr body) boundvars vars)))
      (check-bind body boundvars vars)))

  
  

(define (lambda-check x y)
  (if (or (not (equal? (length x) 3)) (not (equal? (length y) 3)))
      (list 'if '% x y)
      (let ([lamb (replace-lambda (car x) (car y))]
            [xvars (cadr x)][yvars (cadr y)]
            [xbody (caddr x)][ybody (caddr y)])
        (if (not (equal? (length xvars) (length yvars)))
            (list 'if '% x y)
            (let ([boundvars (bind-vars xvars yvars)])
              (let ([bindx (bind-body xbody boundvars xvars)][bindy (bind-body ybody boundvars yvars)])
                (list lamb boundvars (expr-compare bindx bindy))))))))
          
      

(define (basic-check x y)
  (cond
    [(equal? x y)
     x]
    [(and (equal? x #t) (equal? y #f))
     '%]
    [(and (equal? x #f) (equal? y #t))
     '(not %)]
    [else
     (list 'if '% x y)]))

(define (standard-filter x y)
  (if (null? x)
      '()
      (cons (expr-compare (car x) (car y)) (standard-filter (cdr x) (cdr y)))))

(define (expr-compare x y)
  (cond
    [(and (list? x) (list? y) (not (null? x)) (not (null? y)) (equal? (length x) (length y)))
     (cond
       [(equal? (car x) (car y))
        (cond
          [(equal? (car x) 'quote)
           (basic-check x y)]
          [(or (equal? (car x) 'lambda) (equal? (car x) LAMBDA))
           (lambda-check x y)]
          [else
           (standard-filter x y)])]
       [(or (equal? (car x) 'quote) (equal? (car y) 'quote)
            (equal? (car x) 'if) (equal? (car y) 'if))
        (basic-check x y)]
       [(or (and (equal? (car x) 'lambda) (equal? (car y) LAMBDA))
            (and (equal? (car y) 'lambda) (equal? (car x) LAMBDA)))
        (lambda-check x y)]
       [(or (equal? (car x) 'lambda) (equal? (car y) LAMBDA)
            (equal? (car y) 'lambda) (equal? (car x) LAMBDA))
        (basic-check x y)]
       [else
        (standard-filter x y)])]
    [else
     (basic-check x y)]))

(define ns (make-base-namespace))
(define (test-expr-compare x y)
  (and (equal? (eval x ns) (eval (list 'let '((% #t)) (expr-compare x y)) ns))
       (equal? (eval y ns) (eval (list 'let '((% #f)) (expr-compare x y)) ns))))

(define test-expr-x '(+ 3 ((lambda (a b) (if #t (+ b a) (+ a b))) '1 2)))
(define test-expr-y '(* 2 ((λ (a c) (if #f (+ c a) (+ a c))) 1 '2)))

;(test-expr-compare test-expr-x test-expr-y)



