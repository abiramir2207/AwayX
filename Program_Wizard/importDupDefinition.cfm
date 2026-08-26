<cfparam name="PageName"	default="Duplicate Program">
<cfif Not isDefined("dupTemplateManager")>
	<cfset dupTemplateManager = CreateObject("component","components.programs.template.DuplicateTemplateManager").init(ID, '#trim(PageName)#') />
</cfif>
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />		
<cfset appSettings = genSettingsManager.get()>
<!--- get summary of the duplicate definition items (high level) --->
<cfset preDefinedDupDef = dupTemplateManager.getPreDefinedDupDef() />
<cfset itemCountStruc = StructNew()>
<cfparam name="itemList" default="">
<cfloop query="preDefinedDupDef">
	<cfset itemCountStruc[Item] = Item_Count >
	<cfset itemList = listAppend(itemList, item)>
</cfloop>
<cfset itemSortKeyArray = ArrayNew(1)>
<!--- build up itemStruct --->
<cfset itemStruc = StructNew()>
<cfset itemKeyArray = StructKeyArray(itemCountStruc) >
<cfloop index="i" from="1" to="#ArrayLen(itemKeyArray)#"  step="1">
	<cfif IsNumeric(itemKeyArray[i]) >
		<!--- default radio --->
		<cfif itemCountStruc[itemKeyArray[i]] EQ 1>
			<cfset itemStruc[itemKeyArray[i]][1] = 1>
			<cfset radio_index = 1>
		<cfelse>
			<cfset itemStruc[itemKeyArray[i]][1] = 2>
			<cfset radio_index = 2>
		</cfif>
		<cfset item = itemKeyArray[i] >
		<cfset isChecked = 1 >
		<cfif appSettings.getOperatingGroupOn() NEQ 1 AND item EQ 8>
			<cfset radio_index = 0>
			<cfset isChecked = 0>
		</cfif>
		<cfset itemKey = "#listFind(itemList, item)#-#item#-#radio_index#-#isChecked#">
		<cfset itemStruc[itemKey] = ArrayNew(1)>
		<cfset itemStruc[itemKey][1] = radio_index>
	</cfif>
</cfloop>

<!--- loop through item list to get key list --->
<!--- insert into the dup template table--->
<cfset itemStruc.programcontrol_Panel_Options_ID = ID>
<cfset itemStruc.page_id = dupTemplateManager.getPageID() >

<cfset dupTemplateManager.saveTemplateInfo(itemStruc)>

