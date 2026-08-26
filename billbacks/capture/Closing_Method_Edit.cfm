<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Closing Method Edit</title>
	<SCRIPT SRC="/Script/javascript/prototype/prototype.js"></SCRIPT>
	<SCRIPT SRC="/Script/javascript/prototype/scriptaculous.js"></SCRIPT>
	<SCRIPT>
		function toggleReason(num){
			if(document.all.DD_Reason_Code_ID)
			{
				if (num == 2) {
					new Effect.BlindDown($('reasonCodeCont'),{duration:.200});
					document.all.DD_Reason_Code_ID.disabled = false;
				} else {
					new Effect.BlindUp($('reasonCodeCont'),{duration:.200});	
					document.all.DD_Reason_Code_ID.disabled = true;	
					document.all.DD_Reason_Code_ID.value = "";		
				}
			}
		}
	</SCRIPT>
</head>

<body>

<BR>
<CFPARAM NAME="FORM.FormSumitted" DEFAULT="0">

<CFOUTPUT>
<CFIF FORM.FormSumitted EQ 1>
	<CFQUERY NAME="UpdateClosing" DATASOURCE="#Application.Datasource#">
		UPDATE Billback
		SET BB_Closing_Method = #FORM.BB_Closing_Method#<!--- <CFIF IsDefined("FORM.BB_Closing_Method")>2<CFELSE>1</CFIF> --->
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>
	<!--- Ana: D18017 - Vendor Selection Navigation Issue Fix --->
	<CFIF FORM.BB_Closing_Method EQ 2>
		<CFQUERY NAME="UpdatePayReqFlag" DATASOURCE="#Application.Datasource#">
			UPDATE GL_Code_Allocation
			SET Payment_Requested = 0<!--- <CFIF IsDefined("FORM.BB_Closing_Method")>2<CFELSE>1</CFIF> --->
			WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	</CFIF>
	<!--- **START DEV NOTE: DAA; D17150: --->
	<cfif isDefined("FORM.DD_Reason_Code_ID") AND FORM.DD_Reason_Code_ID NEQ "INVALID">
		<cfquery name="UpdateReasonCode" datasource="#application.datasource#">
		UPDATE BB_Approved
		SET BB_Reason_Code_ID = <cfqueryparam value="#FORM.DD_Reason_Code_ID#" cfsqltype="CF_SQL_INTEGER">			
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery> 
	<cfelse>
		<cfquery name="UpdateReasonCode" datasource="#application.datasource#">
		UPDATE BB_Approved
		SET BB_Reason_Code_ID = NULL		
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery> 
	</cfif>
	<!--- **END DEV NOTE: DAA; D17150: --->
	
	
	<!--- BJF: Need to delete cached version of page, if any, in order to display changes --->
	<CFSET sBillbackViewCacheFileName = "View_Billback_" & REREPLACE(Billback_ID,'-','_','ALL') & ".htm" />
	<cfif fileexists("#Application.Doc_Path#\Temp_Files\Billback\Summary_#sBillbackViewCacheFileName#")>
		<cffile action="delete" file="#Application.Doc_Path#\Temp_Files\Billback\Summary_#sBillbackViewCacheFileName#">
	</cfif>
	
	<BR><BR>
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="NAVY" SIZE="3">Closing method has been changed as</FONT></B></TD>			
		</TR>	
		<TR>
			<TD ALIGN="Center"><B><FONT COLOR="Red" SIZE="3"><CFIF IsDefined("FORM.BB_Closing_Method")>"DEDUCTION"<CFELSE>"PAYMENT"</CFIF></FONT></B></TD>
		</TR>
	</TABLE>
	<SCRIPT language="JavaScript">
	function closeAndRefesh()
	{
		window.opener.location.reload();
	}
	window.setTimeout('closeAndRefesh()', 0);
	window.setTimeout('window.close()', 0);
	</SCRIPT>
	<CFABORT>
