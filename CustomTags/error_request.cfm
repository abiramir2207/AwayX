<!---
Id: error_request.cfm, v2.1 9/12/00 2:15:06 PM dbabbitt
Description: This template provides a kinder, 
			 gentler, method of alerting the user 
			 of an error.
--->

<TABLE WIDTH="600" ALIGN="center" BGCOLOR="Yellow"><TR><TD>
	<BLOCKQUOTE STYLE="font-size: large; font-family: Arial, Helvetica, sans-serif;">		An Error occurred when you requested this page. Please email the 
		<CFOUTPUT><A HREF="mailto:#Error.MailTo#?subject=RE: #Error.Template#...">webmaster</A></CFOUTPUT>
		information about this page. We will correct the problem as soon as we can.</BLOCKQUOTE>
	</TD></TR></TABLE>

<!-- #Error.Diagnostics# -->

<!---
	Log: error_request.cfm
	Revision 2.1 9/12/00 2:14:01 PM dbabbitt
	Added a secret diagnostics comment. 
	(Shh!! Don't tell anybody. :-)
	
	Revision 2.0 9/12/00 9:34:59 AM dbabbitt
	This template is now formatted for use 
	in the production server.
	
	Revision 1.1 7/21/00 10:09:27 AM dbabbitt
	The error strings are now preformatted.
	
	Revision 1.0 6/19/00 1:16:31 PM dbabbitt
	This template provides a kinder, 
	gentler, method of alerting the 
	user of an error.
	--->