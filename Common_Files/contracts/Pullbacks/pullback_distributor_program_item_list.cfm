
<cfparam name="form.distributorid" default="">
<cfparam name="form.programid" default="">
<cfparam name="programlist" default="">
<cfparam name="productlist" default="">
<cfparam name="default_pullback_rate" default="0">

<cfparam name="FORM.sort_by" 	default="IN">
<cfparam name="form.sql_Sort_By" default="Item">

<CFSWITCH expression="#FORM.sort_by#">
	<CFCASE value="IN">
		<CFSET form.sql_Sort_By="item">
	</CFCASE>
	<CFCASE value="DS">
		<CFSET form.sql_Sort_By="description">
	</CFCASE>	
</CFSWITCH>

<cfif form.programid NEQ "">
<cfif form.distributorid NEQ "">
<cfsilent>
<cfset GetcontractDetails = PullbackManager.GetcontractDetails(form.programid)>
<cfset GetDistDetails = PullbackManager.GetDistDetails(form.distributorid)>
<cfset GetProducts = PullbackManager.GetCurrentProductlist(CSL_Contract_Main_ID,CSLGetContractInfo.applied_pullbacks,form.distributorid,form.programid,form.sql_Sort_By,FORM.sort_order)>

<cfset productlist = valuelist(GetProducts.BSA_Foodservice_items_master_id)>
<cfset getdefaultpullbackrate = PullbackManager.getDefaultPullbackRate(form.programid,getsettings.ProgramControl_Panel_Options_id)>

<cfif getdefaultpullbackrate.recordcount GT 0>
<cfset default_pullback_rate = getdefaultpullbackrate.Pullback_Default_Rate>
</cfif>
</cfsilent>
<cfoutput>
<TABLE CELLPADDING="0" CELLSPACING="0" align="center" width="780" >
<TR  align="left">
<TD align="left"><strong>#application.returned_customer_setting.distributor_label_singular#: #GetDistDetails.name# - #GetDistDetails.shr_ship_to#<br>Contract: #GetcontractDetails.contract_number# - #GetcontractDetails.contract_title#</strong></TD>
</TR>
</TABLE>
</cfoutput>
<FORM ACTION="pullbacks_save.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="SavePullbacks" STYLE="DISPLAY:INLINE">
 <table width="780" class="maintable" CELLPADDING="0" CELLSPACING="0" align="center">
 <tr  bgcolor="C6FFC6">
  <TD><input name="pullback_rate_check_all" type="checkbox" onclick="selectall(0);" checked></TD>
 <TD id="header" style="font-size: 12px;"  valign="top"> <strong><A HREF="##" OnClick="javaScript: setSortHref('IN');"><cfoutput>#application.returned_customer_setting.ITEM_Label#</cfoutput></A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "IN"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <TD id="header" style="font-size: 12px;"  valign="top"> <strong><A HREF="##" OnClick="javaScript: setSortHref('DS');">Description</A></strong>
 <SPAN ID="SP_SP"<CFIF FORM.sort_by NEQ "DS"> STYLE="VISIBILITY:HIDDEN"</CFIF>>&nbsp;<IMG ID="S_IMG" SRC="\Images\<cfoutput>#Current_Image#</cfoutput>"></SPAN>
</td>
 <TD id="header" style="font-size: 12px;"  valign="top"><strong><cfoutput>#appsettings.getPullbackLabel()#</cfoutput> Rate</strong></TD>
 </TR>
 <cfif GetProducts.recordcount GT 0>
 <cfoutput query="GetProducts" group="BSA_Foodservice_items_master_id">
 <TR>
 <TD><span ID="checkAllPullbackstoapplyrate"><input type="checkbox" name="pullback_apply_rate" value="1" checked></span></TD>
 <TD>#item#</TD>
 <TD>#description#</TD>
 <input type="hidden" name="pullback_#Replace(GetProducts.BSA_Foodservice_items_master_id,"-","_","ALL")#" value="1">
<td>
	<cfif qGetProgramUserSettings.Pullback_Modify_Operator_Program_Rates EQ 1>
	<span ID="editPullbackrate"><input type="textbox" name="pullbackvalue_#Replace(GetProducts.BSA_Foodservice_items_master_id,"-","_","ALL")#" value="<cfif GetProducts.pullback_value NEQ 0>#GetProducts.pullback_value#<cfelse>#default_pullback_rate#</cfif>"  size="5" maxsize="4" onKeyUp="clenseText(this, '0123456789')" ></span>%
	<cfelse>
	<cfif GetProducts.pullback_value NEQ 0>#GetProducts.pullback_value#<cfelse>#default_pullback_rate#</cfif>%
	</cfif>
</td>
	
 </TR>
 </cfoutput>
 <cfelse>
 <TR>
 <TD><strong>No Products found.</strong></TD>
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

<input type="hidden" name="pagetype" value="I">
<input type="hidden" name="contract_main_id" value="<cfoutput>#CSL_Contract_Main_ID#</cfoutput>">
<input type="hidden" name="distributorid" value="<cfoutput>#form.distributorid#</cfoutput>">
<input type="hidden" name="programid" value="<cfoutput>#form.programid#</cfoutput>">
<input type="hidden" name="productlist" value="<cfoutput>#productlist#</cfoutput>">
</FORM>

<FORM ACTION="pullback_index.cfm?CID=<CFOUTPUT>#url.CID#</CFOUTPUT>&margincheck=<cfoutput>#url.margincheck#</cfoutput>" METHOD="post" NAME="DistPrograms" STYLE="DISPLAY:INLINE">
<input type="hidden" name="pagetype" value="I">
<input type="hidden" name="programId" value="<cfoutput>#form.programid#</cfoutput>">
<input type="hidden" name="distributorid" value="<cfoutput>#form.distributorid#</cfoutput>">
<input type="hidden" name="applied_pullbacks" value="<cfoutput>#form.applied_pullbacks#</cfoutput>">
<input type="hidden" name="command" value="edit">
<input type="hidden" name="sort_by" value="">
<input type="hidden" name="sort_Order" value="">
</FORM>
<script>
 function submitForm1(thisForm)
	{
			thisForm.submit();
			return false;
		
	}
	function pullbacksMain()
{
location.href ='/Common_Files/contracts/Pullbacks/pullback_index.cfm?CID=<cfoutput>#URL.CID#</cfoutput>';
}
	function basicInformation()
{
location.href ='/Common_Files/contracts/contract_edit_menu.cfm?CID=<cfoutput>#URL.CID#</cfoutput>';
}
</script>
<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">Error in reading the <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> Name. Please try again.</span><br><br>
</cfif>
<cfelse>
<span STYLE="font: bold 14px sans-serif; color: red;">Error in reading the Contract Number. Please try again.</span><br><br>

</cfif>