<CFELSE>
	<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
	<CFQUERY NAME="GetBBInfo" DATASOURCE="#Application.Datasource#">
		SELECT *,Billback_Closing_Methods.Abbreviation,
            Billback_Closing_Methods.vchBillback_Closing_Method_Desc
    FROM Billback 
    LEFT JOIN Billback_Closing_Methods 
            ON (Billback.BB_Closing_Method = Billback_Closing_Methods.iBillback_Closing_Method_ID)
    WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>	
   <!----------------------------------------------------------------------------- 
    Dev Notes: D18281 - Solo - Add new closing method on billback entry	
  	All the closing method dropdown and values now come from the DB based on 
    the settings in the settings panel 
  -Anand Rao/29-May-09
  ------------------------------------------------------------------------------>  
   <cfquery NAME="getClosingMethods" datasource="#Application.datasource#">
		  	SELECT	iBillback_Closing_Method_ID,
						vchBillback_Closing_Method_Desc,
						bEnabled,
						tiAutoPay_BB_Status,
						Billback_Closing_Methods.Deleted,
						Abbreviation,
						bDefault,
						Closing_Method_Type
				FROM  Billback_Closing_Methods
				INNER JOIN BB_Profile_Closing_Methods
				ON Billback_Closing_Methods.iBillback_Closing_Method_ID = BB_Profile_Closing_Methods.Billback_Closing_Method_ID
				WHERE Billback_Closing_Methods.Deleted = 0
				AND BB_Profile_Closing_Methods.Deleted = 0
				AND Billback_Closing_Methods.bEnabled = 1
				AND BB_Profile_Closing_Methods.Profile_ID = '#request.AccessStructure.Profiles_ID#'
				<cfif (GetBBInfo.Vendor_Only_Billback EQ 1)>
					AND Closing_Method_Type = 1
				</cfif>
				ORDER BY Billback_Closing_Methods.Display_sequence
              </cfquery>
	<!--- **START DEV NOTE: DAA; D17150: --->
	<cfif appsettings.ReasonCodeinBillbackDED >
		<CFQUERY NAME="Get_ReasonCode" DATASOURCE="#Application.Datasource#">
			SELECT 		DD_Reason_Code_ID, DD_Reason_Code_Description, DD_Reason_Code, Display_In, Is_BB_Default
			FROM 		DD_Reason_Code
			WHERE 		Deleted=0 AND Display_In IN (2,3)
			ORDER BY	DD_Reason_Code_Description
		</CFQUERY>
		<cfquery name="SelectedReasonCode" datasource="#application.datasource#">
		SELECT BB_Reason_Code_ID, BB_Amount, Paid_Amount
		FROM BB_Approved	
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
		</cfquery> 
	</cfif>
	<!--- **END DEV NOTE: DAA; D17150: --->
	<CFIF GetBBInfo.Billback_Payee_Type_ID NEQ 1>
		<CFSET Disable_Deduction = 1>
	<CFELSE>
		<CFSET Disable_Deduction = 0>	
	</CFIF>
	<FORM NAME="EditClosing" ACTION="Closing_Method_Edit.cfm" METHOD="POST">
	<INPUT TYPE="Hidden" NAME="Billback_ID" VALUE="#Billback_ID#">
	<INPUT TYPE="Hidden" NAME="FormSumitted" VALUE="0">
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center"><!--- STYLE="Border: 2px solid navy" --->
			<TR>
				<TD COLSPAN="100%" ALIGN="Center"><FONT COLOR="Navy" SIZE="2"><B>Edit Closing Method</B></FONT><HR COLOR="Orange"></TD>
			</TR>
			<TR>
				<TD><B>Billback Code:</B></TD>
				<TD><B><FONT COLOR="Red">#GetBBInfo.BB_Code#</FONT></B></TD>
			</TR>
			<CFSET CheckClosingMethod = "">
			<CFIF GetBBInfo.BB_Closing_Method EQ 2>
				<CFSET CheckClosingMethod = "Checked">
			</CFIF>
			<TR>
				<TD><nobr><B>Closing Method:</B></nobr></TD>
				<TD>
         <cfquery NAME="getClosingMethods" datasource="#application.datasource#">
			  	SELECT	iBillback_Closing_Method_ID,
						vchBillback_Closing_Method_Desc,
						bEnabled,
						tiAutoPay_BB_Status,
						Billback_Closing_Methods.Deleted,
						Abbreviation,
						bDefault,
						Closing_Method_Type
				FROM  Billback_Closing_Methods
				INNER JOIN BB_Profile_Closing_Methods
				ON Billback_Closing_Methods.iBillback_Closing_Method_ID = BB_Profile_Closing_Methods.Billback_Closing_Method_ID
				WHERE Billback_Closing_Methods.Deleted = 0
				AND BB_Profile_Closing_Methods.Deleted = 0
				AND Billback_Closing_Methods.bEnabled = 1
				AND BB_Profile_Closing_Methods.Profile_ID = '#request.AccessStructure.Profiles_ID#'
				<cfif (GetBBInfo.Vendor_Only_Billback EQ 1)>
					AND Closing_Method_Type = 1
				</cfif>
				ORDER BY Billback_Closing_Methods.Display_sequence
              </cfquery>
              
              
  					  <cfloop query="getClosingMethods">
               <cfset setCheckedFlag = "" />
