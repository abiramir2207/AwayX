<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE>ActivEdit Example</TITLE>
</HEAD>

<BODY>

<FORM METHOD="post">
	
	<CF_ACTIVEDIT NAME="content"
		TOOLBAR="cut,copy,paste,|,undo,redo,|,font,bold,italic,underline,|,outdent,indent,|,justifyleft,justifycenter,justifyright,bullets,numbers,|,table,image,showdetails,specialchars,hr,hyperlink,help"

		IMAGEPATH="c:/inetpub/wwwroot/images/"
		IMAGEURL="/images/"
		BASEURL="http://localhost/"
		INC="inc/"
		DEFAULTFONT="10pt verdana"
		QUICKSTYLES="title,header"
		TABVIEW="0"
		ACTIVSCAN="0"
		HEIGHT=500
		WIDTH=800>
		
		Default <B>HTML</B> Content Goes here.
		
	</CF_ACTIVEDIT>
	
	<BR>
	
	<INPUT TYPE="submit" VALUE="submit form">
	
</FORM>


<CFIF IsDefined("form.content")>
This is the content you submitted:
<HR>
<CFOUTPUT>#form.content#</CFOUTPUT>
</CFIF>


</BODY>
</HTML>
