<cfparam name="URL.Billback_ID_Int" default = "0">
<cfparam name="URL.BillbackList" default = "0">
<cfparam name="URL.Page_Relocate" default="">
<cfparam name="URL.UserID" default="0">
<cfparam name="URL.ShowDocs" default="0">
<cfparam name="URL.FlexAppName" default="">


<!--- This is used to get billback_id of a single billback only --->
<cfif URL.Billback_ID_Int neq 0>
  <cfset useLakebaseForGetBillback_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
  <cfif useLakebaseForGetBillback_ID>
    <cftry>
      <cfset getBillback_ID = application.oLakebase.toQuery(
        application.oLakebase.selectRows("billback", { "billback_id_int" = "eq.#URL.Billback_ID_Int#", "select" = "billback_id" })
      )>
      <cfcatch type="any">
        <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
        <cfset useLakebaseForGetBillback_ID = false>
      </cfcatch>
    </cftry>
  </cfif>
  <cfif NOT useLakebaseForGetBillback_ID>
    <CFQUERY NAME="getBillback_ID" DATASOURCE="#Application.Datasource#">
     SELECT Billback_ID
     FROM Billback
     WHERE Billback_ID_Int = '#URL.Billback_ID_Int#'
    </CFQUERY>
  </cfif>
</cfif>

<!--- This is used to get billback_ID of multiple billbacks --->
<cfif URL.BillbackList neq 0>
  <cfset useLakebaseForGetBillbackList_ID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
  <cfif useLakebaseForGetBillbackList_ID>
    <cftry>
      <cfset getBillbackList_ID = application.oLakebase.toQuery(
        application.oLakebase.selectRows("billback", { "billback_id_int" = "in.(#URL.BillbackList#)", "select" = "billback_id" })
      )>
      <cfcatch type="any">
        <!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
        <cfset useLakebaseForGetBillbackList_ID = false>
      </cfcatch>
    </cftry>
  </cfif>
  <cfif NOT useLakebaseForGetBillbackList_ID>
    <CFQUERY NAME="getBillbackList_ID" DATASOURCE="#Application.Datasource#">
     SELECT Billback_ID
     FROM Billback
     WHERE Billback_ID_Int IN (#URL.BillbackList#)
    </CFQUERY>
  </cfif>
</cfif>

<cfif URL.UserID eq 0 AND URL.ShowDocs eq 0>
	<cfif URL.BillbackList eq 0>
		<!--- This one will be used most of the time. --->
		<cflocation url="#Page_Relocate#?BBID=#getBillback_ID.Billback_ID#&FlexAppName=#URL.FlexAppName#&FromFlex=1">
	<cfelse>
		<!--- This is used to pass multiple billbackID's to a specific file. Since the page to be relocated expects BBID variable, the first ID (ListFirst) 
		      from a list of ID's is used to get BBID. Having "BBID" is the relocated file should do nothing, if the code is appropriately modified in that file
		      based on "BillbackList" being passed from here.
		--->
		<cflocation url="#Page_Relocate#?BBID=#ListFirst(getBillbackList_ID.Billback_ID)#&BillbackList=#ValueList(getBillbackList_ID.Billback_ID)#&FlexAppName=#URL.FlexAppName#&FromFlex=1">
	</cfif>
<cfelse>
	<cfif URL.ShowDocs eq 0>
		<!--- Here we are passing "User_ID" too. --->
		<cflocation url="#Page_Relocate#?BBID=#getBillback_ID.Billback_ID#&UserID=#URL.UserID#&FromFlex=1">
	<cfelse>
		<!--- This is used to show a list of documents attached to a billback.The url to open a document cannot have any extra url parameters except the exact ones for the document. 
		      It is as it is what is passed in the URL. 
		--->
		<cflocation url="#Page_Relocate#" addtoken="no">
	</cfif>
</cfif>