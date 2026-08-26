<cfsilent>
<!---
FILE:
FILENAME: 	billbacks/scorecard/display_Billback_List.cfm
CREATED: 	??/??/???? - ???
EDITED:		12/03/2008 - RBL [D17628]

FUNCTIONALITY:
- This template is a piece of the display billback search results puzzle...
--->
<cfset ShowSalesTax = application.appSettingsGet />

<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />

</cfsilent>

<!--- D17544 thought... <cfparam name="url.bHaveResults"	type="boolean" default="0"> --->
<!--- IF we HAVE some schtuff... --->
<!--- <cfif url.bHaveResults>
    <div align="center" onClick="javascript:ColdFusion.Window.hide('billbackSearchResultWindow')" style="background-color:##eeeeee;height:100%;width:100%;">
        <font size="1" color="Black"><b>Complete!</b></font>&nbsp;<font size="1" color="Red">[</font> &nbsp;<font size="1" color="Blue"><a href="#cgi.script_name#?bHaveResults=#url.bHaveResults#">View Billback Search Results</a></font>&nbsp;<font size="1" color="Red">]</font>
    </div>
</cfif> --->

<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags">
<cfparam name="BUSINESS_UNIT_DESC" default="">
<cfparam name="form.currentBillbackList" default="">
<cfparam name="form.massPayBillbackList" default="">
<cfparam name="CanDelete" default="0">
<cfparam name="AlreadySelected" default="">
<cfparam name="form.Source" default="">

 <Cfif Get_Profile_Settings.BB_Delete IS 1>
	<cfset CanDelete = 1>
</CFIF>

<CFINCLUDE TEMPLATE="/billbacks/scorecard/billback_Table_Measures.cfm">

<!--- 57829 required adjustments for Chrome :: IE aligns correctly with measurements in \billbacks\scorecard\billback_Table_Measures.cfm --->
<cfif findNoCase("Chrome", CGI.HTTP_User_Agent) and cgi.SCRIPT_NAME contains "scorecard_content.cfm">
	<!--- to figure out the numbers below for Chrome find out the td widths in IE with DebugBar, then subtract 4 for paddings --->
	<cfscript>
		Status_Width              = 95;
		UPPNF_Width               = 82;
		Number_Width              = 164;
		BBD_Width                 = 215;
		Payee_And_Title_Width     = 245;
		Date_Width                = 134;
		Amount_Width              = 114;
		Analyst_And_Segment_Width = 104;
	</cfscript>
</cfif>

<!--- Dev Note: Clay 11061 --->
<CFIF application.returned_customer_setting.Customer_Keyword EQ "Mccain">
<cfset  deviation_heading  = "VAR" />
<cfset 	deviation_desc  = "Claim Variance" />
<CFELSE>
<cfset  deviation_heading  =  "DEV" />
<cfset 	deviation_desc  = "Deviation" />
</CFIF>
<cfset bBillbackSalesTax = 0 />

<STYLE>
	TR.redTR TD
	{
		color: red;
	}

	#previewlink:hover {text-decoration:underline;}

	input.upload {
		/* outline: 1px solid blue; */
		margin-left: -1px;
	}
</STYLE>

<cfinclude template="billback_status_tool_tip.cfm" />
<cfoutput>#billbackStatusToolTip#</cfoutput>

<SCRIPT SRC="/script/javascript/DHTML_Tooltip_Code.js?a"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
document.body.onload=new Function ("popupInit();")


function initTheTooltip()
{
	popUp(-1)
}


var currentBillbackList = <cfoutput>"#form.currentBillbackList#"</cfoutput>
	function selectedBillbackListManage(oChkBx) {
		billbackID = oChkBx.value;
		if(oChkBx.checked) {
			//add to list
			if(currentBillbackList.length == 0){
				currentBillbackList = billbackID;
			}
			else{
				currentBillbackList = currentBillbackList + ',' + billbackID
			}
		}
		else {
			//remove from list
			tempArray = currentBillbackList.split(",")
			tempcurrentBillbackList = "";
			for(var x=0; x<tempArray.length; x++) {
				if(tempArray[x] != billbackID) {

					if(tempcurrentBillbackList.length == 0){
						tempcurrentBillbackList = tempArray[x];
					}
					else{
						tempcurrentBillbackList = tempcurrentBillbackList + ',' + tempArray[x]
					}
				}
			}
			currentBillbackList = tempcurrentBillbackList;
		}

		document.all.MyForm.currentBillbackList.value = currentBillbackList;
		window.parent.window.globalCurrentBillbackList = currentBillbackList;
	}

</SCRIPT>

<!--- Ana: D17452 Using AJAX to check Template Access --->
<script type='text/javascript'>
   	_ajaxConfig = {'_cfscriptLocation':'/components/Billback/BBVerifyTemplateAccess.cfc','_jsscriptFolder':'/script/javascript/Ajax_JS/','debug':false};
</script>

<script type='text/javascript' src='/Script/javascript/Ajax_JS/ajax.js'></script>
<script type="text/javascript">
var BBID = '00000000-0000-0000-0000000000000000'
function TemplateAccessRedirect(Billback_ID,CallType)
{
	BBID = Billback_ID;
	var User_Profile_ID = "<CFOUTPUT>#Get_Profile_Settings.Profiles_ID#</CFOUTPUT>";
	var Forbid_type = "<CFOUTPUT>#appSettings.getForbidAllowProfilesInTemplates()#</CFOUTPUT>";
    DWREngine.setAsync(true);
	// D17628 [begin]
	// 1
	if (CallType == 1)
	{
    	DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'verifyTemplateAccess', Billback_ID, Forbid_type, User_Profile_ID, ReDirect);
	}
	// 2
	else if (CallType == 2)
	{
		DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'verifyTemplateAccess', Billback_ID, Forbid_type, User_Profile_ID, ReDirectPopupPreview);
	}

	else if (CallType == 3)
	{
		DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'verifyTemplateAccess', Billback_ID, Forbid_type, User_Profile_ID, ReDirectPopupDetailSummary);
	}
	// D17628 [end]
}

function ReDirect(returnedvalue){
	// 1
	if (returnedvalue == 1)
	{
		parent.window.location = "/billbacks/capture/INDEX.CFM?bbid="+BBID
	}
	// 0
	else
	{
		alert("You do not have access to the program(s) in the billback.")
	}
	return false;
}

// D17628 [begin]

function ReDirectPopupPreview(returnedvalue){
	// 1
	if (returnedvalue == 1)
	{
		NewWindow('/billbacks/capture/bb_preview.cfm?BBID='+BBID, 'bb_budget_display', 800, 600, 'yes', 'yes');
	}
	// 0
	else
	{
		alert("You do not have access to the program(s) in the billback.")
	}
	return false;
}

