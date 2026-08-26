

<cfoutput query="qGetCompRebates">
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Work Request</LEGEND>
	
	<table width="90%" border="0">
			
		<tr>
			<td valign="top" align="right" nowrap><strong>Description</strong></td>

			<td valign="top" colspan="3"><textarea cols="70" rows="6" name="Work_Description">#Work_Description#</textarea></td>
		</tr>
		
		<Tr>
			<td valign="top" align="right"><strong>Reference/Error numbers (if any)</strong></td>
			<td valign="top" colspan="3">
				<input type="text" name="Client_Reference_Number" maxlength="50" size="50" value="#Client_Reference_Number#">
			</td>
		
		</TR>
		
		<tr>
			<td valign="top" align="right"><strong>Priority</strong></td>
			<td valign="top"  colspan="3" align="left">
				<select name="Client_Priority">
					<option value="Low" <cfif Client_Priority IS "Low">selected</cfif>>Low</option>
					<option value="Medium" <cfif Client_Priority IS "Medium">selected</cfif>>Medium</option>
					<option value="High" <cfif Client_Priority IS "High">selected</cfif>>High</option>
					<option value="Highest" <cfif Client_Priority IS "Highest">selected</cfif>>Highest</option>
				</select>
			</td>
		
		</tr>
		
		<Tr>
			<td valign="top" align="right"><strong>What part of the application is affected?</strong></td>
			<td valign="top" colspan="3">
				<select name="App_Area">
					<option value="Unknown" <cfif App_Area IS "Unknown">selected</cfif>>Unknown</option>
					<option value="Approvals" <cfif App_Area IS "Approvals">selected</cfif>>Approvals</option>
					<option value="Billbacks" <cfif App_Area IS "Billbacks">selected</cfif>>Billbacks</option>
					<option value="Deductions" <cfif App_Area IS "Deductions">selected</cfif>>Deductions</option>
					<option value="Documents" <cfif App_Area IS "Documents">selected</cfif>>Documents</option>
					<option value="GAUGE" <cfif App_Area IS "GAUGE">selected</cfif>>GAUGE</option>
					<option value="General" <cfif App_Area IS "General">selected</cfif>>General</option>
					<option value="Interface" <cfif App_Area IS "Interface">selected</cfif>>Interface</option>
					<option value="Invoice Tools" <cfif App_Area IS "Invoice Tools">selected</cfif>>Invoice Tools</option>
					<option value="Programs" <cfif App_Area IS "Programs">selected</cfif>>Programs</option>
					<option value="Projects" <cfif App_Area IS "Projects">selected</cfif>>Projects</option>
					<option value="Reports" <cfif App_Area IS "Reports">selected</cfif>>Reports</option>
					<option value="Scorecard" <cfif App_Area IS "Scorecard">selected</cfif>>Scorecard</option>
					<option value="Settings" <cfif App_Area IS "Settings">selected</cfif>>Settings</option>
					<option value="VANTAGE" <cfif App_Area IS "VANTAGE">selected</cfif>>VANTAGE</option>
				</select>
			</td>
		
		</TR>
		
		<tr>
			<td valign="top" align="right"><strong>What kind of problem is this?</strong></td>
			<td valign="top"  colspan="3" align="left">
				<select name="Request_Type">
					<option value="Defect" <cfif Request_Type IS "Defect">selected</cfif>>Defect</option>
					<option value="Cosmetic" <cfif Request_Type IS "Cosmetic">selected</cfif>>Cosmetic</option>
					<option value="Enhancement" <cfif Request_Type IS "Enhancement">selected</cfif>>Enhancement</option>
					<option value="Inquiry" <cfif Request_Type IS "Inquiry">selected</cfif>>Inquiry</option>
				</select>
			</td>
		
		</tr>
		
		<tr>
			<td valign="top" nowrap align="right"><strong>If this is an defect, is there a workaround?</strong></td>
			<td width="25"  align="right">Yes&nbsp;</td>
			<td><input type="radio" name="Has_Workaround" value="1" <cfif Has_Workaround IS 1>checked</cfif>></td>
			<td>&nbsp; </td>
		</tr>
		<tr>
			<td>&nbsp; </td>
			<td width="25"  align="right">
				No&nbsp;</td> 
			<td width="25"><input type="radio" name="Has_Workaround" value="0" <cfif Has_Workaround IS 0>checked</cfif>></td>
			<td width="100%">&nbsp; </td>
		</tr>


		<input type="hidden" name="User_Edited" value="#request.accessStructure.User_ID#">
		
		<tr><td colspan="100%"><hr color="orange"></td></tr>

		<tr>
			<td align="right" nowrap><strong>Estimated Build</strong> </td>
			<td colspan="2"><input type="text" name="Estimated_Build" value="#Estimated_Build#" maxlength="50"></td>
			<td>&nbsp; </td>
		</tr>
		
		<tr>
			<td align="right" nowrap><strong>Estimated Time Required</strong> </td>
			<td colspan="2"><input type="text" name="Estimated_Time_Rqd" value="#Estimated_Time_Required#" maxlength="50"></td>
			<td>&nbsp; </td>
		</tr>
		
		<tr>
			<td align="right" nowrap><strong>Estimated Cost</strong> </td>
			<td colspan="2"><input type="text" name="Estimated_Cost" value="#Estimated_Cost#" maxlength="50"></td>
			<td>&nbsp; </td>
		</tr>
		
		<tr>
			<td align="right" nowrap><strong>BA Ticket Number</strong> </td>
			<td colspan="2"><input type="text" name="BA_Ticket_Number" value="#BA_Ticket_Number#" maxlength="20"></td>
			<td>&nbsp; </td>
		</tr>
	
		<tr>
			<td align="right" nowrap><strong>Completed</strong></td>
			<td width="25"  align="right">No</td>
			<td><input type="radio" name="Is_Completed" value="0" checked></td>
			<td>&nbsp; </td>
		</tr>
		<tr>
			<td>&nbsp; </td>
			<td width="25"  align="right">Yes  </td>
			<td><input type="radio" name="Is_Completed" value="1" <cfif Is_Completed IS 1>checked</cfif>></td>
			<td>&nbsp; </td>
		</tr>

		<tr>
			<td valign="top" align="right" nowrap><strong>Notes</strong></td>

			<td valign="top" colspan="3"><textarea cols="70" rows="6" name="Notes">#Notes#</textarea></td>
		</tr>
	
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
				<BR>
				<CF_button
					button_name		=	""
					button_caption	=	"Update"
					button_action	=	"return updateComp(#Work_Request_ID#);"
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
	
	<input type="hidden" name="Work_Request_ID" value="#Work_Request_ID#">
	
	
	</FIELDSET>
</cfoutput>