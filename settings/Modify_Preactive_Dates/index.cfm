<cfset PAGE_TITLE="Modify Preactive Dates">

<cfparam name="display_type" default="0">
<cfparam name="Contract_Main_ID_List" default="">

<cfmodule template="/customTags/layout.cfm"
		layoutID = "modifyPreactive"
		selectedIndex = "#display_type#">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<STYLE>
		.header
		{
			font-size: 11px; 
			font-weight: bold;
		}
	</STYLE>

<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>	
<SCRIPT SRC="/Common_Files/scripts/Date_Difference.js"></SCRIPT>
</HEAD>

<cfset objProgram = CreateObject("component", "components.programs.program") />
<cfset qryProgramList = objProgram.getProgramDetails(Contract_Main_ID_List)>
<cfset qryHistoryCount = objProgram.getMaxEntryForContractStartDateChangeHistory()>
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" align="Center">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<cfinclude template="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- If there is at least one record. "1" here means zero records. --->
<cfoutput>
<p align="left">
<!--- If the history exists --->
<cfif qryHistoryCount GT 1>
	<span style="color:red;font-weight:bold">[</span> 
		<cfif display_type eq 0>
			<a href="Excel_Report.cfm?display_type=#display_type#" style="font-weight:bold;">View report for last modification</a>
		<cfelseif display_type eq 1>
			<a href="Excel_Report.cfm?display_type=#display_type#" style="font-weight:bold;">View report for last modification</a>
		</cfif>
	<span style="color:red;font-weight:bold">]</span>
</cfif>

<!--- If there are programs on this page. --->
<cfif Contract_Main_ID_List neq "">
	<span style="color:red;font-weight:bold">[</span> 
		<a href="##" onClick="frmExcelReport.submit();" style="font-weight:bold;">View revisions for the below program list</a>
	<span style="color:red;font-weight:bold">]</span>
</cfif>


<!--- The list of programs could be a big one. Use the form to send list of programs. --->
<form name="frmExcelReport" action="Excel_Report.cfm" method="post">
	<input type="hidden" name="Contract_Main_ID_List" value="#Contract_Main_ID_List#">
</form>

</cfoutput>

<p align="center">
	<span style="color:red;font-weight:bold">[</span> 
			<a href="##" style="font-weight:bold;" onClick="getPreActivePrograms()">Select Programs in Pre-active Status</a>
	<span style="color:red;font-weight:bold">]</span>
</p>

<cfset widthStatus = "10%">
<cfset widthProgram = "15%">
<cfset widthTemplate = "20%">
<cfset widthTitle = "25%">
<cfset widthDates = "10%">
<cfset widthNewDates = "10%">
<cfset widthEffectiveDates = "10%">

<FORM name="frmModifyPreactivePrograms" ACTION="index.cfm" METHOD="POST">

<div>
<cf_easydate FormName="frmModifyPreactivePrograms"
	FieldName="massApplyDates"
	Format="mm/dd/yyyy">
	<br />

	<span style="color:red;font-weight:bold">[</span> 
	<cfif display_type eq 0>
		<a id="massApplyDates" href="##'" onClick="applyDates('txtStartDate')" style="font-weight:bold;">mass apply <cfif display_type eq 0>"start date"<cfelseif display_type eq 1>"end date"</cfif></a>
	<cfelseif display_type eq 1>
		<a id="massApplyDates" href="##'" onClick="applyDates('txtEndDate')" style="font-weight:bold;">mass apply <cfif display_type eq 0>"start date"<cfelseif display_type eq 1>"end date"</cfif></a>
	</cfif>
	<span style="color:red;font-weight:bold">]</span>
	<br /><br />
</div>

