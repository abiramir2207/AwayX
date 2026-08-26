
<cfparam name="form.compExternalID" 	default="">
<cfparam name="form.compName" 			default="">
<cfparam name="form.samples_related"	default="0">
<cfparam name="form.ErrorEvent"	default="">

<script type="text/javascript">
function FilesHandler( strIDs ){
	var objIDList = document.forms[ 0 ].AttachedFiles;
 	var nameFiles = objIDList.value + strIDs+"<br>";
	objIDList.value = nameFiles;
	document.all.DivFileNames.innerHTML = nameFiles;
}

function FilesHandlerDelete( strFileName ){
	var objIDList = document.forms[ 0 ].AttachedFiles;
	var sFileName =  strFileName+"<br>";
 	var nameFiles =  objIDList.value.replace( sFileName, "");
	objIDList.value = nameFiles;
	document.all.DivFileNames.innerHTML = nameFiles;
}

</script>

<style>

.dottedTop
{
	
}
.dottedDivider
{

}
.dottedCentralDivider
{
	
}
select
		{
			width: 190px;
			font-size: 11px;
		}
</style>
<cfoutput><CF_MessageWindow></cfoutput>
<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">Work Request</LEGEND>
	<table width="90%" border="0">
		
		<cfoutput>
		<tr>
			<td valign="top" align="right" nowrap><strong>Issue Title</strong></td>
			<td valign="top" colspan="3"><span id="error_title"></span><input type="text" name="Work_Title" maxlength="50" size="50"></td>
		</tr>	
			
		<tr>
			<td valign="top" align="right" nowrap><strong>URL Of The Environment</strong></td>
			<td valign="top" colspan="3"><span id ="err_URLEnvironment"></span><input type="text" name="URLEnvironment" maxlength="50" size="50"></td>
		</tr>

		<tr>
			<td valign="top" align="right" nowrap><strong>Prog ID, BB ID, DD ID, Interface Name</strong></td>
			<td valign="top" colspan="3"><span id ="err_ProgBBDDIDs"></span><input type="text" name="ProgBBDDIDs" maxlength="50" size="50"></td>
		</tr>

		<tr>
			<td valign="top" align="right" nowrap><strong>User Name/Password/Position/Profile</strong></td>
			<td valign="top" colspan="3"><span id ="err_UserInfo"></span><input type="text" name="UserInfo" maxlength="50" size="50"></td>
		</tr>

		<tr>
			<td valign="top" align="right" nowrap><strong>Error Event ##</strong></td>
			<td valign="top" colspan="3"><span id ="err_ErrorEvent"></span><input type="text" name="ErrorEvent" maxlength="50" size="50"></td>
		</tr>
		
		<tr>
			<td valign="top" align="right" nowrap><strong>What is current behavior?</strong></td>
			<td valign="top" colspan="3"><span id ="err_CurrentBehavior"></span>
			<CF_SCALABLETEXTAREA
			NAME="CurrentBehavior"
			ID="CurrentBehavior"
			COLS="110"
			ROWS="5"
			incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">"
			decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">">
			</CF_SCALABLETEXTAREA>
			</td>
		</tr>
		<tr>
			<td valign="top" align="right" nowrap><strong>What is the expected behavior?</strong></td>
			<td valign="top" colspan="3"><span id ="err_ExpectedBehavior"></span>
			<CF_SCALABLETEXTAREA
			NAME="ExpectedBehavior"
			ID="ExpectedBehavior"
			COLS="110"
			ROWS="5"
			incrementlabel="<IMG SRC=""/images/bigger.gif"" BORDER=""0"" TITLE=""Bigger"">"
			decrementLabel="<IMG SRC=""/images/smaller.gif"" BORDER=""0"" TITLE=""Smaller"">">
			</CF_SCALABLETEXTAREA>
			</td>
		</tr>
		<tr>
			<td valign="top" align="right"><strong>Reference/Error numbers (if any)</strong></td>
			<td valign="top" colspan="3">
				<input type="text" name="Client_Reference_Number" maxlength="50" size="50">
			</td>
		</tr>
		
		<tr>
			<td valign="top" align="right"><strong>Priority</strong></td>
			<td valign="top"  colspan="3" align="left"> <span id ="err_Client_Priority"></span>
				<select name="Client_Priority">
					<option value="0">Select Priority</option>
					<option value="Low">Low</option>
					<option value="Medium">Medium</option>
					<option value="High">High</option>
					<option value="Highest">Highest</option>
				</select>
			</td>
		</tr>
		
		<tr>
			<td valign="top" align="right" nowrap><strong>What part of the application is affected?</strong></td>
			<td valign="top" colspan="3"> <span id ="err_App_Area"></span>
			        <cfif application.oApplicationAppSettingsManager.getApplicationAppSettings().getWebserviceOn() EQ 1>			
				<select name="App_Area">
					<option value="0">Select Function</option>
					<option value="Billbacks">Billbacks</option>
					<option value="Deductions">Deductions</option>
					<option value="GAUGE">GAUGE</option>
					<option value="General">General</option>
					<option value="Interface">Interface</option>
					<option value="Invoice Tools">Invoice Tools</option>
					<option value="Programs">Programs</option>
					<option value="Projects">Projects</option>
					<option value="Settings">Settings</option>
					<option value="Unknown">Unknown</option>
					<option value="VANTAGE">VANTAGE</option>
				</select>
			        <cfelse>
					<cfquery name="getPunch_function" datasource="punchlist">
						select 	Punch_function_ID,Punch_function_Desc
						from 	Punch_function
						where 	DisplayOnAppWorkRequest = 1
						order by 	Punch_function_Desc
					</cfquery>
					<select name="App_Area">
						<option value="0">Select Function</option>					
						<cfloop query="getPunch_function">
							<option value="#getPunch_function.Punch_function_Desc#">#getPunch_function.Punch_function_Desc#</option>
						</cfloop>
					</select>
			        </cfif>
			</td>
		</tr>
		
		<tr>
			<td valign="top" align="right"><strong>What type of request is this?</strong></td>
			<td valign="top"  colspan="3" align="left"><span id ="err_Request_Type"></span>
				<select name="Request_Type">
					<option value="0">Select Type</option>
					<option value="Defect">Defect</option>
					<option value="Enhancement">Enhancement</option>
					<option value="Inquiry" selected>Inquiry</option>
					<option value="Service">Service</option>
				</select>
			</td>
		</tr>
		<cfset AttchMatch = "#request.accessStructure.User_ID##request.accessStructure.User_Code##timeFormat(now(), 'HH:mm:sstt')##DateFormat(now(), 'mmm-dd-yyyy')#" />
		<input type="hidden" name="MatchAttch" value="#AttchMatch#">
		<tr>
			<td valign="top" align="right">
			<CF_smallLink 
			title = "attach a file to this work request" 
			url = "##"
			parameters = "onClick=""javascript: return documentWindowAdd('#AttchMatch#');"""
			>
			</td>
			<td  id=DivFileNames></td>
		</tr>
		<input type="hidden" name="AttachedFiles" value="">
		<input type="hidden" name="User_Created" value="#request.accessStructure.User_ID#">
		<input type="hidden" name="Installation_URL" value="#cgi.HTTP_Host#">
		</cfoutput>
		
		<TR>
			<TD COLSPAN="4" ALIGN="center">
				<BR>
				<CF_button
					button_name	=	"save_wr"
					button_caption	=	"submit request"
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