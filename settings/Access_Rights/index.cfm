<!---
	Name: index.cfm
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		The top-level cfm template for the profile management page.
	Usage:
		Contains all profile management presentation and business logic.
--->

<CFSET PAGE_TITLE=	"User Profiles Control Panel">
<CFSET GROUP=		"Control_Panel">
<!--- Dev Note: Clay 7029: Default Form State is Readonly (0) --->
<CFPARAM name="url.lockstate" default="0">


<cfparam name="url.display" default="block">


<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
<TITLE>USER PROFILES: MANAGEMENT CONSOLE</TITLE>

<cfset include_files = [ 	"/common_files/locked-column.css"
							,"/common_files/ViewModes.css"
							,"/script/javascript/string_functions.js"
							,"/Script/javascript/dhtml.js"
							,"/common_files/massUpdate.js"
						]>
<cf_include files=#arrayToList( include_files )#>

<script language="JavaScript" type="text/JavaScript">
<!--
function MM_reloadPage(init) {  //reloads the window if Nav4 resized
  if (init==true) with (navigator) {if ((appName=="Netscape")&&(parseInt(appVersion)==4)) {
    document.MM_pgW=innerWidth; document.MM_pgH=innerHeight; onresize=MM_reloadPage; }}
  else if (innerWidth!=document.MM_pgW || innerHeight!=document.MM_pgH) location.reload();
}
MM_reloadPage(true);
//-->
</script>

<!--- Dev Note: Clay 7029:
     Keep the window in focus (Alt-Tab stills Works) --->


<SCRIPT FOR="window" EVENT="onbeforeunload">
	if(document.all.readonlymode.value == 0 && document.all.showMessage.value == 1)
	{
		if(document.all.approved_blur_method.value == 0)
		{
			event.returnValue = "All unsaved changes will be lost.";
		}
		document.all.approved_blur_method.value = 0;
	}
</SCRIPT>

<!--- Temporarily Allow the Page Onblur  --->
<SCRIPT type="text/javascript" language="JavaScript">
function allowBlur()
{
<!--
	document.all.approved_blur_method.value = 1;
 -->
}

<!--- Suppress Allow the Page Onblur --->
function preventBlur()

{
<!--
	document.all.approved_blur_method.value = 0;
-->
}
</SCRIPT>

<!--- <SCRIPT SRC="/script/javascript/window_functions.js"></SCRIPT> --->

<script>
function massUpdateCheckAll(thisElement)
{
//<!--
		var parentElement = getParentObject(thisElement, 'tr');
		var elemColctn2 = parentElement.getElementsByTagName("input");

		for (var i = 0; i < elemColctn2.length; i++)
		{
			elemColctn2[i].checked = thisElement.checked;
		}
//-->
}
</script>
<style type="text/css" id="groupStyle">
			.groupLabel {
				display : none;
				visibility : hidden;
			}
</style>

<style id="groupStyle_2">
			.groupLabel_2 {
				display : none;
				visibility : hidden;
			}
</style>
</HEAD>


<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" RIGHTMARGIN="0" BOTTOMMARGIN="0" style="overflow:hidden;margin:0px; display:<cfoutput>#url.display#</cfoutput>;" onLoad="javascript:document.all.PleaseWaitMessage.style.display='none';">

<CFINCLUDE TEMPLATE="/includes/call_please_wait.cfm">
<!--- <SPAN ID="bodyText" STYLE="display:none"> --->
<!--- <div style="position:absolute;top:0px;left:0px;padding:0px;width:100%;height:490;overflow">  --->
<!--- For spending cap only -- for all regular lumps sums--->
<cfset UserSetting = CreateObject("component","components.user.Profile").getUserSettingsPanel(request.AccessStructure.Profiles_ID)>

	<!--- Dev Note: drachala; D28010: Profile Setting modifications 
		  what For: Check weather user selected any profiles if so we are passing argument into getprofiles query.	--->

	<cfset profile_id = ''>
	<cfif isdefined("url.profile_id")>
		<cfset profile_id = #trim(url.profile_id)#>
	</cfif>
	
<CFSET getProfiles = CreateObject("component", "components.settings.profiles.profile").getAllProfiles(profile_id=profile_id,UserSettingPanel=UserSetting.Settings_Panel)>

	<!--- End Dev Note: drachala; D28010: Profile Setting modifications  ---> 

