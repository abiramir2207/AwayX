<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<cfparam name="pageTitle" default="Duplicate Program Definition">
<cfparam name="url.DownloadSettings" default=0>

<html>
<head>
<title><cfoutput>#pageTitle#</cfoutput></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<CFSET PAGETITLE = "PROGRAM TEMPLATES: DUPLICATES">
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
	<style>
		TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
		.header {font-size: 12px;padding-left:5px;}
		#oTable tr { line-height:25px; }
	</style>

	<CFINCLUDE TEMPLATE="/get_access_profile.cfm">
	<cfset SPA = CreateObject("component","components.user.settingsPanelAccess").init() />
	<cfset getSPA = SPA.getSPAccess()>

	<CFIF getSPA.Program_Wizard_Index EQ 0>
		<CFLOCATION URL="/Manufacturers/home.cfm" ADDTOKEN="yes">
	</CFIF>

	<cfparam name="form.id" 		default="0">
	<cfparam name="form.nextAction" default="">
	<cfparam name="url.id" 			default="#form.id#"> 
	<cfparam name="Active" 			default="">
	<cfparam name="Action" 			default="">
	<cfparam name="PageName"		default="Duplicate Program">
	<cfparam name="form.Disable_Duplicate_Check_For_Revisions"	default="0">
	<CFPARAM NAME="Generic_Type" DEFAULT="">
	<CFSET GenericType_ID_For_JS = 0>
	<CFIF Generic_Type EQ "Distributor Trade/Shelter" OR Generic_Type EQ "Distributor Off-Invoice">
		<CFSET GenericType_ID_For_JS = 1>
	<CFELSEIF Generic_Type EQ "Operator Direct or HQ Programs" OR Generic_Type EQ "Operator-Deviated Pricing">
		<CFSET GenericType_ID_For_JS = 2>
	<CFELSEIF Generic_Type EQ "Bid Request" OR Generic_Type EQ "Field Execution">
		<CFSET GenericType_ID_For_JS = 3>
	</CFIF>
	<cfset appSettings = application.appSettingsGet />

	<!-- handle form interaction --->
	<script>
		function confirmCompletion()
		{	
			document.all.DupDefInfo.nextAction.value = "save";
			document.all.DupDefInfo.submit();
		}
		function requiredField(count_no, theField, item_no, row_no)
		{
			//this is a date field
			if (count_no == 5) {
				alert("This is a required field.");
				theField.checked = 1;
				}
			var genericType = "<CFOUTPUT>#GenericType_ID_For_JS#</CFOUTPUT>";			
			
			if (genericType == 1 && count_no == 3) {
				alert("This is a required field.");
				theField.checked = 1;
			}			
			else if (genericType == 2 && count_no == 2) {
				alert("This is a required field.");
				theField.checked = 1;
			}
			else if (genericType == 3 && (count_no == 2 || count_no == 3)) 
			{
				if ((count_no == 2 && document.all.chk4.checked == false) || (count_no == 3 && document.all.chk3.checked == false))
				{
					alert("Either <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> or <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> is required.")
					theField.checked = 1;
				}								
			}
			//if unchecked, change all the text to white as the font color 
			var objArray = new Array();
			objArray = findObj(item_no, row_no, 0);
			
			divEle = objArray.pop();
			obj = objArray.pop();

			if (!theField.checked) 
				disAbleEle(obj, divEle);
			else 
				enAbleEle(obj, divEle);
		}
		function requiredFieldN(count_no, theField, item_no, row_no)
		{
			var objArray = new Array();
			objArray = findObj(item_no, row_no, 4);
			divEle = objArray.pop();
			obj = objArray.pop();
			
			if (!theField.checked && item_no != 1 && item_no != 6  && item_no != 9) {
				document.all.item("chk1").checked = 0; 
				document.all.item("chk6").checked = 0; 
				objArray = findObj(5, 3, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
				objArray = findObj(1, 4, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
				objArray = findObj(6, 5, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
				//comment out the relative radio groups 
			}	
			if (document.all.item("chk5").checked) {
				//document.all.item("chk1").checked = 1; 				
				objArray = findObj(5, 3, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				enAbleEle(obj, divEle);
				/*objArray = findObj(1, 4, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				enAbleEle(obj, divEle);*/
			}
			
			/*
			if ( !document.all.item("chk1").checked && document.all.item("chk5").checked) {
				alert("Discount Type could not be unchecked unless Product is unchecked");
				document.all.item("chk1").checked = 1;
				objArray = findObj(1, 4, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				enAbleEle(obj, divEle);
			}
			*/
			if ( document.all.item("chk1").checked && !document.all.item("chk5").checked) {
				alert("Discount Type cannot be checked unless Product is checked");
				document.all.item("chk1").checked = 0;
				objArray = findObj(1, 4, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
			}
			
			if (document.all.item("chk6").checked && (!document.all.item("chk5").checked || !document.all.item("chk1").checked)) {
				alert("Rate cannot be selected unless Product and Discount Type are selected");
				document.all.item("chk6").checked = 0;
				objArray = findObj(6, 5, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
			}
			if (!document.all.item("chk1").checked)
			{
				document.all.item("chk6").checked = 0; 
				objArray = findObj(1, 4, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
				objArray = findObj(6, 5, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);			
			}
			else
			{
				objArray = findObj(1, 4, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				enAbleEle(obj, divEle);
			}
			if (document.all.item("chk6").checked) {
				objArray = findObj(6, 5, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				enAbleEle(obj, divEle);				
			}
			else
			{
				objArray = findObj(6, 5, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
			}
			/* If it is a component */
			if (document.all.item("chk9").checked)
			{
				objArray = findObj(9, 2, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				enAbleEle(obj, divEle);	
			}
			else
			{
				objArray = findObj(9, 2, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);	
			}
				/* If it is Lump Sum Amount */
			if (document.all.item("chk11").checked)
			{
				objArray = findObj(11, 6, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				enAbleEle(obj, divEle);	
			}
			else
			{
				objArray = findObj(11, 6, 4);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);	
			}
		}
		
		function disAbleEle(obj, divEle)
		{	
			// obj.style.backgroundColor  = "#A9A9A9";
			divEle.style.color  = "gray";	
		}
		
		function enAbleEle(obj, divEle)
		{
			obj.style.backgroundColor  = "#FFFFFF";
			divEle.style.color = "black";	
		}
		
		function findObj(item_no, row_no, cell_no )
		{
			obj_array = new Array();
			obj = document.all.oTable.rows(row_no).cells(cell_no);
			obj_array.push(obj);
			divID = "div_sub" + item_no;
			divEle = document.getElementById(divID );
			obj_array.push(divEle);
			return (obj_array);
		}
	</script>
	
	
	
	<cfif isDefined("url.action")>
		<cfset Action = url.action>
	</cfif>
	
	<cfif Not isDefined("ID")>
		<cfset ID = url.id>
	</cfif>
	<cfif isDefined("url.id")>
		<cfset templateManager = CreateObject("component","components.programs.template.TemplateManager").init() />
		<cfset template = templateManager.get(url.id)>
		<cfset dupTemplateManager = CreateObject("component","components.programs.template.DuplicateTemplateManager").init(url.id,trim(PageName)) />
		<cfset currentDuplicateDef = dupTemplateManager.getDupProgramDefinition() >
		<cfset currentDuplicateDefItemDetails = dupTemplateManager.getCurrDuplicateDefItemDetail() >
	</cfif>
	
	<cfset pageName = "dup_program_def">
	
	<cfif UCase(form.nextAction) EQ "SAVE">
		<cfset dupStructure = StructNew()>
		<cfloop query="currentDuplicateDef">
			<cfparam name="chk#item#" default="0">
			<cfparam name="form.#item#" default="#item#-0">
			<cfset item_checked = Evaluate("chk#item#") >
			<cfset itemRadioArray = ListToArray(Evaluate("form.#item#"), "-")>
			<cfset item_key = "#sort_order#-#item#-#itemRadioArray[2]#-#item_checked#">
			<cfset dupStructure[item_key] = ArrayNew(1)>
			<cfset dupStructure[item_key][1] = itemRadioArray[2]>
		</cfloop>
		<!--- insert into the dup template table--->
		<cfset dupStructure.programcontrol_Panel_Options_ID = ID>
		<cfset dupStructure.page_id = form.pageID >
		<cfset dupTemplateManager.saveTemplateInfo(dupStructure)>
		<cfset dupTemplateManager.saveTemplateDuplicateCheckInfo(ID,form.Disable_Duplicate_Check_For_Revisions)>
		
		<!------ Redirect to next page ----->		
		<cfinclude template="Next_Page.cfm" />
		
	</cfif>
	
	<cfif isDefined("url.id")>
		<!--- reorg this part of code --->
		<cfif Action IS "Edit">
			<cfset Active = template.getActive()>
			<cfset Created_Type = template.getCreatedType()>
		</cfif>

		<cfinclude template="header.cfm">
		<!--- retrieve item information, item, default radio index, default value is supposed to set when saving basic info--->
		<!---loop through definition to set up the template page--->
		<cfset dupStruc = structNew()>
		<cfset itemKeyArray = ArrayNew(1) > 
		<!--- loop through definition summary list to get item arrays --->
		<cfparam name="itemList" default="">

		<cfloop query="currentDuplicateDef">
			<!--- get the radio index from definition --->
			<cfset newsort_order = sort_order />
			<cfif sort_order GT 9>
				<cfset newsort_order = "9" & sort_order />
			</cfif>
			<cfparam name="form.#item#" default="#Item#-#Item_Radio_Index#">
			<cfset itemKeyArray[Item] = "#newsort_order#-#Item#-#Item_Name#-#Item_Type#-#isChecked#" >
			<cfset dupStruc[itemKeyArray[Item]] = ArrayNew(1) >
			<cfset itemList = listAppend(itemList, item)>
		</cfloop>

		<!-- loop through definition item list to get item radio description --->
		<!--- for definition item details --->
		<cfloop query="currentDuplicateDefItemDetails">
			<cfscript>
					ArrayAppend(dupStruc[itemKeyArray[Item]], Item_Desc);
			</cfscript>
		</cfloop>

		<form action="Dup_Program_Def.cfm" method="post" name="DupDefInfo">

	<cfif LockedBy_Current_User EQ 1>
		<DIV align="right" style="width:90%;"> <!--- margin-top:-10px; --->
			<CF_button
			button_name		=	""
			button_caption	=	"save and continue"
			button_action	=	"confirmCompletion();"
			button_type		=	"javascript_link"
			button_width	=	"250"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</DIV>
	</cfif>	
		<table  id="oTable" align="center" cellspacing="10" cellpadding="0" border="0" width="95%" <cfif url.DownloadSettings>style="display:none;"</cfif>>
			<cfif url.DownloadSettings>
				<cfset SettingsToExcel (Setting_Name='Disable Duplicate Check For Revisions', Setting_Field_Name='Disable_Duplicate_Check_For_Revisions',SetAsDefault='N/A', Page='3')>	
			<cfelse>
				<tr><td><img src="/images/clear.gif" width="2" height="8"></td></tr>
				<tr>
					<td valign="top">
					<table width="450" cellpadding="0" cellspacing="0" border="0" class="maintable2">
						<tr bgcolor="#F0F8FF"> 
							<td><input type="checkbox" name="Disable_Duplicate_Check_For_Revisions" value="1" <cfif template.Disable_Duplicate_Check_For_Revisions>checked</cfif>></td>
							<td><strong><div class="header">&nbsp;&nbsp;Disable Duplicate Check For Revisions</div></strong></td>
						</tr>
					</table>
					</td>
				</tr>
			</cfif>
		<!--- loop through the keys of dupStruc --->
		<cfif Not StructIsEmpty(dupStruc)>
		<!--- pls don't sort --->
			<cfset dupKeyArray = StructKeyArray(dupStruc)>
			<cfset ArraySort(dupKeyArray,"textnocase","asc") />
			<cfset leftKeyCount = ArrayLen(dupKeyArray) mod 2 >
			<cfset count = 1>
			<cfset row_no = 2 >
			<!--- This code could handle only even number of Keys before. Now it handles for both --->
			<cfif ArrayLen(dupKeyArray) MOD 2 eq 0>
				<cfset averageKeyCount = ArrayLen(dupKeyArray) / 2>
			<cfelse>
				<cfset averageKeyCount = ceiling(ArrayLen(dupKeyArray) / 2)>
			</cfif>
			<!--- not handling left keys at this time--->
			<cfloop index="i" from="1" to="#averageKeyCount#" step="1">
				<!--- item key is based on the following format:"Sort_Order-Item-Item_Name-Item_Type"--->
				<cfset itemKey = dupKeyArray[i]>
				<cfset itemArray = ListToArray(itemKey, "-")>
		
				<cfset item = itemArray[2]>
				<cfset item_name = itemArray[3]>
				<cfset item_type = itemArray[4]>
				<cfset item_isChecked = itemArray[5]>
				<cfif item_type EQ "check">
					<cfset item_type = "checkbox">
				</cfif>
			<cfparam name="chk#item#" default="1">

	<!--- If Not (there are an odd number of keys and it is the last entry). --->
			<cfif NOT (ArrayLen(dupKeyArray) MOD 2 neq 0 AND i eq averageKeyCount)>
				<cfset itemNKey = dupKeyArray[i+averageKeyCount]>
				<cfset itemNArray = ListToArray(itemNKey, "-")>
				<cfset itemN = itemNArray[2] >
				<cfset itemN_name = itemNArray[3]>
				<cfset itemN_type = itemNArray[4]>
				<cfset itemN_isChecked = itemNArray[5]>
				<cfif itemN_type EQ "check">
					<cfset itemN_type = "checkbox">
				</cfif>
				<cfparam name="chk#itemN#" default="1">
			</cfif>
				<!--- Since Spending category(item - 8) has only one option, there is no need of this extra checkbox 
					Generic_Type EQ "LSAutoPay"  is restricted from the Item 8 Spending Category--->
				<tr>
					<td valign="top">
						<table id="oTable_sub<cfoutput>#item#</cfoutput>" width="450" cellpadding="0" cellspacing="0" border="0" class="maintable2">
							<tr bgcolor="#F0F8FF"> 
								<td align="left">
								<!--- set the check value: not done yet --->
									<cfoutput><input type="checkbox" name="chk#item#" id="chk#item#" onClick="requiredField(#count#, this, #item#, #row_no#);" value="1" <cfif Evaluate("chk#item#") EQ item_isChecked AND NOT (Generic_Type EQ "LSAutoPay" AND item eq "8") >checked</cfif> <CFIF appSettings.getOperatingGroupOn() NEQ 1 AND item EQ 8 OR (Generic_Type EQ "LSAutoPay" AND item eq "8")>Disabled</CFIF>></cfoutput>
								</td>
								<td><cfoutput><strong><div id="div_sub#item#" class="header"><CFIF (appSettings.getOperatingGroupOn() NEQ 1 AND item EQ 8)><FONT COLOR="Gray">#trim(item_name)#</FONT><CFELSE>#trim(item_name)#</CFIF></div></strong></cfoutput>
										<cfif url.DownloadSettings>
											<cfset Setting_Value = 'No'>
											<cfif Evaluate("chk#item#") EQ item_isChecked AND NOT (Generic_Type EQ "LSAutoPay" AND item eq "8") >
												<cfset Setting_Value = 'Yes'>
											</cfif>
											<cfset SettingsToExcel (Setting_Name='#trim(item_name)#', Setting_Field_Name='chk#item#', SetAsDefault='N/A', Setting_Value='#Setting_Value#', Page='3')>	
										</cfif>
								</td>
								<td width="100">&nbsp;</td>
								<td width="25">&nbsp;</td>					
							</tr>
							<tr>
								<td colspan="3" align="right" <CFIF (appSettings.getOperatingGroupOn() NEQ 1 AND item EQ 8)>BGCOLOR2="A9A9A9"</CFIF>><cfif item neq "8">Selected<cfelse>&nbsp;</cfif></td>
								<td width="25">&nbsp;</td>					
							</tr>
							<div id="div<cfoutput>#item#</cfoutput>">
								<!--- radio/checkbox option --->
								<cfloop index="j" from="1" to="#ArrayLen(dupStruc[itemKey])#" step="1">
									<cfset thisArray = dupStruc[itemKey] >
									<tr <CFIF (appSettings.getOperatingGroupOn() NEQ 1 AND item EQ 8)>BGCOLOR2="A9A9A9"</CFIF>>
										<td width="15">&nbsp;</td>
										<td align="left"><cfoutput>#thisArray[j]#</cfoutput></td>
										<!--- radio/checkbox--->
										<td align="right"><cfif item neq "8"><input name=<cfoutput>"#item#"</cfoutput> id=<cfoutput>"#item#"</cfoutput> type=<cfoutput>"#item_type#"</cfoutput> <cfif Evaluate("form.#item#") EQ "#item#-#j#">checked</cfif> value=<cfoutput>"#item#-#j#"</cfoutput> <CFIF (appSettings.getOperatingGroupOn() NEQ 1 AND item EQ 8) OR (Generic_Type EQ "LSAutoPay" AND (item eq "8"))>Disabled</CFIF>><cfelse>&nbsp;</cfif></td>
										<td width="25">
										&nbsp;
										<cfif url.DownloadSettings>
											<cfset Setting_Value = 'No'>
											<cfif Evaluate("form.#item#") EQ "#item#-#j#">
												<cfset Setting_Value = 'Yes'>
											</cfif>
											<cfset SettingsToExcel (Setting_Name='#thisArray[j]#', Setting_Field_Name='#item#', Setting_Value='N/A', SetAsDefault='#Setting_Value#', Page='3')>	
										</cfif>
										</td>					
									</tr>
								</cfloop>
							</div>
						</table>
					</td>

					<td valign="top">
					<!--- If Not (there are an odd number of keys and it is the last entry). --->
						<cfif NOT (ArrayLen(dupKeyArray) MOD 2 neq 0 AND i eq averageKeyCount)>
						<table <CFIF (Generic_Type NEQ "LSAutoPay" AND itemN eq "11")>style="visibility:hidden"</CFIF> id="oTable_sub<cfoutput>#itemN#</cfoutput>" width="500" cellpadding="0" cellspacing="0" border="0" class="maintable2">
							<tr bgcolor="#F0F8FF">
								<td class="header" align="left">
									<cfoutput><input type="checkbox" name="chk#itemN#" id="chk#itemN#" value="1" onClick="requiredFieldN(#count#, this, #itemN#, #row_no#);" <cfif Evaluate("chk#itemN#") EQ itemN_isChecked AND ((Generic_Type EQ "LSAutoPay" AND itemN eq "11") OR (Generic_Type NEQ "LSAutoPay" AND itemN Neq "11")) >checked</cfif> <CFIF itemN EQ 1>ReadOnly</CFIF><CFIF (Generic_Type EQ "LSAutoPay" AND itemN Neq "11") OR (Generic_Type NEQ "LSAutoPay" AND itemN eq "11")> Disabled</CFIF>></cfoutput>
								</td>
								<td height="20"><cfoutput><strong><div id="div_sub#itemN#" class="header">#itemN_name#</div></strong></cfoutput>
										<cfif url.DownloadSettings>
											<cfset Setting_Value = 'No'>
											 <cfif Evaluate("chk#itemN#") EQ itemN_isChecked AND ((Generic_Type EQ "LSAutoPay" AND itemN eq "11") OR (Generic_Type NEQ "LSAutoPay" AND itemN Neq "11")) >
												<cfset Setting_Value = 'Yes'>
											</cfif>
											<cfset ShowHide='Show'>
											<CFIF (Generic_Type NEQ "LSAutoPay" AND itemN eq "11")>
												<cfset ShowHide='Hide'>
											</CFIF>
											<cfset SettingsToExcel (Setting_Name='#itemN_name#', Setting_Field_Name='chk#itemN#', SetAsDefault='N/A', Setting_Value='#Setting_Value#', ShowHide='#ShowHide#', Page='3')>	
										</cfif>
								</td>
								<td width="100">&nbsp;</td>
								<td width="25">&nbsp;</td>						
							</tr>
							<!--- Since Component, Discount Type, Rate and LS Dollars have only one option(itemN - 6,1,9,11), there is no need of this extra checkbox 
									Item 5 rate is the only one that needs the radio select. Generic_Type EQ "LSAutoPay" is the only type taht can select "Lump Sum Dollars".
									Generic_Type EQ "LSAutoPay" is restricted from the other items 6,1,9 and 8 (from the other half of display) as well.--->
							<tr>
								<td colspan="3" align="right"><cfif itemN eq "5">Selected<cfelse>&nbsp;</cfif></td>
								<td width="25">&nbsp;</td>					
							</tr>
							<div id="div<cfoutput>#itemN#</cfoutput>">
								<cfloop index="j" from="1" to="#ArrayLen(dupStruc[itemNKey])#" step="1">
									<cfset thisArray = dupStruc[itemNKey] >
									<tr>
										<td width="15">&nbsp;</td>
										<td align="left"><cfoutput>#thisArray[j]#</cfoutput></td>
										<!--- radio/checkbox--->
										<td align="right"><cfif (itemN eq "5") AND (Generic_Type NEQ "LSAutoPay")><input name=<cfoutput>"#itemN#"</cfoutput> id=<cfoutput>"#itemN#"</cfoutput> type=<cfoutput>"#itemN_type#"</cfoutput> <cfif Evaluate("form.#itemN#") EQ "#itemN#-#j#">checked</cfif> value=<cfoutput>"#itemN#-#j#"</cfoutput> ><cfelse>&nbsp;</cfif></td>
										<td width="25">&nbsp;</td>					
										<cfif url.DownloadSettings>
											<cfset Setting_Value = 'No'>
											<cfif Evaluate("form.#itemN#") EQ "#itemN#-#j#">
												<cfset Setting_Value = 'Yes'>
											</cfif>
											<cfset ShowHide='Show'>
											<CFIF (Generic_Type NEQ "LSAutoPay" AND itemN eq "11")>
												<cfset ShowHide='Hide'>
											</CFIF>
											<cfset SettingsToExcel (Setting_Name='#thisArray[j]#', Setting_Field_Name='#itemN#', Setting_Value='N/A', SetAsDefault='#Setting_Value#',  Is_Child_Of='chk#itemN#', ShowHide='#ShowHide#', Page='3')>	
										</cfif>
									</tr>
								</cfloop>	
							</div>
							</cfif>
						</table>
					</td>
				</tr>

				<cfset count = count + 1>
				<cfset row_no = row_no + 1>
			</cfloop>
		</cfif>
		</table>
		<input type="hidden" name="nextAction" id="nextAction" value=<cfoutput>"#form.nextAction#"</cfoutput>>
		<input type="hidden" name="ID" id="ID" value="<cfoutput>#ID#</cfoutput>">
		<input type="hidden" name="PageID" id="ID" value="<cfoutput>#dupTemplateManager.getPageId()#</cfoutput>">
		<!--- action list --->
		<BR><BR>
		<cfif LockedBy_Current_User EQ 1>
		<DIV align="center">
			<CF_button
			button_name		=	""
			button_caption	=	"save and continue"
			button_action	=	"confirmCompletion();"
			button_type		=	"javascript_link"
			button_width	=	"250"
			button_color	=	"Navy"
			button_tip		=	"save and continue"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</DIV>
		</cfif>	
		</form>
	</cfif>
	<cfset count = 0>
	<cfset row_no = 2>
	<cfloop query="currentDuplicateDef">

		<cfif isChecked EQ 0>	
			<script>
				var cell_no;
				<cfwddx action = "CFML2JS" input = "#item#" topLevelVariable = "item_js" >
				<cfwddx action = "CFML2JS" input = "#row_no#" topLevelVariable = "row_no_js" >
				
				if (item_js == 7)
				{
					row_no_js = 2;//2
					cell_no = 0;
				}
				else if (item_js == 3)
				{
					row_no_js = 3;//3
					cell_no = 0;
				}
				else if (item_js == 4)
				{
					row_no_js = 4;//4
					cell_no = 0;
				}
				else if (item_js == 10)
				{
					row_no_js = 5;//5
					cell_no = 0;
				}
				else if (item_js == 8)
				{
					row_no_js = 6;//6
					cell_no = 0;
				}
				else if (item_js == 2)
				{
					row_no_js = 7;//6
					cell_no = 0;
				}
				else if (item_js == 9)
				{
					row_no_js = 2;//2
					cell_no = 4;
				}
				else if (item_js == 5)
				{
					row_no_js = 3;//3
					cell_no = 4;
				}
				else if (item_js == 1)
				{
					row_no_js = 4;//4
					cell_no = 4;
				}
				else if (item_js == 6)
				{
					row_no_js = 5;//5
					cell_no = 4;
				}
				else if (item_js == 11)
				{
					row_no_js = 6;//6
					cell_no = 4;
				}
				
				/*
				if (row_no_js > 5)
					{
						row_no_js = row_no_js - 3;
						cell_no = 4;
					}
				else
					cell_no = 0;*/
				objArray = new Array();
				objArray = findObj(item_js, row_no_js, cell_no);
				divEle = objArray.pop();
				obj = objArray.pop();
				disAbleEle(obj, divEle);
				//requiredField(count_js, eleObj, item_js, row_no_js);
			</script> 
		</cfif>
		<cfset count = count + 1>
		<cfset row_no = row_no + 1>		
	</cfloop>

  <cfif LockedBy_Current_User NEQ 1>
    <cfinclude template="/common_files/jQuery.cfm">
    <script>
 	    $("#oTable input[type!=hidden]").attr("disabled", "disabled");
    </script>
  </cfif>
	
</body>
</html>


