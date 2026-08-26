<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\contracts\contacts.cfm
      Date:     May 23, 2011
      Author:   Chris Nguyen
      Purpose:  Display content on Contacts (LH panel option) page
----------------------------------------------------------------------------------------------------------------------->
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<html>
<head>
<title>Contacts</title>
<link rel="stylesheet" type="text/css" href="/common_files/main_style.css">
<link rel="stylesheet" type="text/css" href="/common_files/dataTable.css">
<cfinclude template="/common_files/jQuery.cfm">
<style>
.label {
  font-size: 9pt;
  font-weight: bold;
  color: navy;
}
.label2 {
  font-size: 8pt;
  font-weight: bold;
}
</style>
</head>
<body>
<CF_MessageWindow>

<!--- Combine gets and posts into the request scope --->
<cfif isDefined("URL")>
  <cfset structAppend(request, URL, true)/>
</cfif>
<cfif isDefined("FORM")>
  <cfset structAppend(request, form, true)/>
</cfif>

<cfscript>
  main = StructNew();
  main.messageMaxLen = 250;
  request.debug = false;
</cfscript>

<!---post back logic starts here--->
<cfif cgi.request_method eq "post" and StructKeyExists(request, "internals")>
  <cfoutput>
  <cfset main.distributors = "">
  <cfset main.operators    = "">

  <cfloop collection="#form#" item="formItem">
    <!--ignore empty form items-->
    <cfif Len(form[formItem])>
      <!--combine all distributor checkboxes-->
      <cfif FindNocase("distributors", formItem) eq 1>
        <cfset main.distributors = main.distributors & form[formItem] & ",">
      </cfif>

      <!--combine all operator checkboxes-->
      <cfif FindNocase("operators", formItem) eq 1>
        <cfset main.operators = main.operators & form[formItem] & ",">
      </cfif>
    </cfif>
  </cfloop>

  <cfquery name="Contacts" datasource = "#application.datasource#">
  	UPDATE Contract_Main_Aux_Data
  	  SET  Approval_Letter_Distributor_Emails = <cfqueryparam cfsqltype="cf_sql_varchar" value="#main.distributors#">
  	       , Approval_Letter_Operator_Emails  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#main.operators#">
           , Approval_Letter_Internal_Emails  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.internals#">
           , Approval_Letter_Email_Message    = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.emailMessage#">
    WHERE Contract_Main_ID  = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
  </cfquery>

  <!--done with saving data in the db, bail out-->
  <script>
    self.close();
  </script>
  </cfoutput>
</cfif>

<!---retrieve existing contacts--->
<cfquery name="contacts" datasource="#application.datasource#">
	SELECT	  CM.Contract_Number
	          , CM.Contract_Title
	          , CMAD.Approval_Letter_Distributor_Emails
	          , CMAD.Approval_Letter_Operator_Emails
	          , CMAD.Approval_Letter_Internal_Emails
	          , CMAD.Approval_Letter_Email_Message
  	FROM		Contract_Main_Aux_Data CMAD, Contract_Main CM
	 WHERE		CMAD.Contract_Main_ID	=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
	          AND CM.Contract_Main_ID	=	<cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
</cfquery>
<!---if no record is returned (this should not happen) bail out--->
<cfif contacts.recordCount eq 0>
  <cfabort>
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>
<cfset appSettings = genSettingsManager.get()>

<!---find distributor emails--->
<cfquery name="rsDistributors" datasource="#application.datasource#">
  SELECT DISTINCT ec.Company_Code
                  , cd.bsa_FoodService_Customers_Id
                  , ec.eMail
                  , ec.Last_Name
                  , ec.First_Name
                  , ec.Title
    FROM Contract_Main cm
         INNER JOIN Contract_Distributors cd ON cm.Contract_Main_Id = cd.Contract_Main_Id
                                                AND cd.Deleted = 0
         INNER JOIN bsa_FoodService_Customers bfc ON bfc.bsa_FoodService_Customers_Id = cd.bsa_FoodService_Customers_Id
         INNER JOIN External_Contacts ec ON ec.Company_Code = bfc.Ship_To
                                            AND ec.Deleted = 0
                                            AND ec.eMail > ''
   WHERE cm.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
         <!---28345 do not select any rows when ext contact setting is not enabled--->
         <cfif appSettings.External_Contacts_Option eq 0> AND 0 = 1 </cfif>
   ORDER BY ec.First_Name, ec.Last_Name
