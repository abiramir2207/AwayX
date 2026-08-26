 <!-----------------------------------------------------------------------------

FILE NAME:		rebill_settings.cfm
DESCRIPTION:	The file handles the settings for the Rebill
              No. D19384: Simplot - CREATE REBILL INTERFACE..
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	21-Apr-2010	Create the file
------------------------------------------------------------------------------> 
<cfoutput>
<cfif (qGetRebillSettings.Updated_Date NEQ "" AND qGetRebillSettings.Name_First NEQ "")>
  
  <table bgcolor="White" style="border-color:Orange;border-style:solid;" cellpadding="2" cellspacing="0" align="center">
  <tr>
  <td>
  	<font size="2"><b>The settings were last updated on #dateformat(qGetRebillSettings.Updated_Date, 'mm/dd/yyyy')# #timeformat(qGetRebillSettings.Updated_Date, 'hh:mm:ss TT')# by #qGetRebillSettings.Name_First# #qGetRebillSettings.Name_Last#</b></font>	        </td>
  </td>
  </tr>
  </table>
  <br>

  </cfif>

<fieldset style="padding:10px; width: 600px; border: 1px solid Blue;">
  <legend style="font: bold 14px sans-serif; color: Red;">Rebill Settings</legend>
    <table cellspacing="0" cellpadding="5" border="0" width="70%" bordercolor="##003399">
<tr>
		<td>Rebill Message Max Size :</td>
		<td><!--- <span id="err_sp_DDRebillMessageMaxSize">&nbsp;&nbsp;</span> ---></td>
		<td nowrap>&nbsp;<input maxlength="3"  onkeypress="return Allow_Key_List('0123456789');" onblur="javaSCript: makeValidIntFloat(this, 1, '0');" class="deductionSettingsInput" type="Text" name="DDRebillMessageMaxSize" value="#qGetRebillSettings.Rebill_Message_Size#"> characters</td>
	</tr> 
<tr>
			  <td colspan="3" align="center">
				  <br>
				  <cf_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return updateRebillSettings();"
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
	</fieldset>  
  </cfoutput> 