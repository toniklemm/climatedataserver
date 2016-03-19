; Program to read and subset input dataset 

; ---------------------------------------------------

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

; ---------------------------------------------------

begin

; if multiple files 
nmme_files = systemfunc("ls pr_day_GFDL*.nc")
nmme_f = addfiles(nmme_files,"r")
ListSetType(nmme_f,"join")

; if single file 
;nmme_1 = addfile("./pr_day_GFDL-FLORB01_FLORB01-P1-ECDA-v3.1-011980_r10i1p1_19800101-19801231.nc","r")

lat = nmme_f[0]->lat
lon = nmme_f[0]->lon 

print("the dimensions of latitude are:")
print(dimsizes(lat))
print("the dimensions of longitude are:")
print(dimsizes(lon))
printMinMax(lon,True) ; prints the minimum and maximum longitude (0.3125 ... 359.6875)
; print(lat) ; prints all 360 latitude entries

; read in the variable (precipitation)

precip = nmme_f[:]->pr*3600*24 ; the original precipitation is expressed as mm per second, we want mm per day
print("variable dimensions")
print(dimsizes(precip))

; since we used join command above, the dimensions of precip should be
; (number files,ndays,nlat,nlon)

; find a user-specified latitude and longitude 
; let's choose latitudes of 
; let's choose longitudes of 

latind = (/20,50/)
lonind = (/230,300/)

lti = ind_nearest_coord(latind,lat,0)
lni = ind_nearest_coord(lonind,lon,0)

lat_subdomain = lat(lti(0):lti(1))
lon_subdomain = lon(lni(0):lni(1))

precip_subdomain = precip(:,:,lti(0):lti(1),lni(0):lni(1))

print(lat_subdomain) ; displays the latitudes of the chosen area
print(lon_subdomain) ; displays the longitudes of the chosen area

; print(dimsizes(precip_subdomain)) ; prints all lats and lons of the subset 

; print(precip_subdomain) ; prints *ALL* precip values for the subset, about 5 million lines total!!!

; ----------------------------------------------------

; nov 28 1980

print(precip_subdomain(0,333,:,:)) ; array subscripting for Nov 28, 1980, all lat and lon


end 




