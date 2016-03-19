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

  nmme_files = systemfunc("ls prlr_day_CanCM3*.nc4")
  nmme_f = addfiles(nmme_files,"r")
  ListSetType(nmme_f,"join")


  ; ***********************************************
  ; READ IN A SINGLE FILE
  ; ***********************************************

  ; nmme_f = addfile("ls prlr_day_CanCM3*.nc4","r")

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

  precip = nmme_f[:]->prlr*1000*86400				; extract precipitation into new variable -> input was m/s, output is mm/day
  print("variable dimensions")
  print(dimsizes(precip))

  ; num_precip = num(precip)					; finds out the number of total values in all 12 model runs
  ; max_precip = max(precip)					; finds the smallest value in any of the 12 model runs

  ; since we used join command above, the dimensions of precip should be (number files,ndays,nlat,nlon)

  ; ***********************************************
  ; CREATE US-SUBSET OF THE GLOBAL DATA
  ; ***********************************************

  ; let's choose latitudes of 
  latind = (/20,51/)						; latind is a variable

  ; let's choose longitudes of 
  lonind = (/230,306/)						; lonind is a variable

  lti = ind_nearest_coord(latind,lat,0)				; lti, lni = variables, ind_nearest_coord = pre-defined functions to determine the indices of locations closest to the coordinate array, needed later to define precip_subdomain_4D
  lni = ind_nearest_coord(lonind,lon,0)

  lat_subdomain = lat(lti(0):lti(1))
  lon_subdomain = lon(lni(0):lni(1))

  precip_subdomain_4D = precip(:,:,lti(0):lti(1),lni(0):lni(1))	; define the subdomain based on latind and lonind

  ; print(lat_subdomain_4D) 					; displays the latitudes of the chosen area
  ; print(lon_subdomain_4D) 					; displays the longitudes of the chosen area

  print(dimsizes(precip_subdomain_4D)) 				; prints all lats and lons of the subset 

  day = nmme_f[0]->time
  ensemble_member = ispan(1,10,1)				; there are 12 ensemble members


  ; ***********************************************
  ; WRITE THE SUBSET INTO NEW netCDF FILE
  ; ***********************************************

    years = 1981						; initiation year for filename, could be a loop
    month = 01							; initiation month for filename, could be a loop

    x = (/years,100/)
    y = product(x)
    z = (/y,month/)
    init = sum(z)						; filename element in YYYYMM format to indicate initiation month

    netCDF1 = True						; Output format is NetCDF

  if (netCDF1) then
    diro = "./"							; output directory is same as input directory

    filename = "CanCM3_pr_"+init+".nc"				; output filename for subset using YYYYMM element
    filo = filename

  end if


  setfileoption("nc","Format","LargeFile")

  if (netCDF1) then
    system("/bin/rm -f "+diro+filo)				; removes old files with the same name if they are present
    ncdf = addfile(diro+filo,"c")

    setfileoption(ncdf,"DefineMode",True)

    ; create attributes
    fAtt = True
    fAtt@title = "CanCM3 data for the Contiguous U.S., initiated: "+init
    fAtt@source = "National Multi-Model Ensemble - put a citation here!"
    fAtt@Conventions = "None"
    ;fAtt@creation_date = systemfunc("date")

    fileattdef(ncdf,fAtt)

    dimNames = (/"year","ensemble_member","day","lat","lon"/)
    dimSizes = (/-1,10,dimsizes(day),dimsizes(lat_subdomain),dimsizes(lon_subdomain)/)	; CanCM3 has only 10 model runs (GFDL has 12)
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

end
