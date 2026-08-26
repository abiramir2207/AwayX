<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
<CFSET URL.PageTitle="PROJECTS: UnknownPayee Bank Info">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</head>

<body>

<!--- Currency --->
<cfset useLakebaseForCurrency = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForCurrency>
	<cftry>
		<cfset Currency = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"ledger_id" = "eq.#URL.LRID#",
				"select" = "curr_symbol"
			}), "curr_symbol"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCurrency = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCurrency>
<CFQUERY NAME = "Currency" DATASOURCE = "#Application.datasource#">
	SELECT curr_symbol FROM Ledger_Table Where Ledger_ID = #URL.LRID#	
</CFQUERY>
</cfif>

<!--- <CFPARAM NAME = "URL.State_code" default = ""> --->
<!--- State code --->
<CFQUERY NAME="getStates" datasource="#application.datasource#">
	Select s.*, c.Country_Sort_Order
	from _states s
	join _country c on s.Country_ID = c.Country_ID
	ORDER BY  isnull(c.Country_Sort_Order, c.country_id) ASC
</CFQUERY>
<!--- Country code --->
<cfset useLakebaseForgetCountry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_country")>
<cfif useLakebaseForgetCountry>
	<cftry>
		<cfset getCountry = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_country", {
				"active" = "eq.1",
				"order" = "country_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCountry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCountry>
<CFQUERY NAME="getCountry" datasource="#application.datasource#">
	SELECT *
	FROM _Country
	where active = 1
	ORDER BY Country_id ASC
</CFQUERY>
</cfif>
<!--- Bank_Address --->
<SCRIPT type = "text/javascript">
function restrictLength(thisobj,valueLength)
		{
			if(event.type == "keypress")
			{
				if(thisobj.value.length >= valueLength)
				{
					return false;
				}
			}			
			if(event.type == "paste")
			{
				var fullData = thisobj.value + window.clipboardData.getData("Text");
				if(fullData.length >= valueLength)
				{	
					thisobj.value = fullData.substr(0,valueLength);
					return false;
				}
			}
			
			return true;
		}
</SCRIPT>

<!--- Location --->	
<SCRIPT language="javascript">
	function Change_Address(thisObj)
	{
		var trState = document.all.TR_CITY_STATE;		
		if(trState)
		{
			var chObjs = document.all[thisObj.name];
			if(chObjs[0].checked)
			{				
				document.all.Customer_Bank_City.disabled = false;
				document.all.Customer_Bank_Statecode.disabled = false;
				document.all.Customer_Bank_Zipcode.disabled = false;
				trState.style.display = "";
			}
			else
			{
				document.all.Customer_Bank_City.disabled = true;
				document.all.Customer_Bank_Statecode.disabled = true;
				document.all.Customer_Bank_Zipcode.disabled = true;
				trState.style.display = "none";
			}
		}
	}
</SCRIPT>




<!--- number check --->
<SCRIPT LANGUAGE="JavaScript" SRC="/script/javascript/string_functions.js"></SCRIPT>



