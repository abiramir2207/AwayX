<!---
               Name: access_rights_matrix.cfm
               Copyright (c) 2006 Blacksmith Applications, Inc.

               Description:
                        The main page for User Profiles
         Usage:
                        included from index.cfm
         Tip:
              All controls will require the following:
              - a mass update cell (leave blank if not required)
              - the apply link (+) should have an onclick function calling massUpdate(control type, control name (matches MASSUPDATEID), value)
              - Each row must include a unique MASSUPDATEID on the input control. Otherwise, the massupdate function will not work.
              - To implement the massupdate by profile, there is a masscontrolid and massupdateready attribute.
                if the massupdateready attribute is false, the field with not allow updates. By default, all inputs should be set to false.
                the masscontrolid is used as a profile key for the column.
            Read_Only State
              - New input controls should include #frmReadOnly# which determines whether the control is accessible in readonly mode.
            Window.Blur
              - A window level event was established to prevent users from minimizing the page.
              Any control that fires the window blur event will execute the window.focus() method unless handled with the following code.
                This would include links and text inputs.
                use: onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" to inhibit this behavior
        Modifications:
            CPM 9501 - Removed Centering and Resizing Logic. Removed Full Screen/Normal Link at bottom of page. Made the Table Div smaller
                   and reduced the size of the window to improve usability on 1024 x 768 browsers.
IMPORTANT NOTE:
If you added a new setting to this file, please insert this new setting to Settings_List.sql accordingly.
--->

<cfparam name="fromSettings_management" default=0>

<!--- D64200 :: Create new accrual budget forecast process START --->
<cfset CustomerSettingsLabels = createObject("component", "mvc.Models.SettingsService").getCustomerSettingsLabels() />
<!--- D64200 :: Create new accrual budget forecast process END --->
<cfset application.util.query.request_settings()>
<cfif fromSettings_management neq 1>
<style>
    tr:hover, td.locked:hover {
      background-color: #bebbb8;
    }
    td.locked:hover {
      color: white;
    }
</style>
    <!--- Dev Note D7029: Get Lock Status --->
