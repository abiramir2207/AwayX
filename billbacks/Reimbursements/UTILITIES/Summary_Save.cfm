<!---------------------------------------------------
This Page gets the Content for Billback Summary
and saves it to a file
and return the file name
---------------------------------------------------->

<!---------------------------------------------------
<CFINCLUDE TEMPLATE="Billback_Summary_Save.cfm">
input variable : Billback_ID
	Which is the uniqueidentifier that represents a Billback
input variable : Billback.HTML_File_Path
	App Relative Path to the Saved HTML File
---------------------------------------------------->
<cfset ShowLinks=0>
<CFSAVECONTENT VARIABLE="Summary_Content">
<style>
	.tableheader
		{
			border-bottom: solid blue 1px;
			font-weight: bold;
		}
	.tdbody	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	.tdbodyright	{border-bottom:solid #93BEE2 1px; border-right:solid #93BEE2 1px; font-size : 10px;}
	.tableborder
		{
			border-bottom: solid blue 1px;
			border-top: solid blue 1px;
			border-right: solid blue 1px;
			border-left: solid blue 1px;
		}

		.inactiveMenuItem {
			width : 100px;
			height : 30px;
			cursor : pointer;
			background-color: WhiteSmoke;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid red 1px;
			border-top:solid WhiteSmoke 1px;
			border-bottom:solid WhiteSmoke 1px;
			border-left:solid WhiteSmoke 1px;
			border-white:solid White 1px;			
		}
		.activeMenuItem {
			width : 100px;
			height : 30px;
			cursor : pointer;
			background-color: silver;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid silver 1px;
			border-top:solid red 1px;
			border-bottom:solid red 1px;
			border-left:solid red 1px;
		}

		.cellaroundIframe {
			border-right:solid red 1px;
			border-top:solid red 1px;
			border-bottom:solid red 1px;
		} 

		.menuItem_idle {
			font-weight: bold;
			background-color: WhiteSmoke;
			PADDING-BOTTOM: 1px;
			PADDING-LEFT: 10px;
			PADDING-RIGHT: 10px;
			PADDING-TOP: 1px;
			border-right:solid red 1px;
			border-top:solid WhiteSmoke 1px;
			border-bottom:solid WhiteSmoke 1px;
			border-left:solid WhiteSmoke 1px;
			border-white:solid White 1px;
		}

					
</style>
<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
<CFINCLUDE TEMPLATE="/billbacks/reimbursements/detail.cfm">
<cfif application.returned_customer_setting.confidentiality_switch NEQ application.returned_customer_setting.customer_setting_error_string><cfif application.returned_customer_setting.confidentiality_switch EQ 1>
<div align="Center">
<table width="90%" BORDER="0" CELLSPACING="0" CELLPADDING="2">
	<TR>
		<TD COLSPAN="100%">
			<br>				
			<hr color="navy">
			<cfoutput>#application.returned_customer_setting.confidentiality_content#</cfoutput>
			<hr 				
			<hr color="navy">
		</TD>
	</TR>
</table></div>
	</cfif></cfif>
	<BR><BR><BR>
	<!--- <CFINCLUDE TEMPLATE="/Common_Files/Email_Footer.cfm"> --->
</CFSAVECONTENT>


<!--- create usable directory information --->
<CFSET The_File_Location = Application.Doc_Path & HTML_File_Path>
<!--- end create usable directory information --->	

<!--- Build complete path --->
<CFSET completepath=The_File_Location>


<!--- Save the file to the server --->
<cffile action="write" file="#completepath#" output="#Summary_Content#">

