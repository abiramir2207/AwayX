<cfsilent>
<cfparam name="attributes.intEmails_name"       default="intEmails_value">                    <!---name of the form input field that holds the INternal email recipients--->
<cfparam name="attributes.intEmails_value"      default="">                                   <!---initial value for internal email recipient--->
<cfparam name="attributes.intEmails_label"      default='<b>Internal Recipients:</b><font color="red"><i> Type at least 2 letters to see suggestions for email addresses for users of the application.<br/>Use up/down arrow to browse, enter to select. Then continue typing to add more. Separating them with a semi-colon (;)</i></font>'>  <!---label for internal email recipient--->
<cfparam name="attributes.intEmails_size"       default="rows=5 cols='100'">                  <!---textarea dimension for internal emails--->
<cfparam name="attributes.intEmails_userIDs"    default="">                                   <!---list of internal user IDs to be used on popup list--->

<cfparam name="attributes.extEmails_name"       default="">                                   <!---name of the form input field that holds the EXternal email recipients--->
<cfparam name="attributes.extEmails_value"      default="">                                   <!---initial value for external email recipient--->
<cfparam name="attributes.extEmails_label"      default="<b>External Email Recipients:</b><font color='red'><i> Enter email addresses for individuals that are not users of the application.</i></font>">  <!---label for external email recipient--->
<cfparam name="attributes.extEmails_size"       default="rows=5 cols='100'">                  <!---textarea dimension for external emails--->
<cfparam name="attributes.extEmails_userIDs"    default="">                                   <!---list of external user IDs to be used on popup list--->

<cfparam name="attributes.extEmails_grid"       default="">                                   <!---display external contacts in datatables grid? 28345--->
<cfparam name="attributes.iDisplayLength"       default="150">                                <!---external contacts datatables grid size--->

<cfparam name="attributes.company_codes"        default="">                                   <!---list of company codes used for filtering external contacts (e.g. '4958','4891')--->

<cfparam name="attributes.include"              default="internal,external">                  <!---identify which group to display internal contacts or external contacts or both--->
<cfparam name="attributes.separate_textarea"    default=true>                                 <!---use separate textarea for each group?--->
<cfparam name="attributes.usage"                default=''>

<cfparam name="attributes.include_jQuery"       default=true>     <!---pass false if jQuery is already loaded--->
<cfparam name="attributes.include_jQueryUI"     default=true>     <!---pass false if jQueryUI is already loaded--->
<cfparam name="attributes.include_jQueryCSS"    default=true>     <!---pass false if jQuery custom CSS is already loaded--->

<cfparam name="attributes.readonly"             default=false>    <!---do not allow editing if this is true--->
<cfparam name="attributes.debug"                default=false>    <!---TODO: assign it to false prior to checking the code in--->

<cfparam name="attributes.table_class"          default="">       <!---CSS class for the whole table--->
<cfparam name="attributes.position"             default="my:'right bottom', at:'right top', collision:'flip'">
</cfsilent>

<!---load jQuery only if needed--->
<cfif attributes.include_jQuery><cfinclude template="/common_files/jQuery.cfm"></cfif>

