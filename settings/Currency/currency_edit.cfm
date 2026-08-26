<cfif isDefined("stError") and stError.bNameExists>
	<script>
		alert("Currency already exists.");
	</script>
</cfif>
<!--- Last edited info --->
<cfif isdefined("qGetCurrencyRebates.Last_Edited_By") AND len(trim(qGetCurrencies.Last_Edited_By)) GT 0 >
	
	<cfquery name="GetUserLastEdited" datasource="#application.datasource#">
	SELECT Name_First + ' ' + Name_Last AS UserLastEdited
	FROM _Users
	WHERE User_ID = '#qGetCurrency.Last_Edited_By#'
	</cfquery>
	<cfif GetUserLastEdited.Recordcount IS 1>
	<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" align="center">
	<TR>
	<TD align="center" width="400px" style="font-size:12px;">
		<B>Last updated on <CFOUTPUT>#dateformat(qGetCurrency.Last_Edited_Date, 'm/d/yyy')# #timeformat(qGetCurrency.Last_Edited_Date, 'h:mm:ss TT')# by #GetUserLastEdited.UserLastEdited#</CFOUTPUT></B></TD>
	</TD>
	</TR>
	</TABLE>
	</cfif>
	<br>
</cfif>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Currency</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Currency Name:</B></TD>
			<TD><INPUT NAME="currencyName" TYPE="text" VALUE="<cfoutput>#qGetCurrency.Currency_Name#</cfoutput>" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Currency Code:</B></TD>
			<TD><INPUT NAME="currencyCode" TYPE="text" VALUE="<cfoutput>#qGetCurrency.Currency_Code#</cfoutput>" SIZE="3" MAXLENGTH="3"></TD>
		</TR>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return upadateCurrency(#qGetCurrency.Currency_ID#);"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</TD>
		</TR>
	</table>
	</FIELDSET>