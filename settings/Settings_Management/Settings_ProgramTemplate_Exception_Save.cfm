<!----
/settings/Settings_Management/Settings_ProgramTemplate_Exception_Save.cfm
Created By: Jane
Created On: Sep 10, 2010
Modified By:
Last Modified On: 
--->

<CFPARAM NAME="GetCurrentSetting_Display_Value.Setting_Display_Value" 	DEFAULT=1>
<CFPARAM NAME="GetCurrentSetting_Display_Value.recordcount" 	DEFAULT=0>
<CFPARAM NAME="FORM.Exception_First_Parent_ID_List" 	DEFAULT="">
<CFPARAM NAME="FORM.StatusSave" 	DEFAULT="0">
<CFPARAM NAME="FORM.Setting_ID" 	DEFAULT="0">
<CFPARAM NAME="FORM.Generic_Type" 	DEFAULT="">
<CFPARAM NAME="FORM.SettingDisplayValueInTable" 	DEFAULT="">
<CFPARAM NAME="FORM.SettingDisplayValueInTableID" 	DEFAULT="0">
<cfoutput>

<!--- Copy Settings_Template_Display to Settings_Template_Display_History  ---> 
<cfquery name="CopyOverToHistory" datasource="#application.datasource#">
	insert into  Settings_Template_Display_History(Settings_Template_Display_ID,Generic_Type,Generic_Type_ID,Setting_Display_Value,Deleted,Deleted_Date,Excluded_First_Parent_ID,Updated_Date,Updated_By,Setting_Display_Value_InTable)
	select 	Settings_Template_Display_ID,Generic_Type,Generic_Type_ID,Setting_Display_Value,Deleted,Deleted_Date,Excluded_First_Parent_ID,Updated_Date,Updated_By,Setting_Display_Value_InTable
	from 	Settings_Template_Display
	where 	deleted = 0
	and 	Generic_Type = '#Form.Generic_Type#' 
	<cfif #Form.Setting_ID# GT 0 >
		and Setting_ID = '#Form.Setting_ID#'	
	<cfelse>
	and 	Setting_Display_Value_InTable = '#FORM.SettingDisplayValueInTable#'
	and 	Setting_Display_Value_InTable_ID = '#FORM.SettingDisplayValueInTableID#'
	</cfif>
	and Excluded_First_Parent_ID > 0
	and Excluded_First_Parent_ID IS NOT NULL
</cfquery>

<CFQUERY NAME="DeleteTemplateException" datasource="#application.datasource#">
		delete from  Settings_Template_Display
		where Generic_Type = '#Form.Generic_Type#'
		<cfif #Form.Setting_ID# GT 0 >
			and Setting_ID = '#Form.Setting_ID#'
		<cfelse>
			and Setting_Display_Value_InTable = '#FORM.SettingDisplayValueInTable#'
			and Setting_Display_Value_InTable_ID = '#FORM.SettingDisplayValueInTableID#'
		</cfif>
		and Excluded_First_Parent_ID > 0
		and Excluded_First_Parent_ID IS NOT NULL
</CFQUERY>

<cfif FORM.StatusSave EQ 1 and FORM.Exception_First_Parent_ID_List NEQ "">
	<CFSET FORM.Exception_First_Parent_ID_List = Trim(FORM.Exception_First_Parent_ID_List)>
	<cfif find(",",#FORM.Exception_First_Parent_ID_List#) EQ 0>
		<cfset arrFirst_Parent_ID =ArrayNew(1)>
		<cfset arrFirst_Parent_ID[1] ="#FORM.Exception_First_Parent_ID_List#">
	<cfelse>
		<cfset arrFirst_Parent_ID = ListToArray(FORM.Exception_First_Parent_ID_List)>
	</cfif>
	<cfloop index="LoopCount" from="1" to="#arrayLen(arrFirst_Parent_ID)#">
	      <cfif #Form.Setting_ID# GT 0 >
		<CFQUERY NAME="InsertTemplateExceptions" datasource="#application.datasource#">
			INSERT INTO Settings_Template_Display
			(Generic_Type, Excluded_First_Parent_ID,Setting_ID,Updated_By)
			VALUES
			('#Form.Generic_Type#', '#arrFirst_Parent_ID[LoopCount]#',#Form.Setting_ID#,'#request.AccessStructure.User_ID#');
		</CFQUERY>
	     <cfelse>
		<CFQUERY NAME="InsertTemplateExceptions" datasource="#application.datasource#">
			INSERT INTO Settings_Template_Display
			(Generic_Type, Excluded_First_Parent_ID,Setting_ID,Updated_By,Setting_Display_Value_InTable,Setting_Display_Value_InTable_ID)
			VALUES
			('#Form.Generic_Type#', '#arrFirst_Parent_ID[LoopCount]#',#Form.Setting_ID#,'#request.AccessStructure.User_ID#','#Form.SettingDisplayValueInTable#','#Form.SettingDisplayValueInTableID#');
		</CFQUERY>		
	      </cfif>
	</cfloop>
</cfif>
</cfoutput>
<CFLOCATION URL="Settings_ProgramTemplate_Exception.cfm?Generic_Type=#Form.Generic_Type#&Setting_ID=#Form.Setting_ID#&Setting_Name=#Setting_Name#&SettingDisplayValueInTable=#Form.SettingDisplayValueInTable#&SettingDisplayValueInTable=#Form.SettingDisplayValueInTableID#" ADDTOKEN="No">
