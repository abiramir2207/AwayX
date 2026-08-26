<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	3/7/2012
 	Developer:	drachala
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		USED TO MAKE AJAX CALLS TO DB FOR CUSTOMER PLANNING GROUPS
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
			tmp.columnArray = ["Checkbox", "PG_Customer_Category_Code", "PG_Customer_Category_Name", "PG_Type_Name", "Include_In_Other", "Deactivate", "Copy", "Remove", "Expand", "MicroMembers"];
		</cfscript>
	<cfelse>
		<cfscript>
			tmp.columnArray = ["Checkbox", "PG_Customer_Category_Code", "PG_Customer_Category_Name", "PG_Type_Name", "Include_In_Other", "Activate", "Copy", "Remove", "Expand", "MicroMembers"];
		</cfscript>
</cfif>


<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
<cfquery name="qppg" datasource="#application.datasource#">
		SELECT '<input type="checkbox" name="chkPGCustomerCatID" value="'+cast(PGCC.PG_Customer_Category_ID as nvarchar(50))+'">' AS Checkbox,
					PGCC.PG_Customer_Category_ID,
					PGCC.PG_Type_ID,
					PGCC.PG_Customer_Category_Code,
					PGCC.PG_Customer_Category_Name,
					PGCC.Active,
					PGCC.Deleted,
					PGCC.Created_Date,
					PGCC.Updated_Date,
					PGCC.Created_By,
					PGCC.Updated_BY,
					PGCC.Include_In_Other_PG,
					BS.Business_Unit_Desc,
					BS.BUSINESS_SEGMENT_ID,
					PGT.PG_Type_Name,
					PGCC.Is_System
		FROM		PG_Customer_Category PGCC
		LEFT JOIN 	PG_Type PGT ON PGT.PG_Type_ID = PGCC.PG_Type_ID
		LEFT JOIN 	Business_Segment BS ON BS.BUSINESS_SEGMENT_ID = PGCC.Business_Segment_ID
		WHERE 		PGCC.Active = #url.active#
		AND   		PGCC.Deleted = 0
		<cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
		AND 		( (PGCC.PG_Customer_Category_Code like '%#url.sSearch#%') OR (PGCC.PG_Customer_Category_Name like '%#url.sSearch#%') OR (PGT.PG_Type_Name like '%#url.sSearch#%') )
		</cfif>
		ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
</cfquery>
<!--- CREATED NEW QUERY WITH ONLY SPECIFIED COLUMNS ABOVE --->
<cfif url.active>
	<cfset tmp.qppg = QueryNew("Checkbox, PG_Customer_Category_Code, PG_Customer_Category_Name, PG_Type_Name, Include_In_Other, Deactivate, Copy, Remove, Expand, MicroMembers","varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
<cfelse>
	<cfset tmp.qppg = QueryNew("Checkbox, PG_Customer_Category_Code, PG_Customer_Category_Name, PG_Type_Name, Include_In_Other, Activate, Copy, Remove, Expand, MicroMembers","varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar,varchar") />
</cfif>

<cfloop query="qppg">

	<cfset QueryAddRow(tmp.qppg) />
	<cfset QuerySetCell(tmp.qppg, "Checkbox", "#qppg.Checkbox#") />
	<!---AJV : D113634 Allow edit for system planning groups  --->
	<cfset PG_Link = '<a href="index.cfm?type=customer&subtype=edit&ID=#qppg.PG_Customer_Category_ID#&Is_System=#Is_System#">' />			 
	<cfset PG_Name 	=  PG_Link & #qppg.PG_Customer_Category_Name# & '</a>' />
	<cfif qppg.Is_System><cfset PG_Name = PG_Name & '*' /> </cfif>
	<cfset PG_Code 	= PG_Link & #qppg.PG_Customer_Category_Code# & '</a>'/>
	<cfif qppg.Is_System> <cfset PG_Code = PG_Code & '*'/> </cfif>

	<cfif qppg.Include_In_Other_PG>
		<cfset Include_In_Other = '<img src="/images/yes.png" style="margin-left:20px">'>
	<cfelse>
		<cfset Include_In_Other = '<img src="/images/no.png" style="margin-left:20px">'>
	</cfif>

	<cfif (Get_Profile_Settings.Planning_Groups_Create EQ 2)>
		<cfif url.active>
			<cfset DeActivate = '<img src="/images/cancel.png" style="margin-left:20px;text-align:center;" onclick="deactivate('& '''#qppg.PG_Customer_Category_ID#''' &');">' />
		<cfelse>
			<cfset Activate 	= '<img src="/images/activate.png" style="margin-left:20px" onclick="activate('& '''#qppg.PG_Customer_Category_ID#''' &');">' />
		</cfif>
	
		<cfset Copy	 	= '<img src="/images/copy_new.png" style="margin-left:20px" onclick="copy('& '''#qppg.PG_Customer_Category_ID#''' &', '& '''#qppg.Is_System#''' &');">' />
		<cfset Delete 	= '<img src="/images/trash.png" style="margin-left:20px" onclick="removed('& '''#qppg.PG_Customer_Category_ID#''' &');">' />
	<cfelse>
		<cfif url.active>
			<cfset DeActivate = 'N/A' />
		<cfelse>
			<cfset Activate 	= 'N/A' />
		</cfif>
		<cfset Copy	 	= 'N/A' />
		<cfset Delete 	= 'N/A' />
		
	</cfif>		
		<cfset Info	 	= '<img src="/images/info.png" style="margin-left:20px" onclick="info('& '''#qppg.PG_Customer_Category_ID#''' &');">'/>
		<cfset MicroMembers	 	= '<img src="/images/on_the_program_item.gif" style="margin-left:20px" onclick="fnViewMicroMembers(2,'& '''#qppg.PG_Customer_Category_ID#''' &', '''');">'/>

		<cfset QuerySetCell(tmp.qppg, "PG_Customer_Category_Code", "#PG_Code#") />
		<cfset QuerySetCell(tmp.qppg, "PG_Customer_Category_Name", "#PG_Name#") />
		<cfset QuerySetCell(tmp.qppg, "PG_Type_Name", "#qppg.PG_Type_Name#") />
		<cfset QuerySetCell(tmp.qppg, "Include_In_Other", "#Include_In_Other#") />

	<cfif url.active>
		<cfset QuerySetCell(tmp.qppg, "Deactivate", "#Deactivate#") />
	<cfelse>
		<cfset QuerySetCell(tmp.qppg, "activate", "#Activate#") />
	</cfif>

		<cfset QuerySetCell(tmp.qppg, "Copy", "#Copy#") />
		<cfset QuerySetCell(tmp.qppg, "Remove", "#Delete#") />
		<cfset QuerySetCell(tmp.qppg, "Expand", "#Info#") />
		<cfset QuerySetCell(tmp.qppg, "MicroMembers", "#MicroMembers#") />

</cfloop>




		<cfset reply.iTotalRecords        = #tmp.qppg.recordcount#>
		<cfset reply.iTotalDisplayRecords = #tmp.qppg.recordcount#>


		<cfset start = url.iDisplaystart>
		<cfset end 	= url.iDisplaystart + url.iDisplayLength>
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