<cfinvoke component="components.general.General_Functions" method="Get_Application_Path" returnVariable="AppPath">
<CFSET getProfileLockStatus = CreateObject("component", "components.settings.profiles.profile").getProfileLockStatus()>
<CFSET getSettingsManagerProfiles = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getProfileSettings()>
<!--- If a lock exists in the Db --->
<cfif len(getProfileLockStatus.Locked_By_User_ID) GT 0>
  <!--- if Locked by the Current User --->
  <cfif url.lockstate EQ 1 AND getProfileLockStatus.Locked_By_User_ID EQ request.AccessStructure.user_id>
    <CFSET Locked = CreateObject("component", "components.settings.profiles.profile").setProfilesLock(#request.AccessStructure.user_id#,1)>
  <!--- if Locked by the Current User but URL.Lockstate is 0 then unlock and proceed --->
  <cfelseif url.lockstate EQ 0 AND getProfileLockStatus.Locked_By_User_ID EQ request.AccessStructure.user_id>
    <CFSET Locked = CreateObject("component", "components.settings.profiles.profile").setProfilesLock(#request.AccessStructure.user_id#,0)>
  <!--- if Lock is more than 15 minutes old then unlock --->
  <cfelseif datediff('n',getProfileLockStatus.Lock_date,Now()) GT 15>
    <CFSET Locked = CreateObject("component", "components.settings.profiles.profile").setProfilesLock(#request.AccessStructure.user_id#,0)>
  <!--- Else Leave in ReadOnly --->
  <cfelse>
    <CFSET Locked = 0 />
</cfif>

<!--- If no lock exists in the database --->
<cfelse>
  <!--- If user is requesting edit mode then set to edit mode --->
  <cfif url.lockstate EQ 1>
    <CFSET Locked = CreateObject("component", "components.settings.profiles.profile").setProfilesLock(#request.AccessStructure.user_id#,1)>
  <!--- Leave in ReadOnly Mode --->
  <cfelse>
    <CFSET Locked = CreateObject("component", "components.settings.profiles.profile").setProfilesLock(#request.AccessStructure.user_id#,0)>
  </cfif>
</cfif>

<CFSET getProfileLockStatus = CreateObject("component", "components.settings.profiles.profile").getProfileLockStatus()>

  <!--- Dev Note: Clay :7029   --->
  <cfif getProfileLockStatus.Is_Locked EQ 0 OR (getProfileLockStatus.Is_Locked EQ 1 AND getProfileLockStatus.Locked_By_User_ID NEQ request.AccessStructure.user_id)>
    <cfset frmREADONLY = "DISABLED">
  <cfelse>
    <cfset frmREADONLY = "">
  </cfif>

<CFSET getSettingsManagerProfiles = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getProfileSettings()>

<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<cfparam name="UseCustomerType" default = 0>

<cfif getProfileLockStatus.Is_Locked EQ 1 AND len(getProfileLockStatus.Locked_By_User_ID) NEQ 0>
  <cfinvoke component = "components.user.usermanager"   method="getUser"   returnVariable = "qLockingUserData" userId= "#getProfileLockStatus.Locked_By_User_ID#">
  <cfset lockingUserName = '#qLockingUserData.name_first# #qLockingUserData.name_last#'>
<cfelse>
  <cfset lockingUserName = ''>
</cfif>


<CFSCRIPT>
  Border="Yes";
  BorderSize=1;
  BorderColor="orange";
  Image="/images/plus3.gif";
  ImageOpen="/images/minus3.gif";
  TitleColor="Blue";
  TitleFont="Arial";
  TitleSize=9;
  IsClosed="No";

  function getCheckBoxDisabled(checkVariableString, noSetBorder)
  {
    checkBoxDisabled = "";
    if(evaluate(checkVariableString) EQ 0)
    {
      checkBoxDisabled = " disabled ";
      if(NOT noSetBorder)
      {
        checkBoxDisabled = checkBoxDisabled & " style=""border: 2px solid Silver;"" ";
      }
    }
    return checkBoxDisabled;
  }

</CFSCRIPT>

<script type="text/javascript" src="/Script/javascript/variable.debugger.js"></script>
<script>
function enableDisableLink(thisObj, profileId)
{
    var disabledLink = eval("document.all.Pullback_Profile_View_Disabled_" + profileId);
    var enabledLink = eval("document.all.Pullback_Profile_View_Enabled_" + profileId);

    if(thisObj.checked)
    {
      disabledLink.style.display = "none";
      enabledLink.style.display = "";
    }
    else
    {
      disabledLink.style.display = "";
      enabledLink.style.display = "none";
    }
}

function enableDisableLink_1(thisObj, profileId)
{

  if("document.all.Lumpsum_Profile_View_Disabled_" + profileId)
  {
  //  if(event.propertyName == "checked")
   // {
      var disabledLink = eval("document.all.Lumpsum_Profile_View_Disabled_" + profileId);
      var enabledLink = eval("document.all.Lumpsum_Profile_View_Enabled_" + profileId);

      if(thisObj.checked)
      {
        disabledLink.style.display = "none";
        enabledLink.style.display = "";
      }
      else
      {
        disabledLink.style.display = "";
        enabledLink.style.display = "none";
      }
   // }
  }
}
  <!--- Dev Note: Milan :10489  --->
  function EnableDisable(thisObj, OtherObj)
  {
    if(OtherObj != undefined){
    var bChecked = thisObj.checked;

    if(bChecked)
    {
      OtherObj.disabled = false;
    }
    else
    {
      OtherObj.checked = false;
      OtherObj.disabled = true;
    }
    }
  }
  <!--- End Note: Milan :10489  --->

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


	/* (Start) - 'bufferTD' and 'id_blankCell' are the cells which have the "read only/edit". These cells need to move while scrolling vertically or horozontally. */
	/* CODE FOR HORIZONTAL SCROLLING */
	document.getElementById('bufferTD').style.left = leftPosition;
	document.getElementById('id_blankCell').style.left = leftPosition;

	/* CODE FOR VERTICAL SCROLLING */
  	document.getElementById('bufferTD').style.top = topPosition;
	document.getElementById('id_blankCell').style.top = topPosition;
	/* (End) - 'bufferTD' and 'id_blankCell' are the cells which have the "read only/edit". These cells need to move while scrolling vertically or horozontally. */

	/* CODE FOR VERTICAL SCROLLING */
	document.getElementById('id_create_profile').style.top = topPosition;
	document.getElementById('id_endcolumn').style.top = topPosition;
	document.getElementById('id_massUpdate').style.top = topPosition;

	<cfoutput query="getProfiles">
	document.getElementById('id_profile_desc_#getProfiles.Profiles_ID#').style.top = topPosition;
	<cfif len(frmReadOnly) EQ 0>
	document.getElementById('id_lockStatus_1_profiles_#getProfiles.Profiles_ID#').style.top = topPosition;
	<cfelse>
	document.getElementById('id_lockStatus_2_profiles_#getProfiles.Profiles_ID#').style.top = topPosition;
	</cfif>
	</cfoutput>
}

/* The below function has been created because "onpropertyChange" does not work from IE 11 onwards. */
function CallChangeDisableOtherCheckBoxes(obj,index,objList,reverseValues)
{
   /* The "index" is useful when we have radio buttons with the same name.
   Currently it is being used for - "Program-None", Program-View" and "Program View & Create" radio button options.
   Index of 2 means "Program-None" for the above set of radio buttons.
  "Program-None" radio button when checked disables a lot of options and so this option is the Main Option (Index 2).
  For radio buttons with only a single option, index of 0 is used.
   */

   var objName =  obj.getAttribute("name");
   var $UIControl = $("input[name=" + objName + "]");
   var objPropChange = $UIControl[index];
   var arrayObjName;
   var profileID;

   arrayObjName = objName.split("_");
   profileID =  arrayObjName[arrayObjName.length-1];

   for (var propName in objList)
    {
  changeDisableOtherCheckBoxes(objPropChange, objList[propName], reverseValues);
  /* If the object to be changed is "Approval Rights", call functions which need to be called,
  when "Approval Rights" checkbox changes value.
  */
  var StrObjName = objList[propName].name;
  var StrMainObjName = obj.name;

  /* When "Approval Rights" checkbox is not checked or unchecked directly by the user. */
  if(StrObjName.indexOf('Cont_Prog_Approval_Rights') != -1) {
    var objApproval = objList[propName];
  }
  /* When "Approval Rights" checkbox is checked or unchecked directly by the user. */
  else if(StrMainObjName.indexOf('Cont_Prog_Approval_Rights') != -1) {
    var objApproval = obj;
  }

  if(objApproval)
  {
  /* Do what needs to be done when Approval Rights" checkbox is not checked or unchecked,
  directly by the user or undirectly.
  */
    toggleApprovalColumnActivity(objApproval);
    enableDisableLink_1(objApproval,profileID);
  }

    }
}

SubmitForm2 = function() {
    $('form[name=MyForm]').hide();

    noty( { text: "Saving profile settings, this can take a while..."
            ,layout:'center'
            ,type:'information'
          });

    SubmitForm();
}

function setTextDecoration(objref,state)
{
  if (state == 1)
    objref.style.textDecoration = "underline";
  else
    objref.style.textDecoration = "none";
}

<!--- view margins setting handling --->
function view_margins(profile_id) {
  var view_margins = $("." + profile_id + "[name=Cont_Prog_View_Margins_"    + profile_id + "]")
      ,vertical_pl = $("." + profile_id + "[name=View_LH_pane_Vertical_P_L_" + profile_id + "]")
      ,whatif_pl   = $("." + profile_id + "[name=View_LH_pane_What_If_P_L_"  + profile_id + "]");

  // when view margin is enabled make vertical p&l, what if p&l enabled
  if (view_margins.is(":checked")) {
    vertical_pl.removeAttr("disabled");
    whatif_pl.removeAttr("disabled");
  }
  // when view margin is disabled make vertical p&l, what if p&l disabled
  else {
    vertical_pl.attr("disabled", true);
    whatif_pl.attr("disabled", true);
  }
  if (0) {
    console.log("profile_id = " + profile_id);
    console.log("lh vertical p&l = " + vertical_pl.attr("disabled"));
    console.log("lh what if p&l  = " + whatif_pl.attr("disabled"));
    console.log("");
  }
}  /* function view_margins() */

function massUpdateVM(t) {
  var mass_groups = $("input.massUpdateColumn:checked")        // gather selected mass update groups
     ,tr = $(t).closest("tr")                                  // locate the parent tr of the current row
     ,mass_checked = tr.find("input[name=Cont_Prog_View_Margins]").is(":checked");

  // console.log(" parent = " + tr.length + "  inputs = " + tr.find("input").length + " mass_checked = " + mass_checked);

  for(var i=0;i < mass_groups.length; i++) {
    var name = mass_groups.eq(i).attr("name");                 // get the mass update column name which includes profile ID in it
        profile_id = name.replace("massUpdateColumn_", "");    // extract profile ID from name
        input = tr.find("input[name=Cont_Prog_View_Margins_" + profile_id + "]");

        input.attr("checked", mass_checked);
        view_margins(profile_id);
  }
}  /* function massUpdate() */
</script>

<!--- write header row if necesary for Save to excel --->
<cfif saveToXl is "yes">
  <!--- empty column for column names --->
   <cf_toFile fname="#fName#" data=",">
  <!--- <cf_toFile fname="#fName#" data="<table><thead><tr>"> --->
  <CFLOOP query="getProfiles">
    <cf_toFile fname="#fName#" data="#getProfiles.Profiles_Short_Desc#,">
  </CFLOOP>
  <!--- add newline --->
  <cf_toFile fname="#fName#" data="" nl="yes">
</cfif>

<cfoutput>
<!--- Set the width of the main tbody td cells--->
<CFSET TD_Width = 70>
<!--- Set the width of the Mass Update td cells --->
<CFSET massUpdate_TD_Width = 90>

<DIV id="tbl-container" onscroll="keepHeaderFixed(this.scrollTop-1,scrollLeft);">
<TABLE class="tbl" style="TOP: 0px;">
<THEAD id="tbl_head">
    <TR>
      <TH width="225" id="bufferTD" name="bufferTD" align="left" valign="middle" style="z-index:40;" nowrap>
        <cfif Locked EQ 1>
          <!--- if it is locked offer to unlock it --->
          	<!--- Dev Note: drachala; D28010: Profile Setting modifications
          			What For: Added cfif condition <A HREF> to add URL variable Which uses to check to display all profiles or only selected profiles.
          			--->
          <a href="index.cfm<cfif isdefined("profile_id") AND len(profile_id) GT 0>?profile_id=#trim(profile_id)#</cfif>" onclick="allowBlur()" STYLE="text-decoration:none;"><IMG SRC="/images/edit_Mode.gif"  border="0"  ALIGN="absmiddle" TITLE="Edit Mode"><br>
        	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
		<span class="ViewModesBracket">[</span>
		    <span class="ViewModes">Click for Read Only</span>
		<span class="ViewModesBracket">]</span></a>
        <cfelse>
          <!--- if it is unlocked offer to lock it --->
          <cfif len(lockingUserName) EQ 0>
		<!--- Dev Note: drachala; D28010: Profile Setting modifications
		What For: Added cfif condition <A HREF> to add URL variable Which uses to check to display all profiles or only selected profiles.
		--->
          <a href="index.cfm?lockstate=1<cfif isdefined("profile_id") AND len(profile_id) GT 0>&profile_id=#trim(profile_id)#</cfif>" onclick="allowBlur()" STYLE="text-decoration:none;">
        <!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
		</cfif>
          <IMG SRC="/images/ReadOnly_Mode.gif" border="0" <cfif len(lockingUserName) NEQ 0>TITLE="This Management Console is currently being viewed by: #Ucase(lockingUserName)#"<cfelse>TITLE="Read-Only Mode"</cfif>>
          <br />
        <cfif len(lockingUserName) NEQ 0>
			<span style="color: RGB(255,0,0);font-size:12px;font-weight:bold;text-decoration:none;">Locked By<br />#Ucase(lockingUserName)#</span>
		<cfelse>
		    <span class="ViewModesBracket">[</span><span class="ViewModes">Click to Edit</span><span class="ViewModesBracket">]</span>
		</cfif>
        <cfif len(lockingUserName) EQ 0>
          </a>
        </cfif>
        </cfif>
        </TH>


        <TH id="id_create_profile" <cfif len(frmReadOnly) EQ 0>WIDTH="75"</cfif> style="text-align:center;">
        	<!--- Dev Note: drachala; D28010: Profile Setting modifications
                  What For: Added LEN of Profile to hide Link to ADD NEW PROFILE from view selected page--->
        <cfif getProfiles.recordcount LT appSettings.getMaxProfileCount() AND len(profile_id) EQ 0>
			<span onClick="profileEdit(0, 1);"  style="cursor: pointer;" title="click here to create a new profile">
				<img src="/images/todo_create_item.gif"><br>[new]</span>
		</cfif>
        	 <!--- End Dev Note: drachala; D28010: Profile Setting modifications  --->
		&nbsp;
        </TH>


      <CFLOOP query="getProfiles">
        <TH id="id_profile_desc_#getProfiles.Profiles_ID#" title="#getProfiles.Profiles_Desc#" align="center" width="#TD_Width#" onclick="profileEdit(#getProfiles.Profiles_ID#, 2);" onmouseover="this.style.backgroundColor='navy';this.firstChild.style.color='white';" onmouseout="this.style.backgroundColor='';this.firstChild.style.color='Blue';" nowrap><B>#getProfiles.Profiles_Short_Desc#</B></TH>
      </CFLOOP>
      <TH id="id_endcolumn" align="center" class="endcolumn" width="100%"></TH>
    </TR>
    <tr>
      <th id="id_blankCell" class="locked" align="left" style="z-index:40;">&nbsp;</th>


        <Th id="id_massUpdate" WIDTH="#massUpdate_TD_Width#" class="subheaderLocked" >
        All: <input type="checkbox" name="selectallprofiles" value="1" onclick="javascript:massUpdateCheckAll(this);" title="Select All Profiles">
        <!--- If page is in readonly mode, allow blur without focus event --->
        <cfif len(frmReadONly) GT 0>
          <INPUT TYPE="hidden" id="approved_blur_method" NAME="approved_blur_method" VALUE="1">
          <INPUT TYPE="hidden" id="readonlymode" NAME="readonlymode" VALUE="1">

        <cfelse>
          <INPUT TYPE="hidden" id="approved_blur_method" NAME="approved_blur_method" VALUE="0">
          <INPUT TYPE="hidden" id="readonlymode" NAME="readonlymode" VALUE="0">
        </cfif>
        </Th>



        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
          <cfif len(frmReadOnly) EQ 0>
            <th id="id_lockStatus_1_profiles_#i#" class="lockednobold"  WIDTH="#TD_Width#" nowrap>
            &nbsp;&nbsp;&nbsp;<span onClick="profileEdit(#i#, 3);"  style="cursor: pointer;" title="copy this profile to a new profile">Copy</span><br>
            &nbsp;&nbsp;&nbsp;<a href="profile_list_users.cfm?pid=#i#" target="listusers" Onclick="javascript:allowBlur();NewWindow(this.href,'listusers',860,600,'yes', 'yes')" TITLE="List users associated to this profile">List</a>
          <cfelse>
          <th id="id_lockStatus_2_profiles_#i#" ALIGN="center" class="subHeaderLocked" WIDTH="#TD_Width#" nowrap>
          <a href="profile_list_users.cfm?pid=#i#" target="listusers" Onclick="javascript:allowBlur();NewWindow(this.href,'listusers',860,600,'yes', 'yes')" TITLE="List users associated to this profile">(list)</a>
          </cfif>
          <cfif len(frmReadOnly) EQ 0>&nbsp;&nbsp;&nbsp;<input TITLE="Select this column for Mass Updates" class="massUpdateColumn" name="massUpdateColumn_#i#" id="massUpdateColumn_#i#" type="checkbox" value="false"></cfif>
          </th>
        </cfloop>
    </tr>
</THEAD>
</cfoutput>
</cfif>
<TBODY id="tbl_body">
<cfset hdrColumnWidth = getProfiles.recordcount + 2>
<cfoutput>


<tr><td id="subheader" class="locked" align="left">Program Profile Settings</td></tr>
  <cfif fromSettings_management eq 1>
    <TR>
      <TD  id="locked"  align="right" nowrap>Program - View & Create</TD>
      <TD  id="locked"  align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Cont_Prog_View_Create_Program" value="1" id = "Cont_Prog_View_Create_Program_1" <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Cont_Prog_View_Create_Program" value="0" id = "Cont_Prog_View_Create_Program_0" <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
	</TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>Program - View & Create</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program NEQ 0><cf_toFile fname="#fName#" data="Program - View & Create"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Cont_Prog_View_Create_Program_Create" NAME="Cont_Prog_View_Create_Program" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','Cont_Prog_View_Create_Program_Create','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="Cont_Prog_View_Create_Program_#i#" onClick="var objList = {obj1:this.form.Cont_Prog_View_Margins_#i#,obj2:this.form.ProgramView_WIPPositionsBelowMe_#i#}; CallChangeDisableOtherCheckBoxes(this,2,objList,1)" MASSUPDATEID="Cont_Prog_View_Create_Program_Create" VALUE="1"<CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Create_Program") EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Create_Program") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right" nowrap>Program - View</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Cont_Prog_View_Create_Program_View" value="1" id = "Cont_Prog_View_Create_Program_View_1" <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Cont_Prog_View_Create_Program_View" value="0" id = "Cont_Prog_View_Create_Program_View_0" <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
   </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program_View EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Program - View</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program_View NEQ 0><cf_toFile fname="#fName#" data="Program - View"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Cont_Prog_View_Create_Program_View" NAME="Cont_Prog_View_Create_Program" VALUE="-1"><a href="##" OnClick="javascript:massUpdate('radio','Cont_Prog_View_Create_Program_View','-1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="Cont_Prog_View_Create_Program_#i#" onClick="var objList = {obj1:this.form.Cont_Prog_View_Margins_#i#,obj2:this.form.ProgramView_WIPPositionsBelowMe_#i#}; CallChangeDisableOtherCheckBoxes(this,2,objList,1)" MASSUPDATEID="Cont_Prog_View_Create_Program_View" VALUE="-1"<CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Create_Program") EQ -1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program_View NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Create_Program") EQ -1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>

  <cfif fromSettings_management eq 1>
    <TR>
	  <TD align="right" nowrap>Program - None</TD>
	  <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Cont_Prog_View_Create_Program_None" value="1" id="Cont_Prog_View_Create_Program_None_1" <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program_None EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Cont_Prog_View_Create_Program_None" value="0" id="Cont_Prog_View_Create_Program_None_0" <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program_None EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Cont_Prog_View_Create_Program_none EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Program - None</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program_none NEQ 0><cf_toFile fname="#fName#" data="Program - None"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Cont_Prog_View_Create_Program_None" NAME="Cont_Prog_View_Create_Program" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','Cont_Prog_View_Create_Program_None','0')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="Cont_Prog_View_Create_Program_#i#"
	  onClick="var objList = {obj1:this.form.Cont_Prog_View_Margins_#i#,obj2:this.form.ProgramView_WIPPositionsBelowMe_#i#,obj3:this.form.Cont_Prog_Approval_Rights_#i#,obj4:this.form.Approve_Pullback_#i#}; if(this.form.Approve_Pgm_Beyond_Budget_#i#){objList['obj5'] = this.form.Approve_Pgm_Beyond_Budget_#i#};if(this.form.Budgets_Actual_Adjustment_#i#){objList['obj6'] = this.form.Budgets_Actual_Adjustment_#i#};if(this.form.Cont_Prog_View_Brokerage_Margins_#i#){objList['obj7'] = this.form.Cont_Prog_View_Brokerage_Margins_#i#};CallChangeDisableOtherCheckBoxes(this,2,objList,1);"
	  MASSUPDATEID="Cont_Prog_View_Create_Program_None" VALUE="0"<CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Create_Program") EQ 0> CHECKED</CFIF>   MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes"  and getSettingsManagerProfiles.Cont_Prog_View_Create_Program_none NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Create_Program") EQ 0>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Create_Program_none NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>

  <!--- 33158 - WIP below me --->
  <cfif fromSettings_management eq 1>
         	<cfset SettingsTemplateFormUserProfile(NameField="ProgramView_WIPPositionsBelowMe", NameFieldDesc="Program - View WIP From Positions Below Me")>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.ProgramView_WIPPositionsBelowMe EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Program - View WIP From Positions Below Me</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.ProgramView_WIPPositionsBelowMe NEQ 0><cf_toFile fname="#fName#" data="Program – View WIP From Positions Below Me"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="ProgramView_WIPPositionsBelowMe" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','ProgramView_WIPPositionsBelowMe','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="ProgramView_WIPPositionsBelowMe_#i#" class="#i#" MASSUPDATEID="ProgramView_WIPPositionsBelowMe" VALUE="1" <CFIF evaluate("Get_#i#_Settings.ProgramView_WIPPositionsBelowMe") EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.ProgramView_WIPPositionsBelowMe NEQ 0>
		<cfif evaluate("Get_#i#_Settings.ProgramView_WIPPositionsBelowMe") EQ 1>
			<cf_toFile fname="#fName#" data=",yes">
		<cfelse>
			<cf_toFile fname="#fName#" data=",no">
		</cfif>
          </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.ProgramView_WIPPositionsBelowMe NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
    <TR>
	  <TD align="right" nowrap>View Margins</TD>
	  <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Cont_Prog_View_Margins" value="1"  id="Cont_Prog_View_Margins_1" <cfif getSettingsManagerProfiles.Cont_Prog_View_Margins EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Cont_Prog_View_Margins" value="0"  id="Cont_Prog_View_Margins_0" <cfif getSettingsManagerProfiles.Cont_Prog_View_Margins EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	  </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Cont_Prog_View_Margins EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>View Margins</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Margins NEQ 0><cf_toFile fname="#fName#" data="View Margins"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Cont_Prog_View_Margins" VALUE="1"><a href="##" onclick="massUpdateVM(this)" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_View_Create_Program", 1)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Cont_Prog_View_Margins_#i#" class="#i#" MASSUPDATEID="Cont_Prog_View_Margins" VALUE="1" <CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Margins") EQ 1> CHECKED</CFIF> onclick="view_margins(#i#)" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Margins NEQ 0>
          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.Cont_Prog_View_Margins") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Margins NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
    <!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->

    <cfif appsettings.getBrokerage_Functionality_On()>
    <cfif fromSettings_management eq 1>
    <TR>
        <TD align="right" nowrap>View Brokerage Margins</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Cont_Prog_View_Brokerage_Margins" value="1" id="Cont_Prog_View_Brokerage_Margins_1" <cfif getSettingsManagerProfiles.Cont_Prog_View_Brokerage_Margins EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Cont_Prog_View_Brokerage_Margins" value="0" id="Cont_Prog_View_Brokerage_Margins_0" <cfif getSettingsManagerProfiles.Cont_Prog_View_Brokerage_Margins EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Cont_Prog_View_Brokerage_Margins EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>View Brokerage Margins</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Brokerage_Margins NEQ 0><cf_toFile fname="#fName#" data="View Brokerage Margins"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
        <INPUT TYPE="checkbox" ID="Cont_Prog_View_Brokerage_Margins" NAME="Cont_Prog_View_Brokerage_Margins" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','Cont_Prog_View_Brokerage_Margins','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_View_Margins", 1)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Cont_Prog_View_Brokerage_Margins_#i#" class="#i#" MASSUPDATEID="Cont_Prog_View_Brokerage_Margins" VALUE="1"<CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Brokerage_Margins") EQ 1> CHECKED</CFIF> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Brokerage_Margins NEQ 0>
	  <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.Cont_Prog_View_Brokerage_Margins") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Brokerage_Margins NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
   </cfif>
    <!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
  <cfif fromSettings_management eq 1>
    <TR>
      <TD  align="right" nowrap>Approval Rights</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Cont_Prog_Approval_Rights" value="1" id="Cont_Prog_Approval_Rights_1" <cfif getSettingsManagerProfiles.Cont_Prog_Approval_Rights EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Cont_Prog_Approval_Rights" value="0" id="Cont_Prog_Approval_Rights_0" <cfif getSettingsManagerProfiles.Cont_Prog_Approval_Rights EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Cont_Prog_Approval_Rights EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approval Rights</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_Approval_Rights NEQ 0><cf_toFile fname="#fName#" data="Approval Rights"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Cont_Prog_Approval_Rights" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Cont_Prog_Approval_Rights','1')"  TITLE="Update all values for this row.">(+)</a></TD>
     <!--- D55216 :: Profile page displaying different values in ready only/Edit mode with IE11 --->
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><SPAN ID="ApprovalRightsCheckboxes">
			<INPUT TYPE="checkbox" NAME="Cont_Prog_Approval_Rights_#i#"
					MASSUPDATEID="Cont_Prog_Approval_Rights" PROFILESPAN="document.all.ProfileSpan_#i#" VALUE="1"
						<CFIF evaluate("Get_#i#_Settings.Cont_Prog_Approval_Rights") EQ 1> CHECKED</CFIF>
						onClick="if(this.form.Approve_Pullback_#i#){var objList = {obj1:form.Approve_Pullback_#i#};CallChangeDisableOtherCheckBoxes(this,0,objList,0);}"
	   						 MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_Approval_Rights NEQ 0>
          <cfif evaluate("Get_#i#_Settings.Cont_Prog_Approval_Rights") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_Approval_Rights NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  <!---D39479 :: Short Cut Routing profile switch START--->
    <cfif fromSettings_management eq 1>
    <TR>
      <TD  align="right" nowrap>Prevent short cut routing</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Prevent_Short_Cut_Routing" value="1" id="Prevent_Short_Cut_Routing_1" <cfif getSettingsManagerProfiles.prevent_short_cut_routing EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Prevent_Short_Cut_Routing" value="0" id="Prevent_Short_Cut_Routing_0" <cfif getSettingsManagerProfiles.prevent_short_cut_routing EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.prevent_short_cut_routing EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Prevent short cut routing</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.prevent_short_cut_routing NEQ 0><cf_toFile fname="#fName#" data="Prevent Short Cut Routing"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Prevent_Short_Cut_Routing" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Prevent_Short_Cut_Routing','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>

        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><SPAN ID="PreventshortcutroutingCheckboxes">
			<INPUT TYPE="checkbox" NAME="prevent_short_cut_routing_#i#"
					MASSUPDATEID="Prevent_Short_Cut_Routing" PROFILESPAN="document.all.ProfileSpan_#i#" VALUE="1"
						<CFIF evaluate("Get_#i#_Settings.prevent_short_cut_routing") EQ 1> CHECKED</CFIF>
						 MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.prevent_short_cut_routing NEQ 0>
          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.prevent_short_cut_routing") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.prevent_short_cut_routing NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  <!---D39479 :: Short Cut Routing profile switch END--->
    <cfif appSettings.getPullbacksOn()> <!--- Dev Note: DRK 9326 --->
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right" nowrap>Approve #appSettings.getPullbackLabel()#</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Pullback" value="1" id="Approve_Pullback_1" <cfif getSettingsManagerProfiles.Approve_Pullback EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Pullback" value="0" id="Approve_Pullback_0" <cfif getSettingsManagerProfiles.Approve_Pullback EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Pullback EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve #appSettings.getPullbackLabel()#</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Pullback NEQ 0><cf_toFile fname="#fName#" data="Approve #appSettings.getPullbackLabel()#"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Pullback" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Pullback','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 1)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><INPUT TYPE="checkbox" NAME="Approve_Pullback_#i#" class="#i#" MASSUPDATEID="Approve_Pullback" PROFILESPAN="document.all.ProfileSpan_#i#" VALUE="1"<CFIF evaluate("Get_#i#_Settings.Approve_Pullback") EQ 1> CHECKED</CFIF>  #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Pullback NEQ 0>
          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.Approve_Pullback") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Pullback NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    <!--- Dev Note: Milan (36010). We do not need this (Approve #appSettings.getPullbackLabel()# - template list) setting now. We now have a new popup to select templates. --->
    <!---
    <cfif fromSettings_management eq 1>
    <TR>
      <TD  align="right" nowrap>Approve #appSettings.getPullbackLabel()# - template list</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="pullback_profile_template_view" value="1" id="pullback_profile_template_view_1" <cfif getSettingsManagerProfiles.pullback_profile_template_view EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="pullback_profile_template_view" value="0" id="pullback_profile_template_view_0" <cfif getSettingsManagerProfiles.pullback_profile_template_view EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.pullback_profile_template_view EQ 0> style="display:none"</cfif>>
	<TD style="background-color: whitesmoke;border-right: 1px solid silver;position: relative;border-top:0px;border-bottom: 0px" nowrap>&nbsp;</TD>
        <TD style="border-top:0px;border-bottom: 0px">&nbsp;</TD>
    </TR>
    <TR <cfif getSettingsManagerProfiles.pullback_profile_template_view EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve #appSettings.getPullbackLabel()# - template list</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.pullback_profile_template_view NEQ 0><cf_toFile fname="#fName#" data="Approve #appSettings.getPullbackLabel()# - template list"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >&nbsp;</TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <cfset bApprovePullback = Evaluate("Get_#i#_Settings.Approve_Pullback") />
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#">

		<cfif #frmREADONLY# EQ "DISABLED">
			<span style="color:999999;"><B>VIEW</B></span>
		<cfelse>
        <span ID="Pullback_Profile_View_Disabled_#i#" style="color:999999;<cfif bApprovePullback EQ 1>display:none</cfif>"><B>VIEW</B></span>
        <span ID="Pullback_Profile_View_Enabled_#i#" value="#i#" style="color:000000;<cfif bApprovePullback EQ 0>display:none</cfif>"><a href="pullback_profile_template.cfm?profileId=#i#" onclick="javaScript: allowBlur(); NewWindow(this.href , 'Profile_Pullback_Template_Access' , 750 , 650 , 'yes' , 'yes'); return false;" target="_blank">VIEW</a></span></span>

		</cfif>

		</TD>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.pullback_profile_template_view NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    --->
    </cfif>
    <cfif appSettings.getPullbacksOn()> <!--- Dev Note: DRK 9326 --->
    <!------
    <TR>
      <TD WIDTH="195" nowrap>Approve #appSettings.getPullbackLabel()#</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Approve #appSettings.getPullbackLabel()#"></cfif>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 1)>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Approve_Pullback_#i#" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Approve_Pullback") IS 1>checked</cfif> #checkBoxDisabled# onpropertyChange="javascript: "></span></TD>
      <cfif saveToXl is "yes">
          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.Approve_Pullback") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
     ----->
     <!------
    <TR valign="top">
        <TD WIDTH="195" nowrap>Approve #appSettings.getPullbackLabel()# - template list</TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset bApprovePullback = Evaluate("Get_#i#_Settings.Approve_Pullback") />
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#">
        <span ID="Pullback_Profile_View_Disabled_#i#" style="color:999999;<cfif bApprovePullback EQ 1>display:none</cfif>">view</span>
        <span ID="Pullback_Profile_View_Enabled_#i#" style="<cfif bApprovePullback EQ 0>display:none</cfif>"><a href="pullback_profile_template.cfm?profileId=#i#" onclick="javaScript: NewWindow(this.href , 'Profile_Pullback_Template_Access' , 750 , 650 , 'yes' , 'yes'); return false;" target="_blank">view</a></span></span>
        </TD>
        </CFLOOP>
    </TR>
    ----->
    </cfif>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right" nowrap>Cancel Program</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Delete_Program_Access" value="1" id="Delete_Program_Access_1" <cfif getSettingsManagerProfiles.Delete_Program_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Delete_Program_Access" value="0" id="Delete_Program_Access_0" <cfif getSettingsManagerProfiles.Delete_Program_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Delete_Program_Access EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Cancel Program</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Delete_Program_Access NEQ 0><cf_toFile fname="#fName#" data="Cancel Program"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Delete_Program_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Delete_Program_Access','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Delete_Program_Access_#i#" class="#i#" MASSUPDATEID="Delete_Program_Access" <CFIF evaluate("Get_#i#_Settings.Delete_Program_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Delete_Program_Access NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Delete_Program_Access") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Delete_Program_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
      <!--- Removed with label 19969
      <TR >
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve All Products Program</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Approve All Products Program"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_All_Products_Program" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_All_Products_Program','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><SPAN ID="Approve_All_Products_ProgramCheckboxes"><INPUT TYPE="checkbox" NAME="Approve_All_Products_Program_#i#" class="#i#" MASSUPDATEID="Approve_All_Products_Program" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Approve_All_Products_Program") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes">
          <CFIF evaluate("Get_#i#_Settings.Approve_All_Products_Program") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      --->
<!--- Dev Note: KAL; 8604 Revision Types Settings --->
    <!--- Dev Note: BSD 10523 Disable Revision Type Settings if RevisionTypesOn
          is False --->
    <cfif appSettings.getRevisionTypesOn()>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right" nowrap>Approve Revision Types</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Revision_Types_A" value="1" id="Approve_Revision_Types_A_1" <cfif getSettingsManagerProfiles.Approve_Revision_Types_A EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Revision_Types_A" value="0" id="Approve_Revision_Types_A_0" <cfif getSettingsManagerProfiles.Approve_Revision_Types_A EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Revision_Types_A EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap valign="top">Approve Revision Types</TD>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
      <INPUT TYPE="checkbox" NAME="Approve_Revision_Types_A" VALUE="1">A <a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Revision_Types_A','1')"   TITLE="Update all values for this row.">(+)</a><br>
      <INPUT TYPE="checkbox" NAME="Approve_Revision_Types_B" VALUE="1">B <a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Revision_Types_B','1')"   TITLE="Update all values for this row.">(+)</a><br>
      <INPUT TYPE="checkbox" NAME="Approve_Revision_Types_C" VALUE="1">C <a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Revision_Types_C','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Revision_Types_A NEQ 0>
        <cf_toFile fname="#fName#" data="Approve Revision Types (A-B-C)">
      </cfif>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <SPAN ID="Approve_Revision_TypesCheckboxes">
          <INPUT TYPE="checkbox" NAME="Approve_Revision_Types_A_#i#" class="#i#" MASSUPDATEID="Approve_Revision_Types_A" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Approve_Revision_Types_A") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>A<BR>
          <INPUT TYPE="checkbox" NAME="Approve_Revision_Types_B_#i#" class="#i#" MASSUPDATEID="Approve_Revision_Types_B" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Approve_Revision_Types_B") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>B<BR>
          <INPUT TYPE="checkbox" NAME="Approve_Revision_Types_C_#i#" class="#i#" MASSUPDATEID="Approve_Revision_Types_C" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Approve_Revision_Types_C") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>C
        </SPAN>
        </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Revision_Types_A NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Approve_Revision_Types_A") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
          <CFIF evaluate("Get_#i#_Settings.Approve_Revision_Types_B") EQ 1>
            <cf_toFile fname="#fName#" data="-yes">
          <cfelse>
            <cf_toFile fname="#fName#" data="-no">
          </cfif>
          <CFIF evaluate("Get_#i#_Settings.Approve_Revision_Types_C") EQ 1>
            <cf_toFile fname="#fName#" data="-yes">
          <cfelse>
            <cf_toFile fname="#fName#" data="-no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Revision_Types_A NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    </cfif>

   <!---D38941 :: New Limited User Profile Edit Functionality START--->
    <cfif fromSettings_management eq 1>
    <TR>
      <TD  align="right" nowrap>Limited Revise</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Limited_Revise" value="1" id="Limited_Revise_1" <cfif getSettingsManagerProfiles.Limited_Revise EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			<input type="radio" name="Limited_Revise" value="0" id="Limited_Revise_0" <cfif getSettingsManagerProfiles.Limited_Revise EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Limited_Revise EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Limited Revise</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Limited_Revise NEQ 0><cf_toFile fname="#fName#" data="Limited Revise"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Limited_Revise" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Limited_Revise','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
         <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
         	<SPAN ID="LimitedReviseCheckboxes">
					<INPUT TYPE="checkbox" NAME="Limited_Revise_#i#" class="#i#" MASSUPDATEID="Limited_Revise" PROFILESPAN="document.all.ProfileSpan_#i#" VALUE="1"
								<CFIF evaluate("Get_#i#_Settings.Limited_Revise") EQ 1> CHECKED</CFIF>
						 		MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
			</SPAN>
		</TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Limited_Revise NEQ 0>
          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.Limited_Revise") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Limited_Revise NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  <!---D38941 :: New Limited User Profile Edit Functionality END--->

    <cfif fromSettings_management eq 1>
      <TR>
        <TD  align="right" nowrap>Approve Group Program</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Approve_Group_Deals" value="1" id="Approve_Group_Deals_1" <cfif getSettingsManagerProfiles.Approve_Group_Deals EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Approve_Group_Deals" value="0" id="Approve_Group_Deals_0" <cfif getSettingsManagerProfiles.Approve_Group_Deals EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
      <TR <cfif getSettingsManagerProfiles.Approve_Group_Deals EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Group Program</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Group_Deals NEQ 0><cf_toFile fname="#fName#" data="Approve Group Program"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Group_Deals" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Group_Deals','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><SPAN ID="Approve_Group_Deals_ProgramCheckboxes"><INPUT TYPE="checkbox" NAME="Approve_Group_Deals_#i#" class="#i#" MASSUPDATEID="Approve_Group_Deals" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Approve_Group_Deals") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Group_Deals NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Approve_Group_Deals") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Group_Deals NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right" nowrap>Mass Approve RFA Programs</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Mass_RFA_Program_Approve" value="1" id="Mass_RFA_Program_Approve_1" <cfif getSettingsManagerProfiles.Mass_RFA_Program_Approve EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Mass_RFA_Program_Approve" value="0" id="Mass_RFA_Program_Approve_0" <cfif getSettingsManagerProfiles.Mass_RFA_Program_Approve EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
      <TR ID="TR_Mass_RFA_Program_Approve" <cfif getSettingsManagerProfiles.Mass_RFA_Program_Approve EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Mass Approve RFA Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_RFA_Program_Approve NEQ 0><cf_toFile fname="#fName#" data="Mass Approve RFA Programs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Mass_RFA_Program_Approve" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Mass_RFA_Program_Approve','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><SPAN ID="Approve_All_Products_ProgramCheckboxes"><INPUT TYPE="checkbox" NAME="Mass_RFA_Program_Approve_#i#" class="#i#" MASSUPDATEID="Mass_RFA_Program_Approve" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Mass_RFA_Program_Approve") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_RFA_Program_Approve NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Mass_RFA_Program_Approve") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>   <cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_RFA_Program_Approve NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
      <TR>
      <TD align="right" nowrap>Approve Growth Programs</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Approve_Growth_Programs" value="1" id="Approve_Growth_Programs_1" <cfif getSettingsManagerProfiles.Approve_Growth_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Approve_Growth_Programs" value="0" id="Approve_Growth_Programs_0" <cfif getSettingsManagerProfiles.Approve_Growth_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
      </TR>
    <cfelse>
      <TR <cfif getSettingsManagerProfiles.Approve_Growth_Programs EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Growth Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Growth_Programs NEQ 0><cf_toFile fname="#fName#" data="Approve Growth Programs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Growth_Programs" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Growth_Programs','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><SPAN ID="Approve_Growth_Programs_ProgramCheckboxes"><INPUT TYPE="checkbox" NAME="Approve_Growth_Programs_#i#" class="#i#" MASSUPDATEID="Approve_Growth_Programs" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Approve_Growth_Programs") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Growth_Programs NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Approve_Growth_Programs") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Growth_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
      <!--- Removed with label 19969
      <tr ID="TR_Approve_Upfront_Payments" <cfif getSettingsManagerProfiles.Approve_Upfront_Payments EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Advanced Funds</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Approve Advanced Funds"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Upfront_Payments" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Upfront_Payments','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><SPAN ID="Approve_Upfront_Payments_ProgramCheckboxes"><INPUT TYPE="checkbox" NAME="Approve_Upfront_Payments_#i#" class="#i#" MASSUPDATEID="Approve_Upfront_Payments" PROFILESPAN="document.all.ProfileSpan_#i#" <CFIF evaluate("Get_#i#_Settings.Approve_Upfront_Payments") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></SPAN></TD>
        <cfif saveToXl is "yes">
          <CFIF evaluate("Get_#i#_Settings.Approve_Upfront_Payments") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
       --->

    <!---Equipment Placement --->
    <cfif appSettings.getEquipment_Placement() IS 1>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD  align="right" nowrap>Approve Equipment/Dispenser Placement</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Equipment_Placement" value="1" id="Approve_Equipment_Placement_1" <cfif getSettingsManagerProfiles.Approve_Equipment_Placement EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Equipment_Placement" value="0" id="Approve_Equipment_Placement_0" <cfif getSettingsManagerProfiles.Approve_Equipment_Placement EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Equipment_Placement EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Equipment/Dispenser Placement</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Equipment_Placement NEQ 0><cf_toFile fname="#fName#" data="Approve Equipment/Dispenser Placement"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Equipment_Placement" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Equipment_Placement','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 1)>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Approve_Equipment_Placement_#i#" class="#i#" MASSUPDATEID="Approve_Equipment_Placement" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Approve_Equipment_Placement") IS 1>checked</cfif> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Equipment_Placement NEQ 0>
          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.Approve_Equipment_Placement") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Equipment_Placement NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
  </cfif>
    <!---End Equipment Placement--->

    <!--- If budget is on --->
    <cfif appSettings.getBudgetsFunctionalityOn()>
    <cfscript>
      variables.budgets_none        = -1;
      variables.budgets_view        = 0;
      variables.budgets_view_create = 1;
    </cfscript>
    <cfif fromSettings_management eq 1>
    <TR>
        <TD align="right"  nowrap>Budgets</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp; &nbsp;
              <input type="radio" name="Create_Budget" value="-1"                     <cfif getSettingsManagerProfiles.Create_Budget EQ variables.budgets_none>checked</cfif>> None &nbsp; &nbsp; &nbsp; &nbsp;
              <input type="radio" name="Create_Budget" value="0" id="Create_Budget_0" <cfif getSettingsManagerProfiles.Create_Budget EQ variables.budgets_view>checked</cfif>> View &nbsp; &nbsp; &nbsp; &nbsp;
              <input type="radio" name="Create_Budget" value="1" id="Create_Budget_1" <cfif getSettingsManagerProfiles.Create_Budget EQ 1>checked</cfif>> View & Create &nbsp; &nbsp; &nbsp; &nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Create_Budget EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Budgets - None</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0><cf_toFile fname="#fName#" data="Budgets - None"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Create_Budget_View"  NAME="Create_Budget" VALUE="#variables.budgets_none#"><a href="##" OnClick="javascript:massUpdate('radio','Create_Budget_View','#variables.budgets_none#')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="radio" NAME="Create_Budget_#i#" MASSUPDATEID="Create_Budget_View" value="#variables.budgets_none#" <cfif evaluate("Get_#i#_Settings.Create_Budget") IS variables.budgets_none>checked</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0>
            <cfif evaluate("Get_#i#_Settings.Create_Budget") EQ variables.budgets_none>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    <TR <cfif getSettingsManagerProfiles.Create_Budget EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Budgets - View</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0><cf_toFile fname="#fName#" data="Budgets - View"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Create_Budget_View"  NAME="Create_Budget" VALUE="#variables.budgets_view#"><a href="##" OnClick="javascript:massUpdate('radio','Create_Budget_View','#variables.budgets_view#')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="radio" NAME="Create_Budget_#i#" MASSUPDATEID="Create_Budget_View" value="0" <cfif evaluate("Get_#i#_Settings.Create_Budget") IS variables.budgets_view>checked</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0>
            <cfif evaluate("Get_#i#_Settings.Create_Budget") EQ variables.budgets_view>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
      <TR <cfif getSettingsManagerProfiles.Create_Budget EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Budgets - View & Create</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0><cf_toFile fname="#fName#" data="Budgets - View & Create"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" NAME="Create_Budget" VALUE="#variables.budgets_view_create#"><a href="##" OnClick="javascript:massUpdate('checkbox','Create_Budget','#variables.budgets_view_create#')"   TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="radio" NAME="Create_Budget_#i#" MASSUPDATEID="Create_Budget_Create" value="#variables.budgets_view_create#" <cfif evaluate("Get_#i#_Settings.Create_Budget") IS variables.budgets_view_create>checked</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0>
            <cfif evaluate("Get_#i#_Settings.Create_Budget") EQ variables.budgets_view_create>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Budget NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Approve Program Beyond Budget</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Pgm_Beyond_Budget" value="1" id="Approve_Pgm_Beyond_Budget_1" <cfif getSettingsManagerProfiles.Approve_Pgm_Beyond_Budget EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Pgm_Beyond_Budget" value="0" id="Approve_Pgm_Beyond_Budget_0" <cfif getSettingsManagerProfiles.Approve_Pgm_Beyond_Budget EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Pgm_Beyond_Budget EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Program Beyond Budget</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Pgm_Beyond_Budget NEQ 0><cf_toFile fname="#fName#" data="Approve Program Beyond Budget"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Pgm_Beyond_Budget" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Pgm_Beyond_Budget','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 1)>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Approve_Pgm_Beyond_Budget_#i#" class="#i#" MASSUPDATEID="Approve_Pgm_Beyond_Budget" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Approve_Pgm_Beyond_Budget") IS 1>checked</cfif> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Pgm_Beyond_Budget NEQ 0>
          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
            <cf_toFile fname="#fName#" data=",n/a">
          <CFelseIF evaluate("Get_#i#_Settings.Approve_Pgm_Beyond_Budget") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Pgm_Beyond_Budget NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
<!--- D33473:Budget Actual Adjustments START --->
	  <cfif fromSettings_management eq 1>
	    <TR>
	      <TD align="right"  nowrap>Budgets Actual Adjustment</TD>
	      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
	           <input type="radio" name="Budgets_Actual_Adjustment" value="1" id="Budgets_Actual_Adjustment_1" <cfif getSettingsManagerProfiles.Budgets_Actual_Adjustment EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	           <input type="radio" name="Budgets_Actual_Adjustment" value="0" id="Budgets_Actual_Adjustment_0" <cfif getSettingsManagerProfiles.Budgets_Actual_Adjustment EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	      </TD>
	    </TR>
	  <cfelse>
	    <TR <cfif getSettingsManagerProfiles.Budgets_Actual_Adjustment EQ 0> style="display:none"</cfif>>
	      <TD WIDTH="195" id="locked" class="locked" nowrap>Budgets Actual Adjustment</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Budgets_Actual_Adjustment NEQ 0><cf_toFile fname="#fName#" data="Budgets Actual Adjustment"></cfif>
	      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Budgets_Actual_Adjustment" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Budgets_Actual_Adjustment','1')"   TITLE="Update all values for this row.">(+)</a></TD>
	      <cfloop query="getProfiles">
	      <cfset i = getProfiles.profiles_id>
	      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 1)>
	      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Budgets_Actual_Adjustment_#i#" class="#i#" MASSUPDATEID="Budgets_Actual_Adjustment" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Budgets_Actual_Adjustment") IS 1>checked</cfif> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
	      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Budgets_Actual_Adjustment NEQ 0>
	          <cfif left(trim(checkBoxDisabled),8) eq "disabled">
	            <cf_toFile fname="#fName#" data=",n/a">
	          <CFelseIF evaluate("Get_#i#_Settings.Budgets_Actual_Adjustment") EQ 1>
	            <cf_toFile fname="#fName#" data=",yes">
	          <cfelse>
	            <cf_toFile fname="#fName#" data=",no">
	          </cfif>
	      </cfif>
	      </CFLOOP>
	      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Budgets_Actual_Adjustment NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	    </TR>
	    </cfif>
<!--- D33473:Budget Actual Adjustments END --->
<!--- D64200 :: Create new accrual budget forecast process START --->
<cfif appSettings.get_Setting('Annual_Budget_Forecast') eq '1'>
	  <cfif fromSettings_management eq 1>
	    <TR>
	      <TD align="right"  nowrap>Create #CustomerSettingsLabels.budget_forecast_label#</TD>
	      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
	           <input type="radio" name="Create_Budget_Forecast" value="1" id="Create_Budget_Forecast_1" <cfif getSettingsManagerProfiles.Budget_Forecast EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	           <input type="radio" name="Create_Budget_Forecast" value="0" id="Create_Budget_Forecast_0" <cfif getSettingsManagerProfiles.Budget_Forecast EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	      </TD>
	    </TR>
	  <cfelse>
	    <TR <cfif getSettingsManagerProfiles.Budget_Forecast EQ 0> style="display:none"</cfif>>
	      <TD WIDTH="195" id="locked" class="locked" nowrap>Create #CustomerSettingsLabels.budget_forecast_label#</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Budget_Forecast NEQ 0><cf_toFile fname="#fName#" data="Budgets Actual Adjustment"></cfif>
	      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Create_Budget_Forecast" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Create_Budget_Forecast','1')"   TITLE="Update all values for this row.">(+)</a></TD>
	      <cfloop query="getProfiles">
	      <cfset i = getProfiles.profiles_id>
	      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Create_Budget_Forecast_#i#" class="#i#" MASSUPDATEID="Create_Budget_Forecast" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Budget_Forecast") IS 1>checked</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
	      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Budget_Forecast NEQ 0>
	          <cfif evaluate("Get_#i#_Settings.Budget_Forecast") EQ 1>
	            <cf_toFile fname="#fName#" data=",yes">
	          <cfelse>
	            <cf_toFile fname="#fName#" data=",no">
	          </cfif>
	      </cfif>
	      </CFLOOP>
	      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Budget_Forecast NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	    </TR>
	    </cfif>
</cfif>
<!--- D64200 :: Create new accrual budget forecast process END --->
    </cfif>
    <cfif appSettings.getShow_Fixed_Freight()>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Freight - View & Create</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Freight_View_Create" value="1" id="Freight_View_Create_1" <cfif getSettingsManagerProfiles.Freight_View_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Freight_View_Create" value="0" id="Freight_View_Create_0" <cfif getSettingsManagerProfiles.Freight_View_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Freight_View_Create EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>Freight - View & Create</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create NEQ 0><cf_toFile fname="#fName#" data="Freight - View & Create"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Freight_View_Create_ID" NAME="Freight_View_Create" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','Freight_View_Create_ID','2')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="Freight_View_Create_#i#" class="#i#" MASSUPDATEID="Freight_View_Create_ID" VALUE="2"<CFIF evaluate("Get_#i#_Settings.Freight_View_Create") EQ 2> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Freight_View_Create") EQ 2>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Freight - View</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Freight_View_Create_View" value="1" id="Freight_View_Create_View_1" <cfif getSettingsManagerProfiles.Freight_View_Create_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Freight_View_Create_View" value="0" id="Freight_View_Create_View_0" <cfif getSettingsManagerProfiles.Freight_View_Create_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Freight_View_Create_View EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>Freight - View</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create_View NEQ 0><cf_toFile fname="#fName#" data="Freight - View"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Freight_View" NAME="Freight_View_Create" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','Freight_View','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="Freight_View_Create_#i#" class="#i#" MASSUPDATEID="Freight_View" VALUE="1"<CFIF evaluate("Get_#i#_Settings.Freight_View_Create") EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create_View NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Freight_View_Create") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Freight - None</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Freight_View_Create_None" value="1" id="Freight_View_Create_None_1" <cfif getSettingsManagerProfiles.Freight_View_Create_None EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Freight_View_Create_None" value="0" id="Freight_View_Create_None_0" <cfif getSettingsManagerProfiles.Freight_View_Create_None EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Freight_View_Create_none EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>Freight - None</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create_none NEQ 0><cf_toFile fname="#fName#" data="Freight - None"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Freight_None" NAME="Freight_View_Create" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','Freight_None','0')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="Freight_View_Create_#i#" class="#i#" MASSUPDATEID="Freight_None" VALUE="0"<CFIF evaluate("Get_#i#_Settings.Freight_View_Create") EQ 0> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create_none NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Freight_View_Create") EQ 0>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Freight_View_Create_none NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>



    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Approve Freight Programs</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Freight_Programs" value="1" id="Approve_Freight_Programs_1" <cfif getSettingsManagerProfiles.Approve_Freight_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Freight_Programs" value="0" id="Approve_Freight_Programs_0" <cfif getSettingsManagerProfiles.Approve_Freight_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Freight_Programs EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Freight Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Freight_Programs NEQ 0><cf_toFile fname="#fName#" data="Approve Freight Programs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Freight_Programs" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Freight_Programs','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Approve_Freight_Programs_#i#" class="#i#" MASSUPDATEID="Approve_Freight_Programs" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Approve_Freight_Programs") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Freight_Programs NEQ 0>
          <cfif evaluate("Get_#i#_Settings.Approve_Freight_Programs") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Freight_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>

        <!--- one profile setting column with ONE enabled status value --->
        <cfset render_setting("Approve Freight Adjustment Programs", "Approve_Freight_Adjustment_Programs", 1, "Approve_Freight_Adjustment_Programs")>

    </cfif>

    <cfif appSettings.get_Setting('custom_rfp_process', 0)>
        <!--- one profile setting column with THREE enabled status values: 0, 1, 2 --->
        <cfset render_setting("RFP Freight - View & Create", "RFP_Freight_View_Create", 2, "RFP_Freight_View_Create")>
        <cfset render_setting("RFP Freight - View", "RFP_Freight_View_Create_View", 1, "RFP_Freight_View_Create")>
        <cfset render_setting("RFP Freight - None", "RFP_Freight_View_Create_None", 0, "RFP_Freight_View_Create")>

        <cfset render_setting("RFP Freight FOB / Delivered - View & Create", "RFP_Freight_FOB_Delivered_View_Create", 2, "RFP_Freight_FOB_Delivered_View_Create")>
        <cfset render_setting("RFP Freight FOB / Delivered - View", "RFP_Freight_FOB_Delivered_View_Create_View", 1, "RFP_Freight_FOB_Delivered_View_Create")>
        <cfset render_setting("RFP Freight FOB / Delivered - None", "RFP_Freight_FOB_Delivered_View_Create_None", 0, "RFP_Freight_FOB_Delivered_View_Create")>

        <cfset render_setting_1("RFP Page - Edit RFA", "RFP_Page_Edit_RFA", 1, "RFP_Page_Edit_RFA")>
    </cfif>

    <!--- one profile setting column with 1 enabled status value --->
    <cfset render_setting("View Prog in Duplicate Check Window", "View_Prog_In_Duplicate_Check_Window", 1, "View_Prog_In_Duplicate_Check_Window")>

    <!--- D20217: 2.Volume Details Tab Display setting --->
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Volume Details Tab Display</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Volume_Details_Tab_Display" value="1" id="Volume_Details_Tab_Display_1" <cfif getSettingsManagerProfiles.Volume_Details_Tab_Display EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Volume_Details_Tab_Display" value="0" id="Volume_Details_Tab_Display_0" <cfif getSettingsManagerProfiles.Volume_Details_Tab_Display EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Volume_Details_Tab_Display EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Volume Details Tab Display</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Volume_Details_Tab_Display NEQ 0><cf_toFile fname="#fName#" data="Volume Details Tab Display"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Volume_Details_Tab_Display" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Volume_Details_Tab_Display','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Volume_Details_Tab_Display_#i#" class="#i#" MASSUPDATEID="Volume_Details_Tab_Display" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Volume_Details_Tab_Display") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.Volume_Details_Tab_Display NEQ 0>
          <cfif evaluate("Get_#i#_Settings.Volume_Details_Tab_Display") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Volume_Details_Tab_Display NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>

<!--- START: 56440: 'Duplicate Check' link inside a program/Anand Rao/04-Jan-2016 --->
	<cfif fromSettings_management eq 1>
	    <TR>
	      <TD align="right"  nowrap>View LH pane Duplicate Check Link</TD>
	      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
	            <input type="radio" name="View_LH_Pane_Duplicate_Checker_Link" value="1" id="View_LH_Pane_Duplicate_Checker_Link" <cfif getSettingsManagerProfiles.View_LH_Pane_Duplicate_Checker_Link EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	            <input type="radio" name="View_LH_Pane_Duplicate_Checker_Link" value="0" id="View_LH_Pane_Duplicate_Checker_Link" <cfif getSettingsManagerProfiles.View_LH_Pane_Duplicate_Checker_Link EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
	      </TD>
	    </TR>
	    <cfelse>
	    <TR <cfif getSettingsManagerProfiles.View_LH_Pane_Duplicate_Checker_Link EQ 0> style="display:none"</cfif>>
	      <TD WIDTH="195" id="locked" class="locked" nowrap>View LH pane Duplicate Check Link</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Duplicate_Checker_Link NEQ 0><cf_toFile fname="#fName#" data="View LH Duplicate Check Link"></cfif>
	      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_LH_Pane_Duplicate_Checker_Link" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_LH_Pane_Duplicate_Checker_Link','1')"   TITLE="Update all values for this row.">(+)</a></TD>
	      <cfloop query="getProfiles">
	      <cfset i = getProfiles.profiles_id>
	      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="View_LH_Pane_Duplicate_Checker_Link_#i#" class="#i#" MASSUPDATEID="View_LH_Pane_Duplicate_Checker_Link" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.View_LH_Pane_Duplicate_Checker_Link") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
	      <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Duplicate_Checker_Link NEQ 0>

	          <cfif evaluate("Get_#i#_Settings.View_LH_Pane_Duplicate_Checker_Link") EQ 1>
	            <cf_toFile fname="#fName#" data=",yes">
	          <cfelse>
	            <cf_toFile fname="#fName#" data=",no">
	          </cfif>
	        </cfif>
	      </CFLOOP>
	      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Duplicate_Checker_Link NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	    </TR>
    </cfif>

<!--- END: 56440: 'Duplicate Check' link inside a program/Anand Rao/04-Jan-2016  --->

    <!--- Start: 21828: CAG - display of LH pane link called Budgets/ Anand Rao/30-Dec-09   --->
  <cfif appSettings.getBudgetsFunctionalityOn()>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>View LH pane Budget Link</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_LH_Pane_Budget_Link" value="1" id="View_LH_Pane_Budget_Link_1" <cfif getSettingsManagerProfiles.View_LH_Pane_Budget_Link EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_LH_Pane_Budget_Link" value="0" id="View_LH_Pane_Budget_Link_0" <cfif getSettingsManagerProfiles.View_LH_Pane_Budget_Link EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.View_LH_Pane_Budget_Link EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>View LH pane Budget Link</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Budget_Link NEQ 0><cf_toFile fname="#fName#" data="View LH pane Budget Link"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_LH_Pane_Budget_Link" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_LH_Pane_Budget_Link','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
      <cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
		<input TYPE="checkbox" NAME="View_LH_Pane_Budget_Link_#i#" class="#i#" MASSUPDATEID="View_LH_Pane_Budget_Link" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.View_LH_Pane_Budget_Link") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Budget_Link NEQ 0>
          <cfif evaluate("Get_#i#_Settings.View_LH_Pane_Budget_Link") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Budget_Link NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
  </cfif>
    <!---- End: 21828: CAG - display of LH pane link called Budgets --->

	<!--- Start: 44346: Adding Recapture Link for user profile   --->
	<cfif appSettings.getPullbacksOn()>
		<cfif fromSettings_management eq 1>
			<TR>
			  <TD align="right"  nowrap>View LH pane Recapture Link</TD>
			  <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
					<input type="radio" name="View_LH_Pane_Recapture_Link" value="1" id="View_LH_Pane_Recapture_Link_1" <cfif getSettingsManagerProfiles.View_LH_Pane_Recapture_Link EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<input type="radio" name="View_LH_Pane_Recapture_Link" value="0" id="View_LH_Pane_Recapture_Link_0" <cfif getSettingsManagerProfiles.View_LH_Pane_Recapture_Link EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			  </TD>
			</TR>
		<cfelse>
			<TR <cfif getSettingsManagerProfiles.View_LH_Pane_Recapture_Link EQ 0> style="display:none"</cfif>>
			  <TD WIDTH="195" id="locked" class="locked" nowrap>View LH pane Recapture Link</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Recapture_Link NEQ 0><cf_toFile fname="#fName#" data="View LH pane Recapture Link"></cfif>
			  <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_LH_Pane_Recapture_Link" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_LH_Pane_Recapture_Link','1')"   TITLE="Update all values for this row.">(+)</a></TD>
			  <cfloop query="getProfiles">
			  <cfset i = getProfiles.profiles_id>
			  <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
				<input TYPE="checkbox" NAME="View_LH_Pane_Recapture_Link_#i#" class="#i#" MASSUPDATEID="View_LH_Pane_Recapture_Link" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.View_LH_Pane_Recapture_Link") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
			  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Recapture_Link NEQ 0>
				  <cfif evaluate("Get_#i#_Settings.View_LH_Pane_Recapture_Link") EQ 1>
					<cf_toFile fname="#fName#" data=",yes">
				  <cfelse>
					<cf_toFile fname="#fName#" data=",no">
				  </cfif>
				</cfif>
			  </CFLOOP>
			  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_Pane_Recapture_Link NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
			</TR>
		</cfif>
	</cfif>
    <!---- End: 44346: Adding Recapture Link for user profile --->

  <cfif appSettings.getApprovalStandardOn() or appSettings.getApprovalLayeredOn() >
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>View LH pane Approved Margins Link</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Cont_Prog_View_Approved_Margins" value="1" id="Cont_Prog_View_Approved_Margins_1" <cfif getSettingsManagerProfiles.Cont_Prog_View_Approved_Margins EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Cont_Prog_View_Approved_Margins" value="0" id="Cont_Prog_View_Approved_Margins_0" <cfif getSettingsManagerProfiles.Cont_Prog_View_Approved_Margins EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Cont_Prog_View_Approved_Margins EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>View LH pane Approved Margins Link</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Approved_Margins NEQ 0><cf_toFile fname="#fName#" data="View LH pane Approved Margins Link"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" ID="Cont_Prog_View_Approved_Margins" NAME="Cont_Prog_View_Approved_Margins" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Cont_Prog_View_Approved_Margins','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_View_Margins", 1)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Cont_Prog_View_Approved_Margins_#i#" class="#i#" MASSUPDATEID="Cont_Prog_View_Approved_Margins" VALUE="1"<CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Approved_Margins") EQ 1> CHECKED</CFIF> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Approved_Margins NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Cont_Prog_View_Approved_Margins") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Cont_Prog_View_Approved_Margins NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
	</cfif>
  </cfif>

    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>View LH pane Vertical P&amp;L</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_LH_pane_Vertical_P_L" value="1" id="View_LH_pane_Vertical_P_L_1" <cfif getSettingsManagerProfiles.View_LH_pane_Vertical_P_L EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_LH_pane_Vertical_P_L" value="0" id="View_LH_pane_Vertical_P_L_0" <cfif getSettingsManagerProfiles.View_LH_pane_Vertical_P_L EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.View_LH_pane_Vertical_P_L EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>View LH pane Vertical P&amp;L</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_pane_Vertical_P_L NEQ 0><cf_toFile fname="#fName#" data="View LH pane Vertical P&L"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" ID="View_LH_pane_Vertical_P_L" NAME="View_LH_pane_Vertical_P_L" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_LH_pane_Vertical_P_L','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <cfset variables.disabled = (evaluate("Get_#i#_Settings.Cont_Prog_View_Create_Program") eq 1 ? "" : "disabled")>
      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_View_Margins", 1)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_LH_pane_Vertical_P_L_#i#" class="#i#" MASSUPDATEID="View_LH_pane_Vertical_P_L" #variables.disabled# VALUE="1"<CFIF evaluate("Get_#i#_Settings.View_LH_pane_Vertical_P_L") EQ 1> CHECKED</CFIF> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_pane_Vertical_P_L NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.View_LH_pane_Vertical_P_L") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_pane_Vertical_P_L NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>

    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>View LH pane What If P&amp;L</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_LH_pane_What_If_P_L" value="1" id="View_LH_pane_What_If_P_L_1" <cfif getSettingsManagerProfiles.View_LH_pane_What_If_P_L EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_LH_pane_What_If_P_L" value="0" id="View_LH_pane_What_If_P_L_0" <cfif getSettingsManagerProfiles.View_LH_pane_What_If_P_L EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.View_LH_pane_What_If_P_L EQ 0> style="display:none"</cfif>>
      <TD WIDTH="225" id="locked" class="locked" nowrap>View LH pane What If P&amp;L</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_pane_What_If_P_L NEQ 0><cf_toFile fname="#fName#" data="View LH pane What If P&L"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" ID="View_LH_pane_What_If_P_L" NAME="View_LH_pane_What_If_P_L" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_LH_pane_What_If_P_L','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_View_Margins", 1)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_LH_pane_What_If_P_L_#i#" class="#i#" MASSUPDATEID="View_LH_pane_What_If_P_L" VALUE="1"<CFIF evaluate("Get_#i#_Settings.View_LH_pane_What_If_P_L") EQ 1> CHECKED</CFIF> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_pane_What_If_P_L NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.View_LH_pane_What_If_P_L") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_LH_pane_What_If_P_L NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>

  <!---begin of 26199--->
  <!---Search Inactive Products--->
  <cfif appSettings.getSearchInactiveProductsInPrograms()>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Search inactive products</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Search_Inactive_Products_Programs" value="1" id="Search_Inactive_Products_Programs_1" <cfif getSettingsManagerProfiles.Search_Inactive_Products_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Search_Inactive_Products_Programs" value="0" id="Search_Inactive_Products_Programs_0" <cfif getSettingsManagerProfiles.Search_Inactive_Products_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <tr <cfif getSettingsManagerProfiles.Search_Inactive_Products_Programs EQ 0> style="display:none"</cfif>>
      <td width="225" id="locked" class="locked" nowrap>Search inactive products</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Products_Programs NEQ 0><cf_toFile fname="#fName#" data="Search inactive products"></cfif>
      <td width="#massUpdate_TD_Width#" class="massUpdate" ><input type="checkbox" id="Search_Inactive_Products_Programs" value="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Search_Inactive_Products_Programs','1')"  title="Update all values for this row.">(+)</a></td>
      <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset checkBoxDisabled = "">
        <td align="center" width="#TD_Width#" nowrap><input type="checkbox" name="Search_Inactive_Products_Programs_#i#" class="#i#" MASSUPDATEID="Search_Inactive_Products_Programs" value="1"<cfif Evaluate("Get_#i#_Settings.Search_Inactive_Products_Programs") eq 1> checked</cfif> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Products_Programs NEQ 0>
          <cfif evaluate("Get_#i#_Settings.Search_Inactive_Products_Programs") eq 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Products_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </tr>
    </cfif>
  </cfif>

  <!---Search Inactive Distributors--->
  <cfif appSettings.getSearchInactiveDistributorsInPrograms()>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Search inactive distributors</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Search_Inactive_Distributors_Programs" value="1" id="Search_Inactive_Distributors_Programs_1" <cfif getSettingsManagerProfiles.Search_Inactive_Distributors_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Search_Inactive_Distributors_Programs" value="0" id="Search_Inactive_Distributors_Programs_0" <cfif getSettingsManagerProfiles.Search_Inactive_Distributors_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <tr <cfif getSettingsManagerProfiles.Search_Inactive_Distributors_Programs EQ 0> style="display:none"</cfif>>
      <td width="225" id="locked" class="locked" nowrap>Search inactive distributors</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Distributors_Programs NEQ 0><cf_toFile fname="#fName#" data="Search inactive distributors"></cfif>
      <td width="#massUpdate_TD_Width#" class="massUpdate" ><input type="checkbox" id="Search_Inactive_Distributors_Programs" value="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Search_Inactive_Distributors_Programs','1')"  title="Update all values for this row.">(+)</a></td>
      <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset checkBoxDisabled = "">
        <td align="center" width="#TD_Width#" nowrap><input type="checkbox" name="Search_Inactive_Distributors_Programs_#i#" class="#i#" MASSUPDATEID="Search_Inactive_Distributors_Programs" value="1"<cfif Evaluate("Get_#i#_Settings.Search_Inactive_Distributors_Programs") eq 1> checked</cfif> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Distributors_Programs NEQ 0>
          <cfif evaluate("Get_#i#_Settings.Search_Inactive_Distributors_Programs") eq 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Distributors_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </tr>
    </cfif>
  </cfif>

  <!---Search Inactive Operators--->
  <cfif appSettings.getSearchInactiveOperatorsInPrograms()>
  <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Search inactive operators</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Search_Inactive_Operators_Programs" value="1" id="Search_Inactive_Operators_Programs_1" <cfif getSettingsManagerProfiles.Search_Inactive_Operators_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Search_Inactive_Operators_Programs" value="0" id="Search_Inactive_Operators_Programs_0" <cfif getSettingsManagerProfiles.Search_Inactive_Operators_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <tr <cfif getSettingsManagerProfiles.Search_Inactive_Operators_Programs EQ 0> style="display:none"</cfif>>
      <td width="225" id="locked" class="locked" nowrap>Search inactive operators</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Operators_Programs NEQ 0><cf_toFile fname="#fName#" data="Search inactive operators"></cfif>
      <td width="#massUpdate_TD_Width#" class="massUpdate" ><input type="checkbox" id="Search_Inactive_Operators_Programs" value="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Search_Inactive_Operators_Programs','1')"  title="Update all values for this row.">(+)</a></td>
      <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset checkBoxDisabled = "">
        <td align="center" width="#TD_Width#" nowrap><input type="checkbox" name="Search_Inactive_Operators_Programs_#i#" class="#i#" MASSUPDATEID="Search_Inactive_Operators_Programs" value="1"<cfif Evaluate("Get_#i#_Settings.Search_Inactive_Operators_Programs") eq 1> checked</cfif> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Operators_Programs NEQ 0>
          <cfif evaluate("Get_#i#_Settings.Search_Inactive_Operators_Programs") eq 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Inactive_Operators_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </tr>
    </cfif>
  </cfif>
  <!---end of 26199--->
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>View CRA Analysis Rpt</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="View_Workflow_Report_Data" value="1" id="View_Workflow_Report_Data_1" <cfif getSettingsManagerProfiles.View_Workflow_Report_Data EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="View_Workflow_Report_Data" value="0" id="View_Workflow_Report_Data_0" <cfif getSettingsManagerProfiles.View_Workflow_Report_Data EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.View_Workflow_Report_Data EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>View CRA Analysis Rpt</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Workflow_Report_Data NEQ 0><cf_toFile fname="#fName#" data="View CRA Analysis Rpt"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Workflow_Report_Data" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Workflow_Report_Data','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="View_Workflow_Report_Data_#i#" class="#i#" MASSUPDATEID="View_Workflow_Report_Data" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.View_Workflow_Report_Data") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Workflow_Report_Data NEQ 0>
        <cfif evaluate("Get_#i#_Settings.View_Workflow_Report_Data") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Workflow_Report_Data NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
