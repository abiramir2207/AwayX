	<CFQUERY NAME="TheQuery" datasource="#application.datasource#">
		SELECT *
		FROM BSA_Foodservice_Brokers
		WHERE
			0 = 0
			AND DELETED = 0 
		<CFIF len(trim(FORM.searchstring)) GT 0>
		AND
		(
			(
				Broker_Name = 'form.searchstring'
				OR
				Broker_Name LIKE '%#form.searchstring#'
				OR
				Broker_Name LIKE '#form.searchstring#%'
				OR
				Broker_Name LIKE '%#form.searchstring#%'
			)
		)
		</CFIF>
	</CFQUERY>
	
	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many brokers in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
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
	<BR>

<!--- 	<FIELDSET STYLE="padding:8px; width: 600px; border: 1px solid Blue;">
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;"><CFIF TheQuery.recordcount EQ 1>Is<CFELSE>Are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>Broker<CFELSE>Brokers</CFIF> That <CFIF TheQuery.recordcount EQ 1>Matched<CFELSE>Match</CFIF> The Above Criteria</LEGEND> --->
		<!--- <CFSET FORM.AlreadySelectedItems = ""> --->
<form>
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="0" align="center" WIDTH="775" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
					<TD align="left"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Brokers"></TD>
					<TD align="left">Broker Number</TD>
					<TD align="left">Broker Name</TD>
					<TD align="left">Region Code</TD>
					<TD align="left">Market Area Name</TD>

				</TR>
			<CFOUTPUT QUERY="TheQuery">
				 <cf_cryp string="#TheQuery.BSA_Foodservice_Brokers_ID#" type="en" key="#caller.key#"> 
					<CFSET GST_ID = trim(TheQuery.BSA_Foodservice_Brokers_ID)>
				<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;">
					<td><CF_GeneralSearchTool_OPTION></td>
					<!--- <TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Foodservice_Brokers_ID)#"<!---  <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Foodservice_Brokers_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Foodservice_Brokers_ID), ",")></CFIF> --->></TD> --->
					<TD NOWRAP  ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#TheQuery.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Region_Legcy_Shard#</TD>
					<TD NOWRAP  ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#TheQuery.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Broker_Name#</TD>
					<TD NOWRAP  ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#TheQuery.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Region_Legcy_Shard#</TD>
					<TD NOWRAP  ONCLICK="NewWindow('/Profiles/Brokers/Broker_profile.cfm?BID=#TheQuery.BSA_Foodservice_Brokers_ID#','name','400','450','Yes', 'No');">#TheQuery.Market_Area#</TD>
 				</TR>
			</CFOUTPUT>
			</TABLE>
		<!--- </CFIF> --->
<!--- 	</FIELDSET> --->
			<!--- <input type="hidden" name="newidlist" value="#form.newidlist#"> --->
		</CFIF>
</form>