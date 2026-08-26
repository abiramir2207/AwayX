<!DOCTYPE HTML>
<cfsilent>
<!-----------------------------------------------------------------------------

FILE NAME:		programChanges.cfm
DESCRIPTION:	This is a popup window that display the changes between this version
				and the earlier version of the program
CREATED BY:		Anand Rao
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	06-May-2015

------------------------------------------------------------------------------>
</cfsilent>
<HTML>
<HEAD>
<TITLE>Program Changes</TITLE>
<style>
	.heading { font-weight:bold; margin:5px 0; color:#330066; font-size:12px; letter-spacing:0.3px; }
	.empty { color:red; font-weight: bold; margin-top:5px; }
	table.section { width:100%; border:1px solid #cc6666;  border-spacing:0; border-collapse: collapse; table-layout:fixed;}
	table.section td { padding:5px; }
	#program { margin:0 0 10px 3px; letter-spacing:0.5px; line-height:17px; }
</style>
</HEAD>
<BODY>
<cfset PageTitle="Program Changes" />
<cfinclude template="/settings/settings_title.cfm">

<cfset Document_Title = "Program Revision Report">

<cfparam name="url.Contract_Number" default="">
<cfparam name="url.Contract_main_id" default="">
<cfparam name="url.Contract_Status" default="">
<cfparam name="url.runReport" default="0"> 	<!--- 49859 --->
<cfparam name="url.CID" default=""> 				<!--- 49859 --->
<cfparam name="form.sort_order" default="desc">
<cfparam name="form.sort_by" default="Revision_Report_Nightly.Contract_Number">
<cfparam name="form.program_number" default="">
<cfparam name="form.approval_type" default="0">

<cfset RevisionProgramManager = CreateObject("component","components.programs.ReviseLog") />
<cfset ContractNumber = URL.Contract_Number />
<cfset ContractID = URL.Contract_main_id />

<cfoutput>
<cfquery name="getProgramInfo" datasource="#application.datasource#">
	select  contract_main_id,Contract_Title,Contract_Start_Date, Contract_End_Date, ISNULL(revision_of_contract_main_id, 0) as revision_of_contract_main_id, Approved, Contract_Number, Revision_of_Contract_Main_ID, ProgramType_ID
	from  	contract_main
	where 	Contract_Main_ID = #ContractID#
</cfquery>
<div id="program">
	#getProgramInfo.Contract_Number#</br>
	#getProgramInfo.Contract_Title#</br>
	#application.util.dateTime.DateSpanFormat(getProgramInfo.Contract_Start_Date, getProgramInfo.Contract_End_Date)#
</div>

<cfscript>
	variables.current_version      = getProgramInfo.Contract_Main_ID;
	variables.prior_version        = getProgramInfo.Revision_of_Contract_Main_ID;

	variables.added_products       = RevisionProgramManager.getProductsChanged(variables.current_version, variables.prior_version, 1);
	variables.removed_products     = RevisionProgramManager.getProductsChanged(variables.prior_version, variables.current_version, 1);

	variables.added_distributors   = RevisionProgramManager.getDistributorsChanged(variables.current_version, variables.prior_version, 1);
	variables.removed_distributors = RevisionProgramManager.getDistributorsChanged(variables.prior_version, variables.current_version, 1);

	variables.added_operators      = RevisionProgramManager.getOperatorsChanged(variables.current_version, variables.prior_version, 1);
	variables.removed_operators    = RevisionProgramManager.getOperatorsChanged(variables.prior_version, variables.current_version, 1);

	bProductsAdded                 = 0;
	bProductsRemoved               = 0;

	appSettings                    = createObject("component", "components.settings.InternalSettings");
	templateSettings               = createObject("component", "components.settings.ProgramTemplateSettings");
	volume_override      		   = {};
	volume_override.is_enabled     = appSettings.get_Setting("Allow_BB_Dont_Count_From_Program") neq "0"
										and templateSettings.get_Setting(ContractID, "BB_Dont_Count_Volume_Select") eq "1";
	if (volume_override.is_enabled) {
		volume_override.added   = RevisionProgramManager.getVolumeOverrideChanges(variables.current_version, variables.prior_version);
		volume_override.removed = RevisionProgramManager.getVolumeOverrideChanges(variables.prior_version, variables.current_version);
		volume_override.changed = RevisionProgramManager.getVolumeOverrideIgnore(variables.current_version, variables.prior_version);
	}
	bDistributorsAdded             = 0;
	bDistributorsRemoved           = 0;
	bOperatorsAdded                = 0;
	bOperatorsRemoved              = 0;
	bOperatorSectionInclude        = templateSettings.get_Setting(ContractID, "Specify_Operators");
</cfscript>

<!---
<cfdump var="#variables.added_products#" />
<cfdump var="#variables.added_distributors#" />
<cfdump var="#variables.added_operators#" /> --->

<div class="heading">#application.returned_customer_setting.Item_Label#s Added</div>
<cfset sNo = 1 />

<table class="section">
	<cfset column_widths()>
	<cfloop query= "variables.added_products">
			<cfif variables.added_products.Added EQ 1>
				<cfif (sNo EQ 1)>
					<tr>
						<td><strong>No.</strong></td>
						<td><strong>#application.returned_customer_setting.Item_Label# Number</strong></td>
						<td><strong>Description</strong></td>
					</tr>
				</cfif>
				<tr>
					<td>#sNo#.</td>
					<td>#variables.added_products.First_ItemNumber#</td>
					<td>#variables.added_products.First_Name#</td>
				</tr>

				<cfset sNo++ />
				<cfset bProductsAdded = 1 />
			</cfif>
	</cfloop>
	</table>

<cfif bProductsAdded EQ 0>
	<div class="empty">** There were no #lcase(application.returned_customer_setting.Item_Label)#s added</div>
</cfif>

<br>

<div class="heading">#application.returned_customer_setting.Item_Label#s Removed</div>
<cfset sNo = 1 />
<table class="section">
	<cfset column_widths()>
	<cfloop query= "variables.removed_products">
		<cfif variables.removed_products.Added EQ 1>
			<cfif (sNo EQ 1)>
				<tr>
					<td  width="5%"><strong>No.</strong></td>
					<td><strong>#application.returned_customer_setting.Item_Label# Number</strong></td>
					<td><strong>Description</strong></td>
				</tr>
			</cfif>
			<tr>
				<td>#sNo#.</td>
				<td>#variables.removed_products.First_ItemNumber#</td>
				<td>#variables.removed_products.First_Name#</td>
			</tr>

			<cfset sNo++ />
			<cfset bProductsRemoved = 1 />
		</cfif>
	</cfloop>
</table>

<cfif bProductsRemoved EQ 0>
	<div class="empty">** There were no #lcase(application.returned_customer_setting.Item_Label)#s removed</div>
</cfif>
<br>

<!--- Distributors Added --->
<div class="heading">#application.returned_customer_setting.distributor_label_plural# Added</div>
<cfset sNo = 1 />
<table class="section">
	<cfset column_widths()>
	<cfloop query= "variables.added_distributors">
			<cfif variables.added_distributors.Added EQ 1>
				<cfif (sNo EQ 1)>
					<tr>
						<td  width="5%"><strong>No.</strong></td>
						<td><strong>#application.returned_customer_setting.distributor_label_singular# Number</strong></td>
						<td><strong>Name</strong></td>
					</tr>
				</cfif>
				<tr>
					<td>#sNo#.</td>
					<td>#variables.added_distributors.Child_Shr_Ship_To#</td>
					<td>#variables.added_distributors.Child_Name#</td>
				</tr>

				<cfset sNo++ />
				<cfset bDistributorsAdded = 1 />
			</cfif>
	</cfloop>
	</table>

<cfif bDistributorsAdded EQ 0>
	<div class="empty">** There were no #lcase(application.returned_customer_setting.distributor_label_Plural)# added</div>
</cfif>
<br>


<!--- Distributors removed --->
<div class="heading">#application.returned_customer_setting.distributor_label_plural# Removed</div>
<cfset sNo = 1 />
<table class="section">
	<!--- <col width="5%">
	<col width="25%">
	<col width="70%"> --->
	<cfset column_widths()>
	<cfloop query= "variables.removed_distributors">
			<cfif variables.removed_distributors.Added EQ 1>
				<cfif (sNo EQ 1)>
					<tr>
						<td  width="5%"><strong>No.</strong></td>
						<td><strong>#application.returned_customer_setting.distributor_label_singular# Number</strong></td>
						<td><strong>Name</strong></td>
					</tr>
				</cfif>
				<tr>
					<td>#sNo#.</td>
					<td>#variables.removed_distributors.Child_Shr_Ship_To#</td>
					<td>#variables.removed_distributors.Child_Name#</td>
				</tr>

				<cfset sNo++ />
				<cfset bDistributorsRemoved = 1 />
			</cfif>
	</cfloop>
	</table>

<cfif bDistributorsRemoved EQ 0>
	<div class="empty">** There were no #lcase(application.returned_customer_setting.distributor_label_Plural)# removed</div>
</cfif>
<br>

<!--- Operator section starts  --->
<cfif bOperatorSectionInclude EQ 1>
	<!--- Operators Added --->
	<div class="heading">#application.returned_customer_setting.operator_label_plural# Added</div>
	<cfset sNo = 1 />
	<table class="section">
	<cfset column_widths()>
		<cfloop query= "variables.added_operators">
				<cfif variables.added_operators.Added EQ 1>
					<cfif (sNo EQ 1)>
						<tr>
							<td  width="5%"><strong>No.</strong></td>
							<td><strong>#application.returned_customer_setting.operator_label_plural# ID</strong></td>
							<td><strong>Name</strong></td>
						</tr>
					</cfif>
					<tr>
						<td>#sNo#.</td>
						<td>#variables.added_operators.Child_Legacy_ID#</td>
						<td>#variables.added_operators.Child_Name#</td>
					</tr>

					<cfset sNo++ />
					<cfset bOperatorsAdded = 1 />
				</cfif>
		</cfloop>
		</table>

	<cfif bOperatorsAdded EQ 0>
		<div class="empty">** There were no #lcase(application.returned_customer_setting.operator_label_plural)# added</div>
	</cfif>
	<br>

	<!--- Operators removed --->
	<div class="heading">#application.returned_customer_setting.operator_label_plural# Removed</div>
	<cfset sNo = 1 />
	<table class="section">
	<cfset column_widths()>
		<cfloop query= "variables.removed_operators">

				<cfif variables.removed_operators.Added EQ 1>
					<cfif (sNo EQ 1)>
						<tr>
							<td  width="5%"><strong>No.</strong></td>
							<td><strong>#application.returned_customer_setting.operator_label_plural# ID</strong></td>
							<td><strong>Name</strong></td>
						</tr>
					</cfif>
					<tr>
						<td>#sNo#.</td>
						<td>#variables.removed_operators.Child_Legacy_ID#</td>
						<td>#variables.removed_operators.Child_Name#</td>
					</tr>

					<cfset sNo++ />
					<cfset bOperatorsRemoved = 1 />
				</cfif>
		</cfloop>
		</table>

	<cfif bOperatorsRemoved EQ 0>
		<div class="empty">** There were no #lcase(application.returned_customer_setting.operator_label_plural)# removed</div>
	</cfif>
	<br>
</cfif><!--- <cfif bOperatorSectionOn EQ 1> --->


<!--- Volume override section starts  --->
<cfif volume_override.is_enabled>
	<div class="heading">Volume Override Added</div>
	<table class="section">
		<cfset column_widths(2)>
		<cfloop query= "volume_override.added">
			<cfif volume_override.added.currentRow eq 1>
				<tr>
					<td><strong>Component</strong></td>
					<td><strong>Pay To</strong></td>
					<td><strong>Ignore Volume</strong></td>
				</tr>
			</cfif>
			<tr>
				<td>#volume_override.added.Discount_Type# - #volume_override.added.Comp_Name#</td>
				<td>#volume_override.added.pays_to#</td>
				<td>#(volume_override.added.Dont_Count_Volume ? 'yes' : 'no')#</td>
			</tr>
		</cfloop>
	</table>

	<cfif volume_override.added.recordCount EQ 0>
		<div class="empty">** There were no volume override added</div>
	</cfif>
	<br>

	<div class="heading">Volume Override Removed</div>
	<table class="section">
		<cfset column_widths(2)>
		<cfloop query= "volume_override.removed">
			<cfif volume_override.removed.currentRow eq 1>
				<tr>
					<td><strong>Component</strong></td>
					<td><strong>Pay To</strong></td>
					<td><strong>Ignore Volume</strong></td>
				</tr>
			</cfif>
			<tr>
				<td>#volume_override.removed.Discount_Type# - #volume_override.removed.Comp_Name#</td>
				<td>#volume_override.removed.Pays_To#</td>
				<td>#(volume_override.removed.Dont_Count_Volume ? 'yes' : 'no')#</td>
			</tr>
		</cfloop>
	</table>

	<cfif volume_override.removed.recordCount EQ 0>
		<div class="empty">** There were no volume override removed</div>
	</cfif>
	<br>

	<div class="heading">Volume Override Changed</div>
	<table class="section">
		<cfset column_widths(2)>
		<cfloop query= "volume_override.changed">
			<cfif volume_override.changed.currentRow eq 1>
				<tr>
					<td><strong>Component</strong></td>
					<td><strong>Pay To</strong></td>
					<td><strong>Ignore Volume</strong></td>
				</tr>
			</cfif>
			<tr>
				<td>#volume_override.changed.Discount_Type# - #volume_override.changed.Comp_Name#</td>
				<td>#volume_override.changed.Pays_To#</td>
				<td>Changed to #(volume_override.changed.Dont_Count_Volume_1 ? 'yes' : 'no')#</td>
			</tr>
		</cfloop>
	</table>

	<cfif volume_override.changed.recordCount EQ 0>
		<div class="empty">** There were no volume override changed</div>
	</cfif>
</cfif>    <!--- <cfif volume_override.is_enabled> --->
<br>
<br>

<a href="##" onclick="javascript:window.close();">#application.util.string.actionLinkFormat2("close window")#</a>


<cffunction name="column_widths" hint="Generate col tags with predefined widths">
	<cfargument name="seq" required="false" default="1">

	<cfif arguments.seq eq 1>
		<cfset local.col_width = ['5%', '25%', '70%']>
	<cfelse>
		<cfset local.col_width = ['35%', '15%', '50%']>
	</cfif>

	<cfloop from="1" to="#arrayLen(local.col_width)#" index="local.array_index">
		<col width=#local.col_width[local.array_index]#>
	</cfloop>
</cffunction>
</cfoutput>
</body>
</html>