<!--- 25709: EZ Button --->
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>EZ Button - Approve Beyond Max Rate</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="EzButton_Approve_Beyond_MaxRate" value="1" id="EzButton_Approve_Beyond_MaxRate_1" <cfif getSettingsManagerProfiles.EzButton_Approve_Beyond_MaxRate EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="EzButton_Approve_Beyond_MaxRate" value="0" id="EzButton_Approve_Beyond_MaxRate_0" <cfif getSettingsManagerProfiles.EzButton_Approve_Beyond_MaxRate EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.EzButton_Approve_Beyond_MaxRate EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>EZ Button - Approve Beyond  Max Rate</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.EzButton_Approve_Beyond_MaxRate NEQ 0><cf_toFile fname="#fName#" data="EZ Button - Approve Beyond  Max Rate"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="EzButton_Approve_Beyond_MaxRate" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','EzButton_Approve_Beyond_MaxRate','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="EzButton_Approve_Beyond_MaxRate_#i#" class="#i#" MASSUPDATEID="EzButton_Approve_Beyond_MaxRate" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.EzButton_Approve_Beyond_MaxRate") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.EzButton_Approve_Beyond_MaxRate NEQ 0>
        <cfif evaluate("Get_#i#_Settings.EzButton_Approve_Beyond_MaxRate") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.EzButton_Approve_Beyond_MaxRate NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>

  <!--- 27180: Bracket pricing logic with selection of override --->

  	<!--- D26123: Volume Forecast
	  	Added: New Profile Setting know as Volume Forecast Below START --->
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Volume Forecast</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Volume_Forecast" value="1" id="Volume_Forecast_1" <cfif getSettingsManagerProfiles.Volume_Forecast EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Volume_Forecast" value="0" id="Volume_Forecast_0" <cfif getSettingsManagerProfiles.Volume_Forecast EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Volume_Forecast EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Volume Forecast</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Volume_Forecast NEQ 0><cf_toFile fname="#fName#" data="Volume Forecast"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Volume_Forecast" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Volume_Forecast','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Volume_Forecast_#i#" class="#i#" MASSUPDATEID="Volume_Forecast" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Volume_Forecast") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Volume_Forecast NEQ 0>
        <cfif evaluate("Get_#i#_Settings.Volume_Forecast") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Volume_Forecast NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  	<!--- D26123: Volume Forecast END --->

  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Edit Volume Forecasts Below Me</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Edit_Volume_FC_Below_Me" value="1" id="Edit_Volume_FC_Below_Me_1" <cfif getSettingsManagerProfiles.Edit_Volume_FC_Below_Me EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Edit_Volume_FC_Below_Me" value="0" id="Edit_Volume_FC_Below_Me_0" <cfif getSettingsManagerProfiles.Edit_Volume_FC_Below_Me EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Volume_Forecast EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Edit Volume Forecasts Below Me</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Volume_FC_Below_Me NEQ 0><cf_toFile fname="#fName#" data="Edit Volume Forecasts Below Me"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Edit_Volume_FC_Below_Me" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Edit_Volume_FC_Below_Me','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Edit_Volume_FC_Below_Me_#i#" class="#i#" MASSUPDATEID="Edit_Volume_FC_Below_Me" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Edit_Volume_FC_Below_Me") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Volume_FC_Below_Me NEQ 0>
        <cfif evaluate("Get_#i#_Settings.Edit_Volume_FC_Below_Me") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Volume_FC_Below_Me NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>

  <!--- Dev Note: Milan (36010): Add a setting called "Templates". Users will be able to select templates for Approval/Agree/Billback etc for a particular profile.  --->
  <cfif fromSettings_management eq 1>
    <TR>
      <TD  align="right" nowrap>Templates</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Add_Templates_To_Profile" value="1" id="Add_Templates_To_Profile_1" <cfif getSettingsManagerProfiles.Add_Templates_To_Profile EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Add_Templates_To_Profile" value="0" id="Add_Templates_To_Profile_0" <cfif getSettingsManagerProfiles.Add_Templates_To_Profile EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Add_Templates_To_Profile EQ 0> style="display:none"</cfif>>
						<TD style="background-color: whitesmoke;border-right: 1px solid silver;position: relative;border-top:0px;border-bottom: 0px" nowrap>&nbsp;</TD>
        <TD style="border-top:0px;border-bottom: 0px">&nbsp;</TD>
    </TR>
    <TR <cfif getSettingsManagerProfiles.Add_Templates_To_Profile EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Templates</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.Add_Templates_To_Profile NEQ 0><cf_toFile fname="#fName#" data="Templates"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >&nbsp;</TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#">

		<cfif #frmREADONLY# EQ "DISABLED">
			<span style="color:999999;"><B>VIEW</B></span>
		<cfelse>
        <span value="#i#" style="color:000000;">
        	<a href="profile_template.cfm?profileId=#i#" onclick="javaScript: allowBlur(); NewWindow(this.href , 'Profile_Template_Access' , 830 , 750 , 'yes' , 'yes'); return false;" target="_blank"><B>VIEW</B></a>
		</span>
		</cfif>
    </span>
		</TD>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Add_Templates_To_Profile NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>

  <CFIF appSettings.getUseFixedPriceType() EQ 1>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Edit Price Bracket</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Edit_Price_Bracket" value="1" id="Edit_Price_Bracket_1" <cfif getSettingsManagerProfiles.Edit_Price_Bracket EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Edit_Price_Bracket" value="0" id="Edit_Price_Bracket_0" <cfif getSettingsManagerProfiles.Edit_Price_Bracket EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Edit_Price_Bracket EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Edit Price Bracket</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Price_Bracket NEQ 0><cf_toFile fname="#fName#" data="Edit Price Bracket"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Edit_Price_Bracket" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Edit_Price_Bracket','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Edit_Price_Bracket_#i#" class="#i#" MASSUPDATEID="Edit_Price_Bracket" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Edit_Price_Bracket") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Price_Bracket NEQ 0>
        <cfif evaluate("Get_#i#_Settings.Edit_Price_Bracket") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Price_Bracket NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  </CFIF>
<!---D42287 :: Competitive Info not required by User Profile START--->
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Competitive Info not required</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Competitive_Info_not_required" value="1" id="Competitive_Info_not_required_1" <cfif getSettingsManagerProfiles.Competitive_Info_not_required EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Competitive_Info_not_required" value="0" id="Competitive_Info_not_required_0" <cfif getSettingsManagerProfiles.Competitive_Info_not_required EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Competitive_Info_not_required EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Competitive Info not required</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Competitive_Info_not_required NEQ 0><cf_toFile fname="#fName#" data="Competitive Info not required"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Competitive_Info_not_required" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Competitive_Info_not_required','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Competitive_Info_not_required_#i#" class="#i#" MASSUPDATEID="Competitive_Info_not_required" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Competitive_Info_not_required") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Competitive_Info_not_required NEQ 0>
        <cfif evaluate("Get_#i#_Settings.Competitive_Info_not_required") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Competitive_Info_not_required NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
<!--- D42287 :: Competitive Info not required by User Profile END--->

<!---44077 :: Mass Change Program Date START--->
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Mass Change Program Start Date</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Mass_Change_Program_Date" value="1" id="Mass_Change_Program_Date_1" <cfif getSettingsManagerProfiles.Mass_Change_Program_Date EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Mass_Change_Program_Date" value="0" id="Mass_Change_Program_Date_0" <cfif getSettingsManagerProfiles.Mass_Change_Program_Date EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Mass_Change_Program_Date EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Mass Change Program Date</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_Change_Program_Date NEQ 0><cf_toFile fname="#fName#" data="Mass Change Program Date"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Mass_Change_Program_Date" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Mass_Change_Program_Date','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Mass_Change_Program_Date_#i#" class="#i#" MASSUPDATEID="Mass_Change_Program_Date" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Mass_Change_Program_Date") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_Change_Program_Date NEQ 0>
        <cfif evaluate("Get_#i#_Settings.Mass_Change_Program_Date") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Mass_Change_Program_Date NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
<!---44077 :: Mass Change Program Date END --->

<!---D50074 :: Viewing and Editing prior program versions START--->
<cfif appSettings.getModifyExpiredPrograms()>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Modify Expired Programs</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Modify_Expired_Programs" value="1" id="Modify_Expired_Programs_1" <cfif getSettingsManagerProfiles.Modify_Expired_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Modify_Expired_Programs" value="0" id="Modify_Expired_Programs_0" <cfif getSettingsManagerProfiles.Modify_Expired_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Modify_Expired_Programs EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Modify Expired Programs<img src="/images/help_small.gif" title="The 'MODIFY' feature allows authorized users to edit previously approved program versions that have expired.  The changes will not affect other versions with effective dates prior to or after the version modified.  Modifications will not route for approval through the normal workflow.  The actions of the user will replace the existing content for the version." /></TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Modify_Expired_Programs NEQ 0><cf_toFile fname="#fName#" data="Modify Expired Programs"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Modify_Expired_Programs" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Modify_Expired_Programs','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Modify_Expired_Programs_#i#" class="#i#" MASSUPDATEID="Modify_Expired_Programs" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Modify_Expired_Programs") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Modify_Expired_Programs NEQ 0>
        <cfif evaluate("Get_#i#_Settings.Modify_Expired_Programs") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Modify_Expired_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
</cfif>
<!---D50074 :: Viewing and Editing prior program versions  END --->

<!--- D66995 :: Rework - Best Plans START --->
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Best Plan Program Access</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
             <input type="radio" name="Best_Plan_Program" value="1" id="Best_Plan_Program_1" <cfif getSettingsManagerProfiles.Best_Plan_Program EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
             <input type="radio" name="Best_Plan_Program" value="0" id="Best_Plan_Program_0" <cfif getSettingsManagerProfiles.Best_Plan_Program EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
      <TR <cfif getSettingsManagerProfiles.Best_Plan_Program EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Best Plan Program Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Best_Plan_Program NEQ 0><cf_toFile fname="#fName#" data="Best Plan Program"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Best_Plan_Program" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Best_Plan_Program','1')"   TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Best_Plan_Program_#i#" class="#i#" MASSUPDATEID="Best_Plan_Program" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Best_Plan_Program") IS 1>checked</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Best_Plan_Program NEQ 0>
            <cfif evaluate("Get_#i#_Settings.Best_Plan_Program") EQ 1>
              <cf_toFile fname="#fName#" data=",yes">
            <cfelse>
              <cf_toFile fname="#fName#" data=",no">
            </cfif>
        </cfif>
        </CFLOOP>
        <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Best_Plan_Program NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
<!--- D66995 :: Rework - Best Plans  END --->

<!--- 81335 :: Tyson feedback on program upload feature 10 15 2018 START --->
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Upload Programs</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
             <input type="radio" name="Upload_Programs" value="1" id="Upload_Programs_1" <cfif getSettingsManagerProfiles.Upload_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
             <input type="radio" name="Upload_Programs" value="0" id="Upload_Programs_0" <cfif getSettingsManagerProfiles.Upload_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
      <TR <cfif getSettingsManagerProfiles.Upload_Programs EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Upload Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Upload_Programs NEQ 0><cf_toFile fname="#fName#" data="Upload Programs"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Upload_Programs" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Upload_Programs','1')"   TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Upload_Programs_#i#" class="#i#" MASSUPDATEID="Upload_Programs" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Upload_Programs") IS 1>checked</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Upload_Programs NEQ 0>
            <cfif evaluate("Get_#i#_Settings.Upload_Programs") EQ 1>
              <cf_toFile fname="#fName#" data=",yes">
            <cfelse>
              <cf_toFile fname="#fName#" data=",no">
            </cfif>
        </cfif>
        </CFLOOP>
        <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Upload_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
<!--- 81335 :: Tyson feedback on program upload feature 10 15 2018  END --->

<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// New Approval Options Code  ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->


    <cfset useLakebaseForgetApprovalMargin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_profile_approval_margins")>
<cfif useLakebaseForgetApprovalMargin>
	<cftry>
		<cfset getApprovalMargin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_group_profile_approval_margins", {
				"deleted" = "eq.0",
				"select" = "group_id,profile_id,amount,approval_method"
			}), "group_id,profile_id,amount,approval_method"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetApprovalMargin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetApprovalMargin>
<CFQUERY NAME="getApprovalMargin" datasource="#application.datasource#">
      SELECT  Group_ID, Profile_ID, Amount, Approval_Method
      FROM  Margin_Group_Profile_Approval_Margins
      WHERE   Deleted = 0
    </CFQUERY>
</cfif>
    <cfset marginDetailsClosed = "yes">

    <cfset AvailableApprovalOptions = genSettingsManager.getApprovalTypeList()>
    <!--- #AvailableApprovalOptions#:::::::::#appSettings.getApprovalLayeredOn()#::::::#genSettingsManager.getApprovalTypeList()# --->

    <cfif ListLen(AvailableApprovalOptions, ",") eq 1>
      <cfset marginDetailsClosed = "no">
    </cfif>
    <!------ loop over the different approval types
    1:
     ----->
     <tr><td id="subheader" class="locked" align="left">Approval Options -  Profile Settings</td></tr>
    <CFLOOP INDEX="ThisApprovalType" list="#AvailableApprovalOptions#">

    <CFSET Approval_Method_Name = "$ Per Pound Margin">
      <CFIF ThisApprovalType EQ 2>
        <CFSET Approval_Method_Name = "Percentage Margin">
      <CFELSEIF ThisApprovalType EQ 3>
        <CFSET Approval_Method_Name = "Total Program % Margin">
      <CFELSEIF ThisApprovalType EQ 4>
        <CFSET Approval_Method_Name = "Spending Cap">
      <CFELSEIF ThisApprovalType EQ 5>
        <CFSET Approval_Method_Name = "Layered">
      <CFELSEIF ThisApprovalType EQ 6>
        <CFSET Approval_Method_Name = "Disposable Goods">
      <CFELSEIF ThisApprovalType EQ 7>
        <CFSET Approval_Method_Name = "Standard">
      </CFIF>
    <TR><TD id="subheader" class="locked" style="font-weight:bold;background-color:RGB(56,56,56);" align="left">Approval Method - #Approval_Method_Name#</TD></tr>
    <!--- Write the header record to XL --->
    <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" nl="Yes" data="Approval Method - #Approval_Method_Name#"></cfif>

    <CFIF ThisApprovalType NEQ 3 AND ThisApprovalType NEQ 5 AND ThisApprovalType NEQ 6 AND ThisApprovalType NEQ 7>
      <CFPARAM NAME="GetSetting_Display_Value.Setting_Display_Value" DEFAULT="1">
      <CFSET qgetProfileGroupApprovalTypeSettings = CreateObject("component", "components.settings.settings_management.TemplateSettingsManager").getProfileGroupApprovalTypeSettings(#ThisApprovalType#)>

    <CFLOOP INDEX="GroupCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">
        <cfset useLakebaseForGetSetting_Display_Value = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("qgetprofilegroupapprovaltypesettings")>
<cfif useLakebaseForGetSetting_Display_Value>
	<cftry>
		<cfset GetSetting_Display_Value = application.oLakebase.toQuery(
			application.oLakebase.selectRows("qgetprofilegroupapprovaltypesettings", {
				"group_labels_approval_group_count" = "eq.#GroupCount#",
				"select" = "setting_display_value"
			}), "setting_display_value"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetSetting_Display_Value = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetSetting_Display_Value>
<cfquery name="GetSetting_Display_Value" dbtype="query" >
          SELECT    Setting_Display_Value
          FROM    qgetProfileGroupApprovalTypeSettings
          WHERE     Group_Labels_Approval_Group_Count = #GroupCount#

        </cfquery>
</cfif>
      <cfif fromSettings_management eq 1>
      <TR>
          <cfset numCount = 3 - len(GroupCount)>
          <CFSET labelIndex = "">
          <cfloop index="z" from="1" to="#numCount#" step="1">
            <cfset labelIndex = labelIndex & "0">
          </cfloop>
          <cfset labelIndex = labelIndex & GroupCount>
          <TD GROUP_ID="#GroupCount#"  align="right" nowrap> #evaluate("application.returned_customer_setting.approval_group_count_#labelIndex#_label")# </TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile" value="1" id="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile_1" <cfif GetSetting_Display_Value.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile" value="0" id="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile_0" <cfif GetSetting_Display_Value.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();"  <cfif GetSetting_Display_Value.Setting_Display_Value EQ 0> style="display:none"</cfif> >
          <cfset numCount = 3 - len(GroupCount)>
          <CFSET labelIndex = "">
          <cfloop index="z" from="1" to="#numCount#" step="1">
            <cfset labelIndex = labelIndex & "0">
          </cfloop>
          <cfset labelIndex = labelIndex & GroupCount>

          <TD GROUP_ID="#GroupCount#" id="locked" class="locked" WIDTH="195" nowrap>
          <!--- <span STYLE="color: blue; cursor:pointer;" ONCLICK="assignTypeCodesToGroup(this.parentElement)" class="groupLabel">#evaluate("application.returned_customer_setting.approval_group_count_#labelIndex#_label")#</span> --->
            <cfif #frmREADONLY# eq "DISABLED">
            	#evaluate("application.returned_customer_setting.approval_group_count_#labelIndex#_label")#
             <cfelse>
            	<span STYLE="color: blue; cursor:pointer;" ONCLICK="assignTypeCodesToGroup(this.parentElement)">#evaluate("application.returned_customer_setting.approval_group_count_#labelIndex#_label")#</span>
            </cfif>
            <cfif saveToXl is "yes" and GetSetting_Display_Value.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" data="#evaluate("application.returned_customer_setting.approval_group_count_#labelIndex#_label")#"></cfif>
          </TD>
          <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><input TYPE="text" SIZE="5" NAME="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile" ID="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile" VALUE="" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile','1')" TITLE="Update all values for this row.">(+)</a></TD>
          <cfloop query="getProfiles">
            <!------ Get group Value for this Profile ----->
            <cfset useLakebaseForqGetMarginValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getapprovalmargin")>
<cfif useLakebaseForqGetMarginValues>
	<cftry>
		<cfset qGetMarginValues = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getapprovalmargin", {
				"group_id" = "eq.#GroupCount#",
				"profile_id" = "eq.#profiles_id#",
				"approval_method" = "eq.#ThisApprovalType#",
				"select" = "amount"
			}), "amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetMarginValues = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetMarginValues>
