<!---
Document Name:	peril_age.cfm
Directory:		/scorecard/settings
Author:			Brenda Flynn
Contact:		bflynn@awayx.com
Date Created:	December 16, 2002

This allows an administrator to specify the tolerances for various deviations.
--->
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<cfset error="">
<cfparam name="form.Validate_BB_UOM" 	default="0">
<cfparam name="form.Validate_BB_UOM_Rate_Threshold" 	default="10">
	
<!---If the form has been submitted--->
<cfif isDefined("form.blnSubmit")>
	<cfif len(trim(FORM.BB_Tolerance_DPP)) EQ 0 OR len(trim(FORM.BB_Tolerance_DPP_Rate)) EQ 0 OR len(trim(FORM.BB_Tolerance_DPPO)) EQ 0 OR  len(trim(FORM.BB_Tolerance_BAP)) EQ 0 OR len(trim(FORM.BB_Tolerance_BAPO)) EQ 0 OR len(trim(FORM.BB_Tolerance_DVT)) EQ 0 OR len(trim(FORM.BB_Tolerance_ERT)) EQ 0 >
	<cfset error="You left a required field empty">

<!---All required fields have an entry--->
<cfelse>

	<!---Checks to make sure it's numeric--->
	<cfif isNumeric(FORM.BB_Tolerance_DPP) 
	AND isNumeric(FORM.BB_Tolerance_DPP_Rate)
	AND isNumeric(FORM.BB_Tolerance_DPPO) 
	AND isNumeric(FORM.BB_Tolerance_BAP) 
	AND isNumeric(FORM.BB_Tolerance_BAPO) 
	AND isNumeric(FORM.BB_Tolerance_DVT) 
	>
	
		<!---Inserts if there are no previous values--->
		<cfif form.up_sv IS 0>
		
		<cfquery name="Insert_Tolerance_Info" datasource="#application.datasource#">

			INSERT INTO Billback_Settings
			(User_ID, 
			BB_Tolerance_DPP, 
			BB_Tolerance_DPP_Rate,
			BB_Tolerance_DPPO,
			BB_Tolerance_BAP,
			BB_Tolerance_BAPO,
			BB_Tolerance_DVT,
			BB_Tolerance_ERT,
			BB_Tolerance_TET,
			BB_Start_Offset_Days,
			BB_End_Offset_Days,
			Validate_BB_UOM,
			Validate_BB_UOM_Rate_Threshold,
			BB_Tolerance_Update_Date,
			BB_Tolerance_Editor_ID)
			VALUES
			('#request.AccessStructure.Company_Main_ID#', 
			'#FORM.BB_Tolerance_DPP#',
			'#FORM.BB_Tolerance_DPP_Rate#',
			#int(FORM.BB_Tolerance_DPPO)#,
			'#FORM.BB_Tolerance_BAP#',
			#int(FORM.BB_Tolerance_BAPO)#,
			#int(FORM.BB_Tolerance_DVT)#,
			'#FORM.BB_Tolerance_ERT#',
			#int(FORM.BB_Tolerance_TET)#,
			#val(FORM.BB_Start_Offset_Days)#,
			#val(FORM.BB_End_Offset_Days)#,
			#val(FORM.Validate_BB_UOM)#,
			#val(FORM.Validate_BB_UOM_Rate_Threshold)#,
			#createodbcdatetime(Now())#, 
			'#request.AccessStructure.User_ID#')
			</cfquery>
		<cfelse>

		<cfquery name="Update_Tolerance_Info" datasource="#application.datasource#">
		UPDATE Billback_Settings
		SET 
		BB_Tolerance_DPP		= #Form.BB_Tolerance_DPP#,	
		BB_Tolerance_DPP_Rate	= #Form.BB_Tolerance_DPP_Rate#,
		BB_Tolerance_DPPO		= #int(Form.BB_Tolerance_DPPO)#,	
		BB_Tolerance_BAP		= #Form.BB_Tolerance_BAP#,	
		BB_Tolerance_BAPO		= #int(Form.BB_Tolerance_BAPO)#,	
		BB_Tolerance_DVT		= #int(Form.BB_Tolerance_DVT)#,
		BB_Tolerance_ERT		= '#Form.BB_Tolerance_ERT#',	
		BB_Tolerance_TET		= '#Form.BB_Tolerance_TET#',
		BB_Start_Offset_Days	= '#val(Form.BB_Start_Offset_Days)#',
		BB_End_Offset_Days		= '#val(Form.BB_End_Offset_Days)#',
		Validate_BB_UOM			= #val(FORM.Validate_BB_UOM)#,
		Validate_BB_UOM_Rate_Threshold = #val(FORM.Validate_BB_UOM_Rate_Threshold)#,
		BB_Range_Update_Date 	= #createodbcdatetime(Now())#,
		BB_Tolerance_Update_Date = #createodbcdatetime(Now())#,
		BB_Tolerance_Editor_ID	 	= '#request.AccessStructure.User_ID#'
		<!---WHERE User_ID			= '#request.AccessStructure.Company_Main_ID#'--->
		</cfquery>
		
		</cfif>
		<CFLOCATION ADDTOKEN="No" URL="expectations.cfm">
	<!---Is numeric--->
	</cfif>	
