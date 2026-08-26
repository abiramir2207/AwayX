<cfparam name="pp_ID" default="">
<cfset form.sg = sessionGUID>
<cfset form.donotrelocate = 1>
<cfset pp_ID = url.id>

<!--- basic Info --->
<cfset useLakebaseForgetBasicInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rules")>
<cfif useLakebaseForgetBasicInfo>
	<cftry>
		<cfset getBasicInfo = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bid_rules", {
				"bid_rule_id" = "eq.#pp_ID#",
				"deleted" = "eq.0",
				"select" = "bid_rule_id,bid_rule_name,bid_rule_desc,bid_rule_uom"
			}), "bid_rule_id,bid_rule_name,bid_rule_desc,bid_rule_uom"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetBasicInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetBasicInfo>
<cfquery name="getBasicInfo" datasource="#application.datasource#">
	SELECT Bid_Rule_ID, Bid_Rule_Name, Bid_Rule_Desc, Bid_Rule_UOM
	FROM Bid_Rules
	WHERE Bid_Rule_ID = '#pp_ID#' AND Deleted = 0
</cfquery>
</cfif>

<cfset form.Bid_Rule_Name 		= getBasicInfo.Bid_Rule_Name>
<cfset form.Bid_Rule_Desc 		= getBasicInfo.Bid_Rule_Desc>
<cfset form.Bid_Rule_UOM 		= getBasicInfo.Bid_Rule_UOM>
<cfset form.Bid_Rule_ID			= getBasicInfo.Bid_Rule_ID>

<cfset form.SuppliedDataType 	= "basic">
<cfinclude template="packet_modifier.cfm">


 <!--- type items --->
<cfset useLakebaseForgetTypes = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_items")>
<cfif useLakebaseForgetTypes>
	<cftry>
		<cfset getTypes = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bid_rule_items", {
				"bid_rule_id" = "eq.#pp_ID#",
				"deleted" = "eq.0",
				"select" = "type_item_id,bid_rule_item_id"
			}), "type_item_id,bid_rule_item_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetTypes = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetTypes>
<cfquery name="getTypes" datasource="#application.datasource#">
	SELECT Type_Item_ID, Bid_Rule_Item_ID
	FROM Bid_Rule_Items
	WHERE Bid_Rule_ID = '#pp_ID#' AND Deleted = 0
</cfquery>
</cfif>

<cfset counter = 1>
<cfset form.fieldnames = "">
<cfloop query="getTypes">
	<cfset "form.type_#counter#" = getTypes.Type_Item_ID>
	<cfset "form.type_#counter#_id" = getTypes.Bid_Rule_Item_ID>
	<cfset form.fieldnames = listappend(form.fieldnames,"type_#counter#")>
	<cfset counter = counter + 1>
</cfloop>
<cfset counter = 1>

<cfset form.SuppliedDataType 	= "type">
<cfinclude template="packet_modifier.cfm">


<!--- modifiers --->
<cfset useLakebaseForgetModifiers = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_modifiers")>
<cfif useLakebaseForgetModifiers>
	<cftry>
		<cfset getModifiers = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bid_rule_modifiers", {
				"bid_rule_id" = "eq.#pp_ID#",
				"deleted" = "eq.0",
				"order" = "modifier_index.asc",
				"select" = "bid_rule_modifier_id,modifier_index,modifier_amount,modifier_desc,modifier_uom,iscompound,isindependent"
			}), "bid_rule_modifier_id,modifier_index,modifier_amount,modifier_desc,modifier_uom,iscompound,isindependent"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetModifiers = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetModifiers>
<cfquery name="getModifiers" datasource="#application.datasource#">
	SELECT Bid_Rule_Modifier_ID, Modifier_Index, Modifier_Amount, Modifier_Desc, Modifier_UOM, iscompound, isindependent
	FROM Bid_Rule_Modifiers
	WHERE Bid_Rule_ID = '#pp_ID#' AND Deleted = 0
	ORDER BY Modifier_Index
</cfquery>
</cfif>