<FORM action="UnknownPayee_Bank_Info_Action.cfm" method="post">
	<CFOUTPUT>
		<INPUT TYPE = "hidden" NAME = "new_bb_check" VALUE = "#url.new_bb_check#">
		<INPUT TYPE = "hidden" NAME = "trans_type" VALUE = "#url.Trans_type#">
		<INPUT TYPE = "hidden" NAME = "LRID" VALUE = "#url.LRID#">
		<INPUT TYPE = "hidden" NAME = "Category" VALUE = "UnknownPayee">
		
	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" WIDTH="725">
		<TR>
			<TD VALIGN = "top" ALIGN="right" NOWRAP><b>Payee Name</b></TD>
			<TD VALIGN = "top"><INPUT SIZE = "45" TYPE = "text" NAME = "Payee_Name" VALUE = "<CFIF isdefined("URL.payee_name")>#URL.Payee_Name#</CFIF>"></TD>
		</TR>
		<TR>
			<TD VALIGN = "top" ALIGN="right" NOWRAP><b>Payee_Address</b></TD>
			<TD VALIGN = "top">
				<TEXTAREA COLS="47" ROWS="2" NAME="Address1" onPaste="javaScript: return restrictLength(this,255);" onKeyPress="javaScript: return restrictLength(this,255);" ><CFIF isdefined("URL.Address1")>#URL.Address1#</CFIF></TEXTAREA>
				<!--- <INPUT SIZE="45" NAME="Address1" VALUE="<CFIF isdefined("URL.Address1")>#URL.Address1#</CFIF>"> ---><br>
				<TEXTAREA COLS="47" ROWS="2" NAME="Address2" onPaste="javaScript: return restrictLength(this,255);" onKeyPress="javaScript: return restrictLength(this,255);" ><CFIF isdefined("URL.Address2")>#URL.Address2#</CFIF></TEXTAREA>
				<!--- <INPUT SIZE="45" NAME="Address2" VALUE="<CFIF isdefined("URL.Address2")>#URL.Address2#</CFIF>"> ---><br>
			</TD>
		</TR>
		<TR>
			<TD VALIGN = "top" ALIGN="right" NOWRAP><b>City/State/Postal</b></TD>
			<TD VALIGN = "TOP">
				<INPUT SIZE="24" NAME="City" VALUE="<CFIF isdefined("URL.City")>#URL.City#</CFIF>">&nbsp;
				<SELECT NAME="State_code"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getStates"><OPTION VALUE="#getStates.State_Code#" <CFIF isdefined("URL.State_code")><CFIF getStates.State_Code EQ URL.State_code> SELECTED</CFIF></CFIF>>#getStates.State_Code#</OPTION></CFLOOP></SELECT>&nbsp;  
				<!--- <INPUT SIZE="3" NAME="State_code" VALUE="<CFIF isdefined("URL.State_Code")>#URL.State_code#</CFIF>">&nbsp; --->
				<INPUT SIZE="4" NAME="Zipcode" VALUE="<CFIF isdefined("URL.Zipcode")>#URL.Zipcode#</CFIF>" MAXLENGTH="10" >&nbsp; <!--- ONKEYUP="clenseText(this,'0123456789')" --->
			
			</TD>
		</TR>

		<TR>
			<TD VALIGN = "top" ALIGN="right" NOWRAP><b>Account No</b></TD>
			<TD VALIGN = "top"><INPUT SIZE = "45" NAME = "Customer_Account_No"></TD>
		</TR>
		<TR>
			<TD VALIGN = "top" ALIGN="right" NOWRAP><b>Transit Routing No</b></TD>
			<TD VALIGN = "top"><INPUT SIZE = "45" NAME = "Customer_Transit_Routing_No" ONKEYUP="clenseText(this,'0123456789')"></TD>
		</TR>
		<TR>
			<TD VALIGN = "top" ALIGN="right" NOWRAP><b>Bank Name</b></TD>
			<TD VALIGN = "top"><INPUT SIZE = "45" TYPE = "text" NAME = "Customer_Bank_Name"></TD>			
		</TR>
		<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><b>Location</b></TD>
						<CFOUTPUT>
						<TD VALIGN="top">
							<CFSET US = "CHECKED">
							<CFSET OUTSIDE_US="">

	 					<CFIF isdefined("URL.new_bb_check")>
							<CFSET STATE = "disabled">
						<cfset useLakebaseForcheck_contury = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("ledger_table")>
