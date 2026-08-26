<cfparam name="form.SuppliedDataType" 	default="">
<cfparam name="form.sg" 				default="">
<cfparam name="form.nextTab"			default="">
<cfparam name="form.donotrelocate"		default="0">

<cfif len(trim(form.SuppliedDataType)) EQ 0 OR len(trim(form.sg)) EQ 0>
	<!--- cfabort and relocatate because something is really wrong --->
	<h1 style="color: red;">CFABORT MISSION </h1>
	<cfabort>
</cfif>

<!-- READ PACKET -->
<!---
<cffile action="READ" file="#apppath#\WddxPackets\#form.sg#.ddx" variable="packet">
--->
<cffile action="READ" file="#Application.Doc_Path#\temp_files\WddxPackets\#form.sg#.ddx" variable="packet">
<cfwddx action="WDDX2CFML" input="#packet#" output="BidRule">


<cfswitch expression="#form.SuppliedDataType#">
<!--- 
							BASIC 
--->
	<cfcase value="basic">
		<cfset BidRule.Basic.Bid_Rule_Name	= form.Bid_Rule_Name>
		<cfset BidRule.Basic.Bid_Rule_Desc	= left(form.Bid_Rule_Desc, 254)>
		<cfset BidRule.Basic.Bid_Rule_UOM	= form.Bid_Rule_UOM>
		
		<cfif isdefined("form.Bid_Rule_ID")>
			<cfset BidRule.Basic.Bid_Rule_ID = form.Bid_Rule_ID>
		</cfif>
	
		<cfif len(trim(BidRule.Basic.Bid_Rule_Name)) GT 0 AND len(trim(BidRule.Basic.Bid_Rule_Desc)) GT 0 AND BidRule.Basic.Bid_Rule_UOM GT 0>
			<cfset BidRule.Basic.ValidData = 1>
		<cfeLse>
			<cfset BidRule.Basic.ValidData = 0>
		</cfif>
	</cfcase>
<!--- TYPE CODES --->
	<cfcase value="type">
		<!--- 
			action list:
			1 = insert new
			2 = update
			3 = delete
		 --->
		<cfset currentlist 	= "">
		<cfset newlist		= "">
		<cfset currentindex = "">
		<cfset newlist_guids = "">
		<cfset originalindexcount = BidRule.Type.Index_Count>
		
				
		<!--- extract supplied info from form --->
		<cfloop index="x" list="#form.fieldnames#">
			<cfset currentfield = x>
			<cfif lcase(left(currentfield, 5)) EQ "type_">
				<cfset currentvalue = trim(evaluate("form.#x#"))>
				<cfset newlist 		= listappend(newlist, currentvalue)>
				
				<cfif isdefined("form.#x#_id")>
					<cfset currentvalue = trim(evaluate("form.#x#_id"))>
					<cfset newlist_guids = listappend(newlist_guids, currentvalue)>
				</cfif>
			</cfif>
		</cfloop>
		
		<!--- compare sent list to existing list --->
		<cf_list_compare List1="#BidRule.Type.Current_Index#" List2="#newlist#">
		<cfset list_remove_these 	= LC_Results1>
		<cfset list_add_these 		= LC_Results2>
		<cfset this.table 	= application.returned_customer_setting.approval_criteria_table>
		<cfset this.ID 		= application.returned_customer_setting.approval_criteria_table_ID>		
		
				
<!---LOOP THROUGH TYPE CODES--->
		<cfloop index="x" from="1" to="#BidRule.Type.Index_Count#" step="1">
			<cfset currentnode = evaluate("BidRule.Type.Type_#x#")>
<!--- AM I SUPPOSED TO DELETE THIS TYPE CODE?--->
			<cfif listfind(list_remove_these, currentnode.type_id)>
<!--- DELETE TYPE CODE FROM PACKET if action 1 remove from packet--->
				<cfif currentnode.action EQ 1>
					<cfset temp = evaluate("BidRule.type")>
					<cfset temp = structdelete(temp, "type_#x#", True)>
				</cfif>
<!---DELETE TYPE CODE FROM TABLE if action 2 update to 3 for removal from table--->
				<cfif currentnode.action EQ 2>
					<cfset currentnode.action = 3>
				</cfif>
			</cfif>

<!--- 
							RESTORE TYPE CODE
							if type added and already existed but flagged for deletion, change back to 2
--->
			<cfif listfind(list_add_these, currentnode.type_id)>
				<!--- if action 3 change to 2 --->
				<cfif currentnode.action EQ 3>
					<cfset currentnode.action = 2>
					<cfset list_add_these = listdeleteat(list_add_these, listfind(list_add_these,currentnode.type_id))>
				</cfif>
			</cfif>				
		</cfloop>

		<!--- insert new types into packet --->
		<cfset thisCounter = 1>
		<cfloop index="x" list="#list_add_these#">
			<cfset protoCopy 			= duplicate(BidRule.Type.ProtoType)>
			<cfset protoCopy.type_id 	= x>
			<cfset protoCopy.action		= 1><!--- insert into table --->
			<cfif listlen(newlist_guids) GT 0>
				<cfset protoCopy.Bid_Rule_Item_ID 	= listgetat(newlist_guids, thisCounter)>
				<cfset protoCopy.action		= 2><!--- update into table --->
			</cfif>
			
			<cfquery name="getTypeDescription" datasource="#application.datasource#">
				SELECT #this.table# as TypeDescription
				FROM #this.table#
				WHERE #this.ID# = '#protoCopy.type_id#'
			</cfquery>
			<cfset protoCopy.Description 	= getTypeDescription.TypeDescription>
			
			<cfset BidRule.Type.Index_Count = BidRule.Type.Index_Count + 1>
			<cfset "BidRule.Type.Type_#BidRule.Type.Index_Count#" = duplicate(protoCopy)>		
			<cfset thisCounter = thisCounter + 1>
		</cfloop>
		
		<!--- re index --->
		<cfset counter = 1>
		<cfloop index="x" from="1" to="#originalindexcount#" step="1">
			<cfif StructKeyExists(BidRule.Type, "Type_#x#")>
				<cfset currentnode = evaluate("BidRule.Type.Type_#x#")>
				<cfset "BidRule.Type.Type_#counter#" = duplicate(currentnode)>
				<cfif counter LT x>
					<cfset temp = evaluate("BidRule.type")>
					<cfset temp = structdelete(temp, "type_#x#", True)>
				</cfif>
				<cfset counter = counter + 1>
			</cfif>
		</cfloop>

		<!--- index list  --->
		<cfset thisCounter = 1>
		<cfset BidRule.Type.Index_Count = 0>
		<cfloop condition="thisCounter NEQ 0">
			<cfif not isdefined("BidRule.Type.Type_#thisCounter#")>
				<cfset thisCounter = 0>
				<cfbreak>
			</cfif>

			<cfset currentnode = evaluate("BidRule.Type.Type_#thisCounter#")>
			<cfif currentnode.action EQ 1 OR currentnode.action EQ 2>
				<cfset currentindex = listappend(currentindex, currentnode.Type_ID)>
			</cfif>
			<cfset BidRule.Type.Index_Count = BidRule.Type.Index_Count + 1>
			<cfset thisCounter = thisCounter + 1>
		</cfloop>
		<cfset BidRule.Type.Current_Index 	= currentindex>
		
		<cfset BidRule.Type.ValidData = 0>
		<cfif listlen(BidRule.Type.Current_Index) GT 0>
			<cfset BidRule.Type.ValidData = 1>
		</cfif>
	</cfcase>
