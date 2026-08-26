
<cfparam name="form.distributorid" default="">
<cfparam name="programlist" default="">
<cfparam name="productlist" default="">

<cfparam name="FORM.sort_by" 	default="CN">
<cfparam name="form.sql_Sort_By" default="contract_number">

<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="CN">
		<CFSET form.sql_Sort_By="contract_number">
	</CFCASE>
	<CFCASE value="CT">
		<CFSET form.sql_Sort_By="contract_title">
	</CFCASE>	
	<CFCASE value="TM">
		<CFSET form.sql_Sort_By="Program_Control_Panel_Options.created_type">
	</CFCASE>	
</CFSWITCH>

<cfif form.distributorid NEQ "">

<cfset getDisCorpPorgrams = PullbackManager.getDisCorpPorgrams(form.distributorid,
CSLGetContractInfo.contract_end_date,CSLGetContractInfo.contract_start_date,getsettings.pullback_template_type,
CSLGetContractInfo.applied_pullbacks,CSL_Contract_Main_ID,
form.sql_Sort_By,FORM.sort_order,GetSettings.ProgramControl_Panel_Options_id)>
<cfset GetProducts = PullbackManager.GetProductlist(CSL_Contract_Main_ID)>
	<cfset IsGroupProducts = PullbackManager.GetProductGroup(CSL_Contract_Main_ID)>
<cfset GetDistDetails = PullbackManager.GetDistDetails(form.distributorid)>

<cfset programlist = valuelist(getDisCorpPorgrams.contract_main_id)>
<cfset productlist = valuelist(GetProducts.BSA_Foodservice_items_master_id)>
<cfoutput>
<TABLE CELLPADDING="0" CELLSPACING="0" align="center" width="760" >
<TR  align="left">
<TD align="left"><strong>#application.returned_customer_setting.distributor_label_singular#: #GetDistDetails.name# - #GetDistDetails.shr_ship_to#</strong></TD>
</TR>
</TABLE>
</cfoutput>
<FORM ACTION="pullbacks_save.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="SavePullbacks" STYLE="DISPLAY:INLINE">
 <table width="760" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center">
 <tr  bgcolor="C6FFC6">
  <TD><input name="pullback_rate_check_all" type="checkbox" onclick="selectall(0);" checked></TD>
<TD id="header" style="font-size: 12px;" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('TM');"><B>Template</B></A>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <TD id="header" style="font-size: 12px;" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CN');"><B>Contract Number</B></A>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
  <TD id="header" style="font-size: 12px;" valign="top"><A HREF="##" OnClick="javaScript: setSortHref('CT');"><B>Contract Title</B></A>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "CT"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <TD id="header" style="font-size: 12px;" valign="top"> <strong>Start Date<br>End Date</strong></TD>
 <TD id="header" style="font-size: 12px;" valign="top"><strong><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate</strong></TD>
  <TD id="header" style="font-size: 12px;" valign="top">&nbsp;</td>
 </TR>
 <cfif getDisCorpPorgrams.recordcount GT 0>
 <cfoutput query="getDisCorpPorgrams" group="contract_main_id">
 <TR>
 <TD><span ID="checkAllPullbackstoapplyrate"><input type="checkbox" name="pullback_apply_rate" value="1" checked></span></TD>
 <TD>#created_type#</TD>
 <TD><A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="getdistprogramitems('#getDisCorpPorgrams.contract_main_id#');">#Contract_Number#</A></TD>
 <TD>#contract_title#</TD>
 <TD>#dateformat(contract_start_date,"mm/dd/yyyy")#<br>#dateformat(contract_end_date,"mm/dd/yyyy")#</TD>
<input type="hidden" name="pullback_#getDisCorpPorgrams.contract_main_id#" value="1">
<td>
	<cfif qGetProgramUserSettings.Pullback_Modify_Operator_Program_Rates EQ 1>
	<span ID="editPullbackrate"><input type="textbox" name="pullbackvalue_#getDisCorpPorgrams.contract_main_id#" value="<cfif trim(getDisCorpPorgrams.Pullback_Level) NEQ "P">*<cfelse>#getDisCorpPorgrams.pullback_value#</cfif>"  size="5" maxsize="4" onKeyUp="clenseText(this, '0123456789')" <cfif trim(getDisCorpPorgrams.Pullback_Level) NEQ "P">disabled</cfif>></span>%
	<cfelse>
	<cfif trim(getDisCorpPorgrams.Pullback_Level) NEQ "P">*<cfelse>#getDisCorpPorgrams.pullback_value#</cfif>%
	</cfif>

