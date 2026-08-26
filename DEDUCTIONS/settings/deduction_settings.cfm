<!---
Document Name:	deduction_settings.cfm
Directory:		/deductions/settings
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	September 26, 2003

Control panel settings for various
--->

<cfset error="">

<!---If the form has been submitted--->
<cfif isDefined("form.blnSubmit")>
	
	<cfset useLakebaseForUpdateorInsert = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
	<cfif useLakebaseForUpdateorInsert>
		<cftry>
			<cfset UpdateorInsert = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deduction_settings", {})
			)>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForUpdateorInsert = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForUpdateorInsert>
	<cfquery name="UpdateorInsert" datasource="#application.datasource#">
	SELECT * FROM Deduction_Settings
	</cfquery>
	</cfif>
	
	<cfif UpdateorInsert.RecordCount IS 1>

		<cfset useLakebaseForUpdateSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
		<cfif useLakebaseForUpdateSettings>
			<cftry>
				<cfset application.oLakebase.updateRows("deduction_settings",
					{ "deduction_settings_id" = "eq.#Deduction_Settings_ID#" },
					{
						"billback" = Billback,
						"osandd" = OSandD,
						"pricing" = Pricing,
						"invoices" = Invoices,
						"excandadj" = ExcandAdj,
						"glcodes" = GLCodes,
						"rebill" = Rebill,
						"images" = Images,
						"use_cleared_amount" = Use_Cleared_Amount,
						"require_bb_to_close" = Require_BB_To_Close,
						"last_changed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
						"changedby" = request.AccessStructure.User_ID,
						"program" = Program
					}
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForUpdateSettings = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForUpdateSettings>
		<cfquery name="UpdateSettings" datasource="#application.datasource#">
		UPDATE Deduction_Settings
		SET Billback 	= 	#Billback#,
			OSandD 		= 	#OSandD#,	
			Pricing		=	#Pricing#,
			Invoices	= 	#Invoices#,
			ExcandAdj	= 	#ExcandAdj#,
			GLCodes		=	#GLCodes#,
			Rebill		=	#Rebill#,		
			Images 		= 	#Images#,	
			Use_Cleared_Amount	= 	#Use_Cleared_Amount#,
			Require_BB_To_Close = #Require_BB_To_Close#,
			Last_Changed=	#createodbcdatetime(Now())#,
			ChangedBy 	=	'#request.AccessStructure.User_ID#',
			Program = #Program#
		WHERE Deduction_Settings_ID = #Deduction_Settings_ID#
		</cfquery>
		</cfif>
		<!--- 	Trade		=	#Trade#,
				Auto_Close	=	#Auto_Close#,
				AC_Dollar	=	#AC_Dollar#, --->
		
		<!---Other than one record to update--->
		<cfelse>	

			<!---Delete in case there are more than one--->
			<cfset useLakebaseForDeleteinCase = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
			<cfif useLakebaseForDeleteinCase>
				<cftry>
					<cfset application.oLakebase.deleteRows("deduction_settings", {})>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForDeleteinCase = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForDeleteinCase>
			<cfquery name="DeleteinCase" datasource="#application.datasource#">
			DELETE FROM Deduction_Settings
			</cfquery>
			</cfif>
	
			<!---Insert new value--->
			<cfset useLakebaseForInsertNewValue = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
			<cfif useLakebaseForInsertNewValue>
				<cftry>
					<cfset application.oLakebase.insertRow("deduction_settings", {
						"billback" = Billback,
						"osandd" = OSandD,
						"pricing" = Pricing,
						"invoices" = Invoices,
						"excandadj" = ExcandAdj,
						"glcodes" = GLCodes,
						"rebill" = Rebill,
						"images" = Images,
						"use_cleared_amount" = Use_Cleared_Amount,
						"require_bb_to_close" = Require_BB_To_Close,
						"last_changed" = dateTimeFormat(now(), "yyyy-mm-dd'T'HH:nn:ss"),
						"changedby" = request.AccessStructure.User_ID,
						"program" = Program
					})>
					<cfcatch type="any">
						<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
						<cfset useLakebaseForInsertNewValue = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForInsertNewValue>
			<cfquery name="InsertNewValue" datasource="#application.datasource#">
			INSERT INTO Deduction_Settings
			(
				Billback,	
				OSandD,		
				Pricing,	
				Invoices,	
				ExcandAdj, 	
				GLCodes,
				Rebill,			
				Images, 		
				Use_Cleared_Amount,
				Require_BB_To_Close,
				Last_Changed,	
				ChangedBy,
				Program	
			)
			VALUES
			(
				#Billback#,
				#OSandD#,
				#Pricing#,
				#Invoices#,
				#ExcandAdj#,
				#GLCodes#,
				#Rebill#,
				#Images#,
				#Use_Cleared_Amount#,
				#Require_BB_To_Close#,
				#createodbcdatetime(Now())#,
				'#request.AccessStructure.User_ID#',
				#Program#
			)
			</cfquery>
		
		</cfif>

</cfif>
<!---End form has been submitted logic--->

<HTML>
<HEAD>
	<TITLE>Deviation Settings</TITLE>

	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/formattotwodecimals.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>

<script>

var ErrorCount = 0;
function confirmCompletion()
{	
	var ErrorCount = 0;
	
		/*if(document.all.AC_dollar.value.length == 0)
		{
			ErrorCount++;
			queueMessage("You must have an auto close amount, even if that amount is 0", document.all.error_AC_dollar);
		}
		else
		{
			clearQueue(document.all.error_AC_dollar);
		}*/
			
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
			if(confirm("Are you sure you want to change these settings?"))
			{
				Deductions.submit()
			}
	}
	else 
	{
		showMessageWindow()
	}	
}

