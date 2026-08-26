<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Profile Settings History Viewer</title>
<STYLE TYPE="text/css">
		.subButton
		{
			font-size: 11px;
			WIDTH: 65px;
			background-color : transparent;
			color : blue;
			border-style : none none none none;
			font-weight : bold;
			border-color : Black Black Black Black;
		}
		.subButtonOver
		{
			font-size: 11px;
			WIDTH: 65px;
			background-color : transparent;
			color : red;
			border-style : none none none none;
			font-weight : bold;
			text-decoration : underline;
			cursor:pointer;
		}
</STYLE>
</head>

<body onload="window.focus()">
<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<cfset wdata = 50>
<cfset wrow = 225>

<!--- create lists used for display loop tlist is for tables taht have one recoed per profile...tlist2 is for tables with manuy entries per profile--->
<cfset tList2 = "">
<cfset tList2 = tlist2 & "Profiles|Profiles_ID">
<cfset tList2 = tlist2 & ",Profiles_Settings|Profiles_ID">
<cfset tList2 = tlist2 & ",BB_Profiles_Settings|Profiles_ID">


<!--- add the profile key into list 2...we need to query dbase on profile setting --->
<!--- <cfset tList2 = ""> --->
<cfset tList2 = tlist2 & ",Profile_LS_Approval|Profiles_ID">
<cfset tList2 = tlist2 & ",Margin_Group_Profile_Approval_Margins|PROFILE_ID">
<cfset tList2 = tlist2 & ",Group_Approval_Rights|USER_PROFILE_ID">

		<!--- Operating Group --->
<cfif appSettings.getOperatingGroupOn()>
	<cfset tList2 = tlist2 & ",Operating_Group_Profile_Map|PROFILES_ID">
</cfif>
		<!--- deductions --->
<!---<cfif application.deductionLinksAvailable> --->  
<cfif application.appSettingsGet.getDeduction_Module()>
  <cfset tList2 = tlist2 & ",Deductions_Profiles_Settings|PROFILES_ID">
</cfif>
		<!--- customer type --->
<cfset UseCustomerType = appSettings.getCustomertype()>
<cfif UseCustomerType IS 1>
  <cfset tList2 = tlist2 & ",Profile_Customer_Type_Settings|PROFILES_ID">
</cfif>	


<cfparam name="form.LogId" default="0">
 <cfquery datasource="#application.datasource#" name="qGetLogDetails">
		SELECT     *
		FROM       Profiles_Settings_Log PSL
		INNER JOIN	_users U 
					on PSL.user_id = U.user_id 
		where PSL.log_id = '#form.logid#'
</cfquery>

 <cfquery datasource="#application.datasource#" name="qGetProfilesLog">
		SELECT	Name_first,
				Name_last,
				PSL.created_date,
				Log_id
		FROM	Profiles_Settings_Log PSL
		INNER JOIN	_users U 
					on PSL.user_id = U.user_id 
		Order by created_date desc
</cfquery> 
<cfif not isdefined("form.submit")>
<cfform name="ProfLog" action="Profiles_settings_log_viewer.cfm">
<table>
<tr><td colspan="2">Select a change record to view the profile settiings in XL:</td></tr>
<tr>
	<td><cfselect name="LogId" >
			<option value="">Select an Update</option>
			<cfoutput query="qGetProfilesLog">
				<option value="#qGetProfilesLog.Log_id#" style="color : black;" <cfif form.logid eq qGetProfilesLog.Log_id>selected</cfif>>#qGetProfilesLog.Name_last#&nbsp;<strong>::</strong>&nbsp;#dateformat(qGetProfilesLog.created_date,"M-D-YY")#&nbsp;<strong>::</strong>&nbsp;#timeformat(qGetProfilesLog.created_date,"HH:MM:SS")#
			</cfoutput>
		</cfselect>
	</td>
	<td>&nbsp;<FONT COLOR="Red" style="font-weight : bold; font-size: 12px;">[</FONT>&nbsp;<input type="Submit" value="View Log" name="submit" class="subbutton"onmouseover="this.className='subbuttonover'" onmouseout="this.className='subbutton'">&nbsp;<FONT COLOR="Red" style="font-weight : bold;font-size: 12px;">]</FONT></td>
</tr>
</table><br>
</cfform>
<cfelse>
<cfheader name="Content-Disposition" value="attachment;filename=Profiles_log.xls"><cfcontent type="application/msexcel">

	<STYLE TYPE="text/css">
		.subButton
		{
			font-size: 11px;
			WIDTH: 65px;
			background-color : transparent;
			color : blue;
			border-style : none none none none;
			font-weight : bold;
			border-color : Black Black Black Black;
		}
		.subButtonOver
		{
			font-size: 11px;
			WIDTH: 65px;
			background-color : transparent;
			color : red;
			border-style : none none none none;
			font-weight : bold;
			text-decoration : underline;
			cursor:pointer;
		}
		.tablestuff
		{
			border-left-width : 1px;
			border-left-color : Black;
			border-left-style : solid;
			border-top-width : 1px;
			border-top-color : Black;
			border-top-style : solid;
			border-right-style : solid;
			border-right-color : Black;
			border-right-width : 1px;
			border-bottom-width : 1px;
			border-bottom-style : solid;
			border-bottom-color : Black;
		}
		.tabledata
		{
			border-left-width : 1px;
			border-left-color : Black;
			border-left-style : solid;
			border-top-width : 1px;
			border-top-color : Black;
			border-top-style : solid;
			border-right-style : solid;
			border-right-color : Black;
			border-right-width : 1px;
			border-bottom-width : 1px;
			border-bottom-style : solid;
			border-bottom-color : Black;
			background-color : Yellow;
		}
		.tablehead
		{
			border-left-width : 1px;
			border-left-color : Black;
			border-left-style : solid;
			border-top-width : 1px;
			border-top-color : Black;
			border-top-style : solid;
			border-right-style : solid;
			border-right-color : Black;
			border-right-width : 1px;
			border-bottom-width : 1px;
			border-bottom-style : solid;
			border-bottom-color : Black;
			background-color : Silver;
		}
