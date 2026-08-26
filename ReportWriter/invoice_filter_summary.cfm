<cfparam name="filter_list" default="" >
<cfparam name="fiscal_period_checked" default="" >
<cfparam name="fiscal_quarter_checked" default="" >
<cfparam name="fiscal_year_checked" default="" >
<!--- check for the selected time span --->
 <cfif ListFind(FORM.history_period, "fiscal_period", ",") GT 0 >
 	<cfset fiscal_period_checked = "YES" >
 <cfelse>
	<cfset fiscal_period_checked = "NO" >
 </cfif> 
 <cfif ListFind(FORM.history_period, "fiscal_quarter", ",") GT 0 >
 	<cfset fiscal_quarter_checked = "YES" >
 <cfelse>
	<cfset fiscal_quarter_checked = "NO" >
 </cfif> 
  <cfif ListFind(FORM.history_period, "fiscal_year", ",") GT 0 >
 	<cfset fiscal_year_checked = "YES" >
 <cfelse>
	<cfset fiscal_year_checked = "NO" >
 </cfif> 
<cfset filSummaryArray = ArrayNew(1) >
<cfset filSummaryList = "Date Span Criteria,Distributor Criteria,Product Criteria,Date Detail" >
<cfset filSummaryArray = ListToArray(filSummaryList, ",") > 

<cfif srNotCSV is false>
<cfoutput>
#trim(filSummaryList)#
#GF_objHandle.getBBToTETLabel()# = #FORM.invoicedate#,#application.returned_customer_setting.zone_label_singular# = <cfif FORM.ZONE_ID EQ 0> ALL <cfelse> #FORM.Zone_Name_Text# </cfif>,#application.returned_customer_setting.type_group_label_singular# = <cfif FORM.TYPE_GROUP_DESC_ID EQ 0>ALL<cfelse>#FORM.Type_Group_Desc_Text#</cfif>,Current Period: #FYPSD# - #FYPED#,History Period: #LFYPSD# - #LFYPED# 
Fiscal Period = #fiscal_period_checked#,#application.returned_customer_setting.region_label_singular# = <cfif REGION_ID EQ 0>ALL<cfelse>#FORM.Region_Name_Text#</cfif>,#application.returned_customer_setting.type_code_label_singular# = <cfif FORM.TYPE_CODE_DESC_ID EQ 0>ALL<cfelse>#FORM.Type_Code_Desc_Text#</cfif>,Current Quarter: #FYQSD# - #FYQED#,History Quarter: #LFYQSD# - #LFYQED# 	
Fiscal Quarter = #fiscal_quarter_checked#,#application.returned_customer_setting.shard_ship_to_label# = <cfif Form.Ship_To EQ "">ANY<cfelse>#Form.Ship_To#</cfif>,Item ## = <cfif Form.item_number EQ "">ALL<cfelse>#FORM.item_number#</cfif>,Current Year: #FYSD# - #FYED#,History Year: #LFYSD# - #LFYED#
Fiscal Year = #fiscal_year_checked#,#application.returned_customer_setting.family_name_label_singular# = <cfif FORM.Family_Name EQ 0>ALL<cfelse>#FORM.Family_Name_Text#</cfif>,Global UOM = <cfif FORM.Global_UOM EQ 1>Case<cfelse>Pound</cfif>
, ,#application.returned_customer_setting.buying_group_label_singular# = <cfif FORM.Buying_Group EQ 0>ALL<cfelse>#FORM.Buying_Group_Text#</cfif>, , ,
</cfoutput>
</cfif>
<cfif srNotCSV>
	<table border="0" id="table1" cellspacing="3" cellpadding="3">