function ReDirectPopupDetailSummary(returnedvalue){
	// 1
	if (returnedvalue == 1)
	{
		NewWindow('/billbacks/capture/INDEX.CFM?bbid='+BBID, 'bb_detail_summary', 980, 700, 'yes', 'yes');
	}
	// 0
	else
	{
		alert("You do not have access to the program(s) in the billback.")
	}
	return false;
}
// D17628 [end]

function openDetails(BBID){
	NewWindow('billback_details.cfm?BBID='+BBID, 'billback_details', 800, 600, 'yes', 'yes');
}
</script>

<!--- END Ana: D17452 Using AJAX to check Template Access --->

<CFINCLUDE TEMPLATE="deduction_age.cfm">
<cfset SECTION_RECORDCOUNT = SC_QUERY.RecordCount>
<!--- D25219: SOW - Enable mass paying of payables START--->
<cfinclude template="/common_files/jQuery.cfm">
<!--- D25219: SOW - Enable mass paying of payables END--->
<form name="ReturnResults" id="ReturnResults" action="/deductions/search_screens/billbacks.cfm" method="Post">
	<style>
		table.Maintable {
			table-layout: fixed;
		}
	</style>
	<TABLE border="0" CLASS="Maintable" WIDTH="<CFOUTPUT>#Table_Width#</CFOUTPUT>" <cfif form.source IS "Deductions"> style="margin:0 auto" <cfelse>align="center"</cfif> CELLPADDING="2" CELLSPACING="0">
	<CFOUTPUT QUERY="SC_QUERY">
		<cfset expiring = DateDiff("d", BB_Date, Now())>
		<!---<cfset expiring = DateFormat(Now(),  'MM/DD/YYYY')  - DateFormat(BB_Date, 'MM/DD/YYYY')>--->
		<cfif expiring GT Aging_Days AND SC_QUERY.Billback_Status_ID LT 5>
			<CFSET this_Billback_Is_Aging = 1>
		<CFELSE>
			<CFSET this_Billback_Is_Aging = 0>
		</CFIF>

<!--- D25219: SOW - Enable mass paying of payables START--->
<cfset expected_claimed_display = 0>
<!--- Check if user has BillBack Approval Rights AND Billback has Deviation Ran against it.--->
<cfif Get_Profile_Settings.BB_Approve AND Deviation_Ran_Date NEQ "">

	<!--- Template Approval Rights START --->
	<cfset CheckTemplateApprovalRights = BBProgramManager.getTemplateApprovalRights(Billback_ID)>

	<CFSET TemplateApprovalRight = 0>
	<CFIF application.appSettingsGet.getForbidAllowProfilesInTemplates() EQ 1 AND CheckTemplateApprovalRights.RecordCount EQ 0>
		<CFSET TemplateApprovalRight = 1>
	<CFELSEIF application.appSettingsGet.getForbidAllowProfilesInTemplates() EQ 0 AND CheckTemplateApprovalRights.RecordCount GT 0>
		<CFSET TemplateApprovalRight = 1>
	</CFIF>

	<!--- If the setting allows for Sales tax Info --->
	<cfset CheckTemplateSalesTax = BBProgramManager.getTemplateSalesTax(Billback_ID)>

	<cfif (CheckTemplateSalesTax.RecordCount GTE 2)>
		<cfloop query = "CheckTemplateSalesTax">
			<cfif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
				<cfset bBillbackSalesTax = 1 />
			</cfif>
		</cfloop>
	<cfelseif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
		<cfset bBillbackSalesTax = 1 />
	</cfif>
	<!--- Template Approval Rights END --->
	<!--- Setting Variable to display Expected and Claim links START --->
		<cfif ( Billback_Status_ID EQ 2 AND TemplateApprovalRight AND (application.appSettingsGet.getBillbackQuickPay() EQ 1 OR application.appSettingsGet.getBillbackQuickPay() EQ 3)

			OR
			    Billback_Status_ID EQ 3 AND TemplateApprovalRight AND (application.appSettingsGet.getBillbackQuickPay() EQ 2 OR application.appSettingsGet.getBillbackQuickPay() EQ 3)
			  )
		>
		<cfset expected_claimed_display = 1>
		</cfif>
	 <!--- Setting Variable to display Expected and Claim links START --->
