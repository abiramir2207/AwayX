<!------ Program_Pricing_Change.cfm ----->
<cfsavecontent variable="priceChangeReport">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Program Pricing Change Log</title>
	<style>
	TABLE.ChangeLog
	{
		font-size:12px;
	}
	TABLE.ChangeLog TD
	{
		border: 1px solid black;
	}
	TD.itemHeading
	{
		background-color:ffdead;
		font-weight:bold;
	}
	TD.itemHeading2
	{
		background-color:cccccc;
		font-weight:bold;
	}
	TABLE.ChangeLogNoBorder
	{
		font-size:12px;
	}
	TABLE.ChangeLogNoBorder TD
	{
		border: none;
	}
	</style>
</head>

<body>
<!------ 
"	Away-X program number
"	R/3 Agreement/Sales Deal number
"	Program Description
"	Program Validity dates
"	SKU with changed NLP or MAF
"	SKU description
"	Program fixed price
"	Current/old program price condition difference
"	New or current NLP
"	New or current MAF
"	Calculated new price condition difference (new NLP + MAF - Program Fixed Price)

 ----->
<cfquery name="qGetProgramPricingChange" datasource="#application.datasource#">
	SELECT	Contract_Main.Contract_Number, Contract_Main.Contract_Title,
			Contract_Main.Contract_reference_Number, Contract_Main.Contract_Start_Date, Contract_Main.Contract_End_Date, 
			BSA_Foodservice_Items_Master.Item, BSA_Foodservice_Items_Master.Description, 
			Program_Pricing_Change.Offered_Price, Program_Pricing_Change.Product_Price, Program_Pricing_Change.Price_Difference,
			Units_of_Measure.Abbreviation UOMDesc, Program_Pricing_Change.Start_Date
	FROM	Program_Pricing_Change
			INNER JOIN Contract_Main
			ON
			Contract_Main.Deleted = 0
			AND Contract_Main.Contract_Main_ID = Program_Pricing_Change.Program_ID
			AND Contract_Main.Contract_Status_Type_IDX <= 6
			<!------ TODO: ----->
			<!------ AND Contract_Main.Sent_To_External_Client = 1 ----->
			INNER JOIN BSA_Foodservice_Items_Master
			ON
			BSA_Foodservice_Items_Master.Deleted = 0
			AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 	Program_Pricing_Change.Product_ID
			INNER JOIN Units_of_Measure
			ON
			Units_of_Measure.Unit_of_Measure_ID = Program_Pricing_Change.Price_UOM
	WHERE	Program_Pricing_Change.Deleted = 0
			AND Program_Pricing_Change.Report_Sent = 0
	ORDER BY Contract_Main.Contract_Number
</cfquery>
<cfoutput><h4>#DateFormat(Now(), "mm/dd/yyyy")# #TimeFormat(Now(), "hh:mm:ss tt")#</h4></cfoutput>
<TABLE cellpadding="2" cellspacing="0" width="100%" class="ChangeLog">
<cfoutput query="qGetProgramPricingChange" group="Contract_Number">
	<TR valign="top">
		<TD colspan="100%" class="itemHeading">
		[#Contract_Number#] #Contract_Title#
		<TABLE cellpadding="2" cellpadding="0" class="ChangeLogNoBorder">
		<TR>
			<TD>Program Dates: </TD>
			<TD align="left">#DateFormat(Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(Contract_End_Date, "mm/dd/yyyy")#&nbsp;</TD>
		</TR>
		<TR>
			<TD>R/3 Agreement/Sales Deal number: </TD>
			<TD align="left">#Contract_reference_Number#&nbsp;</TD>
		</TR>
		</TABLE>
		</TD>
	</TR>
	<TR>
		<TD class="itemHeading2" align="center">Item ##</TD>
		<TD class="itemHeading2" align="center">Description</TD>		
		<TD class="itemHeading2" align="center">Offered Price</TD>
		<TD class="itemHeading2" align="center">Product Price</TD>		
		<TD class="itemHeading2" align="center">Price Difference</TD>
		<TD class="itemHeading2" align="center">Start Date</TD>
	</TR>
	<cfoutput>
	<TR>
		<TD>#Item#</TD>
		<TD>#Description#</TD>		
		<TD>#Offered_Price# / #UOMDesc#</TD>
		<TD>#Product_Price# / #UOMDesc#</TD>		
		<TD>#NumberFormat(Price_Difference, "-.__")# / #UOMDesc#</TD>
		<TD>#DateFormat(Start_Date, "mm/dd/yyyy")#</TD>
	</TR>
	</cfoutput>
</cfoutput>
</table>

</body>
</html>
</cfsavecontent>

<cfif qGetProgramPricingChange.recordCount GT 0>

	<cfset dirName = ExpandPath("Pricing_Reports")>
	<cfif NOT DirectoryExists(dirName)>
		<cfdirectory action="create" directory="#dirName#">
	</cfif>
	
	<cfparam name="request.AccessStructure.USER_ID" 	default="0000000000">
	
	<cfset toEmail = "" />
	<cfset toEmail = ListAppend(toEmail, "dkunnath@bigredflame.com", ";") />
	<!------ 
	<cfset toEmail = ListAppend(toEmail, "J.R.Houchin@conagrafoods.com", ";") />
	<cfset toEmail = ListAppend(toEmail, "Joel.Hilgemann@conagrafoods.com", ";") />
	<cfset toEmail = ListAppend(toEmail, "amcclelland@bigredflame.com", ";") />
	<cfset toEmail = ListAppend(toEmail, "", ";") />
	 ----->
	
	<CF_Writing_Email_Attachment
		Naming_Format = "Pricing_Report_#DateFormat(Now(), "mmddyyyy")#"
		File_Extension = "html"
		Relative_Path = "/Scheduled/Pricing_Reports"
		Output_Content = "#priceChangeReport#"
		Return_File_Name = "Saved_File_Path"
		addNewLine = "No"
		>
		
	<cfmail to = "#toEmail#"
			from = "dkunnath@bigredflame.com"
	      	subject = "Price Change Report"		
			>
			Price change log initiated from #CGI.SERVER_NAME# on #DateFormat(Now(), "mm/dd/yyyy")# #TimeFormat(Now(), "hh:mm:ss tt")#
			<cfmailparam file="#Saved_File_Path#" />
	</cfmail>
	
	<cfquery name="qUpdateProgramPricingChange" datasource="#application.datasource#">
		UPDATE	Program_Pricing_Change SET Program_Pricing_Change.Report_Sent = 1
		FROM	Program_Pricing_Change
				INNER JOIN Contract_Main
				ON
				Contract_Main.Deleted = 0
				AND Contract_Main.Contract_Main_ID = Program_Pricing_Change.Program_ID
				AND Contract_Main.Contract_Status_Type_IDX <= 6
				<!------ TODO: ----->
				<!------ AND Contract_Main.Sent_To_External_Client = 1 ----->
				INNER JOIN BSA_Foodservice_Items_Master
				ON
				BSA_Foodservice_Items_Master.Deleted = 0
				AND BSA_Foodservice_Items_Master.BSA_Foodservice_Items_Master_ID = 	Program_Pricing_Change.Product_ID
				INNER JOIN Units_of_Measure
				ON
				Units_of_Measure.Unit_of_Measure_ID = Program_Pricing_Change.Price_UOM
		WHERE	Program_Pricing_Change.Deleted = 0
				AND Program_Pricing_Change.Report_Sent = 0
	</cfquery>

</cfif>

