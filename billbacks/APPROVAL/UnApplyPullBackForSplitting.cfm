<cfset appSettings = application.oApplicationAppSettingsManager.getApplicationAppSettings() />
<FORM ACTION="pullbacksapply_action.cfm" METHOD="post" NAME="ApplyPullbacksAction">
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Pullback --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
	<INPUT TYPE="Hidden" NAME="ForSplitRemovePullBack" VALUE="1">
	<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />
	
	<!--- Get all the Opr and Local Dis BB that are already applied to this current Dis Corp BB --->
	<cfset GetBillbackstoApply = PullbackManager.GetBillbackstoApply(Dis_BB_Id=Parent,appliedpullbacks=1)>	
	<!--- Check if any Growth pullback amount is applied to this current BB --->
	<cfset checkifBBhasGrowth = PullbackManager.checkifBBhasGrowth(Parent,1)>
	
	<cfif checkifBBhasGrowth.recordcount GT 0>
	<cfloop query="checkifBBhasGrowth">
		<cfset temp = QueryAddRow(GetBillbackstoApply)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_billback_id", checkifBBhasGrowth.pullback_billback_id )>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_from_program_number", checkifBBhasGrowth.pullback_from_program_number)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "BB_title",checkifBBhasGrowth.BB_title)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_reference",checkifBBhasGrowth.bb_reference )>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_code",checkifBBhasGrowth.bb_code )>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_start_date", checkifBBhasGrowth.bb_start_date)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "bb_end_date",checkifBBhasGrowth.bb_end_date )>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "contract_number",checkifBBhasGrowth.contract_number )>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "revision_version", checkifBBhasGrowth.revision_version)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "discount_type_desc", checkifBBhasGrowth.discount_type_desc)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "discount_type_id", checkifBBhasGrowth.discount_type_id)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "Product_BB_Volume_LB", checkifBBhasGrowth.Volume_LB)>
		<cfset Temp = QuerySetCell(GetBillbackstoApply, "pullback_amount", checkifBBhasGrowth.pullback_amount)>
	</cfloop>
	</cfif>
		
	<cfset useLakebaseForSortBillbackstoApply = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("getbillbackstoapply")>
<cfif useLakebaseForSortBillbackstoApply>
	<cftry>
		<cfset SortBillbackstoApply = application.oLakebase.toQuery(
			application.oLakebase.selectRows("getbillbackstoapply", {
				"order" = "pullback_billback_id.asc"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForSortBillbackstoApply = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForSortBillbackstoApply>
<cfquery name="SortBillbackstoApply" dbtype="query">
	select * from
	GetBillbackstoApply
	order by pullback_billback_id
	</cfquery>
</cfif>		
	
	<cfoutput query="SortBillbackstoApply">
	<input type="Hidden" name="pullback_billback_ids" value="#pullback_billback_id#_#discount_type_id#_#product_id#">
	<input type="Hidden" name="pullback_billback_#replace(pullback_billback_id,'-','_','ALL')#_#discount_type_id#_#replace(product_id,'-','_','ALL')#_amount" value="#pullback_amount#">
	<input type="Hidden" name="pullback_billback_#replace(pullback_billback_id,'-','_','ALL')#_#discount_type_id#_#replace(product_id,'-','_','ALL')#_rate" value="#paid_rate#">				
	<cfif discount_type_id EQ 4>
	<input type="Hidden" name="pullback_billback_growth_ids" value="#pullback_billback_id#">
	<input type="hidden" name="growthamount_#replace(pullback_billback_id,'-','_','ALL')#" value="#GrowthPullbackAmount#">
	<input type="hidden" name="growthvolume_#replace(pullback_billback_id,'-','_','ALL')#" value="#Product_BB_Volume_LB#">
	</cfif>
	</cfoutput>	
	<input type="hidden" name="Dis_BB_Id" value="<cfoutput>#Parent#</cfoutput>">
	<input type="hidden" name="unapplypullbacks" value="1">

<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- End Pullback --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
</FORM>	

<TABLE ALIGN="Center">
<TR>
	<TD> <BR><BR><BR><BR>
		<FONT COLOR="Red" SIZE="2"><B>You cannot split a billback that has <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput> applied. To split the billback, first click on "Unapply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>" to remove any pullbacks from the billback.</B></FONT>
	</TD>
</TR>
<TR>
<TD ALIGN="Center"><BR><Br>
<CF_button
			button_name		=	""
			button_caption	=	"unapply <cfoutput>#appsettings.getPullbackLabelLower()#</cfoutput>"
			button_action	=	"UnApplyPullbacks();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"UnApply <cfoutput>#appsettings.getPullbackLabel()#</cfoutput>"
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
			>
</TD>
</TR>
</TABLE>

<SCRIPT language="JavaScript">
function UnApplyPullbacks()
{
	document.all.ApplyPullbacksAction.submit();
}
</SCRIPT>
