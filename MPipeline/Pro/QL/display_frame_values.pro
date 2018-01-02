;***********************************************************************
pro frame_values_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.RPixelInfo,/destroy
end
;***********************************************************************

pro update_frame_values,info

; this is only called if the user changes from decimal to hex or vice
 ; versa

i = info.image_pixel.integrationNO

xvalue = info.image_pixel.xvalue ; starts at 0
yvalue = info.image_pixel.yvalue ; starts at 0


if(xvalue lt 0) then xvalue =0
if(yvalue lt 0) then yvalue = 0


if(info.image_pixel.coadd ne 1 ) then begin 
    value = (*info.image_pixel.pixeldata)[i,*]
    value_ref = (*info.image_pixel.ref_pixeldata)[i,*]
endif else begin
    value = (*info.image_pixel.pixeldata)[*,0]

    value_ref = (*info.image_pixel.refcorrected_pixeldata)[*,0]
endelse

    

lc = value
mdc = value
reset = value
rscd = value

lastframe = value

if(info.image_pixel.file_lc_exist eq 1) then begin
    lc = (*info.image_pixel.lc_pixeldata)
endif

if(info.image_pixel.file_mdc_exist eq 1) then begin
    mdc = (*info.image_pixel.mdc_pixeldata)
 endif

if(info.image_pixel.file_reset_exist eq 1) then begin
    reset = (*info.image_pixel.reset_pixeldata)
 endif

if(info.image_pixel.file_rscd_exist eq 1) then begin
    rscd = (*info.image_pixel.rscd_pixeldata)
 endif

print,info.image_pixel.file_lastframe_exist
if(info.image_pixel.file_lastframe_exist eq 1) then begin
    lastframe = (*info.image_pixel.lastframe_pixeldata)
    help,lastframe
    stop
endif


nend = info.image_pixel.nframes
if(info.image_pixel.coadd eq 1) then  nend = info.image_pixel.nints
framevalue = strarr(nend)
refvalue = strarr(nend)
linvalue = strarr(nend)
darkvalue = strarr(nend)
resetvalue = strarr(nend)
rscdvalue = strarr(nend)
lastframevalue = strarr(nend)


for j = 0,nend-1 do begin
    frame_no = "Frame " + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    rampnew = value[j]
    sramp = strtrim(string(rampnew,format="(f16.2)"),2)
        
    ref_no = "Reference Output " + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    refnew = value_ref[j]
    sref = strtrim(string(refnew,format="(f16.2)"),2)


    lin_no = "Lin Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    lvalue = lc[j]
    slin = strtrim(string(lvalue,format="(f16.2)"),2)

    dark_no = "Dark Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    dvalue =mcd[j]
    sdark = strtrim(string(dvalue,format="(f16.2)"),2)

    reset_no = "Reset Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    rvalue =reset[j]
    sreset = strtrim(string(rvalue,format="(f16.2)"),2)

    rscd_no = "RSCD Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    rvalue =rscd[j]
    srscd = strtrim(string(rvalue,format="(f16.2)"),2)

    lastframe_no = "Lastframe Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    lvalue =lastframe

    slastframe = strtrim(string(lvalue,format="(f16.2)"),2)

    if(info.image_pixel.hex eq 1) then  begin
        if(value[j] lt 0) then begin
            sramp = " Negative Value " 
        endif else begin
            dec2hex,value[j],ramphex,quiet=1,upper=1
            sramp = strtrim(string(ramphex),2)
        endelse
            
        if(value_ref[j] lt 0) then begin
            sref = " Negative Value " 
        endif else begin
            dec2hex,value_ref[j],refhex,quiet=1,upper=1
            sref = strtrim(string(refhex),2)
        endelse
    endif

    if(info.image_pixel.nints eq info.image_pixel.integrationNO ) then begin
        sramp = 'NA'
        sref = 'NA'
    endif    
    framevalue[j] = frame_no +sramp
    refvalue[j] = ref_no  + sref
    linvalue[j] = lin_no + slin
    darkvalue[j] = dark_no + sdark
    resetvalue[j] = reset_no + sreset
    rscdvalue[j] = rscd_no + srscd
    lastframevalue[j] = lastframe_no + slastframe
endfor

widget_control,info.image_pixel.pix_statLabelID[0],set_value = framevalue

