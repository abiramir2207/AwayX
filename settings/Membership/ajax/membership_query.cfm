<!----
	Name: <file name>         
	Copyright (c) 2013 Blacksmith Applications, Inc.       
             
	Description:
		<brief description of what the file is used for>
	Usage:
		<templates that depend on this file>
	Tip:
		<gotchas>
---->
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">

<cfsilent>
 
	<cfparam name="url.iDisplayStart"   default="0">
	<cfparam name="url.iDisplayLength"  default="20">
	<cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"		default="2">
	<cfparam name="url.sSortDir_0"		default="ASC">
	<cfscript>
		tmp   = structnew();
		reply = structnew();
		tmp.page_size   = val(url.iDisplayLength);
		tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
	</cfscript>

<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. USING URL VARIABLE ACTIVE TO DETERMINE WHICH SECTION USER LOOKING--->  
		<cfscript>
			tmp.columnArray = ["Group_Number", "Group_Desc", "Shr_Ship_To", "Name", "Start_Date", "End_Date"];
		</cfscript>   
<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
		SELECT 	cgm.Customer_Group_Type,
		            	f.Group_GUID, 
		            	f.Group_Number, 
		            	f.Group_Desc,
		            	c.BSA_Foodservice_Customers_ID, 
		            	c.Shr_Ship_To, 
		            	c.Name,
		            	cgm.Start_Date, 
		            	cgm.End_Date
		FROM  	Customer_Group_Members cgm
		INNER JOIN All_Customer_Group_Types f
		ON          f.Group_GUID = cgm.Customer_Group_ID
		INNER JOIN BSA_Foodservice_Customers c
		ON          c.BSA_Foodservice_Customers_ID = cgm.BSA_Foodservice_Customers_ID
		WHERE cgm.Deleted = 0
		AND         cgm.Customer_Group_Type = #url.grouptype#
		<cfif len(trim(url.groupid))>
		AND f.Group_GUID = '#trim(url.groupid)#'
		</cfif>
		<cfif len(trim(url.shiptoid))>
		AND c.BSA_Foodservice_Customers_ID = '#trim(url.shiptoid)#'
		</cfif>
		ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#          
</cfquery>
<!--- CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->

	<cfset tmp.qppg = QueryNew("Group_Number, Group_Desc, Shr_Ship_To, Name, Start_Date, End_Date","varchar,varchar,varchar,varchar,varchar,varchar") />
<cfloop query="qppg">

		<cfset QueryAddRow(tmp.qppg) />
		
		<cfset GroupNumber  		= '<a href="javascript:navigate('& '''#qppg.Group_GUID#''' &','& '''#qppg.BSA_Foodservice_Customers_ID#''' &','& '''#url.grouptype#''' &','& '''#qppg.Start_Date#''' &');" style="color:3D3D3D">' & #qppg.Group_Number# & '</a>' />
		<cfset Groupdesc 	 			= '<a href="javascript:navigate('& '''#qppg.Group_GUID#''' &','& '''#qppg.BSA_Foodservice_Customers_ID#''' &','& '''#url.grouptype#''' &','& '''#qppg.Start_Date#''' &');" style="color:3D3D3D">' & #qppg.Group_Desc# & '</a>' />
		<cfset ShrShipTo  					= '<a href="javascript:navigate('& '''#qppg.Group_GUID#''' &','& '''#qppg.BSA_Foodservice_Customers_ID#''' &','& '''#url.grouptype#''' &','& '''#qppg.Start_Date#''' &');" style="color:3D3D3D">' & #qppg.Shr_Ship_To# & '</a>' />
		<cfset ShrShipToName  		= '<a href="javascript:navigate('& '''#qppg.Group_GUID#''' &','& '''#qppg.BSA_Foodservice_Customers_ID#''' &','& '''#url.grouptype#''' &','& '''#qppg.Start_Date#''' &');" style="color:3D3D3D">' & #qppg.Name# & '</a>' />
		<cfset StartDate  					= '<a href="javascript:navigate('& '''#qppg.Group_GUID#''' &','& '''#qppg.BSA_Foodservice_Customers_ID#''' &','& '''#url.grouptype#''' &','& '''#qppg.Start_Date#''' &');" style="color:3D3D3D">' & #qppg.Start_Date# & '</a>' />
		<cfset EndDate  					= '<a href="javascript:navigate('& '''#qppg.Group_GUID#''' &','& '''#qppg.BSA_Foodservice_Customers_ID#''' &','& '''#url.grouptype#''' &','& '''#qppg.Start_Date#''' &');" style="color:3D3D3D">' & #qppg.End_Date# & '</a>' />
	
				
		<cfset QuerySetCell(tmp.qppg, "Group_Number", "#GroupNumber#") />
		<cfset QuerySetCell(tmp.qppg, "Group_Desc", "#GroupDesc#") />
		<cfset QuerySetCell(tmp.qppg, "Shr_Ship_To", "#ShrShipTo#") />
		<cfset QuerySetCell(tmp.qppg, "Name", "#ShrShipToName#") />
		<cfset QuerySetCell(tmp.qppg, "Start_Date", "#StartDate#") />
		<cfset QuerySetCell(tmp.qppg, "End_Date", "#EndDate#") />

</cfloop>

		<cfset reply.iTotalRecords        = #tmp.qppg.recordcount#>
		<cfset reply.iTotalDisplayRecords = #tmp.qppg.recordcount#>

		<cfset start = url.iDisplaystart>
		<cfset end 	= url.iDisplaystart + 20>
		<cfif start EQ 0>
			<cfset start = 1>
		</cfif>

<!--- Generate JSON from Query --->
		<cfset tmp.dArray = ArrayNew(1) >
<cfloop query="tmp.qppg" startrow="#start#" endrow="#end#">
		<cfset dArrayTmp = arraynew(1)>
<cfloop array="#tmp.columnArray#" index="tmp.columnName">
		<cfset ArrayAppend(dArrayTmp, (tmp.qppg[tmp.columnName][tmp.qppg.currentRow]))>
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
 