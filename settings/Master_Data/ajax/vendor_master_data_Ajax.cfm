<!----
	Filename:	C:\Work\Code\base\AwayX\settings\Planning_Groups\ajax\Customer_PG_Query.cfm
	Created:	20-Feb-2017
 	Developer:	Anand Rao
	Copyright (c) 2012 Blacksmith Applications, Inc.

	Description:
		USED TO MAKE AJAX CALLS TO DB FOR TYPE PLANNING GROUPS
	Usage:
		SETTING>>ADMINISTRATOR>>Master Data
---->
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">

  <cfsilent>

    <cfparam name="url.iDisplayStart"   default="0">
    <cfparam name="url.iDisplayLength"  default="500">
    <cfparam name="url.sEcho"           default="10">
	<cfparam name="url.iSortCol_0"		default="0">
	<cfparam name="url.sSortDir_0"		default="ASC">
  <cfscript>
      tmp   = structnew();
      reply = structnew();
      tmp.page_size   = val(url.iDisplayLength);
      tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>
<cfset businessSegManager = CreateObject("component", "components.programs.business_segment.BusinessSegmentManager") />


	<!--- COLUMNS LIST WHICH SHOULD MATCH TO INFO PULLING FROM BELOW QUERY. USING URL VARIABLE ACTIVE TO DETERMINE WHICH SECTION USER LOOKING--->
	<cfif businessSegManager.isEnabledForVendorType()>
	   <cfscript>
            tmp.columnArray = ["Vendor_ID", "VendorName", "Address", "#appSettings.getbusiness_segment_label()#", "Active", "Deleted"];
	   </cfscript>
	 <cfelse>
	   <cfscript>
            tmp.columnArray = ["Vendor_ID", "VendorName", "Address", "Active", "Deleted"];
	   </cfscript>
	</cfif>
<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->
	<cfquery name="qVM" datasource="#application.datasource#">
		SELECT RTRIM(VM.Vendor_ID) as Vendor_ID
					,VM.Vendor_Name as VendorName
					,VM.Address_1 + 
						+ CASE WHEN LEN(VM.Address_2) > 0 THEN ', ' + VM.Address_2  ELSE '' END
						+ ISNULL(',<br>'+VM.City,'n/a')  
						+ ISNULL(', '+VM.state,'n/a')  
						+ ISNULL(', '+VM.zipcode,'n/a') AS Address
					<cfif businessSegManager.isEnabledForVendorType()>
						 	,BS.Business_Unit_Desc AS #appSettings.getbusiness_segment_label()#
					</cfif>
					,CASE WHEN VM.Active_Code = 'A' THEN ' Yes ' ELSE ' No ' END as Active
					,CASE WHEN VM.Deleted = 0 THEN ' No ' ELSE ' Yes ' END as Deleted
		FROM 		Vendor_Master VM
		<cfif businessSegManager.isEnabledForVendorType()>
			LEFT JOIN Business_Segment BS
			ON BS.Business_Segment_ID = VM.Business_Segment_ID
		</cfif>
		WHERE (VM.Deleted = 0 OR VM.Deleted = 1)
	 <cfif StructKeyExists(url, "sSearch") and len(trim(url.sSearch))>
	AND (
 				(VM.Vendor_ID LIKE '%#url.sSearch#%')
		  OR (VM.Vendor_Name LIKE '%#url.sSearch#%')
		  OR (VM.City = '%#url.sSearch#%')
		  OR (VM.State = '%#url.sSearch#%')
	)
	</cfif>
		 ORDER BY #tmp.columnArray[url.iSortCol_0 + 1]# #url.sSortDir_0#
	</cfquery>

    <cfset reply.iTotalRecords        = #qVM.recordcount#>
    <cfset reply.iTotalDisplayRecords = #qVM.recordcount#>
	<cfset start = url.iDisplaystart>
	<cfset end 	= url.iDisplaystart + 500>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>

    <!--- Generate JSON from Query --->
    <cfset tmp.dArray = ArrayNew(1) >
    <cfloop query="qVM" startrow="#start#" endrow="#end#">
      <cfset dArrayTmp = arraynew(1)>
      <cfloop array="#tmp.columnArray#" index="tmp.columnName">
        <cfset ArrayAppend(dArrayTmp, (qVM[tmp.columnName][qVM.currentRow]))>
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