</cfquery>

<!---find operator emails--->
<cfquery name="rsOperators" datasource="#application.datasource#">
  SELECT DISTINCT ec.Company_Code
                  , co.bsa_Operator_Id
                  , ec.eMail
                  , ec.Last_Name
                  , ec.First_Name
                  , ec.Title
    FROM Contract_Main cm
         INNER JOIN Contract_Operators co ON cm.Contract_Main_Id = co.Contract_Main_Id
                                             AND co.Deleted = 0
         INNER JOIN bsa_Operator bo ON bo.bsa_Operator_Id = co.bsa_Operator_Id
         INNER JOIN External_Contacts ec ON ec.Company_Code = COALESCE( Cast( bo.Legacy_Id AS VARCHAR( 50 )), Cast( bo.bsa_Operator_Id AS VARCHAR( 50 )) )
                                            AND ec.Deleted = 0
                                            AND ec.eMail > ''
   WHERE cm.Contract_Main_Id = <cfqueryparam cfsqltype="cf_sql_varchar" value="#request.contractID#">
         <!---28345 do not select any rows when ext contact setting is not enabled--->
         <cfif appSettings.External_Contacts_Option eq 0> AND 0 = 1 </cfif>
   ORDER BY ec.First_Name, ec.Last_Name
</cfquery>

<cfscript>
  main.internals    = contacts.Approval_Letter_Internal_Emails;
  main.distributors = contacts.Approval_Letter_Distributor_Emails;
  main.operators    = contacts.Approval_Letter_Operator_Emails;
  main.emailMessage = contacts.Approval_Letter_Email_Message;
</cfscript>

<cfoutput>
<SPAN CLASS="title2">Program Letter Contacts:</SPAN>
<hr align=left color=blue size=1>
<table border=0 cellspacing=0 cellpadding=0 width=100%>
  <tr bgColor=##ffce84>
    <td noWrap align=left><FONT size=2>&nbsp;Program Number: <B>#contacts.Contract_Number#</B></FONT></td>
    <td noWrap align=right><FONT size=2>Description: <B>#contacts.Contract_Title#</B></FONT>&nbsp;</td>
  </tr>
</table>
<!---display the form--->
<form name="contacts" method="post">
<input type="hidden" name="Contract_Main_ID" value="#request.ContractID#">
<input type="hidden" name="mode" value="#request.mode#">

<!---25704 - 2011-mar-15 added ext. contacts--->
<cfscript>
  // set readonly attribute based on the passing edit parameter
  if ( request.mode eq "view" )
    main.readonly = true;
  else
    main.readonly = false;
</cfscript>

