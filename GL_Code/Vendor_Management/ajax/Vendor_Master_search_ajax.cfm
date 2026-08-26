<!---
	Copyright (c)2016 Blacksmith Applications, Inc.       
	Filename:		C:\Work\base\AwayX\GL_Code\Vendor_Management\ajax\Vendor_Master_search_ajax.cfm
	Created:		2/29/2016
	Developer:		drachala
	Description:	<brief description of what the file is used for>
	Usage:			<templates that depend on this file>
	Tip:			<gotchas>
--->
 
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">

  <cfsilent>
  	  
    <cfparam name="url.iDisplayStart"   	default="0">
    <cfparam name="url.iDisplayLength"  default="100">
    <cfparam name="url.sEcho"           		default="10">
	<cfparam name="url.iSortCol_0"			default="1">
	<cfparam name="url.sSortDir_0"			default="ASC">
	
	<cfset url.iSortCol_0 = url.iSortCol_0 + 1>
	
  <cfscript>
      tmp   = structnew();
      reply = structnew();
      tmp.page_size   = val(url.iDisplayLength);
      tmp.page_number = int(val(url.iDisplayStart) / tmp.page_size) + 1;
  </cfscript>  

<!--- BELOW IS THE QUERY WILL PULLS RECORDS --->

<CFQUERY NAME="GetVMVendorIDInfo" DATASOURCE="#Application.Datasource#">
	SELECT 		'<input type="checkbox" name="VendorMasterID" value="'+cast(Vendor_Master_ID as nvarchar(50))+'">' AS Checkbox
					,RTRIM(Vendor_ID) as Vendor_ID
					,Vendor_Name as vendorName
					,Vendor_Master.Address_1 + 
						+ CASE WHEN LEN(Vendor_Master.Address_2) > 0 THEN ', ' + Vendor_Master.Address_2  ELSE '' END
						+ ISNULL(', '+Vendor_Master.City,'n/a')  
						+ ISNULL(', '+Vendor_Master.state,'n/a')  
						+ ISNULL(', '+Vendor_Master.zipcode,'n/a') AS Address
					,Vendor_Master_ID
	FROM 		Vendor_Master
	WHERE  <CFIF URL.Vendor_ID NEQ "">
					Vendor_ID LIKE '%#URL.Vendor_ID#%' AND
				</CFIF>
				<CFIF URL.Vendor_Name NEQ "">
					Vendor_Name LIKE '%#URL.Vendor_Name#%' AND
				</CFIF>
				<CFIF URL.Vendor_City NEQ "">
					Vendor_Master.City = '#URL.Vendor_City#' AND
				</CFIF>
				<CFIF URL.State NEQ "">
					Vendor_Master.State = '#URL.State#' AND
				</CFIF>
				<CFIF URL.Vendor_country NEQ 0 AND URL.Vendor_country NEQ 'N'>
					Vendor_Master.country_code Like '#URL.Vendor_country#%' AND
				</CFIF>
				<CFIF URL.Vendor_country NEQ 0 AND URL.Vendor_country EQ 'N'>
					Vendor_Master.country_code IS NULL AND
				</CFIF>				
				<cfif URL.Vendor_Active EQ "1">
					Vendor_Master.Deleted = 0
					AND Vendor_Master.Active_Code = 'A'
				<cfelseif URL.Vendor_Active EQ "0">
					Vendor_Master.Deleted = 1
					AND Vendor_Master.Active_Code = 'N'
				</cfif>
	ORDER BY #url.iSortCol_0# #url.sSortDir_0#
</CFQUERY>

    <cfset reply.iTotalDisplayRecords    = #GetVMVendorIDInfo.recordcount#>
    <cfset reply.iTotalRecords = #GetVMVendorIDInfo.recordcount#>
	
	<cfset start	= url.iDisplaystart>
	<cfset end	= url.iDisplaystart + 100>
	<cfif start EQ 0>
		<cfset start = 1>
	</cfif>
	
	<cfset variables.reply.aaData = [] >
    <!--- Generate JSON from Query --->
    <cfset tmp.dArray = ArrayNew(1) >
    <cfloop query="GetVMVendorIDInfo" startrow="#start#" endrow="#end#">	 
		<cfset links = ''>
		<cfif URL.Vendor_Active>
	 	  	<cfset links = '<a onclick="editbank('& '''#GetVMVendorIDInfo.Vendor_Master_ID#''' &');" style="cursor:pointer;">#application.util.string.actionLinkFormat("Edit Bank Info")#</a>'>
			   <cfif editfield>
					<cfset links = links&'&nbsp;<a onclick="editvendor('& '''#GetVMVendorIDInfo.Vendor_Master_ID#''' &');" style="cursor:pointer;">#application.util.string.actionLinkFormat("Edit Vendor")#</a>'>
			   </cfif>
		</cfif>
		 <cfscript>
	       dArrayTmp = [];
	       arrayAppend(dArrayTmp, GetVMVendorIDInfo.Checkbox);
	       arrayAppend(dArrayTmp, GetVMVendorIDInfo.Vendor_ID);
	       arrayAppend(dArrayTmp, GetVMVendorIDInfo.vendorName);
	       arrayAppend(dArrayTmp, GetVMVendorIDInfo.Address); 
	       if (URL.Vendor_Active EQ 1)
	       {
	       	arrayAppend(dArrayTmp, links);
	       } 
	       arrayAppend(variables.reply.aaData, dArrayTmp);
	    </cfscript>
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