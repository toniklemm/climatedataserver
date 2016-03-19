; Program to read and subset input dataset 

; ---------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; ---------------------------------------------------


begin

  ; READ IN MULTIPLE FILES 

  nmme_files = systemfunc("ls pr_day_GFDL*.nc")
  nmme_f = addfiles(nmme_files,"r")

  ListSetType(nmme_f,"join")

  ; READ IN A SINGLE FILE

  ;nmme_1 = addfile("./pr_day_GFDL-FLORB01_FLORB01-P1-ECDA-v3.1-011980_r10i1p1_19800101-19801231.nc","r")

  lat = nmme_f[0]->lat
  lon = nmme_f[0]->lon 


  ; PRINT THE DIMENSIONS OF THE READ-IN FILE

  print("the dimensions of latitude are:")
  print(dimsizes(lat))
  print("the dimensions of longitude are:")
  print(dimsizes(lon))
  printMinMax(lon,True) 			; prints the minimum and maximum longitude (0.3125 ... 359.6875)
  ; print(lat) 				; prints all 360 latitude entries


  ; READ IN THE VARIABLE (precipitation)

  precip = nmme_f[:]->pr*3600*24 		; the original precipitation is expressed as mm per second, we want mm per day --> output is mm/day
  print("variable dimensions")
  print(dimsizes(precip))

  num_precip = num(precip)                    ; finds out the number of total values in all 12 model runs
  max_precip = max(precip)                ; finds the smallest value in any of the 12 model runs
  print("The total number of values in the 12 1980 GFDL model runs are:")
  print(num_precip)
  print("Largest number in the GFDL 1980 files:")
  print(max_precip)
	
  ; since we used join command above, the dimensions of precip should be (number files,ndays,nlat,nlon)

  ; find a user-specified latitude and longitude 

  ; let's choose latitudes of 
    latind = (/20,50/)		; latind is a variable

  ; let's choose longitudes of 
    lonind = (/230,300/)	; lonind is a variable

  lti = ind_nearest_coord(latind,lat,0)		; lti, lni = variables, ind_nearest_coord is a predefined function to determine the indices of locations closest to the coordinate array, needed later to define precip_subdomain
  lni = ind_nearest_coord(lonind,lon,0)

  lat_subdomain = lat(lti(0):lti(1))
  lon_subdomain = lon(lni(0):lni(1))

  precip_subdomain = precip(:,:,lti(0):lti(1),lni(0):lni(1))	; define the subdomain based on latind and lonind

  print(lat_subdomain) 			; displays the latitudes of the chosen area
  print(lon_subdomain) 			; displays the longitudes of the chosen area

  print(dimsizes(precip_subdomain)) 		; prints all lats and lons of the subset 

  printVarSummary(precip_subdomain)		; print summary of subdomain precip: var name, type, byte size, # of values, dimensions (x,y,z,temp)

  precip_avg_3D = dim_avg_n(precip_subdomain, 0)			; calculate array with avg of precip of all 12 model runs for every day, lat, and lon

  precip_avg_2D = dim_avg_n(precip_avg_3D, 0)

  ; print(precip_avg_2D)					; 

  printVarSummary(precip_avg_2D)				; print size (byte, values) and dimensions (x, y, z)
 
  ; print(precip_subdomain) 		; prints *ALL* precip values for the subset, about 5 million lines total!!!

  ; print(precip_subdomain(:,:,:,:))	; array subscripting for all subset lats and lons for 1980, all 12 model runs
  ; print(precip_subdomain(:,:,:,:))
  ; print(precip_subdomain(:,:,:,:))
  ; create plot

  ; create attributes for precip_avg_2D
  precip_avg_2D!0 = "lat_subdomain"				; latitude information come from variable lat_subdomain
  precip_avg_2D&lat_subdomain = lat_subdomain
  precip_avg_2D!1 = "lon_subdomain"				; longitude information come from variable lon_subdomain
  precip_avg_2D&lon_subdomain = lon_subdomain
  precip_avg_2D@long_name = "ensemble precipitation"		; map name, printed on the top left
  precip_avg_2D@units = "mm"					; map units, printed on the top right


  ;************************************************
    wks = gsn_open_wks("png","color_0-100")				; create graphics, PNG file

   res                      = True				; plot mods desired
   res@tiMainString         = "Default Color"			; main title
   res@cnFillOn             = True				; turn on color fill, works with gsn_csm_map() function 3 lines down
   res@gsnAddCyclic         = False
   res@cnLinesOn            = False				; contour lines of the map fill on or off  
    
   res@mpLimitMode = "LatLon"					; define plotted area by lats and lons, namely those of the selection (20-50N, 230-300E)
   res@mpMaxLatF   = 50
   res@mpMinLatF   = 20
   res@mpMaxLonF   = 300
   res@mpMinLonF   = 230   

   res@mpOutlineBoundarySets = "GeophysicalAndUSStates"		; lines and boundaries of USA and US States
   res@mpGeophysicalLineThicknessF = 2				; thickness of the USA lines
   res@mpUSStateLineThicknessF     = 2				; thickness of the state lines

    ;res@mpSpecifiedFillColors  = (/0,100/)			; fill with background color, works with gsn_map() 2 lines down

  plot = gsn_csm_contour_map_ce(wks,precip_avg_2D, res)	; create map


end