<!---                 <cfif (getClosingMethods.iBillback_Closing_Method_ID EQ 2)>
                  <cfif (FORM.BB_Closing_Method EQ 2 OR (FORM.BB_Closing_Method EQ "" AND appSettings.getBillbackClosingMethod() eq 1))>
                    <cfset setCheckedFlag = "checked" />
                  </cfif> --->
                <cfif (GetBBInfo.BB_Closing_Method EQ getClosingMethods.iBillback_Closing_Method_ID)>
                  <cfset setCheckedFlag = "checked" />
                </cfif>
                  <cfif ((getClosingMethods.iBillback_Closing_Method_ID EQ 3) AND (appSettings.getBB_Allow_Off_Invoice_Closing_Method()))>
                <nobr><input type="radio" name="BB_Closing_Method" onclick="toggleReason(#getClosingMethods.iBillback_Closing_Method_ID#);"
                  value="#getClosingMethods.iBillback_Closing_Method_ID#" #setCheckedFlag#><b>#getClosingMethods.vchBillback_Closing_Method_Desc#</b></nobr>
                  <cfelse>
                <nobr><input type="radio" name="BB_Closing_Method" onclick="toggleReason(#getClosingMethods.iBillback_Closing_Method_ID#);"
                  value="#getClosingMethods.iBillback_Closing_Method_ID#" #setCheckedFlag#><b>#getClosingMethods.vchBillback_Closing_Method_Desc#</b></nobr>
                </cfif>
              </cfloop>
              
				<!--- <input type="radio" onclick="toggleReason(1);" name="BB_Closing_Method" value="1" <cfif GetBBInfo.BB_Closing_Method eq 1>checked</cfif>><B>Payment</B>
				<input type="radio" onclick="toggleReason(2);" name="BB_Closing_Method" value="2" <cfif GetBBInfo.BB_Closing_Method EQ 2>checked</cfif>><B>Deduction</B>
				<CFIF appSettings.getBB_Allow_Off_Invoice_Closing_Method()>
					<input type="radio" onclick="toggleReason(3);" name="BB_Closing_Method" value="3" <cfif GetBBInfo.BB_Closing_Method eq 3>checked</cfif>><B>Off Invoice</B>
				</CFIF>
				<input type="radio" onclick="toggleReason(4);" name="BB_Closing_Method" value="4" <cfif GetBBInfo.BB_Closing_Method eq 4>checked</cfif>><B>Adjustment</B>
 --->
        
				<!--- <INPUT TYPE="CheckBox" NAME="BB_Closing_Method" VALUE="2" #CheckClosingMethod#> <B>Deduction</B> --->
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="100%">
					<div id="reasonCodeCont" <cfif GetBBInfo.BB_Closing_Method NEQ 2>style="display:none;"</cfif>>
					<cfif appsettings.ReasonCodeinBillbackDED AND (appSettings.Reason_Code_in_Billback_Display_Setting EQ 1 OR (appSettings.Reason_Code_in_Billback_Display_Setting EQ 2 AND SelectedReasonCode.Paid_Amount LT SelectedReasonCode.BB_Amount))>
						<!--- DEV NOTE: DAA; D17150 --->
						<span id="error_DD_Reason_Code_ID"></span><strong>Select the reason code for approving this billback:</strong><br />
						<SELECT NAME="DD_Reason_Code_ID">
							<OPTION VALUE="INVALID" SELECTED>** Select a Reason code</OPTION>
							<CFLOOP QUERY="Get_ReasonCode">
								<OPTION VALUE="#Get_ReasonCode.DD_Reason_Code_ID#" 
									<cfif SelectedReasonCode.BB_Reason_Code_ID EQ trim(Get_ReasonCode.DD_Reason_Code_ID)>selected <cfelseif  Get_ReasonCode.Is_BB_Default EQ 1>selected </cfif>
								>
									#trim(Get_ReasonCode.DD_Reason_Code_Description)# (#trim(Get_ReasonCode.DD_Reason_Code)#)
								</OPTION>
							</cfloop>
						</SELECT>
					</cfif>
					</div>
				</TD>
			</TR>
			<TR>
				<TD COLSPAN="2" ALIGN="Center"><BR>
					<CF_button
						button_name	=	""
						button_caption	=	"save data"
						button_action	=	"SubmitThis()"
						button_type	=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight	=	"bold"
									>
				</TD>
			</TR>
		</TABLE>
	</FORM>
