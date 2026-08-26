<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings()>
<CFSET PAGE_TITLE= "#appsettings.getPullbackLabel()#">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BACKGROUND="" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0" ONLOAD="">
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
	
<cf_cryp type="de" key="#request.key#" string="#URL.CID#">
<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "pullbacks"> 
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>
<cfparam name="url.error" default="">
<cfparam name="form.command" 	default="">
<cfparam name="form.viewtype" 	default="">
<cfparam name="form.pagetype" default="D">
<cfparam name="form.distributorId" default="">
<cfparam name="form.programId" default="">
<cfparam name="url.FromDistributor_Prg" default="0">
<cfparam name="form.FromDistributor_Prg" default="0">
<cfparam name="url.margincheck" default="0">
<cfparam name="FORM.sort_order" 	default="DESC">
<cfparam name="checkifdistributorsadded" default="0">
<cfparam name="checkifproductsadded" default="0">
<cfparam name="checkifanypullbacksapplied" default="0">
<cfif form.pagetype EQ "D">
<cfparam name="FORM.sort_by" default="DN">
<cfelseif form.pagetype EQ "P">
<cfparam name="FORM.sort_by" default="CN">
<cfelseif form.pagetype EQ "I">
<cfparam name="FORM.sort_by" default="IN">
<cfelse>
<cfparam name="FORM.sort_by" default="">
</cfif>

<cfif form.FromDistributor_Prg IS 1>
	<cfset url.FromDistributor_Prg = 1>
</cfif>

<CFSET ASC_IMG="down_1.gif">
<CFSET DESC_IMG="up_1.gif">

<cfset checksortby = FORM.sort_by>
<CFIF FORM.sort_order EQ "ASC">
	<CFSET Current_Image = ASC_IMG>
<CFELSE>
	<CFSET Current_Image = DESC_IMG>			
</CFIF>

<cfif url.error NEQ "">
<cfif url.error EQ "C">
<span STYLE="font: bold 14px sans-serif; color: red;width:800px">Error in reading the contract number. Please try again.</span><br><br>
<cfelseif url.error EQ "D">
<span STYLE="font: bold 14px sans-serif; color: red;width:800px"><cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> List is empty. Please try again.</span><br><br>
<cfelseif url.error EQ "P">
<span STYLE="font: bold 14px sans-serif; color: red;width:800px">No Corporate programs are found.</span><br><br>
</cfif>
</cfif>

<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
<cfset checkifanypullbacksapplied = PullbackManager.checkifanypullbacksapplied(CSL_Contract_Main_ID)>

<cfset oProgram = CreateObject("component", "components.programs.program") />
<cfset qGetProgramUserSettings = oProgram.getProgramUserSettings() />

<cfif url.margincheck NEQ 1>
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="/common_files/contracts/contract_status_legend.cfm">
</cfif>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 160px; top: 0px;"> </cfif>
<cfinclude template="/common_files/contracts/minimal_contract_info.cfm">

<cfelse>
<CFQUERY NAME="CSLGetContractInfo" datasource="#application.datasource#">
	SELECT 	Program_Control_Panel_Options.Created_Type, Program_Control_Panel_Options.BidRequestStatusOn, Program_Control_Panel_Options.BidRequestStatusChangePgmStatus, dbo.Program_Control_Panel_Options.Generic_Type,Program_Control_Panel_Options.revision_not_allowed,
Program_Control_Panel_Options.copy_not_allowed,Program_Control_Panel_Options.pullbacks_on,
Contract_Main.Contract_Status_Type_IDX,applied_pullbacks,programtype_id,contract_end_date, contract_start_date, Contract_Main_ID
FROM 	Contract_Main
INNER JOIN	Program_Control_Panel_Options
ON 		Contract_Main.ProgramType_ID = Program_Control_Panel_Options.ProgramControl_Panel_Options_ID
WHERE 	Contract_Main.Contract_Main_ID = '#CSL_Contract_Main_ID#'
</CFQUERY>
<cfquery name="GetSettings" datasource="#application.datasource#">
	SELECT *
	FROM Program_Control_Panel_Options
	WHERE ProgramControl_Panel_Options_ID = '#trim(CSLGetContractInfo.programtype_id)#'