</cfif>
<cfif srNotCSV>
	 <tr>
	  <td colspan="2" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; border-bottom-style: solid; border-bottom-width: 1px" bgcolor="#DFDFDF">
	  <b><cfoutput>#filSummaryArray[1]#</cfoutput>:</b></td>
	  <td width="25" rowspan="6">&nbsp;</td>
	  <td colspan="2" style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; border-bottom-style: solid; border-bottom-width: 1px" bgcolor="#DFDFDF">
	  <b><cfoutput>#filSummaryArray[2]#</cfoutput>:</b></td>
	  <td width="25" rowspan="6">&nbsp;</td>
	  <td style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; border-bottom-style: solid; border-bottom-width: 1px" colspan="2" bgcolor="#DFDFDF">
	  <b><cfoutput>#filSummaryArray[3]#</cfoutput>:</b></td>
	   <td width="25" rowspan="6">&nbsp;</td>    
	   <td style="border-left-width: 1px; border-right-width: 1px; border-top-width: 1px; border-bottom-style: solid; border-bottom-width: 1px" colspan="4" bgcolor="#DFDFDF">
	  <b><cfoutput>#filSummaryArray[4]#</cfoutput>:</b></td>
	 </tr>
 </cfif>
 <cfif srNotCSV>
	 <tr>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; <cfoutput>#GF_objHandle.getBBToTETLabel()#</cfoutput></td>
	  <td bgcolor="#ECEAE6" style="color:#CC0000"><big><strong><cfoutput>#FORM.invoicedate#</cfoutput></strong></big></td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; <cfoutput>#application.returned_customer_setting.zone_label_singular#</cfoutput></td>
	  <td bgcolor="#ECEAE6" <cfif FORM.ZONE_ID NEQ 0>style="color:#CC0000"</cfif>><cfif FORM.ZONE_ID EQ 0> ALL <cfelse><cfoutput> <big><strong>#FORM.Zone_Name_Text#</strong></big> </cfoutput></cfif></td>
	  <td bgcolor="#ECEAE6" width="125"><cfoutput>#application.returned_customer_setting.type_group_label_singular#</cfoutput></td>
	  <td nowrap bgcolor="#ECEAE6" <cfif FORM.TYPE_GROUP_DESC_ID NEQ 0>style="color:#CC0000"</cfif>><cfif FORM.TYPE_GROUP_DESC_ID EQ 0> ALL <cfelse><cfoutput> <big><strong>#FORM.Type_Group_Desc_Text#</strong></big> </cfoutput></cfif></td>
	  <td bgcolor="#ECEAE6" width="125">Current Period</td>
	  <td nowrap bgcolor="#ECEAE6"><cfoutput>#FYPSD# - #FYPED#</cfoutput></td>
	  <td bgcolor="#ECEAE6" width="125">History Period</td>
	  <td nowrap bgcolor="#ECEAE6"><cfoutput>#LFYPSD# - #LFYPED#</cfoutput></td>
	 </tr>
</cfif>
<cfif srNotCSV>
	 <tr>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; Fiscal Period</td>
	  <td bgcolor="#ECEAE6"><cfoutput>#fiscal_period_checked#</cfoutput></td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; <cfoutput>#application.returned_customer_setting.region_label_singular#</cfoutput></td>
	  <td nowrap bgcolor="#ECEAE6" <cfif REGION_ID NEQ 0>style="color:#CC0000"</cfif>><cfif REGION_ID EQ 0> ALL <cfelse><cfoutput> <big><strong>#FORM.Region_Name_Text#</strong></big> </cfoutput></cfif></td>
	  <td bgcolor="#ECEAE6" width="125"><cfoutput>#application.returned_customer_setting.type_code_label_singular#</cfoutput></td>
	  <td nowrap bgcolor="#ECEAE6" <cfif FORM.TYPE_CODE_DESC_ID NEQ 0>style="color:#CC0000"</cfif>><cfif FORM.TYPE_CODE_DESC_ID EQ 0> ALL <cfelse><cfoutput> <big><strong>#FORM.Type_Code_Desc_Text#</strong></big> </cfoutput></cfif></td>
	  <td bgcolor="#ECEAE6" width="125">Current Quarter</td>
	  <td nowrap bgcolor="#ECEAE6"><cfoutput>#FYQSD# - #FYQED#</cfoutput></td>
	  <td bgcolor="#ECEAE6" width="125">History Quarter</td>
	  <td nowrap bgcolor="#ECEAE6"><cfoutput>#LFYQSD# - #LFYQED#</cfoutput></td>
	 </tr>
