
;
; Create example array
;
  a = (/ (/1,2,3/), (/4,5,6/), (/7,-999,9/)/)	; array with 3 rows and 3 columns
  a@_FillValue = -999				; defines -999 as missing values

;
; Compute average and the number of non-missing values
;
  average = avg(a)				; computes average of array a (only not-missing values)
  n = num(.not.ismissing(a))			; counts non-missing values
  print(average)				; print a scalar (average) numeric value 
  print(n)					; print number of non-missing values
; a_new = .not.missing(a)
  print(avg(a))					; print the average (again)