<!---MODIFIERS--->
	<cfcase value="modifiers">
		<!--- add a modifier --->
		<cfparam name="form.addModifier" default="0">
		<cfparam name="form.addModBulkInsert" default="0">
		<cfparam name="form.addModBulkInsert_index_count" default="0">
		
		<cfif form.addModifier EQ 1>
			<cfif form.addModBulkInsert EQ 0>
				<cfset BidRule.Modifiers.index_count = BidRule.Modifiers.index_count + 1>
				<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#" = duplicate(BidRule.Modifiers.Prototype)>
				<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#.iscompound" 		= form.addModifier_iscompound>
				<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#.isindependent" 	= form.addModifier_isindependent>
				<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#.action" 			= 1>
			<cfelse>
				<cfloop index="z" from="1" to="#form.addModBulkInsert_index_count#">
					<cfset BidRule.Modifiers.index_count = BidRule.Modifiers.index_count + 1>
					<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#" = duplicate(BidRule.Modifiers.Prototype)>
					<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#.iscompound" 		= evaluate("form.modifier_iscompound_#z#")>
					<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#.isindependent" 	= evaluate("form.modifier_isindependent_#z#")>
					<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#.bid_rule_modifier_id" 	= evaluate("form.Bid_Rule_Modifier_ID_#z#")>
					<cfset "BidRule.Modifiers.Mod_#BidRule.Modifiers.index_count#.action" 			= 2>				
				</cfloop>
			</cfif>
		</cfif>
		<!--- END --->
	
		<!--- Populate Modifiers --->
		<cfloop index="modIndex" from="1" to="#BidRule.modifiers.index_count#" step="1">
			<cfif isdefined("form.modifier_desc_#modIndex#")>
				<cfset temp_desc 	= trim(evaluate("form.modifier_desc_#modIndex#"))>
				<cfset temp_amt 	= trim(evaluate("form.modifier_amount_#modIndex#"))>
				<cfset temp_uom 	= trim(evaluate("form.modifier_uom_#modIndex#"))>			
				
				<cfset currentnode = evaluate("BidRule.Modifiers.Mod_#modIndex#")>
				<cfif len(temp_desc) GT 0 AND len(temp_amt) GT 0 AND temp_uom NEQ 0>
					<cfset currentnode.validdata = 1>
				</cfif>
				
				<cfif currentnode.validdata EQ 1>
					<cfset currentnode.Modifier_Desc 	= temp_desc>
					<cfset currentnode.Modifier_Amount 	= temp_amt>
					<cfset currentnode.Modifier_UOM 	= temp_uom>
				</cfif>
			</cfif>
		</cfloop>

		<!--- delete a modifier and readjust  --->
		<cfparam name="form.deleteModifier" default="0">
		<cfif form.deleteModifier EQ 1>
			<cfset currentnode = evaluate("BidRule.Modifiers.Mod_#deleteModifierIndex#")>
			<cfif len(trim(currentnode.Bid_Rule_Modifier_ID)) gt 0>
				<cfset BidRule.Modifiers.DeleteTheseMods.Index_Count = BidRule.Modifiers.DeleteTheseMods.Index_Count + 1>
				<cfset "BidRule.Modifiers.DeleteTheseMods.Mods.Mod_#BidRule.Modifiers.DeleteTheseMods.Index_Count#" = Duplicate(currentnode)>
				<cfset "BidRule.Modifiers.DeleteTheseMods.Mods.Mod_#BidRule.Modifiers.DeleteTheseMods.Index_Count#.Action" = 3>
			</cfif>
			
			<cfset temp = structdelete(BidRule.Modifiers, "Mod_#deleteModifierIndex#")>
			<cfset BidRule.Modifiers.Index_Count = BidRule.Modifiers.Index_Count - 1>

			<!--- reindex packet --->
			<cfif BidRule.Modifiers.Index_Count GT 0>
				<cfset loopStartIndex = deleteModifierIndex + 1>
				<cfset loopEndIndex = BidRule.Modifiers.Index_Count + 1>
				<cfloop index="x" from="#loopStartIndex#" to="#loopEndIndex#">
					<cfset currentModIndex = x - 1>
					<cfif currentModIndex NEQ 0>
						<cfset "BidRule.Modifiers.Mod_#currentModIndex#" = Duplicate(evaluate("BidRule.Modifiers.Mod_#x#"))>
						<cfset temp = structdelete(BidRule.Modifiers, "Mod_#x#")>
					</cfif>
				</cfloop>
			</cfif>
		
		</cfif>	
		<!--- END --->

		
	
	</cfcase>
	