<cfoutput>
<table border="0" cellpadding="2" cellspacing="0" width="100%" class="MainTable">
	<tr bgcolor= "ffce84" valign="top">
		<td><input type="checkbox" name="allbox" onclick="javaScript: selectAll(this);" checked></td>
		<td class="header" width="#widthStatus#">Status</td>
		<td class="header" width="#widthProgram#">Program</td>
		<td class="header" width="#widthTemplate#">Template</td>
		<td class="header" width="#widthTitle#">Title</td>
		<td class="header" width="#widthDates#">Start Date<BR>End Date</td>
		<td class="header" width="#widthEffectiveDates#">Effective Start Date<BR/>Effective End Date</td>
		<!--- modify start date of preactive version. --->
		<cfif display_type eq 0>
		<td class="header" width="#widthNewDates#">New Start Date</td>
		<!--- modify end date of version prior to the preactive version and delete preactive version. 
		There may be more than one preactive version which the user wants to delete. 
		--->
		<cfelseif display_type eq 1>
		<td class="header" width="#widthNewDates#">New End Date</td>
		</cfif>
	</tr>

	<cfloop query="qryProgramList">
	<tr valign="top" bgcolor="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<td><input type="checkbox" name="SelectedITEMS" VALUE="#Contract_Main_ID#" CHECKED>
		<td width="#widthStatus#">#Contract_Status_Type_Desc#</td>
		<td width="#widthProgram#">#Contract_Number#</td>
		<td width="#widthTemplate#">#Created_Type#</td>
		<td width="#widthTitle#">#Contract_Title#	
		<cfif application.returned_customer_setting.Responsible_Person EQ 1>
			<br>SP:#RSP#</cfif></td>
		<td width="#widthDates#">
		#Contract_Start_Date#<BR>#Contract_End_Date#</td>
		<td width="#widthEffectiveDates#">
		#Effective_Start_Date#<BR>#Effective_End_Date#</td>

		<cfif display_type eq 0>
		<td width="#widthNewDates#">
		<span id="error_InvalidDate_#Contract_Main_ID#"></span>
		<!--- "DisableObject="#NOT(Is_A_Revision)#"" means - Do not allow user to edit, when there is only one version of the program. --->
			<cf_easydate FormName="frmModifyPreactivePrograms"
			FieldName="txtStartDate_#Contract_Main_ID#"
			Format="mm/dd/yyyy"
			DisableObject="#NOT(Is_A_Revision)#"></td>

		<cfelseif display_type eq 1>
		<td width="#widthNewDates#">
		<span id="error_NewDates_#Contract_Main_ID#"></span>
		<span id="error_InvalidDate_#Contract_Main_ID#"></span>
		<!--- "DisableObject="#NOT(Is_A_Revision)#"" means - Do not allow user to edit, when there is only one version of the program. --->
			<cf_easydate FormName="frmModifyPreactivePrograms"
			FieldName="txtEndDate_#Contract_Main_ID#_#Child_Contract_Main_ID#"
			Format="mm/dd/yyyy"
			DisableObject="#NOT(Is_A_Revision)#"></td>
		</cfif>
	</tr>

	<input type="hidden" name="IsParent" value="#Is_Parent#">
	<input type="hidden" name="txtOriginalStartDate_#Contract_Main_ID#" value="#Contract_Start_Date#">
	<input type="hidden" name="txtOriginalEndDate_#Contract_Main_ID#" value="#Contract_End_Date#">
	<input type="hidden" name="Contract_Number_Short_Version_#Contract_Main_ID#" value="#Contract_Number_Short_Version#">
	</cfloop>
</table>

<!--- Variable ("Contract_Main_ID_List") gets assigned from the "ProgramSearchFX.cfm". This is the initial list of selected programs imported from the program flex tool.
Note: The user can unselect programs in CF and so the list of selected programs is determined by "SelectedITEMS" checkbox above.
--->
<input type="hidden" name="Contract_Main_ID_List" value="#Contract_Main_ID_List#">
<input type="hidden" name="display_type" value="#display_type#">
</cfoutput>

<cfif qryProgramList.recordcount GT 0>
		<p align="center">
		<span style="color:red;font-weight:bold">[</span> 
		<cfif display_type eq 0>
			<a href="##'" id="id_ModifyDates" onClick="changeStartDates()" style="font-weight:bold;">modify program effective dates</a>
		<cfelseif display_type eq 1>
			<a href="##'" id="id_ModifyDates" onClick="changeEndDates()" style="font-weight:bold;">delete Pre-active version</a>
		</cfif>
		<span style="color:red;font-weight:bold">]</span>
		</p>
