<!DOCTYPE HTML>
<!---------------------------------------------------------------------------------------------------------------------
			Template: \settings\external_contacts\edit.cfm
			Date:     2013 December
			Author:   Chris Nguyen
			Purpose:  Add/Edit external contact

			Notes:

			Required Input:
----------------------------------------------------------------------------------------------------------------------->
<html>
<head>
	<title></title>
	<link rel="stylesheet" type="text/css" href="/common_files/feedback.css">
	<style>
		#mainfieldset { padding:1%; border:1px solid blue; width:98%; }
		form { margin:0; padding:0; }
		#loading { font-weight:bold; color:#D2691E; margin-top:5px; }
		.item {
			margin:15px;
		}
		.itemlabel {
			width:120px;
			font-weight:bold;
			text-align:right;
			margin-right:8px;
			display:inline-block;
			vertical-align: top;
		}
		#actions {
			margin: 17px 0 10px 145px;
		}
		#actions a {
			margin-right: 25px;
		}
	</style>
	<link rel="stylesheet" type="text/css" href="/common_files/datatable.css">
	<script src="/script/javascript/wholenumbervalidation.js?"></script>
	<cfinclude template="/common_files/jQuery.cfm">
	<script type="text/javascript" src="/script/javascript/jquery.cfjs.min.js"></script>
</head>
<cfparam name="url.del146" default="0">
<!--- 52788 --->
<cfscript>
	// combine gets and posts into the request scope
	if ( isDefined("URL") )
		structAppend(request, URL, true);

	if ( isDefined("FORM") )
		structAppend(request, FORM, true);

	variables.contact_cfc = createObject("component", "components.settings.external_contact");
	variables.pageTitle   = (request.contact_id eq "0" ? "Add" : "Edit") & " External Contact";
</cfscript>

<!--------------------------------------------------------------------------------------------------------------------->

<body>
<cfif url.del146>
	<cfset variables.contact_cfc.delete_contact()>

	<div class="success" style="height:15px;">
		<p><cfoutput>#ucase(url.name)#</cfoutput> contact has been deleted succesfully.</p>
	</div>

	<script>
		$(function() {
			/* wait for a short moment, hide save successfully message and redirect users to the main listing page */
			setTimeout(function() {
				$("div.success").fadeOut();
				window.opener.location.reload(false);
				self.close();
			}, 1750);
		});
	</script>
<cfelseif cgi.request_method eq "post">
	<cfscript>
		 request.combined_phone = request.phone_1 & request.phone_2 & request.phone_3;
		 request.combined_fax   = request.fax_1 & request.fax_2 & request.fax_3;

		// <!--- 45556: External Contacts address field auto defaults to AL, 0 instead of NULL /Anand Rao/14-Oct-14 --->
		request.stateNull = "No";
		request.zipNull = "No";

		if (request.state eq "")
			request.stateNull = "Yes";
		if (request.zip eq "")
			request.zipNull = "Yes";

		if (request.contact_id eq "0") {
			variables.contact_cfc.add_contact();
		}
		else {
			variables.contact_cfc.update_contact();
		}
	</cfscript>
	<fieldset id="mainfieldset">
		<cfoutput>
		<legend style="font:bold 14px sans-serif; color:red;"> #variables.pageTitle# </legend>
			<div class="success" style="height:15px;">
				<p>Your changes have been saved succesfully.</p>
			</div>
		</cfoutput>
	</fieldset>
	<script>
		$(function() {
			// wait for a short moment, hide save successfully message and redirect users to the main listing page
			setTimeout(function() {
				$("div.success").fadeOut();
				<cfoutput> window.location = "#application.HTTPVar##CGI.server_name#/settings/external_contacts/index.cfm"; </cfoutput>
			}, 1750);
		});
	</script>
