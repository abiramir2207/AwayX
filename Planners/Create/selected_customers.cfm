<!----------------------------------------------------------------------------------
Name         :  AwayX/Planners/Create/selected_customers.cfm
Copyright    :  (c) 2022 Blacksmith Applications, Inc.
Created Date :  23-Feb-2022
Created By   :  Anand Rao
Description  :  Screen for displaying the selected alternate customer groups and
				indvidual customers.
---------------------------------------------------------------------------------->

<cfparam name="variables.pgmThinDisplayIsAttachement" 	default="0">
<cfset local.programID = URL.programID />
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
	
<html>
<head>
	<title>Selected customer group</title>
</head>

<body>
<form action="" method="post" name="frmSelectedDist" id="frmSelectedDist">
<cfset CSL_Contract_Main_ID = local.programID />
<cfinclude template="/Common_Files/contracts/commonqueries.cfm" />
<cfset _Setting_Display_Distributor_ID = appSettings.get_Setting('Display_Distributor_ID') />		
<cfset displayGroupANDIndividual = 1>		
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />
<cfif businessSegManager.isEnabledForDistributor()>
	<cfset businessSegmentsOn = 1 />
<cfelse>	
	<cfset businessSegmentsOn = 0 />
</cfif>
<cfif NOT IsDefined("GenProgramManager")>
	<cfset GenProgramManager = CreateObject("component", "components.programs.programManager").init() />
</cfif>
<cfset ViewProgramManager = CreateObject("component", "components.programs.Display_Program.viewprogramtemplateManager") />
<cfset DistGroupManager = CreateObject("component", "components.programs.distributors.DistributorGroupManager").init() />
<cfset altCustomerOn = 1 />
<cfset getDistributors = ViewProgramManager.getDistributors(Contract_Main_ID=URL.programID, businessSegmentsOn=businessSegmentsOn, Specify_Distributor_Groups=DistGroupManager.ProgramDistributorIsGroup(URL.programID), displayGroupANDIndividual=displayGroupANDIndividual, altCustomerON=altCustomerOn)>
<cfset getDistributorExceptions = ViewProgramManager.getDistributorExceptions(CSLGetContractInfo.Contract_Main_ID)>
<cfset ProgramFreightOn = GenProgramManager.GetIsProgramFreightOn(CSLGetContractInfo.contract_main_id)>
<cfoutput>

<cfif getDistributors.recordcount EQ 0>
	<br><br><div align="center"><font color="red"><b>No records to display!</b></font></div><br>
