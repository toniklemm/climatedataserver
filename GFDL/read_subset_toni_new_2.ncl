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

  nmme_files = systemfunc("ls pr_day_GFDL*.nc")
  nmme_f = addfiles(nmme_files,"r")
  ListSetType(nmme_f,"join")


  ; ***********************************************
  ; READ IN A SINGLE FILE
  ; ***********************************************

  ; nmme_f = addfile("ls pr_day_GFDL*.nc","r")

  lat = nmme_f[0]->lat
  lon = nmme_f[0]->lon 

  ; ***********************************************
  ; PRINT THE DIMENSIONS OF THE READ-IN FILE
  ; ***********************************************

  print("the dimensions of latitude are:")
  print(dimsizes(lat))
  print("the dimensions of longitude are:")
  print(dimsizes(lon))
  printMinMax(lon,True) 					; prints the minimum and maximum longitude (0.3125 ... 359.6875)
  ; print(lat) 							; prints all 360 latitude entries


  ; ***********************************************
  ; READ IN THE VARIABLE (precipitation)
  ; ***********************************************

  precip = nmme_f[:]->pr*3600*24 				; extract precipitation into new variable -> output is mm/day
  print("variable dimensions")
  print(dimsizes(precip))

  ; num_precip = num(precip)					; finds out the number of total values in all 12 model runs
  ; max_precip = max(precip)					; finds the smallest value in any of the 12 model runs
  ; print("The total number of values in the 12 1980 GFDL model runs are:")
  ; print(num_precip)
  ; print("Largest number in the GFDL 1980 files:")
  ; print(max_precip)

  ; since we used join command above, the dimensions of precip should be (number files,ndays,nlat,nlon)

  ; ***********************************************
  ; CREATE US-SUBSET OF THE GLOBAL DATA
  ; ***********************************************

  ; let's choose latitudes of 
    latind = (/20,51/)						; latind is a variable

  ; let's choose longitudes of 
    lonind = (/230,306/)					; lonind is a variable

  lti = ind_nearest_coord(latind,lat,0)				; lti, lni = variables, ind_nearest_coord = pre-defined functions to determine the indices of locations closest to the coordinate array, needed later to define precip_subdomain_4D
  lni = ind_nearest_coord(lonind,lon,0)

  lat_subdomain = lat(lti(0):lti(1))
  lon_subdomain = lon(lni(0):lni(1))

  precip_subdomain_4D = precip(:,:,lti(0):lti(1),lni(0):lni(1))	; define the subdomain based on latind and lonind

  ; print(lat_subdomain_4D) 					; displays the latitudes of the chosen area
  ; print(lon_subdomain_4D) 					; displays the longitudes of the chosen area

  ; print(dimsizes(precip_subdomain_4D)) 			; prints all lats and lons of the subset 

  day = nmme_f[0]->time
  ensemble_member = ispan(1,12,1)				; there are 12 ensemble members


  ; ***********************************************
  ; WRITE THE SUBSET INTO NEW netCDF FILE
  ; ***********************************************

    years = 1980
    month = 01

    x = (/years,100/)						; create filename in YYYYMM format for initiation month
    y = product(x)
    z = (/y,month/)
    init = sum(z)

    netCDF1 = True						; Output format is NetCDF

  if (netCDF1) then
    diro = "./"							; output directory is same as input directory

    filename = "Toni_output_data_"+init+".nc"			; output filename for subset using YYYYMM element
    filo = filename

  end if


  setfileoption("nc","Format","LargeFile")

  if (netCDF1) then
    system("/bin/rm -f "+diro+filo)				; removes old files with the same name if they are present
    ncdf = addfile(diro+filo,"c")

    setfileoption(ncdf,"DefineMode",True)

    ; create attributes
    fAtt = True
    fAtt@title = "GFDL FLOR-B01 data for the Contiguous U.S., "+init
    fAtt@source = "National Multi-Model Ensemble - put a citation here!"
    fAtt@Conventions = "None"
    ;fAtt@creation_date = systemfunc("date")

    fileattdef(ncdf,fAtt)

    dimNames = (/"year","ensemble_member","day","lat","lon"/)
    dimSizes = (/-1,12,dimsizes(day),dimsizes(lat_subdomain),dimsizes(lon_subdomain)/)
    dimUnlim = (/True,False,False,False,False/)

    filedimdef(ncdf,dimNames,dimSizes,dimUnlim)

    filevardef(ncdf,"year",typeof(years),(/"year"/))
    filevardef(ncdf,"lat",typeof(lat_subdomain),(/"lat"/))
    filevardef(ncdf,"lon",typeof(lon_subdomain),(/"lon"/))
    filevardef(ncdf,"day",typeof(day),(/"day"/))
    filevardef(ncdf,"ensemble_member",typeof(ensemble_member),(/"ensemble_member"/))

    ; get attributes of our variable
    filevardef(ncdf,"precipitation",typeof(precip_subdomain_4D),(/"ensemble_member","day","lat","lon"/))

    ;now write all the variables to the file

    ncdf->year = (/years/)
    ncdf->ensemble_member = (/ensemble_member/)
    ncdf->day = (/day/)
    ncdf->lat = (/lat_subdomain/)
    ncdf->lon = (/lon_subdomain/)

    ncdf->precipitation = (/precip_subdomain_4D/)

  end if


  ; ***********************************************
  ; REDUCE 4D ARRAY TO PLOTTABLE 2D ARRAY
  ; ***********************************************

  ; print(dimsizes(precip_subdomain_4D)) 			; prints all lats and lons of the subset 
  printVarSummary(precip_subdomain_4D)				; print summary of subdomain precip: var name, type, byte size, # of values, dimensions (x,y,z,temp)

  precip_subdomain_3D = dim_avg_n(precip_subdomain_4D, 0)	; averaging all 12 model runs into one run for every day, lat, and lon, creating 3D array
  precip_subdomain_2D = dim_avg_n(precip_subdomain_3D, 0)	; averaging all daily precipitation values into one annual average for every lat and lon, creating 2D array, needed to plot single map

  printVarSummary(precip_subdomain_2D)				; print size (byte, values) and dimensions (x, y, z)
  ; print(precip_subdomain_4D)					; prints *ALL* precip values for the subset, about 5 million lines total!!!
  ; print(precip_subdomain_4D(:,:,:,:))				; array subscripting for all subset lats and lons for 1980, all 12 model runs


  ; ***********************************************
  ; CREATE MAP
  ; ***********************************************

  ; Define boundaries for map
  precip_subdomain_2D!0 = "lat_subdomain"			; latitude information come from variable lat_subdomain
  precip_subdomain_2D&lat_subdomain = lat_subdomain
  precip_subdomain_2D!1 = "lon_subdomain"			; longitude information come from variable lon_subdomain
  precip_subdomain_2D&lon_subdomain = lon_subdomain
  precip_subdomain_2D@long_name = "Precipitation"		; map subtitle, printed on the top left
  precip_subdomain_2D@units = "mm/day"				; map units, printed on the top right

  wks = gsn_open_wks("png","GFDL_1980_US")			; map name and file type
  cmap = read_colormap_file("BlueDarkRed18")

  res                      = True				; plot mods desired
  res@tiMainString         = "1980 GFDL-Hindcast"		; main title
  res@cnFillOn             = True				; turn on color fill, works with gsn_csm_map() function 3 lines down
  res@gsnAddCyclic         = False
  res@cnLinesOn            = False				; contour lines of the map fill on or off  
  res@mpProjection         = "Mercator"				; Mercator map projection
  res@cnFillPalette        = cmap(::-1,:)			; reverse color map

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

  ; plot = gsn_csm_contour_map_ce(wks,precip_subdomain_2D, res)		; conical equidistant projection, if used take out res@mpProjection line 
  plot = gsn_csm_contour_map(wks,precip_subdomain_2D, res)		; universal map projection, define in res@mpProjection


end
