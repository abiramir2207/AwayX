<cfif isDefined("stError")>
	
	<script>
	<cfoutput>		
	<cfif stError.bNameExists EQ 1>
		alert("This alias already exists. You cannot create two entries with the same alias.");		
	</cfif>
	</cfoutput>
	</script>
</cfif>
<cfoutput>

	<CF_MessageWindow>

<cfparam name="form.Distributor_Alias" 	default="">
<cfparam name="form.Distributor_List" 	default="">

<cfif len(trim(compId)) GT 0 AND len(trim(form.Distributor_List)) LT 1 AND len(trim(form.Distributor_Alias)) LT 1>
	<!--- Edit option --->
	<cfset compAlias = CreateObject("component","components.settings.AliasManagement.Alias")>
	<cfset GetAlias = compAlias.searchAlias("","","","",1,compId)>

	<cfif GetAlias.Recordcount GT 0>
		<cfset form.Distributor_Alias = GetAlias.Alias_String>
		<cfset form.Distributor_List = GetAlias.Alias_Item_ID>
	</cfif>
	
</cfif>

<FIELDSET STYLE="padding:10px; width: 800px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#application.returned_customer_setting.distributor_label_singular# Alias Information</LEGEND>
	<table width="90%" border="0">
		<colgroup>
		<col width="30%"></col>
		<col width="30%"></col>
		</colgroup>
		
		<tr><td colspan="2" class="SectionHeader">#application.returned_customer_setting.distributor_label_singular# Alias</td></tr>
		
			<!--- Distributor Alias  --->
				<TR>
					<TD ALIGN="right"><B>#application.returned_customer_setting.distributor_label_singular# Alias Text:</B><br>(What people call the #application.returned_customer_setting.distributor_label_singular#)</TD>
					<TD><span id="error_DistributorAlias1"></span><span id="error_DistributorAlias2"></span><span id="error_DistributorAlias3"></span><INPUT NAME="Distributor_Alias" TYPE="text" VALUE="#form.Distributor_Alias#" SIZE="30" MAXLENGTH="50"></TD>
				</TR>
				
				<cfif len(trim(form.distributor_list)) GT 0>
				<tr>	
				<td align="right"><strong>Selected #lcase(application.returned_customer_setting.distributor_label_singular)#:</strong></td>
				
				<cfset useLakebaseForGetDistributorInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForGetDistributorInfo>
	<cftry>
		<cfset GetDistributorInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"bsa_foodservice_customers_id" = "eq.#form.distributor_list#",
				"select" = "name,shr_ship_to"
			}), "name,shr_ship_to"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetDistributorInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetDistributorInfo>
<cfquery name="GetDistributorInfo" datasource="#application.datasource#">
				select name, shr_ship_to
				FROM BSA_Foodservice_Customers
				WHERE BSA_Foodservice_Customers_ID = '#form.distributor_list#'
				</cfquery>
</cfif>
				
				<td>#GetDistributorInfo.name# (#GetDistributorInfo.shr_ship_to#)</td>
					
				</tr>
				</cfif>
				
					<TR>
				<TD ALIGN="right">
				
				<cfif len(trim(form.distributor_list)) GT 0>
				<strong>Search for a different #lcase(application.returned_customer_setting.distributor_label_singular)#</strong>:
				<cfelse><B>Search for #lcase(application.returned_customer_setting.distributor_label_singular)#:</B></TD>
				</cfif>

				<TD>
				<CF_smallLink 
				title = "search for #lcase(application.returned_customer_setting.distributor_label_singular)#" 
				url = "##"
				parameters = "onClick=""showDistributorSearchWindow();return false;"""
				> 
<INPUT NAME="Distributor_List" TYPE="hidden"  value="#form.Distributor_List#" ></TD>
			</TR>	
			<tr><td>&nbsp; </td><Td align="Center">
			<p>&nbsp; </p>
			<cfif len(trim(compId)) GT 0>
			<CF_smallLink 
				title = "save #lcase(application.returned_customer_setting.distributor_label_singular)# alias changes" 
				url = "##"
				parameters = "onClick=""confirmDistributorCompletion('#lcase(application.returned_customer_setting.distributor_label_singular)#','edit');return false;"""
			>
			<cfelse>
			<CF_smallLink 
				title = "save #lcase(application.returned_customer_setting.distributor_label_singular)# alias" 
				url = "##"
				parameters = "onClick=""confirmDistributorCompletion('#lcase(application.returned_customer_setting.distributor_label_singular)#','add');return false;"""
			>
			</cfif>
</TD></tr>

	</table>
</FIELDSET>
</cfoutput>