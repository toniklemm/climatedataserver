load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl" 

begin 
	data = asciiread("ASCII_data.asc", (/12,2/), "integer") ;-- read ASCII data to 2D array variable data 
	x = data(:,0) ;-- get all data from column 1
	y = data(:,1) ;-- get all data from column 2 

	res = true
	wks = gsn_open_wks("png", "part_I") 	 ; res = True ; create plot resource object 

;	res@tiMainString = "counts per day" ;-- draw a title on top of plot 

	plot = gsn_csm_xy(wks, x, y, res)
end 

