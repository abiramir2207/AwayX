<cfparam name="form.chkYes" default="0">
<cfparam name="form.SubmitForm" default="0">
<cfparam name="ImportCriteria" default="">
<cfparam name="ImportAll" default="0">
<cfparam name="ImportRecordcount" default="0">

<!--- Either "Discountype" OR "Volume" parameter will be passed to this page. "Discountype" parameter will be passed from the
product add window and the "volume" parameter will be passed while editing volume --->
<cfparam name="Discountype" default="0">
<cfparam name="Volume" default="0">

<script language="javascript">
	function ParentPageFunction()
	{
		if(<cfoutput>#Volume#</cfoutput> == 1)
		{
			window.opener.edit_volume();
		}

		else if (<cfoutput>'#ImportCriteria#'</cfoutput> != '')
		{
			window.opener.submitForm(<cfoutput>'#ImportCriteria#'</cfoutput>);
		}

		else if (<cfoutput>#ImportAll#</cfoutput> != 0)
		{
			window.opener.SubmitFormOnImportAllProducts(<cfoutput>#ImportRecordcount#</cfoutput>);			
		}

		else
		{
			window.opener.SubmitFormOnfinishedSearching();
		}
	}
</script>

<cfif form.chkYes eq 0>
	<cfif SubmitForm eq 0>

				<cfquery name="GetMessage" datasource="#application.datasource#">
					SELECT 
						<cfif Discountype eq 1>
							Program_Control_Panel_Options.Discount_Fixed_Prices_Product_Message
						<cfelseif  Discountype eq 2>
							Program_Control_Panel_Options.Discount_Rebates_Product_Message
						<cfelseif  Discountype eq 3>
							Program_Control_Panel_Options.Discount_Lump_Sums_Product_Message
						<cfelseif  Discountype eq 4>
							Program_Control_Panel_Options.Discount_Growth_Product_Message
						<cfelseif  Discountype eq 5>	
							Program_Control_Panel_Options.Discount_Formula_Pricing_Product_Message
						<cfelseif  Discountype eq 8>	
							Program_Control_Panel_Options.Discount_OffInvoice_Product_Message
						<cfelseif  Discountype eq 10>
							Program_Control_Panel_Options.Discount_BidRequest_Product_Message
						<cfelseif  Volume eq 1>
							Program_Control_Panel_Options.Volume_Related_Message
						</cfif>
						 As ProductMessage
					FROM Contract_Main
						INNER JOIN	Program_Control_Panel_Options
						ON (Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID)
					WHERE Contract_Main_ID = #Program_ID#
				</cfquery>

				<cfoutput>
				<form action="#cgi.SCRIPT_NAME#" method="post" name="frmMessage">
				<table border="0" align="center">
					<tr>
						<td><span style="color:red;font-face:Verdana,Arial,Helvetica,sans-serif">NOTE:</span></td>
					</tr>
					<tr>
						<td><span style="color:red;font-face:Verdana,Arial,Helvetica,sans-serif">#GetMessage.ProductMessage#</span></td>
					</tr>	
					<tr>
						<td align="center">
							<input type="submit" value="OK" onClick="frmMessage.submit();ParentPageFunction();window.close();">
						</td>
					</tr>
					<tr>
						<td><input type="checkbox" name="chkYes" value="1">
								<span style="font-face:Verdana,Arial,Helvetica,sans-serif">Do not show this message again</span>
						</td>
					</tr>
				</table>
					<input type="hidden" name="Program_ID" value="#Program_ID#">
					<input type="hidden" name="Discountype" value="#Discountype#">
					<input type="hidden" name="Volume" value="#Volume#">
					<input type="hidden" name="ImportCriteria" value="#ImportCriteria#">
					<input type="hidden" name="SubmitForm" value="1">
					<input type="hidden" name="ImportAll" value="#ImportAll#">
					<input type="hidden" name="ImportRecordcount" value="#ImportRecordcount#">				
				</form>
				</cfoutput>
	 </cfif>

<cfelse>

			<!--- Do not show the message for this program --->
				<cfquery name="updProductMessage" datasource="#application.datasource#">
					UPDATE Contract_Main_Aux_Data
					SET 
					<cfif Discountype eq 1>
					Show_Fixed_Prices_Related_Message = 0
					<cfelseif  Discountype eq 2>
					Show_Rebates_Related_Message = 0
					<cfelseif  Discountype eq 3>
					Show_Lump_Sums_Related_Message = 0
					<cfelseif  Discountype eq 4>
					Show_Growth_Related_Message = 0
					<cfelseif  Discountype eq 5>
					Show_Formula_Pricing_Related_Message = 0
					<cfelseif  Discountype eq 8>
					Show_OffInvoice_Related_Message = 0
					<cfelseif  Discountype eq 10>
					Show_BidRequest_Related_Message = 0
					<cfelseif Volume eq 1>
					Show_Volume_Related_Message = 0
					</cfif>
					WHERE Contract_Main_ID = #Program_ID#
				</cfquery>

</cfif>