<cfquery name="qGetMarginValues" dbtype="query">
              SELECT  Amount
              FROM  getApprovalMargin
              WHERE Group_ID = #GroupCount#
                  AND Profile_ID = #profiles_id#
                  AND Approval_Method = #ThisApprovalType#
            </cfquery>
</cfif>
            <cfset i = getProfiles.profiles_id>
            <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
            <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#">
            	 <input TYPE="text" NAME="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile_#i#" SIZE="5" MASSUPDATEID="Group_Approval_Type_#ThisApprovalType#_#GroupCount#_Profile" VALUE="<cfif len(trim(qGetMarginValues.Amount)) EQ 0>0.000<cfelse>#qGetMarginValues.Amount#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
            </TD>
            <cfif saveToXl is "yes" and GetSetting_Display_Value.Setting_Display_Value NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                 <cf_toFile fname="#fName#" data=",#qGetMarginValues.Amount#">
              </cfif>
            </cfif>
          </CFLOOP>
          <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and GetSetting_Display_Value.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </CFLOOP>
    </CFIF>
    <CFIF ThisApprovalType EQ 3>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Total Program % Margin</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Group_Approval_Type_3_1_Profile" value="1" id="Group_Approval_Type_3_1_Profile_1" <cfif Group_Approval_Type_3_1_Profile EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Group_Approval_Type_3_1_Profile" value="0" id="Group_Approval_Type_3_1_Profile_0" <cfif Group_Approval_Type_3_1_Profile EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
     <cfelse>
      <TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Group_Approval_Type_3_1_Profile EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Total Program % Margin</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Group_Approval_Type_3_1_Profile NEQ 0><cf_toFile fname="#fName#" data="Total Program % Margin"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text"  SIZE="5" NAME="Group_Approval_Type_#ThisApprovalType#_1_Profile" ID="Group_Approval_Type_#ThisApprovalType#_1_Profile" VALUE="" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Group_Approval_Type_#ThisApprovalType#_1_Profile','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <!------ Get group Value for this Profile ----->
        <cfquery name="qGetMarginValues" dbtype="query">
          SELECT  Amount
          FROM  getApprovalMargin
          WHERE Profile_ID = #profiles_id#
              AND Approval_Method = #ThisApprovalType#
        </cfquery>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="text" NAME="Group_Approval_Type_#ThisApprovalType#_1_Profile_#i#" class="#i#" MASSUPDATEID="Group_Approval_Type_#ThisApprovalType#_1_Profile" SIZE="5" VALUE="#qGetMarginValues.Amount#" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Group_Approval_Type_3_1_Profile NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#qGetMarginValues.Amount#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Group_Approval_Type_3_1_Profile NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
    <CFELSEIF ThisApprovalType EQ 4>
      <cfif appSettings.getApproveLSComponentByProfile() NEQ 1>
      <!---Loop through active, non-deleted lump sum amounts--->
      <cfloop query="GetLumpSums">
      <cfset lsNameID = GetLumpSums.Program_Lump_Sum_Name_ID>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>#Program_Lump_Sum_Name#</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Program_LSN_#lsNameID#" value="1" id="Program_LSN_#lsNameID#_1" <cfif GetLumpSums.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Program_LSN_#lsNameID#" value="0" id="Program_LSN_#lsNameID#_0" <cfif GetLumpSums.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();"  <cfif GetLumpSums.Setting_Display_Value EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>#Program_Lump_Sum_Name#</TD>  <cfif saveToXl is "yes" and GetLumpSums.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" data="#Program_Lump_Sum_Name#"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text"  SIZE="5" NAME="Program_LSN_#lsNameID#" ID="Program_LSN_#lsNameID#" VALUE="" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Program_LSN_#lsNameID#','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset useLakebaseForGetApprovalAmountforProfile = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("profile_ls_approval")>
<cfif useLakebaseForGetApprovalAmountforProfile>
	<cftry>
		<cfset GetApprovalAmountforProfile = application.oLakebase.toQuery(
			application.oLakebase.selectRows("profile_ls_approval", {
				"profiles_id" = "eq.#i#",
				"program_lump_sum_name_id" = "eq.#lsNameID#",
				"select" = "approval_amount"
			}), "approval_amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetApprovalAmountforProfile = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetApprovalAmountforProfile>
<cfquery name="GetApprovalAmountforProfile" datasource="#application.datasource#">
          Select  Approval_Amount
          FROM  Profile_LS_Approval
          WHERE   Profiles_ID = #i#
              AND Program_Lump_Sum_Name_ID = #lsNameID#
        </cfquery>
</cfif>

        <cfif GetApprovalAmountforProfile.Recordcount LT 1>
          <cfset Approval_Amount = 0>
        </cfif>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="text" NAME="Program_Lump_Sum_Name_#i#_#lsNameID#" MASSUPDATEID="Program_LSN_#lsNameID#" SIZE="5" VALUE="<cfif GetApprovalAmountforProfile.Approval_Amount IS "*">#GetApprovalAmountforProfile.Approval_Amount#<cfelse>#numberformat(GetApprovalAmountforProfile.Approval_Amount, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
            <cfif saveToXl is "yes" and GetLumpSums.Setting_Display_Value NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#GetApprovalAmountforProfile.Approval_Amount#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and GetLumpSums.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfloop>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Total #Application.LumpsumLabel# Approval</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Total_LS_Approval_Amount" value="1" id="Total_LS_Approval_Amount_1" <cfif getSettingsManagerProfiles.Total_LS_Approval_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Total_LS_Approval_Amount" value="0" id="Total_LS_Approval_Amount_0" <cfif getSettingsManagerProfiles.Total_LS_Approval_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Total_LS_Approval_Amount EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Total #Application.LumpsumLabel# Approval</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Total_LS_Approval_Amount NEQ 0><cf_toFile fname="#fName#" data="Total #Application.LumpsumLabel# Approval"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Total_LS_Approval_Amount" ID="Total_LS_Approval_Amount" VALUE="" onkeyup="clenseTextBuffer(this, '*-.02134567890')" ><a href="##" OnClick="javascript:massUpdate('textbox','Total_LS_Approval_Amount','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
          <cfset i = getProfiles.profiles_id>
          <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="text" NAME="Total_LS_Approval_Amount_#i#" SIZE="5" MASSUPDATEID="Total_LS_Approval_Amount" VALUE="<cfif evaluate("Get_#i#_Settings.Total_LS_Approval_Amount") IS "*">#evaluate("Get_#i#_Settings.Total_LS_Approval_Amount")#<cfelse> #numberformat(evaluate("Get_#i#_Settings.Total_LS_Approval_Amount"), '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Total_LS_Approval_Amount NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#evaluate("Get_#i#_Settings.Total_LS_Approval_Amount")#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Total_LS_Approval_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Inactive #Application.LumpsumLabel# Approval</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Inactive_LS_Approval_Amount" value="1" id="Inactive_LS_Approval_Amount_1" <cfif getSettingsManagerProfiles.Inactive_LS_Approval_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Inactive_LS_Approval_Amount" value="0" id="Inactive_LS_Approval_Amount_0" <cfif getSettingsManagerProfiles.Inactive_LS_Approval_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Inactive_LS_Approval_Amount EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Inactive #Application.LumpsumLabel# Approval</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Inactive_LS_Approval_Amount NEQ 0><cf_toFile fname="#fName#" data="Inactive #Application.LumpsumLabel# Approval"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Inactive_LS_Approval_Amount" ID="Inactive_LS_Approval_Amount" VALUE="" onkeyup="clenseTextBuffer(this, '*-.02134567890')" ><a href="##" OnClick="javascript:massUpdate('textbox','Inactive_LS_Approval_Amount','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
          <cfset i = getProfiles.profiles_id>
          <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="text" NAME="Inactive_LS_Approval_Amount_#i#" SIZE="5"  MASSUPDATEID="Inactive_LS_Approval_Amount" VALUE="<cfif evaluate("Get_#i#_Settings.Inactive_LS_Approval_Amount") IS "*">#evaluate("Get_#i#_Settings.Inactive_LS_Approval_Amount")#<cfelse> #numberformat(evaluate("Get_#i#_Settings.Inactive_LS_Approval_Amount"), '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Inactive_LS_Approval_Amount NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#evaluate("Get_#i#_Settings.Inactive_LS_Approval_Amount")#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Inactive_LS_Approval_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Growth #Application.LumpsumLabel# Approval</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Lump_Sum_Approval_Amount" value="1" id="Lump_Sum_Approval_Amount_1" <cfif getSettingsManagerProfiles.Lump_Sum_Approval_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Lump_Sum_Approval_Amount" value="0" id="Lump_Sum_Approval_Amount_0" <cfif getSettingsManagerProfiles.Lump_Sum_Approval_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Lump_Sum_Approval_Amount EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Growth #Application.LumpsumLabel# Approval</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Lump_Sum_Approval_Amount NEQ 0><cf_toFile fname="#fName#" data="Growth #Application.LumpsumLabel# Approval"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Lump_Sum_Approval_Amount" ID="Lump_Sum_Approval_Amount" VALUE="" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Lump_Sum_Approval_Amount','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
          <cfset i = getProfiles.profiles_id>
          <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="text" NAME="Lump_Sum_Approval_Amount_#i#" class="#i#" MASSUPDATEID="Lump_Sum_Approval_Amount" SIZE="5" VALUE="<cfif evaluate("Get_#i#_Settings.Lump_Sum_Approval_Amount") IS "*">#evaluate("Get_#i#_Settings.Lump_Sum_Approval_Amount")#<cfelse> #numberformat(evaluate("Get_#i#_Settings.Lump_Sum_Approval_Amount"), '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Lump_Sum_Approval_Amount NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#evaluate("Get_#i#_Settings.Lump_Sum_Approval_Amount")#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Lump_Sum_Approval_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>
      <!---end appSettings.getApproveLSComponentByProfile() NEQ 1 --->
      <!---Only show for spending cap--->
      <!---Only show if it's turned on in application settings--->
      <cfif appSettings.getFloorPrice() IS 1>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approve Below Pricing Floor</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Below_Floor" value="1" id="Approve_Below_Floor_1" <cfif getSettingsManagerProfiles.Approve_Below_Floor EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Below_Floor" value="0" id="Approve_Below_Floor_0" <cfif getSettingsManagerProfiles.Approve_Below_Floor EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR <cfif getSettingsManagerProfiles.Approve_Below_Floor EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Below Pricing Floor</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Below_Floor NEQ 0><cf_toFile fname="#fName#" data="Approve Below Pricing Floor"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Below_Floor" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Below_Floor','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="checkbox" NAME="Approve_Below_Floor_#i#" class="#i#" MASSUPDATEID="Approve_Below_Floor" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Approve_Below_Floor") IS 1>checked</cfif> #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Below_Floor NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelseif evaluate("Get_#i#_Settings.Approve_Below_Floor") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Below_Floor NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approve Below Pricing Floor Amount</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Below_Floor_Amount" value="1" id="Approve_Below_Floor_Amount_1" <cfif getSettingsManagerProfiles.Approve_Below_Floor_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Below_Floor_Amount" value="0" id="Approve_Below_Floor_Amount_0" <cfif getSettingsManagerProfiles.Approve_Below_Floor_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Approve_Below_Floor_Amount EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Below Pricing Floor Amount</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Below_Floor_Amount NEQ 0><cf_toFile fname="#fName#" data="Approve Below Pricing Floor Amount"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Below_Floor_Amount" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Below_Floor_Amount','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#"><input TYPE="text" NAME="Approve_Below_Floor_Amount_#i#" class="#i#" MASSUPDATEID="Approve_Below_Floor_Amount" SIZE="5" <cfif isNumeric(evaluate("Get_#i#_Settings.Approve_Below_Floor_Amount"))>VALUE="#numberformat(evaluate("Get_#i#_Settings.Approve_Below_Floor_Amount"), '_.___')#"<cfelse>VALUE="#trim(evaluate("Get_#i#_Settings.Approve_Below_Floor_Amount"))#"</cfif> onkeyup="clenseTextBuffer(this, '-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></span></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Below_Floor_Amount NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#evaluate("Get_#i#_Settings.Approve_Below_Floor_Amount")#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Below_Floor_Amount NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>
      <!---End pricing floor only--->
      <!----End spending cap only--->
    <CFELSEIF ThisApprovalType EQ 5>
      <!-----layered---->
      <cfif appSettings.getRestrictAccessOnGroup()>
      <cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>#approvalGroupType.Label# Access/Approve</TD>
        <!--- created setting_name called approvalGroupType_view in Setting_list to match the popup window in user profiles setting page--->
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="approvalGroupType_view" value="1" id="approvalGroupType_view_1" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="approvalGroupType_view" value="0" id="approvalGroupType_view_0" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR valign="top" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>#approvalGroupType.Label# Access/Approve</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0><cf_toFile fname="#fName#" data="#approvalGroupType.Label# Access/Approve"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
     <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
		<cfif #frmREADONLY# EQ 'DISABLED'>
	    <span style="color:999999;"><B>VIEW</B></span>
		<cfelse>
        <a href="groupLevelAccessValues.cfm?profileId=#i#" onclick="javaScript:allowBlur();NewWindow(this.href , 'Profile_Group_Access' , 1000 , 650 , 'yes' , 'yes'); return false;" target="_blank"><B>VIEW</B></a>
         </cfif>
	 </TD>
            <!--- <cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0>
              <CFIF evaluate("") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif> --->
        </CFLOOP>
          	<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>
      <cfif appSettings.getApprovalMarginType() eq 2>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approve Beyond Annual Case Rate</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Beyond_Annual_Case_Rate" value="1" id="Approve_Beyond_Annual_Case_Rate_1" <cfif getSettingsManagerProfiles.Approve_Beyond_Annual_Case_Rate EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Beyond_Annual_Case_Rate" value="0" id="Approve_Beyond_Annual_Case_Rate_0" <cfif getSettingsManagerProfiles.Approve_Beyond_Annual_Case_Rate EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApproveBeyondAnnualCaseRate" <cfif getSettingsManagerProfiles.Approve_Beyond_Annual_Case_Rate EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Beyond Annual Case Rate</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Beyond_Annual_Case_Rate NEQ 0><cf_toFile fname="#fName#" data="Approve Beyond Annual Case Rate"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Beyond_Annual_Case_Rate" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Beyond_Annual_Case_Rate','1')"   TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Beyond_Annual_Case_Rate_#i#" class="#i#" MASSUPDATEID="Approve_Beyond_Annual_Case_Rate" <CFIF evaluate("Get_#i#_Settings.Approve_Beyond_Annual_Case_Rate") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Beyond_Annual_Case_Rate NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Approve_Beyond_Annual_Case_Rate") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </cfloop>
        	<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Beyond_Annual_Case_Rate NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approve Lumpsum</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Lumpsum" value="1" id="Approve_Lumpsum_1" <cfif getSettingsManagerProfiles.Approve_Lumpsum EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Lumpsum" value="0" id="Approve_Lumpsum_0" <cfif getSettingsManagerProfiles.Approve_Lumpsum EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApprovalLumpsum" <cfif getSettingsManagerProfiles.Approve_Lumpsum EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Lumpsum</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Lumpsum NEQ 0><cf_toFile fname="#fName#" data="Approve Lumpsum"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Lumpsum" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Lumpsum','1')"   TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Lumpsum_#i#" class="#i#" MASSUPDATEID="Approve_Lumpsum" <CFIF evaluate("Get_#i#_Settings.Approve_Lumpsum") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Lumpsum NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Approve_Lumpsum") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        		<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Lumpsum NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Base View</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Base_View" value="1" id="Base_View_1" <cfif getSettingsManagerProfiles.Base_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Base_View" value="0" id="Base_View_0" <cfif getSettingsManagerProfiles.Base_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApprovalBaseView" <cfif getSettingsManagerProfiles.Base_View EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Base View</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0><cf_toFile fname="#fName#" data="Base View"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Base_View" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Base_View','1')"   TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Base_View_#i#" class="#i#" MASSUPDATEID="Base_View" <CFIF evaluate("Get_#i#_Settings.Base_View") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Base_View") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        	<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Operating Income</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="View_Operating_Income" value="1" id="View_Operating_Income_1" <cfif getSettingsManagerProfiles.View_Operating_Income EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="View_Operating_Income" value="0" id="View_Operating_Income_0" <cfif getSettingsManagerProfiles.View_Operating_Income EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ViewOperatingIncome" <cfif getSettingsManagerProfiles.View_Operating_Income EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Operating Income</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Operating_Income NEQ 0><cf_toFile fname="#fName#" data="View Operating Income"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Operating_Income" VALUE="1"><a href="##"  OnClick="javascript:massUpdate('checkbox','View_Operating_Income','1')"  TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Operating_Income_#i#" class="#i#" MASSUPDATEID="View_Operating_Income" <CFIF evaluate("Get_#i#_Settings.View_Operating_Income") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Operating_Income NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Operating_Income") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        	<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Operating_Income NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Cost</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="View_Cost" value="1" id="View_Cost_1" <cfif getSettingsManagerProfiles.View_Cost EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		<input type="radio" name="View_Cost" value="0" id="View_Cost_0" <cfif getSettingsManagerProfiles.View_Cost EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ViewCost" <cfif getSettingsManagerProfiles.View_Cost EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Cost</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0><cf_toFile fname="#fName#" data="View Cost"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Cost" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Cost','1')"   TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Cost_#i#"  MASSUPDATEID="View_Cost" <CFIF evaluate("Get_#i#_Settings.View_Cost") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Cost") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
          	<td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approve $0 Product Costs</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Zero_Product_Cost" value="1" id="Approve_Zero_Product_Cost_1" <cfif getSettingsManagerProfiles.Approve_Zero_Product_Cost EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Zero_Product_Cost" value="0" id="Approve_Zero_Product_Cost_0" <cfif getSettingsManagerProfiles.Approve_Zero_Product_Cost EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApproveZeroCost"  <cfif getSettingsManagerProfiles.Approve_Zero_Product_Cost EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Approve $0 Product Costs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Zero_Product_Cost NEQ 0><cf_toFile fname="#fName#" data="Aprrove $0 Product Costs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Zero_Product_Cost" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Zero_Product_Cost','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Zero_Product_Cost_#i#" class="#i#" MASSUPDATEID="Approve_Zero_Product_Cost" <CFIF evaluate("Get_#i#_Settings.Approve_Zero_Product_Cost") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Zero_Product_Cost NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Approve_Zero_Product_Cost") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
                	<td width="100%">&nbsp;</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Zero_Product_Cost NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!--- Dev Note: KAL; D21003: Margin Approval - Trade as Percent of Gross Sales, $0 price  --->
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approve $0 Product Price</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Zero_Product_Price" value="1" id="Approve_Zero_Product_Price_1" <cfif getSettingsManagerProfiles.Approve_Zero_Product_Price EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Zero_Product_Price" value="0" id="Approve_Zero_Product_Price_0" <cfif getSettingsManagerProfiles.Approve_Zero_Product_Price EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApproveZeroPrice" <cfif getSettingsManagerProfiles.Approve_Zero_Product_Price EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Approve $0 Product Price</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Zero_Product_Price NEQ 0><cf_toFile fname="#fName#" data="Aprrove $0 Product Price"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Zero_Product_Price" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Zero_Product_Price','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Zero_Product_Price_#i#" class="#i#" MASSUPDATEID="Approve_Zero_Product_Price" <CFIF evaluate("Get_#i#_Settings.Approve_Zero_Product_Price") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Zero_Product_Price NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Approve_Zero_Product_Price") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
                	<td width="100%">&nbsp;</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Zero_Product_Price NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Target Margins</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="View_Target_Margins" value="1" id="View_Target_Margins_1" <cfif getSettingsManagerProfiles.View_Target_Margins EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="View_Target_Margins" value="0" id="View_Target_Margins_0" <cfif getSettingsManagerProfiles.View_Target_Margins EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ViewTargetMargins" <cfif getSettingsManagerProfiles.View_Target_Margins EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Target Margins</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Target_Margins NEQ 0><cf_toFile fname="#fName#" data="View Target Margins"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Target_Margins" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Target_Margins','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Target_Margins_#i#" class="#i#" MASSUPDATEID="View_Target_Margins" <CFIF evaluate("Get_#i#_Settings.View_Target_Margins") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Target_Margins NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Target_Margins") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
                	<td width="100%">&nbsp;</td> <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Target_Margins NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!---76537 :: Margin analysis to various targets START--->
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Additional #appSettings.getMarginColHeader26()#</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="View_Additional_Margins_Targets" value="1" id="View_Additional_Margins_Targets_1" <cfif getSettingsManagerProfiles.View_Additional_Margins_Targets EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="View_Additional_Margins_Targets" value="0" id="View_Additional_Margins_Targets_0" <cfif getSettingsManagerProfiles.View_Additional_Margins_Targets EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ViewAdditionalMarginsTargets" <cfif getSettingsManagerProfiles.View_Additional_Margins_Targets EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Additional #appSettings.getMarginColHeader26()#</TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Additional_Margins_Targets NEQ 0>
          <cf_toFile fname="#fName#" data="View Additional #appSettings.getMarginColHeader26()#">
        </cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
          <INPUT TYPE="checkbox" NAME="View_Additional_Margins_Targets" VALUE="1">
          <a href="##" OnClick="javascript:massUpdate('checkbox','View_Additional_Margins_Targets','1')" TITLE="Update all values for this row.">(+)</a>
        </TD>
        <CFLOOP query="getProfiles">
          <cfset i = getProfiles.profiles_id>
          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
            <INPUT TYPE="checkbox" NAME="View_Additional_Margins_Targets_#i#" class="#i#" MASSUPDATEID="View_Additional_Margins_Targets" <CFIF evaluate("Get_#i#_Settings.View_Additional_Margins_Targets") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
          </TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Additional_Margins_Targets NEQ 0>
            <cfif evaluate("Get_#i#_Settings.View_Additional_Margins_Targets") EQ 1>
              <cf_toFile fname="#fName#" data=",yes">
            <cfelse>
              <cf_toFile fname="#fName#" data=",no">
            </cfif>
          </cfif>
        </CFLOOP>
        <td width="100%">&nbsp;</td>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Additional_Margins_Targets NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!---76537 :: Margin analysis to various targets END--->
      <!------ Layered ----->
      <cfset sLabel = "Max #appsettings.getMarginColHeader14()#" />
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>#sLabel#</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Max_Program_Spend" value="1" id="Max_Program_Spend_1" <cfif getSettingsManagerProfiles.Max_Program_Spend EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Max_Program_Spend" value="0" id="Max_Program_Spend_0" <cfif getSettingsManagerProfiles.Max_Program_Spend EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxProgSpend" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Program_Spend EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>#sLabel#</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Program_Spend NEQ 0><cf_toFile fname="#fName#" data="#sLabel#"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Program_Spend" ID="Max_Program_Spend" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Max_Program_Spend','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Program_Spend"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Program_Spend_#i#" SIZE="5"  MASSUPDATEID="Max_Program_Spend" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Program_Spend NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Program_Spend NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
        <!------ Max Net Sales $ - Layered  ----->
      <!---
          Dev Notes: 22946/Anand Rao/28-Apr-10
          Profile setting to approve Net Sales value on margin page
      --->
      <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Max Net Sales $</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Net_Sales_Dollar" value="1" id="Max_Net_Sales_Dollar_1" <cfif getSettingsManagerProfiles.Max_Net_Sales_Dollar EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Net_Sales_Dollar" value="0" id="Max_Net_Sales_Dollar_0" <cfif getSettingsManagerProfiles.Max_Net_Sales_Dollar EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxNetSalesDollar" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Net_Sales_Dollar EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Max Net Sales $</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Net_Sales_Dollar NEQ 0><cf_toFile fname="#fName#" data="Max Net Sales $"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Net_Sales_Dollar" ID="Max_Net_Sales_Dollar" onkeyup="clenseTextBuffer(this, '*-.02134567890')" VALUE=""><a href="##" OnClick="javascript:massUpdate('textbox','Max_Net_Sales_Dollar','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Net_Sales_Dollar"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Net_Sales_Dollar_#i#"  MASSUPDATEID="Max_Net_Sales_Dollar" SIZE="5" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Net_Sales_Dollar NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Net_Sales_Dollar NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>

      <!------ Layered ----->
      <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Margin Target Variation</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Margin_Target_Variation" value="1" id="Margin_Target_Variation_1" <cfif getSettingsManagerProfiles.Margin_Target_Variation EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Margin_Target_Variation" value="0" id="Margin_Target_Variation_0" <cfif getSettingsManagerProfiles.Margin_Target_Variation EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_MarginVariation" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Margin_Target_Variation EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Margin Target Variation</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Target_Variation NEQ 0><cf_toFile fname="#fName#" data="Margin Target Variation"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Margin_Target_Variation" ID="Margin_Target_Variation" onkeyup="clenseTextBuffer(this, '*-.02134567890')" VALUE=""><a href="##" OnClick="javascript:massUpdate('textbox','Margin_Target_Variation','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Margin_Target_Variation"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Margin_Target_Variation_#i#"  MASSUPDATEID="Margin_Target_Variation" SIZE="5" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Target_Variation NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Target_Variation NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!------ Layered ----->
      <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Min Operating Margin%</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Opr_Margin" value="1" id="Max_Opr_Margin_1" <cfif getSettingsManagerProfiles.Max_Opr_Margin EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Opr_Margin" value="0" id="Max_Opr_Margin_0" <cfif getSettingsManagerProfiles.Max_Opr_Margin EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxOprMargin" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Opr_Margin EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Min Operating Margin%</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Opr_Margin NEQ 0><cf_toFile fname="#fName#" data="Min Operating Margin%"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Opr_Margin" ID="Max_Opr_Margin" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Max_Opr_Margin','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Opr_Margin"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Opr_Margin_#i#"  MASSUPDATEID="Max_Opr_Margin" SIZE="5" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Opr_Margin NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Opr_Margin NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!------ Layered ----->
      <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Max
                  Approvable Volume</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Approval_Volume" value="1" id="Max_Approval_Volume_1" <cfif getSettingsManagerProfiles.Max_Approval_Volume EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Approval_Volume" value="0" id="Max_Approval_Volume_0" <cfif getSettingsManagerProfiles.Max_Approval_Volume EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxVolApproval" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Approval_Volume EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Max Approvable Volume</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Volume NEQ 0><cf_toFile fname="#fName#" data="Max Approvable Volume"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Approval_Volume" ID="Max_Approval_Volume" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Max_Approval_Volume','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Approval_Volume"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Approval_Volume_#i#" SIZE="5"  MASSUPDATEID="Max_Approval_Volume" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        <cfif #evaluate("Get_#i#_Settings.Max_Approval_Volume_Uom")# EQ "">
          <cfset setDefaultSelected = 1>
        <cfelse>
          <cfset setDefaultSelected = 0>
        </cfif>
        <cf_uom_radio
                outputType        = "radio"
                program_id        = ""
                company_main_id     = ""
                default_option_on   = "0"
                default_option_text   = ""
                default_option_value  = "0"
                dropdown_name     = "Max_Approval_Volume_Uom_#i#"
                option_text_abbreviated = "1"
                plural_uom_display    = ""
                product_type_id     = ""
                program_template_id   = ""
                selected_uom_id     = "#evaluate("Get_#i#_Settings.Max_Approval_Volume_Uom")#"
                text_before_tag_close = ""
                uom_id_exclusion_list = "3,2"
                uom_id_inclusion_list = ""
                setDefaultSelected    =   "#setDefaultSelected#"  >

        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Volume NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Volume NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
  <!------ Layered ----->
  <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Min Approvable Volume</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Min_Approval_Volume" value="1" id="Min_Approval_Volume_1" <cfif getSettingsManagerProfiles.Min_Approval_Volume EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Min_Approval_Volume" value="0" id="Min_Approval_Volume_0" <cfif getSettingsManagerProfiles.Min_Approval_Volume EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_MinVolApproval" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Min_Approval_Volume EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Min Approvable Volume</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Min_Approval_Volume NEQ 0><cf_toFile fname="#fName#" data="Min Approvable Volume"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Min_Approval_Volume" ID="Min_Approval_Volume"  onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Min_Approval_Volume','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Min_Approval_Volume"))>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Min_Approval_Volume_#i#" SIZE="5"  MASSUPDATEID="Min_Approval_Volume" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        <cfif #evaluate("Get_#i#_Settings.Min_Approval_Volume_Uom")# EQ "">
          <cfset setDefaultSelected = 1>
        <cfelse>
          <cfset setDefaultSelected = 0>
        </cfif>
          <cf_uom_radio
                outputType        = "radio"
                program_id        = ""
                company_main_id     = ""
                default_option_on   = "0"
                default_option_text   = ""
                default_option_value  = "0"
                dropdown_name     = "Min_Approval_Volume_Uom_#i#"
                option_text_abbreviated = "1"
                plural_uom_display    = ""
                product_type_id     = ""
                program_template_id   = ""
                selected_uom_id     = "#evaluate("Get_#i#_Settings.Min_Approval_Volume_Uom")#"
                text_before_tag_close = ""
                uom_id_exclusion_list = "3,2"
                uom_id_inclusion_list = ""
                setDefaultSelected    =   "#setDefaultSelected#"
              >
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Min_Approval_Volume NEQ 0>
              <cf_toFile fname="#fName#" data=",#iValue#">
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Min_Approval_Volume NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
 <!--- 72497 Program Approval - Annual Volume and % of List Price...  START--->
  <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Max Approvable Annual Volume</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Approval_Annual_Volume" value="1" id="Max_Approval_Annual_Volume_1" <cfif getSettingsManagerProfiles.Max_Approval_Annual_Volume EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Approval_Annual_Volume" value="0" id="Max_Approval_Annual_Volume_0" <cfif getSettingsManagerProfiles.Max_Approval_Annual_Volume EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxAnnVolApproval" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Approval_Annual_Volume EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Max Approvable Annual Volume</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Annual_Volume NEQ 0><cf_toFile fname="#fName#" data="Max Approvable Annual Volume"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Approval_Annual_Volume" ID="Max_Approval_Annual_Volume"  onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Max_Approval_Annual_Volume','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Approval_Annual_Volume"))>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Approval_Annual_Volume_#i#" SIZE="5"  MASSUPDATEID="Max_Approval_Annual_Volume" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>

        <cfif #evaluate("Get_#i#_Settings.Max_Approval_Annual_Volume_Uom")# EQ "">
          <cfset setDefaultSelected = 1>
        <cfelse>
          <cfset setDefaultSelected = 0>
        </cfif>
          <cf_uom_radio
                outputType        = "radio"
                program_id        = ""
                company_main_id     = ""
                default_option_on   = "0"
                default_option_text   = ""
                default_option_value  = "0"
                dropdown_name     = "Max_Approval_Annual_Volume_Uom_#i#"
                option_text_abbreviated = "1"
                plural_uom_display    = ""
                product_type_id     = ""
                program_template_id   = ""
                selected_uom_id     = "#evaluate("Get_#i#_Settings.Max_Approval_Annual_Volume_Uom")#"
                text_before_tag_close = ""
                uom_id_exclusion_list = "3,2"
                uom_id_inclusion_list = ""
                setDefaultSelected    =   "#setDefaultSelected#"
              >

       </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Annual_Volume NEQ 0>
              <cf_toFile fname="#fName#" data=",#iValue#">
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Annual_Volume NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
<!--- 72497 Program Approval - Annual Volume and % of List Price...  END--->


			<!------ Layered - Margin_Display_UOM - LB ----->
      <cfif appSettings.getMarginDisplayLB() EQ 1>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Margin Display UOM - LB</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Margin_Display_UOM_LB" value="1" id="Margin_Display_UOM_LB_1" <cfif getSettingsManagerProfiles.Margin_Display_UOM_LB EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Margin_Display_UOM_LB" value="0" id="Margin_Display_UOM_LB_0" <cfif getSettingsManagerProfiles.Margin_Display_UOM_LB EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_Margin_Display_UOM" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Margin_Display_UOM_LB EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Margin Display UOM - LB</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_LB NEQ 0><cf_toFile fname="#fName#" data="Margin Display UOM - LB"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Margin_Display_UOM_LB" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Margin_Display_UOM_LB','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Margin_Display_UOM_LB"))>
        <cfset iValue = 1>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <INPUT TYPE="checkbox" NAME="Margin_Display_UOM_LB_#i#" class="#i#" MASSUPDATEID="Margin_Display_UOM_LB" <CFIF evaluate("Get_#i#_Settings.Margin_Display_UOM_LB") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_LB NEQ 0>
          <cf_toFile fname="#fName#" data=",#iValue#">
        </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_LB NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>
      <!--- Market_Price_Variance this.value = this.value.replace(/\x2a/, '');--->
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Max Market Price Variance %</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Market_Price_Variance" value="1" id="Market_Price_Variance_1" <cfif getSettingsManagerProfiles.Market_Price_Variance EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Market_Price_Variance" value="0" id="Market_Price_Variance_0" <cfif getSettingsManagerProfiles.Market_Price_Variance EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_MarketPriceVariance" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Market_Price_Variance EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Max Market Price Variance %</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Market_Price_Variance NEQ 0><cf_toFile fname="#fName#" data="Max Market Price Variance %"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Market_Price_Variance" ID="Market_Price_Variance" onkeyup="clenseTextBuffer(this, '2134567890.');" VALUE=""><a href="##" OnClick="javascript:massUpdate('textbox','Market_Price_Variance','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Market_Price_Variance"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Market_Price_Variance_#i#"  MASSUPDATEID="Market_Price_Variance" SIZE="5" VALUE="<cfif iValue EQ 99999>*<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '0213456789.');" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Market_Price_Variance NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Market_Price_Variance NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!--- End Market_Price_Variance End--->

      <!------ Layered - Margin_Display_UOM - CS ----->
      <cfif appSettings.getMarginDisplayCS() EQ 1>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Margin Display UOM - CS</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Margin_Display_UOM_CS" value="1" id="Margin_Display_UOM_CS_1" <cfif getSettingsManagerProfiles.Margin_Display_UOM_CS EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Margin_Display_UOM_CS" value="0" id="Margin_Display_UOM_CS_0" <cfif getSettingsManagerProfiles.Margin_Display_UOM_CS EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_Margin_Display_UOM" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Margin_Display_UOM_CS EQ 0> style="display:none"</cfif>>
       <TD WIDTH="195" id="locked" class="locked" nowrap>Margin Display UOM - CS</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_CS NEQ 0><cf_toFile fname="#fName#" data="Margin Display UOM - CS"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Margin_Display_UOM_CS" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Margin_Display_UOM_CS','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Margin_Display_UOM_CS"))>
        <cfset iValue = 1>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <INPUT TYPE="checkbox" NAME="Margin_Display_UOM_CS_#i#" class="#i#" MASSUPDATEID="Margin_Display_UOM_CS" <CFIF evaluate("Get_#i#_Settings.Margin_Display_UOM_CS") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_CS NEQ 0>
          <cf_toFile fname="#fName#" data=",#iValue#">
        </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_CS NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>

      <!------ Layered - Margin_Display_UOM - EQ ----->
      <cfif appSettings.getMarginDisplayEQ() EQ 1>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Margin Display UOM - EQ CS</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Margin_Display_UOM_EQ" value="1" id="Margin_Display_UOM_EQ_1" <cfif getSettingsManagerProfiles.Margin_Display_UOM_EQ EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Margin_Display_UOM_EQ" value="0" id="Margin_Display_UOM_EQ_0" <cfif getSettingsManagerProfiles.Margin_Display_UOM_EQ EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_Margin_Display_UOM" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Margin_Display_UOM_EQ EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Margin Display UOM - EQ CS</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_EQ NEQ 0><cf_toFile fname="#fName#" data="Margin Display UOM - EQ CS"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Margin_Display_UOM_EQ" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Margin_Display_UOM_EQ','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Margin_Display_UOM_EQ"))>
        <cfset iValue = 1>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <INPUT TYPE="checkbox" NAME="Margin_Display_UOM_EQ_#i#" class="#i#" MASSUPDATEID="Margin_Display_UOM_EQ" <CFIF evaluate("Get_#i#_Settings.Margin_Display_UOM_EQ") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_EQ NEQ 0>
          <cf_toFile fname="#fName#" data=",#iValue#">
        </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Margin_Display_UOM_EQ NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
	</cfif>
  <CFELSEIF ThisApprovalType EQ 6>
      <!-----layered---->
      <cfif appSettings.getRestrictAccessOnGroup()>
      <cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>#approvalGroupType.Label# Access/Approve<br>&nbsp;</TD>
        <!--- created setting_name called approvalGroupType_view in Setting_list to match the popup window in user profiles setting page--->
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="approvalGroupType_view" value="1" id="approvalGroupType_view_1" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="approvalGroupType_view" value="0" id="approvalGroupType_view_0" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR valign="top" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>#approvalGroupType.Label# Access/Approve<br>&nbsp;</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0><cf_toFile fname="#fName#" data="#approvalGroupType.Label# Access/Approve"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <a href="groupLevelAccessValues.cfm?profileId=#i#" onclick="javaScript:allowBlur();NewWindow(this.href , 'Profile_Group_Access' , 750 , 650 , 'yes' , 'yes'); return false;" target="_blank">view</a>
        </TD>
            <!--- <cfif saveToXl is "yes">
              <CFIF evaluate("") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif> --->
        </CFLOOP>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Lumpsum Approval Amount</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Lumpsum_Approval_Amount" value="1" id="Lumpsum_Approval_Amount_1" <cfif getSettingsManagerProfiles.Lumpsum_Approval_Amount EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Lumpsum_Approval_Amount" value="0" id="Lumpsum_Approval_Amount_0" <cfif getSettingsManagerProfiles.Lumpsum_Approval_Amount EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
    <TR id="tr_LumpsumApprovalAmount" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Lumpsum_Approval_Amount EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Lumpsum Approval Amount</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Lumpsum_Approval_Amount NEQ 0><cf_toFile fname="#fName#" data="Lumpsum Approval Amount"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Lumpsum_Approval_Amount" ID="Lumpsum_Approval_Amount" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Lumpsum_Approval_Amount','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="text" NAME="Lumpsum_Approval_Amount_#i#"  MASSUPDATEID="Lumpsum_Approval_Amount" SIZE="5" VALUE="#evaluate("Get_#i#_Settings.Lumpsum_Approval_Amount")#" onkeyup="clenseTextBuffer(this, '*-.02134567890')" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.Lumpsum_Approval_Amount NEQ 0>
              <cf_toFile fname="#fName#" data=",#evaluate("Get_#i#_Settings.Lumpsum_Approval_Amount")#">
          </cfif>
      </CFLOOP>
    </TR>
	</cfif>
    <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Base View</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Base_View" value="1" id="Base_View_1" <cfif getSettingsManagerProfiles.Base_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Base_View" value="0" id="Base_View_0" <cfif getSettingsManagerProfiles.Base_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
    <TR id="tr_ApprovalBaseView" <cfif getSettingsManagerProfiles.Base_View EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Base View</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0><cf_toFile fname="#fName#" data="Base View"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Base_View" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Base_View','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Base_View_#i#" class="#i#" MASSUPDATEID="Base_View" <CFIF evaluate("Get_#i#_Settings.Base_View") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Base_View") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
    <TR>
          <TD align="right"  nowrap>View Cost</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Cost" value="1" id="View_Cost_1" <cfif getSettingsManagerProfiles.View_Cost EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Cost" value="0" id="View_Cost_0" <cfif getSettingsManagerProfiles.View_Cost EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
    </TR>
    <cfelse>
    <TR id="tr_ViewCost" <cfif getSettingsManagerProfiles.View_Cost EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Cost</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0><cf_toFile fname="#fName#" data="View Cost"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Cost" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Cost','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Cost_#i#"  MASSUPDATEID="View_Cost" <CFIF evaluate("Get_#i#_Settings.View_Cost") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Cost") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
	</cfif>
      <CFELSEIF ThisApprovalType EQ 7>
      <!-----layered---->
      <cfif appSettings.getRestrictAccessOnGroup()>
      <cfset approvalGroupType = CreateObject("component", "components.settings.ApprovalGroupManager").getGroupTypeInfo() />
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>#approvalGroupType.Label# Access/Approve<br>&nbsp;</TD>
        <!--- created setting_name called approvalGroupType_view in Setting_list to match the popup window in user profiles setting page--->
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="approvalGroupType_view" value="1" id="approvalGroupType_view_1" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="approvalGroupType_view" value="0" id="approvalGroupType_view_0" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR valign="top" <cfif getSettingsManagerProfiles.approvalGroupType_view EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>#approvalGroupType.Label# Access/Approve<br>&nbsp;</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0><cf_toFile fname="#fName#" data="#approvalGroupType.Label# Access/Approve"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <a href="groupLevelAccessValues.cfm?profileId=#i#" onclick="javaScript:allowBlur();NewWindow(this.href , 'Profile_Group_Access' , 750 , 650 , 'yes' , 'yes');return false;" target="_blank">view</a>
        </TD>
            <!--- <cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0>
              <CFIF evaluate("") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif> --->
        </CFLOOP>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.approvalGroupType_view NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
          <TD align="right"  nowrap>Approve Lumpsum</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Lumpsum" value="1" id="Approve_Lumpsum_1" <cfif getSettingsManagerProfiles.Approve_Lumpsum EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Lumpsum" value="0" id="Approve_Lumpsum_0" <cfif getSettingsManagerProfiles.Approve_Lumpsum EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApprovalLumpsum" <cfif getSettingsManagerProfiles.Approve_Lumpsum EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Lumpsum</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Lumpsum NEQ 0><cf_toFile fname="#fName#" data="Approve Lumpsum"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Lumpsum" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Lumpsum','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Lumpsum_#i#" class="#i#" MASSUPDATEID="Approve_Lumpsum"  <CFIF evaluate("Get_#i#_Settings.Approve_Lumpsum") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Lumpsum NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Approve_Lumpsum") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Lumpsum NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Base View</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Base_View" value="1" id="Base_View_1" <cfif getSettingsManagerProfiles.Base_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Base_View" value="0" id="Base_View_0" <cfif getSettingsManagerProfiles.Base_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApprovalBaseView" <cfif getSettingsManagerProfiles.Base_View EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Base View</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0><cf_toFile fname="#fName#" data="Base View"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Base_View" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Base_View','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Base_View_#i#"  MASSUPDATEID="Base_View" <CFIF evaluate("Get_#i#_Settings.Base_View") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.Base_View") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Base_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Trade Adjustment</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_TPA" value="1" id="View_TPA_1" <cfif getSettingsManagerProfiles.View_TPA EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_TPA" value="0" id="View_TPA_0" <cfif getSettingsManagerProfiles.View_TPA EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApprovalViewTPA" <cfif getSettingsManagerProfiles.View_TPA EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Trade Adjustment
