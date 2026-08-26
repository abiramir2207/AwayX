<!----- program_freight_display_header.cfm ------>
<cfoutput>
<cfset my = structnew()>
<cfif form.command neq "summary" and form.mode neq "summary">

<cfquery name="my.freightLog" datasource="#application.datasource#">
	SELECT Max( Created_Date ) AS Created_Date
	  FROM Log_Program_Distributor_Freight
	 WHERE Program_Id IN ( SELECT Contract_Main_Id
	                         FROM Contract_Main
	                        WHERE Contract_Number = '#qProgramInfo.contract_number#'
	                              AND ( Approved = 1
	                                     OR Deleted = 0 ) -- we want to get any (deleted/non-deleted) approved versions and any non-deleted approved versions
	                      ) 
</cfquery>

<cfif qProgramDistributorFreight.Last_Updated_By neq ""
	or	qProgramInfo.Freight_Approved eq 1
	or	(qProgramInfo.Freight_Approved eq 0 and qProgramInfo.Contract_Status_Type_IDX eq 2)>
	<cfset objUser = CreateObject("component", "components.user.usermanager").init() />
	<table cellpadding="3" cellspacing="0" class="topheader" align="center">
	<tr><td style="border:2px solid orange;" align="center">
	<!----- modified by system - 29665------>
	<cfif my.freightLog.Created_Date neq "">
		Freight was last update on #DateFormat(my.freightLog.Created_Date, "mm/dd/yyyy")# #TimeFormat(my.freightLog.Created_Date, "hh:mm:ss tt")# by System<br>
	</cfif>
	<!----- modified by user ------>
	<cfif qProgramDistributorFreight.Last_Updated_By neq "">
	<cfset lastUpdatedByUserName = objUser.getUserName(qProgramDistributorFreight.Last_Updated_By) />
	Freight was last updated on #DateFormat(qProgramDistributorFreight.Last_Updated_Date, "mm/dd/yyyy")# #TimeFormat(qProgramDistributorFreight.Last_Updated_Date, "hh:mm:ss tt")# by #lastUpdatedByUserName#
	<br>
	</cfif>
	<!----- approved by user ------>
	<cfif qProgramInfo.Freight_Approved eq 1>
	<cfset approvedUpdatedByUserName = objUser.getUserName(qProgramInfo.Freight_Approved_By) />
	Freight was approved on #DateFormat(qProgramInfo.Freight_Approved_Date, "mm/dd/yyyy")# #TimeFormat(qProgramInfo.Freight_Approved_Date, "hh:mm:ss tt")# by #approvedUpdatedByUserName#
	<br>
	</cfif>
	<!----- freight approval required ------>
	<cfif qProgramInfo.Freight_Approved eq 0 and qProgramInfo.Contract_Status_Type_IDX eq 2 and qProgramInfo.Freight_Approval_Required eq 1>
	Pending freight approval
	</cfif>
	</td></tr></table>
</cfif>
</cfif>
<CFQUERY NAME="Get_Settings" datasource="#application.datasource#">
	Select		Volume_UOT_ID
	From		_Users_Settings
	Where		User_ID		=		'#request.AccessStructure.Company_Main_ID#'
</CFQUERY>
<cfset program_Span = Datediff('d', qProgramInfo.Contract_Start_Date, qProgramInfo.Contract_End_Date) + 1>
<cfset ProgVolQty 	= CreateObject("component", "components.programs.volume.ProgramVolume").getProgramQty(qProgramInfo.Contract_Main_ID, program_Span, Get_Settings.Volume_UOT_ID) />
<cfset Program_Qtg_Cases	= ProgVolQty.ProgramQtgCases>
<cfset Program_Qtg_lbs		= ProgVolQty.ProgramQtglbs>
<cfset Volume_UOT_Cases		= ProgVolQty.VolumeUOTCases>
<cfset Volume_UOT_lbs		= ProgVolQty.VolumeUOTlbs>
	<!--- 
			38586: Simplot ENH - Fuel Surcharge Expiring.   CF WORK / Anand Rao / 30-Jul-2013
			-- Send Summarized weekly notification of fuel surcharge expiring
	--->
<br>
<cfif ( (DateFormat(qProgramInfo.Fuel_Surcharge_Expiration_Date,"mm/dd/yyyy") EQ "01/01/1900") OR (DateFormat(qProgramInfo.Fuel_Surcharge_Expiration_Date,"mm/dd/yyyy") EQ "01/01/3900") )>
	<cfset fuelSurchargeExpDate = "">
<cfelse>
	<cfset fuelSurchargeExpDate = qProgramInfo.Fuel_Surcharge_Expiration_Date />
</cfif>	

<div id="mainPane" name="mainPane" style="vertical-align:middle;background:CCFFCC;height:30;padding-left:3;padding-top:3;border-width:1px;">
	<div id="amtPane" name="amtPane" style="vertical-align:middle;float:left;background:CCFFCC;width:30%;height:100%;"> 
				<strong>&nbsp;&nbsp;Fuel Base Amount:</strong> <span id="Err_Fuel_Surcharge_Amount"></span><cfoutput> <strong>$</strong><INPUT TYPE="TEXT" NAME="Fuel_Surcharge_Amount" <CFIF IsDefined("qProgramInfo.Fuel_Surcharge_Amount") and qProgramInfo.Fuel_Surcharge_Amount NEQ 0.00> VALUE="#qProgramInfo.Fuel_Surcharge_Amount#" <CFELSE> VALUE=""</CFIF> onKeyUp="clenseText(this, '0123456789.');allowonlyfourdecimalplaces(this)" style="width:60px;horizontal-align:middle;"></cfoutput> <!---  style="width:60px;height:22" --->