</CFIF>
<cf_MessageWindow />
<SCRIPT language="JavaScript">
function SubmitThis()
{
	var DeductionDisable = "<CFOUTPUT>#Disable_Deduction#</CFOUTPUT>"
  
	
	//*** START DEV NOTE: DAA; D17150: Validation for reason code selection, make sure one is selected
  
   var BBCm_Value = 0;
            var BBCm_Desc= "";
            for (var i=0; i<document.EditClosing.BB_Closing_Method.length; i++)  { 
              if (document.EditClosing.BB_Closing_Method[i].checked){
                BBCm_Value = document.EditClosing.BB_Closing_Method[i].value
              } 
            } 
            if (BBCm_Value == 2)
            {
              BBCm_Desc = "Deduction";
            }
            else if (BBCm_Value == 5)
            {
              BBCm_Desc = "Credit Memo";
            }
  var error_text = "Payee is not a <CFOUTPUT>#application.returned_customer_setting.distributor_label_singular#</CFOUTPUT>. Closing method can not be " + BBCm_Desc ;
            
		<cfif appsettings.ReasonCodeinBillbackDED>
			var ErrorCount = 0;
      if (typeof(document.all.DD_Reason_Code_ID) != "undefined")
      {
  			if (document.all.DD_Reason_Code_ID.value == "INVALID"){
  				queueMessage("Please select a reason code.", document.all.error_DD_Reason_Code_ID);
  				ErrorCount++;
  			} else {
  				clearQueue(document.all.err_Business_Segment_ID);
  			}
			}
			if (ErrorCount != 0){
				showMessageWindow();
				return false;
			}
		</cfif>
	//*** END DEV NOTE: DAA; D17150
	
	if(DeductionDisable == 1 && (BBCm_Value == 2 || BBCm_Value == 5)) 
	{
		alert(error_text);
		return;
	}
	else
	{
		document.all.FormSumitted.value = 1;
		document.EditClosing.submit()
	}
}
</SCRIPT>
</CFOUTPUT>
</body>
</html>