<div style="margin:20 0 10 35"><span class="label">Email Message:</span><br/><textarea id="emailmessage" name="emailmessage" <cfif main.readonly>readonly="readonly"</cfif> cols=107 rows=5>#main.emailMessage#</textarea><br/>
( <span id="charLeft">#(main.messageMaxLen - Len(main.emailMessage))#</span> characters left )</div>
</cfoutput>
<cf_emailRecipient
          intEmails_name  = "internals"
          intEmails_value = #main.internals#
          intEmails_size  = "rows=7 cols=107"
          intEmails_label = '<span class="label">Internal Recipients:</span><font color="red"><br/><i>Type at least 2 letters to see suggestions for email addresses for users of the application. Use up/down <br/>arrow to browse, enter to select. Then continue typing to add more. Separating them with a semi-colon (;)</i></font>'
          include         = "internal"
          include_jQuery  = false
          readonly        = #main.readonly#
          >

<!---list distributors out when they exist--->
<cfset main.checkedDistributors = 0>
<cfif rsDistributors.recordCount>
  <div style="clear:both;margin:10 0 0 35">
  <div style="margin:0 0 7 0">
  <span class="label">Distributor Recipients:</span>
  <cfif main.readonly eq false>
    <span class="label2" style="margin-left:16px;"><input type="checkbox" id="alldistributors" OnClick="process_all('alldistributors', '.distributors')"> All distributor recipients</span>
  </cfif>
  </div>
  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1, 3, 3, 3] )>
  <table class="recipients datagrid" style="table-layout:fixed;">
    <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
      <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
    </cfloop>
    <thead>
    <tr>
        <th>Check</th>
        <th>Name</th>
        <th>Title</th>
        <th>Email</th>
    </tr>
    </thead>
    <tbody>
    <cfoutput query="rsDistributors">
    <!---get checkbox value when it is checked--->
    <cfset main.recipientValue = RecipientVal(rsDistributors.Bsa_Foodservice_Customers_Id, rsDistributors.email)>
    <!---display checkbox & recipient info, checkbox name begins with 'distributors' & ends with current row number--->
    <tr>
      <td><input type="checkbox" name="distributors#rsDistributors.currentRow#" value="#main.recipientValue#" <cfif ListFindNoCase(main.distributors, main.recipientValue)>checked<cfset main.checkedDistributors = main.checkedDistributors + 1></cfif> <cfif main.readonly>disabled</cfif> class="distributors"/></td>
      <td>#rsDistributors.first_name# #rsDistributors.last_name#</td>
      <td>#rsDistributors.title#</td>
      <td>#rsDistributors.email#</td>
    </tr></cfoutput>
    </tbody>
  </table>
  </div>
</cfif>

<!---list operators out when they exist--->
<cfset main.checkedOperators = 0>
<cfif rsOperators.recordCount>
  <div style="margin:15 0 0 35">
    <div style="margin:0 0 7 0"><span class="label">Operator Recipients</span>
      <cfif main.readonly eq false>
        <span class="label2" style="margin-left:16px;"><input type="checkbox" name="alloperators" id="alloperators" onclick="process_all('alloperators', '.operators')"> All operator recipients</span>
      </cfif>
    </div>
  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1, 3, 3, 3] )>
  <table class="recipients datagrid" style="table-layout:fixed;">
    <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
      <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
    </cfloop>
    <thead>
    <tr>
        <th>Check</th>
        <th>Name</th>
        <th>Title</th>
        <th>Email</th>
    </tr>
    </thead>
    <tbody>
    <cfoutput query="rsOperators">
    <!---get checkbox value when it is checked--->
    <cfset main.recipientValue = RecipientVal(rsOperators.Bsa_Operator_Id, rsOperators.email)>
    <!---display checkbox & recipient info, checkbox name begins with 'operators' & ends with current row number--->
    <tr>
      <td><input type="checkbox" name="operators#rsOperators.currentRow#" value="#main.recipientValue#" <cfif ListFindNoCase(main.operators, main.recipientValue)>checked<cfset main.checkedOperators = main.checkedOperators + 1></cfif> <cfif main.readonly>disabled</cfif> class="operators"/></td>
      <td>#rsOperators.first_name# #rsOperators.last_name#</td>
      <td>#rsOperators.title#</td>
      <td>#rsOperators.email#</td>
    </tr></cfoutput>
    </tbody>
  </table>
  </div>
</cfif>