<style>
.ui-autocomplete a.ui-state-hover { font-weight: bold !important;  // rather not bold the hover item (changes the width) }
</style>

<cfif Len(Trim(attributes.table_class)) eq 0>
  <style>
  .emailRecipient { margin-left:35px; width=700px; border=0; }
  </style>
  <cfset attributes.table_class = "emailRecipient">
</cfif>

<cfif attributes.debug>
  <!---<script>alert("company_codes=" + <cfoutput>"#attributes.company_codes#"</cfoutput>);</script>--->
  <cflog file="emailRecipient" text="attributes.company_codes=#attributes.company_codes#">
</cfif>

<!---validate passing parameters--->
<cfif not ListFindNocase(attributes.include, "internal")
  and not ListFindNocase(attributes.include, "external")>
  <script>alert("Include parameter should be either internal, external or both.")</script>
  <cfabort>
</cfif>

<!---assign default name for external email contacts--->
<cfif trim(attributes.extEmails_name) eq "">
  <!---by adding '_2' to the end of the internal email recipients--->
  <cfset attributes.extEmails_name = attributes.intEmails_name & "_2">
</cfif>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init()>
<cfset appSettings = genSettingsManager.get()>

<cfoutput>
<table cellpadding="3" cellspacing="0" class="#attributes.table_class#">
<!---display autocompletion help if it is defined--->
<cfif Len(attributes.Usage)>
  <tr>
    <td>#attributes.usage#</td>
  </tr>
</cfif>

<!---is internal email recipient enabled?--->
<cfif ListFindNocase(attributes.include, "internal")>
  <tr>
    <td>#attributes.intEmails_label#<span id="error_#attributes.intEmails_name#"></span><br/><textarea id="intEmails" name="#attributes.intEmails_name#" #attributes.intEmails_size# <cfif attributes.readonly>readonly="readonly"</cfif>>#attributes.intEmails_value#</textarea></td>
  </tr>
</cfif>

<cfset rsExternalEmails = getExternalEmails()>

<!---is external email recipient enabled?--->
<cfif attributes.separate_textarea and ListFindNocase(attributes.include, "external")>
  <cfif appSettings.External_Contacts_Option eq 0>
    <input type="hidden" name="#attributes.extEmails_name#" value="">     <!---28345 - added hidden input for external email to avoid JS error in validation logic--->
    </table>
  <cfelse>
    <tr>
      <td><br/>#attributes.extEmails_label#<span id="error_#attributes.extEmails_name#"></span><br/>
      <div style="margin:3px 0 3px 0">
      <span style="font-weight:bold;color:red"> [ </span>
            <a href="##" id="addcontacts" style="font-weight: bold;"> add contacts associated to this #lcase(application.returned_customer_setting.shard_ship_to_label)#</a>
          <span style="font-weight:bold;color:red"> ] </span>
      </div>
      <textarea id="extEmails" name="#attributes.extEmails_name#" #attributes.extEmails_size# <cfif attributes.readonly>readonly="readonly"</cfif>>#attributes.extEmails_value#</textarea></td>
    </tr>
    </table>

    <cfif len(attributes.extEmails_grid)>
      <hr style="color:orange">
      <div style="font-size:14px;font-weight:bold;color:navy;margin:10px 0;">Contacts</div>
      <cfset extEmails_grid()>
    </cfif>
  </cfif>
<cfelse>
    </table>
</cfif>
</cfoutput>

<!--------------------------------------------------------------------------------------------------------------------->
<!---load jQuery UI only if needed--->
<cfif attributes.include_jQueryUI><script type="text/javascript" src="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js"></script></cfif>
<!---load jQuery custom CSS only if needed--->
<cfif attributes.include_jQueryCSS><cfhtmlhead text='<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.14.custom.css" type="text/css" />'></cfif>

<!---bind autocomplete plugin in edit mode--->
<cfif not attributes.readonly>
  <cfif attributes.debug>
    <cflog file="emailRecipient" text="ext.contacts=#externalEmails()#">
  </cfif>

<script>
/*load email addresses from db*/
<cfif attributes.separate_textarea>
  var intEmails = [ <cfoutput>#internalEmails()#</cfoutput> ];
  var extEmails = [ <cfoutput>#externalEmails()#</cfoutput> ];
<cfelse>
  <!---one textarea for both internal recipients & external recipients--->
  <cfset intEmails = internalEmails()>
  <!---combine the two lists into one--->
  var intEmails = [ <cfoutput><cfif Len(intEmails)>#intEmails#,</cfif>#externalEmails()#</cfoutput> ];
  var extEmails = [];
</cfif>

	/*return a list of checked contacts*/
	function selected_contacts() {
		var result = [];
		<cfif attributes.include contains "external">
			$('.toggle_one:checked', econt_grid.fnGetNodes()).each(function(){
				result.push( $(this).attr('name') );
			});
		</cfif>
		return result.join(';');
	}


$(function() {
  function split( val ) {
    return val.split( /;\s*/ );
  }
  function extractLast( term ) {
    return split( term ).pop();
  }

  $( "#intEmails" )
    // don't navigate away from the field on tab when selecting an item
    .bind( "keydown", function( event ) {
      if ( event.keyCode === $.ui.keyCode.TAB &&
          $( this ).data( "autocomplete" ).menu.active ) {
        event.preventDefault();
      }
    })
    .autocomplete({
      minLength: 2
      ,autoFocus:true
      ,source: function( request, response ) {
        // delegate back to autocomplete, but extract the last term
        response( $.ui.autocomplete.filter(
          intEmails, extractLast( request.term ) ) );
      }
      ,position: {<cfoutput>#attributes.position#</cfoutput>}
      ,focus: function() {
        // prevent value inserted on focus
        return false;
      }
      ,select: function( event, ui ) {
        var terms = split( this.value );
        // remove the current input
        terms.pop();
        // add the selected item
        terms.push( ui.item.value );
        // add placeholder to get the comma-and-space at the end
        terms.push( "" );
        this.value = terms.join( "; " );
        return false;
      }
    });

  $( "#extEmails" )
    // don't navigate away from the field on tab when selecting an item
    .bind( "keydown", function( event ) {
      if ( event.keyCode === $.ui.keyCode.TAB &&
          $( this ).data( "autocomplete" ).menu.active ) {
        event.preventDefault();
      }
    })
    .autocomplete({
      minLength: 2
      ,source: function( request, response ) {
        // delegate back to autocomplete, but extract the last term
        response( $.ui.autocomplete.filter(
          extEmails, extractLast( request.term ) ) );
      }
      ,position: {<cfoutput>#attributes.position#</cfoutput>}
      ,focus: function() {
        // prevent value inserted on focus
        return false;
      }
      ,select: function( event, ui ) {
        var terms = split( this.value );
        // remove the current input
        terms.pop();
        // add the selected item
        terms.push( ui.item.value );
        // add placeholder to get the comma-and-space at the end
        terms.push( "" );
        this.value = terms.join( "; " );
        return false;
      }
    });
});
$('#addcontacts').click(function(e) {
  e.preventDefault();
  if ( extEmails.length ) {
     $('#extEmails').val( extEmails.join(';') );
  }
  else {
    <cfoutput>
    alert('There are no contacts (with email addresses) associated to this #lcase(application.returned_customer_setting.shard_ship_to_label)#.');
    </cfoutput>
  }
});
</script>
</cfif>

<!---
      open: function(event, ui) {
        $(".ui-autocomplete").position({my:"left top", at:"right top", of:$("#intEmails"), collision: "none"});
      },


      open: function(event, ui) {
        $(".ui-autocomplete").position({my:"left top", at:"right top", of:$("#extEmails"), collision:"none"});
      },
--->

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="externalEmails" output="false" returntype="string" hint="Returns external contact JS array elements">
  <cfscript>
    var result = "";
    var cachedwithin = CreateTimeSpan(0, 0, 0, 0);
  </cfscript>
  <!---email value = { last_name first_name <email> [,] } (e.g. "Joe Smith <joesmith@gmail.com>,Mary Kay <marykay@hotmail.com>")--->
  <cfsavecontent variable="result"><cfoutput query="rsExternalEmails">#emailValue(rsExternalEmails.First_Name, rsExternalEmails.Last_Name, rsExternalEmails.Email)#</cfoutput></cfsavecontent>
  <!---remove the last comma--->
  <cfif Len(result)>
    <cfset result = Left(result, Len(result) - 1)>
  </cfif>

  <cfreturn result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="getExternalEmails" output="false" returntype="query" hint="Returns external contact query">
  <cfscript>
    var result = "";
    var cachedwithin = CreateTimeSpan(0, 0, 0, 0);
  </cfscript>
  <cfif Len(trim(attributes.extEmails_userIDs))>
    <!---retrieve internal email recipients based on a provided list--->
    <cfquery name="result" datasource="#application.datasource#">
      SELECT Last_Name,
             First_Name,
             Company_Name,
             Email
        FROM External_Contacts
       WHERE Contact_ID in (#PreserveSingleQuotes(attributes.extEmails_userIDs)#) AND Email > ''
       ORDER BY Last_Name
    </cfquery>
  <cfelse>
    <!---retrieve external email recipients--->
    <cfquery name="result" datasource="#application.datasource#">
      SELECT Last_Name,
             First_Name,
             Company_Name,
             Email
        FROM External_Contacts
       WHERE Deleted = 0
             AND Email > ''
             <!---don't select any rows if external option is not enabled or company code filter is empty--->
             <cfif not ListFindNocase(attributes.include, "external")
                   or Len(Trim(attributes.company_codes)) eq 0
                   or appSettings.External_Contacts_Option eq 0>
              AND 1 = 0
             <cfelseif Len(attributes.company_codes)>
              AND External_Contacts.Company_Code in (#PreserveSingleQuotes(attributes.company_codes)#)
             </cfif>
       ORDER BY Last_Name
    </cfquery>
  </cfif>
  <cfreturn result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="internalEmails" output="false" returntype="string" hint="Returns internal contact JS array elements">
  <cfscript>
    var result = "";
    var rsInternalEmails = 0;
    var cachedwithin = CreateTimeSpan(1, 0, 0, 0);
    var currentRow = 1;
  </cfscript>

  <cfif Len(trim(attributes.intEmails_userIDs))>
    <!---retrieve internal email recipients based on a provided list--->
    <cfquery name="rsInternalEmails" datasource="#application.datasource#" cachedwithin="#cachedwithin#">
      SELECT DISTINCT U.User_email,
             U.Name_last,
             U.Name_first
        FROM _users U
       WHERE U.User_ID in (#PreserveSingleQuotes(attributes.intEmails_userIDs)#)
       ORDER BY U.Name_last
    </cfquery>
  <cfelse>
    <!---retrieve internal email recipients--->
    <cfquery name="rsInternalEmails" datasource="#application.datasource#" cachedwithin="#cachedwithin#">
      SELECT DISTINCT U.User_email,
                      U.Name_last,
                      U.Name_first
        FROM _users U
       WHERE U.User_email <> ''
             AND Deleted = 0
             <!---don't select any rows if internal option is not enabled--->
             <cfif not ListFindNocase(attributes.include, "internal")>
              AND 1 = 0
             <!---Don't show BSA users --->
             <cfelseif appSettings.getHide_BSA_Users() IS 1>
              AND (U.User_Rights_ID IS NULL OR U.User_Rights_ID != 9999)
             </cfif>
       ORDER BY U.Name_last
    </cfquery>
  </cfif>

  <!---email value = { last_name first_name <email> [,] } (e.g. "Joe Smith <joesmith@gmail.com>,Mary Kay <marykay@hotmail.com>")--->
  <cfsavecontent variable="result"><cfoutput query="rsInternalEmails">#emailValue(rsInternalEmails.name_first, rsInternalEmails.name_last, rsInternalEmails.user_email)#</cfoutput></cfsavecontent>

  <!---remove the last comma--->
  <cfif Len(result)>
    <cfset result = Left(result, Len(result) - 1)>
  </cfif>
  <cfreturn result>
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="emailValue" output="false" returntype="string" hint="Returns email address value displayed in the autocompletion popup.">
  <cfargument name="first_name" type="string" required="true" hint="">
  <cfargument name="last_name"  type="string" required="true" hint="">
  <cfargument name="email"      type="string" required="true" hint="">

  <!---note: value is wrapped in a pair of quote & there is a trailing comma for separating multiple elements--->
  <cfreturn "'" & jsStringFormat(trim(arguments.last_name & ' ' & trim(arguments.first_name) & '<' & trim(arguments.email) & '>')) & "',">

<!---
    <!---use this if display label is not the same as stored value
         also in the calling function, we need to wrap all elements in a pair of bracket {} --->
      <cfreturn jsStringFormat('label:"' & arguments.Last_Name & ' ' & arguments.First_Name & '(' & arguments.Company_Name & ')",'
                             & 'value:"' & arguments.Last_Name & ' ' & arguments.First_Name & '<' & arguments.Email & '>",')>
--->
</cffunction>

<!--------------------------------------------------------------------------------------------------------------------->
<cffunction name="extEmails_grid" output="true" returntype="void" hint="">

  <cfset var vars = structnew()>

  <cfsavecontent variable="vars.htmlHead">
    <link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
  </cfsavecontent>
  <cfhtmlhead text="#vars.htmlHead#">

  <cfset variables.columnSizes = application.util.array.dtColumnSizeInPercent( [1.25, 3, 3, 3] )>
  <table id="extEmails_grid" class="datagrid" style="table-layout:fixed;">
  <cfloop array="#variables.columnSizes#" index="variables.columnPercentage">
    <cfoutput><col width="#variables.columnPercentage#%"></cfoutput>
  </cfloop>
  <thead>
    <tr>
    <th><input type="checkbox" name="toggle_all" id="toggle_all"/> Check</th>
    <th>Name</th>
    <th>Company</th>
    <th>Email</th>
    </tr>
  </thead>
  <tbody>
    <cfoutput query="rsExternalEmails">
      <tr>
        <td><input type="checkbox" name="#rsExternalEmails.Email#" class="toggle_one"/></td>
        <td>#rsExternalEmails.First_Name# #rsExternalEmails.Last_Name#</td>
        <td>#rsExternalEmails.Company_Name#</td>
        <td>#rsExternalEmails.Email#</td>
      </tr>
    </cfoutput>
  </tbody>
  </table>
  <div class="clearfix"></div>
  <cfset datatables.version = "1.9.1">
  <cfinclude template="/common_files/datatables.cfm">
  <script type="text/javascript" src="/Script/javascript/jquery.dataTables-api.js"></script>
  <script>
    var econt_grid = 0;
    function refresh_toggle_all() {
      var all_checked = 1;
      $('.toggle_one').each(function() {    <!---are all single toggle checked?--->
        if ( !$(this).prop('checked') ) {   <!---found one single toggle unchecked--->
           all_checked = 0;
           return false;
        }
      });
      $('##toggle_all').prop('checked', all_checked == 1 );
    }

    var windowHeight = $(window).height(), sScrollY = .55 * windowHeight;
    econt_grid = $('##extEmails_grid').dataTable({
       "bAutoWidth": false
      ,"bPaginate": true
      ,"bSortClasses": false
      ,"bScrollCollapse": true
      ,"iDisplayLength": #attributes.iDisplayLength#
      ,"sDom": 'fpti'
      ,"sScrollY": sScrollY         <!--- data grid height --->
      ,"oLanguage": { "oPaginate": { "sNext": "", "sPrevious": "" } }
      ,"fnDrawCallback": function( oSettings ) {
        refresh_toggle_all();
      }
      ,"aoColumns": [   {"bSortable":false, "bSearchable":false}
                      , {}
                      , {}
                      , {}
                    ]

    }).fnSetFilteringDelay();

    $('##extEmails_grid tbody').on('hover', 'tr', function() { $(this).toggleClass("over"); });

    $('##toggle_all').click(function(e){      <!---listen for click event on toggle all--->
      e.stopPropagation();
      $('.toggle_one').prop('checked', this.checked );
    });

    $('##extEmails_grid tbody').on('click', '.toggle_one', function(e) {
      if ( $(e.target).prop('checked') ) {
        refresh_toggle_all();
      }
      else {
        $('##toggle_all').prop('checked', false );   <!---at least one single toggle is unchecked so uncheck toggle all--->
      }
    });

  </script>
</cffunction>