<cfset counter = 1>
<cfset form.fieldnames = "">
<cfset form.addModifier = 1>
<cfset form.deleteModifierIndex = 0>
<cfset form.addModBulkInsert = 1>
<cfset form.addModBulkInsert_index_count = getModifiers.recordcount>
<cfloop query="getModifiers">
	<cfset "form.modifier_desc_#counter#" 	= getModifiers.Modifier_Desc>
	<cfset "form.modifier_amount_#counter#" = getModifiers.Modifier_Amount>
	<cfset "form.modifier_uom_#counter#"	= getModifiers.Modifier_UOM>
	<cfset "form.modifier_iscompound_#counter#"	= getModifiers.iscompound>
	<cfset "form.modifier_isindependent_#counter#"	= getModifiers.isindependent>
	<cfset "form.Bid_Rule_Modifier_ID_#counter#"	= getModifiers.Bid_Rule_Modifier_ID>
	<cfset "form.Bid_Rule_Modifier_ID_#counter#_Action"	= 2>
	<cfset counter = counter + 1>
</cfloop>

<cfset counter = 1>
<cfset form.SuppliedDataType 	= "modifiers">
<cfinclude template="packet_modifier.cfm">

<!--- volume groups --->
<cfset useLakebaseForgetVolumeGroups = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_volume_groups")>
<cfif useLakebaseForgetVolumeGroups>
	<cftry>
		<cfset getVolumeGroups = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bid_rule_volume_groups", {
				"bid_rule_id" = "eq.#pp_ID#",
				"deleted" = "eq.0",
				"order" = "group_index.asc",
				"select" = "bid_rule_group_id,group_index,range_start,range_end"
			}), "bid_rule_group_id,group_index,range_start,range_end"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetVolumeGroups = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetVolumeGroups>
<cfquery name="getVolumeGroups" datasource="#application.datasource#">
	SELECT Bid_Rule_Group_ID, Group_Index, Range_Start, Range_End
	FROM Bid_Rule_Volume_Groups
	WHERE Bid_Rule_ID = '#pp_ID#' AND Deleted = 0
	ORDER BY Group_Index
</cfquery>
</cfif>

<cfset counter = 1>
<cfset form.fieldnames = "">
<cfset form.VolumegroupCount = getVolumeGroups.Recordcount>
<cfset overageQueryList = "">
<cfloop query="getVolumeGroups">
	<cfset "form.range_start_#counter#" = getVolumeGroups.Range_Start>
	<cfset "form.range_end_#counter#" = getVolumeGroups.Range_End>
	<cfset "form.range_#counter#_Bid_Rule_Group_ID" = getVolumeGroups.Bid_Rule_Group_ID>
	<cfset counter = counter + 1>
</cfloop>
<cfset counter = 1>

<cfset form.SuppliedDataType = "volumegroups">
<cfinclude template			 = "packet_modifier.cfm">

<cfset form.fieldnames = "">
<cfloop index="x" from="1" to="#BidRule.Type.Index_Count#" step="1">
	<cfset currentnode = evaluate("BidRule.Type.Type_#x#")>
	<cfloop index="n" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
		<cfset currentnodeOver = evaluate("BidRule.Type.Type_#x#")>
		<!--- overage --->
		<cfquery name="getOverages" datasource="#application.datasource#">
			SELECT Bid_Rule_Item_Group_Amount_ID, Bid_Rule_Group_ID, Bid_Rule_Item_ID, Amount, uom
			FROM  Bid_Rule_Item_Group_Amounts
			WHERE Bid_Rule_Group_ID = '#evaluate("BidRule.VOLUMEGROUPS.Group_#n#.Bid_Rule_Group_ID")#' AND Bid_Rule_Item_ID = '#currentnode.Bid_Rule_Item_ID#'
		</cfquery>
		
		<cfset "form.type_#x#_group_#n#" = getOverages.amount>
		<cfset "form.type_#x#_group_#n#_uom" = getOverages.uom>
		
		<cfset "form.type_#x#_group_#n#_Bid_Rule_Item_Group_Amount_ID" = getOverages.Bid_Rule_Item_Group_Amount_ID>
		
		<cfset form.fieldnames = listappend(form.fieldnames, "type_#x#_group_#n#")>
		
	</cfloop>
</cfloop>


<cfset form.SuppliedDataType 	= "overage">
<cfinclude template				= "packet_modifier.cfm">


