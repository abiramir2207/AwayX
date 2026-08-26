<!---	Filename:	C:\Work\Code\base\AwayX\settings\edit_master_data\Distributor_Master_Edit.cfm
	Created:	3/12/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO EDIT MASTER DATA
	Usage:
		SETTING>>ADMINISTRATOR>>EDIT_MASTER_DATA.--->
<style type="text/css"> 
	.bold{
		font-weight: bold;
		}
</style>
<cfif isdefined("form.update")>
<!--- SAVE START --->
		<cfset MasterData = CreateObject("component", "components.products.ItemMaster")>
				<cfscript>
						MasterData.UpdateBSAFoodserviceCustomers
													(
														BSA_Foodservice_Customer_Id 		= #trim(form.CUSID)#,
														Freight_Bracket_Setting_Id			= #trim(form.BracketID)#,
														Price_list_id 						= #trim(form.PriceListID)#,
														Price_list_header_id				= #trim(form.PriceListHeaderID)#,
														Distributor_type_id 				= #trim(form.Distributor_Type_Id)#,
														Distributor_type_c_id				= #trim(form.TypeCID)#,
														Distributor_type_b_id				= #trim(form.Distributor_Type_B)#,
														UserID								= #trim(request.AccessStructure.User_ID)#,
														Distributor_type_h_Id				= #FORM.isRediCustomer#
													);
				</cfscript>
	<script>
		window.opener.location.reload(false);
		window.close();
	</script>
