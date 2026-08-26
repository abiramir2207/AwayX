<cfparam name="URL.Program_ID" 	default="">
<cfparam name="URL.LUMP_ID" 	default="">

<cfset LumpSumManager = CreateObject("component", "components.programs.lump_sum_components.LumpSumManager") />
<cfif URL.LUMP_ID NEQ "">	
	<cfset URL.Program_ID = LumpSumManager.getLumpSumProgramID(URL.LUMP_ID) />
</cfif>


<cfif isNumeric(URL.Program_ID)>

<cfoutput>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>#Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</title>
</head>

<body>

<!------ Content starts here ----->

<!------ Get the distributors in the program ----->
<cfset getDistributors  = LumpSumManager.getLumpSumDistributors(URL.Program_ID, URL.LUMP_ID, 1)>

<!------ Display the distributors in the program ----->
<TABLE CLASS="Maintable" WIDTH="100%" CELLPADDING="3" CELLSPACING="0" BORDER="0">
	<caption align="left" style="font-weight:bold;font-size:14px;">#Application.LumpsumLabel# #application.returned_customer_setting.distributor_label_plural#</caption>
	<!--- TABLE HEADERS --->
	<TR ID="header" BGCOLOR="##ffce84">
		<TD ID="header"><B>#Application.LumpsumLabel#&nbsp;</B></TD>
		<TD align="left" ID="header" WIDTH=""><B>#application.returned_customer_setting.distributor_label_singular# Name / #application.returned_customer_setting.shard_ship_to_label#</B></TD>
		<TD ID="header" WIDTH="20%"><B>Address</B></TD>
	</TR>
</cfoutput>		
	<CFOUTPUT QUERY="getDistributors" group="Program_Lump_Sum_ID">
		<TR BGCOLOR="CCCCCC">
			<TD ID="header" colspan="3"><B>#Program_Lump_Sum_Name# (#DollarFormat(Lump_Sum_Amount)#)&nbsp;</B></TD>			
		</TR>
		<cfoutput>
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
			<TD>&nbsp;</TD>
			<TD NOWRAP>#Name#<BR>#Shr_Ship_To#&nbsp;</TD>
			<TD>#Address_1#<BR>#City#,#State# #ZipCode#&nbsp;</TD>
		</TR>
		</cfoutput>
	</CFOUTPUT>
</TABLE>
<center>
<br><br>
<cf_smallLink
	url="##"
	title="close window"
	parameters="STYLE=""cursor:pointer;"" ONCLICK=""javaScript: window.close();return false;"""
	>
</center>

<!------ Content ends here ----->
</body>
</html>


</cfif>