widget_control,info.image_pixel.pix_statLabelID[1],set_value = refvalue

if(info.image_pixel.file_lc_exist eq 1) then $
  widget_control,info.image_pixel.pix_statLabelID[2],set_value = linvalue


if(info.image_pixel.file_mcd_exist eq 1) then $
  widget_control,info.image_pixel.pix_statLabelID[3],set_value = darkvalue

if(info.image_pixel.file_reset_exist eq 1) then $
  widget_control,info.image_pixel.pix_statLabelID[4],set_value = resetvalue

if(info.image_pixel.file_rscd_exist eq 1) then $
  widget_control,info.image_pixel.pix_statLabelID[5],set_value = rscdvalue

if(info.image_pixel.file_lastframe_exist eq 1) then $
  widget_control,info.image_pixel.pix_statLabelID[6],set_value = lastframevalue

value = 0
value_ref = 0
framevalue = 0
refvalue = 0
lastframevalue = 0
reservalue = 0
rscdvalue =0
linvalue = 0

end


;***********************************************************************
;_______________________________________________________________________
;***********************************************************************
pro frame_values_event,event

Widget_Control,event.id,Get_uValue=event_name
widget_control,event.top, Get_UValue = ginfo
widget_control,ginfo.info.QuickLook,Get_Uvalue = info

    case 1 of
;_______________________________________________________________________

; change the display type: decimal, hex
;_______________________________________________________________________

    (strmid(event_name,0,7) EQ 'display') : begin
        if(event.index eq 0) then info.image_pixel.hex = 0
        if(event.index eq 1) then info.image_pixel.hex = 1
        Widget_Control,ginfo.info.QuickLook,Set_UValue=info

        update_frame_values,info
    end

;_______________________________________________________________________
    (strmid(event_name,0,8) EQ 'datainfo') : begin


        data_id ='ID flag '+ strcompress(string(info.dqflag.Unusable),/remove_all) +  ' = ' + info.dqflag.Sunusable +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.Saturated),/remove_all) +  ' = ' + info.dqflag.SSaturated +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.CosmicRay),/remove_all) +  ' = ' + info.dqflag.SCosmicRay +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoiseSpike),/remove_all) +  ' = ' + info.dqflag.SNoiseSpike +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NegCosmicRay),/remove_all) +  ' = ' + info.dqflag.SNegCosmicRay +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoReset),/remove_all) +  ' = ' + info.dqflag.SNoReset +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoDark),/remove_all) +  ' = ' + info.dqflag.SNoDark +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoLin),/remove_all) +  ' = ' + info.dqflag.SNoLin +  string(10b) + $
;                 'ID flag '+ strcompress(string(info.dqflag.OutLinRange),/remove_all) +  ' = ' + info.dqflag.SOutLinRange +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.NoLastFrame),/remove_all) +  ' = ' + info.dqflag.SNoLastFrame +  string(10b) + $
                 'ID flag '+ strcompress(string(info.dqflag.Min_Frame_Failure),/remove_all) +  ' = ' + info.dqflag.SMin_Frame_Failure +  string(10b) 

                 
        result = dialog_message(data_id,/information)
    end
;_______________________________________________________________________

;_______________________________________________________________________

else: ;print," Event name not found ",event_name
endcase
end


;_______________________________________________________________________
; The parameters for this widget are contained in the image_pixel
; structure, rather than a local imbedded structure because
; mql_event.pro also calls to update the pixel info widget

pro display_frame_values,xvalue,yvalue,info,refoutput

; refoutput - this was called from inspect reference output 

window,4,/pixmap
wdelete,4
if(XRegistered ('mpixel')) then begin
    widget_control,info.RPixelInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********

PixelInfo = widget_base(title=" Frame Values for Pixel",$
                        col = 1,mbar = menuBar,group_leader = info.QuickLook,$
                        xsize = 1400,ysize = 500,/base_align_right,xoffset=550,yoffset=100,$
                        /scroll,x_scroll_size = 900,y_scroll_size = 500)

;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='frame_values_quit')

info.image_pixel.xvalue = xvalue
info.image_pixel.yvalue = yvalue

;_______________________________________________________________________
; Pixel Statistics Display
;*********
title_label = widget_label(PixelInfo,value = info.image_pixel.filename,/align_left)