<!---Initialize the appliation settings--->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = application.appSettingsGet>
<cfset UseCustomerType = appSettings.getCustomertype()>
<cfif UseCustomerType IS 1>
	<cfset useLakebaseForGetCustomerTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("customer_type")>
<cfif useLakebaseForGetCustomerTypes>
	<cftry>
		<cfset GetCustomerTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("customer_type", {
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetCustomerTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetCustomerTypes>
<cfquery name="GetCustomerTypes" datasource="#application.datasource#">
	SELECT *
	FROM Customer_Type
	WHERE Deleted = 0
	</cfquery>
</cfif>
</cfif>

<cfinclude template ="profile_qry_include.cfm">


<cfif UseCustomerType IS 1>
<cfloop query="GetCustomerTypes">
	<CFSET j = GetCustomerTypes.customer_type_id>
	<cfloop query="getProfiles">
<cfset i = getProfiles.profiles_id>
	<CFSET Query_Name2="Get_"&i&"_"&j&"_Settings">
	<CFQUERY NAME="#Query_Name2#" datasource="#application.datasource#">
		Select		*
		From		Profile_Customer_Type_Settings
		Where		Profiles_ID		=		#i#
		and customer_type_id = #j#
	</CFQUERY>
</CFloop>
</CFloop>
</cfif>
<!--- Get the date last updated and the user that did the update									 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

	<!--- Dev Note: drachala; D28054 Profile Setting modifications 
		  what For: Get latest time when you did update in a day with minutes apart from each update. Added MAX for Last_date_change--->
	<CFQUERY NAME="Get_Update_Data" datasource="#application.datasource#" MAXROWS="1">
		Select		MAX(Profiles_Settings.Last_Changed_Date) AS Last_Changed_Date,
					Profiles_Settings.Last_Changed_User_ID,
					_Users.Name_First,
					_Users.Name_Last
		From		Profiles_Settings,
					_Users
		Where		Profiles_Settings.Last_Changed_User_ID	=	_Users.User_ID
		Group by    Profiles_Settings.Last_Changed_User_ID,
					_Users.Name_First,
					_Users.Name_Last
		Order by Last_Changed_Date Desc
	</CFQUERY>
	<!--- End Dev Note: drachala; D28054: Profile Setting modifications  ---> 
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- get margin approval method --->
<cfset useLakebaseFormargin_approval_method = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("general_settings")>
<cfif useLakebaseFormargin_approval_method>
	<cftry>
		<cfset margin_approval_method = application.oLakebase.toQuery(
			application.oLakebase.selectRows("general_settings", {
				"select" = "program_margin_approval_method"
			}), "program_margin_approval_method"
		)>
		<cfcatch type="any">
			<cfset useLakebaseFormargin_approval_method = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFormargin_approval_method>
<cfquery name="margin_approval_method" datasource="#application.datasource#">
	SELECT program_margin_approval_method
	FROM General_Settings
</cfquery>
</cfif>

<CFLOOP INDEX="GroupCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">
		<cfloop query="getProfiles">
		<cfset i = getProfiles.profiles_id>
			<cfset useLakebaseForgetApprovalMargin = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("margin_group_profile_approval_margins")>
<cfif useLakebaseForgetApprovalMargin>
	<cftry>
		<cfset getApprovalMargin = application.oLakebase.toQuery(
			application.oLakebase.selectRows("margin_group_profile_approval_margins", {
				"group_id" = "eq.#GroupCount#",
				"profile_id" = "eq.#i#",
				"select" = "amount"
			}), "amount"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetApprovalMargin = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetApprovalMargin>
<CFQUERY NAME="getApprovalMargin" datasource="#application.datasource#">
				SELECT Amount
				FROM Margin_Group_Profile_Approval_Margins
				WHERE Group_ID='#GroupCount#' AND Profile_ID='#i#'
			</CFQUERY>
</cfif>
			<CFSET "FORM.Group_#GroupCount#_Profile_#i#" = getApprovalMargin.Amount>

			<cfif len(trim(getApprovalMargin.Amount)) EQ 0>
				<CFSET "FORM.Group_#GroupCount#_Profile_#i#" = "0.000">
			</cfif>
		</CFLOOP>
	</CFLOOP>


	<cfset fileName = "">
	<cfset fileName = "type_code_to_group_assignment.cfm">

<SCRIPT>
	function assignTypeCodesToGroup(oTD){
		if(oTD.getAttribute('GROUP_ID') != null){
			NewWindow("/settings/<cfoutput>#fileName#</cfoutput>?group_id="+oTD.getAttribute('GROUP_ID'), "typecodegroup", 800, 600, "yes", "yes")
		}
	//type_code_to_group_assignment.cfm
	}
</SCRIPT>

<script>
		var decimalPlaces = 3;

		function SubmitForm() {
				document.all.MyForm.submit();
		}

		function clenseTextBuffer(textObject,validlist){
			if(textObject.value.indexOf("*") != -1){
				textObject.value = "*";
			}
			else{
				clenseText(textObject,validlist)
				limitXdecimalplaces(decimalPlaces, textObject);
			}
		}
		var styleText = "border: 2px solid Silver;";
		var oListStartIndex = 0;
		var oInput_Overide = false;
		function toggleApprovalColumnActivity(oInput){
			spanWithElements = eval(oInput.getAttribute('PROFILESPAN'))

			for(var x = 0; x<spanWithElements.length; x++){

				inputArea = getFirstChild(spanWithElements[x]);

				if(oInput_Overide){
					if(x==0) {
						if(oInput.checked) {
							inputArea.style.cssText = "";
							inputArea.disabled = false;
						} else {
							inputArea.disabled = true;
							inputArea.checked = false;
							if (inputArea.type == "text") {
								inputArea.value = "0.000";
								inputArea.style.cssText = styleText;
							}
						}
					} else {
						inputArea.disabled = true;
						if (inputArea.type == "text") {
							inputArea.value = "0.000";
							inputArea.style.cssText = styleText;
						}
					}
				} else {
					if(!oInput.checked){
						inputArea.disabled = true;
						inputArea.checked = false;
						if (inputArea.type == "text") {
							inputArea.value = "0.000";
							inputArea.style.cssText = styleText
						}
					}
					else{
						inputArea.style.cssText = ""
						inputArea.disabled = false;
					}
				}
			}
			//reInitGroupValues();
		}

		function approvalTypeMech(oRadioValue){
			switch(oRadioValue) {
				case "1":
					decimalPlaces = 3;
					oListStartIndex = 0;
					oInput_Overide = false;
					document.all.groupStyle.disabled = true;
					document.all.groupStyle_2.disabled = false;
				break;

				case "2":
					decimalPlaces = 1;
					oListStartIndex = 0;
					oInput_Overide = false;
					document.all.groupStyle.disabled = true;
					document.all.groupStyle_2.disabled = false;
				break;

				case "3":
					decimalPlaces = 1;
					oListStartIndex = 1;
					oInput_Overide = true;
					document.all.groupStyle.disabled = false;
					document.all.groupStyle_2.disabled = true;
				break;

				case "4":
					decimalPlaces = 4;
					oListStartIndex = 0;
					oInput_Overide = false;
					document.all.groupStyle.disabled = true;
					document.all.groupStyle_2.disabled = false;
				break;
			}

			<!------
			<cfoutput>
			<cfloop query="getProfiles">
			<cfset i = getProfiles.profiles_id>

				//Changes the group approval rights
				toggleApprovalColumnActivity(document.all.Cont_Prog_Approval_Rights_#i#);


			</CFLOOP>
			</cfoutput>
			----->

			//reInitGroupValues();
		}


		function reInitGroupValues() {
			<cfoutput>
			<CFLOOP INDEX="GroupCount" FROM="1" TO="#application.returned_customer_setting.approval_group_count#" STEP="1">
				<cfloop query="getProfiles">
				<cfset i = getProfiles.profiles_id>
					clenseTextBuffer(document.all.Group_#GroupCount#_Profile_#i#, '*-.02134567890')
				</CFLOOP>
			</CFLOOP>
			</cfoutput>
		}

		function changeLSApproval(chObj)
		{
			if(event.propertyName == "checked")
			{
				var trobj = document.all.tr_LumpSumApproval;
				var show = "none";
				if(chObj.checked)
				{
					show = "";
				}
				trobj.style.display = show;

				var trobj = document.all.tr_InactiveLSApproval;
				var show = "none";
				if(chObj.checked)
				{
					show = "";
				}
				trobj.style.display = show;

				<Cfloop query="GetLumpSums">
				var trobj = document.all.LumpSumNames_<cfoutput>#Program_Lump_Sum_Name_ID#</cfoutput>;
				var show = "none";
				if(chObj.checked)
				{
					show = "";
				}
				trobj.style.display = show;
				</CFLOOP>
				reInitGroupValues();

			<cfoutput>
			<cfloop query="getProfiles">
			<cfset i = getProfiles.profiles_id>
				toggleApprovalColumnActivity(document.all.Cont_Prog_Approval_Rights_#i#);

			</CFLOOP>
			</cfoutput>

				approvalTypeMech(chObj.value);
			}

		}

	var pwinretval = 0;

	function profileEdit(ID, Action) {
		dataArray = new Array(1);
		dataArray[0] = ID;
		dataArray[1] = Action;

		/*
		action:
			1=new
			2=edit
		*/

		<!--- Added below line of code for chrome --->
		<!--- start --->
		window.returnValue = undefined;
		<!--- end --->
		pwinretval = window.showModalDialog("profile_admin_window.cfm",dataArray,"dialogHeight: 310px; dialogWidth: 500px; dialogTop: px; dialogLeft: px; edge: Raised; center: Yes; help: No; resizable: No; status: No;");
		
		<!--- Added below block of code for chrome --->
		<!--- start --->
		if (pwinretval == undefined)
		{
			pwinretval = window.returnValue;
		}
		<!--- end --->

		if(pwinretval == 1)
		{
			document.all.showMessage.value = 0;
			window.location.href = window.location.href;
		}
		pwinretval = 0;

	}
</script>








<FORM ACTION="access_rights_matrix_action.cfm?profile_id=<cfoutput>#profile_id#</cfoutput>" METHOD="post" NAME="MyForm">
<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<input name="showMessage" type="hidden" value="1" />

<!--- settings for the "Save to Excel" option ::  mws 9-3-04--->
<cfparam name="saveToXl" default="no">
<cfif saveToXl is "yes"> <!--- write the output to a var to be exported --->
		<CFSET XL_file_name=createuuid()>
		<!--- Replace the hyphens with underscores --->
		<CFSET XL_file_name=replace(XL_file_name,"-","_","All")>


		<CFSET appPath=request.app_general_functions.Get_Application_Path()>
		
			<!--- Dev Note: drachala; D28010: Profile Setting modifications 
					  what For: Download Excel Option 4.	--->
		
		<!--- Dev Note: 9377 - Move Excel Download into Common Documents folder --->
		<!--- <cfset fName = "#Application.Doc_Path#\Temp_Files\Settings\Profiles\#XL_file_name#.csv"> --->
			<cfset fName = "#Application.Doc_Path#\Temp_Files\Settings\Profiles\Access_Rights.csv">

		<!---<cfset output_to_excel="<cfsetting enablecfoutputonly=""yes"" showdebugoutput=""no""><cfheader name=""Content-Disposition"" value=""attachment;filename=Access_Rights.csv""><cfcontent type=""application/msexcel""><cfoutput>">--->
		<cfset output_to_excel="">
		<CFFILE ACTION="WRITE" FILE="#fname#" OUTPUT="#output_to_excel#" ADDNEWLINE="no">
	
</cfif>

<TABLE ID="lastUpdatedBy" BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
<TR>
<TD align="left" width="700px" style="border-right: 0px;font-size:12px;">
	<B>The profile settings were last updated on <CFOUTPUT>#dateformat(Get_Update_Data.Last_Changed_Date, 'm/d/yyy')# #timeformat(Get_Update_Data.Last_Changed_Date, 'h:mm:ss TT')# by #Get_Update_Data.name_first# #Get_Update_Data.name_last#</CFOUTPUT></B>
</TD>
<TD align="right" style="border-left: 0px;font-weight:bold;font-size:12px;"><SPAN style="color:rgb(255,0,0)">To Indicate No Limit (*)</SPAN>&nbsp;&nbsp;<span onMouseOver="allowBlur();" onMouseOut="preventBlur();"><CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm"></span></TD>
</TR>
</TABLE>

<!---Does the company have a default price list?--->
<cfquery name="TableExists" datasource="#application.datasource#">
	SELECT * FROM Information_Schema.Tables
	WHERE Table_Name = 'Price_List_Default'
</cfquery>

<cfparam name="tablewidth" default="1024">
<CFSET TD_Width = 80>
<cfset tablewidth = (getProfiles.recordcount * TD_Width)>
<cfif tablewidth lt 830>
<cfset tablewidth = 830>
</cfif>


	<cfinclude template="access_rights_matrix.cfm">
	
</form>

<!-------------------- End Added By Deepa ----------------------------------------->
<span id="trackerSpan" style="position: absolute; top: 0px; left: 0px;"></span>
</body>