<!---Is defined--->
</cfif>
	
</cfif>
<!---End form has been submitted logic--->

<HTML>
<HEAD>
	<TITLE>Billback Tolerance Settings</TITLE>

	<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/formattotwodecimals.js"></SCRIPT>
	<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>

<script>

var ErrorCount = 0;
function confirmCompletion()
{
	var ErrorCount = 0;
	
<!--- Distributor Purchase Period Ratio - Volume --->
		if(document.all.BB_Tolerance_DPP.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio for Volume is a required field", document.all.error_BB_Tolerance_DPP);
		}		
		else if(document.all.BB_Tolerance_DPP.value == 0)
		{
			ErrorCount++;
			queueMessage("<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio for Volume must be greater than 0 to 1", document.all.error_BB_Tolerance_DPP);
		}
		else
		{
			clearQueue(document.all.error_BB_Tolerance_DPP);
		}
<!--- Distributor Purchase Period Ratio - Rate --->
		if(document.all.BB_Tolerance_DPP_Rate.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio for Rate is a required field", document.all.error_BB_Tolerance_DPP_Rate);
		}		
		else if(document.all.BB_Tolerance_DPP_Rate.value == 0)
		{
			ErrorCount++;
			queueMessage("<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio for Rate must be greater than 0 to 1", document.all.error_BB_Tolerance_DPP_Rate);
		}
		else
		{
			clearQueue(document.all.error_BB_Tolerance_DPP_Rate);
		}
	<!--- Distributor Purchase Period Offset --->
		if(document.all.BB_Tolerance_DPPO.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Offset is a required field", document.all.error_BB_Tolerance_DPPO);
		}
		else
		{
			clearQueue(document.all.error_BB_Tolerance_DPPO);
		}
		
	<!--- Billback Aggregation Period Ratio --->
		if(document.all.BB_Tolerance_BAP.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("Billback Aggregation Period Ratio is a required field", document.all.error_BB_Tolerance_BAP);
		}
		else
		{
			clearQueue(document.all.error_BB_Tolerance_BAP);
		}
		
		<!--- Billback Aggregation Period Offset --->
		if(document.all.BB_Tolerance_BAPO.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("Billback Aggregation Period Offset is a required field", document.all.error_BB_Tolerance_BAPO);
		}
		else
		{
			clearQueue(document.all.error_BB_Tolerance_BAPO);
		}
	
	<!--- Delivered Rate Tolerance --->
		if(document.all.BB_Tolerance_DVT.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("Delivered Rate Tolerance is a required field", document.all.error_BB_Tolerance_DVT);
		}
		else
		{
			clearQueue(document.all.error_BB_Tolerance_DVT);
		}
	
	<!--- FOB Rate Tolerance --->
		if(document.all.BB_Tolerance_ERT.value.length == 0)	
		{
			ErrorCount++;
			queueMessage("Rate Tolerance is a required field", document.all.error_BB_Tolerance_ERT);
		}
		else
		{
			clearQueue(document.all.error_BB_Tolerance_ERT);
		}
		
<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0) 
	{
		if(confirm("Press OK if all information is correct"))
		{
			Tolerance.submit()
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

/***************************************************************************************
   Added for making the DPP Ratio and BAP Ratio to accept double digit values max 99.99 
   Label No: D18095 - Anand Rao 02/09/09
***************************************************************************************/
function twoDecimal(textObject)	{
	var inputText = textObject.value;
	if(inputText.length != 0){
		//look for an existing decimal
		DecimalLocation = inputText.indexOf(".")
		if(DecimalLocation != -1) 
		{
			if (DecimalLocation > 2)
			{
			alert("The ratio cannot be greater than 99.99 to 1");
			textObject.value = textObject.value.substr(DecimalLocation-1)
			}
		}
		else {
		
			if(inputText.length > 2)
			{
				alert("The ratio cannot be greater than 99.99 to 1");
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

<CFSET pagetitle = "Billback: Tolerance Settings">

<!---Displays the page title set above--->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">


<!--- Gets the date that this setting was updated --->
<CFQUERY NAME="Get_Tolerance_Settings" DATASOURCE="#application.datasource#">
SELECT	Billback_Settings.BB_Tolerance_DPP,
		Billback_Settings.BB_Tolerance_DPP_Rate,
		Billback_Settings.BB_Tolerance_DPPO,
		Billback_Settings.BB_Tolerance_BAP,
		Billback_Settings.BB_Tolerance_BAPO,
		Billback_Settings.BB_Tolerance_DVT,
		Billback_Settings.BB_Tolerance_ERT,
		Billback_Settings.BB_Tolerance_TET,
		Billback_Settings.BB_Start_Offset_Days,
		Billback_Settings.BB_End_Offset_Days,
		Billback_Settings.Validate_BB_UOM,
		Billback_Settings.Validate_BB_UOM_Rate_Threshold,
		Billback_Settings.BB_Tolerance_Update_Date,
		_Users.Name_First,
		_Users.Name_Last
FROM	Billback_Settings
		LEFT JOIN _Users
		ON
		_Users.User_ID = Billback_Settings.BB_Tolerance_Editor_ID
<!---WHERE	Billback_Settings.User_ID		=		'#request.AccessStructure.Company_Main_ID#'--->
</CFQUERY>

<!--- Set the update/save flag that will be passed to the next page --->
<FORM ACTION="expectations.cfm" METHOD="post" name="Tolerance">

<!---Hidden boolean, which, if defined, tells me that the form has been submitted--->
<input type="hidden" name="blnSubmit" value="1">

<CFIF Get_Tolerance_Settings.recordcount EQ 0>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="0">
<CFELSE>
	<INPUT TYPE="hidden" NAME="up_sv" VALUE="1">
	
	<!---Displays who last updated this information and when--->
	<CFIF Get_Tolerance_Settings.BB_Tolerance_Update_Date NEQ "">
	<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(Get_Tolerance_Settings.BB_Tolerance_Update_Date,  'm/d/yyy')# #timeformat(Get_Tolerance_Settings.BB_Tolerance_Update_Date, 'h:mm:ss TT')# by #Get_Tolerance_Settings.Name_First#  #Get_Tolerance_Settings.Name_Last#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
	</TABLE>
	<BR>
	</CFIF>
</CFIF>


<!---Majority of form goes here--->
<div align="center"><font color="red"><cfoutput>#Error#</cfoutput></font></div>

	<TABLE BORDER="0" CELLSPACING="10" CELLPADDING="0" ALIGN="center">
		
		
		<!---Distributor Purchase Period Volume--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Tolerance_DPP"></span>
			<B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio for Volume:</B></TD>
			<td rowspan="10" bgcolor="orange" width="2"><img src="/images/nothing_small.gif" width="2" height="1"></td>
			<TD>
			&nbsp; <input type="text" name="BB_Tolerance_DPP" size="5" maxlength="5" <cfif len("Get_Tolerance_Settings.BB_Tolerance_DPP") NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.BB_Tolerance_DPP#</cfoutput>"<cfelse>value="1"</cfif> onKeyUp="clenseText(this, '0123456789.');allowonlytwodecimalplaces(this);twoDecimal(this)"> to 1   
			</TD>
		</TR>
		
		<!---Distributor Purchase Period Rate--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Tolerance_DPP_Rate"></span>
			<B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Ratio for Rate:</B></TD>
			<TD>
			&nbsp; <input type="text" name="BB_Tolerance_DPP_Rate" size="5" maxlength="5" <cfif len("Get_Tolerance_Settings.BB_Tolerance_DPP_Rate") NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.BB_Tolerance_DPP_Rate#</cfoutput>"<cfelse>value="1"</cfif> onKeyUp="clenseText(this, '0123456789.');allowonlytwodecimalplaces(this);twoDecimal(this)"> to 1   
			</TD>
		</TR>
			
		
			<!---Distributor Purchase Period Offset--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Tolerance_DPPO"></span>
			<B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Purchase Period Offset:</B><br>(In days)</TD>
			
			<TD>
			&nbsp; <input type="text" name="BB_Tolerance_DPPO" size="3" maxlength="3" 
			<cfif len("Get_Tolerance_Settings.BB_Tolerance_DPPO") NEQ 0> 
			value="<cfoutput>#Get_Tolerance_Settings.BB_Tolerance_DPPO#</cfoutput>"
			<cfelse> value="0" </cfif> 
			onKeyUp="clenseText(this, '0123456789');">  
			</TD>
		</TR>
		
		<!---Billback Aggregation Period--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Tolerance_BAP"></span>
			<B>Billback Aggregation Period Ratio:</B><br></TD>
			
			<TD>
			&nbsp; <input type="text" name="BB_Tolerance_BAP" size="5" maxlength="5" 
			<cfif len("Get_Tolerance_Settings.BB_Tolerance_BAP") NEQ 0> 
			value="<cfoutput>#Get_Tolerance_Settings.BB_Tolerance_BAP#</cfoutput>"
			<cfelse> value="1" </cfif> 
			onKeyUp="clenseText(this, '0123456789.');allowonlytwodecimalplaces(this);twoDecimal(this);"> to 1  
			</TD>
		</TR>
		
		<!---Billback Aggregation Period Offset--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Tolerance_BAPO"></span>
			<B>Billback Aggregation Period Offset:</B><br>(In days)<br></TD>
			
			<TD>
			&nbsp; <input type="text" name="BB_Tolerance_BAPO" size="3" maxlength="3" <cfif len("Get_Tolerance_Settings.BB_Tolerance_BAPO") NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.BB_Tolerance_BAPO#</cfoutput>"<cfelse>value="0"</cfif> onKeyUp="clenseText(this, '0123456789');"> 
			</TD>
		</TR>
		
		<!---Distributor Volume Tolerance--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Tolerance_DVT"></span>
			<B><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Volume Tolerance:</B><br>(Whole percent difference)<br></TD>
			
			<TD>
			&nbsp; <input type="text" name="BB_Tolerance_DVT" size="3" maxlength="2" <cfif len("Get_Tolerance_Settings.BB_Tolerance_DVT") NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.BB_Tolerance_DVT#</cfoutput>"<cfelse>value="0"</cfif> onKeyUp="clenseText(this, '0123456789');">% 
			</TD>
		</TR>
		
		<!---Delivered Rate Tolerance--->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Tolerance_ERT"></span>
			<B>Rate Tolerance:</B><br>(Whole percent)<br></TD>
			
			<TD>
			&nbsp; <input type="text" name="BB_Tolerance_ERT" size="3" maxlength="2" <cfif len("Get_Tolerance_Settings.BB_Tolerance_ERT") NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.BB_Tolerance_ERT#</cfoutput>"<cfelse>value="0"</cfif> onKeyUp="clenseText(this, '01234567893');">% 
			</TD>
		</TR>
		
		<cfif application.returned_customer_setting.Permit_Ship_Date IS 1>	
		<!---Trade Eligibility Trigger--->
		<TR>
			<TD align="right" nowrap><B>Trade Eligibility Trigger:</B><br><br></TD>
			
			<TD>
			
			&nbsp; Invoice Date: <input type="radio" name="BB_Tolerance_TET" <cfif Get_Tolerance_Settings.BB_Tolerance_TET EQ 1> checked </cfif> checked value="1">
						
			Ship Date: <input type="radio" name="BB_Tolerance_TET" <cfif Get_Tolerance_Settings.BB_Tolerance_TET EQ 2> checked </cfif> value="2">
			</TD>
		</TR>
		<cfelse>
		<input type="hidden" name="BB_Tolerance_TET" value="1">
		</cfif>
		
		
		<!--- BB Delivery Start Date Offset (in days) --->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_Start_Offset_Days"></span>
			<B>Dist Trade Shelter - BB Delivery Start Date Offset:<br>(In days)</B></TD>
			
			<TD>
			&nbsp; <input type="text" name="BB_Start_Offset_Days" size="3" maxlength="5" <cfif len("Get_Tolerance_Settings.BB_Start_Offset_Days") NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.BB_Start_Offset_Days#</cfoutput>"<cfelse>value="0"</cfif> onKeyUp="clenseText(this, '01234567893');">
			</TD>
		</TR>
		
		<!--- BB Delivery End Date Offset (in days) --->
		<TR>
			<TD align="right" nowrap>
			<!---Span is for error image--->
			<span id="error_BB_End_Offset_Days"></span>
			<B>Dist Trade Shelter - BB Delivery End Date Offset:<br>(In days)</B></TD>
			
			<TD>
			&nbsp; <input type="text" name="BB_End_Offset_Days" size="3" maxlength="5" <cfif len("Get_Tolerance_Settings.BB_End_Offset_Days") NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.BB_End_Offset_Days#</cfoutput>"<cfelse>value="0"</cfif> onKeyUp="clenseText(this, '01234567893');"> 
			</TD>
		</TR>
		
		<!--- BB Delivery End Date Offset (in days) --->
		<TR>
			<TD align="right">
			<!---Span is for error image--->
			<span id="err_Validate_BB_UOM"></span>
			<B>Validate BB UOM is entered correctly:</B>
		</TD>
			
			<TD>
			&nbsp; <INPUT TYPE="Checkbox" NAME="Validate_BB_UOM" VALUE="1"  style="vertical-align:bottom" onClick="javascript: if(this.checked){document.all.Validate_BB_UOM_Rate_Threshold.disabled = false; document.all.Validate_BB_UOM_Rate_Threshold.value='10.00';} else {document.all.Validate_BB_UOM_Rate_Threshold.disabled = true};" <cfif Get_Tolerance_Settings.Validate_BB_UOM EQ "1">checked</cfif>>
			&nbsp;Claimed Rate Threshold&nbsp;<input name="Validate_BB_UOM_Rate_Threshold" name="Validate_BB_UOM_Rate_Threshold" type="text" size="2" maxlength="6" <cfif len(Get_Tolerance_Settings.Validate_BB_UOM_Rate_Threshold) NEQ 0> value="<cfoutput>#Get_Tolerance_Settings.Validate_BB_UOM_Rate_Threshold#</cfoutput>"<cfelse>value="10"</cfif> onkeypress="return Allow_Key_List('0123456789.');" onblur="javaSCript: makeValidIntFloat(this, 0, '0');" <cfif Get_Tolerance_Settings.Validate_BB_UOM NEQ "1">disabled</cfif>>%
			<CF_SmallHelp
					width="300"
					displayShifyX = "-300"
					displayShifyY = "-100"
					imgPath="/images/help_small.gif"
					imgWidth="14"
					imgHeight="13"
					dropdownCheck="0"
					>
					Clients sometimes make the mistake of uploading/entering the billback volume as Cases when it was actually Pounds.  For example, the actual billback was $100 and 100 pounds.  But user uploaded 100 cases and it resolved to 3,000 pounds (assume 30 # case).  When recapture runs, Forge recaptures way too much.  Analytics will also have an issue with the volume being way too much.  To catch this issue before the billback is approved, this setting has been created.  When this setting is ON, it will compare the claimed rate per case or per pound against the pure expected rate per case or per pound.  If the claimed rate is 10% or less of the expected rate, Forge will call it out on the deviation grid as a possible UOM issue and will not auto approve the billback.
			</CF_SmallHelp>
			</TD>
		</TR>
		
	</TABLE>

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