</cfif>
<cfif srNotCSV> 
	 <tr>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; Fiscal Quarter</td>
	  <td bgcolor="#ECEAE6"><cfoutput>#fiscal_quarter_checked#</cfoutput></td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; <cfoutput>#application.returned_customer_setting.shard_ship_to_label#</cfoutput></td>
	  <td nowrap bgcolor="#ECEAE6" <cfif Form.Ship_To NEQ "">style="color:#CC0000"</cfif>><cfif Form.Ship_To EQ ""> ANY <cfelse><cfoutput> <big><strong>#Form.Ship_To#</strong></big> </cfoutput></cfif></td>
	  <td bgcolor="#ECEAE6" width="125">Item ##</td>
	  <td nowrap bgcolor="#ECEAE6" <cfif Form.item_number NEQ "">style="color:#CC0000"</cfif>><cfif Form.item_number EQ ""> ALL <cfelse><cfoutput> <big><strong>#FORM.item_number#</strong></big> </cfoutput></cfif></td>
	  <td bgcolor="#ECEAE6" width="125">Current Year</td>
	  <td nowrap bgcolor="#ECEAE6"><cfoutput>#FYSD# - #FYED#</cfoutput></td>
	  <td bgcolor="#ECEAE6" width="125">History Year</td>
	  <td nowrap bgcolor="#ECEAE6"><cfoutput>#LFYSD# - #LFYED#</cfoutput></td>
	 </tr>
</cfif>
<cfif srNotCSV> 
	 <tr>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; Fiscal Year</td>
	  <td bgcolor="#ECEAE6"><cfoutput>#fiscal_year_checked#</cfoutput></td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; <cfoutput>#application.returned_customer_setting.family_name_label_singular#</cfoutput></td>
	  <td nowrap bgcolor="#ECEAE6" <cfif FORM.Family_Name NEQ 0>style="color:#CC0000"</cfif>><cfif FORM.Family_Name EQ 0> ALL <cfelse><cfoutput> <big><strong>#FORM.Family_Name_Text#</strong></big> </cfoutput></cfif></td>
	  <td bgcolor="#ECEAE6" width="125">Global UOM</td>
	  <td nowrap bgcolor="#ECEAE6" style="color:#CC0000"><big><strong><cfif FORM.Global_UOM EQ 1>Case<cfelseif FORM.Global_UOM EQ 2>Pound<cfelse>Dollar</cfif></strong></big></td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;</td>
	  <td bgcolor="#ECEAE6">&nbsp;</td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;</td>
	  <td bgcolor="#ECEAE6">&nbsp;</td>
	 </tr>
</cfif>
<cfif srNotCSV> 
	 <tr>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;</td>
	  <td bgcolor="#ECEAE6">&nbsp;</td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;&nbsp; <cfoutput>#application.returned_customer_setting.buying_group_label_singular#</cfoutput></td>
	  <td nowrap bgcolor="#ECEAE6" <cfif FORM.Buying_Group NEQ 0>style="color:#CC0000"</cfif>><cfif FORM.Buying_Group EQ 0> ALL <cfelse><big><strong><cfoutput> #FORM.Buying_Group_Text# </cfoutput></strong></big></cfif></td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;</td>
	  <td bgcolor="#ECEAE6">&nbsp;</td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;</td>
	  <td bgcolor="#ECEAE6">&nbsp;</td>
	  <td bgcolor="#ECEAE6" width="125">&nbsp;</td>
	  <td bgcolor="#ECEAE6">&nbsp;</td>
	 </tr>
</cfif> 
<cfif srNotCSV> 
 	</table> 
</cfif>

