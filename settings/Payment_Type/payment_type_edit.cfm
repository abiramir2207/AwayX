<cfif isDefined("stError") and stError.bNameExists>
	<script>
		alert("Claim mechanism already exists.");
	</script>
</cfif>
<!--- Last edited info --->
<cfif isdefined("qGetCompRebates.Last_Edited_By") AND len(trim(qGetCompRebates.Last_Edited_By)) GT 0 >

	<cfset useLakebaseForGetUserLastEdited = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_users")>
<cfif useLakebaseForGetUserLastEdited>
	<cftry>
		<cfset GetUserLastEdited = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_users", {
				"user_id" = "eq.#qGetCompRebates.Last_Edited_By#",
				"select" = "name_first + ' ' + name_last as userlastedited"
			}), "name_first + ' ' + name_last as userlastedited"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetUserLastEdited = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetUserLastEdited>
<cfquery name="GetUserLastEdited" datasource="#application.datasource#">
	SELECT Name_First + ' ' + Name_Last AS UserLastEdited
	FROM _Users
	WHERE User_ID = '#qGetCompRebates.Last_Edited_By#'
	</cfquery>
</cfif>
	<cfif GetUserLastEdited.Recordcount IS 1>
	<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;margin-top:10px;" CELLPADDING="3" CELLSPACING="0" align="center">
	<TR>
	<TD align="center" width="400px" style="font-size:12px;">
		<B>Last updated on <CFOUTPUT>#dateformat(qGetCompRebates.Last_Edited_Date, 'm/d/yyy')# #timeformat(qGetCompRebates.Last_Edited_Date, 'h:mm:ss TT')# by #GetUserLastEdited.UserLastEdited#</CFOUTPUT></B></TD>
	</TD>
	</TR>
	</TABLE>
	</cfif>
	<br>
