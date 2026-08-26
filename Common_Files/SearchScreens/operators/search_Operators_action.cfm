<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Retrieve operators																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFQUERY NAME="TheQuery" datasource="#application.datasource#">

Select		*

From		BSA_Operator

Where		deleted = 0
			<CFIF Operator_State NEQ "All">
				and
				Operator_State	=	'#Operator_State#'
			</CFIF>

			<CFIF Operator_Type NEQ "All">
				and
				Operator_Type	=	'#Operator_Type#'
			</CFIF>
			
			<CFIF Operator_Location_Type NEQ "All">
				and
				Operator_Location_Type	=	'#Operator_Location_Type#'
			</CFIF>
			
			<CFIF trim(Operator_Name) NEQ "">
				and
				(
					Operator_Name 	like 	'%#Operator_Name#%'
					or
					Operator_Name 	like 	'#Operator_Name#%'
					or
					Operator_Name 	like 	'%#Operator_Name#'
					or
					Operator_Name 	=	 	'#Operator_Name#'
				)
			</CFIF>
			
			<CFIF trim(Operator_City) NEQ "">
				and
				(
					Operator_City 	like 	'%#Operator_City#%'
					or
					Operator_City 	like 	'#Operator_City#%'
					or
					Operator_City 	like 	'%#Operator_City#'
					or
					Operator_City 	like 	'#Operator_City#'
				)
			</CFIF>

			<CFIF trim(Operator_DBA) NEQ "">
				and
				(
					Operator_DBA 	like 	'%#Operator_DBA#%'
					or
					Operator_DBA 	like 	'#Operator_DBA#%'
					or
					Operator_DBA 	like 	'%#Operator_DBA#'
					or
					Operator_DBA 	like 	'#Operator_DBA#'
				)
			</CFIF>
		ORDER BY 	Operator_Name
</CFQUERY>

<SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many <cfoutput>#application.returned_customer_setting.operator_label_plural#</cfoutput> in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
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
	<CFIF TheQuery.recordcount GTE 500>
		<FONT SIZE="+1"><B>Your query returned more than 500 records. Please narrow your search.</B></FONT>
	<CFELSE>
	
		<TABLE border="0" cellspacing="0" cellpadding="2" align="center" CLASS="Maintable" width="900">
			<TR ID="header" BGCOLOR="#ffce84">
				<TD align="left"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>"></TD>
				<TD align="left"><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</TD>
				<!--- <TD align="left">Type</TD> --->
				<TD align="left" WIDTH="150">Location<BR>Type</TD>
				<TD align="left">City<BR>State</TD>
				<TD align="left"># of<BR>Locations&nbsp;</TD>
				<TD align="left" VALIGN="bottom" WIDTH="30%">Doing Business As</TD>
	
			</TR>
		<CFOUTPUT QUERY="TheQuery">
			<CFSET GST_ID = trim(TheQuery.BSA_Operator_ID)>
			<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF> style="cursor: pointer;">
				<td><CF_GeneralSearchTool_OPTION></td>
				<!--- <TD align="center"><INPUT type="Checkbox" NAME="SelectedITEMS" VALUE="#trim(TheQuery.BSA_Operator_ID)#"<!---  <CFIF listfind(FORM.FinalItemList, trim(TheQuery.BSA_Operator_ID)) NEQ 0>CHECKED<CFSET FORM.AlreadySelectedItems = listappend(FORM.AlreadySelectedItems, trim(TheQuery.BSA_Operator_ID), ",")></CFIF> --->></TD> --->
				<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;" >#TheQuery.operator_name#</TD>
				<!--- <TD>#TheQuery.operator_type#&nbsp;</TD> --->
				<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;" >#TheQuery.Operator_Location_Type#&nbsp;</TD>
				<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;" >#TheQuery.Operator_City#, #TheQuery.Operator_State#&nbsp;</TD>
				<TD NOWRAP onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#trim(TheQuery.BSA_Operator_ID)#','name','400','450','Yes', 'No');return false;" >#numberformat(TheQuery.Operator_Number_Of_Locations,'_,___,___')#&nbsp;</TD>
				<TD onclick="NewWindow('/profiles/operators/operator_profile.cfm?OID=#cryp.value#','name','400','450','Yes', 'No');return false;" >#TheQuery.Operator_DBA#&nbsp;</TD>
				</TR>
		</CFOUTPUT>
		</TABLE>
	</CFIF>
</CFIF>