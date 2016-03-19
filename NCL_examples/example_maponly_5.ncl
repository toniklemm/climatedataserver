;================================================;
;  maponly_5.ncl
;  URL: http://ncl.ucar.edu/Document/Graphics/Interfaces/gsn_csm_map.shtml
;================================================;
;
; Concepts illustrated:
;   - Drawing a satellite map
;   - Changing the view of a satellite map
;
;=================================================;
;
; These files are loaded by default in NCL V6.2.0 and newer
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"   
; load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"   
;=================================================;
begin

  wks  = gsn_open_wks("pdf","maponly_270_45_3-0")         ; send graphics to PDF file, name is "maponly.pdf"

  res                            = True		; "True" to apply the variables below, "False" if not
  res@mpFillOn			 = True		; turns on map fill 
  res@mpProjection               = "CylindricalEqualArea"	; choose map projection
  res@mpCenterLonF               = 270.0  	; choose center lon (0 = Greenwich, 90 = Asia, 180 = Pacific, 270 = America)
  res@mpCenterLatF               = 45.    	; choose center lat
  res@mpSatelliteDistF           = 3.0  	; choose satellite view

  plot = gsn_csm_map(wks,res)			; draw satellite proj map

end
;=================================================;