</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_TPA NEQ 0><cf_toFile fname="#fName#" data="View Trade Adjustment"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_TPA" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_TPA','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_TPA_#i#" class="#i#" MASSUPDATEID="View_TPA" <CFIF evaluate("Get_#i#_Settings.View_TPA") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_TPA NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_TPA") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_TPA NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Net Sales</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Net_Sales" value="1" id="View_Net_Sales_1" <cfif getSettingsManagerProfiles.View_Net_Sales EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Net_Sales" value="0" id="View_Net_Sales_0" <cfif getSettingsManagerProfiles.View_Net_Sales EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
      </TR>
      <cfelse>
      <TR id="tr_ApprovalViewNetSales" <cfif getSettingsManagerProfiles.View_Net_Sales EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Net Sales
</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Net_Sales NEQ 0><cf_toFile fname="#fName#" data="View Net Sales"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Net_Sales" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Net_Sales','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Net_Sales_#i#"  MASSUPDATEID="View_Net_Sales" <CFIF evaluate("Get_#i#_Settings.View_Net_Sales") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Net_Sales NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Net_Sales") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Net_Sales NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Operating Income</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Operating_Income" value="1" id="View_Operating_Income_1" <cfif getSettingsManagerProfiles.View_Operating_Income EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Operating_Income" value="0" id="View_Operating_Income_0" <cfif getSettingsManagerProfiles.View_Operating_Income EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ViewOperatingIncome" <cfif getSettingsManagerProfiles.View_Operating_Income EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Operating Income</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Operating_Income NEQ 0><cf_toFile fname="#fName#" data="View Operating Income"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Operating_Income" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Operating_Income','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Operating_Income_#i#"  MASSUPDATEID="View_Operating_Income" <CFIF evaluate("Get_#i#_Settings.View_Operating_Income") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Operating_Income NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Operating_Income") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
      </CFLOOP>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Operating_Income NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Cost</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Cost" value="1" id="View_Cost_1" <cfif getSettingsManagerProfiles.View_Cost EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Cost" value="0" id="View_Cost_0" <cfif getSettingsManagerProfiles.View_Cost EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ViewCost" <cfif getSettingsManagerProfiles.View_Cost EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Cost</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0><cf_toFile fname="#fName#" data="View Cost"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Cost" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Cost','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Cost_#i#"  MASSUPDATEID="View_Cost" <CFIF evaluate("Get_#i#_Settings.View_Cost") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Cost") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Cost NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Target Margins</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Target_Margins" value="1" id="View_Target_Margins_1" <cfif getSettingsManagerProfiles.View_Target_Margins EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="View_Target_Margins" value="0" id="View_Target_Margins_0" <cfif getSettingsManagerProfiles.View_Target_Margins EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_ViewTargetMargins" <cfif getSettingsManagerProfiles.View_Target_Margins EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>View Target Margins</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Target_Margins NEQ 0><cf_toFile fname="#fName#" data="View Target Margins"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Target_Margins" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Target_Margins','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Target_Margins_#i#"  MASSUPDATEID="View_Target_Margins" <CFIF evaluate("Get_#i#_Settings.View_Target_Margins") EQ 1> CHECKED</CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Target_Margins NEQ 0>
              <CFIF evaluate("Get_#i#_Settings.View_Target_Margins") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
        </CFLOOP>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Target_Margins NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Max Program Spend</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Program_Spend" value="1" id="Max_Program_Spend_1" <cfif getSettingsManagerProfiles.Max_Program_Spend EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Program_Spend" value="0" id="Max_Program_Spend_0" <cfif getSettingsManagerProfiles.Max_Program_Spend EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxProgSpend" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Program_Spend EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Max Program Spend</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Program_Spend NEQ 0><cf_toFile fname="#fName#" data="Max Program Spend"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Program_Spend" ID="Max_Program_Spend" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Max_Program_Spend','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Program_Spend"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Program_Spend_#i#" SIZE="5"  MASSUPDATEID="Max_Program_Spend" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Program_Spend NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Program_Spend NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Program % Margin</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Opr_Margin" value="1" id="Max_Opr_Margin_1" <cfif getSettingsManagerProfiles.Max_Opr_Margin EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Opr_Margin" value="0" id="Max_Opr_Margin_0" <cfif getSettingsManagerProfiles.Max_Opr_Margin EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxOprMargin" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Opr_Margin EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Program % Margin</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Opr_Margin NEQ 0><cf_toFile fname="#fName#" data="Program % Margin"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Opr_Margin" ID="Max_Opr_Margin" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Max_Opr_Margin','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Opr_Margin"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Opr_Margin_#i#" SIZE="5"  MASSUPDATEID="Max_Opr_Margin" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Opr_Margin NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Opr_Margin NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!------ Layered ----->
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Max Approvable Volume</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Approval_Volume" value="1" id="Max_Approval_Volume_1" <cfif getSettingsManagerProfiles.Max_Approval_Volume EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Max_Approval_Volume" value="0" id="Max_Approval_Volume_0" <cfif getSettingsManagerProfiles.Max_Approval_Volume EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_MaxVolApproval" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Max_Approval_Volume EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Max Approvable Volume</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Volume NEQ 0><cf_toFile fname="#fName#" data="Max Approvable Volume"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="text" SIZE="5" NAME="Max_Approval_Volume" ID="Max_Approval_Volume" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##"OnClick="javascript:massUpdate('textbox','Max_Approval_Volume','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Max_Approval_Volume"))>
        <cfset checkBoxDisabled = getCheckBoxDisabled("Get_#i#_Settings.Cont_Prog_Approval_Rights", 0)>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Max_Approval_Volume_#i#" SIZE="5"  MASSUPDATEID="Max_Approval_Volume" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" #checkBoxDisabled# MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        <cfif #evaluate("Get_#i#_Settings.Max_Approval_Volume_Uom")# EQ "">
          <cfset setDefaultSelected = 1>
        <cfelse>
          <cfset setDefaultSelected = 0>
        </cfif>
          <cf_uom_radio
                program_id        = ""
                company_main_id     = ""
                default_option_on   = "0"
                default_option_text   = ""
                default_option_value  = "0"
                dropdown_name     = "Max_Approval_Volume_Uom_#i#"
                option_text_abbreviated = "1"
                plural_uom_display    = ""
                product_type_id     = ""
                program_template_id   = ""
                selected_uom_id     = "#evaluate("Get_#i#_Settings.Max_Approval_Volume_Uom")#"
                text_before_tag_close = ""
                uom_id_exclusion_list = "3,2"
                uom_id_inclusion_list = ""
                setDefaultSelected    =   "#setDefaultSelected#"
              >
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Volume NEQ 0>
              <cfif left(trim(checkBoxDisabled),8) eq "disabled">
                   <cf_toFile fname="#fName#" data=",n/a">
                   <CFelse>
                <cf_toFile fname="#fName#" data=",#iValue#">
              </cfif>
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Max_Approval_Volume NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      <!------ Layered ----->
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Min Approvable Volume</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Min_Approval_Volume" value="1" id="Min_Approval_Volume_1" <cfif getSettingsManagerProfiles.Min_Approval_Volume EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Min_Approval_Volume" value="0" id="Min_Approval_Volume_0" <cfif getSettingsManagerProfiles.Min_Approval_Volume EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR id="tr_MinVolApproval" onmouseover="javascript:allowBlur();" onmouseout="javascript:preventBlur();" <cfif getSettingsManagerProfiles.Min_Approval_Volume EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Min Approvable Volume</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Min_Approval_Volume NEQ 0><cf_toFile fname="#fName#" data="Min Approvable Volume"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><input TYPE="text" SIZE="5" NAME="Min_Approval_Volume" ID="Min_Approval_Volume" VALUE="" onkeyup="clenseTextBuffer(this, '*-.02134567890')"><a href="##" OnClick="javascript:massUpdate('textbox','Min_Approval_Volume','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <cfset iValue = Trim(evaluate("Get_#i#_Settings.Min_Approval_Volume"))>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
        <span ID="ProfileSpan_#i#">
        <input TYPE="text" NAME="Min_Approval_Volume_#i#" SIZE="5" MASSUPDATEID="Min_Approval_Volume" VALUE="<cfif iValue IS "*">#iValue#<cfelse>#numberformat(iValue, '_.___')#</cfif>" onkeyup="clenseTextBuffer(this, '*-.02134567890')" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </span>
        <cfif #evaluate("Get_#i#_Settings.Min_Approval_Volume_Uom")# EQ "">
          <cfset setDefaultSelected = 1>
        <cfelse>
          <cfset setDefaultSelected = 0>
        </cfif>
          <cf_uom_radio
                program_id        = ""
                company_main_id     = ""
                default_option_on   = "0"
                default_option_text   = ""
                default_option_value  = "0"
                dropdown_name     = "Min_Approval_Volume_Uom_#i#"
                option_text_abbreviated = "1"
                plural_uom_display    = ""
                product_type_id     = ""
                program_template_id   = ""
                selected_uom_id     = "#evaluate("Get_#i#_Settings.Min_Approval_Volume_Uom")#"
                text_before_tag_close = ""
                uom_id_exclusion_list = "3,2"
                uom_id_inclusion_list = ""
                setDefaultSelected    =   "#setDefaultSelected#"
              >
        </TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Min_Approval_Volume NEQ 0>
              <cf_toFile fname="#fName#" data=",#iValue#">
            </cfif>
        </CFLOOP>
        <td width="">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Min_Approval_Volume NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
      </CFIF>
    <!--- </TD>
    </TR> --->
    </CFLOOP>



