<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
	SELECT dbo.BSA_Foodservice_Brokers.*, 
	    dbo.BSA_Foodservice_Customers.*
	FROM dbo.BSA_Foodservice_Brokers INNER JOIN
	    dbo.BSA_Foodservice_Customers ON 
	    dbo.BSA_Foodservice_Brokers.Broker_Legcy_Shard = dbo.BSA_Foodservice_Customers.Std_Broker
	WHERE
		0 = 0 AND dbo.BSA_Foodservice_Customers.DELETED = 0 
		<CFIF FORM.Family_Name NEQ 0>
			AND dbo.BSA_Foodservice_Customers.Family_Name = '#FORM.Family_Name#'
		</CFIF>

		<CFIF FORM.Broker NEQ 0>
			AND BSA_Foodservice_Customers.std_broker = '#FORM.Broker#'
		</CFIF>

		<CFIF FORM.State NEQ 0>
			AND BSA_Foodservice_Customers.state = '#FORM.State#'
		</CFIF>

		<CFIF FORM.Market_Area NEQ 0>
			AND BSA_Foodservice_Brokers.Market_Area = '#FORM.Market_Area#'
		</CFIF>
		
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
			(
				Name = '#form.searchstring#'
				OR
				Name LIKE '%#form.searchstring#'
				OR
				Name LIKE '#form.searchstring#%'
				OR
				Name LIKE '%#form.searchstring#%'
			)
			OR
			(
				dbo.BSA_Foodservice_Customers.City = '#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.City LIKE '%#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Customers.City LIKE '#form.searchstring#%'
				OR
				dbo.BSA_Foodservice_Customers.City LIKE '%#form.searchstring#%'
			)
			OR
			(
				Family_Name = '#form.searchstring#'
				OR
				Family_Name LIKE '%#form.searchstring#'
				OR
				Family_Name LIKE '#form.searchstring#%'
				OR
				Family_Name LIKE '%#form.searchstring#%'
			)
			<CFIF isnumeric(form.searchstring)>
			OR
			(
				Shr_Family = '#form.searchstring#'
				OR
				Shr_Family LIKE '%#form.searchstring#'
				OR
				Shr_Family LIKE '#form.searchstring#%'
				OR
				Shr_Family LIKE '%#form.searchstring#%'
			)
			</CFIF>
			OR
			(
				dbo.BSA_Foodservice_Brokers.Broker_Name = '#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '#form.searchstring#%'
				OR
				dbo.BSA_Foodservice_Brokers.Broker_Name LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
		order by name
	</CFQUERY>
	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<SCRIPT>

		function CA() {
			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many <cfoutput>#application.returned_customer_setting.distributor_label_plural#</cfoutput> in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
				for (var i=0;i<MyForm.elements.length;i++)
					{
						var e = MyForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = MyForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}
</SCRIPT>	
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="0" align="center" WIDTH="850" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<TD align="left"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Distributors"></TD>
					<TD>Ship-to #</TD>
					<TD align="left"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Name</TD>
					<TD>City</TD>
					<TD ALIGN="center">State</TD>
					<!--- <TD>Shared Family Code</TD> --->
					<TD>Family Name</TD>
				</TR>
			<CFOUTPUT QUERY="TheQuery">
				<cf_cryp type="en" string="#TheQuery.BSA_Foodservice_Customers_ID#" key="#caller.key#"> 
				<CFSET GST_ID = trim(TheQuery.BSA_Foodservice_Customers_ID)>
			<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;">
				
				<td><CF_GeneralSearchTool_OPTION></td>
				
				<!--- <TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Customers_ID)#" <!--- <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Customers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Customers_ID), ",")></CFIF> --->></TD> --->
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#TheQuery.BSA_Foodservice_Customers_ID#','name','400','450','Yes', 'No');return false;" >#TheQuery.Ship_To#</TD>
					<TD  onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;" NOWRAP>#TheQuery.Name#</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#TheQuery.City#</TD>
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;" ALIGN="center">#TheQuery.State#</TD>
					   <!--- <TD>#TheQuery.Shr_Family#</TD> --->
					<TD onclick="NewWindow('/profiles/Distributors/Distributor_profile.cfm?DID=#cryp.value#','name','400','450','Yes', 'No');return false;">#TheQuery.Family_Name#&nbsp;</TD>
 				</TR>
				<cfflush>
			</CFOUTPUT>
			</TABLE>
		</CFIF>