</td>
<TD><cfif trim(getDisCorpPorgrams.Pullback_Level) NEQ "P">
<A STYLE="cursor:pointer;" ONCLICK="changeDisableOtherCheckBoxes( document.all.pullbackvalue_#getDisCorpPorgrams.contract_main_id#,document.all.pullback_#getDisCorpPorgrams.contract_main_id#,pullback_level_#getDisCorpPorgrams.contract_main_id#)"><img src="/images/pm_edit.gif"></A>
<CFMODULE template="/CustomTags/SmallHelp.cfm"
					width = "280"
					height = "50"
					imgPath="/Images/Asterix.gif"
					imgWidth="10"
					imgHeight="10"
					dropdownCheck=0
					displayShifyX="-280"
					>
An asterick in the #LCase(appsettings.getPullbackLabel())# % field indicates the #LCase(appsettings.getPullbackLabel())# rate has been applied at the product level, instead of the program level.  
The asterisk cannot be changed unless you decide to apply the #LCase(appsettings.getPullbackLabel())# rate at the program level.  
If you would like to change the #LCase(appsettings.getPullbackLabel())# rate to be at the program level, click on the icon <img src="/images/pm_edit.gif" border="0" />.  
By clicking on this icon it will unlock the #LCase(appsettings.getPullbackLabel())# % field so you can delete the asterisk and type in a percentage to #LCase(appsettings.getPullbackLabel())# at the program level.
					</cfmodule>
					<cfelse>&nbsp;</cfif><input type="hidden" name="pullback_level_#getDisCorpPorgrams.contract_main_id#" value="#trim(getDisCorpPorgrams.Pullback_Level)#"></td>
 </TR>
 </cfoutput>
 <cfelse>
 <TR>
 <TD><strong>No Programs found.</strong></TD>
 </TR>
  </cfif>
</TABLE>

<TABLE CELLPADDING="0" CELLSPACING="0" align="center" width="780" >
 <tr>
 <td colspan="100%">&nbsp; </td>
 </tr>
<cfif qGetProgramUserSettings.Pullback_Modify_Operator_Program_Rates EQ 1>
 <tr> <!---<cfif getDisCorpPorgrams.recordcount GT 0>--->
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Save"
			button_action	=	"submitForm1(document.SavePullbacks);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Save <cfoutput>#appsettings.getPullbackLabel()#</cfoutput>"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>		
		</td>
		<td>&nbsp; </td>
		<!---</cfif>--->
		
		</tr>
		 <tr>
 <td colspan="100%">&nbsp; </td>
 </tr>
</cfif>
		<tr>
		
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Back"
			button_action	=	"goback();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Go Back"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"<cfoutput>#appsettings.getPullbackLabel()#</cfoutput> main page"
			button_action	=	"pullbacksMain();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Go Back"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		</td>
		
		<td align="left">
		<CF_button
			button_name		=	""
			button_caption	=	"Continue to program summary"
			button_action	=	"basicInformation();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Continue to program summary"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
		
		</td>
		</tr>
</table>
<input type="hidden" name="pagetype" value="P">
<input type="hidden" name="contract_main_id" value="<cfoutput>#CSL_Contract_Main_ID#</cfoutput>">
<input type="hidden" name="distributorid" value="<cfoutput>#form.distributorid#</cfoutput>">
<input type="hidden" name="programlist" value="<cfoutput>#programlist#</cfoutput>">
<input type="hidden" name="productlist" value="<cfoutput>#productlist#</cfoutput>">
</FORM>

<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="DistPrograms" STYLE="DISPLAY:INLINE">
<input type="hidden" name="pagetype" value="I">
<input type="hidden" name="programId" value="">
<input type="hidden" name="distributorid" value="<cfoutput>#form.distributorid#</cfoutput>">
<input type="hidden" name="applied_pullbacks" value="<cfoutput>#form.applied_pullbacks#</cfoutput>">
<input type="hidden" name="command" value="edit">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
</FORM>
<script>
 function submitForm1(thisForm)
	{
			<cfif listlen(productlist) GT 0>
			thisForm.submit();
			return false;
			<cfelse>
					<cfif IsGroupProducts EQ 0>
						alert("Please select products for the discount types before you save");
					<cfelse>
						alert(" Please select products for the discount types before you save. \n For product groups, please Apply Volume for the program.");
					</cfif>
			</cfif>
	}

function basicInformation()
{
location.href ='/Common_Files/contracts/contract_edit_menu.cfm?CID=<cfoutput>#URL.CID#</cfoutput>';
}
	function pullbacksMain()
{
location.href ='/Common_Files/contracts/Pullbacks/pullback_index.cfm?CID=<cfoutput>#URL.CID#</cfoutput>';
}
	
function getdistprogramitems(programId)
{
document.DistPrograms.sort_by.value = "IN";
document.DistPrograms.sort_Order.value = 'DESC';
document.DistPrograms.programId.value = programId;
document.DistPrograms.submit();
}
</script>
<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;width:800px">Error in reading the Distributor Name. Please try again.</span><br><br>
</cfif>