<cfsetting enablecfoutputonly="Yes" showdebugoutput="No">
<!-----show_Download_Files.cfm---->
<cfparam name="URL.APPRELATIVEFILEPATH" 	default="">
<cfparam name="URL.CONTENT_TYPE" 	default="application/unknown">
<CFIF Len(Trim(URL.CONTENT_TYPE)) EQ 0>
	<CFSET URL.URL="application/unknown">
</CFIF>

<CFINCLUDE TEMPLATE="/get_App_Path.cfm">

<CFSET URL.APPRELATIVEFILEPATH = REReplaceNoCase(URL.APPRELATIVEFILEPATH, "/", "\", "All")>
<CFSET URL.APPRELATIVEFILEPATH = REReplaceNoCase(URL.APPRELATIVEFILEPATH, "\\$", "")>
<CFSET URL.APPRELATIVEFILEPATH = REReplaceNoCase(URL.APPRELATIVEFILEPATH, "^\\", "")>	
<CFSET FULLPATH="#Application.Doc_Path#\temp_files\#URL.APPRELATIVEFILEPATH#">
<CFSET fileName=GetFileFromPath(FULLPATH)>

<cfheader name="Content-Disposition" value="attachment;filename=#fileName#">
<cfcontent type="text/plain"  file="#FULLPATH#">

<!------<cfcontent type="#URL.CONTENT_TYPE#" file="#APPLICATIONPATH#\#URL.APPRELATIVEFILEPATH#" deletefile="No">----->
<!---
<cffile action = "read"
  file = "#FULLPATH#"
  variable = "fileContent">
<CFOUTPUT>#fileContent#</CFOUTPUT>
--->

<!------
application/unknown
APPLICATION/OCTET-STREAM
image/jpeg
.a 		application/octet-stream 
.ai 	application/postscript 
.aif 	audio/x-aiff 
.aifc 	audio/x-aiff 
.aiff 	audio/x-aiff 
.arc 	application/octet-stream 
.au 	audio/basic 
.avi 	application/x-troff-msvideo 
.bcpio 	application/x-bcpio 
.bin 	application/octet-stream 
.c 		text/plain 
.c++ 	text/plain 
.cc 	text/plain 
.cdf 	application/x-netcdf 
.cpio 	application/x-cpio 
.djv 	image/x-djvu 
.djvu 	image/x-djvu 
.dump 	application/octet-stream 
.dvi 	application/x-dvi 
.eps 	application/postscript 
.etx 	text/x-setext 
.exe 	application/octet-stream 
.gif 	image/gif 
.gtar 	application/x-gtar 
.gz 	application/octet-stream 
.h 		text/plain 
.hdf 	application/x-hdf 
.hqx 	application/octet-stream 
.htm 	text/html 
.html 	text/html 
.iw4 	image/x-iw44 
.iw44 	image/x-iw44 
.ief 	image/ief 
.java 	text/plain 
.jfif 	image/jpeg 
.jfif-tbnl image/jpeg 
.jpe 	image/jpeg 
.jpeg 	image/jpeg 
.jpg 	image/jpeg 
.latex 	application/x-latex 
.man 	application/x-troff-man 
.me 	application/x-troff-me 
.mime 	message/rfc822 
.mov 	video/quicktime 
.movie 	video/x-sgi-movie 
.mpe 	video/mpeg 
.mpeg 	video/mpeg 
.mpg 	video/mpeg 
.ms 	application/x-troff-ms 
.mv 	video/x-sgi-movie 
.nc 	application/x-netcdf 
.o 		application/octet-stream 
.oda 	application/oda 
.pbm 	image/x-portable-bitmap 
.pdf 	application/pdf 
.pgm 	image/x-portable-graymap 
.pl 	text/plain 
.pnm 	image/x-portable-anymap 
.ppm 	image/x-portable-pixmap 
.ps 	application/postscript 
.qt 	video/quicktime 
.ras 	image/x-cmu-rast 
.rgb 	image/x-rgb 
.roff 	application/x-troff 
.rtf 	application/rtf 
.rtx 	application/rtf 
.saveme application/octet-stream 
.sh 	application/x-shar 
.shar 	application/x-shar 
.snd 	audio/basic 
.src 	application/x-wais-source 
.sv4cpio application/x-sv4cpio 
.sv4crc application/x-sv4crc 
.t 		application/x-troff 
.tar 	application/x-tar 
.tex 	application/x-tex 
.texi 	application/x-texinfo 
.texinfo application/x-texinfo 
.text 	text/plain 
.tif 	image/tiff 
.tiff 	image/tiff 
.tr 	application/x-troff 
.tsv 	text/tab-separated-values 
.txt 	text/plain 
.ustar 	application/x-ustar 
.uu 	application/octet-stream 
.wav 	audio/x-wav 
.wsrc 	application/x-wais-source 
.xbm 	image/x-xbitmap 
.xls	application/ms-excel
.xpm 	image/x-xpixmap 
.xwd 	image/x-xwindowdump 
.z 		application/octet-stream 
.zip 	application/zip 
----->