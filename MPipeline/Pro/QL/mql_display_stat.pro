;***********************************************************************
pro mql_stat_quit,event
widget_control,event.top, Get_UValue = tinfo
widget_control,tinfo.info.QuickLook,Get_UValue=info
widget_control,info.StatInfo,/destroy
end

;***********************************************************************

;***********************************************************************
;_______________________________________________________________________
;_______________________________________________________________________
; This program produces a widget that gives statistical information
; on an image. The statisical information was determined by the
; program get_image_stat.pro

pro mql_display_stat,info

window,4,/pixmap
wdelete,4
if(XRegistered ('mstat')) then begin
    widget_control,info.StatInfo,/destroy
endif

;_______________________________________________________________________
;*********
;Setup main panel
;*********
i = info.image.integrationNO
j = info.image.rampNO


if(info.data.read_all eq 0) then begin
    i = 0
    if(info.data.num_frames ne info.data.nramps) then begin 
        j = info.image.rampNO- info.control.frame_start
    endif
endif


xstart = 0 & xend = 0 
ystart = 0 & yend = 0 

stitle = strarr(3)
mean = fltarr(3)
st_pixel = fltarr(3)
var = fltarr(3)
min = fltarr(3)
max = fltarr(3)
median = fltarr(3)
st_mean  = fltarr(3)
skew = fltarr(3)
ngood = lonarr(3)
nbad = lonarr(3)


stitle[0] = " Statistics on Science Image "
; These statistics were filled in after they where read in (read_multi_frames) 
; mask and does not include the reference pixels for the statistics. 

mean[0] = info.image.stat[0]
st_pixel[0] = info.image.stat[1]
var[0] = st_pixel[0]*st_pixel[0]
min[0] = info.image.stat[2]
max[0] = info.image.stat[3]
median[0] = info.image.stat[4]
st_mean[0] = info.image.stat[5]
skew[0] = info.image.stat[6]
ngood[0] = info.image.stat[7]
nbad[0] = info.image.stat[8]


stitle[1] = " Statistics on Zoom Image "
mean[1] = info.image.zoom_stat[0]
st_pixel[1] = info.image.zoom_stat[1]

var[1] = st_pixel[1]*st_pixel[1] 

min[1] = info.image.zoom_stat[2] 
max[1] = info.image.zoom_stat[3] 
median[1] = info.image.zoom_stat[4] 
st_mean[1] = info.image.zoom_stat[5] 
Skew[1]= info.image.zoom_stat[6] 
ngood[1] = info.image.zoom_stat[7]
nbad[1] = info.image.zoom_stat[8]

xstart = info.image.x_zoom_start
xend = info.image.x_zoom_end
ystart = info.image.y_zoom_start
yend = info.image.y_zoom_end

stitle[2] = " Statistics on Slope Image "
mean[2] = info.data.reduced_stat[0,0]
st_pixel[2] = info.data.reduced_stat[2,0]
var[2] = st_pixel[2]*st_pixel[2,0]
min[2] = info.data.reduced_stat[3,0]
max[2] = info.data.reduced_stat[4,0]
median[2] = info.data.reduced_stat[2,0]
st_mean[2] = info.data.reduced_stat[7,0]
skew[2] = info.data.reduced_stat[8,0]
ngood[2] = info.data.reduced_stat[9,0]
nbad[2] = info.data.reduced_stat[10,0]


statinfo = widget_base(title="Statistics on Images",$
                         col = 1,mbar = menuBar,group_leader = info.RawQuickLook,$
                           xsize = 730,ysize = 270,/align_right)
lineid = widget_base(statinfo,row = 1)
si = strtrim(string(info.image.integrationNO+1),2)
sj = strtrim(string(info.image.rampNO+1),2)
st = 'Integration: ' + si + '    Frame: ' + sj
label = widget_label(lineid,value=st,/align_center,font=info.font5)
nolable = widget_label(lineid,value='   No reference pixels included',font = info.font5)

graphID_master1 = widget_base(statinfo,row=1)

graphID = lonarr(3)
graphID[0] = widget_base(graphID_master1,col=1)
graphID[1] = widget_base(graphID_master1,col=1)
graphID[2] = widget_base(graphID_master1,col=1)
;********
; build the menubar
;********
QuitMenu = widget_button(menuBar,value="Quit",font = info.font2)
quitbutton = widget_button(quitmenu,value="Quit",event_pro='mql_stat_quit')

;_______________________________________________________________________
for i = 0,2 do begin 
    resbase = Widget_Base(graphid[i], /column, /Frame)
    stit  =    stitle[i]
    smean =    '           Mean:       ' + strtrim(string(mean[i],format="(g14.6)"),2) 
    sdpixel =  'Standard Deviation:    ' +  strtrim(string(st_pixel[i],format="(g14.6)"),2)
    smin =     '            Min:       '+ strtrim(string(min[i],format="(g14.6)"),2) 
    smax =     '            Max:       '+strtrim( string(max[i],format="(g14.6)"),2)
    smed     = '         Median:       '+strtrim( string(median[i],format="(g14.6)"),2)
    sskew =    '           Skew:       '+strtrim( string(skew[i],format="(g14.6)"),2)
    sgood =    '# of Good Pixels:      '+strtrim( string(ngood[i],format="(i10)"),2)
    sbad  =    '# of Bad/Sat Pixels:   '+strtrim( string(nbad[i],format="(i10)"),2)
    if(i eq 2) then sbad  = '# Sat Pixels or Pixels Flagged as Bad: '+strtrim( string(nbad[i],format="(i10)"),2)
 
    titlelab = Widget_Label(resbase, Value = stit)
    meanlab = Widget_Label(resbase, Value = smean)
    sdplab = Widget_Label(resbase, Value = sdpixel)
    minlab = Widget_Label(resbase, Value = smin)
    maxlab = Widget_Label(resbase, Value = smax)
    medlab = Widget_Label(resbase, Value = smed)
    sklab = Widget_Label(resbase, Value = sskew)
    glab = Widget_Label(resbase, Value = sgood)
    blab = Widget_Label(resbase, Value = sbad)

    if(i eq 1 )  then begin
        if(info.data.subarray eq 0) then begin
            if(xstart lt 4) then xstart = 4
            if(xend gt 1028) then xend = 1028
        endif
        sxrange =   ' X pixel range :  '+ strtrim( string(xstart+1,format="(g14.6)"),2) + ' to ' +$
                    strtrim( string(xend+1,format="(g14.6)"),2)
        syrange =   ' Y pixel range :  '+ strtrim( string(ystart+1,format="(g14.6)"),2) + ' to ' +$
                strtrim( string(yend+1,format="(g14.6)"),2)
        xrangelab = Widget_Label(resbase, Value = sxrange)
        yrangelab = Widget_Label(resbase, Value = syrange)
    endif
    if(i eq 2) then info_label = widget_button(resbase,value = 'Info on Bad Pixels',$
                                               event_pro = 'info_badpixel',/align_left)
endfor

info.StatInfo = statinfo

stat = {info                  : info}	



Widget_Control,info.StatInfo,Set_UValue=stat
widget_control,info.StatInfo,/realize

XManager,'mstat',info.statinfo,/No_Block
Widget_Control,info.QuickLook,Set_UValue=info

end