function oneDecimal(textObject)	{
	var inputText = textObject.value;
	if(inputText.length != 0){
		//look for an existing decimal
		DecimalLocation = inputText.indexOf(".")
		if(DecimalLocation != -1) 
		{
			if (DecimalLocation > 1)
			{
			alert("The ratio cannot be greater than 9.99 to 1");
			textObject.value = textObject.value.substr(DecimalLocation-1)
			}
		}
		else {
		
			if(inputText.length > 1)
			{
				alert("The ratio cannot be greater than 9.99 to 1");
				textObject.value = textObject.value.substring(0, inputText.length-1)
				
			}
			//textObject.value = inputText + ".00";
		}
	}
}

</SCRIPT>

<CF_MessageWindow>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">

<CFSET pagetitle = "Deviation Settings">

<!---Displays the page title set above--->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">

<!--- Gets the date that this setting was updated --->
<cfset useLakebaseForGet_Deduction_Settings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deduction_settings")>
<cfif useLakebaseForGet_Deduction_Settings>
	<cftry>
		<cfset Get_Deduction_Settings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deduction_settings", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Deduction_Settings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Deduction_Settings>
<CFQUERY NAME="Get_Deduction_Settings" DATASOURCE="#application.datasource#">
SELECT * FROM Deduction_Settings
</CFQUERY>
</cfif>
<!---
 	--Deduction_Settings.Trade,
	--Deduction_Settings.Auto_Close,
	--Deduction_Settings.AC_Dollar, 
 --->

<cfif len(trim(Get_Deduction_Settings.ChangedBy)) GT 0>
	<cfset useLakebaseForGetChangerName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetChangerName>
	<cftry>
		<cfset GetChangerName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#Get_Deduction_Settings.ChangedBy#",
				"select" = "name_first,name_last"
			}), "name_first,name_last"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetChangerName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetChangerName>
<cfquery name="GetChangerName" datasource="#application.datasource#">
		SELECT Name_First, Name_Last FROM _Users WHERE User_ID = '#Get_Deduction_Settings.ChangedBy#'
	</cfquery>