<cfelse>
	<cfscript>
		variables.qContact  = variables.contact_cfc.get_contact();
		variables.getStates = variables.contact_cfc.get_states();
	</cfscript>

	<fieldset id="mainfieldset">
		<cfoutput>
		<legend style="font:bold 14px sans-serif; color:red;"> #variables.pageTitle# </legend>

		<cfif cgi.request_method eq "post">
			<div class="success" style="height:15px;">
				<p>Your changes have been saved succesfully.</p>
			</div>
		</cfif>

		<form name="dataentry" method="post">
		<input type="hidden" name="contact_id" value="#request.contact_id#">

		<div class="item">
			<label class="itemlabel" for="first_name">First Name:</label><span></span>
			<input type="text" name="first_name" class="itemvalue" value="#variables.qContact.First_Name#">
		</div>

		<div class="item">
			<label class="itemlabel" for="last_name">Last Name:</label><span></span>
			<input type="text" name="last_name" class="itemvalue" value="#variables.qContact.Last_Name#">
		</div>

		<div class="item">
			<label class="itemlabel" for="company_code">Company Code:</label><span></span>
			<input type="text" name="company_code" class="itemvalue" value="#variables.qContact.Company_Code#">
		</div>
		<div class="item">
			<label class="itemlabel" for="company_name">Company Name:</label><span></span>
			<input type="text" name="company_name" class="itemvalue" value="#variables.qContact.Company_Name#" size="73">
		</div>

		<div class="item">
			<label class="itemlabel" for="title">Job Title:</label><span></span>
			<input type="text" name="title" class="itemvalue" value="#variables.qContact.Title#" size="73">
		</div>


		<div class="item">
			<label class="itemlabel" for="email">Email:</label><span></span>
			<input type="text" name="email" class="itemvalue" value="#variables.qContact.Email#" size="73">
		</div>
	<!---D43415 :: Users should be able to update external contacts START --->
		<div class="item">
			<label class="itemlabel" for="company_code">Address:</label><span></span>
			<textarea cols="42" rows="2" name="Address" onPaste="javaScript: return restrictLength(this,255);" onKeyPress="javaScript: return restrictLength(this,255);">#variables.qContact.address#</TEXTAREA>
		</div>

		 <div class="item">
			<label class="itemlabel" for="company_code">City/State/Postal:</label><span></span>
			<input name="city" value="#variables.qContact.city#" type="text" maxlength="50">

			<select name="state">
			<option value="">Pick a State</option>
				<cfsetting enablecfoutputonly="true" >
				<cfloop query="variables.getStates">
					<cfoutput><option value="#variables.getStates.state_id#"<cfif variables.getStates.state_id eq variables.qContact.state> selected</cfif>>#variables.getStates.state_code#</option></cfoutput>
				</cfloop>
				<cfsetting enablecfoutputonly="false" >
			</select>
						,
					<input name="zip" value="#variables.qContact.zip#" type="text" size="4" maxlength="5">
		</div>

		 <div class="item">
			<label class="itemlabel" for="company_code">Phone:</label><span></span>
				<input name="phone_1" value="#Left(variables.qContact.phone, 3)#" type="text" size="1" maxlength="3" onKeyUp="nextBox(this, 'phone_1',3);">
						- <input name="phone_2" value="#right(left(variables.qContact.phone,6),3)#" type="text" size="1" maxlength="3" onKeyUp="nextBox(this, 'phone_2',3);">
						- <input name="phone_3" value="#right(variables.qContact.phone,4)#" type="text" size="2" maxlength="4" onKeyUp="nextBox(this, 'phone_3',3);">
						&nbsp;Ext. <input name="phone_ext" value="#variables.qContact.ext#" type="text" size="2" maxlength="10">
		</div>

		 <div class="item">
			<label class="itemlabel" for="company_code">Fax:</label><span></span>
				<input name="fax_1" value="#Left(variables.qContact.fax,3)#" type="text" size="1" maxlength="3" onKeyUp="nextBox(this, 'fax_1',3);">
			- <input name="fax_2" value="#right(left(variables.qContact.fax,6),3)#" type="text" size="1" maxlength="3" onKeyUp="nextBox(this, 'fax_2',3);">
			- <input name="fax_3" value="#right(variables.qContact.fax,4)#" type="text" size="2" maxlength="4" onKeyUp="nextBox(this, 'fax_3',3);">
		</div>
	<!---D43415 :: Users should be able to update external contacts END --->

		<div class="item">
			<label class="itemlabel" for="notes">Notes:</label><span></span>
			<textarea name="notes" id="notes" rows=3 cols=100>#variables.qContact.Notes#</textarea>
		</div>

		<div id="actions">
		 <a href="##" id="save">#application.util.string.actionLinkFormat2("save")#</a>
		 <a href="##" id="return">#application.util.string.actionLinkFormat2("cancel")#</a>
		</div>
		</form>
		</cfoutput>
	</fieldset>

	<!------------------------------------------------JAVASCRIPT----------------------------------------------------------->

	<script>
		// EDITING mode
		$("#return").click( function() {
			<cfoutput> window.location = "#application.HTTPVar##CGI.server_name#/settings/external_contacts/index.cfm"; </cfoutput>
		});

		$("#save").click( function() {
			var errors = [];
			var test_value = $.Trim( $('input[name="first_name"]').val() );
			if (test_value == '') {
				errors.push('Please enter a first name.');
			}

			test_value = $.Trim( $('input[name="last_name"]').val() );
			if (test_value == '') {
				errors.push('Please enter a last name.');
			}

			if ( $('#notes').val().length > 250 ) {
				errors.push('Please limit notes to 250 characters.');
			}

			var duplicateExists = false;
			$.ajax({ url: "/components/settings/external_contact.cfc"
			        ,type: "post"
			        ,timeout:60000
			        ,data: 	{ 	method: "is_duplicate_contact"
							    ,first_name: $("input[name=first_name]").val()
							    ,last_name: $("input[name=last_name]").val()
							    ,email: $("input[name=email]").val()
							    ,company_code: $("input[name=company_code]").val()
							  	,contact_id: <cfoutput>#request.contact_id#</cfoutput>
							}
			        ,dataType: "json"
			        ,async: false
			        ,success: function(json) { duplicateExists = json.DUPLICATEEXISTS; }
		  	});
		  	if (duplicateExists) {
		  		errors.push("The selected name, company code and email already exists.");
		  	}

			if ( errors.length ) {
				alert( errors.join('\n') );
			}
			else {
				$("form[name=dataentry]").submit();
			}
		});

		function restrictLength(thisobj,valueLength) {
			if(event.type == "keypress")
			{
				if(thisobj.value.length >= valueLength)
				{
					return false;
				}
			}
			if(event.type == "paste")
			{
				var fullData = thisobj.value + window.clipboardData.getData("Text");
				if(fullData.length >= valueLength)
				{
					thisobj.value = fullData.substr(0,valueLength);
					return false;
				}
			}
			return true;
		}
	</script>
</cfif>
</body>
</html>