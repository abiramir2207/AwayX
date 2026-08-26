<!-----------------------------------------------------------------------------
FILE NAME:		rebill_package_variable_size.cfm
DESCRIPTION:	This page will be used to edit the length of the variable used
              in the Rebill Package.
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			Anand Rao	09-Apr-10 Added the page for changing the variable size
------------------------------------------------------------------------------>  
<cfif (qGetVariableSize.Last_Updated_Date NEQ "" AND qGetVariableSize.Name_First NEQ "")>
  <cfoutput>
  <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="2" cellspacing="0" align="center">
  <tr>
  <td>
  	<font size="2"><b>The settings were last updated on #dateformat(qGetVariableSize.Last_Updated_Date, 'mm/dd/yyyy')# #timeformat(qGetVariableSize.Last_Updated_Date, 'hh:mm:ss TT')# by #qGetVariableSize.Name_First# #qGetVariableSize.Name_Last#</b></font>	        </td>
  </td>
  </tr>
  </table>
  <br>
  </cfoutput> 
</cfif> 
<fieldset style="padding:10px; width: 600px; border: 1px solid Blue;">
  <legend style="font: bold 14px sans-serif; color: Red;">Rebill Variables</legend>
    <table cellspacing="0" cellpadding="5" border="1" width="70%" bordercolor="##003399">
      <tr><td><b>Variable Name</b></td><td><strong>Size</strong></td></tr>
      <cfoutput query="qGetVariableSize">
        <tr>
          <td nowrap>#qGetVariableSize.Rebill_Package_Variable#</td> 
     
          <td>
          <cfif findnocase("date",#qgetvariablesize.rebill_package_variable#)>
            <input type="text" maxlength="3" name="Std_Length_#DD_Rebill_package_Variable_ID#" value="10" readonly onkeypress="return Allow_Key_List('0123456789');" onPaste="return Allow_Key_List('0123456789');" style="background:grey;width:30;" >
          <cfelse>
            <input type="text" maxlength="3" name="Std_Length_#DD_Rebill_package_Variable_ID#" value="#Std_Length#" onkeypress="return Allow_Key_List('0123456789');" onPaste="return Allow_Key_List('0123456789');" style="width:30;">
          </cfif>
            <input type="hidden" name="DD_Rebill_package_Variable_ID_#DD_Rebill_package_Variable_ID#" value="#DD_Rebill_package_Variable_ID#" />
          </td>
        </tr>
      </cfoutput>
		  <tr>
      </tr>
		  <tr>
			  <td colspan="100%" align="center">
				  <br>
				  <cf_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return updateRebillVariables();"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				  >
			  </td>
		  </tr>
	  </table>
    <cfoutput>
      <input type="hidden" value="#qGetVariableSize.RecordCount#" name="totalVarCount" />
    </cfoutput>
	</fieldset>