<table style="margin:15 0 0 40" cellpadding="10">
	<tr>
	  <!---show save option if operating mode is not view--->
	  <cfif request.mode neq "view">
  		<td>
 	      <cfset button_caption = "save contacts">
  			<CF_button
  				button_name		=	"save"
  				button_caption=	#button_caption#
  				button_action	=	"save();"
  				button_type		=	"javascript_link"
  				button_width	=	"150"
  				button_color	=	"Navy"
  				button_tip		=	"Click here to save..."
  				font_color		=	"White"
  				font_size		  =	"12"
  				font_weight		=	"bold">
  		</td>
	  </cfif>

	  <!---show return to program option if operating mode is not rfa--->
		<td>
			<CF_button
				button_name		=	"viewprogram"
				button_caption=	"return to program view"
				button_tip		=	"Click here to return..."
				button_action	=	"self.close();"
				button_type		=	"javascript_link"
				button_width	=	"150"
				button_color	=	"Navy"
				font_color		=	"White"
				font_size		  =	"12"
				font_weight		=	"bold">
		</td>
	</tr>
</table>
</form>

<cfinclude template="/common_files/dataTables.cfm">

<script language="javascript" src="/script/javascript/google/base.min.js"></script>
<script language="javascript" src="/script/javascript/google/string.min.js"></script>
<script language="javascript" src="/script/javascript/google/emailaddress.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>

<script>
<cfif rsDistributors.recordCount eq main.checkedDistributors>
$('#alldistributors').attr('checked', 'true');
</cfif>
<cfif rsOperators.recordCount eq main.checkedOperators>
  $('#alloperators').attr('checked', 'true');
</cfif>
$.fn.dataTableExt.afnSortData['dom-checkbox'] = function  ( oSettings, iColumn ) {
	var aData = [];
	$( 'td:eq('+iColumn+') input', oSettings.oApi._fnGetTrNodes(oSettings) ).each( function () {
		aData.push( this.checked==true ? "1" : "0" );
	} );
	return aData;
}
$('table.recipients').dataTable({
	 "bPaginate": false
  ,"bSortClasses": false
  ,"bScrollCollapse": true
  ,"sScrollXInner": "100%"
  ,"sScrollY": "500px"         <!---limit datagrid to 400px in height--->
  ,"aaSorting": [[ 1, "asc" ]]
  ,"aoColumns": [   {"sSortDataType": "dom-checkbox" }
                  , {}
                  , {}
                  , {}
                ]
}).fnSetFilteringDelay();
// $(window).resize(function(){  $('table.recipients').fnAdjustColumnSizing(); });
function save() {
	if ( (goog.string.isEmpty(document.all.internals.value)) || (goog.format.EmailAddress.isValidAddress(document.all.internals.value)) )
    contacts.submit();
  else {
		queueMessage("Please review and correct the email addresses", document.all.error_internals);
		showMessageWindow();
  }
}
function process_all( elementID, checkClass ) {
  $(checkClass).attr('checked', $('#' + elementID).attr('checked'));
}
$('#emailmessage').keyup(function() {
  var len = this.value.length, maxlen = <cfoutput>#main.messageMaxLen#</cfoutput>;
  if (len >= maxlen)
    this.value = this.value.substring(0, maxlen);
  $('#charLeft').text(maxlen - len);
});
$('table.recipients tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });
</script>

<cffunction name="RecipientHtml" output="false" returntype="string" hint="Returns the recipient name & email.">
  <cfargument name="first_name" type="string" required="true" hint="">
  <cfargument name="last_name"  type="string" required="true" hint="">
  <cfargument name="email"      type="string" required="true" hint="">

  <cfreturn trim(arguments.last_name & ' ' & trim(arguments.first_name) & ' (' & trim(arguments.email) & ')')>
</cffunction>

<cffunction name="RecipientVal" output="false" returntype="string" hint="Returns the recipient value when checked.">
  <cfargument name="id"    type="string" required="true" hint="">
  <cfargument name="email" type="string" required="true" hint="">

  <!--separate id and email with a vertical bar, the id is used to find distributor/operator info to be included
      in the letter-->
  <cfreturn trim(arguments.id) & '|' & trim(arguments.email)>
</cffunction>

</body>
</html>