</cfif>
	<cfset FirstName = GetChangerName.Name_First>
	<cfset LastName = GetChangerName.Name_Last>
<cfelse>
	<cfset FirstName="Not Yet">
	<cfset LastName="Changed">
</cfif>

<div align="center">
<!--- Set the update/save flag that will be passed to the next page --->
<FORM ACTION="deduction_settings.cfm" METHOD="post" name="Deductions">

<!---Hidden boolean, which, if defined, tells me that the form has been submitted--->
<input type="hidden" name="blnSubmit" value="1">


<CFIF Get_Deduction_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">


	<!---Displays who last updated this information and when--->

	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_Deduction_Settings.Last_Changed,  'm/d/yyy')# #timeformat(Get_Deduction_Settings.Last_Changed, 'h:mm:ss TT')# by #FirstName#  #LastName#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>

</CFIF>


<!---Majority of form goes here--->
<div align="center"><font color="red"><cfoutput>#Error#</cfoutput></font></div>

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0">
		
		<tr><td align="right"><strong>Include area for search by deduction analysts?</strong></td><td><strong>Yes</strong></td><Td><strong>No</strong></TD></tr>
		
		<!---Program--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Billback"></span>
			<B>Program:</B></TD>
			<Td><input type="radio" name="Program" value="1" <cfif Get_Deduction_Settings.Program IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Program" value="0" <cfif Get_Deduction_Settings.Program IS 0> checked</cfif>></TD>
		</TR>
		<!---Billbacks--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Billback"></span>
			<B>Billbacks:</B></TD>
			<Td><input type="radio" name="Billback" value="1" <cfif Get_Deduction_Settings.Billback IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Billback" value="0" <cfif Get_Deduction_Settings.Billback IS 0> checked</cfif>></TD>
		</TR>
		
		<!---Require billback to close--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Billback_To_Close"></span>
			<B>Require an associated billback to close the deduction?:</B></TD>
			<Td><input type="radio" name="Require_BB_To_Close" value="1" <cfif Get_Deduction_Settings.Require_BB_To_Close IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Require_BB_To_Close" value="0" <cfif Get_Deduction_Settings.Require_BB_To_Close IS 0> checked</cfif>></TD>
		</TR>
		
		<!---OS&D--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_OSandD"></span>
			<B>OS&amp;D:</B></TD>
			<Td><input type="radio" name="OSandD" value="1" <cfif Get_Deduction_Settings.OSandD IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="OSandD" value="0" <cfif Get_Deduction_Settings.OSandD IS 0> checked</cfif>></TD>
		</TR>
		
		<!---Pricing--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Pricing"></span>
			<B>Pricing:</B></TD>
			<Td><input type="radio" name="Pricing" value="1" <cfif Get_Deduction_Settings.Pricing IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Pricing" value="0" <cfif Get_Deduction_Settings.Pricing IS 0> checked</cfif>></TD>
		</TR>
		
		<!---Invoices--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Invoices"></span>
			<B>Invoices:</B></TD>
			<Td><input type="radio" name="Invoices" value="1" <cfif Get_Deduction_Settings.Invoices IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Invoices" value="0" <cfif Get_Deduction_Settings.Invoices IS 0> checked</cfif>></TD>
		</TR>
		
		<!---Exclusions and Adjustments--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_ExcAndAdj"></span>
			<B>Exclusions and Adjustments:</B></TD>
			<Td><input type="radio" name="ExcAndAdj" value="1" <cfif Get_Deduction_Settings.ExcAndAdj IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="ExcAndAdj" value="0" <cfif Get_Deduction_Settings.ExcAndAdj IS 0> checked</cfif>></TD>
		</TR>
		
		<!---Exclusions and Adjustments--->
		<!--- 
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Trade"></span>
			<B>Trade Earned:</B></TD>
			<Td><input type="radio" name="Trade" value="1" <cfif Get_Deduction_Settings.Trade IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Trade" value="0" <cfif Get_Deduction_Settings.Trade IS 0> checked</cfif>></TD>
		</TR>
		 --->
		<!--- 
		<!---General Ledger Codes--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_GLCodes"></span>
			<B>General Ledger Codes:</B></TD>
			<Td><input type="radio" name="GLCodes" value="1" <cfif Get_Deduction_Settings.GLCodes IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="GLCodes" value="0" <cfif Get_Deduction_Settings.GLCodes IS 0> checked</cfif>></TD>
		</TR> --->
		<input type="hidden" name="GLCodes" value="0">
		
		<!--- Images --->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Images"></span>
			<B>Images:</B></TD>
			<Td><input type="radio" name="Images" value="1" <cfif Get_Deduction_Settings.Images IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Images" value="0" <cfif Get_Deduction_Settings.Images IS 0> checked</cfif>></TD>
		</TR>
		
		<!--- Cleared Amount --->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_Use_Cleared_Amount"></span>
			<B>Use Cleared Amount:</B></TD>
			<Td><input type="radio" name="Use_Cleared_Amount" value="1" <cfif Get_Deduction_Settings.Use_Cleared_Amount IS 1> checked</cfif>></TD>
			<Td><input type="radio" name="Use_Cleared_Amount" value="0" <cfif Get_Deduction_Settings.Use_Cleared_Amount IS 0> checked</cfif>></TD>
		</TR>
		
		<tr><td colspan="3"><hr color="orange"></tr>
		
		<!---Rebill--->
		<TR>
			<TD align="right" nowrap valign="top">
			<!---Span is for error image--->
			<span id="error_Rebill"></span>
			<B>Who controls rebilling?:</B></TD>
			<Td>
			Blackmith Applications<Br>
			<input type="radio" name="Rebill" value="2" <cfif Get_Deduction_Settings.Rebill IS 2> checked</cfif>>
			</TD>
			<Td>
			<cfoutput>#request.AccessStructure.Company_Name#</cfoutput><br>
			<input type="radio" name="Rebill" value="1" <cfif Get_Deduction_Settings.Rebill IS 1> checked</cfif>>
			</TD>
		</TR>
		
		<tr><td colspan="3"><hr color="orange"></tr>
		
		<!---Auto Close--->
		<!--- 
		<TR>
			<TD align="right" nowrap valign="top">
			<!---Span is for error image--->
			<span id="error_Auto_Close"></span>
			<B>Auto Close?:</B></TD>
			<Td>
					<input type="radio" name="Auto_Close" value="0" <cfif Get_Deduction_Settings.Auto_Close IS 0> checked</cfif>>
			</TD>
			<Td>
					<input type="radio" name="Auto_Close" value="1" <cfif Get_Deduction_Settings.Auto_Close IS 1> checked</cfif>>
			</TD>
		</TR>
		 --->
		<!---Auto Close length--->
		<!--- 
		<TR>
			<TD align="right" nowrap valign="top">
			<!---Span is for error image--->
			<span id="error_AC_dollar"></span>
			<B>Close below what dollar amount?:</B></TD>
			<Td colspan="2">$<input type="text" size="5" name="AC_dollar" value="<cfoutput>#Get_Deduction_Settings.AC_dollar#</cfoutput>" onKeyUp="clenseText(this, '0123456789.');allowonlytwodecimalplaces(this);oneDecimal(this);">
			</TD>
		</TR>
		 --->
		<input type="hidden" name="Deduction_Settings_ID" value="<cfoutput>#Get_Deduction_Settings.Deduction_Settings_ID#</cfoutput>">
		
	</TABLE>
</form>
</div>	
<!---End majority of form--->
<BR>
<div align="center">
<CF_button
		button_name		=	""
		button_caption	=	"Save Preferences..."
		button_action	=	"confirmCompletion();"
		button_type		=	"javascript_link"
		button_width	=	"175"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>
</div>
</BODY>
</HTML>