</cfif>
</FORM>

<script>
<cfoutput>
function getPreActivePrograms() {
/*
USAGE OF URL VARIABLES BELOW:
1) status:
From program scorecard, We pass the status descriptopn to program flex. This way the flex scorecard automatically filters by program status.
Here by passing "status=Pre-Active", we are filtering for programs in "Preactive" status.

2) Formname:
"Formname=frmModifyPreactivePrograms" is used on "/flex/search/ProgramSearchFx.cfm". When the programs are selected on the prorgam flex tool, the list.
of selected programs is passed back here using the Formname.

3) Fieldname:
"Fieldname=Contract_Main_ID_List". "Contract_Main_ID_List" is the variable to which the selected programs from flex are passed.

4) importlist_type:
"importlist_type=1" is used on the program search tool so that "import selected programs" button is available.

5) display_type
display_type=0 is used to select (focus) the first selected option in the header.
display_type=1 is used to select (focus) the second selected option in the header.
*/
<cfif appSettings.getFlexProgramSearch() EQ 2 OR appSettings.getFlexProgramSearch() EQ 3>
NewWindow("/flex/search/ProgramSearchFx.cfm?status=Pre-Active&Formname=frmModifyPreactivePrograms&Fieldname=Contract_Main_ID_List&importlist_type=1&display_type=#display_type#", 'preactive_programs_search', '800', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
<cfelseif appSettings.getFlexProgramSearch() EQ 4 OR appSettings.getFlexProgramSearch() EQ 5>
NewWindow("/programs/program_search.cfm?scorecard_status=4&Formname=frmModifyPreactivePrograms&Fieldname=Contract_Main_ID_List&importlist_type=1&display_type=#display_type#", 'preactive_programs_search', '800', '600', 'Yes', 'Yes', 'Yes', 'Yes', 'Yes','Yes', true);
</cfif>
}
</cfoutput>
function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.SelectedITEMS;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}
}

/* mass apply dates */
function applyDates(dateType)
{
	var DataFormList = document.forms['frmModifyPreactivePrograms'].elements;	
	var i=DataFormList.length;
	var name_;
	var elem;
	var counter = 0;

	for (var i=0, il= DataFormList.length; i<il; i++){
		elem =DataFormList[i];
		name_ = elem.name;

			if(elem.type=='text' && name_.indexOf(dateType) != -1)
			{
				if(DataFormList.massApplyDates.value != '' && elem.disabled == false)
				{
					if(DataFormList.SelectedITEMS[counter].checked)
					{
					elem.value = DataFormList.massApplyDates.value;
					}
				counter = counter + 1;
				}
			}
	}
}

function changeStartDates()
{
	var ErrorCount = 0;
	var DataFormList = document.forms['frmModifyPreactivePrograms'].elements;	
	var i=DataFormList.length;
	var name_;
	var elem;
	var validEntry = 0;
	var cm_id = 0;
		
		/* Loop through the form. */
		for (var i=0, il= DataFormList.length; i<il; i++){
			elem =DataFormList[i];
			name_ = elem.name;
				
				if(elem.type=='text' && name_.indexOf('txtStartDate') != -1)
				{
					if(elem.value != '')
					{
						/* There is at least one record with a "new start date". */
						validEntry = 1;
					}
			
				/* If the "new start date" is entered for the program version */
				if(elem.value != '')
				{	
					LastDashPosition = name_.indexOf('_');
					cm_id = name_.substring(13, name_.length);

					new_start_date = new Date(elem.value);
					original_end_date = new Date(eval('DataFormList.txtOriginalEndDate_' + cm_id +'.value'));

					if(days_between(original_end_date,new_start_date,1) < 0)
					{
						ErrorCount++;
						queueMessage("The start date cannot be after the end date.", eval('document.all.error_InvalidDate_' + cm_id));
					}
					else
					{
						clearQueue(eval('document.all.error_InvalidDate_' + cm_id));
					}
				} 
			}
		}
	
	<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
	if(ErrorCount == 0 && validEntry == 1)
	{
		document.frmModifyPreactivePrograms.action = "modify_preactive_start_dates_action.cfm";
		document.frmModifyPreactivePrograms.submit();

		/* disable link */
		disableButton('id_ModifyDates', true, false);
	}
	else {
			if(validEntry == 0)
			{
				alert("There should be at least one record with a new start date");
			}
			else{
				showMessageWindow();
			}				
	}
}

