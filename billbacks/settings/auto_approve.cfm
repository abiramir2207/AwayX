<!---
***********************************************************************
Created By: Tim Ford
File Path: /billbacks/settings/auto_approve.cfm
Created Date: 1/28/2010
Description: This file is responsible for modifying billback auto approve settings
***********************************************************************
--->
<cfset useLakebaseForGetBBAutoApproveLogic = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_application_settings")>
<cfif useLakebaseForGetBBAutoApproveLogic>
	<cftry>
		<cfset GetBBAutoApproveLogic = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_application_settings", {
				"select" = "custom_auto_approve_type"
			}), "custom_auto_approve_type"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBAutoApproveLogic = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBAutoApproveLogic>
<cfquery name="GetBBAutoApproveLogic" datasource="#application.datasource#">
select Custom_Auto_Approve_Type
from _Application_Settings
</cfquery>
</cfif>

<cfparam name="form.Operator_List" 						default="" />
<cfparam name="form.Distributor_List" 					default="" />
<cfparam name="form.firstTimeLoading" 					default="1" />
<cfparam name="form.blnSubmit" 							default="0" />
<cfparam name="form.AutoApprove_not_allowed"		 	default="0" />
<cfparam name="form.rdo_Auto_Approve_BB_Types"			default="" />
<cfparam name="form.Auto_Approve_Amount"				default="" />
<cfparam name="form.Auto_Approved_BB_Status"			default="" />
<cfparam name="form.Auto_Appr_Reference_Exclusive"		default="0" />
<cfparam name="form.Auto_Appr_Consider_Created_Date"	default="0" />
<cfparam name="form.Auto_Appr_Age"						default="0" />
<cfparam name="form.Auto_Appr_Divested_Items"			default="0" />
<cfparam name="form.Auto_Appr_Unknown_Items"			default="0" />
<cfparam name="form.Auto_Appr_Payee_Operator"			default="0" />
<cfparam name="form.Auto_Appr_Payee_Distributor"		default="0" />
<cfparam name="form.Auto_Approve_Dummy_Prog"			default="0" />
<cfparam name="form.AutoApproveCMOFF"					default="0" />

<cfif (GetBBAutoApproveLogic.Custom_Auto_Approve_Type EQ 2)>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
	<span style="font-size:12px;color:red;text-align:center;width:100%;padding-top:25px;">
	Based on Program's Discount Identifier -
	Only third party billbacks (CBS) in RFA status that are processed through auto deviation will be auto approved
	</span>
	<cfabort />
</cfif>


<cfif form.blnSubmit eq 1>
	<cfinclude template="auto_approve_save.cfm" />
	<cfabort />
</cfif>
	
<!--- Added two fields  Auto_Approve_BB_Types, Auto_Approved_BB_Status to the select --->
<cfquery name="GetAutoApproveFromBillbacks" datasource="#application.datasource#">
	SELECT	Auto_Approve_On,
			Auto_Approve_Amount,
			Auto_Approve_Updated_Date,
			Auto_Approve_BB_Types,
			Auto_Approved_BB_Status,
			Auto_Appr_Reference_Exclusive,
			Auto_Appr_Consider_Created_Date,
			ISNULL(Auto_Appr_Age, '') AS Auto_Appr_Age,
			Auto_Appr_Divested_Items,
			Auto_Appr_Unknown_Items,
			Auto_Appr_Payee_Operator,
			Auto_Appr_Payee_Distributor,
			_Users.Name_First,
			_Users.Name_Last,
			Auto_Approve_Dummy_Prog,
			Auto_Approve_CM_OFF
	FROM 	Billback_Settings
			LEFT JOIN _Users ON 
			_Users.User_ID = Billback_Settings.Auto_Approve_Updated_By
</cfquery>
	
<cfif form.firstTimeLoading eq 1>
	
	<cfset useLakebaseForqGetDistributorList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_appr_payee_exception")>
