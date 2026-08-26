<!doctype html>
<cfsilent>
<!---------------------------------------------------------------------------------------------------------------------
      Template: \GL_Code\Vendor_Management\edit_bank.cfm
      Date:     2015 Oct
      Author:   Chris Nguyen
      Purpose:  Edit bank information for vendor master :: WR 55346
----------------------------------------------------------------------------------------------------------------------->
<!--- save was clicked, save changes to the db --->
<cfif cgi.request_method eq "post">
    <cfoutput>
    <cfquery name="variables.vendor" datasource="#application.datasource#">
        UPDATE Vendor_Master
           SET vendor_bank_name = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.vendor_bank_name#">
              ,vendor_bank_routing_number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.vendor_bank_routing_number#">
              ,vendor_bank_account_number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.vendor_bank_account_number#">
              ,email_address = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.email_address#">
              ,fax_number = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.fax_number#">
              ,payment_delivery_type = <cfqueryparam cfsqltype="cf_sql_varchar" value="#form.payment_delivery_type#">
         WHERE Vendor_Master_ID = '#form.vmi#'
    </cfquery>
    </cfoutput>
</cfif>    <!--- cgi.request_method neq "post" --->
</cfsilent>
  <cfquery name="variables.vendor" datasource="#application.datasource#">
    SELECT *
    FROM Vendor_Master
    WHERE Vendor_Master_ID = <cfoutput>'#url.vmi#'</cfoutput>
  </cfquery>
<html>
    <head>
        <title>Vendor Master - Bank Information</title>
        <style>
        body { padding: 7px; }
        #header { background-image: url("/Images/gradient.jpg");
                  background-repeat: no-repeat;
                  background-color:#a7caf2;
                  height: 30px;
                }
        p { margin:0px; padding:7px;
                  color:white;
                  font-weight: bold;
                  font-size:1.1em; }
        form { width:90%; margin: 25px 15px; }
            form input[type=text] { display:inline-block; }
        label { width: 150px; font-weight: bold; display:inline-block; }
        form div { height: 40px; }
        div#action { margin: 25px 0;}
        a { margin:15px; }
        </style>
    </head>
    <body>
        <!--- save was clicked, changes were saved to the db, now just close the window --->
        <cfif cgi.request_method eq "post">
            <script> window.close(); </script>
        </cfif>
        <cfoutput>
        <div id="header">
            <p>#variables.vendor.Vendor_Name# - #variables.vendor.vendor_id# - #variables.vendor.Address_1# #variables.vendor.City# #variables.vendor.State# #variables.vendor.ZipCode#</p>
        </div>

        <form name="bank_form" method="post">
            <input type="hidden" name="vmi" value="#url.vmi#">
            <div><label>Bank Name:</label><input type="text" size="100" name="vendor_bank_name" value="#variables.vendor.vendor_bank_name#"></div>
            <div><label>Bank Routing Number:</label><input type="text" size="60" name="vendor_bank_routing_number" value="#variables.vendor.vendor_bank_routing_number#"></div>
            <div><label>Bank Account Number:</label><input type="text" size="60" name="vendor_bank_account_number" value="#variables.vendor.vendor_bank_account_number#"></div>
            <div><label>Email Address:</label><input type="text" size="100" name="email_address" value="#variables.vendor.email_address#"></div>
            <div><label>Fax Number:</label><input type="text" size="60" name="fax_number" value="#variables.vendor.fax_number#"></div>
            <div><label>Delivery Type:</label><input type="radio" name="payment_delivery_type"
                                                    <cfif variables.vendor.payment_delivery_type eq "email"> checked=checked </cfif> value="email"> email
                                        &nbsp; &nbsp; <input type="radio" name="payment_delivery_type"
                                                    <cfif variables.vendor.payment_delivery_type eq "fax"> checked=checked </cfif> value="fax"> fax</div>
            <div id="action">
                <a href="##" id="save">#application.util.string.actionLinkFormat2( "save" )#</a>
                <a href="##" id="cancel">#application.util.string.actionLinkFormat2( "cancel" )#</a>
            </div>
        </form>
        </cfoutput>

        <cfinclude template="/common_files/jQuery.cfm">
        <cfinclude template="/common_files/focus.cfm">

        <script>
            $("#cancel").click(function() { window.close(); } );
            $("#save").click(function() { $('form').submit(); } );
            $('input[name=vendor_bank_name]').focus();
        </script>
    </body>
</html>