</cfif>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Claim Mechanism</LEGEND>
	<table border="0">
		<TR>
			<TD ALIGN="right" width="40%"><B>Claim Mechanism Name:</B></TD>
			<TD width="60%"><INPUT NAME="compName" TYPE="text" VALUE="<cfoutput>#qGetCompRebates.Payment_Type_Name#</cfoutput>" SIZE="30" MAXLENGTH="50"></TD>
		</TR>
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()>
		<TR>
			<TD ALIGN="right"><B>Automatically pay:</B></TD>
			<TD>
				No <input type="radio" name="compDesc" value="0" checked>&nbsp;
				Yes <input type="radio" name="compDesc" value="1" <cfif qGetCompRebates.Is_Auto_Pay IS 1>checked</cfif>>
			</TD>
		</TR>
  <!---
    D18281: Display a field "Auto Pay Billback Closing Method
            only if Auto Pay is checked as Yes else hide it.
            -Anand Rao/29-May-09
  --->
 <script  language="JavaScript1.2">
    function fnToggleBB()
    {
      if (document.DataForm.compDesc[1].checked)
      {
         divBBCMtxt.style.display='block';
         divBBCMctrl.style.display='block';
      }
      else{
       //  document.DataForm.BBClosingMethod.selectedIndex = 0;
         divBBCMtxt.style.display='none';
         divBBCMctrl.style.display='none';
      }
    }
    </script>

    <TR>
		<TD ALIGN="right" valign="top"><div id="divBBCMtxt"><B>Auto Pay Billback Closing Method:</B></div></TD>
		<TD>
			<div id="divBBCMctrl">
				<select name="BBClosingMethod">
					<option value="0" <cfif qGetCompRebates.Billback_Closing_Method_ID EQ 0>selected</cfif>>Select a Closing Method</option>
						<cfloop query="getClosingMethods">
						<cfoutput><option value="#getClosingMethods.iBillback_Closing_Method_ID#" <cfif qGetCompRebates.Billback_Closing_Method_ID EQ #getClosingMethods.iBillback_Closing_Method_ID#>selected</cfif>>#getClosingMethods.vchBillback_Closing_Method_Desc#</option>  </cfoutput>
						</cfloop>
				</select>
			</div>
		</TD>
		</TR>
        <cfelse>
		<input type="hidden" name="compDesc" value="0">
		<input type="hidden" name="BBClosingMethod" value="0">
		</cfif> <!--- if auto pay app switch is OFF --->
		<TR>
			<TD ALIGN="right"><B>Off Invoice:</B></TD>
			<TD>
				No <input type="radio" name="Off_Invoice" value="0" checked>&nbsp;
				Yes <input type="radio" name="Off_Invoice" value="1" <cfif qGetCompRebates.Off_Invoice IS 1>checked</cfif>>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Restrict from billbacks:</B></TD>
			<TD>
				No <input type="radio" name="Restrict_From_Billback" value="0" checked>&nbsp;
				Yes <input type="radio" name="Restrict_From_Billback" value="1" <cfif qGetCompRebates.Restrict_From_Billback IS 1>checked</cfif>>
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right" valign="top"><B>Program Interface Lock:</B></TD>
			<TD>
        <!-----------------------------------------------------------------------------
        Dev Notes: D19033
        	Changed the logic such that if the application.appsettingsget.getProgramLockTypeID()
          is Off(set to 'Do Not Lock' then the user will not be able to edit/add the
          program Interface Lock and by default this value will be set to No. If the
          appsetting is on (ie., had selected anyone of the other 3 options then the
          user will be able to add/edit this.
        -Anand Rao/19-May-09
        ------------------------------------------------------------------------------>
        <cfif application.appsettingsget.getProgramLockTypeID() EQ 0>
          <cfif qGetCompRebates.Program_Lock_Type_ID EQ 0>
            No<span onmouseout="popUpTip(event,'dist_Tip');" onmouseover="popUpTip(event,'dist_Tip');">
  			      <img src="/images/help_small.gif" />
            </span>
            <div id="dist_Tip" class="tip">
  					  <p align="left">The setting called Program Lock Type is set to Do Not Lock, therefore you cannot change this claim mechanic setting</p>
        		</div>
          <cfelse>
            Yes<span onmouseout="popUpTip(event,'dist_Tip');" onmouseover="popUpTip(event,'dist_Tip');">
  			      <img src="/images/help_small.gif" />
            </span>
            <div id="dist_Tip" class="tip">
  					  <p align="left">The setting called Program Lock Type is set to Do Not Lock, therefore you cannot change this claim mechanic setting</p>
        		</div>
          </cfif>
        <input type="hidden"  name = "Program_Lock_Type_ID"  value= "<cfoutput>#qGetCompRebates.Program_Lock_Type_ID#</cfoutput>" />
         <cfelse>
  				No <input type="radio" name="Program_Lock_Type_ID" value="0" <cfif qGetCompRebates.Program_Lock_Type_ID EQ 0>checked</cfif>>&nbsp;
  				Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>" <cfif application.appsettingsget.getProgramLockTypeID() eq qGetCompRebates.Program_Lock_Type_ID>checked</cfif>>
  			</cfif>
      </TD>
		</TR>
		<cfif appSettings.getProgramClaimRatesReportAvailable()>
		<TR>
			<TD ALIGN="right" valign="top"><B>Include in Claim Rates Report:</B></TD>
			<TD>
				No <input type="radio" name="Include_Claim_Rates_Report" value="0" checked>&nbsp;
				Yes <input type="radio" name="Include_Claim_Rates_Report" value="1" <cfif qGetCompRebates.Include_Claim_Rates_Report IS 1>checked</cfif>>
			</TD>
		</TR>
		</cfif>
		<cfif appSettings.getShowPricingReport()>
		<TR>
			<TD ALIGN="right" valign="top"><B>Include in Pricing Report:</B></TD>
			<TD>
				No <input type="radio" name="Include_Pricing_Report" value="0" checked>&nbsp;
				Yes <input type="radio" name="Include_Pricing_Report" value="1" <cfif qGetCompRebates.Include_Pricing_Report IS 1>checked</cfif>>
			</TD>
		</TR>
		</cfif>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return upadateComp(#qGetCompRebates.Payment_Type_ID#);"
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