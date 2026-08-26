 <!---      
			 Name:          renewable_programs.cfm               
			 Copyright:     Copyright (c) 2006 Blacksmith Applications, Inc.       
			 Created Date:  03/21/2006
			 Created By:    Milan Mushran
			 Description:   This page show all the programs set for auto-renewal
			 Parameters:    ShowExcel (If the report needs to be exported to Excel)     
			 Usage:         renewable_programs.cfm
--->

 <style type="text/css">
	.heading{ 	
		font-family: verdana,arial,helvetica; font-size: 11px;font-weight: bold;background: #FFB062;
		}
	.PageContent{ 		
		font-family:Verdana, Arial, Helvetica, sans-serif;font-size:9px;
		}
	TD.UNDERLINED{		
		border-bottom: 1px solid #7575FF;font-family:Verdana, Arial, Helvetica, sans-serif;font-size:10px;
		}
	TR.highlight TD.UNDERLINED{		
		background-color: #EAFFEA;
		}
	TR.nothighlight TD.UNDERLINED{  
		border-bottom: 1px solid #7575FF;
		}
	</style>

<cfparam name="ShowExcel" default="0">

<cfquery name="GetAutoRenewablePrograms" datasource="#application.datasource#">
SELECT DISTINCT Contract_main.Contract_Number as Program_Number,
	Contract_main.Contract_title as Program_Name, 
	Program_Control_panel_Options.Created_Type as Template_Type,
	Contract_main.Contract_Start_Date as Start_Date,
	Contract_main.Contract_End_Date as End_Date,
	Contract_Status_Types.Contract_Status_Type_Desc as Status_Description,
	Program_Auto_Renew.AR_Notification_Date as Auto_Renew_Date,
	_Users.Name_First+' '+Name_Last as RSP

FROM Contract_main 

LEFT OUTER JOIN Program_Control_panel_Options ON
Contract_main.ProgramType_ID = Program_Control_panel_Options.ProgramControl_panel_Options_ID
AND Program_Control_panel_Options.Deleted =0 

LEFT OUTER JOIN Program_Auto_Renew ON
Contract_Main.Contract_Main_ID = Program_Auto_Renew.Program_ID
AND Program_Auto_Renew.Deleted = 0
AND	Program_Auto_Renew.Active = 1

LEFT OUTER JOIN Contract_Status_Types ON
Contract_Status_Types.Contract_Status_Type_ID = Contract_main.Contract_Status_Type_IDX

LEFT OUTER JOIN _Users ON
Contract_main.Responsible_User_ID = _Users.User_ID
AND _Users.Deleted = 0

WHERE Contract_main.deleted = 0
AND Program_Auto_Renew.Renewed = 0
ORDER BY Auto_Renew_Date,Program_Number
</cfquery>

<cfoutput>
<div align="right">
	<a href="#cgi.SCRIPT_NAME#?ShowExcel=1" style="font-family: verdana,arial,helvetica;font-weight:bold;"><span style="font-weight:bold;color:red">[</span>Export to Excel<span style="font-weight:bold;color:red">]</span></a>
</div>
</cfoutput>

<!--- If the Report type is an Excel File, prompt the user to open or save the file --->
<cfif ShowExcel eq "1">
		<cfcontent type="application/unknown">
		<cfheader name="Content-Disposition" value="attachment;filename=Renewable_Programs.xls">
</cfif>

<!--- HTML Report --->
<cfif ShowExcel eq "0">
<div align="center" style="font-family: verdana,arial,helvetica;font-weight:bold;fony-size: 11px;">
	LIST OF PROGRAMS FOR AUTO RENEWAL
</div>
<br />

<table align="center" width="100%" class="PageContent" border="0" cellspacing="0">
	<tr>
		<td class="heading">Program ID</td>
		<td class="heading">Description</td>
		<td class="heading">Start Date<br />End Date</td>
		<td class="heading">Status</td>
		<td class="heading">Template Type</td>
		<td class="heading">RSP</td>
		<td class="heading">Renew Date</td>
	</tr>
	<cfoutput query="GetAutoRenewablePrograms">
	<tr onmouseover="this.className='highlight'" onmouseout="this.className='nothighlight'">
		<td width="10%" class="underlined">#Program_Number#</td>
		<td width="30%" class="underlined">#Program_Name#</td>
		<td width="10%" class="underlined">#DateFormat(Start_Date, "MM/DD/YYYY")#<br />#DateFormat(End_Date,"MM/DD/YYYY")#</td>
		<td width="15%" class="underlined"><cfif Status_Description neq "">#Status_Description#<cfelse>&nbsp;</cfif></td>
		<td width="15%" class="underlined">#Template_Type#</td>
		<td width="10%" class="underlined"><cfif RSP neq "">#RSP#<cfelse>&nbsp;</cfif></td>
		<td width="10%" class="underlined"><cfif Auto_Renew_Date neq "">#DateFormat(Auto_Renew_Date, "MM/DD/YYYY")#<cfelse>&nbsp;</cfif></td>
	</tr>
	</cfoutput>
</table>

<cfelse>

<!--- Excel Report (No need for style sheet here. I also seperated the Start Date and End date values, so that these values 
			can be sorted in Excel) --->
<table align="center" width="100%" border="0" cellspacing="0">
	<tr>
		<td><b>Program ID</b></td>
		<td><b>Description</b></td>
		<td><b>Start Date</b></td>
		<td><b>End Date</b></td>
		<td><b>Status</b></td>
		<td><b>Template Type</b></td>
		<td><b>RSP</b></td>
		<td><b>Renew Date</b></td>
	</tr>

	<cfoutput query="GetAutoRenewablePrograms">
	<tr>
		<td width="10%">#Program_Number#</td>
		<td width="30%">#Program_Name#</td>
		<td width="10%">#DateFormat(Start_Date, "MM/DD/YYYY")#</td>
		<td width="10%">#DateFormat(End_Date,"MM/DD/YYYY")#</td>
		<td width="15%"><cfif Status_Description neq "">#Status_Description#<cfelse>&nbsp;</cfif></td>
		<td width="15%">#Template_Type#</td>
		<td width="10%"><cfif RSP neq "">#RSP#<cfelse>&nbsp;</cfif></td>
		<td width="10%"><cfif Auto_Renew_Date neq "">#DateFormat(Auto_Renew_Date, "MM/DD/YYYY")#<cfelse>&nbsp;</cfif></td>
	</tr>
	</cfoutput>
</table>
</cfif>

