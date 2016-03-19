q    = random_uniform(-20,100,(/3,5,10/))	; Create a variable (q) of size (3,5,10) array
qAvg = dim_avg_n(q, 2)				; calculate the avg of the leftmost (q, 0), middle (q, 1), or rightmost (q, 2) dimension of the array
n = num(qAvg)
min_q = min(qAvg)
; print(q)
print(qAvg)
print(n)
print(min_q)