<cfif useLakebaseForqGetDistributorList>
	<cftry>
		<cfset qGetDistributorList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("auto_appr_payee_exception", {
				"payee_type" = "eq.1",
				"select" = "distributor_id"
			}), "distributor_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetDistributorList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetDistributorList>
<cfquery name="qGetDistributorList" datasource="#application.datasource#">
		SELECT	DISTINCT Distributor_ID
		FROM	Auto_Appr_Payee_Exception
		WHERE	Payee_Type = 1
	</cfquery>
</cfif>
	
	<cfset useLakebaseForqGetOperatorList = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("auto_appr_payee_exception")>
<cfif useLakebaseForqGetOperatorList>
	<cftry>
		<cfset qGetOperatorList = application.oLakebase.toQuery(
			application.oLakebase.selectRows("auto_appr_payee_exception", {
				"payee_type" = "eq.2",
				"select" = "operator_id"
			}), "operator_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForqGetOperatorList = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForqGetOperatorList>
<cfquery name="qGetOperatorList" datasource="#application.datasource#">
		SELECT	DISTINCT Operator_ID
		FROM	Auto_Appr_Payee_Exception
		WHERE	Payee_Type = 2
	</cfquery>
</cfif>
	
	<cfset form.Operator_List					= valueList(qGetOperatorList.Operator_ID) />
	<cfset form.Distributor_List				= valueList(qGetDistributorList.Distributor_ID) />
	<cfset form.Auto_Approve_Amount				= GetAutoApproveFromBillbacks.Auto_Approve_Amount />
	<cfset form.Auto_Approve_Updated_Date		= GetAutoApproveFromBillbacks.Auto_Approve_Updated_Date />
	<cfset form.rdo_Auto_Approve_BB_Types		= GetAutoApproveFromBillbacks.Auto_Approve_BB_Types />
	<cfset form.Auto_Approved_BB_Status			= GetAutoApproveFromBillbacks.Auto_Approved_BB_Status />
	<cfset form.Auto_Appr_Reference_Exclusive	= GetAutoApproveFromBillbacks.Auto_Appr_Reference_Exclusive />
	<cfset form.Auto_Appr_Consider_Created_Date	= GetAutoApproveFromBillbacks.Auto_Appr_Consider_Created_Date />
	<cfset form.Auto_Appr_Age					= GetAutoApproveFromBillbacks.Auto_Appr_Age />
	<cfset form.Auto_Appr_Divested_Items		= GetAutoApproveFromBillbacks.Auto_Appr_Divested_Items />
	<cfset form.Auto_Appr_Unknown_Items			= GetAutoApproveFromBillbacks.Auto_Appr_Unknown_Items />
	<cfset form.Auto_Appr_Payee_Operator		= GetAutoApproveFromBillbacks.Auto_Appr_Payee_Operator />
	<cfset form.Auto_Appr_Payee_Distributor		= GetAutoApproveFromBillbacks.Auto_Appr_Payee_Distributor />
	<cfset form.Auto_Approve_Dummy_Prog			= GetAutoApproveFromBillbacks.Auto_Approve_Dummy_Prog />
	<cfset form.AutoApproveCMOFF 				= GetAutoApproveFromBillbacks.Auto_Approve_CM_OFF />
	<cfif (GetAutoApproveFromBillbacks.Auto_Approve_On EQ 1)>
		<cfset form.AutoApprove_not_allowed			= 0 />
	<cfelse>
		<cfset form.AutoApprove_not_allowed			= 1 />
	</cfif>
</cfif>

<cfoutput>
<cfif len(trim(form.Operator_List))>

	<cfquery name="qGetOperators" datasource="#application.datasource#">
		SELECT	*
		FROM	BSA_Operator
		WHERE	BSA_Operator_ID IN (#form.Operator_List#)
	</cfquery>

</cfif>
				
<cfif len(trim(form.Distributor_List))>

	<cfquery name="qGetDistributors" datasource="#application.datasource#">
		SELECT	*
		FROM	BSA_Foodservice_Customers
		WHERE	BSA_Foodservice_Customers_ID IN (#listQualify(form.Distributor_List, "'", ",", "ALL")#)
	</cfquery>
</cfif>
	
	
<CFQUERY NAME="qGetBillbackStatus" DATASOURCE="#Application.Datasource#">
	SELECT	Billback_Status_ID,
			BB_Status_Description
	FROM	Billback_Status
	WHERE 	Billback_Status_ID IN (3,4,5)
	ORDER BY Status_Order_Number
</CFQUERY>


<CFSET PAGETITLE = "BILLBACKS: AUTO APPROVE SETTINGS">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>#PAGETITLE#</TITLE>
<script src="/script/javascript/string_functions.js" language="JavaScript"></script>
<script src="/Common_Files/Delete_Functions.js"></script>
<script type="text/javascript" src="/script/tTip.js"></script>
<link rel="stylesheet" href="/styles/tTip.css" type="text/css" />
<script language="javascript">
	
	function deleteThisEntry(FieldNameRe, entryID, entryType)
	{
		var operLabel = '<cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>';
		var distLabel = '<cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>';
		var trObj = document.getElementById("TR_" + FieldNameRe);
		var trIndex = trObj.rowIndex;
		var bDelete = true;
		var label, finalList, resultString, inputObj;
		
		if(entryType == 'oper')
		{
			inputObj	= document.all.Operator_List;
			label		= operLabel;
		}
		else
		{
			inputObj	= document.all.Distributor_List;
			label		= distLabel;
		}
		
		finalList	= inputObj.value;
		resultString = ListDeleteItem(finalList, ",", entryID);
		
		if(resultString == finalList)
		{
			resultString = ListAppendItem(finalList, ",", entryID);
			bDelete = false;
		}
		
		inputObj.value = resultString;

		if(trObj)
		{
			var srcObj = event.srcElement;
			if(bDelete)
			{ 
				propogateProperty(trObj, "style.backgroundColor", "##CCCCCC", false);
				propogateProperty(trObj, "style.textDecoration", "line-through", true);
				srcObj.title = "undo " + label + " deletion";
				srcObj.src = undodeleteImg.src;
			}
			else
			{				
				var bgCol = "Whitesmoke";
				propogateProperty(trObj, "style.backgroundColor", bgCol, false);
				propogateProperty(trObj, "style.textDecoration", "none", false);
				srcObj.title = "delete this " + label;
				srcObj.src = deleteImg.src;
			}
		}				
		event.cancelBubble = true;
	}
</script>
</HEAD>
<BODY BGCOLOR="Whitesmoke" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red">
<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/settings/settings_title.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<TABLE BGCOLOR="White" style="border-color:Orange;border-style:solid;" CELLPADDING="3" CELLSPACING="0">
	<TR>
	<TD>
	<FONT SIZE="2"><B>This setting was last updated on <CFOUTPUT>#dateformat(GetAutoApproveFromBillbacks.Auto_Approve_Updated_Date, 'm/d/yyy')# #timeformat(GetAutoApproveFromBillbacks.Auto_Approve_Updated_Date, 'h:mm:ss TT')#</CFOUTPUT> by <CFOUTPUT>#GetAutoApproveFromBillbacks.Name_First# #GetAutoApproveFromBillbacks.Name_Last#</CFOUTPUT></B></FONT>
	</TD>
	</TR>
  </TABLE>
<BR>
<FORM action="auto_approve.cfm" METHOD="post" NAME="autoApproveForm">

<!--- 
	START: D44693: Reinhart AutoMatch Inquiry/ Anand Rao / 07-Jan-2015
--->
<cfif  GetBBAutoApproveLogic.Custom_Auto_Approve_Type EQ 1>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	
	<tr>
		<th colspan="100%" align="left">
			<font color="navy">Billback Auto Approve</font>
		</th>
	</tr>
	
	<tr>
		<td colspan="2">
		<BR>
		<BR>
		</td>
	</tr>

<TR>
		<TD>
		<span onmouseout="popUpTip(event,'tOpenHelp');" onmouseover="popUpTip(event,'tOpenHelp');"> <B>Do not allow Auto-Approve:</B>:  <img src="/images/help_small.gif" />  </span>
</td>
<td>&nbsp;<div id="tOpenHelp" class="tip">When the application setting "BB Auto Approve Logic" is set to "Based on Closing Method" then the auto approve job will include both EDI and User Uploaded billbacks.   Even though below setting is set to 'Uploaded Billbacks Only', both EDI and User Uploaded billbacks are included in auto approve.</div>
		  
 
		 

		</TD>
		<TD>
			<INPUT TYPE="Checkbox" NAME="AutoApproveCMOFF" VALUE="1" <cfif form.AutoApproveCMOFF EQ 1>checked</cfif> >
		</TD>
	</TR>
	<tr>
    	<td colspan="100%">
      		<input type="Radio" name="rdo_Auto_Approve_BB_Types" value="1" <cfif form.rdo_Auto_Approve_BB_Types EQ 1>checked</cfif> checked>Uploaded billbacks only
       		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      		<input type="Radio" name="rdo_Auto_Approve_BB_Types" value="2" disabled >Manually created billbacks only
     		 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      		<input type="Radio" name="rdo_Auto_Approve_BB_Types" value="3" disabled>Both
   		 </td>
  </tr>

<table cellpadding="3" cellspacing="0" border="0">
	<tr>
		<td valign="bottom" style="border-bottom:none">
			<strong>Auto Approve User Upload Billbacks by #application.returned_customer_setting.operator_label_singular#:</strong>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Payee_Operator" type="checkbox" value="1" onClick="javascript:enableException(this);" <cfif form.Auto_Appr_Payee_Operator eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td colspan="100%" style="border-top:none">
			<div id="operatorExceptions" <cfif form.Auto_Appr_Payee_Operator neq 1>style="display:none"</cfif>>
				<CF_openLayer
					Border="Yes"
					BorderSize="1"  
					BorderColor="orange"  
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="Include for the following #application.returned_customer_setting.operator_label_singular# payees"  
					TitleClosed="Include for the following #application.returned_customer_setting.operator_label_singular# payees"  
					TitleTooltip="Click to Show/Hide"  
					TitleFont="font"  
					TitleColor="Blue"  
					TitleSize="9"  
					IsClosed="No"  
					Width="100%">
					
					<CF_button
						button_name		=	""
						button_caption	=	"select #lcase(application.returned_customer_setting.operator_label_plural)#"
						button_action	=	"operatorSearch()"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						class			=	"NotMaintable">
					<br>
					<!---/////////////////////////////// Operator List /////////////////////////////////--->
					<cfif len(trim(form.Operator_List)) and qGetOperators.RecordCount>
					<table>
						<cfloop query="qGetOperators">
						<tr>
							<td id="TR_oper_#BSA_Operator_ID#" STYLE="cursor: pointer;" NOWRAP>
								<img id="theImage"  style="cursor: pointer;" onClick="deleteThisEntry('oper_#BSA_Operator_ID#','#BSA_Operator_ID#', 'oper');" src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0" />&nbsp;
								#Operator_Name#&nbsp;<cfif len(Legacy_ID)>#Legacy_ID#<cfelse>#BSA_Operator_ID#</cfif>
							</td>
						</tr>
						</cfloop>
					</table>
					</cfif>
				</CF_openLayer>
			</div>
		</td>
	</tr>
</table>
<br><br>
<table cellpadding="3" cellspacing="0" border="0">
	<tr>
		<td valign="bottom" style="border-bottom:none">
			<strong>Auto Approve User Upload Billbacks by #application.returned_customer_setting.distributor_label_singular#:</strong>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Payee_Distributor" type="checkbox" value="1" onClick="javascript:enableException(this);" <cfif form.Auto_Appr_Payee_Distributor eq 1>checked</cfif> />
		</td>
	</tr>
		<tr>
		<td colspan="100%" style="border-top:none">
			<div id="distributorsExceptions" <cfif form.Auto_Appr_Payee_Distributor neq 1>style="display:none"</cfif>>
				<CF_openLayer
					Border="Yes"
					BorderSize="1"  
					BorderColor="orange"  
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="Include for the following #application.returned_customer_setting.distributor_label_singular# payees"  
					TitleClosed="Include for the following #application.returned_customer_setting.distributor_label_singular# payees"  
					TitleTooltip="Click to Show/Hide"  
					TitleFont="font"  
					TitleColor="Blue"  
					TitleSize="9"  
					IsClosed="No"  
					Width="100%">
					
					<CF_button
						button_name		=	""
						button_caption	=	"select #lcase(application.returned_customer_setting.distributor_label_plural)#"
						button_action	=	"distributorSearch()"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						class			=	"NotMaintable">
					<br>
					<!---/////////////////////////////// Distributor List /////////////////////////////////--->
					<cfif len(trim(form.Distributor_List)) and qGetDistributors.RecordCount>
					<table>
						<cfloop query="qGetDistributors">
						<tr>
							<TD id="TR_dist_#BSA_Foodservice_Customers_ID#" STYLE="cursor: pointer;" NOWRAP>
								<img id="theImage"  style="cursor: pointer;" onClick="deleteThisEntry('dist_#BSA_Foodservice_Customers_ID#','#BSA_Foodservice_Customers_ID#', 'dist');" src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0" />&nbsp;
								#Name#&nbsp;#Ship_To#
							</td>
						</tr>
						</cfloop>
					</table>
					</cfif>
				</CF_openLayer>
			</div>
		</td>
	</tr>
</table>
<br>
<strong>Auto Approve Threshold Amounts: </strong><br>

a. Closing method = Deduction, claimed >= $300, deviation < $100 - Auto match By Bill to and reference <br>
b. Closing method = Deduction, claimed < $300, deviation < $100 - Auto Approve as write-off<br>
c. Closing method = Payment, Claimed  $ < = $300 and deviation $ <= 10% <br>
d. Closing method = Payment, Claimed $ > $300, deviation $ < $100 <br>
e. Any billback with a claimed/expected amount > $250,000 is not included in Auto Approve<br>


<input type="hidden"	name="sel_Auto_Approved_BB_Status" value="0">

<cfelse>
<!--- 
	END: D44693: Reinhart AutoMatch Inquiry/ Anand Rao / 07-Jan-2015
--->

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
	
	<tr>
		<th colspan="100%" align="left">
			<font color="navy">Billback Auto Approve</font>
		</th>
	</tr>
	
	<tr>
		<td colspan="2">
		<BR>
		<BR>
		</td>
	</tr>

	<TR>
		<TD>
			<B>Do not allow Auto-Approve:</B>
		</TD>
		<TD>
			<INPUT onClick="javascript:EnableAutoApproveAmout(this)"  TYPE="Checkbox" NAME="AutoApprove_not_allowed" VALUE="1" <cfif form.AutoApprove_not_allowed EQ 1>checked</cfif>>
		</TD>
	</TR>
  <!----------------------------------------------------------------------------- 
    Dev Notes: D19081
	   BB auto approve modifications
    -Anand Rao/21-May-09
------------------------------------------------------------------------------>

	<tr>
    	<td colspan="100%">
      		<input type="Radio" name="rdo_Auto_Approve_BB_Types" value="1" <cfif form.rdo_Auto_Approve_BB_Types EQ 1>checked</cfif> checked>Uploaded billbacks only
       		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      		<input type="Radio" name="rdo_Auto_Approve_BB_Types" value="2" <cfif form.rdo_Auto_Approve_BB_Types EQ 2>checked</cfif> >Manually created billbacks only
     		 &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
      		<input type="Radio" name="rdo_Auto_Approve_BB_Types" value="3" <cfif form.rdo_Auto_Approve_BB_Types EQ 3>checked</cfif>>Both
   		 </td>
  </tr>
  
  <TR id="tr_AutoApproveAmount">
		<TD>
			<BR><B>Automatically approve uploaded billbacks where the billback<br> amount is less than or equal to:</B>
		</TD>
		<TD>
			&nbsp;&nbsp;<INPUT TYPE="Text" NAME="Auto_Approve_Amount" VALUE="#form.Auto_Approve_Amount#" SIZE="5" ONKEYUP="clenseText(this,'0123456789.')">
		</TD>
	</TR>

	<TR id="tr_AutoApproveAmount">
		<td colspan="3">
			<div id="divExceptions">
				<CF_button
					button_name		=	"btnExceptions"
					button_caption	=	"view auto approve exceptions"
					button_action	=	"AutoApprove()"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			</div>
		</td>
	</TR>

	<tr>
    	<td>
      		<br>
      		<strong> BB status if auto approved:</strong>
    	</td>
    	<td>
     		<br>
      		&nbsp;&nbsp;
			<select id = "sel_Auto_Approved_BB_Status" name="sel_Auto_Approved_BB_Status">
				<cfloop query="qGetBillbackStatus">
					<option value="#Billback_Status_ID#" <cfif form.Auto_Approved_BB_Status EQ Billback_Status_ID>selected</cfif>>#BB_Status_Description#</option><!--- <cfif qGetToleranceSettings.Billback_Status_ID_Below eq Billback_Status_ID>selected</cfif> --->
				</cfloop>       
      		</select>
    	</td>
  	</tr>
  	<tr>
    	<td>
      		<br>
      		<strong>Billback reference ## is exclusive:</strong>
			<cf_SmallHelp width="300" dropdownCheck="0">
				This setting is due to some distributors that are deducting for N billbacks with a single deduction. 
				Many of the billbacks have small enough dollar amounts to be auto approved and set to PAID status.
				However, when we set the billbacks to PAID status the users are unable to match these billbacks to a deduction.
				Therefore, when this setting is turned ON we will sum the claimed amounts for any billbacks with the same reference number to determine if the billbacks should be eligible to be auto approved.
			</cf_SmallHelp>
    	</td>
    	<td>
     		<br>
      		&nbsp;&nbsp;
			<input name="Auto_Appr_Reference_Exclusive" type="checkbox" value="1" <cfif form.Auto_Appr_Reference_Exclusive EQ 1>checked</cfif> />
    	</td>
  	</tr>
	<tr>
		<td>
			<br>
			<strong>Consider billbacks created date:</strong>
		</td>
		<td>
			<br>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Consider_Created_Date" type="checkbox" value="1" <cfif form.Auto_Appr_Consider_Created_Date eq 1>checked</cfif> onClick="javascript:enableAge(this)"  />
		</td>
	</tr>
	<tr>
		<td>
			<br>
			<strong>The billback created date is greater than:</strong>
		</td>
		<td>
			<br>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Age" type="text" value="#form.Auto_Appr_Age#" maxlength="3" size="5" onKeyUp="clenseText(this,'0123456789')" />
		</td>
	</tr>
	<tr>
		<td>
			<br>
			<strong>Auto approve should process BBs with divested items:</strong>
		</td>
		<td>
			<br>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Divested_Items" type="checkbox" value="1" <cfif form.Auto_Appr_Divested_Items eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<br>
			<strong>Auto approve should process BBs with unknown items:</strong>
		</td>
		<td>
			<br>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Unknown_Items" type="checkbox" value="1" <cfif form.Auto_Appr_Unknown_Items eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td>
			<br>
			<strong>Auto approve should process BBs with dummy Program:</strong>
		</td>
		<td>
			<br>
			&nbsp;&nbsp;
			<input name="Auto_Approve_Dummy_Prog" type="checkbox" value="1" <cfif form.Auto_Approve_Dummy_Prog eq 1>checked</cfif> />
		</td>
	</tr>
</TABLE>
<br><br>
<table cellpadding="3" cellspacing="0" border="0">
	<tr>
		<td valign="bottom" style="border-bottom:none">
			<strong>Auto approve should process BBs where the payee = operator:</strong>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Payee_Operator" type="checkbox" value="1" onClick="javascript:enableException(this);" <cfif form.Auto_Appr_Payee_Operator eq 1>checked</cfif> />
		</td>
	</tr>
	<tr>
		<td colspan="100%" style="border-top:none">
			<div id="operatorExceptions" <cfif form.Auto_Appr_Payee_Operator neq 1>style="display:none"</cfif>>
				<CF_openLayer
					Border="Yes"
					BorderSize="1"  
					BorderColor="orange"  
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="Except for the following #application.returned_customer_setting.operator_label_singular# payees"  
					TitleClosed="Except for the following #application.returned_customer_setting.operator_label_singular# payees"  
					TitleTooltip="Click to Show/Hide"  
					TitleFont="font"  
					TitleColor="Blue"  
					TitleSize="9"  
					IsClosed="No"  
					Width="100%">
					
					<CF_button
						button_name		=	""
						button_caption	=	"select #lcase(application.returned_customer_setting.operator_label_plural)#"
						button_action	=	"operatorSearch()"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						class			=	"NotMaintable">
					<br>
					<!---/////////////////////////////// Operator List /////////////////////////////////--->
					<cfif len(trim(form.Operator_List)) and qGetOperators.RecordCount>
					<table>
						<cfloop query="qGetOperators">
						<tr>
							<TD id="TR_oper_#BSA_Operator_ID#" STYLE="cursor: pointer;" NOWRAP>
								<img id="theImage"  style="cursor: pointer;" onClick="deleteThisEntry('oper_#BSA_Operator_ID#','#BSA_Operator_ID#', 'oper');" src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0" />&nbsp;
								#Operator_Name#&nbsp;#BSA_Operator_ID#
							</td>
						</tr>
						</cfloop>
					</table>
					</cfif>
				</CF_openLayer>
			</div>
		</td>
	</tr>
</table>
<br><br>
<table cellpadding="3" cellspacing="0" border="0">
	<tr>
		<td valign="bottom" style="border-bottom:none">
			<strong>Auto approve should process BBs where the payee = distributor:</strong>
			&nbsp;&nbsp;
			<input name="Auto_Appr_Payee_Distributor" type="checkbox" value="1" onClick="javascript:enableException(this);" <cfif form.Auto_Appr_Payee_Distributor eq 1>checked</cfif> />
		</td>
	</tr>
		<tr>
		<td colspan="100%" style="border-top:none">
			<div id="distributorsExceptions" <cfif form.Auto_Appr_Payee_Distributor neq 1>style="display:none"</cfif>>
				<CF_openLayer
					Border="Yes"
					BorderSize="1"  
					BorderColor="orange"  
					Image="/images/plus2.gif"
					ImageOpen="/images/minus2.gif"
					Title="Except for the following #application.returned_customer_setting.distributor_label_singular# payees"  
					TitleClosed="Except for the following #application.returned_customer_setting.distributor_label_singular# payees"  
					TitleTooltip="Click to Show/Hide"  
					TitleFont="font"  
					TitleColor="Blue"  
					TitleSize="9"  
					IsClosed="No"  
					Width="100%">
					
					<CF_button
						button_name		=	""
						button_caption	=	"select #lcase(application.returned_customer_setting.distributor_label_plural)#"
						button_action	=	"distributorSearch()"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
						class			=	"NotMaintable">
					<br>
					<!---/////////////////////////////// Distributor List /////////////////////////////////--->
					<cfif len(trim(form.Distributor_List)) and qGetDistributors.RecordCount>
					<table>
						<cfloop query="qGetDistributors">
						<tr>
							<TD id="TR_dist_#BSA_Foodservice_Customers_ID#" STYLE="cursor: pointer;" NOWRAP>
								<img id="theImage"  style="cursor: pointer;" onClick="deleteThisEntry('dist_#BSA_Foodservice_Customers_ID#','#BSA_Foodservice_Customers_ID#', 'dist');" src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0" />&nbsp;
								#Name#&nbsp;#Ship_To#
							</td>
						</tr>
						</cfloop>
					</table>
					</cfif>
				</CF_openLayer>
			</div>
		</td>
	</tr>
</table>
</cfif>
<BR><BR>
	<CF_button
		button_name		=	""
		button_caption	=	"save data"
		button_action	=	"validate()"
		button_type		=	"javascript_link"
		button_width	=	"100"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold"
	>

<input type="hidden"	name="SelectSingleSearchResultOnly" value="0">
<input type="hidden" 	name="Operator_List" 				value="#form.Operator_List#">
<input type="hidden" 	name="Distributor_List"				value="#form.Distributor_List#">
<input type="hidden" 	name="blnSubmit" 					value="0">
<input type="hidden" 	name="firstTimeLoading" 			value="0">

</FORM>

<SCRIPT language="JavaScript">

	function distributorSearch()
	{
		NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?Formname=autoApproveForm&FieldName=Distributor_List&SelectSingleSearchResultOnly=0", "distributorwindow", 850, 600, "yes", "yes");
	}
	
	function operatorSearch()
	{
		NewWindow("/billbacks/search_screens/PM_select_operators.cfm?Formname=autoApproveForm&FieldName=Operator_List&searchoperator=1", "operatorwindow", 850, 600, "yes", "yes");
	}
	
	function AutoApprove()
	{
		document.location = '../../DEDUCTIONS/settings/Auto_Close_Exceptions.cfm';
	}
	
	function EnableAutoApproveAmout(thisObj)
	{
		// Dev Note: KAL - D7911 Auto Close not allowed checkbox
		// this function enables or disbales Auto Close Amount Text Box
		var formObj1	= 	document.all.Auto_Approve_Amount;
    	var formObj2  	= 	document.all.rdo_Auto_Approve_BB_Types;
    	var formObj3  	=	document.all.sel_Auto_Approved_BB_Status;    
    
		if(thisObj.checked)
		{
      		document.all.tr_AutoApproveAmount.disabled = true;
			formObj1.value       = '';
			formObj1.disabled    = true;
      		formObj2[0].disabled = true;		  
      		formObj2[1].disabled = true;		  
      		formObj2[2].disabled = true;		        
      		formObj3.disabled = true;      
    		divExceptions.style.display = 'none';
		}
		else
		{
			document.all.tr_AutoApproveAmount.disabled = false;
			formObj1.disabled    = false;
      		formObj2[0].disabled = false;		  
      		formObj2[1].disabled = false;		  
      		formObj2[2].disabled = false;	  
      		formObj3.disabled    = false;         
			formObj1.value       = '#form.Auto_Approve_Amount#';
      		divExceptions.style.display = 'block';    
		}
	}
			
	function enableException(thisObj)
	{
    
		var exceptionType = thisObj.name;

		if(thisObj.checked)
		{    
			if(exceptionType == 'Auto_Appr_Payee_Distributor')
			{
				distributorsExceptions.style.display = 'block';
			}
			else
			{
    			operatorExceptions.style.display = 'block';
			}
		}
		else
		{
			if(exceptionType == 'Auto_Appr_Payee_Distributor')
			{
				distributorsExceptions.style.display = 'none';
			}
			else
			{
    			operatorExceptions.style.display = 'none';
			}
		}
	}
	
	function enableAge(thisObj)
	{
		var formObj	= 	document.all.Auto_Appr_Age;  
    
		if(thisObj.checked)
		{
			formObj.disabled    = false;
			formObj.value       = '#form.Auto_Appr_Age#';

		}
		else
		{
			formObj.value       = '';
			formObj.disabled    = true;   
		}
	}
	
	function validate()
	{
		document.all.blnSubmit.value = 1;
		document.all.autoApproveForm.submit();
	}
	
	<cfif  GetBBAutoApproveLogic.Custom_Auto_Approve_Type EQ 2>	
		<cfif form.Auto_Approve_Amount EQ "">
			var thisObj = document.all.AutoApprove_not_allowed;
			thisObj.checked = true;
			EnableAutoApproveAmout(thisObj);
		</cfif>
	</cfif>
</script>
</BODY></HTML></cfoutput>

 