displaytypes = ['Decimal Display',$
              'Hexidecimal Display']

display_base = widget_base(PixelInfo,col= 1,/align_left)
DMenu = widget_droplist(display_base,value=displaytypes,uvalue='display')

pix_statLabel = strarr(9)
pix_statFormat = strarr(9)

pix_statLabel =["Integration", "X", "Y", "Signal (DN/S)", "Uncertainty (DN/S)","Data Quality Flag",$
                                "Zero Pt of Fit","# Good Frames", "Read # of 1st Sat" ]
if(info.image_pixel.coadd) then pix_statLabel =["Integration", "X", "Y", "Coadd (DN/frame)", $
                                                                 "Uncertainty (DN/frame)","Data Quality Flag",$
                                "Zero Pt of Fit","# Good Frames", "Read # of 1st Sat" ]
pix_statFormat = ["I3", "I4", "I4", "F16.2","F16.2","I8","F16.2","I4","F16.2"]

nend = info.image_pixel.nframes
i = info.image_pixel.integrationNO


if(info.image_pixel.coadd eq 1) then nend = info.image_pixel.nints
ssignal = 'NA'
suncertainty = 'NA'
si = strtrim(string(i+1,format="("+pix_statFormat[0]+")"),2)
sx = strtrim(string(xvalue+1,format="("+pix_statFormat[1]+")"),2)
sy = strtrim(string(yvalue+1,format="("+pix_statFormat[2]+")"),2)

slope_exist = info.image_pixel.slope_exist
if(info.image_pixel.integrationNO+1 gt info.image_pixel.nslopes) then slope_exist = 0


if(slope_exist) then begin 
    signal  = info.image_pixel.slope
    zeropt =  info.image_pixel.zeropt

    uncertainty   = info.image_pixel.uncertainty
    id   = info.image_pixel.quality_flag

    ngood =  info.image_pixel.ngood
    numsat =  info.image_pixel.nframesat
    

    ssignal = strtrim(string(signal,format="("+pix_statFormat[3]+")"),2)
    suncertainty = strtrim(string(uncertainty,format="("+pix_statFormat[4]+")"),2)
    sid = strtrim(string(id,format="("+pix_statFormat[5]+")"),2)
    szeropt = strtrim(string(zeropt,format="("+pix_statFormat[6]+")"),2)
    sngood = strtrim(string(ngood,format="("+pix_statFormat[7]+")"),2)
    snumsat = strtrim(string(numsat,format="("+pix_statFormat[8]+")"),2)

endif else begin
    ssignal = 'NA'
    suncertianty = 'NA'
    sid = 'NA'
    szeropt = 'NA'
    sngood = 'NA'
    snumsat = 'NA'
endelse

if(refoutput eq 1) then begin
    szeropt = 'NA'
    suncertainty = 'NA'
    sid = 'NA'
    sngood = 'NA'
    snumsat = 'NA'
endif
if(info.data.slope_zsize eq 2 or info.data.slope_zsize eq 3) then begin
    suncertainty = 'NA'
    sid = 'NA'
    sngood = 'NA'
    snumsat = 'NA'
endif

value = (*info.image_pixel.pixeldata)[i,*]
value_ref = (*info.image_pixel.ref_pixeldata)[i,*]



value_refcorrected = 0
if(info.image_pixel.file_refcorrection_exist eq 1) then $
  value_refcorrected = (*info.image_pixel.refcorrected_pixeldata)[i,*]
value_id =0
if(info.image_pixel.file_ids_exist eq 1) then $
  value_id = (*info.image_pixel.id_pixeldata)[i,*]
value_lc  =0
if(info.image_pixel.file_lc_exist eq 1) then begin
  value_lc = (*info.image_pixel.lc_pixeldata)[i,*]
endif

value_mdc  =0
if(info.image_pixel.file_mdc_exist eq 1) then begin
  value_mdc = (*info.image_pixel.mdc_pixeldata)[i,*]
endif

value_reset  =0
if(info.image_pixel.file_reset_exist eq 1) then begin
  value_reset = (*info.image_pixel.reset_pixeldata)[i,*]
endif

value_rscd  =0
if(info.image_pixel.file_rscd_exist eq 1) then begin
  value_rscd = (*info.image_pixel.rscd_pixeldata)[i,*]