</cfif>
<cfif getDistributors.recordcount GT 0>
	<cfif ((find("1","#valuelist(getDistributors.is_Group)#") GTE 1) OR (find("true","#valuelist(getDistributors.is_Group)#") GTE 1) )>
		<cfset distGroupLevelTypeIDs = valueList(getDistributors.Distributor_Group_Level_ID) />
		<cfquery name="qGetDistGrpLevelType" datasource="#application.datasource#">
			SELECT Distributor_Group_Level_ID,Group_Level_Desc FROM Distributor_Group_Level WHERE Distributor_Group_Level_ID IN (#distGroupLevelTypeIDs#)
		</cfquery>
		<cfquery name="getDistributors2"  dbType = "query">
 			SELECT qGetDistGrpLevelType.*, getDistributors.* 
			FROM getDistributors,qGetDistGrpLevelType  
			WHERE getDistributors.Distributor_Group_Level_ID = qGetDistGrpLevelType.Distributor_Group_Level_ID 
		</cfquery>
		<cfset getDistributors = getDistributors2 />
	</cfif>
</cfif>

<cfif getDistributors.recordcount GT 0>
<table border="0" cellpadding="0" cellspacing="0" width="870">	
	<tr>
		<td colspan="2">
		<br><b><font size="2" color="navy">Selected <cfif GetSettings.Allow_Vendor_Only EQ 1>#variables.VendorLabel#s<cfelse>#application.returned_customer_setting.distributor_label_plural#</cfif></font></B>&nbsp: Count = #getDistributors.recordcount# <a href="##" id="toggleDistributors" style="margin-left:5px;"></a> &nbsp; <cfif (URL.bEdit EQ 1)><a href="##" onclick="javascript:deleteAllAltDists();">#application.util.string.actionLinkFormat2("Delete all #application.returned_customer_setting.distributor_label_plural#")#</a></cfif>&nbsp;&nbsp;<a href="downloadAltCustomers.cfm?programID=#CSLGetContractInfo.contract_main_id#">#application.util.string.actionLinkFormat2("Download XL")#</a>&nbsp;&nbsp;<cfif appSettings.get_Setting('Custom_RFP_Process',0) EQ 1 and GetSettings.RFP_Process EQ 1>
			<cfscript>
			 		oRFP		= CreateObject("component", "mvc.Models.Program.RfpManager");
			        q = oRFP.getFreightDataQuery(CSLGetContractInfo.Contract_Main_ID);	
			</cfscript>
			<cfquery name="SetMatrix" dbtype = "query">
					Select * from q where fixed_component_type IN (8,9) 
			</cfquery>
			<cfif setMatrix.recordcount GT 0 && session.Get_Profile_Settings.RFP_Freight_FOB_Delivered_View_Create GT 0><a  href="####" id="rfpfreight" name="rfpfreight" title="Choose FOB or Delivered Pricing"onClick="CreateRFPFreight();">#application.util.string.linkFormat("FOB / Delivered")#</a></cfif>
		</cfif>
		<hr color="Navy">
		<cfif getDistributorExceptions.RECORDCOUNT GT 0><span id="distributorInclusionsHeading" style="font-size:11px;font-weight:bold;color:navy;">#application.returned_customer_setting.distributor_label_singular# Inclusions</span></cfif>
			<table id="eligibleDistributors" cellspacing="3" cellpadding="3" width="100%">
				<cfif getDistributors.RecordCount GT 0>
					<cfloop query="getDistributors">
						<cfif getDistributors.Is_Group eq 1>
							<cfset this.profileId = "#getDistributors.BSA_Foodservice_Customers_ID#&Distributor_Group_Level_ID=#getDistributors.Distributor_Group_Level_ID#&Is_Group=1&programId=#CSLGetContractInfo.Contract_Main_ID#" />
						<cfelse>
							<cfset this.profileId = getDistributors.BSA_Foodservice_Customers_ID />
						</cfif>
						 <td class="dataStyle" width="33%" valign="top" bgcolor="F2F2F2" <cfif NOT isDefined("URL.action_type")> style="cursor: help;" onmouseover="menuID=3;URLstring='';an_ID='#this.profileId#';doNotRelocate=1;" onmouseout="menuID=0;" </cfif>> 
							 <span><font size="1"> 
								<!--- If fixed price freight is on --->
								<cfif (getDistributors.is_group EQ 1)>
									<strong>#getDistributors.Group_Level_Desc#::</strong>
								</cfif>
								<cfif (NOT variables.pgmThinDisplayIsAttachement) AND (ProgramFreightOn eq 1) AND (Get_Profile_Settings.Approve_Freight_Programs OR Get_Profile_Settings.Freight_View_Create NEQ 0) AND ProgramDistributorFreightCount eq 1 AND ProgramFreightComponentType neq 0>
								   <a href="##" onclick="NewWindow('/common_files/contracts/Contract_Fixed_Freight_details.cfm?ProgramID=#CSLGetContractInfo.Contract_Main_ID#&Distributor_ID=#URLEncodedFormat(getDistributors.BSA_Foodservice_Customers_ID)#','viewfreight','850','600','Yes', 'Yes');" style="color:000000"> 
									#trim(getDistributors.Name)#<cfif _Setting_Display_Distributor_ID eq '1' AND Len(Shr_Ship_To)>(#trim(Shr_Ship_To)#)<cfelseif (_Setting_Display_Distributor_ID eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND Len(Ship_To)>(#trim(Ship_To)#)</cfif></a>
								<cfelseif getsettings.Discount_Fixed_Prices_Freight EQ 1 >
									 <a href="##" onclick="NewWindow('/common_files/contracts/Contract_Fixed_Customer_Rates.cfm?ProgramID=#CSLGetContractInfo.Contract_Main_ID#&Distributor_ID=#URLEncodedFormat(getDistributors.BSA_Foodservice_Customers_ID)#','viewfreight','850','600','Yes', 'Yes');" style="color:000000">
									#trim(getDistributors.Name)#<cfif _Setting_Display_Distributor_ID eq '1' AND Len(Shr_Ship_To)>(#trim(Shr_Ship_To)#)<cfelseif (_Setting_Display_Distributor_ID eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND Len(Ship_To)>(#trim(Ship_To)#)</cfif></a>
								<cfelse>
								  #trim(getDistributors.Name)#<cfif _Setting_Display_Distributor_ID eq '1' AND Len(Shr_Ship_To)>(#trim(Shr_Ship_To)#)<cfelseif (_Setting_Display_Distributor_ID eq '0' OR appSettings.get_Setting('Display_Item_No') eq '') AND Len(Ship_To)>(#trim(Ship_To)#)</cfif>
								</cfif>
								<cfif Distributor_Group_Level_ID EQ 1>
									<cfset distCount = DistGroupManager.getDistributorGroupDistributorCount(Distributor_Group_Level_ID, Distributor_Group_ID) />(#distCount# #application.returned_customer_setting.distributor_label_plural#)
								</cfif>
								<cfif getDistributors.CITY NEQ "" AND getDistributors.STATE NEQ "">
									<br>#trim(getDistributors.City)#, #getDistributors.State# #trim(getDistributors.zipcode)#
								</cfif>
								<cfif appSettings.get_Setting('GPO_One_Page_Program_Creation') EQ 1 AND GetDiscountIdentifier.Discount_Identifier_Number EQ "CPA">
									
										<a  href="####" id="custPDF"
												name="custPDF" title="Create a Distributor PDF"
												onClick="CreateCpaDistPDF('#getDistributors.BSA_Foodservice_Customers_ID#');">
										<img src="/images/PDF_Icon.gif" align="middle" border="0" height="15" width="12"/></a>
									
								</cfif>
								 </font></span></TD>
						<cfif getDistributors.currentRow MOD 3><cfelse></tr><tr></cfif>
					</cfloop>
				<cfelse>
					<td align="center"><b><font color="Red">NONE SUPPLIED</font></b></td>
				</cfif>
			</table>
 	
</cfif>	
<input type="hidden" name="delAllClicked" id="delAllClicked" value="0">
<input type="hidden" name="Contract_Main_ID" id="Contract_Main_ID" value="#CSLGetContractInfo.Contract_Main_ID#">
<input type="hidden" name="plannerID" id="plannerID" value="#URL.plannerID#">
<br>
<div align="center">
<a href="##" onclick="javascript:refreshAndCloseAltCust();">#application.util.string.actionLinkFormat2("Close Window")#</a>
</div>
</cfoutput>		
</form>

</body>
<script language="javascript">
function deleteAllAltDists()
{
	var confirmdelete = confirm("Click OK to permanently delete all the data. You won't be able to undo this change...");
	if (confirmdelete == true)
	{
		document.getElementById("delAllClicked").value = "1";
		<cfoutput>
		document.getElementById('frmSelectedDist').action = "/Planners/Create/planner_alternate_customers.cfm?CID=#URL.CID#&plannerID=#URL.plannerID#&bEdit=#URL.bEdit#";
		document.getElementById('frmSelectedDist').target = "_top";
		</cfoutput>
		this.frmSelectedDist.submit();
	}
}
function refreshAndCloseAltCust(){
	self.parent.opener.document.MyForm.bLoadVolumeFromDB.value = "1"
	parent.opener.document.MyForm.submit();
	parent.refreshAndCloseAltCustMain();
}
</script>
</html>
