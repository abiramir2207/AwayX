<!----
	Filename:	C:\Work\Code\base\AwayX\settings\app_settings_19.cfm
	Created:	1/9/2012
 	Developer:	drachala
	Copyright (c) 2006 Blacksmith Applications, Inc.

	Description:
		Used to UPDATE "Rebate, Lump Sum, Growth, Fixed Price"
	Usage:
		U
---->
<cfset qdiscountTypes = request.qLabels.getDiscountTypes()>
<cfset session.labelMode = URL.labelMode>
<cfset session.appSetCode = URL.appSetCode>
<cfset session.incFile = URL.incFile>

<cfset discountTypesValue = "">

<cfloop query="qdiscountTypes" >
	<cfset discountTypesValue = #listappend(discountTypesValue, discount_type_desc)#>
</cfloop>
<cfif isDefined("URL.updated") AND URL.updated EQ 1>
	<div id="masterContainer">
		<strong style="color:green; font-size:18px;">Labels updated successfully.</strong>
	</div>
</cfif>
<form name="discountTypes" action="" method="post">
<div id="masterContainer">
<cfset discountTypeList = "Fixed Price,Growth,Lump Sum, Rebate">
<cfset discountTypesId = "1, 4, 3, 2">
	<div id="headerContainer">
		<div id="innerheaderContainer">Discount Type Label</div>
		<div id="innerheaderContainer">Client Label</div>
	</div>
		<cfset row = 0>
	<cfloop list="#discountTypeList#" index="i">
		<cfset row = row + 1>
		<cfif row MOD 2>
			<cfset rowHilite = "rowBg1">
		<cfelse>
			<cfset rowHilite = "rowBg2">
		</cfif>
<cfoutput>
		<div id="bodyContainer" class="sortSection #rowHilite#">
			<div id="innerBodyContainer">
				 #i#
			</div>
			<div id="innerBodyContainer">
				 <input tpe="text" name="discountTypeName_#row#" value="#listgetat(discountTypesValue, row)#" size="25">
			</div>
		</div>
		<input type="hidden" name="discountTypeID_#row#" value="#listgetat(discountTypesId, row)#">
</cfoutput>
	</cfloop>
	<cfoutput><input type="hidden" name="loopCnt" value="#row#"></cfoutput>
</div>
	<input type="hidden" name="DiscountTypes" value="1">
<div id="MainBtnCont" align="center" style="width:700px;margin:10px;">
		<CF_button
				button_name		=	""
				button_caption	=	"Save"
				button_action	=	"discountTypes.submit(document.discountTypes);"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				button_tip		=	"Save"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
				>
</div>
</form>