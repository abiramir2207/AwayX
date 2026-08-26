<!---
	Copyright (c)2016 Blacksmith Applications, Inc.       
	Filename:		Common_Files\contracts\ajax\select_vendors_ajax.cm
					Copied and modified code from "\GL_Code\Vendor_Management\ajax\Vendor_Master_search_ajax.cfm"
	Created:		7/31/2018
	Developer:		Milan Mushran
	Description:	get vendors on the program
--->
<cfsetting showDebugOutput="no">

<cfprocessingdirective suppresswhitespace="yes">
 <cfsilent>
  
<cfparam name="form.iDisplayStart"   	default="0">
<cfparam name="form.iDisplayLength"		default="100">
<cfparam name="form.sEcho"           	default="10">
<cfparam name="form.iSortCol_0"			default="1">
<cfparam name="form.sSortDir_0"			default="ASC">
<cfparam name="form.SelectedVendorList"	default="">
<cfparam name="form.Show_All_Records"	default="0">

<cfscript>
  reply = structnew();
</cfscript>  

<!--- Note: "form.SelectedVendorList" has the list of vendors on the program --->
<CFQUERY NAME="GetVMVendorIDInfo" DATASOURCE="#Application.Datasource#">
	SELECT 		RTRIM(Vendor_ID) as Vendor_ID
				,Vendor_Name as vendorName
				,Vendor_Master.Address_1 + 
					+ CASE WHEN LEN(Vendor_Master.Address_2) > 0 THEN ', ' + Vendor_Master.Address_2  ELSE '' END
					+ ISNULL(', '+Vendor_Master.City,'n/a')  
					+ ISNULL(', '+Vendor_Master.state,'n/a')  
					+ ISNULL(', '+Vendor_Master.zipcode,'n/a') AS Address
				,Vendor_Master.Vendor_Master_ID
	FROM		Vendor_Master
	INNER JOIN  BSA_Foodservice_Customers
	ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Vendor_Master.Vendor_Master_ID
	WHERE BSA_Foodservice_Customers.Is_Vendor = 1
	<CFIF form.Vendor_ID NEQ "">
			AND Vendor_ID LIKE '%#form.Vendor_ID#%' 
			</CFIF>
			<CFIF form.Vendor_Name NEQ "">
			AND	Vendor_Name LIKE '%#form.Vendor_Name#%'
			</CFIF>
			<CFIF form.Vendor_City NEQ "">
			AND	Vendor_Master.City = '#form.Vendor_City#'
			</CFIF>
			<CFIF form.State NEQ "">
			AND	Vendor_Master.State = '#form.State#'
			</CFIF>
			<CFIF form.Vendor_country NEQ "" AND form.Vendor_country NEQ 'N'>
			AND	Vendor_Master.country_code Like '#form.Vendor_country#%'
			</CFIF>
			<CFIF form.Vendor_country NEQ "" AND form.Vendor_country EQ 'N'>
			AND	Vendor_Master.country_code IS NULL
			</CFIF>
	<!--- Show existing program records --->
	<CFIF form.Show_All_Records eq 0>
	<cfif len(form.SelectedVendorList) GT 0>
	AND Vendor_Master.Vendor_Master_ID IN (#ListQualify(form.SelectedVendorList, "'" , ",", "ALL")#)
	</cfif>
	<cfelse>
	<!---  Show "valid records" OR the ones which already exist on the program --->
	AND
	(
	(Vendor_Master.Deleted = 0 AND Vendor_Master.Active_Code = 'A')
	<cfif len(form.SelectedVendorList) GT 0>
	OR
	(Vendor_Master.Vendor_Master_ID IN (#ListQualify(form.SelectedVendorList, "'" , ",", "ALL")#))
	</cfif>
	)
	</cfif>
	ORDER BY #form.iSortCol_0# #form.sSortDir_0#
</CFQUERY>

<cfset reply.iTotalDisplayRecords    = #GetVMVendorIDInfo.recordcount#>
<cfset reply.iTotalRecords = #GetVMVendorIDInfo.recordcount#>

<cfset start	= form.iDisplaystart + 1>
<cfset end	= form.iDisplaystart + 100>

<cfset variables.reply.aaData = [] >
<!--- Generate JSON from Query --->
<cfset tmp.dArray = ArrayNew(1) >
<cfloop query="GetVMVendorIDInfo" startrow="#start#" endrow="#end#">	 
	 <cfscript>
	   dArrayTmp = [];
		if(ListFindNoCase(form.SelectedVendorList,Vendor_Master_ID) != 0){
		arrayAppend(dArrayTmp,'<input type="checkbox" name="VendorMasterID" checked class="vendorCheckbox" onClick="addRemoveVendors()" value="#Vendor_Master_ID#">');
		}
		else{
		arrayAppend(dArrayTmp,'<input type="checkbox" name="VendorMasterID" class="vendorCheckbox" onClick="addRemoveVendors()" value="#Vendor_Master_ID#">');
		}

	   arrayAppend(dArrayTmp, GetVMVendorIDInfo.Vendor_ID);
	   arrayAppend(dArrayTmp, GetVMVendorIDInfo.vendorName);
	   arrayAppend(dArrayTmp, GetVMVendorIDInfo.Address); 
	   arrayAppend(variables.reply.aaData, dArrayTmp);
	</cfscript>
	<cfset ArrayAppend(tmp.dArray, dArrayTmp) >	
	
</cfloop>

<cfset reply.aaData = tmp.dArray>
<cfset reply.sEcho  = javacast('int', form.sEcho)>
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