</STYLE>
	<cfoutput query="qGetLogDetails">

		<table cellspacing="0" cellpadding="1">
			<tr>
				<td colspan="100%"><font size="3" color="##000000">#qGetLogDetails.Name_First# #qGetLogDetails.Name_last# edited on #dateformat(qGetLogDetails.created_date,"M-D-YY")#&nbsp;::&nbsp;#timeformat(qGetLogDetails.created_date,"hh:mm:ss tt")#</font></td>
			</tr>	
		<!--- LIST 2 for Tables that have multi rows for each id	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
		<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
			
			<tr>
				<td>
					<cfloop list="#tlist2#" index="tName">
						<table class="tablestuff" cellpadding="5" cellspacing="0" bgcolor="transparent">
							<cfsilent>
						 	   <cfset tkey =	gettoken(tname,2,"|")>
								<cfset tname =	gettoken(tname,1,"|")>	
								<CFWDDX action="WDDX2CFML" INPUT="#evaluate(tname)#" OUTPUT="profStruct">
								<CFSET theColumnList = evaluate("profStruct.#tname#.columnlist")>
								<CFSET theCount = evaluate("profStruct.#tname#.recordcount")>
							</cfsilent>
						<cfif tkey neq "" and isDefined("profStruct.#tname#.#tkey#")>
							 <cfset IDlist =  evaluate("profStruct.#tname#.#tkey#")>
							
							<!--- @@ #theCount# @@ --->
							<tr>
								<td bgcolor="##FF0000" class="tablestuff"><strong><font size="3">#replace(tname,"_"," ","all")#</font></strong></td>
								
						<cfloop list="#theColumnList#" index="col">
							<!--- <tr> ---><!--- do not need to display these ...need better way to handle --->
							<cfif col neq tkey and col neq "deleted" and col neq "GROUP_APPROVAL_RIGHTS_ID" and not col CONTAINS "user_id" and not col CONTAINS "created_date" and not col CONTAINS "updated_date" and col neq "PROFILES_SETTINGS_ID">
								<CFSET theValList = evaluate("profStruct.#tname#.#col#")>
								
								<td class="tablehead"><strong>#replace(col,"_"," ","all")#</strong><!--- <br>#theValList#<br> ---></td>
								<cfset "#col#" = ListToArray(theValList)><!--- #ArrayLen(evaluate(col))# --->
							</cfif>
						</cfloop>
							</tr>
						
							
							<cfloop list="#idlist#" index="theVal">
							    <cfset i = gettoken(theVal,2,"|")>
								<cfset theProfVal = gettoken(theVal,3,"|")>
								<cfset theVal = gettoken(theVal,1,"|")>
										<cfsilent>
										    <!--- <cfset idIndex = gettoken(id,2,"|")>
										 	<cfset id = gettoken(id,1,"|")> --->
											<cfquery datasource="#application.datasource#" name="gGetProf">
														SELECT Profiles_Short_Desc from Profiles
														where -- deleted = 0 and 
														profiles_id = '#theProfVal#'
											</cfquery>
										</cfsilent>
							   <tr>
							      <td class="tablehead">&nbsp;<strong>#gGetProf.Profiles_Short_Desc#&nbsp;(#theProfVal#)<!--- &nbsp;^^^#i#^^^#theProfVal# ---></strong></td>
								  <cfloop list="#theColumnList#" index="col">
										<!--- <tr> ---><!--- do not need to display these ...need better way to handle --->
										<cfif col neq tkey and col neq "deleted" and col neq "GROUP_APPROVAL_RIGHTS_ID" and not col CONTAINS "user_id" and not col CONTAINS "created_date" and not col CONTAINS "updated_date" and col neq "PROFILES_SETTINGS_ID">
										<CFSET theValList = evaluate("profStruct.#tname#.#col#")>
										<CFSET data =  evaluate("#col#[#i#]")>
										<CFSET rec =  gettoken(data,2,"|")>
										<CFSET prof =  gettoken(data,3,"|")>
										<CFSET data =  gettoken(data,1,"|")>
								  <td <cfif (#i# MOD 2) is 0>class="tabledata"<cfelse>class="tablestuff"</cfif>>&nbsp;#data#<!--- &nbsp;^^^#rec#^^^#prof# ---></td>
								  <!--- <tr bgcolor="###Iif(((qDataArch.CurrentRow MOD 2) is 0),de('FFFFFF'),de('EAFFEA'))#"> --->
								        </cfif>
								  </cfloop>
								</tr>
							</cfloop>
			
							</tr>
						</cfif>
						
						</table><br>
					</cfloop>
				</td>
			</tr>
			
		<!--- LIST 2 for Tables that have multi rows for each id	XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->
		<!--- XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX --->		
			
			
		</table>

	</cfoutput>
</cfif>

</body>
</html>
