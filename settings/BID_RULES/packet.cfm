<cfset sessionGUID 											= createuuid()&createuuid()>
<cfset sessionGUID											= replace(sessionGUID, "-", "", "ALL")>
<cfset BidRule 												= StructNew()>
<cfset BidRule.sessionGUID									= sessionGUID>

<cfset BidRule.Basic 										= StructNew()>
<cfset BidRule.Basic.Bid_Rule_ID							= "">
<cfset BidRule.Basic.ValidData								= "0">
<cfset BidRule.Basic.Bid_Rule_Name							= "">
<cfset BidRule.Basic.Bid_Rule_Desc							= "">
<cfset BidRule.Basic.Bid_Rule_UOM							= "0">

<cfset BidRule.Modifiers 									= StructNew()>
<cfset BidRule.Modifiers.Index_Count 						= 0>
<cfset BidRule.Modifiers.DeleteTheseMods 					= StructNew()>
<cfset BidRule.Modifiers.DeleteTheseMods.Index_Count		= 0>
<cfset BidRule.Modifiers.DeleteTheseMods.Mods				= StructNew()>
	<cfset BidRule.Modifiers.Prototype						= StructNew()>
	<cfset BidRule.Modifiers.Prototype.Action				= 0>
	<cfset BidRule.Modifiers.Prototype.Bid_Rule_Modifier_ID	= "">
	<cfset BidRule.Modifiers.Prototype.Modifier_Index		= "">
	<cfset BidRule.Modifiers.Prototype.Modifier_Amount		= "">
	<cfset BidRule.Modifiers.Prototype.Modifier_Desc		= "">
	<cfset BidRule.Modifiers.Prototype.Modifier_UOM			= "">
	<cfset BidRule.Modifiers.Prototype.iscompound			= "">
	<cfset BidRule.Modifiers.Prototype.isindependent		= "">
	<cfset BidRule.Modifiers.Prototype.ValidData			= 0>
	
<!--- 	<!--- init mods --->
	<cfset defaultmodcount = 2>
	<cfloop index="x" from="1" to="#defaultmodcount#" step="1">
		<cfset protoCopy = duplicate(BidRule.Modifiers.ProtoType)>
		<cfset "BidRule.Modifiers.Mod_#x#" = duplicate(protoCopy)>
		<cfif x mod 2>
			<cfset "BidRule.Modifiers.Mod_#x#.iscompound" = 1>
		<cfelse>
			<cfset "BidRule.Modifiers.Mod_#x#.isindependent" = 1>
		</cfif>
		<cfset BidRule.Modifiers.Index_Count = BidRule.Modifiers.Index_Count + 1>
	</cfloop> --->

<cfset BidRule.type 										= StructNew()>
<cfset BidRule.type.ValidData 								= 0>
<cfset BidRule.type.Index_Count 							= 0>
<cfset BidRule.type.Current_Index 							= "">
<cfset BidRule.type.Overage.ValidData						= 0>
<cfset BidRule.type.Bid_Rule_Item_ID						= "">
<cfset BidRule.type.Is_Exception_Type						= 0>

	<cfset BidRule.type.prototype.Index_Count				= "">
	<cfset BidRule.type.prototype.type_id					= "">
	<cfset BidRule.type.prototype.action					= ""><!--- 1, insert, 2, delete_from_table, 3, delete_from_packet --->
	<cfset BidRule.type.prototype.Description				= "">
	<cfset BidRule.type.prototype.OverageAmounts			= StructNew()>
	<cfset BidRule.type.prototype.OverageAmounts.Index_Count = 0>

<cfset BidRule.volumegroups 								= StructNew()>
<cfset BidRule.volumegroups.index_count						= 0>
<cfset BidRule.volumegroups.ValidData						= 0>
<cfset BidRule.volumegroups.DeleteTheseGroups				= StructNew()>
<cfset BidRule.volumegroups.DeleteTheseGroups.Index_Count	= 0>
	<cfset BidRule.volumegroups.prototype					= StructNew()>
	<cfset BidRule.volumegroups.prototype.Bid_Rule_Group_ID	= "">
	<cfset BidRule.volumegroups.prototype.Group_Index		= "">
	<cfset BidRule.volumegroups.prototype.Bid_Rule_ID		= "">
	<cfset BidRule.volumegroups.prototype.Range_Start		= "">
	<cfset BidRule.volumegroups.prototype.Range_End			= "">
	


<cfset BidRule.overage 										= StructNew()>

<cfset BidRule.exceptions					= StructNew()>
<cfset BidRule.exceptions.index_count 		= 0>
<cfset BidRule.exceptions.ValidData 		= 0>
<cfset BidRule.exceptions.groups 			= structnew()>

<cfset BidRule.exceptions.DELETETHESEGROUPS 			= structnew()>
<cfset BidRule.exceptions.DELETETHESEGROUPS.INDEX_COUNT	= 0>


<cfset BidRule.exceptions.prototype 							= structnew()>
<cfset BidRule.exceptions.prototype.name 						= "">
<cfset BidRule.exceptions.prototype.Exception_Group_ID			= "">
<cfset BidRule.exceptions.prototype.Bid_Rule_Exception_Group_ID	= "">
<cfset BidRule.exceptions.prototype.product_list 				= "">
<cfset BidRule.exceptions.prototype.OverageAmounts				= StructNew()>
<cfset BidRule.exceptions.prototype.OverageAmounts.Index_Count 	= 0>
<cfset BidRule.exceptions.prototype.action 						= 1><!--- 1, insert, 2, delete_from_table, 3, delete_from_packet --->



<cfwddx action="CFML2WDDX" input="#BidRule#" output="BidRule_Serialized" usetimezoneinfo="Yes">
<!-- <cfdump var="#BidRule_Serialized#"> -->
<!---
<cffile action="WRITE" file="#apppath#\WddxPackets\#sessionGUID#.ddx" output="#BidRule_Serialized#" addnewline="Yes">
--->
<cffile action="WRITE" file="#Application.Doc_Path#\temp_files\WddxPackets\#sessionGUID#.ddx" output="#BidRule_Serialized#" addnewline="Yes">