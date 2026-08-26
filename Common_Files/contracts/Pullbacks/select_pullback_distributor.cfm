<cfset PullbackManager = CreateObject("component","components.programs.pullbacks.PullbackManager") />

<cfset GetDistributors = PullbackManager.GetDistributorlist(CSL_Contract_Main_ID,CSLGetContractInfo.applied_pullbacks)>
<FORM Action="" NAME="DistList" STYLE="DISPLAY:INLINE" STYLE="DISPLAY:INLINE" target="_self">
 <table width="780" class="maintable" CELLPADDING="0" CELLSPACING="0">
 <tr  bgcolor="C6FFC6">
 <TD id="header" style="font-size: 12px;" colspan="100%"> <strong>Select <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput></TD>
</TR>
<TR>
<cfoutput query="GetDistributors">
<TD WIDTH="33%" VALIGN="top" BGCOLOR="F2F2F2"><span ID="checkAllDist"><input type="checkbox" name="distributor_id" value="#GetDistributors.BSA_Foodservice_Customers_id#" checked> #GetDistributors.name# - #shr_ship_to#</span></TD>
<CFIF getDistributors.CURRENTROW MOD 3><CFELSE></TR><TR></CFIF>
</cfoutput>
</TR>
</table>
<cfoutput><input type="hidden" name="contract_main_id" value="#CSL_Contract_Main_ID#">
<input type="hidden" name="FromDistributor_Prg" value="#url.FromDistributor_Prg#">
</cfoutput>
</form>
<br>
<table>
<tr>
<td>
<CF_button

			button_name		=	""
			button_caption	=	"Submit"
			button_action	=	"submitdistdetails();"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Submit"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			></td>
<td><CF_button
			button_name		=	""
			button_caption	=	"Check All"
			button_action	=	"selectalldist(true);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Check All"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			></td>
<td><CF_button
			button_name		=	""
			button_caption	=	"UnCheck All"
			button_action	=	"selectalldist(false);"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Select All"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			></td>
<td><CF_button
			button_name		=	""
			button_caption	=	"Back"
			button_action	=	"history.back()"
			button_type		=	"javascript_link"
			button_width	=	"150"
			button_color	=	"Navy"
			button_tip		=	"Select All"
			font_color		=	"White"
			font_size		=	"14"
			font_weight		=	"bold"
			></td>
</tr>
</TABLE>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<script>
function selectalldist(type){
 var obj = window.checkAllDist; 
			if(obj != null){
				if(obj.length)
				{
					for(var x=0; x<obj.length;x++){
						box = getFirstChild(obj[x])
						if(box.disabled == false)
						{
						box.checked = type;
						}
						else
						{
							box.disabled = true;
						}
					}
				}
				else
				{
					box = getFirstChild(obj)
					box.checked = type;
				}
			}
		}
function submitdistdetails()
{
	
	NewWindow('','pullbackdetails','870','620','Yes', 'No');
	document.DistList.target = 'pullbackdetails';
	document.DistList.action = 'view_pullback_distributor_program_details.cfm?contract_main_id=<cfoutput>#CSL_Contract_Main_ID#</cfoutput>&FromDistributor_Prg=<cfoutput>#url.FromDistributor_Prg#</cfoutput>';
	document.all.DistList.submit();	
	//NewWindow('','pullbackdetails','800','620','Yes', 'No');
	//DistList.submit();
}
</script>