</cfquery>
<cfset Contract_Main_ID = CSL_Contract_Main_ID>
<cfif url.margincheck EQ 1>
<cfinclude template="/common_files/contracts/discount_queries.cfm">
</cfif>
<!--- check if any products/distributors added or removed after pullbacks are applied --->
<cfset checkifdistributorsadded = PullbackManager.checkifdistributorsadded(CSL_Contract_Main_ID)>
<cfset checkifproductsadded = PullbackManager.checkifproductsadded(CSL_Contract_Main_ID)>
<cfset checkifproductsremoved = PullbackManager.checkifproductsremoved(CSL_Contract_Main_ID)>
<cfset checkifdistributorsremoved = PullbackManager.checkifdistributorsremoved(CSL_Contract_Main_ID)>
</cfif>
<cfparam name="form.applied_pullbacks" default="#CSLGetContractInfo.applied_pullbacks#">
<span align="center" STYLE="font: bold 14px sans-serif; color: Navy;"><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Information</span><br><br>

<!--- if pullbacks are applied on any one of the distributors and if the calling page is Dis Corp program and want to view pullbacks by customer --->
<cfif (checkifanypullbacksapplied GT 0 OR url.FromDistributor_Prg EQ 1) and form.viewtype EQ "custview">
	<cfinclude template="select_pullback_distributor.cfm">
<!--- if pullbacks are applied on any one of the distributors and if the calling page is Dis Corp program and want to view pullbacks by template --->
<cfelseif (checkifanypullbacksapplied GT 0 OR url.FromDistributor_Prg EQ 1) and form.viewtype EQ "templateview">
	<cfinclude template="view_pullback_distributor_template_details.cfm">
<!--- if pullbacks are not applied on any one of the distributors and if the calling page is NOT Dis Corp program(the calling program can be either Local Dis or Opr prg) and want to edit pullback rules --->
<cfelseif ((checkifanypullbacksapplied EQ 0 OR form.command EQ "edit") and url.FromDistributor_Prg EQ 0) OR (url.margincheck EQ 1 and url.FromDistributor_Prg EQ 0)>
<cfif form.pagetype NEQ "D" and qGetProgramUserSettings.Pullback_Modify_Operator_Program_Rates EQ 1>
<div id="Layer7" style="position:relative; width:500px; height:0px; z-index:3; left: 550px; top: -20px;">
<B><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate:</B> <INPUT TYPE="Text" NAME="pullback_amount" SIZE="3" ONKEYUP="clenseText(this, '.0123456789'); threeDecimalPlaces(this);" onblur="threeDecimalPlaces(this)" maxsize="4">
<FONT COLOR="Red"><B>[ </B></FONT><A ONCLICK="ApplyAmountToSelectedBoxes()" STYLE="cursor: pointer;"><strong>apply rate</strong></A><FONT COLOR="Red"><B> ]</B></FONT>
</div>
</cfif>
<!--- If the current page is edit distributor pullbacks --->
	<cfif (form.pagetype EQ "D" and url.FromDistributor_Prg EQ 0)>
	<cfif url.margincheck EQ 1 and url.FromDistributor_Prg EQ 0>
	<cfif checkifproductsadded GT 0 or checkifdistributorsadded GT 0 or checkifproductsremoved GT 0 or checkifdistributorsremoved GT 0>
	<TABLE CELLPADDING="0" CELLSPACING="0" align="center" width="780" >
	<TR  align="left">
	<TD align="left"><font color="red"><cfif checkifproductsadded GT 0 OR checkifproductsremoved GT 0><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> are not applied to all products on the program.</cfif></font></TD>
	</TR>
	<TR  align="left">
	<TD align="left"><font color="red"><cfif checkifdistributorsadded GT 0 GT checkifdistributorsremoved GT 0><cfoutput>#appsettings.getPullbackLabel()#</cfoutput>s are not applied to all <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> on the program.</cfif></font></TD>
	</TR>
	</TABLE>
	</cfif>
	</cfif>
		<cfinclude template="pullback_distributor_list.cfm">
	<!--- If the current page is edit distributor-programs pullback values --->
	<cfelseif form.pagetype EQ "P" and url.FromDistributor_Prg EQ 0>
		<cfinclude template="pullback_distributor_program_list.cfm">
	<!--- If the current page is edit distributor-programs-items pullback values --->
	<cfelseif form.pagetype EQ "I" and url.FromDistributor_Prg EQ 0>
		<cfinclude template="pullback_distributor_program_item_list.cfm">
	</cfif>

