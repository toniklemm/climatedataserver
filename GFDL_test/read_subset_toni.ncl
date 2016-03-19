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
printMinMax(lon,True)
print(lat)

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

print(lat_subdomain)
print(lon_subdomain)

print(dimsizes(precip_subdomain))

day = nmme_f[0]->time
ensemble_member = ispan(1,12,1) ; there are 12 ensemble members
; ----------------------------------------------------

; write out the data into a new netCDF file


years = 1980

; we want to write NetCDF!
netCDF1 = True
if (netCDF1) then
diro = "./" ; output directory for the data we are creating

filename = "Toni_output_data"+years+".nc"
filo = filename
end if


setfileoption("nc","Format","LargeFile")

if (netCDF1) then
system("/bin/rm -f "+diro+filo) ; removes old files with the same name if they are present
ncdf = addfile(diro+filo,"c")

setfileoption(ncdf,"DefineMode",True)

; create attributes
fAtt = True
fAtt@title = "NMME ensemble data for the Contiguous U.S"+years
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
filevardef(ncdf,"precipitation",typeof(precip_subdomain),(/"ensemble_member","day","lat","lon"/))

;now write all the variables to the file

ncdf->year = (/years/)
ncdf->ensemble_member = (/ensemble_member/)
ncdf->day = (/day/)
ncdf->lat = (/lat_subdomain/)
ncdf->lon = (/lon_subdomain/)

ncdf->precipitation = (/precip_subdomain/)

end if


end