</div>
<div id="rdoPane" name="rdoPane" style="display:table-cell;vertical-align:middle;float:left;background:CCFFCC;width:22%;height:30;"> 
	<strong>Fuel Base Adj.:</strong>	 	<input name="Send_Summarized_Weekly_Notification_Fuel_Surcharge" type="radio" value="1" <cfif qProgramInfo.Fuel_Surcharge_ON EQ 1> CHECKED</cfif> onclick="fnHideFields(this);"> Yes 
		 <input name="Send_Summarized_Weekly_Notification_Fuel_Surcharge" type="radio" value="0" <cfif qProgramInfo.Fuel_Surcharge_ON EQ 0> CHECKED</cfif> onclick="fnHideFields(this);"> No
	</div>
	
		<cfif qProgramInfo.Fuel_Surcharge_ON>
			<cfset display= "block"> 
		<cfelse> 
			<cfset display= "none">
		</cfif>
	<div id="dataPane" name="dataPane" style="float:left;background:CCFFCC;width:48%;display:#display#"  >
		<table width="100%" border="0" borderwidth="0">
			<tr>
				<td width="2%">&nbsp;</td>
				<td align="right" width="48%">
				 <strong>Fuel Base Adj. Expiration:</strong>
				</td>
				<td><span id="Err_Fuel_Surcharge_Expiration_Date"></span></td><td><CF_EASYDATE FORMNAME="ProgramFreightForm" FIELDNAME="Fuel_Surcharge_Expiration_Date" FORMAT="mm/dd/yyyy" DEFAULT="#fuelSurchargeExpDate#">
				</td>
				<td width="2%">&nbsp;</td>
			</tr>
		</table>
	</div>
</div>	
<br>
	<!--- END 38586 --->

<table border="0" cellpadding="0" cellspacing="0" width="100%" class="topheader">
	<tr valign="top">
	<td colspan="2">
		[#qProgramInfo.Contract_Number#] #qProgramInfo.Contract_Title#
	</td>
	<td nowrap>
		<sup class="overrideDisplay">&nbsp;&nbsp;* - overridden</sup>
	</td>
	</tr>

	<tr>
	<td width="40%">
		Span: #DateFormat(qProgramInfo.Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(qProgramInfo.Contract_End_Date, "mm/dd/yyyy")#
	</td>
	<td width="40%" nowrap>
		Quantity:
		#trim(numberformat(round(Program_Qtg_Cases),'___,___,___,___,___,___'))# #request.app_general_functions.getUOMDesc(uomId=1)# / #trim(numberformat(round(Program_Qtg_lbs),'___,___,___,___,___,___'))# #request.app_general_functions.getUOMDesc(uomId=2)#
		<!---#qProgramInfo.Contract_Quantity# #request.app_general_functions.getUOMDesc(uomId=qProgramInfo.Contract_Quantity_UOM_IDX)#--->
	</td>
	<td nowrap>
		Freight Type: #qProgramInfo.Fixed_Type#
	</td>
	</tr>
	<cfif form.command neq "summary" and form.mode neq "summary">
	<!----- program date changes ------>
	<cfif qProgramInfo.Freight_Contract_Start_Date neq "" and qProgramInfo.Freight_Contract_End_Date neq "">
		<cfif datediff("d", qProgramInfo.Contract_Start_Date, qProgramInfo.Freight_Contract_Start_Date) neq 0
			or datediff("d", qProgramInfo.Contract_End_Date, qProgramInfo.Freight_Contract_End_Date) neq 0>
			<cfquery name="my.otherContract" datasource="#application.datasource#">
				SELECT CASE
							WHEN LEN(MAX(revision_version)) = 4 THEN RIGHT('000' + CAST(MAX(revision_version) AS VARCHAR(10)), 4)
							WHEN LEN(MAX(revision_version)) = 5 THEN RIGHT('000' + CAST(MAX(revision_version) AS VARCHAR(10)), 5)
							ELSE RIGHT('000' + CAST(MAX(revision_version) AS VARCHAR(10)), 3)
						END AS Version
				  FROM Contract_Main
				 WHERE Contract_Number = '#qProgramInfo.contract_number#'
				       AND Approved = 1
				       AND Contract_Start_Date = '#qProgramInfo.Freight_Contract_Start_Date#'
				       AND Contract_End_Date = '#qProgramInfo.Freight_Contract_End_Date#'
			</cfquery>

			<tr>
			<td colspan="188%" style="color:red;">
				Span has changed.  Freight was calculated when span was #DateFormat(qProgramInfo.Freight_Contract_Start_Date, "mm/dd/yyyy")# - #DateFormat(qProgramInfo.Freight_Contract_End_Date, "mm/dd/yyyy")#
				<!---29665 - Added another refresh link--->
				<cfif len(my.otherContract.Version) gt 0>(version #my.otherContract.Version#)</cfif>
				<cfif (qProgramInfo.contract_status_type_idx eq 1 OR qProgramInfo.contract_status_type_idx eq 2) and qProgramInfo.Freight_Approved eq 0>
						<!------- refresh freight data --------->
						&nbsp;<CF_smallLink
							title = "refresh freight data"
							url = "##"
							parameters = "onClick=""javascript: return submitForm('refresh-data');return false;"""
						>
					</cfif>
			</td>
			</tr>
		</cfif>
	</cfif>
	</cfif>
</table>
</cfoutput>


