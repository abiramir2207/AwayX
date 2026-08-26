<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
<TITLE>PROFILES: ACCESS SETTINGS MATRIX</TITLE>
<cfmodule template="/customTags/include.cfm" file_to_include="/common_files/locked-column.css, /common_files/ViewModes.css, /Script/javascript/dhtml.js, /Script/javascript/dom_common.js, /script/javascript/string_functions.js, /script/javascript/format_functions.js, /Common_Files/scripts/allowonlytwodecimalplaces.js"/>
<style>
	body {
		height: 100%;
		}
		/* comment the code as an IE 10 fix. */
		/*
		thead td {
		top: expression(parentNode.parentNode.parentNode.parentNode.scrollTop-1);
		z-index: 30;
		}
		*/
		thead th, thead th.locked	{
			font-size: 11px;
			font-weight: bold;
			text-align: center;
			color: black;
			border-right: 1px solid #dddddd;
			position:relative;
			cursor: default;
		}
	.retroFieldsIndicator {
		font-size: 22px;
		color:green;
		font-weight:bold;
		vertical-align:middle;
		}
	#matrix-container {
		overflow: auto;
		width: 100%;
		height: 400;
		}
	.maximize {
		position:absolute;
		left:5px;
		top:5px;
		width: 100%;
		height: 700;
		background-color: white;
		z-index: 100;
		margin: 5;
		}
	.minimize {
		height:400;
		}
	.over{
		font-size: normalpt;
		color: blue;
		text-decoration: underline;
		cursor: pointer;
		}
	.tooltipHide {
		display:none;
		}
	.tooltipShow {
		border:1px solid black;
		background-color:lightyellow;
		padding:3;
		position:absolute;
		z-index: 500;
		width: 150;
		left:3px;
		}
</style>
</HEAD>

<cfscript>
	// save all general labels into a structure
	general_labels = application.util.query.generalLabel();
</cfscript>

<cfset templateManager = CreateObject("component", "components.programs.template.TemplateManager").init() />

<!------ get the list of active templates. ----->
<cfset getCurTemplates = templateManager.getAll(1)>

<!--- For the selected profile, get all the "Profile/Template/Forbid Access Type" combination records. --->
<cfquery name="getCurChecks" datasource="#application.datasource#">
	SELECT	*
	FROM	Profile_Forbidden_Template
	WHERE	profile_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#URL.profileId#">
</cfquery>

<!---Initialize the appliation settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset forbidType = appSettings.getForbidAllowProfilesInTemplates() />

<!--- List of active templates. --->
<cfset templateList = valueList(getCurTemplates.ProgramControl_Panel_Options_ID,",")>

<!---D38941 :: New Limited User Profile Edit Functionality START--->
	<cfset actionListShort = "Access, Approval, Lumpsum, Billback, Agree, #appSettings.getPullbackLabelLower()#, Limited Revise, BB Lumpsum">
	<cfset variables.Options = listlen(actionListShort)/>
	<cfset actionListPosition = "1,2,3,5,4,8,6,7">

	<cfset actionListAllow = "
					Allowed access to profile,
					Allowed approval to profile,
					Allowed lumpsum approval to profile,
					Allowed Billback approval to profile,
					Allowed agree only to profile,
					Allowed #appSettings.getPullbackLabelLower()# approval to profile,
					Allowed Limited Revise only to profile,
					Allowed Billback approval with Lump Sum
					">

	<cfset actionListForbid = "
					Profile to forbid from using this template,
					Profile to forbid from approving this template,
					Profile to forbid from approving lumpsum,
					Profile to forbid from Approving billback with this template,
					Profile to allow only agree programs,
					Profile to forbid from approving #appSettings.getPullbackLabelLower()#,
					Profile to forbid from Limited Revise this template,
					Profiles to forbid from Approving billback with Lump Sum
					">
