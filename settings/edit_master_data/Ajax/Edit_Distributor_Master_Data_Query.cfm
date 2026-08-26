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
			tmp.columnArray = ["SHIP_TO", "NAME", "Address", "City", "State", "Freight_Bracket_Label", "Price_List_Description", "Distributor_Type_Name", "Distributor_Type_C_Desc", "Distributor_Type_B_Desc", "Distributor_Type_H_Desc"];    
		</cfscript>



<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="Items" datasource="#application.datasource#">
			SELECT 	BSA.Ship_To, 
							BSA.Name, 
							BSA.BSA_Foodservice_Customers_ID, 
							PLH.Price_List_Description AS Price_List_Description, 
							T.Distributor_Type_Name AS Distributor_Type_Name, 
							C.Distributor_Type_C_Desc AS Distributor_Type_C_Desc,
							B.Distributor_Type_B_Desc AS Distributor_Type_B_Desc,  
							FLB.Freight_Bracket_Label AS Freight_Bracket_Label,
							ISNULL(BSA.Address_1,'N/A') AS Address,
							ISNULL(BSA.City,'N/A') AS City,
							ISNULL(BSA.State,'N/A') AS State,
							-- BSA.Is_Redi_Customer 
							H.Distributor_Type_H_Desc AS Distributor_Type_H_Desc
		FROM 			BSA_Foodservice_Customers BSA
		LEFT JOIN 	Customer_Warehouse_Bracket CWB 
		ON	  			CWB.Distributor_Id = BSA.BSA_Foodservice_Customers_ID
		AND 			CWB.Deleted = 0
		LEFT JOIN 	Freight_Lookup_Bracket_Settings FLB 
		ON	  			FLB.Freight_Bracket_Setting_ID = CWB.Freight_Bracket_Setting_ID
		LEFT JOIN	Distributor_Type_c C 
		ON				C.Distributor_Type_C_ID = BSA.distributor_type_c_id
		AND 			C.Deleted = 0
		LEFT JOIN	Distributor_Type_b B 
		ON				B.Distributor_Type_B_ID = BSA.distributor_type_b_id
		AND 			B.Deleted = 0
		LEFT JOIN	Distributor_Type_H H 
		ON				H.Distributor_Type_H_ID = BSA.distributor_type_h_id
		AND 			H.Deleted = 0

		LEFT JOIN	Distributor_Type T 
		ON				T.Distributor_Type_ID = BSA.Distributor_Type_ID
		AND 			T.Deleted = 0
		LEFT JOIN	Freight_Lookup_Bracket_Settings FBS 
		ON				FBS.Freight_Bracket_Setting_ID = CWB.Freight_Bracket_Setting_ID
		LEFT JOIN	Price_List_Header PLH 
		ON				PLH.Price_List_Header_ID = BSA.Price_List_Header_ID
		AND			PLH.Deleted = 0
		WHERE		BSA.Deleted = 0
		<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		AND 	 	( 
							(BSA.Ship_To 									LIKE 	'%#url.sSearch#%') 
		OR 				(BSA.Name 									LIKE 	'%#url.sSearch#%') 
		OR 				(PLH.Price_List_Description 		LIKE 	'%#url.sSearch#%') 
		OR 				(T.Distributor_Type_Name 			LIKE 	'%#url.sSearch#%') 
		OR 				(C.Distributor_Type_C_Desc 		LIKE 	'%#url.sSearch#%')
		OR				(B.Distributor_Type_B_Desc 		LIKE 	'%#url.sSearch#%') 
		OR 				(FLB.Freight_Bracket_Label 		LIKE 	'%#url.sSearch#%')
		OR				(BSA.Address_1								LIKE 	'%#url.sSearch#%') 
		OR				(BSA.City 										LIKE 	'%#url.sSearch#%')
					)	
		</cfif>
		ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#             
</cfquery>

<cfset ItemsInfo = QueryNew("SHIP_TO, NAME, Address, City, State, Freight_Bracket_Label, Price_List_Description, Distributor_Type_Name, Distributor_Type_C_Desc,Distributor_Type_B_Desc,Distributor_Type_H_Desc","varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />

<cfloop query="Items">

		<cfset QueryAddRow(ItemsInfo) />
		<cfset Shiplink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Customers_ID#''' &');" style="color:3D3D3D">' & #Ship_To# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "SHIP_TO", "#Shiplink#") />
		<cfset Namelink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Customers_ID#''' &');" style="color:3D3D3D">' & #Name# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "NAME", "#Namelink#") />	
		<cfset QuerySetCell(ItemsInfo, "Address", "#Address#") />
		<cfset QuerySetCell(ItemsInfo, "City", "#City#") />	
		<cfset QuerySetCell(ItemsInfo, "State", "#State#") />		
		<cfset Bracketlink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Customers_ID#''' &');" style="color:3D3D3D">' & #Freight_Bracket_Label# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Freight_Bracket_Label", "#Bracketlink#") />
		<cfset Pricelink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Customers_ID#''' &');" style="color:3D3D3D">' & #Price_List_Description# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Price_List_Description", "#Pricelink#") />
		<cfset Disclink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Customers_ID#''' &');" style="color:3D3D3D">' & #Distributor_Type_Name# & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Distributor_Type_Name", "#Disclink#") />
		<cfset Clink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Customers_ID#''' &');" style="color:3D3D3D">' & Distributor_Type_C_Desc & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Distributor_Type_C_Desc", "#Clink#") />		
		<cfset Blink 	= '<a href="javascript:navigate('& '''#BSA_Foodservice_Customers_ID#''' &');" style="color:3D3D3D">' & Distributor_Type_B_Desc & '</a>' />
		<cfset QuerySetCell(ItemsInfo, "Distributor_Type_B_Desc", "#Blink#") />
		<cfset isRediCustomer = Distributor_Type_H_Desc />
		<cfset QuerySetCell(ItemsInfo, "Distributor_Type_H_Desc", "#isRediCustomer#" ) />		

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
 