<!--- SAVE END --->
<cfelse>
	<cfset Distributors = createObject("component", "components.products.ItemMaster").getDistributors(#url.CUSID#)>
	<cfset DistributorType = createObject("component", "components.products.ItemMaster").getDistributorsType()>
	<cfset DistributorTypeB = createObject("component", "components.products.ItemMaster").getDistributorsTypeB()>
	<cfset DistributorTypeH = createObject("component", "components.products.ItemMaster").getDistributorsTypeH()>
	
<!--- D32337: Edit master data -- cant change Type C label.. START --->
<cfquery name="qDistributorsettings" datasource="#application.datasource#" >
	SELECT Group_Level_Desc
	FROM   Distributor_group_level
	WHERE  Distributor_group_attribute_table IN ('Distributor_Type','Distributor_Type_B','Distributor_Type_C','Distributor_Type_H')
</cfquery>

<cfset labels = arraynew(1)>
<cfloop query="qDistributorsettings">
<cfset arrayappend(labels, #qDistributorsettings.Group_Level_Desc#)>
</cfloop>
<!--- D32337: Edit master data -- cant change Type C label.. END --->

<cfoutput query="Distributors">
	<cfif len(UserName) or len(date)>
		<div style="width:100%; border:solid; border-color:orange; border-width:2px; padding:2px; text-align: center;font-weight: bold;margin-top:5px;">
		Last updated by #UserName# on #DateFormat(Date, "mmm/d/yy")# at #TimeFormat(Date, "hh:mm:ss tt")#
		</div>
	</cfif>

<cfform name="distributoredit" action="distributor_master_edit.cfm" id="distributoredit">
	<table width="98%" align="center" border="0">
		<tr id="BracketInfo" style="display:none;">
			<td colspan="2" align="center" style="color:red;font-weight:bold;">Bracket you entered is invalid.</td>
		</tr>
		<tr id="PriceListInfo" style="display:none;">
			<td colspan="2" align="center" style="color:red;font-weight:bold;">PriceList you entered is invalid.</td>
		</tr>
		<tr id="TypeCInfo" style="display:none;">
			<td colspan="2" align="center" style="color:red;font-weight:bold;">#labels[2]# you entered is invalid.</td>
		</tr>
		<tr>
			<td class="bold" style="width:150px;">Ship To</td>
			<td><cfinput type="text" name="ship_to" value="#ship_to#" style="width:100%;" disabled /></td>
			<cfinput type="hidden" name="CUSID" value="#url.CUSID#">
		</tr>
		<tr>
			<td class="bold">Name</td>
			<td><cfinput type="text" name="name" value="#name#" style="width:100%;" disabled /></td>
		</tr>
		<!--- D39476 :: Edit Master Data - Distributor - add address, city, state--->
		<tr>
			<td class="bold">Address</td>
			<td><cfinput type="text" name="Address" value="#address#" style="width:100%;" disabled /></td>
		</tr>
		<!---D39476 :: Edit Master Data - Distributor - add address, city, state --->
		<tr>
			<td class="bold">BRACKET</td>
			<td><cfinput type="text" name="Bracket" value="#Freight_Bracket_Label#" style="width:100%;" autosuggest="cfc:components.products.ItemMaster.getBracketNames({cfautosuggestvalue})" showAutosuggestLoadingIcon="false"/></td>
				<cfinput type="hidden" name="BracketID" style="width:100%;" bind="cfc:components.products.ItemMaster.getBracketid({Bracket})" bindonload="true"/>
		</tr>
		<tr>
			<td class="bold">PRICE LIST </td>
			<td><cfinput type="text" name="PriceList" value="#Price_List_Description#" style="width:100%;" autosuggest="cfc:components.products.ItemMaster.getPriceList({cfautosuggestvalue})" showAutosuggestLoadingIcon="false"/></td>
	            <cfinput type="hidden" name="PriceListID" style="width:100%;" bind="cfc:components.products.ItemMaster.getPriceListid({PriceList})" bindonload="true"/>	
				<cfinput type="hidden" name="PriceListHeaderID" style="width:100%;" bind="cfc:components.products.ItemMaster.getPriceListheaderid({PriceList})" bindonload="true"/>
		</tr>
		<tr>
			<td class="bold">#labels[1]#</td>
			<td>
				<select name="Distributor_Type_Id">
					<cfloop query="DistributorType" >
						<option value="#Distributor_type_id#" <cfif #Distributors.distributor_type_id# EQ #DistributorType.distributor_type_id#>SELECTED</cfif>>
							#Distributor_type_name#
						</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<tr>
			<td class="bold">#labels[3]#</td>
			<td><cfinput type="text" name="TypeC" value="#distributor_type_c_desc#" style="width:100%;" autosuggest="cfc:components.products.ItemMaster.getTypeC({cfautosuggestvalue})" showAutosuggestLoadingIcon="false"/></td>
	            <cfinput type="hidden" name="TypeCID" style="width:100%;" bind="cfc:components.products.ItemMaster.getTypeCid({TypeC})" bindonload="true"/>
		</tr>
		<!--- START: D44724 Billback Approval Automation/Distributor_Type_B selection --->
		<tr>
			<td class="bold">#labels[2]#</td>
			<td><select name="Distributor_Type_B">
					<cfloop query="DistributorTypeB" >
						<option value="#Distributor_Type_B_ID#" <cfif #Distributors.Distributor_Type_B_ID# EQ #DistributorTypeB.Distributor_Type_B_ID#>SELECTED</cfif>>
							#Distributor_Type_B_Desc#
						</option>
					</cfloop>
				</select>
		</tr>
		<!--- END: D44724 Billback Approval Automation --->		
		<!--- START: D75132: Enhancement ReD Price List & Flag /Anand Rao/28-Nov-2018 --->
		<tr>
			<td class="bold">#labels[4]#</td>
			<td><select name="isRediCustomer">
					<cfloop query="DistributorTypeH" >
						<option value="#Distributor_Type_H_ID#" <cfif #Distributors.Distributor_Type_H_ID# EQ #DistributorTypeH.Distributor_Type_H_ID#>SELECTED</cfif>>
								#Distributor_Type_H_Desc#
						</option>
					</cfloop>
				</select>
			</td>
		</tr>
		<!--- END: D75132: Enhancement ReD Price List & Flag /Anand Rao/28-Nov-2018 --->	
		
	</table>
		<input type="hidden" name="type" value="Distributor">
		<input type="hidden" name="update" value="1">
	
</cfform>
<div align="center">
			<a href="javascript:document.getElementById('distributoredit').reset();">#application.util.string.actionLinkFormat("reset")# </a>
			<a href="javascript:modify();">#application.util.string.actionLinkFormat("save")#</a>
</div>
</cfoutput>
</cfif>
<script>
	function modify(){
	var count = 0;
	if(document.all.Bracket.value != '' && document.all.BracketID.value == ''){
		document.getElementById("BracketInfo").style.display = "block";
		var count = count + 1;
	}
	if(document.all.PriceList.value != '' && (document.all.PriceListID.value == '' || document.all.PriceListHeaderID.value == '') ){
		document.getElementById("PriceListInfo").style.display = "block";
		var count = count + 1;
	}
	if(document.all.TypeC.value != '' && document.all.TypeCID.value == ''){
		document.getElementById("TypeCInfo").style.display = "block";
		var count = count + 1;
	}

	if(count == 0){
		
			if(document.all.Bracket.value == '' || document.all.PriceList.value == '' || document.all.Distributor_Type_Id.value == '' || document.all.TypeC.value == ''){

				if(confirm("Do you want to submit form with empty values ?")){
						distributoredit.submit();
				}

			}
			else{
						distributoredit.submit();
					}

		
	}
}
</script>
<style>
 #bracketautosuggest {
	z-index:3;
 }
 #bracketcontainer{
 	margin-top:5px;
 }
 #pricelistautosuggest {
	z-index:2;
 }
 #pricelistcontainer{
 	margin-top:5px;
 }
 #typecautosuggest {
	z-index:1;
 }
 #typeccontainer{
 	margin-top:5px;
 }
</style>