<!---D38941 :: New Limited User Profile Edit Functionality END--->

	<SCRIPT>
			<cfif forbidType EQ 1>
			function staychecked(objs, obj) {
			var sChkBx = objs + '_5';
			var h = '<input type="checkbox" name="sChkBx" id="' + sChkBx + '" disabled="true" readonly="true">';
			var oChkBx = 'document.matrixForm.' + objs + "_5";
			document.getElementById('divA').innerHTML = h;
				box1 = document.getElementById(objs + "_1");
				box2 = document.getElementById(objs + "_2");
				box3 = document.getElementById(objs + "_3");
			/* If recapture (pullback) column exists. */
			if(document.getElementById(objs + "_6")){
			var box6 = document.getElementById(objs + "_6");
			}

				if(oChkBx){
				}
				else{
					box5 = document.getElementById(objs + "_5");
					}

				if (box1.checked == true) {
				if (obj == true) {
					box2.checked = true;
					box3.checked = true;
					box5.checked = true;
					if(box6){
					box6.checked = true;
					}
				} else {
					box2.checked = true;
					box3.checked = true;
					box5.checked = true;
					if(box6){
					box6.checked = true;
					}
				}
				}

			/* When "forbidType EQ 1 (cf code)", then whatever checkbox is selected is what is retricted in the profile, unlike
			"forbidType EQ 0" where whatever checkbox is selected is what actually gets set in the profile - so these 2 are opposites
			of each other.
			 When "forbidType EQ 1" - when the user does not have profile access (checkbox checked), the user should not be provided with
			 recapture (pullback) too.
			*/
			if(box2.checked == true){
				if(box6){
				box6.checked = true;
				}
			}
			}
			</cfif>

			function checkRow(elId, tchk) {
			var sChkBx = elId + '_5';
			var h = '<input type="checkbox" name="sChkBx" id="' + sChkBx + '" disabled="true" readonly="true">';
			var oChkBx = 'document.matrixForm.' + elId + '_5';
			box2 = document.getElementById(elId + "_2");
			box3 = document.getElementById(elId + "_3");
			box4 = document.getElementById(elId + "_4");/* 97865*/
			box8 = document.getElementById(elId + "_8"); /* 97865*/

			/* If recapture (pullback) column exists. */
			if(document.getElementById(elId + "_6")){
			var box6 = document.getElementById(elId + "_6");
			}
				/* 97865 - LS BB Controls  START*/
				if(	box4.checked == true){
					box8.disabled = false;
				}else{
					box8.disabled = true;
				}
				/* 97865 - LS BB Controls  END*/
			if(document.getElementById(elId + '_5')){
					box5 = document.getElementById(elId + "_5");
					box5.checked = false;
				}
				else{
					document.getElementById('divA').innerHTML = h;
					box5 = document.getElementById(elId + "_5");
					box5.checked = false;
					}
		 	var HiddenAgree = document.getElementById(sChkBx + "_hidden");

			if (tchk == true) {
			<cfif forbidType EQ 0>
				box2.disabled = false;
				box3.disabled = false;
				box5.disabled = false;
			<cfelse>
				box2.checked = true;
				box3.checked = true;
				box5.checked = true;
				if(box6){
				box6.checked = true;
				}
			</cfif>
			} else {
			<cfif forbidType EQ 0>
				box2.checked = false;
				box2.disabled = true;
				box3.checked = false;
				box3.disabled = true;
				box5.checked = false;
				box5.disabled = true;
				if(box6){
				box6.checked = false;
				box6.disabled = true;
				}
				HiddenAgree.disabled = true;
			<cfelse>
				box2.checked = false;
				box3.checked = false;
				box5.checked = false;
				if(box6){
				box6.checked = false;
				}
			</cfif>
			}
			}

			function check_uncheck(objs, obj){

			/* approval checkbox */
			box2 = document.getElementById(objs + "_2");
			/* recapture (pullback) checkbox */
			if(document.getElementById(objs + "_6")){
			var box6 = document.getElementById(objs + "_6");

			/* If approval checkbox is turned ON, recapture (pullback) checkbox is enabled. */
			if(box2.checked == true){
			box6.disabled = false;
			}
			/* If approval checkbox is turned OFF, recapture (pullback) checkbox is disabled. */
			else{
			box6.disabled = true;
			box6.checked = false;
			}
			}
			}

			function chkColumn(colId, obj) {

			listString = new String("<cfoutput>#templateList#</cfoutput>")
			var templateList = listString.split(",");

			for (var i=0; i<templateList.length; i++) {

			MainInstance = document.getElementById("all_1");
			boxcolumn = document.getElementById(templateList[i] + "_" + colId);
			boxrow = document.getElementById(templateList[i] + "_1");
			boxhead1 = document.getElementById("all_1");
			boxhead2 = document.getElementById("all_2");
			boxhead3 = document.getElementById("all_3");
			boxhead4 = document.getElementById("all_4");
			boxhead5 = document.getElementById("all_5");
			boxhead6 = document.getElementById("all_6");
			boxrow6  = document.getElementById(templateList[i] + "_6");

			if (obj == true){
				boxcolumn.checked = true;
				if (boxhead1.checked == true) {
					<cfif forbidType EQ 0>
						boxhead2.disabled = false;
						boxhead3.disabled = false;
						boxhead5.disabled = false;
					<cfelse>
						boxhead2.checked = true;
						boxhead3.checked = true;
						boxhead5.checked = true;
					</cfif>
					if (boxrow.checked = true){
						checkRow(templateList[i], boxrow.checked);
					} else {
						checkRow(templateList[i], boxrow.checked);
					}

					if (boxhead2.checked == true)
					{
						if (boxhead6) {
							<cfif forbidType EQ 0>
								boxhead6.disabled = false;
							<cfelse>
								 boxhead6.checked = true;
							</cfif>
						}
						if (boxrow6) {
							if (boxrow6.checked = true){
								checkRow6(templateList[i], boxrow6.checked);
							} else {
								checkRow6(templateList[i], boxrow6.checked);
							}
						}
					}
					if (boxhead2.checked == false)
					{
						if (boxhead6) {
							<cfif forbidType EQ 0>
								boxhead6.disabled = true;
							<cfelse>
								boxhead6.checked = false;
							</cfif>
						}
						if (boxrow6) {
							if (boxrow6.checked = false){
								checkRow6(templateList[i], boxrow6.checked);
							} else {
								checkRow6(templateList[i], boxrow6.checked);
							}
						}
					}
				}
			} else {
				boxcolumn.checked = false;
				if (boxhead1.checked == false) {
					<cfif forbidType EQ 0>
						boxhead2.checked = false;
						boxhead2.disabled = true;
						boxhead3.checked = false;
						boxhead3.disabled = true;
						boxhead5.checked = false;
						boxhead5.disabled = true;
					<cfelse>
						boxhead2.checked = false;
						boxhead3.checked = false;
						boxhead5.checked = false;
					</cfif>
					if (boxrow.checked = false){
						checkRow(templateList[i], boxrow.checked);
					} else {
						checkRow(templateList[i], boxrow.checked);
					}
				}
				if (boxhead2.checked == false)
				{
					if (boxhead6) {
						<cfif forbidType EQ 0>
							boxhead6.disabled = true;
						<cfelse>
							 boxhead6.checked = false;
						</cfif>
					}
					if (boxrow6) {
						if (boxrow6.checked = false){
							checkRow6(templateList[i], boxrow6.checked);
						} else {
							 checkRow6(templateList[i], boxrow6.checked);
						}
					}
				}
			}
			}
			}

			function checkRow6(elId, tchk)
			{
				var sChkBx = elId + '_6';
				if(document.getElementById(elId + "_6")){
				var box6 = document.getElementById(elId + "_6");
				}

				if (tchk == true) {
				<cfif forbidType EQ 0>
					box6.disabled = false;
					box6.checked = false;
				</cfif>
				}
				else {
				<cfif forbidType EQ 0>
					box6.disabled = true;
					box6.checked = false;
	 			</cfif>
				}
			}

			function setClassName(objId, className) {
			document.getElementById(objId).className = className;
			}

			function maximize() {
			obj = document.getElementById("fullScr");

			if (obj.innerHTML == 'Maximize +') {
			obj.innerHTML = 'Minimize -';
			document.getElementById("matrix-container").style.height = screen.availHeight - 400;
			setClassName('MasterContainer', 'maximize');
			} else {
			obj.innerHTML = 'Maximize +';
			document.getElementById("matrix-container").style.height = 400;
			setClassName('MasterContainer', 'minimize');
			}
			}

			function confirmCompletion() {
			matrixForm.action = "profile_template_action.cfm"
			matrixForm.submit();
			}

			function keepHeaderFixed(topPosition,leftPosition)
	{
	/* CODE FOR HORIZONTAL SCROLLING */

	/* Find the element which is a "<td>" */
	var cellObject = document.getElementsByTagName("td");

	/*Loop through the "<td>" object. Look for specific "id" (below), then move that cell from the left based on scroll position.
	The position of the "<td>" will match the scroll position.
	*/
	for(i=0;i<cellObject.length;i++)
	{
		if (cellObject[i].getAttribute('id') == 'subheader' || cellObject[i].getAttribute('id') == 'locked') {

			cellObject[i].style.left = leftPosition;
		}
	}

	/* CODE FOR VERTICAL SCROLLING */

	document.getElementById('bufferTD').style.top = topPosition;

	<cfoutput>
	<cfloop index="i" list="#actionListPosition#" delimiters=",">
	<cfif i NEQ 6 OR appSettings.getPullbacksOn()>/*D38941 :: New Limited User Profile Edit Functionality*/
	    document.getElementById('topHead_#i#').style.top = topPosition;
	</cfif>
	</cfloop>
	</cfoutput>
	}
	</SCRIPT>

