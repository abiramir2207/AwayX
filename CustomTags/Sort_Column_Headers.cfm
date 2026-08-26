<!------ Sort_Column_Headers.cfm ----->
<cfsetting enablecfoutputonly="Yes">
<cfparam name="Attributes.formName" 	default="">
<cfparam name="Attributes.sortByFieldName" 	default="">
<cfparam name="Attributes.sortOrderFieldName" 	default="">
<cfparam name="Attributes.sortByList" 	default="">
<cfparam name="Attributes.currentSortBy" 	default="">
<cfparam name="Attributes.currentSortOrder" 	default="">
<cfparam name="Attributes.TDExtraStyle" 		default="">

<cfoutput>
	<script language="JavaScript">
	function sortByThisItem(thisSortItem, thisSortOrder)
	{
		var formObj;
		formObj = document.all.#Attributes.formName#;
		formObj.#Attributes.sortByFieldName#.value = thisSortItem;
		formObj.#Attributes.sortOrderFieldName#.value = thisSortOrder;
		formObj.submit();
		return false;
	}	
	</script>
</cfoutput>
<cfloop list="#Attributes.sortByList#" delimiters="," index="thisItem">
	<cfset itemLabel = ListFirst(thisItem, ":")>
	<cfset itemValue = "">
	<cfif ListLen(thisItem, ":") GT 1>
		<cfset itemValue = ListGetAt(thisItem, 2, ":")>
	</cfif>
	
	<CFSET sortImage="">				
	<cfif itemValue EQ Attributes.currentSortBy>
		<cfif Attributes.currentSortOrder EQ "DESC">
			<cfset New_Sort_Order="ASC">
			<cfset sortImage="up_1.gif">
		<cfelse>
			<cfset New_Sort_Order="DESC">
			<cfset sortImage="down_1.gif">
		</CFIF>
	<cfelse>
		<cfset New_Sort_Order="ASC">
	</cfif>
	<cfoutput>	
	<td id="header" #Attributes.TDExtraStyle#>
	<cfif Len(itemValue) GT 0>
	<a href="##" OnClick="javaScript: return sortByThisItem('#itemValue#','#New_Sort_Order#');">
	</cfif>
	<b>#itemLabel#</b>
	<cfif Len(itemValue) GT 0>
	<cfif Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></cfif>
	</td>
	</cfoutput>
</cfloop>
<cfsetting enablecfoutputonly="No">