function changeEndDates()
{
	var ErrorCount = 0;
	var DataFormList = document.forms['frmModifyPreactivePrograms'].elements;	
	var i=DataFormList.length;
	var name_;
	var elem;
	var counter = 0;
	var cmid = 0;
	var cm_id = 0;
	var validEntry = 0;

	/* Outer loop through the form */
	for (var i=0, il= DataFormList.length; i<il; i++){
		elem =DataFormList[i];
		name_ = elem.name;
			
			if(elem.type=='text' && name_.indexOf('txtEndDate') != -1)
			{
				if(elem.value != '')
				{
					/* There is at least one record with a "new end date". */
					validEntry = 1;
				}
				
				/* If the "new end date" is entered for the program version */
				if(elem.value != '')
				{	
					LastDashPosition = name_.lastIndexOf('_');
					cm_id = name_.substring(11, (LastDashPosition));

					new_end_date = new Date(elem.value);
					original_start_date = new Date(eval('DataFormList.txtOriginalStartDate_' + cm_id +'.value'));

					if(days_between(new_end_date,original_start_date,1) < 0)
					{
						ErrorCount++;
						queueMessage("The end date cannot be before the start date.", eval('document.all.error_InvalidDate_' + cm_id));
					}
					else
					{
						clearQueue(eval('document.all.error_InvalidDate_' + cm_id));
					}

					/* If the program version has a revision (is a parent program) */
					if(DataFormList.IsParent[counter]){
						if(DataFormList.IsParent[counter].value == 1)
						{
							LastDashPosition = name_.lastIndexOf('_');

							/* Get the contract_main_id of the revised program. The Parent program's "fieldname" stores that information. */
							childContractMainID = name_.substring(LastDashPosition + 1, name_.length);
									
									/* Inner loop through the form */
									for (var j=0, jl= DataFormList.length; j<jl; j++){
										innerElem =DataFormList[j];
										innerName_ = innerElem.name;
											
											if(innerElem.type=='text' && innerName_.indexOf('txtEndDate') != -1)
											{
												/* if the revised version of the program does not have a "new end date". */
												if(innerElem.value == '')
												{	
													LastDashPosition = innerName_.lastIndexOf('_');
													cmid = innerName_.substring(11, (LastDashPosition));
													
													/* Find the revised version. */
													if(cmid == childContractMainID)
													{	
														/* If a program version has a revision, then the parent cannot be deleted without deleting the child too.
														The child (if it does not have a revision) can be deleted by itself,
														Note: We are not only dealing with programs in "pre-active" status , but also revisions of programs in pre-active status,
														which when approved will be in pre-active status, but before approval will still be considered a revision.
														*/
														ErrorCount++;
														queueMessage("This version cannot be deleted without deleting it's child versions. The child version(s) are highlighted.", eval('document.all.error_NewDates_' + cmid));
													}
													else
													{
														clearQueue(eval('document.all.error_NewDates_' + cmid));
													}
												}
											}
									}
							}
						}
				}
				counter = counter + 1;
			}
	}

			<!--- SHOW CONFIRMATION BOX IF ALL IS GOOD OR SHOW THE ERROR BOX --->
			if(ErrorCount == 0 && validEntry == 1)
			{
				document.frmModifyPreactivePrograms.action = "modify_preactive_end_dates_action.cfm";
				document.frmModifyPreactivePrograms.submit();

				/* disable link */
				disableButton('id_ModifyDates', true, false);
			}
			else {
					if(validEntry == 0)
					{
						alert("There should be at least one record with a new end date");
					}
					else{
						showMessageWindow();
					}				
			}
}
</script>

<CF_MessageWindow>

</BODY>
</cfmodule>

</HTML>