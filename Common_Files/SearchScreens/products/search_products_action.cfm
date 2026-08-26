	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Items_Master
		WHERE
			0 = 0
		<CFIF FORM.Qbrand_desc NEQ 0>
			AND
			Q_Brand_Desc = '#FORM.Qbrand_desc#'
		</CFIF>

		<CFIF FORM.typecode_desc NEQ 0>
			AND
			Type_Code_Desc = '#FORM.typecode_desc#'
		</CFIF>

		<CFIF FORM.typegroup_desc NEQ 0>
			AND
			Type_Group_Desc = '#FORM.typegroup_desc#'
		</CFIF>

		<CFIF FORM.brand NEQ 0>
			AND
			brand = '#FORM.brand#'
		</CFIF>
<!--- 
		<CFIF FORM.Qbrand_desc NEQ 0>
			AND
			Q_Brand_Desc = '#FORM.Q_Brand_Desc#'
		</CFIF>
 --->
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
		
			(
				Item = '#form.searchstring#'
				OR
				Item LIKE '%#form.searchstring#'
				OR
				Item LIKE '#form.searchstring#%'
				OR
				Item LIKE '%#form.searchstring#%'
			)
			OR
			(
				UPC = '#form.searchstring#'
				OR
				UPC LIKE '%#form.searchstring#'
				OR
				UPC LIKE '#form.searchstring#%'
				OR
				UPC LIKE '%#form.searchstring#%'
			)
			<CFIF isnumeric(#form.searchstring#)>
			OR
			(
				Case_Count = '#form.searchstring#'
				OR
				Case_Count LIKE '%#form.searchstring#'
				OR
				Case_Count LIKE '#form.searchstring#%'
				OR
				Case_Count LIKE '%#form.searchstring#%'
			)
			OR
			(
				Pack_Size = '#form.searchstring#'
				OR
				Pack_Size LIKE '%#form.searchstring#'
				OR
				Pack_Size LIKE '#form.searchstring#%'
				OR
				Pack_Size LIKE '%#form.searchstring#%'
			)
			</CFIF>
			OR
			(
				Description = '#form.searchstring#'
				OR
				Description LIKE '%#form.searchstring#'
				OR
				Description LIKE '#form.searchstring#%'
				OR
				Description LIKE '%#form.searchstring#%'
			)
			OR
			(
				Brand = '#form.searchstring#'
				OR
				Brand LIKE '%#form.searchstring#'
				OR
				Brand LIKE '#form.searchstring#%'
				OR
				Brand LIKE '%#form.searchstring#%'
			)
			OR
			(
				Type_Code_Desc = '#form.searchstring#'
				OR
				Type_Code_Desc LIKE '%#form.searchstring#'
				OR
				Type_Code_Desc LIKE '#form.searchstring#%'
				OR
				Type_Code_Desc LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
	</CFQUERY>
<SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many products in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
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
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</SCRIPT>	

		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="0" CLASS="Maintable" WIDTH="850">
				<TR ID="header" BGCOLOR="#ffce84">
					<TD><CF_GeneralSearchTool_OPTION selectall="yes"></TD>
					<TD align="left">UPC Code</TD>
					<TD align="left">Item #</TD>
					<TD align="left">Description</TD>
					<!--- <TD align="left">QBrand</TD> --->
					<TD align="left">Type Code Description</TD>
					<!--- <TD align="left">Type Group Description</TD> --->
					<TD align="left">Brand</TD>
			<CFOUTPUT QUERY="TheQuery">
				<!--- <CFSET GST_ID = TheQuery.UPC> --->
				<cf_cryp type="en" string ="#UPC#" key="#caller.key#">
					<CFSET PID = cryp.value>
				<!--- <CFSET GST_ID = trim(TheQuery.Item)> --->
				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> STYLE="cursor:pointer;">
				<CFSET GST_ID = upc>
					<TD><CF_GeneralSearchTool_OPTION></TD>
					<TD  NOWRAP ONCLICK="NewWindow('/Profiles/Products/Product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');">#TheQuery.UPC#</TD>
					<TD NOWRAP ONCLICK="NewWindow('/Profiles/Products/Product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');">#TheQuery.ITEM#</TD>
					<TD NOWRAP ONCLICK="NewWindow('/Profiles/Products/Product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');">#TheQuery.Description#</TD>
					<!--- <TD>#TheQuery.Q_Brand_Desc#</TD> --->
					<TD NOWRAP ONCLICK="NewWindow('/Profiles/Products/Product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');">#TheQuery.Type_Code_Desc#</TD>
					<!--- <TD NOWRAP>#TheQuery.Type_Group_Desc#</TD> --->
					<TD NOWRAP ONCLICK="NewWindow('/Profiles/Products/Product_profile.cfm?PID=#PID#','name','400','450','Yes', 'No');">#TheQuery.Brand#</TD>
 				</TR>
			<CFFLUSH>
			</CFOUTPUT>
			</TABLE>
		</CFIF>