<!--- Set the width of the main tbody td cells--->
<CFSET TD_Width = 90>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" RIGHTMARGIN="0" BOTTOMMARGIN="0" >
<CF_MessageWindow>

<cfset sProfileName = CreateObject("component", "components.user.Profile").getProfileName(url.profileId)>
<cfoutput>
	<span style="color:Navy;font-size:18;">
		List of templates for #sProfileName#
	</span>

<form action="profile_template_action.cfm" method="post" name="matrixForm">
	<div id="divA" style="display:none"></div>
	<div id="MasterContainer">
	<table width="90%" cellspacing="0" cellpadding="0"  border="0" style="margin-top:-5px;">
		<tr valign="middle">
			<cfif forbidType EQ 0>
				<td nowrap class="retroFieldsIndicator">*</td>
				<td nowrap>Fields which will be saved retroactively for all previous versions</td>
			</cfif>
		</tr>
	</table>

<!--- We have included a file "Select_GroupLevelAccess_Profiles.cfm" which has option of selecting multiple profiles. On that page,
the profile checkboxes also have the same name "profile_Id". This value gets overwritten by that one (multiple selection), if
one or more checkboxes are selected there.
--->
	<input type="hidden" name="profile_Id" value="#URL.profileId#">
	<!---This is the profileID which the user used to visit this page --->
	<input type="hidden" name="Original_profile_Id" value="#URL.profileId#">
	<input type="hidden" name="forbidtype" value="#forbidtype#">
