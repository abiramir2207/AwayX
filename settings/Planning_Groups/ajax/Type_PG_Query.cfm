<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala        
	Copyright (c) 2012 Blacksmith Applications, Inc.       
             
	Description:
		USED TO MAKE AJAX CALLS TO DB FOR TYPE PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>PLANNING GROUPS.
---->
<cfsetting showDebugOutput="no">

<cfinclude template="/get_access_profile.cfm">
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
<cfif url.active>
	   <cfscript>
            tmp.columnArray = ["Checkbox", "PG_Type_Code", "PG_Type_Name", "PG_Group_Type", "Deactivate", "Remove", "Expand"];    
	   </cfscript>
<cfelse>
      <cfscript>
            tmp.columnArray = ["Checkbox", "PG_Type_Code", "PG_Type_Name", "PG_Group_Type", "Activate", "Remove", "Expand"];
	  </cfscript>   
</cfif>
   

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
    SELECT	DISTINCT
		'<input type="checkbox" name="ChkPGTypeID" value="'+cast(PGT.PG_Type_ID as nvarchar(50))+'">' AS Checkbox,
        PGT.PG_Type_ID,
		PGT.PG_Type_Code,
        PGT.PG_Type_Name,
        PGT.PG_Group_Type, 
		PGT.Is_System  
        FROM	PG_Type PGT
        LEFT JOIN PG_Product_Category PGPC 
        ON		PGPC.Pg_Type_ID = PGT.PG_Type_ID 
        AND		PGPC.Active = 1 
        AND		PGPC.Deleted = 0
        LEFT JOIN PG_Customer_Category PGCC 
        ON		PGCC.Pg_Type_ID = PGT.PG_Type_ID 
        AND		PGCC.Active = 1 
        AND		PGCC.Deleted = 0
        LEFT JOIN PG_Operator_Category PGOC 
        ON		PGOC.PG_Type_ID = PGT.PG_Type_ID 
        AND		PGOC.Active = 1 
        AND		PGOC.Deleted = 0
        WHERE	PGT.Active = #url.active# 
        AND		PGT.Deleted = 0
    <cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		AND ( (PGT.PG_Type_ID like '%#url.sSearch#%') OR (PGT.PG_Type_Name like '%#url.sSearch#%') )	
	</cfif>
        ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfquery>
<!--- PGT.PG_Type_Name CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
<cfif url.active>
   <cfset tmp.qppg = QueryNew("Checkbox, PG_Type_Code, PG_Type_Name, PG_Group_Type, Deactivate, Remove, Expand", "varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
<cfelse>
   <cfset tmp.qppg = QueryNew("Checkbox, PG_Type_Code, PG_Type_Name, PG_Group_Type, Activate, Remove, Expand", "varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
</cfif>
   <cfloop query="qppg">
      <cfset QueryAddRow(tmp.qppg) />
	  <cfset QuerySetCell(tmp.qppg, "Checkbox", "#qppg.Checkbox#") />
	  <cfif Is_System>
	  	<cfset PG_Code 	= #qppg.PG_Type_Code# & '*' />
	  	<cfset PG_Name 	= #qppg.PG_Type_Name# />
		  	  <cfelse>
	  	<cfset PG_Code 	= '<a href="index.cfm?type=type&subtype=edit&ID=#qppg.PG_Type_ID#">' & #qppg.PG_Type_Code# & '</a>' />
	  	<cfset PG_Name 	= '<a href="index.cfm?type=type&subtype=edit&ID=#qppg.PG_Type_ID#">' & #qppg.PG_Type_Name# & '</a>' />
	  </cfif>
	  <cfif PG_Group_Type EQ "1">
        <cfset PGTypeCategory = application.returned_customer_setting.Item_Label />
      <cfelseif PG_Group_Type EQ "2">
        <cfset PGTypeCategory = application.returned_customer_setting.distributor_label_singular />
      <cfelseif PG_Group_Type EQ "3">
        <cfset PGTypeCategory = application.returned_customer_setting.Operator_Label_Singular  />
      </cfif>
	  <cfif (Get_Profile_Settings.Planning_Groups_Create EQ 2)>
		  <cfif url.active>
			  <cfset DeActivate = '<img src="/images/cancel.png" style="margin-left:20px" onclick="deactivate('& '''#qppg.PG_Type_ID#''' &' , '& '''#PG_Group_Type#'''&' , '& '''#url.active#''' &');">' />
		  <cfelse>
			  <cfset Activate 	= '<img src="/images/activate.png" style="margin-left:20px" onclick="activate('& '''#qppg.PG_Type_ID#''' &' , '& '''#url.active#''' &');">' />
		  </cfif>
		  <cfset Delete 	= '<img src="/images/trash.png" style="margin-left:20px" onclick="removed('& '''#qppg.PG_Type_ID#''' &' , '& '''#url.active#''' &');">' />
	  <cfelse>
		  <cfif url.active>
			  <cfset DeActivate = 'N/A' />
		  <cfelse>
		  	<cfset Activate 	= 'N/A' />
		  </cfif>
		  <cfset Delete 	= 'N/A' />
	  </cfif>
	  <cfset Info	 	= '<img src="/images/info.png" style="margin-left:20px" onclick="info('& '''#qppg.PG_Type_ID#''' &' , '& '''#PG_Group_Type#'''&' , '& '''#url.active#''' &');">'/>

      <cfset QuerySetCell(tmp.qppg, "PG_Type_Code", "#PG_Code#") />
      <cfset QuerySetCell(tmp.qppg, "PG_Type_Name", "#PG_Name#") />
      <cfset QuerySetCell(tmp.qppg, "PG_Group_Type", "#PGTypeCategory#") />
	  <cfif url.active>
      <cfset QuerySetCell(tmp.qppg, "Deactivate", "#Deactivate#") />
	  <cfelse>
      <cfset QuerySetCell(tmp.qppg, "Activate", "#Activate#") />
	  </cfif>
      <cfset QuerySetCell(tmp.qppg, "Remove", "#Delete#") />
      <cfset QuerySetCell(tmp.qppg, "Expand", "#Info#") />

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
 