<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////// New Approval Options Code ////////////////////////////////////////////////////--->
<!---/////////////////////////////////////////////////////////////////////////////////////////////////////////////////--->

    <!---*****************************************************************************************************************************
    ************************** Tim Ford: Label 16888 - Display Lump Sum Approval amounts if the approval scheme **********************
    ************************** is layered and Lump Sum Approval by Component is on under the approval settings  **********************
    *******************************************************************************************************************************--->
    <cfif appSettings.getApproveLSComponentByProfile() and ThisApprovalType neq 4>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>#Application.LumpsumLabel# Component Approval</TD>
        <!--- --created Lumpsum_Profile_View_Disabled_Enabled called approvalGroupType_view in Setting_list to match the popup window in user profiles setting page --->
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Lumpsum_Profile_View_Disabled_Enabled" value="1" id="Lumpsum_Profile_View_Disabled_Enabled_1" <cfif getSettingsManagerProfiles.Lumpsum_Profile_View_Disabled_Enabled EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Lumpsum_Profile_View_Disabled_Enabled" value="0" id="Lumpsum_Profile_View_Disabled_Enabled_0" <cfif getSettingsManagerProfiles.Lumpsum_Profile_View_Disabled_Enabled EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
    <TR><TD style="background-color: whitesmoke;border-right: 1px solid silver;position: relative;border-top:0px;border-bottom: 0px" nowrap>&nbsp;</TD>
        <TD style="border-top:0px;border-bottom: 0px">&nbsp;</TD>
    </TR>
    <TR <cfif getSettingsManagerProfiles.Lumpsum_Profile_View_Disabled_Enabled EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>#Application.LumpsumLabel# Component Approval</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Lumpsum_Profile_View_Disabled_Enabled NEQ 0><cf_toFile fname="#fName#" data="#Application.LumpsumLabel# Component Approval"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >&nbsp;</TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <cfset Approval_Rights = val(Evaluate("Get_#i#_Settings.Cont_Prog_Approval_Rights"))>

        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#">

        	<cfif #frmREADONLY# EQ 'DISABLED'>
        		<span style="color:999999;"><B>VIEW</B></span>
        	<cfelse>
	    <span ID="Lumpsum_Profile_View_Disabled_#i#" style="color:999999;<cfif Approval_Rights EQ 1>display:none</cfif>"><B>VIEW</B></span>
        <span ID="Lumpsum_Profile_View_Enabled_#i#" value="#i#" style="<cfif Approval_Rights EQ 0>display:none</cfif>"><a href="lumpsumAccessValues.cfm?profileId=#i#" onclick="javaScript: allowBlur(); NewWindow(this.href , 'Profile_Lumpsum_Template_Access' , 750 , 650 , 'yes' , 'yes'); return false;" target="_blank"><B>VIEW</B></a></span>
            </cfif>
	     </span>
        </TD>
      </CFLOOP>
      <td width="100%">&nbsp;</td><cfif saveToXl is "yes" and getSettingsManagerProfiles.Lumpsum_Profile_View_Disabled_Enabled NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    </cfif>
    <!---*****************************************************************************************************************************
    ************************************************* END Lump Sum Approval amounts **************************************************
    *******************************************************************************************************************************--->
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Read
              Only Catalog Access</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Read_Only_Catalog_Access" value="1" id="Read_Only_Catalog_Access_1" <cfif getSettingsManagerProfiles.Read_Only_Catalog_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Read_Only_Catalog_Access" value="0" id="Read_Only_Catalog_Access_0" <cfif getSettingsManagerProfiles.Read_Only_Catalog_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Read_Only_Catalog_Access EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Read Only Catalog Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Read_Only_Catalog_Access NEQ 0><cf_toFile fname="#fName#" data="Read Only Catalog Access"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Read_Only_Catalog_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Read_Only_Catalog_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Read_Only_Catalog_Access_#i#"  MASSUPDATEID="Read_Only_Catalog_Access" <CFIF evaluate("Get_#i#_Settings.Read_Only_Catalog_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Read_Only_Catalog_Access NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Read_Only_Catalog_Access") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Read_Only_Catalog_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>See Only Awarded in Catalog</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="See_Awarded_In_Catalog" value="1" id="See_Awarded_In_Catalog_1" <cfif getSettingsManagerProfiles.See_Awarded_In_Catalog EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="See_Awarded_In_Catalog" value="0" id="See_Awarded_In_Catalog_0" <cfif getSettingsManagerProfiles.See_Awarded_In_Catalog EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.See_Awarded_In_Catalog EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>See Only Awarded in Catalog</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.See_Awarded_In_Catalog NEQ 0><cf_toFile fname="#fName#" data="See Only Awarded in Catalog"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="See_Awarded_In_Catalog" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','See_Awarded_In_Catalog','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="See_Awarded_In_Catalog_#i#"  MASSUPDATEID="See_Awarded_In_Catalog" <CFIF evaluate("Get_#i#_Settings.See_Awarded_In_Catalog") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.See_Awarded_In_Catalog NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.See_Awarded_In_Catalog") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.See_Awarded_In_Catalog NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>

    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Approve Duplicate Programs</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Approve_Duplicate_Programs" value="1" id="Approve_Duplicate_Programs_1" <cfif getSettingsManagerProfiles.Approve_Duplicate_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Approve_Duplicate_Programs" value="0" id="Approve_Duplicate_Programs_0" <cfif getSettingsManagerProfiles.Approve_Duplicate_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Duplicate_Programs EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Duplicate Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Duplicate_Programs NEQ 0><cf_toFile fname="#fName#" data="Approve Duplicate Programs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Duplicate_Programs" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Duplicate_Programs','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Duplicate_Programs_#i#"  MASSUPDATEID="Approve_Duplicate_Programs" <CFIF evaluate("Get_#i#_Settings.Approve_Duplicate_Programs") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Duplicate_Programs NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Approve_Duplicate_Programs") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Duplicate_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>

	<!--- Tim Ford - 01/08/2015: WR 47065 - Change Order - Program Approvals --->
	<cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Manually Select Approvers</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Manually_Select_Approvers" value="1" id="Manually_Select_Approvers_1" <cfif getSettingsManagerProfiles.Manually_Select_Approvers EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Manually_Select_Approvers" value="0" id="Manually_Select_Approvers_0" <cfif getSettingsManagerProfiles.Manually_Select_Approvers EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Manually_Select_Approvers EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Manually Select Approvers</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Manually_Select_Approvers NEQ 0><cf_toFile fname="#fName#" data="Manually Select Approvers"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Manually_Select_Approvers" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Manually_Select_Approvers','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Manually_Select_Approvers_#i#"  MASSUPDATEID="Manually_Select_Approvers" <CFIF evaluate("Get_#i#_Settings.Manually_Select_Approvers") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Manually_Select_Approvers NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Manually_Select_Approvers") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Manually_Select_Approvers NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>

    <cfif appSettings.getSysco_report_on() IS 1>
    <cfif fromSettings_management eq 1>
    <TR>
        <TD align="right"  nowrap>Approve Sysco Deals</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Sysco_Deals" value="1" id="Approve_Sysco_Deals_1" <cfif getSettingsManagerProfiles.Approve_Sysco_Deals EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Sysco_Deals" value="0" id="Approve_Sysco_Deals_0" <cfif getSettingsManagerProfiles.Approve_Sysco_Deals EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Sysco_Deals EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Approve Sysco Deals</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Sysco_Deals NEQ 0><cf_toFile fname="#fName#" data="Approve Sysco Deals"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Sysco_Deals" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Sysco_Deals','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Sysco_Deals_#i#"  MASSUPDATEID="Approve_Sysco_Deals" <CFIF evaluate("Get_#i#_Settings.Approve_Sysco_Deals") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Sysco_Deals NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Approve_Sysco_Deals") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </cfloop>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Sysco_Deals NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    </cfif>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Reassign Programs</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Reassign_Program_Access" value="1" id="Reassign_Program_Access_1" <cfif getSettingsManagerProfiles.Reassign_Program_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Reassign_Program_Access" value="0" id="Reassign_Program_Access_0" <cfif getSettingsManagerProfiles.Reassign_Program_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Reassign_Program_Access EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Reassign Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reassign_Program_Access NEQ 0><cf_toFile fname="#fName#" data="Reassign Programs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Reassign_Program_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Reassign_Program_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Reassign_Program_Access_#i#"  MASSUPDATEID="Reassign_Program_Access" <CFIF evaluate("Get_#i#_Settings.Reassign_Program_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reassign_Program_Access NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Reassign_Program_Access") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reassign_Program_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    <!--- Removed with label 19969
    <TR>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Reimbursement/Spend Update</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Reimbursement/Spend Update"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Reimbursement_Update" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Reimbursement_Update','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Reimbursement_Update_#i#"  MASSUPDATEID="Reimbursement_Update" <CFIF evaluate("Get_#i#_Settings.Reimbursement_Update") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes">
          <CFIF evaluate("Get_#i#_Settings.Reimbursement_Update") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    --->
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Restrict Program Access to Created by</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Program_Scorecard_Restrict_Created_By" value="1" id="Program_Scorecard_Restrict_Created_By_1" <cfif getSettingsManagerProfiles.Program_Scorecard_Restrict_Created_By EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Program_Scorecard_Restrict_Created_By" value="0" id="Program_Scorecard_Restrict_Created_By_0" <cfif getSettingsManagerProfiles.Program_Scorecard_Restrict_Created_By EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Program_Scorecard_Restrict_Created_By EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Restrict Program Access to Created by</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Program_Scorecard_Restrict_Created_By NEQ 0><cf_toFile fname="#fName#" data="Restrict Program Access to Created by"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Program_Scorecard_Restrict_Created_By" VALUE="1"><a href="##" TITLE="Update all values for this row."  OnClick="javascript:massUpdate('checkbox','Program_Scorecard_Restrict_Created_By','1')" >(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Program_Scorecard_Restrict_Created_By_#i#"  MASSUPDATEID="Program_Scorecard_Restrict_Created_By" <CFIF evaluate("Get_#i#_Settings.Program_Scorecard_Restrict_Created_By") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Program_Scorecard_Restrict_Created_By NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Program_Scorecard_Restrict_Created_By") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Program_Scorecard_Restrict_Created_By NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    <cfif appSettings.getRFAAgree()>
    <!--- Removed with label 19969
    <TR>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Executive Agreement</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="Executive Agreement"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Executive_Agreement" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Executive_Agreement','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Executive_Agreement_#i#"  MASSUPDATEID="Executive_Agreement" <CFIF evaluate("Get_#i#_Settings.Executive_Agreement") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes">
          <CFIF evaluate("Get_#i#_Settings.Executive_Agreement") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    --->
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>RFA scorecard - Agreed / Display all </TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="RFA_Agreed" value="1" id="RFA_Agreed_1" <cfif getSettingsManagerProfiles.RFA_Agreed EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="RFA_Agreed" value="0" id="RFA_Agreed_0" <cfif getSettingsManagerProfiles.RFA_Agreed EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.RFA_Agreed EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>RFA scorecard - Agreed</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.RFA_Agreed NEQ 0><cf_toFile fname="#fName#" data="RFA scorecard - Agreed"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="RFA_Agreed_A" NAME="RFA_Agreed" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','RFA_Agreed_A','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="RFA_Agreed_#i#"  MASSUPDATEID="RFA_Agreed_A" VALUE="1"<CFIF evaluate("Get_#i#_Settings.RFA_Agreed") EQ 1> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.RFA_Agreed NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.RFA_Agreed") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.RFA_Agreed NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    <!--- Removed with label 19969
    <TR>
      <TD WIDTH="195" id="locked" class="locked" nowrap>RFA scorecard - Executive agreed</TD>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data="RFA scorecard - Executive agreed"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="RFA_Agreed_EA" NAME="RFA_Agreed" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','RFA_Agreed_EA','2')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="RFA_Agreed_#i#" VALUE="2"  MASSUPDATEID="RFA_Agreed_EA" <CFIF evaluate("Get_#i#_Settings.RFA_Agreed") EQ 2> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes">
          <CFIF evaluate("Get_#i#_Settings.RFA_Agreed") EQ 2>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    --->
    <TR <cfif getSettingsManagerProfiles.RFA_Agreed EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>RFA scorecard - Display all</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.RFA_Agreed NEQ 0><cf_toFile fname="#fName#" data="RFA scorecard - Display all"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="RFA_Agreed_DA" NAME="RFA_Agreed" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','RFA_Agreed_DA','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="radio" NAME="RFA_Agreed_#i#" VALUE="0"  MASSUPDATEID="RFA_Agreed_DA" <CFIF evaluate("Get_#i#_Settings.RFA_Agreed") EQ 0> CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.RFA_Agreed NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.RFA_Agreed") EQ 0>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.RFA_Agreed NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    </cfif>
    <cfif appSettings.getrolloverprograms_on()>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approve Roll Over Programs</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Roll_Over_Programs" value="1" id="Approve_Roll_Over_Programs_1" <cfif getSettingsManagerProfiles.Approve_Roll_Over_Programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Approve_Roll_Over_Programs" value="0" id="Approve_Roll_Over_Programs_0" <cfif getSettingsManagerProfiles.Approve_Roll_Over_Programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Approve_Roll_Over_Programs EQ 0> style="display:none"</cfif>>
      	<TD WIDTH="195" id="locked" class="locked" nowrap>Approve Roll Over Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Roll_Over_Programs NEQ 0><cf_toFile fname="#fName#" data="Approve Roll Over Programs"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Roll_Over_Programs" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Roll_Over_Programs','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Roll_Over_Programs_#i#"  MASSUPDATEID="Approve_Roll_Over_Programs" <CFIF evaluate("Get_#i#_Settings.Approve_Roll_Over_Programs") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Roll_Over_Programs NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Approve_Roll_Over_Programs") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Roll_Over_Programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    </CFIF>
    <cfif fromSettings_management eq 1>
    <TR>
      <TD align="right"  nowrap>Display broker list</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="View_Broker_List" value="1" id="View_Broker_List_1" <cfif getSettingsManagerProfiles.View_Broker_List EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="View_Broker_List" value="0" id="View_Broker_List_0" <cfif getSettingsManagerProfiles.View_Broker_List EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.View_Broker_List EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Display broker list</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Broker_List NEQ 0><cf_toFile fname="#fName#" data="Display broker list"></cfif>
        <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="View_Broker_List" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Broker_List','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Broker_List_#i#"  MASSUPDATEID="View_Broker_List" <CFIF evaluate("Get_#i#_Settings.View_Broker_List") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Broker_List NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.View_Broker_List") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Broker_List NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    <cfif TableExists.Recordcount GT 0>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Approval is based on</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="program_margin_approval_method" value="1" id="program_margin_approval_method_1" <cfif getSettingsManagerProfiles.program_margin_approval_method EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="program_margin_approval_method" value="0" id="program_margin_approval_method_0" <cfif getSettingsManagerProfiles.program_margin_approval_method EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.program_margin_approval_method EQ 0> style="display:none"</cfif>>
    <TD width="195" id="locked" class="locked" nowrap>Approval is based on</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.program_margin_approval_method NEQ 0><cf_toFile fname="#fName#" data="Approval is based on"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
      <CFLOOP INDEX="ThisApprovalType" list="#AvailableApprovalOptions#">
      <cfset shortDesc = genSettingsManager.getApprovalTypeShortDesc(ThisApprovalType)>
      <cfset longDesc = genSettingsManager.getApprovalTypeLongDesc(ThisApprovalType)>
      <INPUT title="#longDesc#" TYPE="radio" ID="program_margin_approval_method_#ThisApprovalType#" NAME="program_margin_approval_method" VALUE="#ThisApprovalType#"><b>#shortDesc#</b><a href="##" OnClick="javascript:massUpdate('radio','program_margin_approval_method_#ThisApprovalType#','1')" TITLE="Update all values for this row.">(+)</a><br>
      </cfloop>
      </TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap >
        <!--- write the column break (comma) outside of the loop --->
        <cfif saveToXl is "yes"><cf_toFile fname="#fName#" data=","></cfif>
        <CFLOOP INDEX="ThisApprovalType" list="#AvailableApprovalOptions#">
          <cfset shortDesc = genSettingsManager.getApprovalTypeShortDesc(ThisApprovalType)>
          <cfset longDesc = genSettingsManager.getApprovalTypeLongDesc(ThisApprovalType)>
                  <input title="#longDesc#" type="Radio" value="#ThisApprovalType#" name="program_margin_approval_method_#i#"  MASSUPDATEID="program_margin_approval_method_#ThisApprovalType#" <cfif evaluate("Get_#i#_Settings.program_margin_approval_method") EQ ThisApprovalType> CHECKED</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
                  <b>#shortDesc#</b><br/>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles.program_margin_approval_method NEQ 0>
            <cfif evaluate("Get_#i#_Settings.program_margin_approval_method") EQ ThisApprovalType><cf_toFile fname="#fName#" data="#longDesc#"></cfif>
          </cfif>
        </cfloop>
      </TD>
    </cfloop>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.program_margin_approval_method NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    </cfif>

    <CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1>
    <cfif fromSettings_management eq 1>
    <TR>
        <TD align="right"  nowrap>Fund Setting Access</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Fund_Setting_Access" value="1" id="Fund_Setting_Access_1" <cfif getSettingsManagerProfiles.Fund_Setting_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Fund_Setting_Access" value="0" id="Fund_Setting_Access_0" <cfif getSettingsManagerProfiles.Fund_Setting_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Fund_Setting_Access EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Fund Setting Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Fund_Setting_Access NEQ 0><cf_toFile fname="#fName#" data="Fund Setting Access"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Fund_Setting_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Fund_Setting_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Fund_Setting_Access_#i#"  MASSUPDATEID="Fund_Setting_Access" <CFIF evaluate("Get_#i#_Settings.Fund_Setting_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Fund_Setting_Access NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Fund_Setting_Access") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Fund_Setting_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
    </CFIF>

    <!---Payment Processor--->
    <cfif application.returned_customer_setting.Accounting_Specialist eq 1>
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Payment Processor</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Payment_Processor" value="1" id="Payment_Processor_1" <cfif getSettingsManagerProfiles.Payment_Processor EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Payment_Processor" value="0" id="Payment_Processor_0" <cfif getSettingsManagerProfiles.Payment_Processor EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
      <TR <cfif getSettingsManagerProfiles.Payment_Processor EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Payment Processor</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Payment_Processor NEQ 0><cf_toFile fname="#fName#" data="Payment Processor"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Payment_Processor" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Payment_Processor','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">

          <cfset i = getProfiles.profiles_id>

          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
            <span ID="ProfileSpan_#i#">
              <input TYPE="checkbox" NAME="Payment_Processor_#i#" PROFILESPAN="document.all.ProfileSpan_#i#"  MASSUPDATEID="Payment_Processor" value="1" <CFIF evaluate("Get_#i#_Settings.Payment_Processor") EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
            </span>
          </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Payment_Processor NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Payment_Processor") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>

        </CFLOOP>

        <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Payment_Processor NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>

      </TR>
    </cfif>
    </cfif>
        <!--- Business Considerations --->
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Business Considerations</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Internal_Notes" value="1" id="Internal_Notes_1" <cfif getSettingsManagerProfiles.Internal_Notes EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
              <input type="radio" name="Internal_Notes" value="0" id="Internal_Notes_0" <cfif getSettingsManagerProfiles.Internal_Notes EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
      <TR <cfif getSettingsManagerProfiles.Internal_Notes EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Business Considerations</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Internal_Notes NEQ 0><cf_toFile fname="#fName#" data="Business Considerations"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Internal_Notes" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Internal_Notes','1')"  TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">

          <cfset i = getProfiles.profiles_id>

          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
            <span ID="ProfileSpan_#i#">
              <input TYPE="checkbox" NAME="Internal_Notes_#i#" PROFILESPAN="document.all.ProfileSpan_#i#"  MASSUPDATEID="Internal_Notes" value="1" <CFIF evaluate("Get_#i#_Settings.Internal_Notes") EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
            </span>
          </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Internal_Notes NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Internal_Notes") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>

        </CFLOOP>

        <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Internal_Notes NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>


             <cfif appSettings.getpaymenthistoryon()>
        <!---Alert user about payment history--->
      <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Payment history alert on approval</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Payment_History_Alert" value="1" id="Payment_History_Alert_1" <cfif getSettingsManagerProfiles.Payment_History_Alert EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Payment_History_Alert" value="0" id="Payment_History_Alert_0" <cfif getSettingsManagerProfiles.Payment_History_Alert EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR <cfif getSettingsManagerProfiles.Payment_History_Alert EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Payment history alert on approval</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Payment_History_Alert NEQ 0><cf_toFile fname="#fName#" data="Payment history alert on approval"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Payment_History_Alert" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Payment_History_Alert','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">

          <cfset i = getProfiles.profiles_id>

          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
            <span ID="ProfileSpan_#i#">
              <input TYPE="checkbox" NAME="Payment_History_Alert_#i#" PROFILESPAN="document.all.ProfileSpan_#i#"  MASSUPDATEID="Payment_History_Alert" value="1" <CFIF evaluate("Get_#i#_Settings.Payment_History_Alert") EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
            </span>
          </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Payment_History_Alert NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Payment_History_Alert") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>

        </CFLOOP>

        <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Payment_History_Alert NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
           </cfif>


  <!--- 27514: Generate Program Letters --->
<cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Generate Program Letters</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Generate_Program_letters" value="1" id="Generate_Program_letters_1" <cfif getSettingsManagerProfiles.Generate_Program_letters EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        <input type="radio" name="Generate_Program_letters" value="0" id="Generate_Program_letters_0" <cfif getSettingsManagerProfiles.Generate_Program_letters EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Generate_Program_letters EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Generate Program letters</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Generate_Program_letters NEQ 0><cf_toFile fname="#fName#" data="Generate Program letters"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Generate_Program_letters" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Generate_Program_letters','1')"   TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles">
    <cfset i = getProfiles.profiles_id>
    <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="Generate_Program_letters_#i#" class="#i#" MASSUPDATEID="Generate_Program_letters" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.Generate_Program_letters") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Generate_Program_letters NEQ 0>
        <cfif evaluate("Get_#i#_Settings.Generate_Program_letters") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Generate_Program_letters NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>

     <cfif appSettings.getlettersavailable()>
     <!--- Whether a user can delete pages from letter --->
	 <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Delete Pages in Program Letter</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Delete_Pages_Program_Letter" value="1" id="Delete_Pages_Program_Letter_1" <cfif getSettingsManagerProfiles.Delete_Pages_Program_Letter EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="Delete_Pages_Program_Letter" value="0" id="Delete_Pages_Program_Letter_0" <cfif getSettingsManagerProfiles.Delete_Pages_Program_Letter EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
      <TR <cfif getSettingsManagerProfiles.Delete_Pages_Program_Letter EQ 0> style="display:none"</cfif>>
        <TD WIDTH="195" id="locked" class="locked" nowrap>Delete Pages in Program Letter</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Delete_Pages_Program_Letter NEQ 0><cf_toFile fname="#fName#" data="Delete Pages Program Letter"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Delete_Pages_Program_Letter" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Delete_Pages_Program_Letter','1')" TITLE="Update all values for this row.">(+)</a></TD>
        <cfloop query="getProfiles">

          <cfset i = getProfiles.profiles_id>

          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
            <span ID="ProfileSpan_#i#">
              <input TYPE="checkbox" NAME="Delete_Pages_Program_Letter_#i#" PROFILESPAN="document.all.ProfileSpan_#i#"  MASSUPDATEID="Delete_Pages_Program_Letter" value="1" <CFIF evaluate("Get_#i#_Settings.Delete_Pages_Program_Letter") EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
            </span>
          </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.Delete_Pages_Program_Letter NEQ 0>
          <CFIF evaluate("Get_#i#_Settings.Delete_Pages_Program_Letter") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>

        </CFLOOP>

        <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Delete_Pages_Program_Letter NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
      </TR>
      </cfif>
           </cfif>
    <!------ Post Approval Status ----->
    <cfif appSettings.getPgmPostApprovalStatus() EQ 1>
    <cfset ProgramPostApprovalStatusManager = CreateObject("component", "components.programs.ProgramPostApprovalStatusManager").init() />
    <cfset qGetProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getProgramPostApprovalStatus() />
    <cfloop query="qGetProgramPostApprovalStatus">
        <cfset Current_Program_Post_Approval_Status_ID = Program_Post_Approval_Status_ID />
        <cfset qGetThisProfileProgramPostApprovalStatus = ProgramPostApprovalStatusManager.getProfileProgramPostApprovalStatus(Current_Program_Post_Approval_Status_ID) />

        <cfif fromSettings_management eq 1>
        <TR>
            <TD align="right"  nowrap>Allow Change Status #Program_Post_Approval_Status_Desc#</TD>
            <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="ProfileProgramPostApprovalStatus_#Program_Post_Approval_Status_ID#" value="1" id="ProfileProgramPostApprovalStatus_#Program_Post_Approval_Status_ID#_1" <cfif Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="ProfileProgramPostApprovalStatus_#Program_Post_Approval_Status_ID#" value="0" id="ProfileProgramPostApprovalStatus_#Program_Post_Approval_Status_ID#_0" <cfif Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            </TD>
        </TR>
        <cfelse>
            <TR <cfif qGetProgramPostApprovalStatus.Setting_Display_Value EQ 0> style="display:none"</cfif>>
                <TD WIDTH="225" id="locked" class="locked" nowrap> Allow Change Status #Program_Post_Approval_Status_Desc# </TD>
                <cfif saveToXl is "yes" and qGetProgramPostApprovalStatus.Setting_Display_Value NEQ 0>
                    <cf_toFile fname="#fName#" data="Allow Change Status #Program_Post_Approval_Status_Desc#">
                </cfif>
                <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
                    <INPUT TYPE="checkbox" NAME="ProfileProgramPostApprovalStatus_#Current_Program_Post_Approval_Status_ID#" VALUE="1">
                    <a href="##" OnClick="javascript:massUpdate('checkbox','ProfileProgramPostApprovalStatus_#Current_Program_Post_Approval_Status_ID#','1')" TITLE="Update all values for this row.">(+)</a>
                </TD>
                <cfloop query="getProfiles">
                    <cfset i = getProfiles.profiles_id>
                    <cfloop query="qGetThisProfileProgramPostApprovalStatus">
                        <cfif  i  eq qGetThisProfileProgramPostApprovalStatus.profiles_id>
                            <cfset currentChecked=0 />
                            <cfif qGetThisProfileProgramPostApprovalStatus.Profile_Selected_ID neq "">
                                <cfset currentChecked=1 />
                            </cfif>
                            <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
                                <span ID="ProfileSpan_#i#">
                                    <input TYPE="checkbox" NAME="ProfileProgramPostApprovalStatus_#Current_Program_Post_Approval_Status_ID#_#i#"  MASSUPDATEID="ProfileProgramPostApprovalStatus_#Current_Program_Post_Approval_Status_ID#" value="1" <cfif currentChecked>CHECKED</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
                                </span>
                            </TD>
                            <cfif saveToXl is "yes" and qGetProgramPostApprovalStatus.Setting_Display_Value neq 0>
                                <cfif currentChecked EQ 1>
                                    <cf_toFile fname="#fName#" data=",yes">
                                <cfelse>
                                    <cf_toFile fname="#fName#" data=",no">
                                </cfif>
                            </cfif>
                        </cfif>
                    </cfloop>
                </cfloop>

            <td width="100%">&nbsp;</td>
            <cfif saveToXl is "yes" and qGetProgramPostApprovalStatus.Setting_Display_Value neq 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
            </TR>
        </cfif>
    </cfloop>
    </cfif>
</cfoutput>
<cfoutput>
<cfif UseCustomerType IS 1>
<CFIF GetCustomerTypes.recordcount GT 0>

  <!--- write the header to XL --->
<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="Customer Types" nl="yes"></cfif>

<!--- <TABLE CELLPADDING="0px" cellspacing="1px" BORDER="0" width="#tablewidth#"> --->
<CFLOOP query="GetCustomerTypes">
<cfset j = GetCustomerTypes.customer_type_id>
  <cfif fromSettings_management eq 1>
  <TR>
      <TD align="right"  nowrap>#GetCustomerTypes.Customer_Type_Desc#</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Customer_Type_#j#" value="1" id="Customer_Type_#j#_1" <cfif GetCustomerTypes.Setting_Display_Value EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Customer_Type_#j#" value="0" id="Customer_Type_#j#_0" <cfif GetCustomerTypes.Setting_Display_Value EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
  </TR>
  <cfelse>
  <TR <cfif GetCustomerTypes.Setting_Display_Value EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>#GetCustomerTypes.Customer_Type_Desc#</TD>  <cfif saveToXl is "yes" and GetCustomerTypes.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" data="#GetCustomerTypes.Customer_Type_Desc#"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Customer_Type_#j#" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Customer_Type_#j#','1')" TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Customer_Type_#j#_#i#"  MASSUPDATEID="Customer_Type_#j#" <CFIF evaluate("Get_#i#_#j#_Settings.Profile_Customer_Type_Value") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
        <cfif saveToXl is "yes" and GetCustomerTypes.Setting_Display_Value NEQ 0>
          <CFIF evaluate("Get_#i#_#j#_Settings.Profile_Customer_Type_Value") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and GetCustomerTypes.Setting_Display_Value NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
  </cfif>
  </CFLOOP>
</CFIF>
</cfif>

  <cfif appSettings.getReleaseSettlement()>
    <!--- Release Settlement --->
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Release Settlement</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="ReleaseSettlement" value="1" id="ReleaseSettlement_1" <cfif getSettingsManagerProfiles.ReleaseSettlement EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="ReleaseSettlement" value="0" id="ReleaseSettlement_0" <cfif getSettingsManagerProfiles.ReleaseSettlement EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.ReleaseSettlement EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Release Settlement</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.ReleaseSettlement NEQ 0><cf_toFile fname="#fName#" data="Release Settlement"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="ReleaseSettlement" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','ReleaseSettlement','1')"  TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">

        <cfset i = getProfiles.profiles_id>

        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
          <span ID="ProfileSpan_#i#">
            <input TYPE="checkbox" NAME="ReleaseSettlement_#i#" PROFILESPAN="document.all.ProfileSpan_#i#"  MASSUPDATEID="ReleaseSettlement" value="1" <CFIF evaluate("Get_#i#_Settings.Release_Settlement") EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
          </span>
        </TD>
      <cfif saveToXl is "yes" and getSettingsManagerProfiles.ReleaseSettlement NEQ 0>
        <CFIF evaluate("Get_#i#_Settings.Release_Settlement") EQ 1>
          <cf_toFile fname="#fName#" data=",yes">
        <cfelse>
          <cf_toFile fname="#fName#" data=",no">
        </cfif>
      </cfif>

      </CFLOOP>

      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.ReleaseSettlement NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
    </cfif>
  </cfif>
</cfoutput>
<CFINCLUDE TEMPLATE="\billbacks\settings\access_rights.cfm"><!--- <br> --->

<!--- Operating Group --->
<cfif appSettings.getOperatingGroupOn()>
<CFINCLUDE TEMPLATE="\settings\operating_group\access_rights.cfm"><!--- <br> --->
</cfif>

<!---<cfif application.deductionLinksAvailable> --->
<cfif application.appSettingsGet.getDeduction_Module()>
<!----Add Deduction User Profiles--->
 <CFINCLUDE TEMPLATE="\deductions\settings\deduction_access_rights.cfm">
</cfif>

<!--- START: 57305: Retail Planner/01-Mar-2016/Anand Rao --->
<cfif appSettings.get_Setting('Retail_Planner') eq '1'>
	  <cfinclude template="planners_access_rights.cfm">
</cfif>
<!--- END:  57305: Retail Planner/01-Mar-2016/Anand Rao --->

<cfoutput>
<!--- write the header to XL --->
<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="Administrative Control Panels" nl="yes"></cfif>
<tr><td id="subheader" class="locked" align="left">Administrative Control Panel Settings</td></tr>
<cfoutput>
<cfif fromSettings_management eq 1>
    <TR>
        <TD align="right"  nowrap>What If P&amp;L</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="What_If_From_Scratch" value="1" id="What_If_From_Scratch_1" <cfif getSettingsManagerProfiles.What_If_From_Scratch EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="What_If_From_Scratch" value="0" id="What_If_From_Scratch_0" <cfif getSettingsManagerProfiles.What_If_From_Scratch EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
    </TR>
<cfelse>
    <TR <cfif getSettingsManagerProfiles.What_If_From_Scratch EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>What If P&amp;L</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.What_If_From_Scratch NEQ 0><cf_toFile fname="#fName#" data="What If P&L"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="What_If_From_Scratch" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','What_If_From_Scratch','1')"   TITLE="Update all values for this row.">(+)</a></TD>
      <cfloop query="getProfiles">
        <cfset i = getProfiles.profiles_id>
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
            <input TYPE="checkbox" NAME="What_If_From_Scratch_#i#" class="#i#" MASSUPDATEID="What_If_From_Scratch" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.What_If_From_Scratch") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
        </TD>
        <cfif saveToXl is "yes" and getSettingsManagerProfiles.What_If_From_Scratch NEQ 0>
          <cfif evaluate("Get_#i#_Settings.What_If_From_Scratch") EQ 1>
            <cf_toFile fname="#fName#" data=",yes">
          <cfelse>
            <cf_toFile fname="#fName#" data=",no">
          </cfif>
        </cfif>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.What_If_From_Scratch NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