</cfoutput>

<div id=matrix-container style="border:1px solid #cccccc;" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">
<cfsavecontent variable="variables.table_content">
<table class="tbl" style="top: 0px;" border="0" cellpadding="0" cellspacing="0">
<cfoutput>
<thead id="tbl_head">
	<tr>
		<th name="bufferTD" id="bufferTD" width="150" class="locked" align="center" valign="middle" nowrap
			style="z-index:40; border-right: 1 solid ##cccccc; border-bottom: 1 solid ##cccccc; font-weight:normal; text-align:left;">
					<span id="fullScr" onMouseOver="this.className='over'" onMouseOut="this.className=''" onclick="maximize()" style="position: relative;">Maximize +</span>
			<br>
			<span style="font-weight:bold">Templates to <cfif forbidType eq 1>Forbid<cfelse>Allow</cfif></span>
		</th>
		<cfloop index="i" list="#actionListPosition#" delimiters=",">

		<cfif i NEQ 6 OR appSettings.getPullbacksOn()>

				<cfif forbidType EQ 1>
						<cfset displayText = listgetat(actionListForbid,i)>
				<cfelse>
						<cfset displayText = listgetat(actionListAllow,i)>
				</cfif>
				<cfset displayTextShort = listgetat(actionListShort, i)>

				<th	valign="middle" nowrap align="center" id="topHead_#i#" width="#TD_Width#" style="border-right: 1 solid ##cccccc; border-bottom: 1 solid ##cccccc;"
				onmouseover="setClassName('Profile_#i#', 'tooltipShow');this.style.backgroundColor='lightyellow';"
				onmouseout="setClassName('Profile_#i#', 'tooltipHide');this.style.backgroundColor='';">

						<span id="err_Forbid_Profile_#i#"></span> &nbsp;
						<font class="retroFieldsIndicator">*</font>
								#displayTextShort#
						<br />
						<input type="checkbox"
									<cfif i EQ 1>
											onClick="chkColumn('#i#', this.checked);"
											id="all_#i#"
									<cfelse>
											id="all_#i#"
											<cfif forbidType EQ 1>
													onclick="
													if (document.getElementById('all_1').checked == true) {
													staychecked('all', this.checked);
													} else {
													chkColumn('#i#', this.checked);
													}
													"
											<cfelse>
													onclick="chkColumn('#i#', this.checked);"
											</cfif>
											<cfif (i NEQ 4 and i NEQ 7 and i NEQ 8 and forbidType EQ 0)>
											disabled
											</cfif>
									</cfif>
						>

						<div id="Profile_#i#" class="tooltipHide"  style="top:<cfif forbidType EQ 0>63px<cfelse>48px</cfif>;">
						#displayText#
						</div>
				</th>
				</cfif>
		</cfloop>
	</tr>
