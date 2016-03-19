; Program to read and subset input dataset and save in a new file - Thanks to Esther!!

; ---------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; ---------------------------------------------------


begin

  ; ***********************************************
  ; READ IN MULTIPLE FILES 
  ; ***********************************************

  ; nmme_files = systemfunc("ls Toni_output_data_*.nc")
  ; precip = addfiles(nmme_files,"r")
  ; ListSetType(precip_subdomain_4D,"join")
  ; lat = precip[0]->lat
  ; lon = precip[0]->lon


  ; ***********************************************
  ; READ IN A SINGLE FILE
  ; ***********************************************

  precip = addfile("Toni_output_data_198001.nc","r")

  lat = precip->lat
  lon = precip->lon
  precip_subdomain_4D = precip->precipitation			; reading in precipitation array for all 4 dimensions (runs, days, lat, lon)
  ; precip_jan_01 = precip_subdomain_4D->precipitation(:,0,:,:)	; example: reading in precipitation array for Jan 1 for every run, lat, and lon

  ; print("lat:")
  ; print(lat)
  ; print("lon:")
  ; print(lon)
  ; printVarSummary(precip)

  lat!0 = "lat"				; Esther's suggestion
  lat&lat = lat				; to fix the code,
  lat@units = "degrees_north"		; but it doesn't seem
  lat@long_name = "latitude"		; to work though. :-(

  lon!0 = "lon"
  lon&lon = lon
  lon@units = "degrees_east"
  lon@long_name = "longitude"

  ; latind = (/20,51/)
  ; lonind = (/230,306/)
  ; lti = ind_nearest_coord(latind,lat,0)			; lti, lni = variables, ind_nearest_coord = pre-defined functions to determine the indices of locations closest to the coordinate array, needed later to define precip_subdomain_4D
  ; lni = ind_nearest_coord(lonind,lon,0)
  ; lat_subdomain = lat(lti(0):lti(1))
  ; lon_subdomain = lon(lni(0):lni(1))

  ; ***********************************************
  ; REDUCE 4D ARRAY TO PLOTTABLE 2D ARRAY
  ; ***********************************************

  ; print(dimsizes(precip_subdomain_4D)) 			; prints all lats and lons of the subset 
  printVarSummary(precip_subdomain_4D)				; print summary of subdomain precip: var name, type, byte size, # of values, dimensions (x,y,z,temp)
  print("dimsizes(precip_subdomain_4D)")
  print(dimsizes(precip_subdomain_4D))

  precip_subdomain_3D = dim_avg_n(precip_subdomain_4D,0)	; averaging all 12 model runs into one run for every day, lat, and lon, creating 3D array
  precip_subdomain_2D = dim_avg_n(precip_subdomain_3D,0)	; averaging all daily precipitation values into one annual average for every lat and lon, creating 2D array, needed to plot single map

  printVarSummary(precip_subdomain_2D)				; print size (byte, values) and dimensions (x, y, z)
  ; print(precip_subdomain_4D)					; prints *ALL* precip values for the subset, about 5 million lines total!!!
  ; print(precip_subdomain_4D(:,:,:,:))				; array subscripting for all subset lats and lons for 1980, all 12 model runs


  ; ***********************************************
  ; CREATE MAP
  ; ***********************************************

  ; Define boundaries for map
    precip_subdomain_2D!0 = "lat"				; latitude information come from variable lat_subdomain
    precip_subdomain_2D&lat = lat				; DEBUGGED: changed this from "precip_subdomain_2D&lat_subdomain = lat"
    precip_subdomain_2D!1 = "lon"				; longitude information come from variable lon_subdomain
    precip_subdomain_2D&lon = lon				; DEBUGGED: changed this from "precip_subdomain_2D&lon_subdomain = lon"
    precip_subdomain_2D@long_name = "Precipitation"		; map subtitle, printed on the top left
    precip_subdomain_2D@units = "mm/day"			; map units, printed on the top right
  printVarSummary(precip_subdomain_2D)

  wks = gsn_open_wks("png","GFDL_1980_US")			; map name and file type
  cmap = read_colormap_file("BlueDarkRed18")

  res                      = True				; plot mods desired
  res@tiMainString         = "1980 GFDL-Hindcast"			; main title
  res@cnFillOn             = True				; turn on color fill, works with gsn_csm_map() function 3 lines down
  res@gsnAddCyclic         = False
  res@cnLinesOn            = False				; contour lines of the map fill on or off  
  res@mpProjection         = "Mercator"				; Mercator map projection
  res@cnFillPalette        = cmap(::-1,:)				; reverse color map

  res@mpLimitMode    = "LatLon"					; define plotted area by lats and lons, namely those of the selection (20-50N, 230-300E)
  res@mpMaxLatF      = 50
  res@mpMinLatF      = 20
  ; res@mpCenterLatF = 35					; define center latitude, only use with res@mpPrjection is conical equidistant
  res@mpMaxLonF      = 305
  res@mpMinLonF      = 230
  ; res@mpCenterLonF = 265					; define center longitude, only use with res@mpPrjection is conical equidistant

  res@mpOutlineBoundarySets = "GeophysicalAndUSStates"		; lines and boundaries of USA and US States
  res@mpGeophysicalLineThicknessF = 2				; thickness of the USA lines
  res@mpUSStateLineThicknessF     = 2				; thickness of the state lines

  ; res@mpSpecifiedFillColors  = (/0,100/)			; fill with background color, works with gsn_map() 2 lines down

  ; ***********************************************
  ; PLOT MAP
  ; ***********************************************

  ; plot = gsn_csm_contour_map_ce(wks,precip_subdomain_2D, res)	; conical equidistant projection, if used take out res@mpProjection line 
  plot = gsn_csm_contour_map(wks,precip_subdomain_2D, res)	; universal map projection, define in res@mpProjection


end
