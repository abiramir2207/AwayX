<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<cfquery name="getCreatedTypes" datasource="#application.datasource#">
	SELECT DISTINCT *
	FROM Program_Control_Panel_Options
	WHERE Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	AND Generic_Type = 'Operator-deviated Pricing'
	AND Deleted = 0
</cfquery>

<cfset PAGE_TITLE = "Select Contract Type">

<html>
<head>
	<title><cfoutput>#PAGE_TITLE#</cfoutput></title>
</head>

<body leftmargin="0" topmargin="0" bottommargin="0" rightmargin="0">

<cfinclude template="/includes/header.cfm">

<br><br>
<blockquote>
	<blockquote>
		<p style="border: thin solid Orange; padding: 5px 5px 5px 5px; width: 260px; font-size: 12px; font-family: Arial, Helvetica, sans-serif;">
			<strong>What type of program would like to create?</strong>
		</p>
	</blockquote>
	
<form action="/common_files/contracts/contract_create_1_form.cfm" method="post" name="MyForm" id="MyForm">
	<blockquote>
		<font face="Arial,Helvetica,sans-serif"style="font-size: 11pt;">
			<ul style="list-style-image: none; list-style-type: none; list-style: none;">
				<cfoutput query="getCreatedTypes">
					<li><input type="radio" name="ProgramType" value="#Invoice_Billback#,#IB_Required#;#Claim_Period#,#CP_Required#;#Item_Number#,#IN_Required#;#Total_Dollar_Pound#,#TDP_Required#;#Menu_Listing#,#ML_Required#;#Branded_Point_Of_Sale#,#BPOS_Required#;#Mandated_Specification#,#MS_Required#;#Optional_Specification#,#OS_Required#;#Feature_Sheet#,#FS_Required#;#getCreatedTypes.Created_Type#">&nbsp;&nbsp;#Created_Type#</li>
				</cfoutput>
			</ul>
		</font>
	</blockquote>
</blockquote>
</form>
<BLOCKQUOTE><BLOCKQUOTE><BLOCKQUOTE><BLOCKQUOTE>
<TABLE>
<TR>

	<TD width="200">
	<CF_button
		button_name		=	""
		button_caption	=	"   continue   "
		button_action	=	"javascript: sendScripts()"
		button_type		=	"link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
	</TD>
</TR>
</TABLE>


</BLOCKQUOTE></BLOCKQUOTE></BLOCKQUOTE></BLOCKQUOTE>
<cfinclude template="/includes/footer.cfm">
</body>
</html>

<script>
	function sendScripts(){
		MyForm.submit();
	}
</script>