<cfif useLakebaseForcheck_contury>
	<cftry>
		<cfset check_contury = application.oLakebase.toQuery(
			application.oLakebase.selectRows("ledger_table", {
				"ledger_id" = "eq.#URL.LRID#",
				"select" = "curr_symbol"
			}), "curr_symbol"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForcheck_contury = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForcheck_contury>
<CFQUERY name = "check_contury" datasource = "#Application.datasource#">
							SELECT Curr_symbol from Ledger_Table where Ledger_ID = #URL.LRID#	
						</CFQUERY>
</cfif>
						
						<CFIF check_contury.curr_symbol EQ "US">
							<!--- <INPUT TYPE = "hidden" NAME = "Customer_Bank_Location" VALUE = "1"> --->
							<CFSET US_ADDRESS = "CHECKED">						 
							<CFSET US = "CHECKED">
							<CFSET OUTSIDE_US = ""> 
						<CFELSE>
							<!--- <INPUT TYPE = "hidden" NAME = "Customer_Bank_Location" VALUE = "0"> --->
							<CFSET US = "">
							<CFSET OUTSIDE_US = "CHECKED"> 				
						</CFIF>
						</CFIF>
							<CFPARAM NAME = "US_Address" default = "">
							<CFPARAM NAME = "state" default = "">
						<!--- <CFIF #Get_Item.Customer_Bank_Location# EQ 0>
							<CFSET US ="">
							<CFSET OUTSIDE_US="CHECKED">
						<CFELSEIF #Get_Item.Customer_Bank_Location# EQ 1 >
							<CFSET US="CHECKED">
							<CFSET OUTSIDE_US="">
						</CFIF>		
 --->
						
						
						<INPUT TYPE = "radio" NAME = "Customer_Bank_Location" VALUE = "1" #US#  onClick="javaScript: Change_Address(this);">United States
						<INPUT TYPE = "radio" NAME = "Customer_Bank_Location" VALUE = "0" #OUTSIDE_US#  onClick="javaScript: Change_Address(this);">Outside United States
						</TD>
						</CFOUTPUT>
					</TR>

					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Bank Address</B></TD>
						<TD VALIGN="top">

							<CFOUTPUT>
								<TEXTAREA COLS="47" ROWS="2" NAME="Customer_Bank_Address" onPaste="javaScript: return restrictLength(this,255);" onKeyPress="javaScript: return restrictLength(this,255);" ></TEXTAREA>
								<!--- <INPUT SIZE="45" NAME="Customer_Bank_Address" VALUE="#Get_Item.Customer_Bank_Address#"> <br>--->
							</CFOUTPUT>
						</TD>
					</TR>
					<TR ID="TR_CITY_STATE"<CFIF Len(US) LTE 0> STYLE="DISPLAY:NONE"</CFIF>>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>City/State/Postal</B></TD>
						<TD VALIGN="top"> 
							<CFOUTPUT>
								<INPUT <CFIF Len(US) LTE 0> DISABLED </CFIF>SIZE="24" NAME="Customer_Bank_City" VALUE="">&nbsp;
								<SELECT <CFIF Len(US) LTE 0> DISABLED  </CFIF>NAME="Customer_Bank_Statecode"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getStates"><OPTION VALUE="#getStates.State_Code#" >#getStates.State_Code#</OPTION></CFLOOP></SELECT>&nbsp;  
								<INPUT <CFIF Len(US) LTE 0> DISABLED </CFIF>NAME="Customer_Bank_Zipcode" VALUE="" TYPE="text" SIZE="4" MAXLENGTH="10">&nbsp;  <!--- ONKEYUP="clenseText(this,'0123456789')" --->
							</CFOUTPUT>
						</TD>
					</TR>
					<TR>
						<TD VALIGN="top" ALIGN="right" NOWRAP><B>Country</B></TD>
						<TD VALIGN="top"> 
							<CFOUTPUT>
								<SELECT NAME="Customer_Bank_Country_Code"><OPTION VALUE="" SELECTED></OPTION><CFLOOP QUERY="getCountry"><OPTION VALUE="#getCountry.Country_Code#" <CFIF isdefined("URL.country_code")><CFIF getStates.country_code EQ URL.country_code> SELECTED</cfif></CFIF>>#getCountry.Country_Name#</OPTION></CFLOOP></SELECT>&nbsp;  
							</CFOUTPUT>
						</TD>
					</TR>
		

		
		<TR>
			<TD VALIGN = "top" ALIGN="right" NOWRAP><INPUT TYPE = "submit" VALUE = "Save"</TD>
		</TR>
	</TABLE>
	</CFOUTPUT>
</FORM>


</body>
</html>
