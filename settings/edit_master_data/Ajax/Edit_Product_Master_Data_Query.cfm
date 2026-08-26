<!----
	Filename:	C:\Work\Code\base\AwayX\settings\edit_Master_data\ajax\Edit_master_data_query.cfm
	Created:	3/12/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR MASTER DATA
	Usage:
		SETTING>>ADMINISTRATOR>>EDIT_MASTER_DATA.
---->
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">

<cfsilent>
 
<cfparam name="url.iDisplayStart"   default="0">
<cfparam name="url.iDisplayLength"  default="20">
<cfparam name="url.sEcho"           default="10">
<cfparam name="url.iSortCol_0"		default="0">
<cfparam name="url.sSortDir_0"		default="ASC">

	<cfscript>
		tmp   = structnew();
		reply = structnew();
		tmp.page_size   = val(url.iDisplayLength);
		tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
	</cfscript>

<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. --->  
		<cfscript>
			tmp.columnArray = ["Item", "Description", "Brand", "Product", "Class","TypeCode"];    
		</cfscript>



<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="Items" datasource="#application.datasource#">
		SELECT     		BSA.Item AS Item, 
								BSA.Description AS Description, 
								Brand.Brand AS Brand, 
								Class_Code.Class_Code_Desc AS Class, 
								BSA_Product_Group.Product_Group_Desc AS Product,
								Type_Code_Desc.Type_Code_Desc AS TypeCode, 
								BSA.BSA_Foodservice_Items_Master_ID
		FROM       		BSA_Foodservice_Items_Master BSA
		INNER JOIN 	Brand 
		ON 					BSA.Brand_ID = Brand.Brand_ID 
		LEFT JOIN  		Class_Code 
		ON 					BSA.Class_Code_UUID = Class_Code.Class_Code_UUID 
		LEFT JOIN  		BSA_Product_Group 
		ON 					BSA.BSA_Product_Group_ID = BSA_Product_Group.BSA_Product_Group_ID
		LEFT JOIN  		Type_Code_Desc 
		ON BSA.Type_Code_Desc_ID = 	Type_Code_Desc.Type_Code_Desc_ID
		WHERE	   		BSA.Deleted = 0 
		AND 	   			BSA.Active_Code = '#trim(url.active)#'
		<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		AND 	 ( 
						(Item like '%#url.sSearch#%') 
				OR 	(Description like '%#url.sSearch#%') 
				OR 	(Brand.Brand like '%#url.sSearch#%') 
				OR 	(Class_Code_Desc like '%#url.sSearch#%') 
				OR 	(Product_Group_Desc like '%#url.sSearch#%')
				OR  (Type_Code_Desc.Type_Code_Desc like '%#url.sSearch#%')
					)	
		</cfif>
		ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#             
</cfquery>

<cfset ItemsInfo = QueryNew("Item, Description, Brand, Product, Class, TypeCode","varchar,varchar,varchar,varchar,varchar,varchar") />

<cfloop query="Items">

		<cfset QueryAddRow(ItemsInfo) />
		<cfset Itemlink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Items_Master_ID#''' &');" style="color:3D3D3D">' & #Item# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Item", "#Itemlink#") />
		<cfset Desclink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Items_Master_ID#''' &');" style="color:3D3D3D">' & #Description# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Description", "#Desclink#") />	
		<cfset BIDlink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Items_Master_ID#''' &');" style="color:3D3D3D">' & #Brand# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Brand", "#BIDlink#") />
		<cfset Productlink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Items_Master_ID#''' &');" style="color:3D3D3D">' & #Product# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Product", "#Productlink#") />
		<cfset Classlink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Items_Master_ID#''' &');" style="color:3D3D3D">' & #Class# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Class", "#Class#") />
		<cfset TypeCodelink = '<a href="javascript:navigate('& '''#BSA_Foodservice_Items_Master_ID#''' &');" style="color:3D3D3D">' & #TypeCode# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "TypeCode", "#TypeCode#") />
		
</cfloop>

		<cfset reply.iTotalRecords        = #ItemsInfo.recordcount#>
		<cfset reply.iTotalDisplayRecords = #ItemsInfo.recordcount#>


		<cfset start = url.iDisplaystart>
		<cfset end 	= url.iDisplaystart + 20>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>

<!--- Generate JSON from Query --->
		<cfset tmp.dArray = ArrayNew(1) >
<cfloop query="ItemsInfo" startrow="#start#" endrow="#end#">
		<cfset dArrayTmp = arraynew(1)>
<cfloop array="#tmp.columnArray#" index="tmp.columnName">
		<cfset ArrayAppend(dArrayTmp, (ItemsInfo[tmp.columnName][ItemsInfo.currentRow]))>
</cfloop>
		<cfset ArrayAppend(tmp.dArray, dArrayTmp) >
</cfloop>

		<cfset reply.aaData = tmp.dArray>
		<cfset reply.sEcho  = javacast('int', url.sEcho)>

		<cfset tmp.sOut = SerializeJSON( reply )>

<!--- Since SerializeJSON capitalize the content which is case-sensitive let's reset it the correct way --->
		<cfset tmp.sOut = Replace (tmp.sOut, 'SECHO', 'sEcho')>
		<cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALRECORDS', 'iTotalRecords')>
		<cfset tmp.sOut = Replace (tmp.sOut, 'ITOTALDISPLAYRECORDS', 'iTotalDisplayRecords')>
		<cfset tmp.sOut = Replace (tmp.sOut, 'AADATA', 'aaData')>
</cfsilent>


<!---send JSON data back to client--->
<cfoutput>#tmp.sOut#</cfoutput>
</cfprocessingdirective>
 