<!--- exceptions --->
<cfquery name="getRuleExceptions" datasource="#application.datasource#">
	SELECT Bid_Rule_Exception_Groups.Bid_Rule_ID, Bid_Rule_Exception_Groups.Exception_Group_ID, Bid_Rule_Exception_Groups.Bid_Rule_Exception_Group_ID, Exception_Groups.Group_name
	FROM Bid_Rule_Exception_Groups, Exception_Groups
	WHERE 
	Bid_Rule_Exception_Groups.Exception_Group_ID = Exception_Groups.Exception_Group_ID
	AND	Bid_Rule_Exception_Groups.Bid_Rule_ID = '#pp_ID#'
	AND Bid_Rule_Exception_Groups.Deleted = 0
</cfquery>
<cfset form.GroupCount = getRuleExceptions.RecordCount>

<cfset counter = 1>
<cfloop query="getRuleExceptions">
	<cfset thisException_Group_Name = getRuleExceptions.Group_name>
	<cfset thisException_Group_ID = getRuleExceptions.Exception_Group_ID>
	<cfset thisBid_Rule_Exception_Group_ID = getRuleExceptions.Bid_Rule_Exception_Group_ID>
	
	
	
	<cfset "form.Inp_Group_#counter#_Name" 	= thisException_Group_Name>
	<cfset "form.Inp_Group_#counter#_ID" 	= thisException_Group_ID>
	<cfset "form.Inp_Group_#counter#_Bid_Rule_Exception_Group_ID" 	= thisBid_Rule_Exception_Group_ID>
	
	
	<cfset useLakebaseForgetGroupProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("exception_group_products")>
<cfif useLakebaseForgetGroupProducts>
	<cftry>
		<cfset getGroupProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("exception_group_products", {
				"exception_group_id" = "eq.#thisException_Group_ID#",
				"deleted" = "eq.0",
				"select" = "product_id"
			}), "product_id"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForgetGroupProducts = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForgetGroupProducts>
<cfquery name="getGroupProducts" datasource="#application.datasource#">
		SELECT Product_ID 
		FROM  Exception_Group_Products
		WHERE Exception_Group_ID = '#thisException_Group_ID#'
		AND Deleted = 0
	</cfquery>
</cfif>
	
	<cfset "form.Inp_Group_#counter#_ProductList" = valuelist(getGroupProducts.Product_ID)>

<cfset counter = counter + 1>
</cfloop>
	
<cfset form.exception_action = "loadIntoPacket">
<cfset form.SuppliedDataType 	= "exceptions">
<cfinclude template				= "packet_modifier.cfm">

<cfset form.fieldnames = "">
<cfloop index="x" from="1" to="#BidRule.Exceptions.Index_Count#" step="1">
	<cfset currentnode = evaluate("BidRule.Exceptions.Groups.Group_#x#")>
	<cfloop index="n" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
		<cfset currentnodeOver = evaluate("BidRule.Exceptions.Groups.Group_#x#")>
		<!--- overage --->
		<cfquery name="getOverages" datasource="#application.datasource#">
			SELECT Bid_Rule_Exception_Group_Amount_ID, Bid_Rule_Group_ID, Bid_Rule_Exception_Group_ID, Amount, uom
			FROM  Bid_Rule_Exception_Group_Amounts
			WHERE Bid_Rule_Group_ID = '#evaluate("BidRule.VOLUMEGROUPS.Group_#n#.Bid_Rule_Group_ID")#' AND Exception_Group_ID = '#currentnode.Exception_Group_ID#'
		</cfquery>
		
		<cfset "form.Exception_#x#_group_#n#" = getOverages.amount>
		<cfset "form.Exception_#x#_group_#n#_uom" = getOverages.uom>
		<cfset "form.Exception_#x#_group_#n#_Bid_Rule_Exception_Group_Amount_ID" = getOverages.Bid_Rule_Exception_Group_Amount_ID>
		
		<cfset form.fieldnames = listappend(form.fieldnames, "Exception_#x#_group_#n#")>
		
	</cfloop>
</cfloop>

<cfset form.SuppliedDataType 	= "overage">
<cfinclude template				= "packet_modifier.cfm">

<!--- <hr color="red">
<cfdump var="#form#">
<cfabort> --->