endif

value_lastframe  =0
if(info.image_pixel.file_lastframe_exist eq 1) then begin
  value_lastframe = (*info.image_pixel.lastframe_pixeldata)[i]
endif



info_string = "Frame "

if(info.image_pixel.coadd eq 1) then begin
    value = (*info.image_pixel.pixeldata)[*,0]
    value_ref = (*info.image_pixel.ref_pixeldata)[*,0]
    value_refcorrected = (*info.image_pixel.refcorrected_pixeldata)[*,0]
    value_id = (*info.image_pixel.id_pixeldata)[*,0]
    info_string = "Int "
endif





pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[0]+' = ' + $
                                             si, $ 
                                             /dynamic_resize,/align_left)

pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[1]+' = ' + $
                                             sx, $ 
                                             /dynamic_resize,/align_left)
pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[2]+' = ' + $
                                             sy, $ 
                                             /dynamic_resize,/align_left)


pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[3]+' = ' + $
                                             ssignal, $ 
                                             /dynamic_resize,/align_left)

pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[4]+' = ' + $
                                             suncertainty, $ 
                                             /dynamic_resize,/align_left)

info_base = widget_base(pixelinfo,row=1,/align_left)
pix_statLabelID = widget_label(info_base,$
                                             value= pix_statLabel[5]+' = ' + $
                                             sid, $ 
                                             /dynamic_resize,/align_left)
info_label = widget_button(info_base,value = 'Info',uvalue = 'datainfo')

if(info.image_pixel.coadd eq 0)then pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[6]+' = ' + $
                                             szeropt, $ 
                                             /dynamic_resize,/align_left)

if(info.image_pixel.coadd eq 1) then pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[6]+' =  NA',$
                                             /dynamic_resize,/align_left)

pix_statLabelID = widget_label(pixelinfo,$
                               value= pix_statLabel[7]+' = ' + $
                               sngood, $ 
                               /dynamic_resize,/align_left)

pix_statLabelID = widget_label(pixelinfo,$
                                             value= pix_statLabel[8]+' = ' + $
                                             snumsat, $ 
                                             /dynamic_resize,/align_left)




framevalue = strarr(nend)
refvalue = strarr(nend)
refcorrected_value = strarr(nend)
id_value = strarr(nend)
lc_value = strarr(nend)
mdc_value = strarr(nend)
reset_value = strarr(nend)
rscd_value = strarr(nend)
lastframe_value = strarr(nend)

for j = 0,nend-1 do begin
    svalue = strtrim(string(value[j],format="("+pix_statFormat[4]+")"),2)
    srefvalue = strtrim(string(value_ref[j],format="("+pix_statFormat[4]+")"),2)


    if(info.image_pixel.file_refcorrection_exist eq 0) then  begin
        srefcorrected_value = 'NA'
    endif else begin 
        srefcorrected_value = strtrim(string(value_refcorrected[j],format="("+pix_statFormat[4]+")"),2)
    endelse



    if(info.image_pixel.file_ids_exist eq 0) then begin
        sid_value = 'NA'
    end else begin
        sid_value = strtrim(string(value_id[j],format="("+pix_statFormat[2]+")"),2)
    endelse

    if(info.image_pixel.file_lc_exist eq 0) then begin
        slc_value = 'NA'
    endif else begin 
        slc_value = strtrim(string(value_lc[j],format="("+pix_statFormat[4]+")"),2)
    endelse


    if(info.image_pixel.file_mdc_exist eq 0) then begin
        smdc_value = 'NA'
    endif else begin 

        smdc_value = strtrim(string(value_mdc[j],format="("+pix_statFormat[4]+")"),2)
     endelse

    if(info.image_pixel.file_reset_exist eq 0) then begin
        sreset_value = 'NA'
    endif else begin 
        sreset_value = strtrim(string(value_reset[j],format="("+pix_statFormat[4]+")"),2)
     endelse

    if(info.image_pixel.file_rscd_exist eq 0) then begin
        srscd_value = 'NA'
    endif else begin 
        srscd_value = strtrim(string(value_rscd[j],format="("+pix_statFormat[4]+")"),2)
     endelse



    if(info.image_pixel.file_lastframe_exist eq 0 or j+1 ne nend) then begin
        slastframe_value = 'NA'
    endif else begin 

        slastframe_value = strtrim(string(value_lastframe,format="("+pix_statFormat[4]+")"),2)
    endelse


    frame_no = info_string + strcompress(string(fix(j+1)),/remove_all)+ " = " 


    if(info.image_pixel.nints eq info.image_pixel.integrationNO) then begin
        svalue = 'NA'
        srefvalue = 'NA'
        srefcorrected_value= 'NA'
        sid_value = 'NA'
        slc_value = 'NA'
        smdc_value = 'NA'
        sreset_value = 'NA'
        srscd_value = 'NA'
        slastframe_value = 'NA'
    endif


    if(j+1 lt info.image_pixel.start_fit or j+1 gt info.image_pixel.end_fit) then begin
        srefcorrected_value = 'NA'
        sid_value = 'NA'
        slc_value = 'NA'
        smdc_value = 'NA'
        sreset_value = 'NA'
        srscd_value = 'NA'
        slastframe_value = 'NA'
    endif



    framevalue[j] = frame_no + svalue
        
    ref_no = "Reference Output" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    refvalue[j] = ref_no + srefvalue

    refcorrected_no = "Reference Corrected " + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    refcorrected_value[j] = refcorrected_no + srefcorrected_value

    id_no = "ID Flag " + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    id_value[j] = id_no + sid_value

    lc_no = "Lin Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    lc_value[j] = lc_no + slc_value

    mdc_no = "Dark Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    mdc_value[j] = mdc_no + smdc_value

    reset_no = "Reset Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    reset_value[j] = reset_no + sreset_value

    rscd_no = "RSCD Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    rscd_value[j] = rscd_no + srscd_value

    lastframe_no = "Last Frame Corr" + strcompress(string(fix(j+1)),/remove_all)+ " = " 
    lastframe_value[j] = lastframe_no + slastframe_value