</thead>
</cfoutput>

<tbody id="tbl_body">
<!--- Use the "group" attribute of "getCurTemplates", as we need to group the templates by "Generic_Type". --->

<cfoutput query="getCurTemplates" group="Generic_Type">
	<tr>
		<td colspan="100%" class="locked" id="subheader"><strong>#general_labels[ Generic_Type ]#</strong></td>
	</tr>

	<!--- This inner "<cfoutput>" tag will group the templates by "Generic_Type". --->
	<cfoutput>

	<TR onMouseOver="this.style.backgroundColor='##EEEEEE';" onMouseOut="this.style.backgroundColor='';">
		<td class="locked" id="locked" width="150" style="border-bottom: 1 solid ##cccccc;" title="#getCurTemplates.Program_Description#">
				#getCurTemplates.Created_Type#
		</td>

			<cfloop index="i" list="#actionListPosition#" delimiters=",">
				<cfif i NEQ 6 OR appSettings.getPullbacksOn()>
				<!--- Add a checkbox (by default).  --->
				<cfset bAddCheckBox = 1>
				<!--- LSAutoPay does not use Agree and so we do not add a checkbox for the "LSAutoPay template and 'Agree' combination". "i = 5" means "Agree". --->
				<cfif Generic_Type eq "LSAutoPay" and i eq 5>
						<cfset bAddCheckBox = 0>
				</cfif>

				<cfquery name="ShouldBeChecked" dbtype="query">
						SELECT 		*
						FROM 		getCurChecks
						WHERE 		Template_ID = <cfqueryparam cfsqltype="cf_sql_integer" value="#getCurTemplates.ProgramControl_Panel_Options_ID#">
						AND 	forbid_access_type = <cfqueryparam cfsqltype="cf_sql_integer" value="#i#">
				</cfquery>

				<!--- If the  "Profile/Template/Forbid Access Type" combination exists in the db, then that particular combination's checkbox should be selected. --->
				<cfif ShouldBeChecked.Recordcount GT 0>
						<cfset ShouldThisBeChecked = 1>
				<cfelse>
						<cfset ShouldThisBeChecked = 0>
				</cfif>

