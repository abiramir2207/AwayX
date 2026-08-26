<cfoutput>

<FIELDSET STYLE="padding:10px; width: 700px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Rebill Letter Clauses</LEGEND>
	<table>
		<cfoutput>
	
		<TR>
			<TD ALIGN="right" valign="top"><B>Clause text:</B></TD>
			<TD>
      <!--- 
    				Dev Notes: D24468/Anand Rao/17-Aug-10
    				URL on email notifications
    	--->  
      <cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
    
		<cfset siteURL = application.HTTPVar & CGI.SERVER_NAME />
     
      <CF_ACTIVEDIT 
	NAME="compName"
	TOOLBAR="cut,copy,paste,|,undo,redo,|,font,bold,italic,underline,|,outdent,indent,|,justifyleft,justifycenter,justifyright,bullets,numbers"
	IMAGEPATH="#APPLICATIONPATH#/images/"
	IMAGEURL="/images/"
	BASEURL="#siteURL#/"
	INC="/Customtags/ActiveEdit/activedit/inc/"
	DEFAULTFONT="10pt Arial"
	QUICKSTYLES="title,header"
	TABVIEW="0"
	ACTIVSCAN="0"
	ALLOWEDITSOURCE="no"
	HEIGHT=200
	WIDTH=400>
		#QGetCompRebates.DD_Rebill_Text#
		</CF_ACTIVEDIT></TD>
		</TR>
		
		<!---Get Deduction Classifications --->
		<cfset useLakebaseForgetDeductionClassifications = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_classification")>
		<cfif useLakebaseForgetDeductionClassifications>
			<cftry>
				<cfset getDeductionClassifications = application.oLakebase.toQuery(
					application.oLakebase.selectRows("dd_classification", {
						"select" = "dd_classification_id,dd_classification_desc",
						"deleted" = "eq.0",
						"order" = "is_default.asc,dd_classification_desc.asc"
					}),
					"dd_classification_id,dd_classification_desc"
				)>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForgetDeductionClassifications = false>
				</cfcatch>
			</cftry>
		</cfif>
		<cfif NOT useLakebaseForgetDeductionClassifications>
		<cfquery name="getDeductionClassifications" datasource="#application.datasource#">
		SELECT DD_Classification_ID, DD_Classification_Desc
		FROM DD_Classification
		WHERE Deleted = 0
		ORDER BY Is_Default, DD_Classification_Desc
		</cfquery>
		</cfif>
		
		<tr>
			<td align="right" valign="top"><strong>Deduction Classification</strong></td>
			<td>
				<select name="DD_Classification_ID">
				<option value="0" <cfif QGetCompRebates.DD_Classification_ID IS 0 OR QGetCompRebates.DD_Classification_ID IS 1>selected</cfif>>No classification restriction</option>
				<cfloop query="getDeductionClassifications">
				<option value="#getDeductionClassifications.DD_Classification_ID#" <cfif QGetCompRebates.DD_Classification_ID IS getDeductionClassifications.DD_Classification_ID>selected</cfif>>#left(getDeductionClassifications.DD_Classification_Desc, 50)#</option>
				</cfloop>
				</select>
			</td>
		</tr>
		
		<tr><Td align="right"  valign="top"><strong>Is this mandatory?</strong></TD>
		<td>Yes <input type="radio" value="1" name="Is_Mandatory" <cfif QGetCompRebates.Is_Mandatory IS 1>checked</cfif>><br>No &nbsp; <input type="radio" value="0" name="Is_Mandatory" <cfif QGetCompRebates.Is_Mandatory IS 0>checked</cfif>></td>
		</tr>
		
		<tr><Td align="right" valign="top"><strong>Can the analyst edit this information?</strong></TD>
		<td>Yes <input type="radio" value="1" name="Is_Editable" <cfif QGetCompRebates.Is_Editable IS 1>checked</cfif>><br>No &nbsp;  <input type="radio" value="0" name="Is_Editable" <cfif QGetCompRebates.Is_Editable IS 0>checked</cfif>></td>
		</tr>
	
	<tr><Td align="right" valign="top"><strong>Order for this information</strong></TD>
		<td><input type="text" name="Clause_Order" value="#QGetCompRebates.Clause_Order#" size="3" maxlength="3" onKeyUp="clenseText(this, '0123456789');"></td>
		</tr>
	
		</cfoutput>	
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<input type="hidden" name="CompID" value="#QGetCompRebates.DD_Rebill_ID#">
				<input type="hidden" name="command" value="update">
			
			<input type="submit" value="Save">
			<!--- 	<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return upadateComp(#qGetCompRebates.DD_Rebill_ID#);"
					button_type		=	"javascript_link"
					button_width	=	"75"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				> --->
			</TD>
		</TR>
	</table>
	</FIELDSET>
</cfoutput>