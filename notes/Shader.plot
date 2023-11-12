set term x11 background rgb "white"
set pointsize 1

splot 'notes/Shader.data' with points lc rgbcolor '#a83be3', 'notes/Shader.data.2' with points lc rgbcolor '#eb7a34'
pause -1
