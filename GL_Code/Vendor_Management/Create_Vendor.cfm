<!---
	Copyright (c)2016 Blacksmith Applications, Inc.
	Filename:		C:\Work\base\AwayX\GL_Code\Vendor_Management\Create_Vendor.cfm
	Created:		3/1/2016
	Developer:		drachala
	Description:	Used to create New Vendor
--->

<cfparam name="url.deactivate" default="" >
<cfparam name="url.activate" default="0" >
<cfparam name="url.create" default="0" >
<cfparam name="url.vmi" default="0" >
<cfparam name="form.vendor_id" default="Vendor ID is assigned once user saves the infomation." />
<cfparam name="form.vendor_name" default="" />
<cfparam name="form.address" default="" />
<cfparam name="form.address2" default="" />
<cfparam name="form.vendor_city" default="" />
<cfparam name="form.vendor_state" default="0" />
<cfparam name="form.zip_code" default="" />
<cfparam name="form.vendor_country" default="0" />
<cfparam name="form.saveType" default="" />

<cfif url.create AND len(url.deactivate) EQ 0>
	<cfset PageTitle="  Create A Vendor">
<cfelseif url.create eq 0 AND len(url.deactivate) EQ 0>
	<cfset PageTitle="  Update Vendor">
<cfelseif url.deactivate EQ 0>
	<cfset PageTitle="  activate Vendor">
<cfelse>
	<cfset PageTitle="  deactivate Vendor">
</cfif>

<cfinclude template="/settings/settings_title.cfm">

<cfif url.deactivate EQ 1>
		<cfquery name="deActivateVendors" datasource="#application.datasource#">
			UPDATE Vendor_Master
			SET Deleted = 1, Active_Code='N'
		   WHERE Vendor_Master_ID in (<cfqueryparam value="#url.vmi#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
		</cfquery>
<cfelseif url.deactivate EQ 0>
		<cfquery name="ActivateVendors" datasource="#application.datasource#">
			UPDATE Vendor_Master
			SET Deleted = 0, Active_Code='A'
		   WHERE Vendor_Master_ID in (<cfqueryparam value="#url.vmi#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
		</cfquery>
</cfif>

<cfif (url.create EQ 0 AND form.saveType eq '') OR (len(url.deactivate)) >

	<cfquery name="GetVendorInfo" datasource="#application.datasource#">
			SELECT  *
			FROM Vendor_Master
			WHERE Vendor_Master_ID in (<cfqueryparam value="#url.vmi#" cfsqltype="CF_SQL_VARCHAR" list="yes" />)
	</cfquery>

	<cfif len(url.deactivate)>

		<span style="font-size:13px;color:green;padding:10px;">
			<cfoutput>#valuelist(GetVendorInfo.Vendor_Name)#</cfoutput> <cfif url.deactivate> deactivated <cfelse> activated</cfif>.
		</span>
	<script>
		setTimeout(function(){
							    self.close();
							},2000);
	</script>
	<cfelse>

		<cfset form.vendor_id 			= GetVendorInfo.Vendor_ID>
		<cfset form.vendor_name 		= GetVendorInfo.Vendor_Name>
		<cfset form.address 				= GetVendorInfo.Address_1>
		<cfset form.address2 				= GetVendorInfo.Address_2>
		<cfset form.vendor_city 			= GetVendorInfo.City>
		<cfset form.vendor_state 		= GetVendorInfo.State>
		<cfset form.zip_code 				= GetVendorInfo.Zipcode>
		<cfset form.vendor_country 	= GetVendorInfo.Country_Code>

	</cfif>

</cfif>



<cfif len(url.deactivate) EQ 0>

<cfinclude template="/Common_Files/jQuery.cfm">

<style>
	.header{
		font-weight: bold;
		font-size: 12px;
	}
	.error{
	   	border-style: solid;
	    border-width: 1px;
		border-color: red;
	}
</style>

<cfif form.saveType eq 'create'>
	<cfquery name="GetVenNumber" datasource="#application.datasource#">
			SELECT  MAX(REPLACE(Vendor_ID, 'VEN-','')) + 1 AS newID
			FROM Vendor_Master
			WHERE Vendor_ID like 'VEN-%'
	</cfquery>

	<cfif len(GetVenNumber.newID) EQ 0>
		<cfset newVendorID = 'VEN-1001'>
	<cfelse>
		<cfset newVendorID = 'VEN-'&GetVenNumber.newID>
	</cfif>

	<cfquery name="InsertNewVendor" datasource="#application.datasource#">
		INSERT INTO Vendor_Master (Vendor_ID, Vendor_Name, Address_1, Address_2, City, State, Zipcode, Country_Code, Active_code)
		VALUES('#newVendorID#','#form.vendor_name#','#form.address#','#form.address2#','#form.vendor_city#','#form.vendor_state#','#form.zip_code#','#form.vendor_country#','A')
	</cfquery>

	<div style="color:green;padding-top:25px;font-size:12px;text-align:center;">
		Vendor <cfoutput>#form.vendor_name#</cfoutput> is added to system.
	</div>
	<script>
		setTimeout(function(){
							    self.close();
							},2000);
	</script>

<cfelseif form.saveType eq 'update'>
	<cfquery name="updateVendorInfo" datasource="#application.datasource#">
		UPDATE Vendor_Master
		SET Vendor_Name = '#form.vendor_name#'
			, Address_1 = '#form.address#'
			, Address_2 = '#form.address2#'
			, City = '#form.vendor_city#'
			, State = '#form.vendor_state#'
			, Zipcode = '#form.zip_code#'
			, Country_Code = '#form.vendor_country#'
			, Active_code = 'A'
			, User_Updated = 1
	   WHERE Vendor_Master_ID = '#form.vmi#'
	</cfquery>
	<div style="color:green;padding-top:25px;font-size:12px;text-align:center;">
		Vendor <cfoutput>"#form.vendor_name#"</cfoutput> is updated in the system.
	</div>
	<script>
		setTimeout(function(){
							    self.close();
							},2000);
	</script>
<cfelse>
<!---STATE --->
	<cfset useLakebaseForGetStates = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_states")>
<cfif useLakebaseForGetStates>
	<cftry>
		<cfset GetStates = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_states", {
				"order" = "state_name.asc",
				"select" = "state_code as state,state_name"
			}), "state_code as state,state_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetStates = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetStates>