<!--- VOLUME GROUPS --->
	<cfcase value="volumegroups">
		<cfset URL.VOLUMEGROUPCOUNT = FORM.VOLUMEGROUPCOUNT>
		<!-- if the variable is defined the user wants action -->
		<cfif isdefined("URL.VOLUMEGROUPCOUNT")>
			<cfif URL.VOLUMEGROUPCOUNT GT 10>
				<cfset URL.VOLUMEGROUPCOUNT = 10>
			</cfif>
			
			<!-- init vars assuming user wants to add groups -->
			<cfset incrementvalue = 1>
			<cfset loopFrom = 1>
			<cfset loopTo = URL.VOLUMEGROUPCOUNT>
			
			<!-- If the request is to remove groups, init vars to make it happen -->
			<cfif URL.VOLUMEGROUPCOUNT LT BidRule.VOLUMEGROUPS.INDEX_COUNT>
				<cfset incrementvalue = -1>
				<cfset loopFrom = BidRule.VOLUMEGROUPS.INDEX_COUNT>
				<cfset loopTo = URL.VOLUMEGROUPCOUNT>
			</cfif>
			
			<!-- before destructively manipulating packet, store data supplied by last user form post into packet -->
			<cfloop index="x" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
				<cfif structkeyexists(BidRule.VOLUMEGROUPS, "group_#x#")>
					<cfif isdefined("form.range_start_#x#")>
						<cfset "BidRule.VOLUMEGROUPS.group_#x#.range_start" = evaluate("form.range_start_#x#")>
					</cfif>
					
					<cfif isdefined("form.range_end_#x#")>
						<cfset "BidRule.VOLUMEGROUPS.group_#x#.range_end" = evaluate("form.range_end_#x#")>
					</cfif>			

					<cfif isdefined("form.range_#x#_Bid_Rule_Group_ID")>
						<cfset "BidRule.VOLUMEGROUPS.group_#x#.Bid_Rule_Group_ID" = evaluate("form.range_#x#_Bid_Rule_Group_ID")>
					</cfif>
				</cfif>
			</cfloop>
			
			<!-- destructively manipulating packet (aka: add or remove volume group objects from it) -->
			<cfloop index="x" from="#loopFrom#" to="#loopTo#" step="#incrementvalue#">
				<!-- does the group related to the loop index exist  -->
				<cfif structkeyexists(BidRule.volumegroups, "group_#x#")><cfset isDefGroup = 1><cfelse><cfset isDefGroup = 0></cfif>
				<!-- if increment value is negative, user wants to delete packets -->
				<cfif incrementvalue LT 0>
					<cfif isDefGroup IS 1 AND x NEQ loopTo><!--- delete it --->
						<cfset thisGroupID = evaluate("BidRule.volumegroups.Group_#x#.Bid_Rule_Group_ID")>
						<cfif len(thisGroupID) GT 0>
							<cfset BidRule.volumegroups.deletethesegroups.index_count = BidRule.volumegroups.deletethesegroups.index_count + 1>
							<cfset "BidRule.volumegroups.deletethesegroups.Group_#BidRule.volumegroups.deletethesegroups.index_count#_ID" = thisGroupID>
						</cfif>
						<cfset temp = structdelete(BidRule.VOLUMEGROUPS, "Group_#x#")>
					</cfif>
				<cfelse>			
					<cfif isDefGroup IS 0><!--- init prototype, aka: create new group --->
						<cfset temp = structinsert(BidRule.VOLUMEGROUPS, "Group_#x#", Duplicate(BidRule.VOLUMEGROUPS.ProtoType))>
					</cfif>			
				</cfif>
				<!-- up the loop count -->
				<cfset BidRule.VOLUMEGROUPS.INDEX_COUNT = x>
			</cfloop>

			<!-- re-store data supplied by last user form post into packet -->
			<cfloop index="x" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
				<cfif structkeyexists(BidRule.VOLUMEGROUPS, "group_#x#")>
					<cfif isdefined("form.range_start_#x#")>
						<cfset "BidRule.VOLUMEGROUPS.group_#x#.range_start" = evaluate("form.range_start_#x#")>
					</cfif>
					
					<cfif isdefined("form.range_end_#x#")>
						<cfset "BidRule.VOLUMEGROUPS.group_#x#.range_end" = evaluate("form.range_end_#x#")>
					</cfif>			
							<cfset BidRule.Blah = "">
					<cfif isdefined("form.range_#x#_Bid_Rule_Group_ID")>
						<cfset "BidRule.VOLUMEGROUPS.group_#x#.Bid_Rule_Group_ID" = evaluate("form.range_#x#_Bid_Rule_Group_ID")>
					</cfif>
				</cfif>
			</cfloop>
		</cfif><!-- end  isdefined("URL.VOLUMEGROUPCOUNT") -->	
		
		<cfset BidRule.volumegroups.ValidData = 0>
		<cfif BidRule.volumegroups.index_count GT 0>
			<cfset BidRule.volumegroups.ValidData = 1>
		</cfif>
	</cfcase>
<!--- 
							OVERAGE 
--->
	<cfcase value="overage">
		<cfloop index="x" list="#form.fieldnames#" delimiters=",">
			<cfset tempArray = listtoarray(x, "_")>
			<cfif arraylen(tempArray) EQ 4>
				<cfif tempArray[1] EQ "TYPE">
					<cfset currentnode = evaluate("BidRule.Type.Type_#tempArray[2]#.OverageAmounts")>
					<cfset "currentnode.Group_Overage_#tempArray[4]#" = evaluate("form.#x#")>
					<cfif isdefined("form.#x#_Bid_Rule_Item_Group_Amount_ID")>
						<cfset "currentnode.Group_Overage_#tempArray[4]#_Bid_Rule_Item_Group_Amount_ID" = evaluate("form.#x#_Bid_Rule_Item_Group_Amount_ID")>
					</cfif>
					<cfif isdefined("form.#x#_UOM")>
						<cfset "currentnode.Group_Overage_#tempArray[4]#_UOM" = evaluate("form.#x#_UOM")>
					</cfif>
				</cfif>

				<!--- manage exceptions --->
				<cfif tempArray[1] EQ "EXCEPTION">
					<cfset currentnode = evaluate("BidRule.Exceptions.Groups.Group_#tempArray[2]#.OverageAmounts")>
					<cfset "currentnode.Group_Overage_#tempArray[4]#" = evaluate("form.#x#")>
					<cfif isdefined("form.#x#_Bid_Rule_Exception_Group_Amount_ID")>
						<cfset "currentnode.Group_Overage_#tempArray[4]#_Bid_Rule_Exception_Group_Amount_ID" = evaluate("form.#x#_Bid_Rule_Exception_Group_Amount_ID")>
					</cfif>
					<cfif isdefined("form.#x#_UOM")>
						<cfset "currentnode.Group_Overage_#tempArray[4]#_UOM" = evaluate("form.#x#_UOM")>
					</cfif>
				</cfif>				
			</cfif>
		</cfloop>
	</cfcase>

<!--- EXCEPTIONS --->
	<cfcase value="exceptions">
	
		<cfif isdefined("form.fieldnames")>
		<cfloop index="fname" list="#form.fieldnames#">
			<cfif len(trim(fname)) GT 10>
				<cfset tempArray = listtoarray(fname, "_")>
				<cfif arraylen(tempArray) EQ 4>
					<cfif lcase(tempArray[1]) EQ "inp" AND lcase(tempArray[2]) EQ "group" AND lcase(tempArray[4]) EQ "name">
						<cfset "BidRule.exceptions.groups.group_#tempArray[3]#.name" = evaluate("form.#fname#")>
					</cfif>
				</cfif>
			</cfif>
		</CFLOOP>
		</cfif>
	