</cfif>
<!--- D25219: SOW - Enable mass paying of payables END--->
		<!------
		 CLASS="redTR"
		----->
		<!--- setting to check whether the Sales Tax info is required --->
		<!--- <cfinvoke component="components.settings.ApplicationSettingsManager" method="get" returnVariable="ShowSalesTax"> --->

		<CFSET TRBGColor = IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))>
		<CFSET TRTitle = "">
		<!--- Sets background color to purple --->
		<CFIF form.source EQ "Deductions" AND appSettings.getMatch_BB_DD_Based_On_Same_ReferenceNum() AND IsSameReferenceNum EQ 1>
			<CFSET TRBGColor = "E1CEEC">
			<CFSET TRTitle = "Deduction Reference Num = Billback Number">
		</CFIF>
		<CFIF this_Billback_Is_Aging>
			<CFIF TRTitle NEQ "">
				<CFSET TRTitle="#TRTitle##chr(13)#This billback is in danger of being deducted.  It is now #expiring# day(s) since the billback date.">
			<CFELSE>
				<CFSET TRTitle="This billback is in danger of being deducted.  It is now #expiring# day(s) since the billback date.">
			</CFIF>
		</cfif>
		<!--- <tr <CFIF FORM.source EQ "Deductions" AND appSettings.getMatch_BB_DD_Based_On_Same_ReferenceNum() AND IsSameReferenceNum EQ 1>BGCOLOR="E1CEEC" <CFELSE>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top" <CFIF this_Billback_Is_Aging> TITLE="This billback is in danger of being deducted.  It is now #expiring# day(s) since the billback date."</cfif></CFIF>> --->
		<tr BGCOLOR= #TRBGColor# VALIGN="top" id="#Billback_ID#">

		<cfset BillbackReplaced = replace(SC_QUERY.Billback_ID, '-', '_', "all")>

		<cfif form.Source Is "Deductions">

		<td width="#spacerwidth#">&nbsp;</td>
		<td width="#SelectionWidth#">

		<cfif BB_Is_Locked IS 0>
		<span ID="checkallReasons">

        	<!--- D17544 11/17/08 RBL - TheQuery.Billback_ID below was replaced to variables.qBillbackSearchResults.Billback_ID --->
			<CFIF appSettings.getMultiple_BB_Per_Deduction()>
				<span ID="selectedReasons"><input TYPE="checkbox" NAME="selectedReasons" value="#BillbackReplaced#" <Cfif bBillbackSalesTax EQ 0><!--- <CFIF ShowSalesTax.getBillbacksSalesTax() eq 0> --->BB_Amount="#BB_Approved_Amount#"<CFELSE>BB_Amount="#(val(BB_Approved_Amount) + val(TotalTaxAmount))#"</CFIF> onClick="javascript:addRemoveBillback(this)"   <cfif Listcontains(AlreadySelected, variables.qBillbackSearchResults.Billback_ID, ",")>Checked<CFELSEIF ListContainsNoCase(Form.CurrentBillbackList, BillbackReplaced, ",")>CHECKED</cfif> ></span>
			<CFELSE>
				<input TYPE="radio" NAME="selectedReasons" value="#BillbackReplaced#" ONCLICK="if(!this.checked) document.all.checkall.checked = false;"  <cfif Listcontains(AlreadySelected, SC_QUERY.Billback_ID, ",")>Checked</cfif> >
			</CFIF>

		</span>

		<cfelse>
			<CFIF appSettings.getMultiple_BB_Per_Deduction()>
				<input TYPE="checkbox" NAME="selectedReasons" value="#BillbackReplaced#" disabled>
			<CFELSE>
				<input TYPE="radio" NAME="selectedReasons" value="#BillbackReplaced#" disabled>
			</CFIF>
		</cfif>
		</td>

		<cfelseif CanDelete EQ 1 AND BB_Is_Locked EQ 0>
			<!--- WIP and RFA only --->

			<cfif (Billback_Status_ID IS 1 OR Billback_Status_ID IS 2 ) OR(  Billback_Status_ID IS 3 AND BB_Payment_Request_Sent EQ 0 )>
				<span ID="checkallReasons">
				<td width="#spacerwidth#">&nbsp; <!--- #spacerwidth# ---> </td>
				<td width="#SelectionWidth#"><!--- #SelectionWidth# --->
				<span ID="selectedReasons"><input TYPE="checkbox" NAME="selectedReasons" value="#BillbackReplaced#" onClick="javascript:addRemoveBillback(this)"  <cfif ListContainsNoCase(Form.CurrentBillbackList, BillbackReplaced, ",")>CHECKED</cfif> ></span></td>
				</span>
			<cfelse>
				<td width="#spacerwidth#">&nbsp;</td>
				<td width="#SelectionWidth#">&nbsp;</td>
			</cfif>

		<cfelseif  CanDelete EQ 1 AND BB_Is_Locked EQ 1>
		<td  width="#spacerwidth#">&nbsp;</td>
		<td width="#SelectionWidth#">&nbsp;</td>

		<Cfelse>
		<td width="#spacerwidth#">&nbsp;</td>
		<td width="#SelectionWidth#">&nbsp;</td>
		</cfif>

		<CFQUERY NAME="qGetAttachments" DATASOURCE="#Application.Datasource#">
			SELECT 	Count(Billback_ID) as BB_Attachment_Count
			FROM 	Contract_Attachments
			WHERE 	Contract_Attachments.Billback_ID = '#Billback_ID#'
			AND 	Contract_Attachments.Deleted = 0
		</CFQUERY>
		<cfset Attachment_Count = qGetAttachments.BB_Attachment_Count />
    	<TD NOWRAP ALIGN="left" WIDTH="#Status_Width#" >
 			#getBBStatusImageString(SC_QUERY.Billback_Status_ID)#
			<!---warning and lock images--->
			<!--- show a lock for locked contracts --->
      <!---
        Dev Notes: 21312/Anand Rao/17-Nov-09:
        Added a Replace function in the below query to replace the ; with a "" so that
        the Name_First an Name_Last will be properly returned.
      --->
			<CFIF BB_Is_Locked EQ 1>
				<cfquery name="LookUpTheLockingUser" datasource="#application.datasource#">
					SELECT Name_First, Name_Last
					FROM _Users
					WHERE User_ID = '#Replace(BB_Locked_By_User_ID,";","","ONE")#'
				</cfquery>
				<IMG SRC="/images/lock.gif" TITLE="This billback is currently being viewed by #LookUpTheLockingUser.Name_First# #LookUpTheLockingUser.Name_Last#" height="16" width="12">
			<cfelse><img src="/images/fill.gif" width="12" border="0">
			</CFIF>
			<CFIF Attachment_Count GT 0><img src="/images/doc.gif" width="13" border="0" title="This billback has #Attachment_Count# document<CFIF Attachment_Count GT 1>s</CFIF> attached">
			<CFELSE><img src="/images/fill.gif" width="13" border="0"></CFIF>
			<cfset bb_parent = 0><!--- D25219: SOW - Enable mass paying of payables --->
			<CFIF bb_Is_child EQ 1>
				<!--- Ana: D17452 Using AJAX to check Template Access
				<A HREF="##" STYLE="FONT-SIZE:10PX;" ONCLICK="javascript: TemplateAccessRedirect('#BB_parent_ID#',1); return false;"><img src="/Images/child_New.gif" alt="Click to view original billback." width="13" height="13" border="0"></A>
				 --->
				<A TARGET="_parent" HREF="/billbacks/capture/INDEX.CFM?bbid=#BB_parent_ID#" STYLE="FONT-SIZE:10PX;" ><img src="/Images/child_New.gif" title="Click to view original billback." width="13" height="13" border="0"></A>
			<CFELSE>
				<CFQUERY NAME="CheckForChild" DATASOURCE="#Application.Datasource#">
				SELECT BB_Parent_ID FROM Billback WHERE BB_Parent_ID = '#Billback_ID#'
				</CFQUERY>
				<CFIF CheckForChild.RecordCount GT 0>
					<cfset bb_parent = 1> <!--- D25219: SOW - Enable mass paying of payables --->
					<img src="/Images/parent_New.gif" title="Split into #CheckForChild.RecordCount# billbacks." width="13" height="13" border="0">
				<CFELSE>
					<!---
					Not sure whether commenting this will cause any issues. Added comment so that
					the status images  (approved and beyond) are aligned properly vertically along with other status images.
					<cfif (Billback_Status_ID NEQ 1 AND Billback_Status_ID NEQ 2)>
						<img src="/images/fill.gif" width="12" border="0">
					</cfif>--->
				</CFIF>
			</CFIF>
			<cfif (Billback_Status_ID EQ 3 OR Billback_Status_ID EQ 4 OR Billback_Status_ID EQ 5) AND BB_Payment_Request_Sent EQ 1>
				<cfset BB_Payment_Request_Sent_Date = "#DateFormat(BB_Payment_Request_Sent_On, "mm/dd/yyyy")# #TimeFormat(BB_Payment_Request_Sent_On, "hh:mm:ss tt")#" />
				<cfset BB_Received_Ack_Date_Str = "#DateFormat(BB_Received_Ack_Date, "mm/dd/yyyy")# #TimeFormat(BB_Received_Ack_Date, "hh:mm:ss tt")#" />

				<cfif BB_Received_Ack_Type EQ 0>
					<IMG SRC="/images/arrow1.gif" width="10" height="10" title="This billback is being sent to ERP #chr(13)##chr(10)#Send Date: #BB_Payment_Request_Sent_Date#">
				<cfelseif BB_Received_Ack_Type EQ 1 AND Set_Billbacks_To_Paid_No_Interface EQ 0>
					<IMG SRC="/images/arrow2.gif" width="10" height="10" title="This billback has been successfully loaded in ERP #chr(13)##chr(10)#Send Date: #BB_Payment_Request_Sent_Date# #chr(13)##chr(10)#<Cfif len(trim(BB_Received_Ack_Date_Str))>Acknowledge Date: #BB_Received_Ack_Date_Str# #chr(13)##chr(10)#</Cfif><cfif len(trim(Voucher_Number))>Voucher Number: #Voucher_Number#</cfif>">
				<cfelseif BB_Received_Ack_Type EQ 2>
					<IMG SRC="/images/arrow1_red.gif" width="10" height="10" title="This billback failed to get loaded in ERP #chr(13)##chr(10)#Send Date: #BB_Payment_Request_Sent_Date# #chr(13)##chr(10)#Acknowledge Date: #BB_Received_Ack_Date_Str#">
				<cfelse>
					<!---
					Not sure whether commenting this will cause any issues. Added comment so that
					the status images  (approved and beyond) are aligned properly vertically along with other status images.
					<cfif (Billback_Status_ID NEQ 1 AND Billback_Status_ID NEQ 2)>
					  <img src="/images/fill.gif" width="12" border="0">
					 </cfif>--->
				</cfif>
			<cfelseif Billback_Status_ID EQ 8 AND BB_Approved_Void_Sent_On NEQ "">
				<cfset BB_Approved_Void_Sent_Date = "#DateFormat(BB_Approved_Void_Sent_On, "mm/dd/yyyy")# #TimeFormat(BB_Approved_Void_Sent_On, "hh:mm:ss tt")#" />
				<cfset BB_Approved_Void_Ack_Date_Str = "#DateFormat(BB_Approved_Void_Ack_Date, "mm/dd/yyyy")# #TimeFormat(BB_Approved_Void_Ack_Date, "hh:mm:ss tt")#" />

				<cfif BB_Approved_Void_Ack_Type EQ 0>
					<IMG SRC="/images/arrow1.gif" width="10" height="10" title="This billback reverse is being sent to ERP #chr(13)##chr(10)#Send Date: #BB_Approved_Void_Sent_Date#">
				<cfelseif BB_Approved_Void_Ack_Type EQ 1  AND Set_Billbacks_To_Paid_No_Interface EQ 0>
					<IMG SRC="/images/arrow2.gif" width="10" height="10" title="This billback reverse has been successfully loaded in ERP #chr(13)##chr(10)#Send Date: #BB_Approved_Void_Sent_Date# #chr(13)##chr(10)#Acknowledge Date: #BB_Approved_Void_Ack_Date_Str# #chr(13)##chr(10)#Voucher Number: #Voucher_Number#">
				<cfelseif BB_Approved_Void_Ack_Type EQ 2>
					<IMG SRC="/images/arrow1_red.gif" width="10" height="10" title="This billback reverse failed to get loaded in ERP #chr(13)##chr(10)#Send Date: #BB_Approved_Void_Sent_Date# #chr(13)##chr(10)#Acknowledge Date: #BB_Approved_Void_Ack_Date_Str#">
				<cfelse>
					<!---
					Not sure whether commenting this will cause any issues. Added comment so that
					the status images  (approved and beyond) are aligned properly vertically along with other status images.
					<cfif (Billback_Status_ID NEQ 1 AND Billback_Status_ID NEQ 2)>
						 <img src="/images/fill.gif" width="12" border="0">
					 </cfif>--->
				</cfif>
			<cfelse>
			    		<!---
					Not sure whether commenting this will cause any issues. Added comment so that
					the status images  (approved and beyond) are aligned properly vertically along with other status images.
				<cfif (Billback_Status_ID NEQ 1 AND Billback_Status_ID NEQ 2)>
						 <img src="/images/fill.gif" width="12" border="0">
				</cfif>--->

			</cfif>

		</TD>

		<td align="center" nowrap WIDTH="#UPPNF_Width#" valign="top" <CFIF TRTitle NEQ "">TITLE="#TRTitle#"</CFIF>>

             <!-----------------------------------------------------------------------------
              Dev Notes: D18281 - Solo - Add new closing method on billback entry
            	All the closing method dropdown and values now come from the DB based on
              the settings in the settings panel
            -Anand Rao/29-May-09
            ------------------------------------------------------------------------------>

      	<span title="#vchBillback_Closing_Method_Desc#">&nbsp;&nbsp;&nbsp;#Abbreviation#</span>
			<!--- <CFIF BB_Closing_method EQ 2>
				<span title="Deduction">&nbsp;&nbsp;&nbsp;DED</span>
			<CFELSE>
				<span title="Payment">&nbsp;&nbsp;&nbsp;PMT</span>
			</CFIF>  --->
  <!--- 18281 end --->

 		<br>
			<CFIF Deviated EQ 1><span title="#deviation_desc#">&nbsp;&nbsp;&nbsp;#deviation_heading#</span></CFIF>
		</td>
		<TD NOWRAP WIDTH="#Number_Width#"  <CFIF TRTitle NEQ "">TITLE="#TRTitle#"</CFIF>>
			<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
			<!--- Ana: D17452 Using AJAX to check Template Access --->
            <!--- D17628 [begin] RBL 12/3/08
			<A HREF="##" STYLE="FONT-SIZE:10PX;" TITLE="View #BB_Code# Details (right click for new window)" ONCLICK="javascript: TemplateAccessRedirect('#Billback_ID#',1);           return false;" oncontextmenu="javascript: TemplateAccessRedirect('#Billback_ID#',3);return false;">#left(BB_Code, 50)#</A>
             D17628 [end] RBL 12/3/08 --->
			<A TARGET="_parent" HREF="/billbacks/capture/INDEX.CFM?bbid=#Billback_ID#" STYLE="FONT-SIZE:10PX;" TITLE="View the details for billback #BB_Code#">#left(BB_Code, 50)#</A>

			<FONT SIZE="2" COLOR="Red"><B>]</B></FONT><br>
			<cfif len(BB_Start_Date) EQ 0 OR len(BB_End_Date) EQ 0>
				<span style="color:RGB(125,125,125);)" Title="Preview is disabled until creation is complete.">preview</span><br />
				<span style="color:RGB(125,125,125);)" Title="Details is disabled until creation is complete.">details</a>
			<cfelse>
				<!--- Ana: D17452 Using AJAX to check Template Access --->
                <!--- D17628 [begin] RBL 12/3/08
				<a href="##" style="color:RGB(0,0,0)" id="previewlink" TITLE="View #BB_Code# Preview In New Window" ONCLICK="javascript: TemplateAccessRedirect('#Billback_ID#',2); return false;" oncontextmenu="javascript: return false;">Preview</a>
                 D17628 [end] RBL 12/3/08 --->
				<a href="/billbacks/capture/bb_preview.cfm?BBID=#Billback_ID#" style="color:RGB(0,0,0)" id="previewlink" target="preview_window" >preview</a><br />
				<a href="javascript:void(0)" onClick="javascript:openDetails('#Billback_ID#')" style="color:RGB(0,0,0)" id="detailslink">details</a>
			</cfif>
      <!---
        19441: If the Billback status is 2 and the Flex tool display is on in the appsettings
        then show the image/link for the Flex BB deviation
        21160: Anand Rao/09-Nov-09
        Added the condition "AND (Uploaded_Billback NEQ 0)" so that the grid can be used
        only for the uploaded_billbacks and not for all types. This was to avaoid
        getting the lumpsum into the flex grid.
        21923: Anand Rao/23-Feb-2010: CAG - Flex Deviation grid modifications
       --->
      <cfif (((Billback_Status_ID EQ 2) OR((Billback_Status_ID EQ 3) AND(appSettings.getUpdate_BB_Approve_Amt() EQ 1))) AND (DD_Closure_Sent_on EQ "") AND (appSettings.get_Setting('BB_Deviation_Format') is 'Flex' OR appSettings.get_Setting('BB_Deviation_Format') contains 'CF') AND Auto_Billback EQ 0 )><!---  AND (Uploaded_Billback NEQ 0) was removed from the condition --->

		<cfif appSettings.get_Setting('BB_Deviation_Format') contains 'CF'>
			<cfset actionPage ="/billbacks/Deviation/Deviation_Main.cfm">
			 <cfset caller = "BBAgGridScoreCard">
			 <cfset source = "BBAgGridScoreCard">
		<cfelse>
			 <cfset actionPage ="/flex/Billback/BillbackDevAppFX.cfm">
			 <cfset caller = "BBFlexScoreCard">
			 <cfset source = "BBFlexScoreCard">
		</cfif>

		&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<a href="##" title="BB Deviation Tool" onclick="javascript:window.open('#actionPage#?bbid=#Billback_ID#&userID=#request.AccessStructure.User_ID#&caller=#caller#&source=#source#','BBDeviation','location=1,status=1,scrollbars=1,resizable=1,left=0,width=1350,height=800');return false;"><cfif ((BB_Loc_Duplicate EQ '') OR (BB_Loc_Duplicate EQ 0))><img src="/images/worksheet.gif" border="0" width="12" height="10"><cfelse><img src="/images/doubledip2.png" border="0" width="12" height="10"></cfif></a>
      </cfif>

			<cfif application.returned_customer_setting.Accounting_Specialist eq 1>

				<!---create the data struct to pass to the accountinSpecialist section if it's on in customer settings--->
				<cfset tmpStruct = StructNew() />
				<cfset tmpStruct.programId = Program_ID />
				<cfset tmpStruct.profileId = request.AccessStructure.Profiles_ID />
				<cfset tmpStruct.handler = "display" />
				<!---layout is just a namespace for the custom tag lib--->
				<layout:section name="views.programs.accountingSpecialist" parameters="#tmpStruct#">

			</cfif>

			<!--- Show "Disagreed" billback info. --->
			<cfinvoke component = "components.billback.BillbackManager" method = "getDisagreeDetails" returnVariable = "BillBackDisagreeInfo">
					<cfinvokeargument name="billbackID" value="#billback_ID#">
			</cfinvoke>

			<cfif BillBackDisagreeInfo.BB_Disagree neq 0>
				<span style="color:red; font-weight:bold;">[disagreed]</span>
			</cfif>
			<br>
			<cfif (BB_All_Dup_Group_ID NEQ "")>
			<font color="red" size="2px"><strong>Duplicate</strong></font>
			</cfif>
		</TD>
		<TD NOWRAP WIDTH="#BBD_Width#" <CFIF TRTitle NEQ "">TITLE="#TRTitle#"</CFIF>>
		<CFIF this_Billback_Is_Aging><FONT COLOR="White" style="font-size:bold;background-color:Red;">&nbsp;</CFIF>#dateformat(BB_Date, 'mm/dd/yyyy')#<CFIF this_Billback_Is_Aging> (#expiring#)&nbsp;</FONT></CFIF>
		<BR>
		<CFSET display_Title=Left(BB_Reference,Ref_Num_Len)>
		<CFIF LEN(display_Title) LT Len(BB_Reference)>
			<CFSET display_Title="#display_Title#...">
		</CFIF>
		<CFIF len(trim(display_Title)) EQ 0>
			<CFSET display_Title=" ">
		</CFIF>
		#HTMLEditFormat(display_Title)#<br>#referenceNum#
		</TD>

	<cfset Payee_Name = "None">
		<!--- Get payee information for this billback --->
		<cfswitch expression="#Billback_Payee_Type_ID#">
			<!--- Distributor payee ---->
			<cfcase value="1">
				<cfquery name="GetPayee" datasource="#application.datasource#">
				SELECT ISNULL(BSA_Foodservice_Customers.Name,VM.Vendor_Name) as Payee_Name
				FROM Billback_Distributor
				LEFT JOIN BSA_Foodservice_Customers
					ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
				LEFT JOIN Vendor_Master VM ON ---added VM join for Auto Pay w/multiple distributors
					VM.vendor_Master_Id = Billback_Distributor.Distributor_ID
				WHERE	Billback_Distributor.Billback_ID = '#Billback_ID#'
					AND Billback_Distributor.Deleted = 0
				</cfquery>
				<cfset Payee_Name = GetPayee.Payee_Name>
			</cfcase>
			<!--- Operator payee --->
			<cfcase value="2">
				<cfquery name="GetPayee" datasource="#application.datasource#">
				SELECT BSA_Operator.Operator_Name as Payee_Name
				FROM BSA_Operator
					INNER JOIN Billback_Operator
					ON Billback_Operator.Billback_ID = '#Billback_ID#'
					AND Billback_Operator.Deleted = 0
					AND BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
				</cfquery>
				<cfset Payee_Name = GetPayee.Payee_Name>
			</cfcase>
			<!--- Broker payee --->
			<cfcase value="3">
				<cfquery name="GetPayee" datasource="#application.datasource#">
				SELECT BSA_Foodservice_Brokers.Broker_Name as Payee_Name
				FROM BSA_Foodservice_Brokers
					INNER JOIN Billback_Broker
					ON Billback_Broker.Billback_ID = '#Billback_ID#'
					AND Billback_Broker.Deleted = 0
					AND BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID
				</cfquery>
				<cfset Payee_Name = GetPayee.Payee_Name>
			</cfcase>
			<!--- In case there is another payee --->
			<cfdefaultcase>
				<cfset Payee_Name = "NA">
			</cfdefaultcase>
		</cfswitch>

		<TD WIDTH="#Payee_And_Title_Width#" TITLE="Payee: #Payee_Name##chr(13)#Title: #HTMLEditFormat(BB_Title)#">
		<CFSET display_Title=Left(Payee_Name,Payee_Len)>
		<CFIF LEN(display_Title) LT Len(Payee_Name)>
			<CFSET display_Title="#display_Title#...">
		</CFIF>
		<CFIF len(trim(display_Title)) EQ 0>
			<CFSET display_Title=" ">
		</CFIF>
 		#HTMLEditFormat(display_Title)#
		<BR>
		<CFSET display_Title=Left(BB_Title,Title_Len)>
		<CFIF LEN(display_Title) LT Len(BB_Title)>
			<CFSET display_Title="#display_Title#...">
		</CFIF>
		<CFIF len(trim(display_Title)) EQ 0>
			<CFSET display_Title=" ">
		</CFIF>
 		#HTMLEditFormat(display_Title)#
		<cfif Billback_Status_ID EQ 2>
			<!--- Get CRA Details --->
			<cfquery name="GetCRA" datasource="#application.datasource#">
				SELECT	TOP 1 User_positions_ID, Authority_Sequence_Order
	            FROM	Billback_Approvable_Positions BillbackApprovablePositions
	            WHERE	BillbackApprovablePositions.Billback_ID = '#billback_id#'
	                 AND NOT EXISTS
	                              (	SELECT DISTINCT BB_Agreed_Info.User_Position_ID
	                                FROM       	BB_Agreed_Info
	                    LEFT JOIN	Authority_Sequence
	                    ON			Authority_Sequence.Authority_Sequence_ID = BB_Agreed_Info.Authority_Sequence_ID
	                                WHERE      	BB_Agreed_Info.Billback_ID = BillbackApprovablePositions.Billback_ID
	                                AND			BB_Agreed_Info.Deleted = 0
	                                AND User_Positions_ID IS NOT NULL
	                                AND		BillbackApprovablePositions.User_Positions_ID = BB_Agreed_Info.User_Position_ID
	                                AND		ISNULL(BillbackApprovablePositions.Authority_Sequence_Order, 0) = ISNULL(Authority_Sequence.Authority_Sequence_Order, 0)
	                   )
	            ORDER BY BillbackApprovablePositions.Service_Market_ID DESC, BillbackApprovablePositions.Service_Region_ID DESC, BillbackApprovablePositions.Service_Zone_ID DESC, BillbackApprovablePositions.Authority_Sequence_Order DESC
			</cfquery>
			<cfset CRAPositionLabel = "" />
			<cfset CRAAuthoritySequenceLabel = "" />
			<cfif isNumeric(GetCRA.User_positions_ID)>
				<cfquery name="GetCRALabel" datasource="#application.datasource#">
					SELECT	Position_To_Approve.Position_Label Position_To_Approve_Label,
							<cfif isNumeric(GetCRA.Authority_Sequence_Order)>
            				Approve_Authority_Sequence.Authority_Sequence_Name Approve_Authority_Sequence_Name
							<cfelse>
							'' Approve_Authority_Sequence_Name
							</cfif>
					FROM	User_Positions Position_To_Approve
					<cfif isNumeric(GetCRA.Authority_Sequence_Order)>
					LEFT JOIN Authority_Sequence Approve_Authority_Sequence
		            ON	Position_To_Approve.Service_Market_ID IS NULL
		            AND Position_To_Approve.Service_Region_ID IS NULL
		            AND Position_To_Approve.Service_Zone_ID IS NULL
		            AND Approve_Authority_Sequence.Deleted = 0
		            AND Approve_Authority_Sequence.Authority_Sequence_Order = #GetCRA.Authority_Sequence_Order#
		            </cfif>
	            	WHERE	Position_To_Approve.User_Positions_ID = #GetCRA.User_positions_ID#
				</cfquery>
				<cfif GetCRALabel.recordCount>
					<cfset CRAPositionLabel = GetCRALabel.Position_To_Approve_Label />
					<cfset CRAAuthoritySequenceLabel = GetCRALabel.Approve_Authority_Sequence_Name />
				</cfif>
			</cfif>

				<div title="Currently Responsible for Approval: #CRAPositionLabel# #CRAAuthoritySequenceLabel#">
					<a href="##" onclick="javaScript:NewWindow('show_approvable_users.cfm?BBID=#billback_id#','ShowApprovableUsers','500','600','Yes', 'Yes');return false;">
						CRA: #CRAPositionLabel# #CRAAuthoritySequenceLabel#
					</a>
				</div>
		</cfif>
		</TD>
		<TD NOWRAP WIDTH="#Date_Width#" <CFIF TRTitle NEQ "">TITLE="#TRTitle#"</CFIF>>
		#dateformat(BB_Start_Date, 'm/d/yyyy')#&nbsp;<BR>
		#dateformat(BB_End_Date, 'm/d/yyyy')#<br>
		<!--- D25219: SOW - Enable mass paying of payables START--->
		<cfif (expected_claimed_display) AND (bb_parent EQ 0) AND (BB_Is_Locked EQ 0 OR BB_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
			<cfset bb_info = #Billback_ID# & '_' & #SC_QUERY.CurrentRow#>
			<cfset bb_text = #Billback_ID# & '_text'>
				<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
					<FONT COLOR="blue"><a href="javascript:PayBillback('#Billback_ID#', '#bb_info#', '#bb_text#', 'E');">Pay Expected $</a></FONT>
				<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
		</cfif>
		<!--- D25219: SOW - Enable mass paying of payables END--->
		</TD>
		<CFSET Amount_Title="Claimed:#dollarformat(BB_Amount)#">
		<CFIF Billback_Status_ID EQ 2>
			<CFSET Amount_Title="Claimed:#dollarformat(BB_Amount)##chr(13)#Variance:#dollarformat(iif(BB_Variance LT 0,"0","BB_Variance"))#">
		</CFIF>
		<CFIF Billback_Status_ID GT 2>
			<cfif bBillbackSalesTax EQ 0>
			<!--- <CFIF ShowSalesTax.getBillbacksSalesTax() eq 0> --->
				<CFSET Amount_Title="#Amount_Title##chr(13)#Approved:#dollarformat(BB_Approved_Amount)#">
			<CFELSE>
			<!--- If the setting allows for Sales tax Info --->
				<CFSET Amount_Title="#Amount_Title##chr(13)#Approved:#dollarformat(val(BB_Approved_Amount) + val(TotalTaxAmount))##chr(13)##dollarformat(val(BB_Approved_Amount))# + #dollarformat(val(TotalTaxAmount))#(Sales Tax)">
			</CFIF>
		</CFIF>

		<TD NOWRAP WIDTH="#Amount_Width#" TITLE="#Amount_Title#">
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR>
					<TD STYLE="border:none;">
						#dollarformat(BB_Amount)#
					</TD>
				</TR>
				<CFIF Billback_Status_ID EQ 2>
				<TR>
					<TD STYLE="border:none;">
						#dollarformat(iif(BB_Variance LT 0,"0","BB_Variance"))#
					</TD>
				</TR>
				</CFIF>
				<CFIF Billback_Status_ID GT 2>
					<cfif bBillbackSalesTax EQ 0>
					<!--- <CFIF ShowSalesTax.getBillbacksSalesTax() eq 0> --->
						<TR><TD STYLE="border:none;">#dollarformat(BB_Approved_Amount)#</TD></TR>
					<CFELSE>
					<!--- If the setting allows for Sales tax Info --->
						<TR><TD STYLE="border:none;">
							<cfset TaxplusApproved = val(BB_Approved_Amount) + val(TotalTaxAmount) />
							<cfif (TaxplusApproved GT BB_Approved_Amount)>
								#dollarformat(BB_Approved_Amount)#
							<cfelse>
								#dollarformat(val(BB_Approved_Amount) + val(TotalTaxAmount))#
							</cfif>
						</TD></TR>
					</CFIF>
				</CFIF>
		<!--- D25219: SOW - Enable mass paying of payables START--->
		<cfif (expected_claimed_display) AND (bb_parent EQ 0) AND (BB_Is_Locked EQ 0 OR BB_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
			<TR>
				<TD STYLE="border:none;">
				<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
					<FONT COLOR="blue"><a href="javascript:PayBillback('#Billback_ID#', '#bb_info#', '#bb_text#', 'BB');">Pay Claimed $</a></FONT>
				<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
				<!---<br><a href="pay_claimed_expected.cfm?BBID=#Billback_ID#&type=BB">test</a>--->
				</TD>
			</TR>
		</cfif>
		<!--- D25219: SOW - Enable mass paying of payables END--->
			</TABLE>
		</TD>
		<TD NOWRAP WIDTH="#Analyst_And_Segment_Width#" title="#business_unit_desc#">
			&nbsp;#BBanalyst_Name_First# #BBanalyst_Name_Last#
			<cfif businessSegmentsOn>
				<cfset maxBusinessSegmentLen = 10 >
				<br>&nbsp;<cfif len(business_unit_desc) GT maxBusinessSegmentLen>#left(business_unit_desc,maxBusinessSegmentLen)#...<cfelse>#business_unit_desc#</cfif>
			</cfif>
		</TD>


		<!--- ................................................................................................................... --->
		<!--- IF BBManualSetPaidStatus QUICK  appSettings.Mass_Pay_Billback   ................................................... --->
		<!--- D32285 : Manually Set BB Status to Paid 			................................................................. --->
		<!--- ................................................................................................................... --->
		<Cfif NOT isDefined("Get_Profile_Settings.Mass_Billback_Pay")>
			<cfquery name="Get_Profile_Settings" datasource="#application.datasource#">
				SELECT Mass_Billback_Pay, BB_Approve FROM BB_Profiles_Settings WHERE Profiles_ID = 	'#request.AccessStructure.Profiles_ID#'
			</cfquery>
		</CFIF>

		<!---Which status billbacks to show? --->
		<cfif appSettings.Mass_Pay_Billback IS 1> <!--- Payment request to Paid --->
			<cfset Status_to_Show = 4>
		</cfif>
		<cfif appSettings.Mass_Pay_Billback IS 2> <!--- RFA to paid --->
			<cfset Status_to_Show = 2>
		</cfif>
		<!--- 62833: Update [ pay selected billbacks ] feature to work with approved billbacks / option '3' for both RFA and Approved status /Anand Rao/08-Sep-2016--->
		<cfif appSettings.Mass_Pay_Billback IS 3> <!--- RFA or Approved to paid --->
			<cfset Status_to_Show = 3 />
			<cfif (Billback_Status_ID EQ 2)>
				<cfset Status_to_Show = 2>
			<cfelseif Billback_Status_ID EQ 3>
				<cfset Status_to_Show = 3>
			</cfif>
		</cfif>

		<cfif Get_Profile_Settings.Mass_Billback_Pay IS 1 AND appSettings.Mass_Pay_Billback IS NOT 0 AND Get_Profile_Settings.BB_Approve IS 1 AND Billback_Status_ID EQ Status_to_Show>
			<!---Let's see if the billback has a program which has mass pay turned on -- all programs on billback must be created with a template that has mass payment --->
			<cfset ShowMassPay = 0>
			<cfquery name="GetTemplateSettingsForBillbackPrograms" datasource="#application.datasource#">
				SELECT Distinct Program_Control_Panel_Options.Mass_Billback_Pay
				FROM			Program_Control_Panel_Options
				INNER JOIN 		Contract_Main
				ON 				Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
				INNER JOIN 		Billback_Program
				ON 				Billback_Program.Program_ID = Contract_Main.Contract_Main_ID
				AND 			Billback_Program.Deleted = 0
				AND 			Billback_Program.Billback_ID = '#Billback_ID#'
			</cfquery>

			<cfif GetTemplateSettingsForBillbackPrograms.Recordcount IS 1>
				<cfif GetTemplateSettingsForBillbackPrograms.Mass_Billback_Pay IS 1>
					<cfset ShowMassPay = 1>
				</cfif>
			</cfif>

			<cfif ShowMassPay IS 1>
				<!---<input type="checkbox" value="#Billback_ID#" name="MassPay_#BillbackReplaced#" onclick="selectedBillbackListManage(this)" >--->
				<td width="15"><span title="Update Billback to Paid Status"><input type="checkbox" class="chkPaid" value="#Billback_ID#" id="chkPaid_#BillbackReplaced#" <cfif listfind(form.massPayBillbackList,Billback_ID) GT 0>CHECKED</cfif>/></span></td>
				<cfelse>
				<td width="15">&nbsp; </td>
			</cfif>
		<cfelse>
				<td width="15">&nbsp; </td>
		</cfif>
		<!--- ................................................................................................................... --->
		<!--- IF BBManualSetPaidStatus QUICK  appSettings.Mass_Pay_Billback  .................................................... --->
		<!--- D32285 : Manually Set BB Status to Paid 			................................................................. --->
		<!--- ................................................................................................................... --->



		<td width="15"> <input class='upload' type='checkbox' title='Select this Billback for documents upload'> </td>
	</TR>
	<!--- D25219: SOW - Enable mass paying of payables START--->
	<cfif (expected_claimed_display) AND (bb_parent EQ 0) AND (BB_Is_Locked EQ 0 OR BB_Locked_By_User_ID EQ request.AccessStructure.User_ID)>
	<tr>
		<td id="#bb_info#" STYLE="display:none; border:solid; border-color: yellow;;height:40px;" colspan="100">

						<table align="center">
						<tr>
							<td style="border: none;">
								<span style="color: red;font-weight:bold;font-size:13px;">[</span>
										<span style="color: blue;"><b>#left(BB_Code, 50)#</b></span>
								<span style="color: red;font-weight:bold;font-size:13px;">]</span>
							</td>
							<td id="#bb_text#" style="display:block;border: none;">
								Approval is in process.
							</td>
						</tr>
					</table>

		</td>
	</tr>
	</cfif>
	<!--- D25219: SOW - Enable mass paying of payables END--->
	</CFOUTPUT>
	</table>
	<cfoutput>
	<cfif form.Source IS "Deductions">
		<input type="hidden" name="Deduction_ID" value="#Deduction_ID#">
		<input type="hidden" name="currentBillbackList" value="#form.currentBillbackList#">
		<input type="hidden" name="Done" value="1">
	</cfif>
	</cfoutput>

	</form>
	<p></p>
<!---
	Dev Notes: D23467/Anand Rao/20-May-10
	 JS error on billback scorecard page
   Added an isDefined checking for FORM.DoSearch to make sure that the javascript
   gets executed only when the user comes from the search page and if he just
   clicks on the billbacks link and comes to this page then the script will not
   get executed, hence will not throw the error.
--->
<cfif isDefined("FORM.DOSEARCH")><cfoutput>
  <script>
<!--- D70951 :: ‘Please Wait’ Indicator     Release START --->
	try {
		//window.parent.clearHandler();
		parent.document.getElementById("divWait1").style.display='none';
		parent.document.getElementById("BBInfo").style.display='block';
		parent.document.getElementById("BBCount").innerHTML='<B>Count : </B> #SC_QUERY.record_count#';
		parent.document.getElementById("BBClaimed").innerHTML='<B>Total Claimed : </B> #dollarformat(SC_QUERY.TotalClaimAmount)#';
		parent.document.getElementById("BBVariance").innerHTML='<B>Variance : </B> #dollarformat(SC_QUERY.TotalVariance)#';
		parent.document.getElementById("headerTable").style.display='';
	}
	catch (error) {
	}
<!--- D70951 :: ‘Please Wait’ Indicator     Release END --->
  </script></cfoutput>
</cfif>
<!--- D25219: SOW - Enable mass paying of payables START--->
<script type="text/javascript" src="/Script/javascript/variable.debugger.js"></script>
<script>
	function PayBillback(bbid, bbinfo, bbtext, type){
		var check = confirm("Do you want to approve/ agree this Billback ?")
		if(check){
		 $('#' + bbid).css('display', 'none');
		 $('#' + bbinfo).css('display', 'block');
					$.ajax({
							"dataType": 'json',
							"type": "POST",
							 url: "ajax/pay_claimed_expected.cfm?BBID="+bbid+"&type="+type,

							 success: function (json) {
								$('#' + bbinfo).css('border-color', 'green');
								$('#' + bbtext).text(json.bbStatus);
								$('#' + bbinfo).delay(25000).hide('slow');
							}
					})
		}
	}
	// D32285 : Manually Set BB Status to Paid 			................................................................. ---
	<!--- 2015 apr 29 chrisn :: replaced $ with jQuery to fix JS errors on IE 8 & IE 9 --->
	jQuery(document).ready(function() {
		//select checkboxes in master list
		var arrMassPayBillbackList =  window.parent.massPayBillbackList;
		jQuery('.chkPaid').each(function(){
			jQuery(this).attr('checked', (jQuery.inArray(jQuery(this).val(), arrMassPayBillbackList) > -1) )
		});
		//check header row check box if necessary
		manageChkAllPaid();
		//alert(window.parent.document.all.SearchForm.massPayBillbackList.value);
		jQuery('#ReturnResults .chkPaid').click(function() {
			var arrBBtoPay = window.parent.massPayBillbackList;
	    	var chkBox = jQuery(this);
			var uid = chkBox.val();
			//if checked and not in list -> add
		    if (chkBox.is(':checked')){
		        // the checkbox was checked add to list
				arrBBtoPay[arrBBtoPay.length++] = uid;
		    } else{
		        // the checkbox was unchecked remove from list
				arrBBtoPay = jQuery.grep(arrBBtoPay, function(value) {
					return value != uid;
				} );
		    }
			window.parent.document.all.SearchForm.massPayBillbackList.value = arrBBtoPay.join();
			window.parent.window.massPayBillbackList = arrBBtoPay;
			manageChkAllPaid();
		});
	});

	function manageChkAllPaid(){
		var arrItems = [];
		var arrItemsChecked = [];
		//get list of items on current page
		arrItems = jQuery('.chkPaid').map(function() {
				return jQuery(this).val();
		}).get();
		//get list of CHECKED items on current page
		arrItemsChecked = jQuery('.chkPaid:checked').map(function() {
				return jQuery(this).val();
		}).get();

		var bool = (arrItems.length == arrItemsChecked.length && arrItemsChecked.length > 0);

		jQuery('#chkAllPaid',window.parent.document).attr('checked', bool );
	}

	document.querySelectorAll( 'input[name=selectedReasons]' ).forEach( e => e.title = 'Select this billback to delete' );
</script>
<!--- D25219: SOW - Enable mass paying of payables END--->