</cfif>
</cfoutput>


  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Commodity Settings</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Commodity_Settings" value="1" id="Commodity_Settings_1" <cfif getSettingsManagerProfiles.Commodity_Settings EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Commodity_Settings" value="0" id="Commodity_Settings_0" <cfif getSettingsManagerProfiles.Commodity_Settings EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Commodity_Settings EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Commodity Settings</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Settings NEQ 0><cf_toFile fname="#fName#" data="Commodity Settings"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Commodity_Settings" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Commodity_Settings','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Commodity_Settings_#i#"  MASSUPDATEID="Commodity_Settings" <CFIF evaluate("Get_#i#_Settings.Commodity_Settings") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> onClick="javaScript:commodityCheck(this);" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Settings NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Commodity_Settings") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Settings NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Price Rule</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Commodity_Price_Rule_View" value="1" id="Commodity_Price_Rule_View_1" <cfif getSettingsManagerProfiles.Commodity_Price_Rule_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Commodity_Price_Rule_View" value="0" id="Commodity_Price_Rule_View_0" <cfif getSettingsManagerProfiles.Commodity_Price_Rule_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR  <cfif getSettingsManagerProfiles.Commodity_Price_Rule_View EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>View Price Rule</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Price_Rule_View NEQ 0><cf_toFile fname="#fName#" data="View Price Rule"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Commodity_Price_Rule_View" VALUE="1"><a href="##"  OnClick="javascript:massUpdate('checkbox','Commodity_Price_Rule_View','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Commodity_Price_Rule_View_#i#"  MASSUPDATEID="Commodity_Price_Rule_View" <CFIF evaluate("Get_#i#_Settings.Commodity_Price_Rule_View") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Price_Rule_View NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Commodity_Price_Rule_View") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Price_Rule_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Create/Edit
          Price Rule</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Commodity_Price_Rule_Create_Edit" value="1" id="Commodity_Price_Rule_Create_Edit_1" <cfif getSettingsManagerProfiles.Commodity_Price_Rule_Create_Edit EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Commodity_Price_Rule_Create_Edit" value="0" id="Commodity_Price_Rule_Create_Edit_0" <cfif getSettingsManagerProfiles.Commodity_Price_Rule_Create_Edit EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Commodity_Price_Rule_Create_Edit EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Create/Edit Price Rule</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Price_Rule_Create_Edit NEQ 0><cf_toFile fname="#fName#" data="Create/Edit Price Rule"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Commodity_Price_Rule_Create_Edit" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Commodity_Price_Rule_Create_Edit','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Commodity_Price_Rule_Create_Edit_#i#"  MASSUPDATEID="Commodity_Price_Rule_Create_Edit" <CFIF evaluate("Get_#i#_Settings.Commodity_Price_Rule_Create_Edit") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Price_Rule_Create_Edit NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Commodity_Price_Rule_Create_Edit") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Commodity_Price_Rule_Create_Edit NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
   <cfif fromSettings_management neq 1>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <INPUT TYPE="hidden" NAME="Report_Scheduler_#i#" <CFIF evaluate("Get_#i#_Settings.Report_Scheduler") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
    </CFLOOP>

   </cfif>


  <cfset RAL = CreateObject("component", "components.user.ReportsCentralAccess").init() />
  <cfset GetLevels = RAL.getRCACodeList() />
   <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap valign="top">Reports Access Level</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Reports_Access_Level" value="1" id="Reports_Access_Level_1" <cfif getSettingsManagerProfiles.Reports_Access_Level EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Reports_Access_Level" value="0" id="Reports_Access_Level_0" <cfif getSettingsManagerProfiles.Reports_Access_Level EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Reports_Access_Level EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap valign="top">Reports Access Level</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reports_Access_Level NEQ 0><cf_toFile fname="#fName#" data="Reports Access Level"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
    <cfloop query="GetLevels">
    <INPUT TYPE="radio" NAME="Reports_Access_Level" ID="Reports_Access_Level_Mass_#getlevels.level_code#" VALUE="#getlevels.level_code#"><a href="##" OnClick="javascript:massUpdate('radio','Reports_Access_Level_Mass_#getlevels.level_code#','#getlevels.level_code#')" TITLE="Update all values for this row.">(+)</a><br>
    </cfloop>
    </TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="left" WIDTH="#TD_Width#" nowrap>
          <CFLOOP QUERY="GetLevels">
            <input type="radio" name="Reports_Access_Level_#i#"  MASSUPDATEID="Reports_Access_Level_Mass_#getlevels.level_code#" VALUE="#getlevels.level_code#" <CFIF evaluate("Get_#i#_Settings.Reports_Access_Level") EQ #getlevels.level_code#>CHECKED</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>#getlevels.description#<br>
          </CFLOOP>
      </TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reports_Access_Level NEQ 0>
      <CFLOOP QUERY="GetLevels">
        <CFIF evaluate("Get_#i#_Settings.Reports_Access_Level") EQ #GetLevels.Level_Code#>
          <cf_toFile fname="#fName#" data=",#GetLevels.Description#">
        </CFIF>
      </CFLOOP>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reports_Access_Level NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap valign="top">Settings Control Panel</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Settings_Panel" value="1" id="Settings_Panel_1" <cfif getSettingsManagerProfiles.Settings_Panel EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Settings_Panel" value="0" id="Settings_Panel_0" <cfif getSettingsManagerProfiles.Settings_Panel EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
	<TR <cfif getSettingsManagerProfiles.Settings_Panel EQ 0> style="display:none"</cfif>>
		<TD WIDTH="195" id="locked" class="locked" nowrap>Settings Control Panel</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.Settings_Panel NEQ 0><cf_toFile fname="#fName#" data="Settings Control Panel"></cfif>
		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >&nbsp;</TD>
		<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
		<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
		<span ID="ProfileSpan_#i#">
			<cfif #frmREADONLY# EQ "DISABLED">
				<span style="color:999999;"><B>VIEW</B></span>
			<cfelse>
			<span value="#i#" style="color:000000;">
				<a href="profile_settings_Panel.cfm?profileId=#i#&AdminUserFromProfilesPage=1" onclick="javaScript: allowBlur(); NewWindow(this.href , 'Profile_Settings_Panel_Access' , 830 , 750 , 'yes' , 'yes'); return false;" target="_blank"><B>VIEW</B></a>
			</span>
			</cfif>
		</span>
		</TD>
    </CFLOOP>
    <td width="100%">&nbsp;</td>
  </TR>
  </cfif>

  <!---D10010 BJF Client Work Request --->
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Submit Work
          Request Tickets</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Submit_Work_Request" value="1" id="Submit_Work_Request_1" <cfif getSettingsManagerProfiles.Submit_Work_Request EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Submit_Work_Request" value="0" id="Submit_Work_Request_0" <cfif getSettingsManagerProfiles.Submit_Work_Request EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
    <TR <cfif getSettingsManagerProfiles.Submit_Work_Request EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Submit Work Request Tickets</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Submit_Work_Request NEQ 0><cf_toFile fname="#fName#" data="Submit Work Request Tickets"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Submit_Work_Request" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Submit_Work_Request','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Submit_Work_Request_#i#"  MASSUPDATEID="Submit_Work_Request" <CFIF evaluate("Get_#i#_Settings.Submit_Work_Request") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Submit_Work_Request NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Submit_Work_Request") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Submit_Work_Request NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <!---D10010 BJF Client Work Request --->
   <cfif appSettings.getShowProjectsScoreCard()>
   <cfif fromSettings_management eq 1>
  <TR>
      <TD align="right"  nowrap>Project Management Access</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="PM_Access" value="1" id="PM_Access_1" <cfif getSettingsManagerProfiles.PM_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="PM_Access" value="0" id="PM_Access_0" <cfif getSettingsManagerProfiles.PM_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
  </TR>
    <cfelse>
  <TR <cfif getSettingsManagerProfiles.PM_Access EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Project Management Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.PM_Access NEQ 0><cf_toFile fname="#fName#" data="Project Management Access"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="PM_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','PM_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="PM_Access_#i#"  MASSUPDATEID="PM_Access" <CFIF evaluate("Get_#i#_Settings.PM_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.PM_Access NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.PM_Access") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.PM_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
  <TR>
      <TD align="right"  nowrap>Project Reassign Access</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Reassign_Project_Access" value="1" id="Reassign_Project_Access_1" <cfif getSettingsManagerProfiles.Reassign_Project_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Reassign_Project_Access" value="0" id="Reassign_Project_Access_0" <cfif getSettingsManagerProfiles.Reassign_Project_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
  </TR>
    <cfelse>
  <TR <cfif getSettingsManagerProfiles.Reassign_Project_Access EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Project Reassign Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reassign_Project_Access NEQ 0><cf_toFile fname="#fName#" data="Project Reassign Access"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Reassign_Project_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Reassign_Project_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Reassign_Project_Access_#i#"  MASSUPDATEID="Reassign_Project_Access" <CFIF evaluate("Get_#i#_Settings.Reassign_Project_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reassign_Project_Access NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Reassign_Project_Access") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Reassign_Project_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  </cfif>
  <cfif fromSettings_management eq 1>
  <TR>
      <TD align="right"  nowrap>Clause Library Access</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Clause_Library_Access" value="1" id="Clause_Library_Access_1" <cfif getSettingsManagerProfiles.Clause_Library_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Clause_Library_Access" value="0" id="Clause_Library_Access_0" <cfif getSettingsManagerProfiles.Clause_Library_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Clause_Library_Access EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Clause Library Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Clause_Library_Access NEQ 0><cf_toFile fname="#fName#" data="Clause Library Access"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Clause_Library_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Clause_Library_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Clause_Library_Access_#i#" class="#i#" MASSUPDATEID="Clause_Library_Access" <CFIF evaluate("Get_#i#_Settings.Clause_Library_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Clause_Library_Access NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Clause_Library_Access") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Clause_Library_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <!--- BJF 16174 --->
  <cfif appSettings.getView_Trade_Checkbook() IS 1>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Trade Checkbook Access</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Show_Trade_Checkbook" value="1" id="Show_Trade_Checkbook_1" <cfif getSettingsManagerProfiles.Show_Trade_Checkbook EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Show_Trade_Checkbook" value="0" id="Show_Trade_Checkbook_0" <cfif getSettingsManagerProfiles.Show_Trade_Checkbook EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Show_Trade_Checkbook EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Trade Checkbook Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Show_Trade_Checkbook NEQ 0><cf_toFile fname="#fName#" data="Trade Checkbook Access"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Show_Trade_Checkbook" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Show_Trade_Checkbook','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Show_Trade_Checkbook_#i#" class="#i#" MASSUPDATEID="Show_Trade_Checkbook" <CFIF evaluate("Get_#i#_Settings.Show_Trade_Checkbook") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Show_Trade_Checkbook NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Show_Trade_Checkbook") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Show_Trade_Checkbook NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  </cfif>
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Program
          - Edit/Remove Required Clause</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Clause_Program_Edit_Remove" value="1" id="Clause_Program_Edit_Remove_1" <cfif getSettingsManagerProfiles.Clause_Program_Edit_Remove EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Clause_Program_Edit_Remove" value="0" id="Clause_Program_Edit_Remove_0" <cfif getSettingsManagerProfiles.Clause_Program_Edit_Remove EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Clause_Program_Edit_Remove EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Program - Edit/Remove Required Clause</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Clause_Program_Edit_Remove NEQ 0><cf_toFile fname="#fName#" data="Program - Edit/Remove Required Clause"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Clause_Program_Edit_Remove" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Clause_Program_Edit_Remove','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Clause_Program_Edit_Remove_#i#"  MASSUPDATEID="Clause_Program_Edit_Remove" <CFIF evaluate("Get_#i#_Settings.Clause_Program_Edit_Remove") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Clause_Program_Edit_Remove NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Clause_Program_Edit_Remove") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Clause_Program_Edit_Remove NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <CFIF application.returned_customer_setting.standard_pricelist IS 1>
  <cfif fromSettings_management eq 1>
    <TR>
    <TD align="right"  nowrap>Price List Access</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Access_Price_List" value="1" id="Access_Price_List_1" <cfif getSettingsManagerProfiles.Access_Price_List EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Access_Price_List" value="0" id="Access_Price_List_0" <cfif getSettingsManagerProfiles.Access_Price_List EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Access_Price_List EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Price List Access</TD>  <cfif saveToXl is "yes"  and getSettingsManagerProfiles.Access_Price_List NEQ 0><cf_toFile fname="#fName#" data="Price List Access"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Access_Price_List" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Access_Price_List','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT onClick="changeDisableOtherCheckBoxes(this, this.form.Special_Price_List_Access_#i#, 0);" TYPE="checkbox" NAME="Access_Price_List_#i#"  MASSUPDATEID="Access_Price_List" <CFIF evaluate("Get_#i#_Settings.Access_Price_List") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Access_Price_List NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Access_Price_List") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Access_Price_List NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>

  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>View Special Price List</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Special_Price_List_Access" value="1" id="Special_Price_List_Access_1" <cfif getSettingsManagerProfiles.Special_Price_List_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Special_Price_List_Access" value="0" id="Special_Price_List_Access_0" <cfif getSettingsManagerProfiles.Special_Price_List_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
    <cfelse>
  <TR <cfif getSettingsManagerProfiles.Special_Price_List_Access EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>View Special Price List</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Special_Price_List_Access NEQ 0><cf_toFile fname="#fName#" data="View Special Price List"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Special_Price_List_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Special_Price_List_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Special_Price_List_Access_#i#"  MASSUPDATEID="Special_Price_List_Access" <CFIF evaluate("Get_#i#_Settings.Special_Price_List_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> <CFIF evaluate("Get_#i#_Settings.Access_Price_List") NEQ 1>DISABLED</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Special_Price_List_Access NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Special_Price_List_Access") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Special_Price_List_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  </CFIF>
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Create #application.returned_customer_setting.operator_label_singular# access</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Create_Operator_Access" value="1" id="Create_Operator_Access_1" <cfif getSettingsManagerProfiles.Create_Operator_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Create_Operator_Access" value="0" id="Create_Operator_Access_0" <cfif getSettingsManagerProfiles.Create_Operator_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Create_Operator_Access EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Create #application.returned_customer_setting.operator_label_singular# access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Operator_Access NEQ 0><cf_toFile fname="#fName#" data="Create #application.returned_customer_setting.operator_label_singular# access"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Create_Operator_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Create_Operator_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Create_Operator_Access_#i#"  MASSUPDATEID="Create_Operator_Access" <CFIF evaluate("Get_#i#_Settings.Create_Operator_Access") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Operator_Access NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Create_Operator_Access") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Operator_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <!---View invoices BJF D9313--->
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Invoices</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="View_Invoices" value="1" id="View_Invoices_1" <cfif getSettingsManagerProfiles.View_Invoices EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="View_Invoices" value="0" id="View_Invoices_0" <cfif getSettingsManagerProfiles.View_Invoices EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.View_Invoices EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>View Invoices</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Invoices NEQ 0><cf_toFile fname="#fName#" data="View Invoices"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="View_Invoices" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Invoices','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Invoices_#i#"  MASSUPDATEID="View_Invoices" <CFIF evaluate("Get_#i#_Settings.View_Invoices") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Invoices NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.View_Invoices") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Invoices NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
    <!---Dev Note: Milan 8854 - Install Patch --->
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Install Patch</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Install_Patch" value="1" id="Install_Patch_1" <cfif getSettingsManagerProfiles.Install_Patch EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Install_Patch" value="0" id="Install_Patch_0" <cfif getSettingsManagerProfiles.Install_Patch EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Install_Patch EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Install Patch</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Install_Patch NEQ 0><cf_toFile fname="#fName#" data="Install Patch"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Install_Patch" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Install_Patch','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Install_Patch_#i#"  MASSUPDATEID="Install_Patch" <CFIF evaluate("Get_#i#_Settings.Install_Patch") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Install_Patch NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Install_Patch") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Install_Patch NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
    <!---Dev Note: Milan 16852 - Search Documents --->
    <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Search Documents</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Search_Documents" value="1" id="Search_Documents_1" <cfif getSettingsManagerProfiles.Search_Documents EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Search_Documents" value="0" id="Search_Documents_0" <cfif getSettingsManagerProfiles.Search_Documents EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Search_Documents EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Search Documents</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Documents NEQ 0><cf_toFile fname="#fName#" data="Search Documents"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Search_Documents" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Search_Documents','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Search_Documents_#i#"  MASSUPDATEID="Search_Documents" <CFIF evaluate("Get_#i#_Settings.Search_Documents") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Documents NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Search_Documents") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Search_Documents NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
<!---
  Dev Notes: D23320/Anand Rao/06-May-10
  User profile setting to view private documents
--->
 <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>View Private Documents</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="View_Private_Documents" value="1" id="View_Private_Documents_1" <cfif getSettingsManagerProfiles.View_Private_Documents EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="View_Private_Documents" value="0" id="View_Private_Documents_0" <cfif getSettingsManagerProfiles.View_Private_Documents EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
 <cfelse>
 <TR <cfif getSettingsManagerProfiles.View_Private_Documents EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>View Private Documents</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Private_Documents NEQ 0><cf_toFile fname="#fName#" data="View Private Documents"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="View_Private_Documents" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','View_Private_Documents','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="View_Private_Documents_#i#"  MASSUPDATEID="View_Private_Documents" <CFIF evaluate("Get_#i#_Settings.View_Private_Documents") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Private_Documents NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.View_Private_Documents") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.View_Private_Documents NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
 </cfif>

<!--- D36549 :: prof model -- new profile management consol setting --->
<cfif appSettings.getProfitabilityModel()>
		 <cfif fromSettings_management eq 1>
		      <TR>
		        <TD align="right"  nowrap>Profitability Model</TD>
		        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
		          <input type="radio" name="Profitability_Model" value="1" id="Profitability_Model_1" <cfif getSettingsManagerProfiles.Profitability_Model EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		          <input type="radio" name="Profitability_Model" value="0" id="Profitability_Model_0" <cfif getSettingsManagerProfiles.Profitability_Model EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
		        </TD>
		      </TR>
		 <cfelse>
		 <TR <cfif getSettingsManagerProfiles.Profitability_Model EQ 0> style="display:none"</cfif>>
		    <TD WIDTH="195" id="locked" class="locked" nowrap>Profitability Model </TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Profitability_Model NEQ 0><cf_toFile fname="#fName#" data="Profitability Model"></cfif>
		    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Profitability_Model" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Profitability_Model','1')" TITLE="Update all values for this row.">(+)</a></TD>
		    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
		      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Profitability_Model_#i#"  MASSUPDATEID="Profitability_Model" <CFIF evaluate("Get_#i#_Settings.Profitability_Model") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
		    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Profitability_Model NEQ 0>
		      <CFIF evaluate("Get_#i#_Settings.Profitability_Model") EQ 1>
		        <cf_toFile fname="#fName#" data=",yes">
		      <cfelse>
		        <cf_toFile fname="#fName#" data=",no">
		      </cfif>
		    </cfif>
		    </CFLOOP>
		  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Profitability_Model NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		  </TR>
		 </cfif>
</cfif>
<!---  D36549 :: prof model -- new profile management consol setting --->

<!--- Tim Ford - 10/22/2013: Label 39875 - Redistribution Module - Profile Setting --->
 <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Redistribution</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Redistribution" value="1" id="Redistribution_1" <cfif getSettingsManagerProfiles.Redistribution EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Redistribution" value="0" id="Redistribution_0" <cfif getSettingsManagerProfiles.Redistribution EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
 <cfelse>
 <TR <cfif getSettingsManagerProfiles.Redistribution EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Redistribution</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Redistribution NEQ 0><cf_toFile fname="#fName#" data="Redistribution"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Redistribution" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Redistribution','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Redistribution_#i#"  MASSUPDATEID="Redistribution" <CFIF evaluate("Get_#i#_Settings.Redistribution") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Redistribution NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Redistribution") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
  <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Redistribution NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
 </cfif>


<!--- (Start) Only if the Export Program App Setting is turned on --->
<cfif appSettings.getShowExportPrograms() >
  <!--- write the header to XL --->
<cfif saveToXl is "yes"><cf_toFile fname="#fName#" nl="Yes" data=""><cf_toFile fname="#fName#" data="Export Agreements" nl="yes"></cfif>
<tr><td id="subheader" class="locked" align="left">Export Agreements</td></tr>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Approval Rights</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Export_Agreements" value="1" id="Approve_Export_Agreements_1" <cfif getSettingsManagerProfiles.Approve_Export_Agreements EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Approve_Export_Agreements" value="0" id="Approve_Export_Agreements_0" <cfif getSettingsManagerProfiles.Approve_Export_Agreements EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
    <cfelse>
  <TR <cfif getSettingsManagerProfiles.Approve_Export_Agreements EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Approval Rights</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Export_Agreements NEQ 0><cf_toFile fname="#fName#" data="Approval Rights"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Approve_Export_Agreements" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Approve_Export_Agreements','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Approve_Export_Agreements_#i#"  MASSUPDATEID="Approve_Export_Agreements" <CFIF evaluate("Get_#i#_Settings.Approve_Export_Agreements") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Export_Agreements NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Approve_Export_Agreements") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Approve_Export_Agreements NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Creation Rights</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Create_Export_Agreements" value="1" id="Create_Export_Agreements_1" <cfif getSettingsManagerProfiles.Create_Export_Agreements EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Create_Export_Agreements" value="0" id="Create_Export_Agreements_0" <cfif getSettingsManagerProfiles.Create_Export_Agreements EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
    <cfelse>
  <TR <cfif getSettingsManagerProfiles.Create_Export_Agreements EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Creation Rights</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Export_Agreements NEQ 0><cf_toFile fname="#fName#" data="Creation Rights"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Create_Export_Agreements" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Create_Export_Agreements','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Create_Export_Agreements_#i#"  MASSUPDATEID="Create_Export_Agreements" <CFIF evaluate("Get_#i#_Settings.Create_Export_Agreements") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Export_Agreements NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Create_Export_Agreements") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Export_Agreements NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Approval & Creation Rights</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Create_Approve_Export_Agreements" value="1" id="Create_Approve_Export_Agreements_1" <cfif getSettingsManagerProfiles.Create_Approve_Export_Agreements EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Create_Approve_Export_Agreements" value="0" id="Create_Approve_Export_Agreements_0" <cfif getSettingsManagerProfiles.Create_Approve_Export_Agreements EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
    <cfelse>
  <TR <cfif getSettingsManagerProfiles.Create_Approve_Export_Agreements EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Approval & Creation Rights</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Approve_Export_Agreements NEQ 0><cf_toFile fname="#fName#" data="Approval and Creation Rights"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Create_Approve_Export_Agreements" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Create_Approve_Export_Agreements','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Create_Approve_Export_Agreements_#i#"  MASSUPDATEID="Create_Approve_Export_Agreements" <CFIF evaluate("Get_#i#_Settings.Create_Approve_Export_Agreements") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Approve_Export_Agreements NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Create_Approve_Export_Agreements") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_Approve_Export_Agreements NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Create New Customer</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Create_New_Export_Customer" value="1" id="Create_New_Export_Customer_1" <cfif getSettingsManagerProfiles.Create_New_Export_Customer EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Create_New_Export_Customer" value="0" id="Create_New_Export_Customer_0" <cfif getSettingsManagerProfiles.Create_New_Export_Customer EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
    <cfelse>
  <TR <cfif getSettingsManagerProfiles.Create_New_Export_Customer EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Create New Customer</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_New_Export_Customer NEQ 0><cf_toFile fname="#fName#" data="Create New Customer"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Create_New_Export_Customer" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Create_New_Export_Customer','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Create_New_Export_Customer_#i#"  MASSUPDATEID="Create_New_Export_Customer" <CFIF evaluate("Get_#i#_Settings.Create_New_Export_Customer") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_New_Export_Customer NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Create_New_Export_Customer") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Create_New_Export_Customer NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  <cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap>Credit Manager</TD>
    <TD align="left" valign="top" nowrap="nowrap" WIDTH="270">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Credit_Manager" value="1" id="Credit_Manager_1" <cfif getSettingsManagerProfiles.Credit_Manager EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Credit_Manager" value="0" id="Credit_Manager_0" <cfif getSettingsManagerProfiles.Credit_Manager EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
  <TR <cfif getSettingsManagerProfiles.Credit_Manager EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Credit Manager</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Credit_Manager NEQ 0><cf_toFile fname="#fName#" data="Credit Manager"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Credit_Manager" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Credit_Manager','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Credit_Manager_#i#"  MASSUPDATEID="Credit_Manager" <CFIF evaluate("Get_#i#_Settings.Credit_Manager") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Credit_Manager NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Credit_Manager") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Credit_Manager NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
  </cfif>
  <!--- (End) Only if the Export Program App Setting is turned on --->
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Re-instate deleted programs</TD>
        <TD align="left" valign="top" nowrap="nowrap" WIDTH="270">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Re_instate_deleted_programs" value="1" id="Re_instate_deleted_programs_1" <cfif getSettingsManagerProfiles.Re_instate_deleted_programs EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Re_instate_deleted_programs" value="0" id="Re_instate_deleted_programs_0" <cfif getSettingsManagerProfiles.Re_instate_deleted_programs EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
 <TR <cfif application.appSettingsGet.getViewDeleteRecords() eq 0    <!--- 35714 --->
           or getSettingsManagerProfiles.Re_instate_deleted_programs EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Re-instate Deleted Programs</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Re_instate_deleted_programs NEQ 0><cf_toFile fname="#fName#" data="Re-instate Deleted Programs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Re_instate_deleted_programs" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Re_instate_deleted_programs','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Re_instate_deleted_programs_#i#"  MASSUPDATEID="Re_instate_deleted_programs" <CFIF evaluate("Get_#i#_Settings.Re_instate_deleted_programs") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Re_instate_deleted_programs NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Re_instate_deleted_programs") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Re_instate_deleted_programs NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
 <!--- D40664 :: Settings page to show Deleted Billbacks START --->
   <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Re-instate deleted payables</TD>
        <TD align="left" valign="top" nowrap="nowrap" WIDTH="270">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Re_instate_deleted_billbacks" value="1" id="Re_instate_deleted_billbacks_1" <cfif getSettingsManagerProfiles.Re_instate_deleted_billbacks EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Re_instate_deleted_billbacks" value="0" id="Re_instate_deleted_billbacks_0" <cfif getSettingsManagerProfiles.Re_instate_deleted_billbacks EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
 <TR <cfif application.appSettingsGet.getViewDeleteRecords() eq 0  or getSettingsManagerProfiles.Re_instate_deleted_billbacks EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Re-instate Deleted Payables</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Re_instate_deleted_billbacks NEQ 0><cf_toFile fname="#fName#" data="Re-instate Deleted Billbacks"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Re_instate_deleted_billbacks" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Re_instate_deleted_billbacks','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Re_instate_deleted_billbacks_#i#"  MASSUPDATEID="Re_instate_deleted_billbacks" <CFIF evaluate("Get_#i#_Settings.Re_instate_deleted_billbacks") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Re_instate_deleted_billbacks NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Re_instate_deleted_billbacks") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Re_instate_deleted_billbacks NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
<!--- D40664 :: Settings page to show Deleted Billbacks END --->

<!--- ------ D51056 app setting for Dashboards to turn on/off BEGIN ------ --->
<cfif appSettings.get_Setting('Dashboards') eq '1'>
<!--- D29929: Dashboard Settings START --->
<cfif fromSettings_management eq 1>
    <TR>
      <TD  align="right" nowrap>Dashboard Access</TD>
      <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Dashboard_Access_View" value="1" id="Dashboard_Access_View_1" <cfif getSettingsManagerProfiles.Dashboard_Access_View EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
            <input type="radio" name="Dashboard_Access_View" value="0" id="Dashboard_Access_View_0" <cfif getSettingsManagerProfiles.Dashboard_Access_View EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      </TD>
    </TR>
    <cfelse>
    <TR <cfif getSettingsManagerProfiles.Dashboard_Access_View EQ 0> style="display:none"</cfif>>
				    <TD style="background-color: whitesmoke;border-right: 1px solid silver;position: relative;border-top:0px;border-bottom: 0px" nowrap>&nbsp;</TD>
        <TD style="border-top:0px;border-bottom: 0px">&nbsp;</TD>
    </TR>
    <TR <cfif getSettingsManagerProfiles.Dashboard_Access_View EQ 0> style="display:none"</cfif>>
      <TD WIDTH="195" id="locked" class="locked" nowrap>Dashboard Access</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_Access_View NEQ 0><cf_toFile fname="#fName#" data="Dashboard Access List"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >&nbsp;</TD>
      <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
        <!---<cfset bApprovePullback = Evaluate("Get_#i#_Settings.Approve_Pullback") />--->
        <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><span ID="ProfileSpan_#i#">

		<cfif #frmREADONLY# EQ "DISABLED">
			<span style="color:999999;"><B>VIEW</B></span>
		<cfelse>
        <!---<span ID="Dashboard_Access_View_Disabled_#i#" style="color:999999;<cfif bApprovePullback EQ 1>display:none</cfif>"><B>VIEW</B></span>--->
        <span ID="Dashboard_Access_View_Enabled_#i#" value="#i#" style="color:000000;">
        <a href="Dashboard_Access.cfm?profileId=#i#" onclick="javaScript:allowBlur();NewWindow(this.href , 'Dashboard_Access' , 750 , 650 , 'yes' , 'yes'); return false;" target="_blank"><B>VIEW</B></a>
		    </span>
		</cfif>
    </span>
		</TD>
      </CFLOOP>
      <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_Access_View NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
    </TR>
</cfif>

  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Dashboard Remote Access</TD>
        <TD align="left" valign="top" nowrap="nowrap" WIDTH="270">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Dashboard_Remote_Access" value="1" id="Dashboard_Remote_Access_1" <cfif getSettingsManagerProfiles.Dashboard_Remote_Access EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Dashboard_Remote_Access" value="0" id="Dashboard_Remote_Access_0" <cfif getSettingsManagerProfiles.Dashboard_Remote_Access EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
 <TR <cfif getSettingsManagerProfiles.Dashboard_Remote_Access EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Remote Dashboard Access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_Remote_Access NEQ 0><cf_toFile fname="#fName#" data="Dashboard Remote Access"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Dashboard_Remote_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Dashboard_Remote_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Dashboard_Remote_Access_#i#"  MASSUPDATEID="Dashboard_Remote_Access" <CFIF evaluate("Get_#i#_Settings.Dashboard_Remote_Access") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_Remote_Access NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Dashboard_Remote_Access") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_Remote_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>


<cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap valign="top">Dashboard UOM</TD>
        <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Dashboard_UOM" value="1" id="Dashboard_UOM_1" <cfif getSettingsManagerProfiles.Dashboard_UOM EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Dashboard_UOM" value="0" id="Dashboard_UOM_0" <cfif getSettingsManagerProfiles.Dashboard_UOM EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
      <cfelse>
  <TR <cfif getSettingsManagerProfiles.Dashboard_UOM EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap valign="top">Dashboard UOM</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_UOM NEQ 0><cf_toFile fname="#fName#" data="Dashboard UOM"></cfif>
    <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >
		    <INPUT TYPE="radio" NAME="Dashboard_UOM" ID="Dashboard_UOM_0" VALUE="4"><a href="##" OnClick="javascript:massUpdate('radio','Dashboard_UOM_0','1')" TITLE="Update all values for this row.">(+)</a><br>
		    <INPUT TYPE="radio" NAME="Dashboard_UOM" ID="Dashboard_UOM_1" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','Dashboard_UOM_1','1')" TITLE="Update all values for this row.">(+)</a><br>
		    <INPUT TYPE="radio" NAME="Dashboard_UOM" ID="Dashboard_UOM_2" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','Dashboard_UOM_2','1')"  TITLE="Update all values for this row.">(+)</a><br>
		    <INPUT TYPE="radio" NAME="Dashboard_UOM" ID="Dashboard_UOM_3" VALUE="9"><a href="##" OnClick="javascript:massUpdate('radio','Dashboard_UOM_3','1')"  TITLE="Update all values for this row.">(+)</a><br>
    </TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="left" WIDTH="#TD_Width#" nowrap>
           <input type="radio" name="Dashboard_UOM_#i#"  MASSUPDATEID="Dashboard_UOM_0" VALUE="4" <CFIF evaluate("Get_#i#_Settings.Dashboard_UOM") EQ 4>CHECKED</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>$<br>
           <input type="radio" name="Dashboard_UOM_#i#"  MASSUPDATEID="Dashboard_UOM_1" VALUE="1" <CFIF evaluate("Get_#i#_Settings.Dashboard_UOM") EQ 1>CHECKED</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>Cs<br>
           <input type="radio" name="Dashboard_UOM_#i#"  MASSUPDATEID="Dashboard_UOM_2" VALUE="2" <CFIF evaluate("Get_#i#_Settings.Dashboard_UOM") EQ 2>CHECKED</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>Lb<br>
           <input type="radio" name="Dashboard_UOM_#i#"  MASSUPDATEID="Dashboard_UOM_3" VALUE="9" <CFIF evaluate("Get_#i#_Settings.Dashboard_UOM") EQ 9>CHECKED</cfif> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>Equiv Cs<br>
      </TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_UOM NEQ 0>
	<cfif evaluate("Get_#i#_Settings.Dashboard_UOM")EQ 4>
        	<cf_toFile fname="#fName#" data=",$">
    	<cfelseif evaluate("Get_#i#_Settings.Dashboard_UOM")EQ 1>
        	<cf_toFile fname="#fName#" data=",Cs">
    	<cfelseif evaluate("Get_#i#_Settings.Dashboard_UOM")EQ 2>
        	<cf_toFile fname="#fName#" data=",Lb">
    	<cfelseif evaluate("Get_#i#_Settings.Dashboard_UOM")EQ 9>
        	<cf_toFile fname="#fName#" data=",Equiv Cs">
    	</cfif>
    </cfif>

    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Dashboard_UOM NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
<!--- D29929: Dashboard Settings END --->
</cfif>  <!--- ------ D51056 app setting for Dashboards to turn on/off END ------ --->

    <!---30417 - Settings for product master edit feature--->
    <cfif fromSettings_management eq 1>
      	<cfset SettingsTemplateFormUserProfile(NameField="Edit_Product_MasterData", NameFieldDesc="Edit Product Master Data")>
  <cfelse>
  	<TR <cfif application.appSettingsGet.getEdit_Product_Master_Data() eq 0    <!--- 35714 --->
              or getSettingsManagerProfiles.Edit_Product_MasterData EQ 0> style="display:none"</cfif>>
    		<TD WIDTH="195" id="locked" class="locked" nowrap>Edit Product Master Data</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Product_MasterData NEQ 0><cf_toFile fname="#fName#" data="Edit Product Master Data"></cfif>
    		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Edit_Product_MasterData" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Edit_Product_MasterData','1')" TITLE="Update all values for this row.">(+)</a></TD>
    		<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Edit_Product_MasterData_#i#"  MASSUPDATEID="Edit_Product_MasterData" <CFIF evaluate("Get_#i#_Settings.Edit_Product_MasterData") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Product_MasterData NEQ 0>
      				<CFIF evaluate("Get_#i#_Settings.Edit_Product_MasterData") EQ 1>
        					<cf_toFile fname="#fName#" data=",yes">
      				<cfelse>
        					<cf_toFile fname="#fName#" data=",no">
      				</cfif>
    			</cfif>
    		</CFLOOP>
  		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Edit_Product_MasterData NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  	</TR>
  </cfif>

  <!---41568 - Profile Settings - Message Center --->
  <cfif fromSettings_management eq 1>
      	<cfset SettingsTemplateFormUserProfile(NameField="Message_Center_Viewing", NameFieldDesc="Message Center Viewing")>
  <cfelse>
  	<TR <cfif getSettingsManagerProfiles.Message_Center_Viewing EQ 0> style="display:none"</cfif>>
    		<TD WIDTH="195" id="locked" class="locked" nowrap>Message Center Viewing</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Message_Center_Viewing NEQ 0><cf_toFile fname="#fName#" data="Message Center Viewing"></cfif>
    		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Message_Center_Viewing" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Message_Center_Viewing','1')" TITLE="Update all values for this row.">(+)</a></TD>
    		<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Message_Center_Viewing_#i#"  MASSUPDATEID="Message_Center_Viewing" <CFIF evaluate("Get_#i#_Settings.Message_Center_Viewing") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Message_Center_Viewing NEQ 0>
      				<CFIF evaluate("Get_#i#_Settings.Message_Center_Viewing") EQ 1>
        					<cf_toFile fname="#fName#" data=",yes">
      				<cfelse>
        					<cf_toFile fname="#fName#" data=",no">
      				</cfif>
    			</cfif>
    		</CFLOOP>
  		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Message_Center_Viewing NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  	</TR>
  </cfif>

  <cfif fromSettings_management eq 1>
      	<cfset SettingsTemplateFormUserProfile(NameField="Message_Center_Administration", NameFieldDesc="Message Center Administration")>
  <cfelse>
  	<TR <cfif  getSettingsManagerProfiles.Message_Center_Administration EQ 0> style="display:none" </cfif>>
    		<TD WIDTH="195" id="locked" class="locked" nowrap>Message Center Administration</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Message_Center_Administration NEQ 0><cf_toFile fname="#fName#" data="Message Center Administration"></cfif>
    		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Message_Center_Administration" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Message_Center_Administration','1')" TITLE="Update all values for this row.">(+)</a></TD>
    		<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Message_Center_Administration_#i#"  MASSUPDATEID="Message_Center_Administration" <CFIF evaluate("Get_#i#_Settings.Message_Center_Administration") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Message_Center_Administration NEQ 0>
      				<CFIF evaluate("Get_#i#_Settings.Message_Center_Administration") EQ 1>
        					<cf_toFile fname="#fName#" data=",yes">
      				<cfelse>
        					<cf_toFile fname="#fName#" data=",no">
      				</cfif>
    			</cfif>
    		</CFLOOP>
  		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Message_Center_Administration NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  	</TR>
  </cfif>
  <cfif application.appSettingsGet.get_Setting('BB_Doc_Server_Folder') NEQ ''>
  	  <cfif fromSettings_management eq 1>
      	<cfset SettingsTemplateFormUserProfile(NameField="Browse_BBDoc_Server_Files", NameFieldDesc="Browse Files on Document Server")>
	  <cfelse>
	  	<TR <cfif  getSettingsManagerProfiles.Browse_BBDoc_Server_Files EQ 0> style="display:none" </cfif>>
	    		<TD WIDTH="195" id="locked" class="locked" nowrap>Browse Files on Document Server</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Browse_BBDoc_Server_Files NEQ 0><cf_toFile fname="#fName#" data="Browse Files on Document Server"></cfif>
	    		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Browse_BBDoc_Server_Files" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Message_Center_Administration','1')" TITLE="Update all values for this row.">(+)</a></TD>
	    		<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
	      			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Browse_BBDoc_Server_Files_#i#"  MASSUPDATEID="Browse_BBDoc_Server_Files" <CFIF evaluate("Get_#i#_Settings.Browse_BBDoc_Server_Files") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
	    			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Browse_BBDoc_Server_Files NEQ 0>
	      				<CFIF evaluate("Get_#i#_Settings.Browse_BBDoc_Server_Files") EQ 1>
	        					<cf_toFile fname="#fName#" data=",yes">
	      				<cfelse>
	        					<cf_toFile fname="#fName#" data=",no">
	      				</cfif>
	    			</cfif>
	    		</CFLOOP>
	  		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Browse_BBDoc_Server_Files NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	  	</TR>
	  </cfif>
  </cfif>
  <cfif LEN(TRIM(appSettings.get_Setting('Analytics_OpenDocument_URL'))) GT '0'>
  	  <cfif fromSettings_management eq 1>
      	<cfset SettingsTemplateFormUserProfile(NameField="Analytics_SSO", NameFieldDesc="Analytics SSO access")>
	  <cfelse>
	  	<TR <cfif  getSettingsManagerProfiles.Analytics_SSO EQ 0> style="display:none" </cfif>>
	    		<TD WIDTH="195" id="locked" class="locked" nowrap>Analytics SSO access</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Analytics_SSO NEQ 0><cf_toFile fname="#fName#" data="Browse Files on Document Server"></cfif>
	    		<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Analytics_SSO" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Analytics_SSO','1')" TITLE="Update all values for this row.">(+)</a></TD>
	    		<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
	      			<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Analytics_SSO_#i#"  MASSUPDATEID="Analytics_SSO" <CFIF evaluate("Get_#i#_Settings.Analytics_SSO") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
	    			<cfif saveToXl is "yes" and getSettingsManagerProfiles.Analytics_SSO NEQ 0>
	      				<CFIF evaluate("Get_#i#_Settings.Analytics_SSO") EQ 1>
	        					<cf_toFile fname="#fName#" data=",yes">
	      				<cfelse>
	        					<cf_toFile fname="#fName#" data=",no">
	      				</cfif>
	    			</cfif>
	    		</CFLOOP>
	  		<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Analytics_SSO NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
	  	</TR>
	  </cfif>
  </cfif>
<!--- 76021 :: Ember:  Open Document from FORGE Application START--->
<cfif LEN(TRIM(appSettings.get_Setting('Ember_OpenDocument_URL'))) GT '0'>
  <cfif fromSettings_management eq 1>
    <cfset SettingsTemplateFormUserProfile(NameField="Ember_Access", NameFieldDesc="Insights SSO Access")>
  <cfelse>
        <TR>
            <TD WIDTH="195" id="locked" class="locked" nowrap>Insights SSO Access</TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.Ember_Access NEQ 0><cf_toFile fname="#fName#" data="Browse Files on Document Server"></cfif>
            <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="Ember_Access" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Ember_Access','1')" TITLE="Update all values for this row.">(+)</a></TD>
            <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
              <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
                  <INPUT TYPE="checkbox" NAME="Ember_Access_#i#"  MASSUPDATEID="Ember_Access" <CFIF evaluate("Get_#i#_Settings.Ember_Access") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
              </TD>
              <cfif saveToXl is "yes" and getSettingsManagerProfiles.Ember_Access NEQ 0>
                  <CFIF evaluate("Get_#i#_Settings.Ember_Access") EQ 1>
                      <cf_toFile fname="#fName#" data=",yes">
                  <cfelse>
                      <cf_toFile fname="#fName#" data=",no">
                  </cfif>
              </cfif>
            </CFLOOP>
          <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Ember_Access NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
        </TR>
  </cfif>
</CFIF>
<!--- 76021 :: Ember:  Open Document from FORGE Application END --->
<!--- D57447 :: Create and modify vendor records START--->
<cfif appSettings.getModifyVendorRecords() >
  <cfif fromSettings_management eq 1>
      <TR>
        <TD align="right"  nowrap>Modify Vendors</TD>
        <TD align="left" valign="top" nowrap="nowrap" WIDTH="270">&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Modify_Vendors_VendorManagement" value="1" id="Modify_Vendors_VendorManagement_1" <cfif getSettingsManagerProfiles.Modify_Vendors_VendorManagement EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          <input type="radio" name="Modify_Vendors_VendorManagement" value="0" id="Modify_Vendors_VendorManagement_0" <cfif getSettingsManagerProfiles.Modify_Vendors_VendorManagement EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
        </TD>
      </TR>
  <cfelse>
 <TR <cfif application.appSettingsGet.getViewDeleteRecords() eq 0    <!--- 35714 --->
           or getSettingsManagerProfiles.Modify_Vendors_VendorManagement EQ 0> style="display:none"</cfif>>
    <TD WIDTH="195" id="locked" class="locked" nowrap>Modify Vendors</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Modify_Vendors_VendorManagement NEQ 0><cf_toFile fname="#fName#" data="Re-instate Deleted Programs"></cfif>
      <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="Modify_Vendors_VendorManagement" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','Modify_Vendors_VendorManagement','1')" TITLE="Update all values for this row.">(+)</a></TD>
    <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
      <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT TYPE="checkbox" NAME="Modify_Vendors_VendorManagement_#i#"  MASSUPDATEID="Modify_Vendors_VendorManagement" <CFIF evaluate("Get_#i#_Settings.Modify_Vendors_VendorManagement") EQ 1>VALUE="1" CHECKED<CFELSE>VALUE="1"</CFIF> MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
    <cfif saveToXl is "yes" and getSettingsManagerProfiles.Modify_Vendors_VendorManagement NEQ 0>
      <CFIF evaluate("Get_#i#_Settings.Modify_Vendors_VendorManagement") EQ 1>
        <cf_toFile fname="#fName#" data=",yes">
      <cfelse>
        <cf_toFile fname="#fName#" data=",no">
      </cfif>
    </cfif>
    </CFLOOP>
    <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Modify_Vendors_VendorManagement NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
  </TR>
  </cfif>
</cfif>
<!--- D57447 :: Create and modify vendor records END--->

	<!--- START: D96464: HF Bundle - Finance Security Role Update --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planning Groups - View & Create --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD  align="right" nowrap>Planning Groups - View & Create</TD>
			<TD WIDTH="270" align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planning_Groups_Create" value="1" id="Planning_Groups_Create_1" <cfif getSettingsManagerProfiles.Planning_Groups_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planning_Groups_Create" value="0" id="Planning_Groups_Create_0" <cfif getSettingsManagerProfiles.Planning_Groups_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planning_Groups_Create EQ 0> style="display:none"</cfif>>
			<TD WIDTH="275" id="locked" class="locked" nowrap>Planning Groups - View & Create</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_Create NEQ 0><cf_toFile fname="#fName#" data="View & Create"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Planning_Groups_Create_Mass_2" NAME="Planning_Groups_Create" VALUE="2"><a href="##" OnClick="javascript:massUpdate('radio','Planning_Groups_Create_Mass_2','2')" TITLE="Update all values for this row.">(+)</a></TD>


			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
					<INPUT NAME="Planning_Groups_Create_#counter#" TYPE="radio"  MASSUPDATEID="Planning_Groups_Create_Mass_2" ID="Planning_Groups_Create_#counter#" VALUE="2" onclick="checkview(#counter#);" <CFIF getProfiles.Planning_Groups_Create EQ 2>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#>
				</TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_Create NEQ 0>
					<CFIF evaluate("getProfiles.Planning_Groups_Create") EQ 2>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planning Groups - View  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Planning Groups - View</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planning_Groups_View" value="1" id="Planning_Groups_View_1" <cfif getSettingsManagerProfiles.Planning_Groups_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planning_Groups_View" value="0" id="Planning_Groups_View_0" <cfif getSettingsManagerProfiles.Planning_Groups_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planning_Groups_View EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Planning Groups - View</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_View NEQ 0><cf_toFile fname="#fName#" data="View Only"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Planning_Groups_Create_Mass_1"  NAME="Planning_Groups_Create" VALUE="1"><a href="##" OnClick="javascript:massUpdate('radio','Planning_Groups_Create_Mass_1','1')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="Planning_Groups_Create_#counter#" TYPE="radio"  MASSUPDATEID="Planning_Groups_Create_Mass_1" ID="Planning_Groups_Create_#counter#" VALUE="1" onclick="checkview(#counter#);" <CFIF getProfiles.Planning_Groups_Create EQ 1>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_Create NEQ 0>
					<CFIF evaluate("getProfiles.Planning_Groups_Create") EQ 1>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>

	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<!--- Planning Groups - None  --->
	<!--------------------------------------------------------------------------------------------------------------------------------------------------------->
	<cfif fromSettings_management eq 1>
		<TR>
			<TD align="right" nowrap>Planning Groups - None</TD>
			<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planning_Groups_None" value="1" id="Planning_Groups_None_1" <cfif getSettingsManagerProfiles.Planning_Groups_Create EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
				<input type="radio" name="Planning_Groups_None" value="0" id="Planning_Groups_None_0" <cfif getSettingsManagerProfiles.Planning_Groups_Create EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
			</TD>
		</TR>
	<cfelse>
		<TR <cfif getSettingsManagerProfiles.Planning_Groups_None EQ 0> style="display:none"</cfif>>
			<TD WIDTH="195" id="locked" class="locked" nowrap>Planning Groups - None</TD> <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_None NEQ 0><cf_toFile fname="#fName#" data="None"></cfif>
			<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="radio" ID="Planning_Groups_Create_Mass_0"  NAME="Planning_Groups_Create" VALUE="0"><a href="##" OnClick="javascript:massUpdate('radio','Planning_Groups_Create_Mass_0','0')" TITLE="Update all values for this row.">(+)</a></TD>
			<CFLOOP QUERY="getProfiles">
				<CFSET counter=getProfiles.Profiles_ID>
				<TD ALIGN="center" WIDTH="#TD_Width#" nowrap><INPUT NAME="Planning_Groups_Create_#counter#" TYPE="radio"  MASSUPDATEID="Planning_Groups_Create_Mass_0" ID="Planning_Groups_Create_#counter#" VALUE="0" onclick="checkview(#counter#);" <CFIF getProfiles.Planning_Groups_Create EQ 0>CHECKED</CFIF> MASSCONTROLID="massUpdateColumn_#counter#" #frmREADONLY#></TD>
				<cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_None NEQ 0>
					<CFIF evaluate("getProfiles.Planning_Groups_Create") EQ 0>
						<cf_toFile fname="#fName#" data=",yes">
					<cfelse>
						<cf_toFile fname="#fName#" data=",no">
					</cfif>
				</cfif>
			</CFLOOP>
			<td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.Planning_Groups_Create NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
		</TR>
	</cfif>
<!--- END: D96464: HF Bundle - Finance Security Role Update --->
<!--- START: 103971 - Double Dip Report / Anand Rao / 17-Feb-2021 --->
<cfif request.settings.Double_Dip_Report eq '1'>
  <cfif fromSettings_management eq 1>
    <cfset SettingsTemplateFormUserProfile(NameField="DoubleDipReport", NameFieldDesc="Double Dip Report")>
  <cfelse>
        <TR>
            <TD WIDTH="195" id="locked" class="locked" nowrap>Double Dip Rpt</TD>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles.DoubleDipReport NEQ 0><cf_toFile fname="#fName#" data="Browse Files on Document Server"></cfif>
            <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate"  nowrap><INPUT TYPE="checkbox" NAME="DoubleDipReport" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','DoubleDipReport','1')" TITLE="Update all values for this row.">(+)</a></TD>
            <cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
              <TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
                  <INPUT TYPE="checkbox" NAME="DoubleDipReport_#i#"  MASSUPDATEID="DoubleDipReport" <CFIF evaluate("Get_#i#_Settings.DoubleDipReport") EQ 1> CHECKED<CFELSE></CFIF> VALUE="1" MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
              </TD>
              <cfif saveToXl is "yes" and getSettingsManagerProfiles.DoubleDipReport NEQ 0>
                  <CFIF evaluate("Get_#i#_Settings.DoubleDipReport") EQ 1>
                      <cf_toFile fname="#fName#" data=",yes">
                  <cfelse>
                      <cf_toFile fname="#fName#" data=",no">
                  </cfif>
              </cfif>
            </CFLOOP>
          <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles.DoubleDipReport NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
        </TR>
  </cfif>
</CFIF>
<!--- END: 103971 - Double Dip Report / Anand Rao / 17-Feb-2021 --->

<!--- 112733 Forge Dashboards - CF settings START--->
<cfif request.settings.Home_Page_Dashboards eq '1'>
<cfif fromSettings_management eq 1>
  <TR>
    <TD align="right"  nowrap valign="top">Home Page Dashboards</TD>
    <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
      <input type="radio" name="Home_Page_Dashboards" value="1" id="Home_Page_Dashboards_1" <cfif getSettingsManagerProfiles.Home_Page_Dashboards EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      <input type="radio" name="Home_Page_Dashboards" value="0" id="Home_Page_Dashboards_0" <cfif getSettingsManagerProfiles.Home_Page_Dashboards EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
    </TD>
  </TR>
  <cfelse>
<TR <cfif getSettingsManagerProfiles.Home_Page_Dashboards EQ 0> style="display:none"</cfif>>
<TD WIDTH="195" id="locked" class="locked" nowrap>Home Page Dashboards</TD><cfif saveToXl is "yes" and getSettingsManagerProfiles.Home_Page_Dashboards NEQ 0><cf_toFile fname="#fName#" data="Home_Page_Dashboards"></cfif>
<TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" >&nbsp;</TD>
<cfloop query="getProfiles"><cfset i = getProfiles.profiles_id>
<TD ALIGN="center" WIDTH="#TD_Width#" nowrap>
<span ID="ProfileSpan_#i#">
  <cfif #frmREADONLY# EQ "DISABLED">
    <span style="color:999999;"><B>VIEW</B></span>
  <cfelse>
  <span value="#i#" style="color:000000;">
    <a href="Forge_Dashboard_Access.cfm?profileId=#i#&AdminUserFromProfilesPage=1" onclick="javaScript: allowBlur(); NewWindow(this.href , 'Forge_Dashboard_Access' , 500 , 500 , 'yes' , 'yes'); return false;" target="_blank"><B>VIEW</B></a>
  </span>
  </cfif>
</span>
</TD>
</CFLOOP>
<td width="100%">&nbsp;</td>
</TR>
</cfif>
</cfif>
	<!--- 112733 Forge Dashboards - CF settings END--->

	  </TBODY>
 </TABLE>
 </DIV>
<!--- <br> --->
</cfoutput>
<cfif fromSettings_management neq 1>
<cfoutput>
<table align="center" border="0" width="98%">
<tr>
  <td class="footerlinks" width="25%">
    <CFIF Locked EQ 1>
      <a href="##" id="saveSettings">#application.util.string.actionLinkFormat2("save settings")#</a>
    <CFELSE>
      <a href="##" onclick="return false;">#application.util.string.actionLinkFormat2("view settings")#</a>
    </CFIF>
  </td>
    <td class="footerlinks" width="25%">
      <cfif saveToXl is "no"><!---  save or export settings --->
        <a id="create_xl" href="##">#application.util.string.actionLinkFormat2("create xl file")#</a>
      <cfelse>
        <!--- Dev Note: 9377 - Move Excel Download into Common Documents folder --->
        <a href="/getDocument.cfm?filepath=Temp_Files/Settings/Profiles/#XL_file_name#.CFM">#application.util.string.actionLinkFormat2("create xl file")#</a>
      </cfif>
    </td>
    <td class="footerlinks" width="25%">
        <a href="##" onclick="javascript:allowBlur();window.close();">#application.util.string.actionLinkFormat2("close window")#</a>
    </td>

  </tr>

</table>

</cfoutput>
<cfoutput>
<script>
  <cfinclude template="profileScript.js">
</script>
</cfoutput>

<cfinclude template="\common_files\jQuery.cfm">
<script type="text/javascript" src="/script/javascript/jquery.noty.packaged.min.js"></script>

<script>
  /*
      D55216 :: Profile page displaying different values in ready only/Edit mode with IE11
      THIS BLOCK OF CODE CAUSING "APPROVE RECAPTURE" SETTING TO TOGGLE IN IE11 WHEN PROFILE PAGE IS IN EDIT MODE.
      WE HAVE CF CODE IN PLACE TO ENABLE/DISABLE "APPROVE RECAPTURE" SETTING BASED ON "APPROVE RIGHTS" WHEN PAGE IS LOADED.
      WE HAVE ONCLICK EVENT ON "APPROVE RIGHTS" WHICH WILL TOGGLE "APPROVE RECAPTURE" BASED ON "APPROVE RIGHTS".
      AS THIS CODE SEEMS REDUNDANT AND CAUSING ISSUE SO COMMENTED BELOW CODE.

  for(var z=0; z<document.all.ApprovalRightsCheckboxes.length; z++){
    theCheckbox=getFirstChild(document.all.ApprovalRightsCheckboxes[z]);
    //callfireEvent(document,theCheckbox,'Click');
    theCheckbox.fireEvent("onclick");
  }
  */

  approvalTypeMech('<cfoutput>#margin_approval_method.program_margin_approval_method#</cfoutput>');

  function changeDisableOtherCheckBoxes(thisObj, OtherObj, reverseValues)
  {
    var bChecked = thisObj.checked;
    if(OtherObj)
    {
      if(reverseValues)
      {
        bChecked = !bChecked;
      }

      if(!(bChecked))
      {
        OtherObj.checked = false;
      }
      OtherObj.disabled = !(bChecked);
    }
  }
  $('#saveSettings').click(function() {
      allowBlur();
      var $form = $('form[name=MyForm]');
      $form.hide();
      noty( { text: "Saving profile settings, this can take a while..."
              ,layout:'center'
              ,type:'information'
              ,killer:true
            });
      $form.submit();
  });
  $('#create_xl').click(function() {
      allowBlur();
      $('form[name=MyForm]').hide();
      noty( { text: "Creating xl file, please wait..."
              ,layout:'center'
              ,type:'information'
              ,killer:true
            });
      window.location = "/settings/Access_Rights/index.cfm?saveToXl=yes&PageTitle=Users: user profiles";
  });
</script>

   <cfif saveToXl is "yes"><cfoutput>
      <script language="JavaScript">
        <!-- hide
        <!--- Dev Note: 9377 - Move Excel Download into Common Documents folder --->
        function openGetFile() {
          window.open('/settings/Access_Rights/download.CFM?fn=#XL_file_name#&display=#url.display#','dlwin','width=300,height=200');
        }
        openGetFile();
        // -->
      </script></cfoutput>
  </cfif>
</cfif>

<cffunction name="SettingsTemplateFormUserProfile">
	<cfargument name="NameField" type="string" required="true" default="">
	<cfargument name="NameFieldDesc" type="string" required="true" default="">
	<cfoutput>
	<TR>
      		<TD  align="right" nowrap>#arguments.NameFieldDesc#</TD>
      		<TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
          			<input type="radio" name="#arguments.NameField#" value="1" id = "#arguments.NameField#_1" <cfif getSettingsManagerProfiles[arguments.NameField] EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          			<input type="radio" name="#arguments.NameField#" value="0" id = "#arguments.NameField#_0" <cfif getSettingsManagerProfiles[arguments.NameField] EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
     		 </TD>
	</TR>
	</cfoutput>
</cffunction>


<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~ Reusable rendering setting function ~~~~~~~~~~~~~~~~~ --->
<!--- ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ --->
<cffunction name="render_setting">
    <cfargument name="setting_label" required="true">
    <cfargument name="visibility_column_name" required="true">
    <cfargument name="enabled_setting_value" required="true">
    <cfargument name="setting_column_name" required="true">

    <cfoutput>
    <cfif fromSettings_management eq 1>
        <tr>
            <td align="right" nowrap>#arguments.setting_label#</td>
            <td align="left" valign="top" nowrap="nowrap"> &nbsp;
                <input type="radio" name="#arguments.visibility_column_name#" value="1" id="#arguments.visibility_column_name#_1"
                    <cfif getSettingsManagerProfiles[arguments.visibility_column_name] eq 1>checked</cfif>> Show &nbsp; &nbsp; &nbsp;
                <input type="radio" name="#arguments.visibility_column_name#" value="0" id="#arguments.visibility_column_name#_0"
                    <cfif getSettingsManagerProfiles[arguments.visibility_column_name] eq 0>checked</cfif>> Hide &nbsp; &nbsp; &nbsp;
            </td>
        </tr>
    <cfelse>
        <tr <cfif getSettingsManagerProfiles[arguments.visibility_column_name] eq 0> style="display:none"</cfif>>
            <td width="225" id="locked" class="locked" nowrap>#arguments.setting_label#</td>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles[arguments.visibility_column_name] neq 0>
                <cf_toFile fname="#fName#" data="#arguments.setting_label#">
            </cfif>

            <td width="#massUpdate_TD_Width#" class="massUpdate" >
                <input type="radio" ID="#arguments.visibility_column_name#_ID" name="#arguments.setting_column_name#" value="#arguments.enabled_setting_value#">
                <a href="##" onClick="javascript:massUpdate('radio','#arguments.visibility_column_name#_ID','#arguments.enabled_setting_value#')"
                    title="Update all values for this row.">(+)</a>
            </td>

            <cfloop query="getProfiles">
                <cfset i = getProfiles.profiles_id>
                <td align="center" width="#TD_Width#" nowrap>
                    <input type="radio" name="#arguments.setting_column_name#_#i#" class="#i#" MASSUPDATEID="#arguments.visibility_column_name#_ID"
                        value="#arguments.enabled_setting_value#"
                        <cfif variables["Get_#i#_Settings"][arguments.setting_column_name][1] eq arguments.enabled_setting_value> checked</cfif>
                        MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#>
                </td>
                <cfif saveToXl is "yes" and getSettingsManagerProfiles[arguments.visibility_column_name] neq 0>
                    <cfif variables["Get_#i#_Settings"][arguments.setting_column_name][1] eq arguments.enabled_setting_value>
                        <cf_toFile fname="#fName#" data=",yes">
                    <cfelse>
                        <cf_toFile fname="#fName#" data=",no">
                    </cfif>
                </cfif>
            </cfloop>

            <td width="100%"> </td>
            <cfif saveToXl is "yes" and getSettingsManagerProfiles[arguments.visibility_column_name] neq 0>
                <cf_toFile fname="#fName#" nl="Yes" data="">
            </cfif>
        </tr>
    </cfif>
</cfoutput>
</cffunction>




<cffunction name="render_setting_1">
    <cfargument name="setting_label" required="true">
    <cfargument name="visibility_column_name" required="true">
    <cfargument name="enabled_setting_value" required="true">
    <cfargument name="setting_column_name" required="true">

    <cfoutput>    
    <cfif fromSettings_management eq 1>
        <TR>
          <TD align="right"  nowrap>#arguments.setting_label#</TD>
          <TD align="left" valign="top" nowrap="nowrap">&nbsp;&nbsp;&nbsp;
                <input type="radio" name="#arguments.setting_column_name#" value="1" id="#arguments.setting_column_name#_1" <cfif getSettingsManagerProfiles[arguments.setting_column_name] EQ 1>checked</cfif>> Show&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                <input type="radio" name="#arguments.setting_column_name#" value="0" id="#arguments.setting_column_name#_0" <cfif getSettingsManagerProfiles[arguments.setting_column_name] EQ 0>checked</cfif>> Hide&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          </TD>
        </TR>
      <cfelse>
        <TR <cfif getSettingsManagerProfiles[arguments.setting_column_name] EQ 0> style="display:none"</cfif>>
          <TD WIDTH="195" id="locked" class="locked" nowrap>#arguments.setting_label#</TD>  <cfif saveToXl is "yes" and getSettingsManagerProfiles[arguments.setting_column_name] NEQ 0><cf_toFile fname="#fName#" data="#arguments.setting_label#"></cfif>
          <TD WIDTH="#massUpdate_TD_Width#" class="massUpdate" ><INPUT TYPE="checkbox" NAME="#arguments.setting_column_name#" VALUE="1"><a href="##" OnClick="javascript:massUpdate('checkbox','#arguments.setting_column_name#','1')"   TITLE="Update all values for this row.">(+)</a></TD>
          <cfloop query="getProfiles">
          <cfset i = getProfiles.profiles_id>
          <TD ALIGN="center" WIDTH="#TD_Width#" nowrap><input TYPE="checkbox" NAME="#arguments.setting_column_name#_#i#" class="#i#" MASSUPDATEID="#arguments.setting_column_name#" PROFILESPAN="document.all.ProfileSpan_#i#" value="1" <cfif evaluate("Get_#i#_Settings.#arguments.setting_column_name#") IS 1>checked</cfif>  MASSCONTROLID="massUpdateColumn_#i#" #frmREADONLY#></TD>
          <cfif saveToXl is "yes" and getSettingsManagerProfiles[arguments.setting_column_name] NEQ 0>
              <cfif evaluate("Get_#i#_Settings.#arguments.setting_column_name#") EQ 1>
                <cf_toFile fname="#fName#" data=",yes">
              <cfelse>
                <cf_toFile fname="#fName#" data=",no">
              </cfif>
            </cfif>
          </CFLOOP>
          <td width="100%">&nbsp;</td>  <cfif saveToXl is "yes" and getSettingsManagerProfiles[arguments.setting_column_name] NEQ 0><cf_toFile fname="#fName#" nl="Yes" data=""></cfif>
        </TR>
        </cfif>
    </cfoutput>
</cffunction>