<!--- 		<cfdump var="#BidRule.exceptions#">
		<cfabort> --->
		<cfswitch expression="#form.exception_action#">
			<cfcase value="add_group">

				<cfset BidRule.exceptions.index_count = BidRule.exceptions.index_count + 1>
				<CFSET tempgroup_ID = "GROUP_NEW_" & timeformat(now(), 'hhmmss')>
				<CFSET "BidRule.exceptions.groups.group_#BidRule.exceptions.index_count#" = duplicate(BidRule.exceptions.prototype)>
		
			</cfcase>
			
			<cfcase value="remove_group">
				<cfset DeleteTheseStruct = BidRule.exceptions.deletethesegroups>
				<cfset currentNode = evaluate("BidRule.exceptions.groups.Group_#form.exception_action_index#")>
				<cfif len(trim(currentNode.Exception_Group_ID)) GT 0>
					<cfset DeleteTheseStruct.Index_Count = DeleteTheseStruct.Index_Count + 1>
					<cfset currentNode.action = 3>
					<cfset "DeleteTheseStruct.Group_#DeleteTheseStruct.Index_Count#" = Duplicate(currentNode)>
				</cfif>
				
				<cfset temp = structdelete(BidRule.exceptions.groups, "Group_#form.exception_action_index#")>
				
				<cfloop index="x" from="#form.exception_action_index#" to="#BidRule.exceptions.index_count#">
					<cfset counterNext = x + 1>
					<cfif isdefined("BidRule.exceptions.groups.Group_#counterNext#")>
						<cfset "BidRule.exceptions.groups.Group_#x#" = duplicate(evaluate('BidRule.exceptions.groups.Group_#counterNext#'))>
					</cfif>
				</cfloop>
				
				<cfset temp = structdelete(BidRule.exceptions.groups, "Group_#BidRule.exceptions.index_count#")>
				<cfset BidRule.exceptions.index_count = BidRule.exceptions.index_count - 1>
				
			</cfcase>
			
			<cfcase value="add_product">
				<cfset "BidRule.exceptions.groups.group_#form.exception_action_index#.Product_List" = form.Product_List>
			</cfcase>
			
			<cfcase value="remove_product">
				<cfset tempArray = listtoarray(form.exception_action_index, "_")>
				<cfset index = tempArray[1]>
				<cfset id = tempArray[2]>
				<cfset tempList = evaluate("BidRule.exceptions.groups.group_#index#.Product_List")>
				<cfset tempA = listfindnocase(tempList, id)>
				<cfif tempA GT 0>
					<cfset tempList = listdeleteat(tempList, tempA)>
				</cfif>
				<cfset "BidRule.exceptions.groups.group_#index#.Product_List" = tempList>
			</cfcase>
		
			<cfcase value="loadIntoPacket">
				<cfloop index="x" from="1" to="#form.GroupCount#" step="1">
					<CFSET "BidRule.exceptions.groups.group_#x#" = duplicate(BidRule.exceptions.prototype)>
					<cfset currentnode = evaluate("BidRule.Exceptions.Groups.Group_#x#")>
					<cfset currentnode.name 				= evaluate("form.Inp_Group_#x#_Name")>
					<cfset currentnode.Exception_Group_ID 	= evaluate("form.Inp_Group_#x#_ID")>
					<cfset currentnode.Bid_Rule_Exception_Group_ID = evaluate("form.Inp_Group_#x#_Bid_Rule_Exception_Group_ID")>
					<cfset currentnode.product_list 		= evaluate("form.Inp_Group_#x#_ProductList")>
					<cfset currentnode.action 				= 2>
					
				</cfloop>
				
					<cfset BidRule.exceptions.index_count = form.GroupCount>
			</cfcase>
		
		</cfswitch>
		
	</cfcase>
	
	
<!--- 
							SAVE DATA
--->
	<cfcase value="commitdata">
<!--- 
							SAVE BASIC DATA
--->
		<cfif len(BidRule.Basic.Bid_Rule_ID) EQ 0>
			<cfset useLakebaseForinsertBasicInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rules")>
