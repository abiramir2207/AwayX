<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;margin-top:10px;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">CLAIM MECHANISMS</LEGEND>
	<table border="0">
		<TR>
			<TD ALIGN="right" width="25%"><B>Claim Mechanism Name:</B></TD>
			<TD width="75%"><INPUT NAME="compName" TYPE="text" SIZE="25" MAXLENGTH="25"></TD>
		</TR>
		<cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getBBAutoReport()> <!--- if auto pay app switch is ON --->
		<TR>
			<TD ALIGN="right"><B>Automatically pay:</B></TD>
			<TD>
				No<input type="radio" name="compDesc" value="0" checked>&nbsp;
				Yes <input type="radio" name="compDesc" value="1">
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
        // document.DataForm.BBClosingMethod.selectedIndex = 0;
         //document.DataForm.BBClosingMethod.options[document.DataForm.BBClosingMethod.selectedIndex].value = 0;
         divBBCMtxt.style.display='none';
         divBBCMctrl.style.display='none';
      }
    }
    </script>
  <TR>
			 <TD ALIGN="right" valign="top"><div id="divBBCMtxt"><B>Auto Pay Billback Closing Method:</B></div></TD>
			<TD>
        <div id="divBBCMctrl"><cfoutput>
          <select name="BBClosingMethod">
            <option value="0">Select a Closing Method</option>
           <cfloop query="getClosingMethods">
            <option value="#getClosingMethods.iBillback_Closing_Method_ID#">#getClosingMethods.vchBillback_Closing_Method_Desc#</option>
           </cfloop>
          </select>
          </cfoutput>
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
				No<input type="radio" name="Off_Invoice" value="0" checked>&nbsp;
				Yes <input type="radio" name="Off_Invoice" value="1">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Restrict from billbacks:</B></TD>
			<TD>
				No<input type="radio" name="Restrict_From_Billback" value="0" checked>&nbsp;
				Yes <input type="radio" name="Restrict_From_Billback" value="1">
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
           No<span onmouseout="popUpTip(event,'dist_Tip');" onmouseover="popUpTip(event,'dist_Tip');">
  			      <img src="/images/help_small.gif" />
            </span>
            <div id="dist_Tip" class="tip">
  					  <p align="left">The setting called Program Lock Type is set to ‘Do Not Lock’, therefore you cannot change this claim mechanic setting</p>
        		</div>
         <input type="hidden"  name = "Program_Lock_Type_ID"  value= "0" />
        <cfelse>
  				No<input type="radio" name="Program_Lock_Type_ID" value="0" checked>&nbsp;
  				Yes <input type="radio" name="Program_Lock_Type_ID" value="<cfoutput>#application.appsettingsget.getProgramLockTypeID()#</cfoutput>">
  			</cfif>
      </TD>
		</TR>
		<cfif appSettings.getProgramClaimRatesReportAvailable()>
		<TR>
			<TD ALIGN="right" valign="top"><B>Include in Claim Rates Report:</B></TD>
			<TD>
				No<input type="radio" name="Include_Claim_Rates_Report" value="0" checked>&nbsp;
				Yes <input type="radio" name="Include_Claim_Rates_Report" value="1">
			</TD>
		</TR>
		</cfif>
		<cfif appSettings.getShowPricingReport()>
		<TR>
			<TD ALIGN="right" valign="top"><B>Include in Pricing Report:</B></TD>
			<TD>
				No<input type="radio" name="Include_Pricing_Report" value="0" checked>&nbsp;
				Yes <input type="radio" name="Include_Pricing_Report" value="1">
			</TD>
		</TR>
		</cfif>
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Add"
					button_action	=	"return addComp();"
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