<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<CFPARAM NAME="URL.Billback_Product_Detail_ID"								DEFAULT="">
<CFSET Billback_Product_Detail_ID=URL.Billback_Product_Detail_ID>

<CFINCLUDE TEMPLATE="Deviation_Constants.CFM">


<html>
<head>
	<title>Billback <cfoutput>#appSettings.getDeviationLabel()#</cfoutput> - Product Date Overlap</title>
</head>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">
<BLOCKQUOTE>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">


<!------------------------------show spinner ---------------------------->
<!-----
<CFSET PW_Type="1">
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>

<SCRIPT>
document.all.PleaseWaitMessage.style.display='none';
</SCRIPT>
------->
<BR><BR>
<!---------------- Date overlap code starts here --------------------------------------->
<CFINCLUDE TEMPLATE="Date_Overlap_With_Other_Billbacks.cfm">
<!---------------- Date overlap code ends here --------------------------------------->

<!------
Total_Overlap
----->
<CFIF isDefined("Total_Overlap")>
	<CFOUTPUT>
	<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Product_Rate">
	SELECT	
			Billback_Product_Detail.BB_Rate
			FROM	Billback_Product_Detail	
		WHERE	
			Billback_Product_Detail.Billback_Product_Detail_ID = '#Billback_Product_Detail_ID#'
			AND
			Billback_Product_Detail.Deleted = 0
	</CFQUERY>
	
	<BR>
	<B>Date overlap #appSettings.getDeviationLabel()# calculation</B>
	<HR COLOR="Orange">


	<!------------- Find dates deviated ------------------>
	<CFSET Billback_interval=DATEDIFF("d", This_Billback_Start_Date, This_Billback_End_Date) + 1>

	<TABLE CELLPADDING="2" CELLSPACING="0" BORDER="0" WIDTH="60%">	
		<TR>
			<TD>Total Billback Interval</TD>
			<TD>D1</TD>
			<TD>&nbsp:&nbsp;</TD>		
			<TD>		
			#Billback_interval# days
			</TD>
		</TR>
		<TR>
			<TD>Dates Overlapped</TD>
			<TD>D2</TD>
			<TD>&nbsp:&nbsp;</TD>		
			<TD>		
			#Total_Overlap# days
			</TD>
		</TR>
		<TR>
			<TD>Overlap percentage</TD>
			<TD>D3 = D2 / D1</TD>
			<TD>&nbsp:&nbsp;</TD>		
			<TD>		
			<CFSET Overlap_Percent=(Total_Overlap * 100)/Billback_interval>
			#NumberFormat(Overlap_Percent, DEVIATION_PERCENT_FORMAT)#%
			</TD>
		</TR>
		<TR>
			<TD>Total Amount claimed</TD>
			<TD>A1</TD>
			<TD>&nbsp:&nbsp;</TD>		
			<TD>#DollarFormat(Billback_Product_Rate.BB_Rate)#</TD>
		</TR>
		<TR>
			<TD>#appSettings.getDeviationLabel()# Amount</TD>
			<TD>A2 = A1 * D3</TD>
			<TD>&nbsp:&nbsp;</TD>		
			<TD>
			<CFSET dev_Claim_Amount = Billback_Product_Rate.BB_Rate * Overlap_Percent / 100>
			#DollarFormat(dev_Claim_Amount)#
			</TD>
		</TR>
	</TABLE>
</CFOUTPUT>	
</CFIF>


	<BR><BR>
<SCRIPT LANGUAGE="JavaScript" SRC="common_js.js"></SCRIPT>
<TABLE ALIGN="CENTER" WIDTH="50%">
	<TD ALIGN="CENTER">
	<CF_button
			button_name		=	""
			button_caption	=	"print"
			button_action	=	"printPage();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"print"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
	<TD ALIGN="CENTER">
	<CF_button
			button_name		=	""
			button_caption	=	"close this window"
			button_action	=	"window.close();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"close this window"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
	</TD>
</TABLE>	
		<BR><BR>
</BLOCKQUOTE>
</BODY>
</HTML>

