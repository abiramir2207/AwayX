<cfcomponent output="false" alias="mvc.Models.Item.vos.ProductAttr">

	<cfproperty name="active" 					type="boolean"	default="1" >
	<cfproperty name="allowFilter" 				type="boolean"	default="0" >
	<cfproperty name="allowInGroupSearch"		type="boolean"	default="0" >
	<cfproperty name="allowInSearch" 			type="boolean"	default="0" >
	<cfproperty name="createdDate" 				type="string"	default="" >
	<cfproperty name="groupLevelId"				type="numeric"	default="0">
	<cfproperty name="groupLevelDesc"			type="string"	default="">
	<cfproperty name="listOrder"				type="numeric"	default="0" >
	<cfproperty name="pgFlag"					type="boolean"	default="0" >
	<cfproperty name="pgGroupType"  			type="numeric"	default="0" >
	<cfproperty name="productGroupAttributeId" 				type="numeric"	default="0" >
	<cfproperty name="productGroupAttributeIdField" 		type="string"	default="" >
	<cfproperty name="productGroupAttributeInterfaceField" 	type="string"	default="" >
	<cfproperty name="productGroupAttributeMasterIdField" 	type="string"	default="" >
	<cfproperty name="productGroupAttributeNameField" 		type="string"	default="" >
	<cfproperty name="productGroupAttributeNumberField" 	type="string"	default="" >
	<cfproperty name="productGroupAttributeSearchSequenceField" type="string"	default="" >
	<cfproperty name="productGroupAttributeTable" 			type="string"	default="" >
	<cfproperty name="ProductGroupLevelId"					type="numeric"	default="0" >
	<cfproperty name="searchDp" 							type="array" 	default="#ArrayNew(1)#">

	<!---
	<cfproperty name="" 	type="string" default="">
	<cfproperty name="" 	type="string" default="">
	--->

</cfcomponent>