endfor
pix2 = widget_base(PixelInfo,row=1,/align_left)
info.image_pixel.pix_statLabelID[0] = widget_list(pix2,$
                              value=framevalue,/align_left,scr_ysize=200,$
                              uvalue = 'frame')

if(info.image_pixel.file_refcorrection_exist ne 0) then $
pix_statLabelID = widget_list(pix2,$
                              value=refcorrected_value,/align_left,scr_ysize=200,$
                              uvalue ='refc')


if(info.image_pixel.file_mdc_exist eq 1) then $
info.image_pixel.pix_statLabelID[3] = widget_list(pix2,$
                                                  value=mdc_value,/align_left,scr_ysize=200,$
                                                  uvalue ='mdc')

if(info.image_pixel.file_reset_exist eq 1) then $
info.image_pixel.pix_statLabelID[4] = widget_list(pix2,$
                                                  value=reset_value,/align_left,scr_ysize=200,$
                                                  uvalue ='reset')

if(info.image_pixel.file_rscd_exist eq 1) then $
info.image_pixel.pix_statLabelID[5] = widget_list(pix2,$
                                                  value=rscd_value,/align_left,scr_ysize=200,$
                                                  uvalue ='rscd')

if(info.image_pixel.file_lastframe_exist eq 1) then $
info.image_pixel.pix_statLabelID[5] = widget_list(pix2,$
                                                  value=lastframe_value,/align_left,scr_ysize=200,$
                                                  uvalue ='lastframe')

if(info.image_pixel.file_lc_exist eq 1) then $
info.image_pixel.pix_statLabelID[2] = widget_list(pix2,$
                                                  value=lc_value,/align_left,scr_ysize=200,$
                                                  uvalue ='lc')

if(info.image_pixel.file_ids_exist ne 0) then $
  pix_statLabelID = widget_list(pix2,$
                                value=id_value,/align_left,scr_ysize=200,$
                                uvalue ='id')



info.image_pixel.pix_statLabelID[1] = widget_list(pix2,$
                                                  value=refvalue,/align_left,scr_ysize=200,$
                                                  uvalue ='ref')


info.RPixelInfo = pixelinfo

pixel = {info                  : info}	



Widget_Control,info.rPixelInfo,Set_UValue=pixel
widget_control,info.rPixelInfo,/realize

XManager,'mpixel',pixelinfo,/No_Block,event_handler = 'frame_values_event'

Widget_Control,info.QuickLook,Set_UValue=info

end