<cfquery name="GetStates" datasource="#application.datasource#">
		SELECT DISTINCT State_CODE As State, State_Name
		FROM _States
		ORDER BY State_Name
	</cfquery>
</cfif>

	<cfsavecontent variable="variables.vendor_states">
		<SELECT NAME="vendor_state" STYLE="WIDTH:300px;" id="vendor_state">
			<OPTION VALUE="0">Select A State</OPTION>
			<cfoutput QUERY="GetStates">
				<OPTION VALUE="#trim(GetStates.state)#" <cfif form.vendor_state EQ GetStates.state>SELECTED</cfif>>
					<CFIF len(trim(GetStates.state)) EQ 0>Sate Not Specified<CFELSE>#trim(GetStates.state_name)#</CFIF>
				</OPTION>
			</cfoutput>
		</SELECT>
	</cfsavecontent>

<!--- COUNTRY --->
	<cfset useLakebaseForgetCountry = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("_country")>
<cfif useLakebaseForgetCountry>
	<cftry>
		<cfset getCountry = application.oLakebase.toQuery(
			application.oLakebase.selectRows("_country", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetCountry = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetCountry>
<CFQUERY NAME="getCountry" DATASOURCE="#Application.Datasource#">
		SELECT * FROM _Country
	</CFQUERY>
</cfif>

	<cfsavecontent variable="variables.vendor_countries">
		<SELECT NAME="vendor_country" STYLE="WIDTH:300px;" id="vendor_country">
			<OPTION value="0">Select A Country</OPTION>
			<cfoutput QUERY="getCountry">
				<OPTION VALUE="#getCountry.Country_Code#" <cfif form.vendor_country EQ getCountry.Country_Code>SELECTED</cfif>>
					#getCountry.Country_Name#
				</OPTION>
			</cfoutput>
		</SELECT>
	</cfsavecontent>

<b style="color:red">*</b> Indicates all fields are mandatory.

<form name="CreateVendor" action="Create_Vendor.cfm" method="post" id="CreateVendor">
	<cfoutput>
	<input type="hidden" name="saveType" value="0" id="saveType">
	<input type="hidden" name="vmi" value="#url.vmi#">
		<table width="625" border="0">
		    <tr>
		        <td class="header">Vendor ID <b style="color:red">*</b></td>
		        <td colspan="3">
		        	<cfif url.create>
						<b style="color:red">#ucase(form.vendor_id)#</b>
					<cfelse>
						<input type="hidden" name="vendor_id" value="#form.vendor_id#" readonly size="75">
						#form.vendor_id#
					</cfif>
				</td>
		    </tr>
		    <tr>
		        <td class="header" id="vendor_name">Vendor Name <b style="color:red">*</b></td>
		        <td colspan="3"><input type="text" name="vendor_name" value="#form.vendor_name#"></td>
		    </tr>
		    <tr>
		        <td class="header" id="address">Address <b style="color:red">*</b></td>
		       	<td ><input type="text" name="address" value="#form.address#"></td>
		        <td class="header">Address 2</td>
		        <td><input type="text" name="address2" value="#form.address2#"></td>
		    </tr>
		    <tr>
		        <td class="header" id="vendor_city">City <b style="color:red">*</b></td>
		        <td colspan="3"><input type="text" name="vendor_city" value="#form.vendor_city#"</td>
		    </tr>
		    <tr>
		        <td class="header vendor_state">State <b style="color:red">*</b></td>
		        <td>#application.util.string.compress( variables.vendor_states )#</td>
				<td class="header" id="zip_code">Postal Code <b style="color:red">*</b></td>
				<td><input type="text" name="zip_code" value="#form.zip_code#"></td>
		    </tr>
		    <tr>
		        <td class="header vendor_country">Country <b style="color:red">*</b></td>
		        <td colspan="3">#application.util.string.compress( variables.vendor_countries )#</td>
		    </tr>
			<tr>
				<td colspan="4"><br>
					<a class="reset" style="cursor:pointer;">#application.util.string.actionLinkFormat("reset")#</a>&nbsp;&nbsp;
				<cfif url.create>
					<a class="submit" style="cursor:pointer;">#application.util.string.actionLinkFormat("create vendor")#</a>
				<cfelse>
					<a class="submit" style="cursor:pointer;">#application.util.string.actionLinkFormat("update vendor")#</a>
				</cfif>
				</td>
			</tr>
		</table>
	</cfoutput>
</form>

<script language="javascript">
	$(document).ready(function() {
	$( ".submit" ).click(function() {
		var donotSubmit = 0;

		$('input').each(function() {
			var id = $(this).attr("name");
			if($(this).val().length == 0 && id != 'address2'){
				$('#'+id).addClass("error");
				donotSubmit = 1
			}
			else{
				$('#'+id).removeClass("error");
			}
		});

		$('select ').each(function() {
			var id = $(this).attr("name");
			var s = $('#'+id).val();
			if(s == 0){
				$('.'+id).addClass("error");
				donotSubmit = 1
			}
			else{
				$('.'+id).removeClass("error");
			}
		});

		if (donotSubmit == 0) {
			<cfif url.create>
				$("#saveType").val("create");
			<cfelse>
				$("#saveType").val("update");
			</cfif>
			$("#CreateVendor").submit();
		}
	});

	$(".reset").on("click", function(){
		$('input:text').val('');
		$('select').find('option:first').attr('selected', 'selected');
		});
	});
</script>
</cfif>

</cfif>