<td align="center" width="#td_width#" nowrap style="border-bottom: 1 solid ##cccccc;<cfif i eq 1>border-right: 1 solid ##cccccc;</cfif>">
		<span id="ForbidCheckboxes">
				<cfset chkbxName = getCurTemplates.ProgramControl_Panel_Options_ID & "_Template_Name_" & getCurTemplates.created_type & "_" & i>
				<span id="err_#chkbxName#"></span>
				<cfif bAddCheckBox eq 1>
							<INPUT TYPE="checkbox"
									<cfif i EQ 1 OR i EQ 4>
											ONCLICK="checkRow(#getCurTemplates.ProgramControl_Panel_Options_ID#, this.checked);"
											ID="#getCurTemplates.ProgramControl_Panel_Options_ID#_#i#"
									<cfelse>
											ID="#getCurTemplates.ProgramControl_Panel_Options_ID#_#i#"
											<cfif forbidType EQ 1>
													onclick="staychecked(#getCurTemplates.ProgramControl_Panel_Options_ID#, this.checked);"
											</cfif>
											<!--- "4" is billback. It can be controlled by itself, but Approval,Lumpsum, and Agree will be disabled by default. Once the user checks (turns on)
											"Access" checbox, then Approval,Lumpsum, and Agree will be enabled and the user will have the option of turning on those options.
											--->
											<cfif i NEQ 4 and forbidType EQ 0>
													onclick="check_uncheck(#getCurTemplates.ProgramControl_Panel_Options_ID#, this.checked);"
											</cfif>
											<cfif i NEQ 4 and i NEQ 7 and forbidType EQ 0>
													disabled
											</cfif>
									</cfif>
							name="#chkbxName#"
							value="1"
							<CFIF ShouldThisBeChecked EQ 1>
							checked
							</CFIF>
							>
							<cfif i EQ 5 and forbidType EQ 0 AND ShouldThisBeChecked>
									<INPUT TYPE="hidden" name="#chkbxName#" value="1" id="#getCurTemplates.ProgramControl_Panel_Options_ID#_#i#_hidden">
							</cfif>

				<cfelse>
				N/A
				</cfif>
		</span>
</td>
				</cfif>
		</cfloop>
	</tr>
	</cfoutput>
</cfoutput>
</tbody>
</table>
</cfsavecontent>
<cfoutput>#application.util.string.compress( variables.table_content )#</cfoutput>
</div>

<!--- Pass the list of templates to action page.  --->
<cfoutput><input type="hidden" name="ActiveTemplateList" value="#templateList#"></cfoutput>

<table align="center">
	<tr>
		<td>
			<br>&nbsp;
				<div align="center">
					<CF_button
						button_name	="save"
						button_caption	="Save"
						button_action	="confirmCompletion();"
						button_type	="javascript_link"
						button_width	="250"
						button_color	="Navy"
						button_tip	="Save"
						font_color	="White"
						font_size	="12"
						font_weight	="bold"
						>
				</div>
		</td>
	</tr>
</table>

<table>
<tr>
	<td colspan="100%">
	<!--- include a list of profiles. this will be helpful in selecting multiple profiles for a particular template configuration above --->
		<cfinclude template="select_grouplevelaccess_profiles.cfm" />
	</td>
</tr>
</table>

</div>
</form><br /><br />


<!--- Activate boxes where box1 is already checked. --->
<cfif forbidType EQ 0>
<script>
	myString = new String("<cfoutput>#templateList#</cfoutput>")
	templateArray = myString.split(",");

	for (var i=0; i<templateArray.length; i++) {

	 		boxMain = document.getElementById(templateArray[i] + "_1").checked;
	 		boxa = document.getElementById(templateArray[i] + "_2");
	 		boxb = document.getElementById(templateArray[i] + "_3");
			// For a LS AutoPay template "5" (agree) will not exist.
			if(document.getElementById(templateArray[i] + "_5"))
			{
	 			boxc = document.getElementById(templateArray[i] + "_5");
			}
	 		boxd = document.getElementById(templateArray[i] + "_6");

		 boxe = document.getElementById(templateArray[i] + "_4").checked;
	 		boxf = document.getElementById(templateArray[i] + "_8");

	 	if (boxMain == true) {
	 		boxa.disabled = false;
	 		boxb.disabled = false;
			// If the template is NOT "LS AutoPay" template. For a LS AutoPay template "5" (agree) will not exist.
			if(!document.getElementById(templateArray[i] + "_5"))
			{
	 			boxc.disabled = false;
			}
	 		if(boxd)
			{
				boxd.disabled = false;
			}
	 	} else {
	 		boxa.disabled = true;
	 		boxb.disabled = true;
			// If the template is NOT "LS AutoPay" template. For a LS AutoPay template "5" (agree) will not exist.
			if(!document.getElementById(templateArray[i] + "_5"))
			{
	 			boxc.disabled = true;
			}
	 		if(boxd)
			{
				boxd.disabled = true;
			}
		 }
		 if (boxe == true) {
			boxf.disabled = false;
		 }else{
			boxf.disabled = true;
		 }
	}
</script>
</cfif>
<cfinclude template="/common_files/focus.cfm">
</body>
</html>