<cfelseif url.FromDistributor_Prg EQ 1>
<cfinclude template="apply_template_defaultpullbackrates.cfm">
<!--- If the calling page is either Dis Corp program or pullbacks are applied on opr or local Dis program, give an option to either view by template/customer and edit(on opr or Local Dis if the contract status is less than 3 --->
<cfelseif (checkifanypullbacksapplied GT 0)>
<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&FromDistributor_Prg=<cfoutput>#url.FromDistributor_Prg#</cfoutput>" METHOD="post" NAME="ViewPullbacks" STYLE="DISPLAY:INLINE">
 <table>
 <tr>
 <td style="font-size: 12px;" nowrap>
 <b>View <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> rates? </b>
 </td>
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Template View"
			button_action	=	"submitForm(document.ViewPullbacks, 'View','templateview');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"View <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rates"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			>
		</td>
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"<cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> View"
			button_action	=	"submitForm(document.ViewPullbacks, 'View','custview');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"View <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rates"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			>
		</td>
		<cfif CSLGetContractInfo.Contract_Status_Type_IDX LT 3 and url.FromDistributor_Prg EQ 0>
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Edit <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rates"
			button_action	=	"submitForm(document.ViewPullbacks, 'Edit','');"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Edit <cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rates"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			>
		</td>
		</cfif>
	</tr>
 </table>
<cfoutput> <input type="hidden" name="command" value="#form.command#">
  <input type="hidden" name="viewtype" value="#form.viewtype#"></cfoutput>
</FORM>
</cfif>
<!--- </cfif> --->

<cfif url.margincheck NEQ 1>
<cfif application.programlayout EQ 1></div></cfif>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
</cfif>
<script>
 function submitForm(thisForm, sCommand, vType)
	{
		thisForm.command.value = sCommand;
		if (vType != "")
		{
		thisForm.viewtype.value = vType;
		}
		thisForm.submit();
		return false;
	}
</script>

<SCRIPT LANGUAGE="javaScript">
	function getParentObject(thisObj, tagName)
	{
		if(thisObj.tagName.toLowerCase() == tagName.toLowerCase())
		{
			return thisObj;
		}
		else if(thisObj.tagName.toLowerCase() == "body")
		{
			return null;
		}
		else
		{
			return getParentObject(thisObj.parentElement, tagName);
		}
	}
	var sortBy;
	var sort_order;
	var orderFileName;
	
	initialise();
	function initialise()
	{		
		sortBy = "<cfoutput>#checksortby#</cfoutput>";
		<CFIF FORM.sort_order EQ "ASC">
			sort_order = 1;
		<CFELSE>
			sort_order = 0;		
		</CFIF>
		orderFileName = "<cfoutput>#Current_Image#</cfoutput>";
	}
	function setSortHref(sortVal)
	{
		if(sortBy == sortVal)
		{
			sort_order *= -1;
		}
		else
		{
			sort_order = 1;
			sortBy = sortVal;
		}
		var SORTORDER;
		
		if(sort_order < 0)
		{
			SORTORDER = "DESC";
			orderFileName = "<cfoutput>#DESC_IMG#</cfoutput>";
		}
		else
		{
			SORTORDER = "ASC";
			orderFileName = "<cfoutput>#ASC_IMG#</cfoutput>";
		}
		document.DistPrograms.pagetype.value = '<cfoutput>#form.pagetype#</cfoutput>';
		document.DistPrograms.sort_by.value = sortVal;
		document.DistPrograms.sort_Order.value = SORTORDER;
		
		var thisCell = getParentObject(event.srcElement,"TD");		
		//setSortImage(thisCell);
		document.DistPrograms.submit();
	}
	/*
	function setSortImage(thisCell)
	{
		
		var thisSPObj = thisCell.all.SP_SP;
		var spObjs = document.all.SP_SP;
		var i;
		alert(orderFileName);
		for(i=0;i<spObjs.length;i++)
		{
			if(spObjs[i] == thisSPObj)
			{
				spObjs[i].all.S_IMG.src = "/Images/" + orderFileName;
				alert(spObjs[i].all.S_IMG.src);
				spObjs[i].style.visibility = "visible";
			}
			else
			{
				spObjs[i].style.visibility = "hidden";
			}
		}	
	}*/
</SCRIPT>
<script>
function selectall(type){
if (type == 0)
{
var obj = window.checkAllPullbackstoapplyrate;
}
 else 
{
var obj = window.checkAllPullbacks;
}
			if(obj != null){
				if(obj.length)
				{
					for(var x=0; x<obj.length;x++){
						box = getFirstChild(obj[x])
						if(box.disabled == false)
						{
						if (type == 0)
						box.checked = document.all.pullback_rate_check_all.checked
						else
						box.checked = document.all.pullback_check_all.checked
						}
						else
						{
							box.disabled = true
						}
					}
				}
				else
				{
					box = getFirstChild(obj)
					if (type == 0)
					box.checked = document.all.pullback_rate_check_all.checked
					else
					box.checked = document.all.pullback_check_all.checked
				}
			}
}
function threeDecimalPlaces(textObject){		
			if(event.type == "keyup") {
				
				if(textObject.value.indexOf(".") != -1) {
					if(textObject.value.length - textObject.value.indexOf(".") >= 0) {
						var validNumber = new NumberFormat();
						validNumber.setCommas(false);
						validNumber.setCurrency(false);
						validNumber.setPlaces(0);		
						validNumber.setNumber(textObject.value);
						textObject.value = validNumber.toFormatted();
					}
				}
			}
			
			if(event.type == "blur") {
				var validNumber = new NumberFormat();
				validNumber.setCommas(false);
				validNumber.setCurrency(false);
				validNumber.setPlaces(0);		
				validNumber.setNumber(textObject.value);
				textObject.value = validNumber.toFormatted();			
			}
		}		
<!--- Dev Note: Clay 10067: Modified this function to check if the form fields are enabled prior to updating their values --->
function ApplyAmountToSelectedBoxes(){
var obj1 = window.checkAllPullbackstoapplyrate; 
var obj2 = window.editPullbackrate;

if(obj1 != null){
				if(obj1.length)
				{
					for(var x=0; x<obj1.length;x++){
						box = getFirstChild(obj1[x]);
						if(box.checked == true)
						{
						rate = getFirstChild(obj2[x]);
							if(getFirstChild(obj2[x]).disabled == false)
							{
								//pullbackchecked = obj3[x].firstChild;
								rate.value = document.all.pullback_amount.value;
								//pullbackchecked.checked = box.checked;
							}
						}
					}
				}
				else
				{
					box = getFirstChild(obj1);
					if(box.checked)
					{
						rate = getFirstChild(obj2);
						if(getFirstChild(obj2).disabled == false)
						{
							rate.value = document.all.pullback_amount.value;
						}
					}
				}
			}
}
</script>

<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="PullbackInfoGoBack" STYLE="DISPLAY:INLINE">
<input type="hidden" name="pagetype" value="D">
<input type="hidden" name="programId" value="<cfoutput>#CSL_Contract_Main_ID#</cfoutput>">
<input type="hidden" name="distributorid" value="<cfoutput>#form.distributorid#</cfoutput>">
<input type="hidden" name="command" value="edit">
</FORM>

<script>
function goback()
{
<cfif form.pagetype EQ "I">
document.all.PullbackInfoGoBack.pagetype.value = 'P';
</cfif>
document.all.PullbackInfoGoBack.submit();
}
function changeDisableOtherCheckBoxes(OtherObj,OtherObj2,PullbackType)
{	
	OtherObj.disabled = !(OtherObj.disabled);
	OtherObj.value = 0;
	PullbackType.value = 'P'

}
</script>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BODY>
</HTML>