<cfif useLakebaseForinsertBasicInfo>
	<cftry>
		<cfset application.oLakebase.insertRow("bid_rules", {
			"bid_rule_name" = "#BidRule.Basic.Bid_Rule_Name#",
			"bid_rule_desc" = "#BidRule.Basic.Bid_Rule_Desc#",
			"bid_rule_uom" = "#BidRule.Basic.Bid_Rule_UOM#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertBasicInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertBasicInfo>
<cfquery name="insertBasicInfo" datasource="#application.datasource#">
				INSERT INTO Bid_Rules
				(Bid_Rule_Name,Bid_Rule_Desc,Bid_Rule_UOM)
				VALUES
				('#BidRule.Basic.Bid_Rule_Name#','#BidRule.Basic.Bid_Rule_Desc#','#BidRule.Basic.Bid_Rule_UOM#')
			</cfquery>
</cfif>
			<cfset BidRule.Basic.Bid_Rule_ID = insertBasicInfo.Bid_Rule_ID>
		<cfelse>
			<cfquery name="insertBasicInfo" datasource="#application.datasource#">
				UPDATE 
					Bid_Rules
				SET
					Bid_Rule_Name = '#BidRule.Basic.Bid_Rule_Name#',
					Bid_Rule_Desc = '#BidRule.Basic.Bid_Rule_Desc#',
					Bid_Rule_UOM = '#BidRule.Basic.Bid_Rule_UOM#'
				WHERE
					Bid_Rule_ID = '#BidRule.Basic.Bid_Rule_ID#'
			</cfquery>
		</cfif>
<!--- 
							SAVE VOLUME GROUPS
--->
		<cfloop index="i" from="1" to="#BidRule.VOLUMEGROUPS.INDEX_COUNT#" step="1">
			<cfset currentnode = evaluate("BidRule.VolumeGroups.Group_#i#")>
			<cfif len(currentnode.Bid_Rule_Group_ID) EQ 0>
				<!--- insert --->
				<cfset useLakebaseForinsertGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_volume_groups")>
<cfif useLakebaseForinsertGroup>
	<cftry>
		<cfset application.oLakebase.insertRow("bid_rule_volume_groups", {
			"bid_rule_id" = "#BidRule.Basic.Bid_Rule_ID#",
			"group_index" = "#i#",
			"range_start" = "#currentnode.Range_Start#",
			"range_end" = "#currentnode.Range_End#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertGroup>
<cfquery name="insertGroup" datasource="#application.datasource#">
					INSERT INTO Bid_Rule_Volume_Groups
					(Bid_Rule_ID,Group_Index,Range_Start,Range_End)
					VALUES
					('#BidRule.Basic.Bid_Rule_ID#','#i#','#currentnode.Range_Start#','#currentnode.Range_End#')
				</cfquery>
</cfif>
				<cfset "Bid_Rule_Group_ID_#i#" = insertGroup.Bid_Rule_Group_ID>
			<cfelse>
				<!--- update --->
				<cfset useLakebaseForupdateGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_volume_groups")>
<cfif useLakebaseForupdateGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rule_volume_groups",
			{
				"bid_rule_group_id" = "eq.#currentnode.Bid_Rule_Group_ID#"
			},
			{
				"group_index" = "#i#",
				"range_start" = "#currentnode.Range_Start#",
				"range_end" = "#currentnode.Range_End#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateGroup>
<cfquery name="updateGroup" datasource="#application.datasource#">
					UPDATE Bid_Rule_Volume_Groups
					SET 
						Group_Index	= '#i#',
						Range_Start	= '#currentnode.Range_Start#',
						Range_End	= '#currentnode.Range_End#'
						WHERE Bid_Rule_Group_ID = '#currentnode.Bid_Rule_Group_ID#'
				</cfquery>
</cfif>
				<cfset "Bid_Rule_Group_ID_#i#" = currentnode.Bid_Rule_Group_ID>
			</cfif>			
		</cfloop>
		
		<cfloop index="x" from="1" to="#BidRule.volumegroups.deletethesegroups.index_count#">
			<cfquery name="deleteGroups" datasource="#application.datasource#">
				UPDATE Bid_Rule_Volume_Groups
				SET Deleted = 1
				WHERE Bid_Rule_Group_ID = '#evaluate("BidRule.volumegroups.deletethesegroups.group_#x#_id")#'
			</cfquery>
		</cfloop>
		
<!--- 
							SAVE TYPE CODES
--->
		<cfset thisCounter = 1>
		<!--- loop through types --->
		<cfloop condition="thisCounter NEQ 0">
			<cfif not isdefined("BidRule.Type.Type_#thisCounter#")>
				<cfset thisCounter = 0>
				<cfbreak>
			</cfif>
			<cfset currentnode = evaluate("BidRule.Type.Type_#thisCounter#")>
			<!--- if action 1 insert --->
			<cfif currentnode.action EQ 1>
				<cfquery name="insertTypeCode" datasource="#application.datasource#">
					INSERT INTO Bid_Rule_Items
					(Bid_Rule_ID,Type_Item_ID)
					VALUES
					('#BidRule.Basic.Bid_Rule_ID#', '#currentnode.type_id#')
				</cfquery>
				<cfset currentnode.Bid_Rule_Item_ID = insertTypeCode.Bid_Rule_Item_ID>
			</cfif>

			<!--- if action 2 update --->

			<cfif currentnode.action EQ 2>
				<cfset useLakebaseForupdateTypeCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_items")>
<cfif useLakebaseForupdateTypeCode>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rule_items",
			{
				"bid_rule_item_id" = "eq.#currentnode.type_id#"
			},
			{
				"deleted" = "0"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateTypeCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateTypeCode>
<cfquery name="updateTypeCode" datasource="#application.datasource#">
					UPDATE Bid_Rule_Items
					SET Deleted = 0
					WHERE Bid_Rule_Item_ID = '#currentnode.type_id#'
				</cfquery>
</cfif>
			</cfif>

			<!--- if action 3 delete --->

			<cfif currentnode.action EQ 3>
				<cfset useLakebaseFordeleteTypeCode = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_items")>
<cfif useLakebaseFordeleteTypeCode>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rule_items",
			{
				"bid_rule_item_id" = "eq.#currentnode.Bid_Rule_Item_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteTypeCode = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteTypeCode>
<cfquery name="deleteTypeCode" datasource="#application.datasource#">
					UPDATE Bid_Rule_Items
					SET Deleted = 1
					WHERE Bid_Rule_Item_ID = '#currentnode.Bid_Rule_Item_ID#'
				</cfquery>
</cfif>
			</cfif>
			
 			<!--- update Overage amount --->
			<cfset currentnode_overage = currentnode.overageamounts>
			<cfloop index="x" from="1" to="#currentnode_overage.index_count#" step="1">
				<cfset thisOverageAmount = evaluate("currentnode_overage.Group_Overage_#x#")>
				<cfset thisOverageAmountUOM = evaluate("currentnode_overage.Group_Overage_#x#_UOM")>
				<cfswitch expression="#currentnode.action#">
					<cfcase value="1"><!--- insert --->
						<cfquery name="insertOverage" datasource="#application.datasource#">
							INSERT INTO Bid_Rule_Item_Group_Amounts
							(Bid_Rule_Group_ID,Bid_Rule_Item_ID,Amount, uom)
							VALUES
							('#evaluate("Bid_Rule_Group_ID_#x#")#','#currentnode.Bid_Rule_Item_ID#','#thisOverageAmount#', '#thisOverageAmountUOM#')
						</cfquery>
					</cfcase>

					<cfcase value="2"><!--- update --->
						<cfif isdefined("currentnode_overage.Group_Overage_#x#_Bid_Rule_Item_Group_Amount_ID")>
							<cfset thisOverageAmountID = evaluate("currentnode_overage.Group_Overage_#x#_Bid_Rule_Item_Group_Amount_ID")>
							<cfif len(thisOverageAmountID) gt 0>
								<cfset useLakebaseForupdateAmount = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_item_group_amounts")>
<cfif useLakebaseForupdateAmount>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rule_item_group_amounts",
			{
				"bid_rule_item_group_amount_id" = "eq.#thisOverageAmountID#"
			},
			{
				"amount" = "#thisOverageAmount#",
				"uom" = "#thisOverageAmountUOM#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateAmount = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateAmount>
<cfquery name="updateAmount" datasource="#application.datasource#">
									UPDATE Bid_Rule_Item_Group_Amounts
									SET Amount = '#thisOverageAmount#', UOM = '#thisOverageAmountUOM#'
									WHERE Bid_Rule_Item_Group_Amount_ID = '#thisOverageAmountID#'
								</cfquery>
</cfif>
							<cfelse>
								<cfquery name="insertOverage" datasource="#application.datasource#">
									INSERT INTO Bid_Rule_Item_Group_Amounts
									(Bid_Rule_Group_ID,Bid_Rule_Item_ID,Amount, uom)
									VALUES
									('#evaluate("Bid_Rule_Group_ID_#x#")#','#currentnode.Bid_Rule_Item_ID#','#thisOverageAmount#', '#thisOverageAmountUOM#')
								</cfquery>						
							</cfif>
						<cfelse>
							<cfquery name="insertOverage" datasource="#application.datasource#">
								INSERT INTO Bid_Rule_Item_Group_Amounts
								(Bid_Rule_Group_ID,Bid_Rule_Item_ID,Amount, uom)
								VALUES
								('#evaluate("Bid_Rule_Group_ID_#x#")#','#currentnode.Bid_Rule_Item_ID#','#thisOverageAmount#', '#thisOverageAmountUOM#')
							</cfquery>						
						</cfif>
					</cfcase>

					<cfcase value="3"><!--- update --->
						<cfif isdefined("currentnode_overage.Group_Overage_#x#_Bid_Rule_Item_Group_Amount_ID")>
							<cfset thisOverageAmountID = evaluate("currentnode_overage.Group_Overage_#x#_Bid_Rule_Item_Group_Amount_ID")>
							<cfquery name="updateAmount" datasource="#application.datasource#">
								UPDATE Bid_Rule_Item_Group_Amounts
								SET Deleted = 1
								WHERE Bid_Rule_Item_Group_Amount_ID = '#thisOverageAmountID#'
							</cfquery>
						</cfif>
					</cfcase>					
				</cfswitch>
			</cfloop>
		

		<cfset thisCounter = thisCounter + 1>
	</cfloop>
<!--- 
							SAVE MODIFIERS
--->
		<cfloop index="x" from="1" to="#BidRule.Modifiers.Index_Count#">
			<cfset currentnode = evaluate("BidRule.Modifiers.Mod_#x#")>
			<cfif len(currentnode.Bid_Rule_Modifier_ID) EQ 0 AND currentnode.Action EQ 1>
				<!--- insert --->
				<cfquery name="insertModifier" datasource="#application.datasource#">
					INSERT INTO Bid_Rule_Modifiers
					(Bid_Rule_ID,Modifier_Index,Modifier_Amount,Modifier_Desc,Modifier_UOM, iscompound, isindependent)
					VALUES
					('#BidRule.Basic.Bid_Rule_ID#','#x#','#currentnode.Modifier_Amount#','#currentnode.Modifier_Desc#','#currentnode.Modifier_UOM#', '#currentnode.iscompound#', '#currentnode.isindependent#')
				</cfquery>
			</cfif>
			<!--- update --->
			<cfif len(currentnode.Bid_Rule_Modifier_ID) GT 0 AND currentnode.Action EQ 2>
				<cfset useLakebaseForupdateModifier = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_modifiers")>
<cfif useLakebaseForupdateModifier>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rule_modifiers",
			{
				"bid_rule_modifier_id" = "eq.#currentnode.Bid_Rule_Modifier_ID#"
			},
			{
				"modifier_index" = "#x#",
				"modifier_amount" = "#currentnode.Modifier_Amount#",
				"modifier_desc" = "#currentnode.Modifier_Desc#",
				"modifier_uom" = "#currentnode.Modifier_UOM#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateModifier = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateModifier>
<cfquery name="updateModifier" datasource="#application.datasource#">
					UPDATE
						Bid_Rule_Modifiers
					SET
						Modifier_Index		= '#x#',
						Modifier_Amount		= '#currentnode.Modifier_Amount#',
						Modifier_Desc		= '#currentnode.Modifier_Desc#',
						Modifier_UOM		= '#currentnode.Modifier_UOM#'
					WHERE
						Bid_Rule_Modifier_ID = '#currentnode.Bid_Rule_Modifier_ID#'
				</cfquery>
</cfif>	
			</cfif>
		</cfloop>
		
		<!--- delete modifiers --->
		<cfloop index="x" from="1" to="#BidRule.Modifiers.Deletethesemods.index_count#">
			<cfset currentnode = evaluate("BidRule.Modifiers.Deletethesemods.Mods.Mod_#x#")>
			<cfif len(currentnode.Bid_Rule_Modifier_ID) GT 0 AND currentnode.Action EQ 3>
				<cfset useLakebaseForDeleteMod = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_modifiers")>
<cfif useLakebaseForDeleteMod>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rule_modifiers",
			{
				"bid_rule_modifier_id" = "eq.#currentnode.Bid_Rule_Modifier_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForDeleteMod = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeleteMod>
<cfquery name="DeleteMod" datasource="#application.datasource#">
					UPDATE Bid_Rule_Modifiers
					SET Deleted = 1
					WHERE Bid_Rule_Modifier_ID = '#currentnode.Bid_Rule_Modifier_ID#'
				</cfquery>
</cfif>
			</cfif>
		</cfloop>
		
		<!--- SAVE EXCEPTIONS --->
		<cfloop index="x" from="1" to="#BidRule.Exceptions.Index_Count#">
			<cfset currentnode = evaluate("BidRule.Exceptions.Groups.Group_#x#")>
			
			<cfswitch expression="#currentnode.action#">
				<cfcase value="1"><!--- this is an overall new exception group --->
					<cfset useLakebaseForinsertExceptionGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("exception_groups")>
<cfif useLakebaseForinsertExceptionGroup>
	<cftry>
		<cfset application.oLakebase.insertRow("exception_groups", {
			"group_name" = "#currentnode.name#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForinsertExceptionGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForinsertExceptionGroup>
<cfquery name="insertExceptionGroup" datasource="#application.datasource#">
						INSERT INTO  Exception_Groups
						(Group_Name)
						VALUES
						('#currentnode.name#')
					</cfquery>
</cfif>
					<cfset currentnode.Exception_Group_ID = insertExceptionGroup.Exception_Group_ID>
					
					<!--- relate this group to this rule --->
					<cfset useLakebaseForbindGroupToRule = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_exception_groups")>
<cfif useLakebaseForbindGroupToRule>
	<cftry>
		<cfset application.oLakebase.insertRow("bid_rule_exception_groups", {
			"bid_rule_id" = "#BidRule.Basic.Bid_Rule_ID#",
			"exception_group_id" = "#currentnode.Exception_Group_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForbindGroupToRule = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForbindGroupToRule>
<cfquery name="bindGroupToRule" datasource="#application.datasource#">
						INSERT INTO Bid_Rule_Exception_Groups
						(Bid_Rule_ID, Exception_Group_ID)
						VALUES
						('#BidRule.Basic.Bid_Rule_ID#', '#currentnode.Exception_Group_ID#')
					</cfquery>
</cfif>
					<cfset currentnode.Bid_Rule_Exception_Group_ID = bindGroupToRule.Bid_Rule_Exception_Group_ID>
					
				</cfcase>
				
				<cfcase value="2"><!--- update group --->
					<cfset useLakebaseForupdateGroupInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("exception_groups")>
<cfif useLakebaseForupdateGroupInfo>
	<cftry>
		<cfset application.oLakebase.updateRows("exception_groups",
			{
				"exception_group_id" = "eq.#currentnode.Exception_Group_ID#"
			},
			{
				"group_name" = "#currentnode.Name#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdateGroupInfo = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdateGroupInfo>
<cfquery name="updateGroupInfo" datasource="#application.datasource#">
						UPDATE Exception_Groups
						SET Group_Name = '#currentnode.Name#'
						WHERE Exception_Group_ID = '#currentnode.Exception_Group_ID#'
					</cfquery>
</cfif>
				</cfcase>

				<cfcase value="3"><!--- deltet group rule --->
					<cfquery name="updateGroupInfo" datasource="#application.datasource#">
						UPDATE Bid_Rule_Exception_Groups
						SET Deleted = 1
						WHERE 
							Exception_Group_ID = '#currentnode.Exception_Group_ID#' 
							AND
							Bid_Rule_ID = '#BidRule.Basic.Bid_Rule_ID#'
					</cfquery>
				</cfcase>				
			</cfswitch>
			
			<cfif len(trim(currentnode.Exception_Group_ID)) GT 0>
			<!--- loop through group products --->
				<cfset useLakebaseForgetGroupProducts = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("exception_group_products")>
<cfif useLakebaseForgetGroupProducts>
	<cftry>
		<cfset getGroupProducts = application.oLakebase.toQuery(
			application.oLakebase.selectRows("exception_group_products", {
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
					FROM Exception_Group_Products
					WHERE Deleted = 0
				</cfquery>
</cfif>
				
					<cfset DBList = valuelist(getGroupProducts.Product_ID)>
					<cfset UsrList = currentnode.Product_List>
					
					<cf_list_compare List1="#DBList#" List2="#UsrList#">
					
					<cfset AddTheseProducts=LC_Results2>
					<cfset RemoveTheseProducts=LC_Results1>
					
					<!--- add products to group --->
					<cfif listlen(AddTheseProducts) GT 0>
						<cfloop index="x" list="#AddTheseProducts#">
							<cfset useLakebaseForaddProductToGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("exception_group_products")>
<cfif useLakebaseForaddProductToGroup>
	<cftry>
		<cfset application.oLakebase.insertRow("exception_group_products", {
			"product_id" = "#x#",
			"exception_group_id" = "#currentnode.Exception_Group_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForaddProductToGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForaddProductToGroup>
<cfquery name="addProductToGroup" datasource="#application.datasource#">
								INSERT INTO Exception_Group_Products
								(Product_ID, Exception_Group_ID)
								VALUES
								('#x#', '#currentnode.Exception_Group_ID#')
							</cfquery>
</cfif>
						</cfloop>
					</cfif>

					<!--- remove products from group --->
					<cfif listlen(RemoveTheseProducts) GT 0>
						<cfloop index="x" list="#RemoveTheseProducts#">
							<cfset useLakebaseForRemoveProductFromGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("exception_group_products")>
<cfif useLakebaseForRemoveProductFromGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("exception_group_products",
			{
				"product_id" = "eq.#x#",
				"exception_group_id" = "eq.#currentnode.Exception_Group_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForRemoveProductFromGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForRemoveProductFromGroup>
<cfquery name="RemoveProductFromGroup" datasource="#application.datasource#">
								UPDATE Exception_Group_Products
								SET Deleted = 1
								WHERE Product_ID = '#x#'
								AND Exception_Group_ID = '#currentnode.Exception_Group_ID#'
							</cfquery>
</cfif>
						</cfloop>
					</cfif>					
			</cfif>
			
 			<!--- update Overage amount --->
			<cfset currentnode_overage = currentnode.overageamounts>
			<cfloop index="x" from="1" to="#currentnode_overage.index_count#" step="1">
				<cfset thisOverageAmount = evaluate("currentnode_overage.Group_Overage_#x#")>
				<cfset thisOverageAmountUOM = evaluate("currentnode_overage.Group_Overage_#x#_UOM")>
				<cfswitch expression="#currentnode.action#">
					<cfcase value="1"><!--- insert --->
						<cfquery name="insertOverage" datasource="#application.datasource#">
							INSERT INTO Bid_Rule_Exception_Group_Amounts
							(Bid_Rule_Group_ID,Bid_Rule_Exception_Group_ID,Amount, uom, Exception_Group_ID)
							VALUES
							('#evaluate("Bid_Rule_Group_ID_#x#")#','#currentnode.Bid_Rule_Exception_Group_ID#','#thisOverageAmount#', '#thisOverageAmountUOM#', '#currentnode.Exception_Group_ID#')
						</cfquery>
					</cfcase>

					<cfcase value="2"><!--- update --->
						<cfif isdefined("currentnode_overage.Group_Overage_#x#_Bid_Rule_Exception_Group_Amount_ID")>
							<cfset thisOverageAmountID = evaluate("currentnode_overage.Group_Overage_#x#_Bid_Rule_Exception_Group_Amount_ID")>
							<cfif len(thisOverageAmountID) gt 0>
								<cfquery name="updateAmount" datasource="#application.datasource#">
									UPDATE Bid_Rule_Exception_Group_Amounts
									SET Amount = '#thisOverageAmount#', UOM = '#thisOverageAmountUOM#'
									WHERE Bid_Rule_Exception_Group_Amount_ID = '#thisOverageAmountID#'
								</cfquery>
							<cfelse>
								<cfquery name="insertOverage" datasource="#application.datasource#">
									INSERT INTO Bid_Rule_Exception_Group_Amounts
									(Bid_Rule_Group_ID,Bid_Rule_Exception_Group_ID,Amount, uom, Exception_Group_ID)
									VALUES
									('#evaluate("Bid_Rule_Group_ID_#x#")#','#currentnode.Bid_Rule_Exception_Group_ID#','#thisOverageAmount#', '#thisOverageAmountUOM#', '#currentnode.Exception_Group_ID#')
								</cfquery>						
							</cfif>
						<cfelse>
							YO: <h1></h1>
							<cfflush>
							<cfquery name="insertOverage" datasource="#application.datasource#">
									INSERT INTO Bid_Rule_Exception_Group_Amounts
									(Bid_Rule_Group_ID,Bid_Rule_Exception_Group_ID,Amount, uom, Exception_Group_ID)
									VALUES
									('#evaluate("Bid_Rule_Group_ID_#x#")#','#currentnode.Bid_Rule_Exception_Group_ID#','#thisOverageAmount#', '#thisOverageAmountUOM#', '#currentnode.Exception_Group_ID#')
							</cfquery>						
						</cfif>
					</cfcase>

					<cfcase value="3"><!--- update --->
						<cfif isdefined("currentnode_overage.Group_Overage_#x#_Bid_Rule_Item_Group_Amount_ID")>
							<cfset thisOverageAmountID = evaluate("currentnode_overage.Group_Overage_#x#_Bid_Rule_Item_Group_Amount_ID")>
							<cfquery name="updateAmount" datasource="#application.datasource#">
								UPDATE Bid_Rule_Exception_Group_Amounts
								SET Deleted = 1
								WHERE Bid_Rule_Exception_Group_Amount_ID = '#thisOverageAmountID#'
							</cfquery>
						</cfif>
					</cfcase>					
				</cfswitch>
			</cfloop>			
		</cfloop>	
		
		<!--- DELETE GROUPS FROM RULES --->	
		<cfloop index="x" from="1" to="#BidRule.Exceptions.DeleteTheseGroups.Index_Count#">
			<cfset currentNode = evaluate("BidRule.Exceptions.DeleteTheseGroups.Group_#x#")>
			<cfset useLakebaseFordeleteExceptionGroup = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bid_rule_exception_groups")>
<cfif useLakebaseFordeleteExceptionGroup>
	<cftry>
		<cfset application.oLakebase.updateRows("bid_rule_exception_groups",
			{
				"bid_rule_id" = "eq.#BidRule.Basic.Bid_Rule_ID#",
				"exception_group_id" = "eq.#currentNode.Exception_Group_ID#"
			},
			{
				"deleted" = "1"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseFordeleteExceptionGroup = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseFordeleteExceptionGroup>
<cfquery name="deleteExceptionGroup" datasource="#application.datasource#">
				UPDATE Bid_Rule_Exception_Groups
				SET Deleted = 1
				WHERE Bid_Rule_ID = '#BidRule.Basic.Bid_Rule_ID#' AND Exception_Group_ID = '#currentNode.Exception_Group_ID#'
			</cfquery>
</cfif>
			
		</cfloop>
		

		<!--- LAST MODIFIED RECORD --->
		<cfquery name="updateLastModified" datasource="#application.datasource#">
			UPDATE Bid_Rules
			SET 
				Last_Mod_Usr_ID = '#request.AccessStructure.user_id#',
				Last_Mod_Date = getdate()
			WHERE
				Bid_Rule_ID = '#BidRule.Basic.Bid_Rule_ID#'
		</cfquery>
		
		<cfset url.sg = form.sg>
		<cfset url.id = BidRule.Basic.Bid_Rule_ID>
		<cfset BidRule = "">
		<cfinclude template="packet.cfm">
		<cfinclude template="populatepacket.cfm">		
		<cfset form.donotrelocate = 0>
	</cfcase>
	
	<cfcase value="exception_list">
		<cfparam name="form.list_of_selected_groups" default="">
		<cfparam name="form.currentgrouplist" default="">
		<!--- compare sent list to existing list --->
		<cf_list_compare List1="#form.list_of_selected_groups#" List2="#form.CurrentGroupList#">
		<cfset list_remove_these 	= LC_Results1>
		<cfset list_add_these 		= LC_Results2>
	
		<cfloop index="x" list="#list_add_these#">
				<cfset BidRule.exceptions.index_count = BidRule.exceptions.index_count + 1>
				<CFSET "BidRule.exceptions.groups.group_#BidRule.exceptions.index_count#" = duplicate(BidRule.exceptions.prototype)>
				<cfset currentNode = evaluate("BidRule.exceptions.groups.group_#BidRule.exceptions.index_count#")>
				<cfset currentNode.name = evaluate("form.Group_#x#_name")>
				<cfset currentNode.exception_group_id = x>
				<cfset currentNode.product_list = evaluate("form.Group_#x#_ProductList")>
		</cfloop>
	
		
		<!--- remove groups --->
		<cfloop index="x" from="1" to="#BidRule.Exceptions.Index_Count#" step="1">
			<cfset currentnode = evaluate("BidRule.Exceptions.Groups.Group_#x#")>
			<cfif len(trim(currentnode.exception_group_id)) gt 0>
				<cfif listfind(list_remove_these, currentnode.exception_group_id) NEQ 0>
				
				</cfif>
			</cfif>
		</cfloop>

	</cfcase>

	<cfdefaultcase>
		<!-- something is wrong i should neva never be executed -->
	</cfdefaultcase>
</cfswitch>

<!--- validate groups --->
<cfset BidRule.volumegroups.ValidData = 0>
<cfif BidRule.volumegroups.index_count GT 0>
	<cfset BidRule.volumegroups.ValidData = 1>
</cfif>
<!--- make sure overages are in the type structs and exception structs--->
<!---  --->
<cfset OverageStructList = ArrayNew(1)>
<cfset OverageStructList[1][1] = "BidRule.Type"> <!--- Struct Location --->
<cfset OverageStructList[1][2] = "Index_Count"> <!--- Struct item count --->
<cfset OverageStructList[1][3] = "Type_"> <!--- Struct Location --->
<cfset OverageStructList[1][4] = "overageamounts"> <!--- Struct Location --->

<cfset OverageStructList[2][1] = "BidRule.Exceptions"> <!--- Struct Location --->
<cfset OverageStructList[2][2] = "Index_Count"> <!--- Struct item count --->
<cfset OverageStructList[2][3] = "Groups.Group_"> <!--- Struct Location --->
<cfset OverageStructList[2][4] = "overageamounts"> <!--- Struct Location --->

<!--- <cfdump var="#BidRule.Type#">
<hr>
<cfdump var="#form#">
<cfabort> --->

<cfloop index="CurrentCount" from="1" to="#arraylen(OverageStructList)#">
	<cfloop index="x" from="1" to="#evaluate('#OverageStructList[CurrentCount][1]#.#OverageStructList[CurrentCount][2]#')#" step="1">
		<!--- <cfset currentnode = evaluate("BidRule.Type.Type_#x#.OverageAmounts")> --->
		<cfset currentnode = #evaluate('#OverageStructList[CurrentCount][1]#.#OverageStructList[CurrentCount][3]##x#.#OverageStructList[CurrentCount][4]#')#> 
		<!-- init vars assuming user wants to add groups -->
		<cfset incrementvalue = 1>
		<cfset loopFrom = 1>
		<cfset loopTo = BidRule.Volumegroups.Index_Count>
		<!-- If the request is to remove groups, init vars to make it happen -->
		<cfif BidRule.Volumegroups.Index_Count LT currentnode.INDEX_COUNT>
			<cfset incrementvalue = -1>
			<cfset loopFrom = currentnode.INDEX_COUNT>
			<cfset loopTo = BidRule.Volumegroups.Index_Count>
		</cfif>
	
		<cfloop index="n" from="#loopFrom#" to="#loopTo#" step="#incrementvalue#">
			<cfset isDefGroup = 0>
			<cfif structkeyexists(currentnode, "Group_Overage_#n#")>
				<cfset isDefGroup = 1>
			</cfif>
			<cfif incrementvalue LT 0>
				<cfif isDefGroup IS 1 and n NEQ loopTo><!--- delete it --->
					<cfset temp = structdelete(Currentnode, "Group_Overage_#n#")>
				</cfif>
			<cfelse>			
				<cfif isDefGroup IS 0><!--- init prototype, aka: create new group --->
					<cfset "currentnode.Group_Overage_#n#" = "">
				</cfif>			
			</cfif>
			<cfset currentnode.Index_Count = n>
		</cfloop>
	</cfloop>

	
<!--- 	<cfoutput><h1>#tempCounter# EQ #evaluate("#OverageStructList[CurrentCount][1]#.#OverageStructList[CurrentCount][2]#")#*(#BidRule.volumegroups.index_count#))</h1></cfoutput>
	<cfabort>
 --->
	<cfset "#OverageStructList[CurrentCount][1]#.Overage.ValidData" = 0>
	<cfset tempCounter = 0>
	<cfset thisCounter = 1>
	<cfset deleteCounter = 0>
	
	<!--- loop through types --->
	<cfloop condition="thisCounter NEQ 0">
		<cfif not isdefined("#OverageStructList[CurrentCount][CurrentCount]#.#OverageStructList[CurrentCount][3]##thisCounter#")>
			<cfset thisCounter = 0>
			<cfbreak>
		</cfif>
			
		<cfset currentnode = evaluate("#OverageStructList[CurrentCount][CurrentCount]#.#OverageStructList[CurrentCount][3]##thisCounter#")>
		<cfif currentnode.action NEQ 3>
			<!--- loop through overages --->
			<cfloop index="n" from="1" to="#currentnode.OverageAmounts.Index_Count#" step="1">
				<cfset currentOverageNode = evaluate("currentnode.OverageAmounts.Group_Overage_#n#")>
				<cfif len(currentOverageNode) GT 0 AND isnumeric(currentOverageNode)>
					<cfset tempCounter = tempCounter + 1>
				</cfif>
			</cfloop>
		<cfelse>
			<cfset deleteCounter = deleteCounter + 1>
		</cfif>
		<cfset thisCounter = thisCounter + 1>
	</cfloop>
	
	<cfif (tempCounter) EQ ((evaluate("#OverageStructList[CurrentCount][1]#.#OverageStructList[CurrentCount][2]#")-deleteCounter)*(BidRule.volumegroups.index_count)) AND tempCounter NEQ 0>
		<cfset "#OverageStructList[CurrentCount][1]#.Overage.ValidData" = 1>
	</cfif>
<!---  --->	
</cfloop>
<!---  --->



<!-- WRITE PACKET -->
<cfwddx action="CFML2WDDX" input="#BidRule#" output="packet" usetimezoneinfo="Yes">
<!---
<cffile action="WRITE" file="#apppath#\WddxPackets\#form.sg#.ddx" output="#packet#" addnewline="Yes">
--->
<cffile action="WRITE" file="#Application.Doc_Path#\temp_files\WddxPackets\#form.sg#.ddx" output="#packet#" addnewline="Yes">

<cfif form.donotrelocate EQ 0>
	<cfif form.nextTab EQ "savecomplete">
		<cflocation url="popupWindow_Content.cfm?currentTab=summary&sg=#form.sg#&savecomplete=1" addtoken="No">
	<cfelse>
		<cflocation url="popupWindow_Content.cfm?currentTab=#form.nextTab#&sg=#form.sg#" addtoken="No">
	</cfif>
	
</cfif>