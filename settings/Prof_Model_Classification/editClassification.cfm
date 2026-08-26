<!---------------------------------------------------------------------------------------------------------------------
      Template: \settings\Prof_Model_Classification\listClassification.cfm
      Date:     2013 Feb
      Author:   Chris Nguyen
      Purpose:  Allow users to manage profitability model classifications

			Remarks:  
----------------------------------------------------------------------------------------------------------------------->
<cfmodule template="/customTags/layout.cfm" layoutID = "profit-models-classification">
<style>
.action { margin-left:20px; }
label { margin-right:5px; font-weight:bold; font-size:1em; }
</style>
<cfscript>
  dataCFC = createObject("component", "components.general.Profitability_Models");
</cfscript>


<cfif cgi.request_method eq "post">
	<cfset dataCFC.saveClassification(  classification_id   = form.classification_id
	                                   ,classification_name = form.classification_name )>
	<cflocation url="listClassification.cfm" addtoken="false">
</cfif>

<cfscript>
  qClassification = dataCFC.getClassifications( url.classification_id );
</cfscript>

<cfoutput>
<fieldset id="mainfieldset" style="padding:10px; border: 1px solid blue;">
	<legend style="font: bold 14px sans-serif; color: red;"><cfif qClassification.recordCount eq 0>Create New <cfelse>Edit</cfif> Classification</legend>
	<form id="form226" method="post">
	<input type="hidden" name="classification_id" id="classification_id" value="#url.classification_id#">
	<label for="classification_name">Classification Name:</label>
	<input name="classification_name" size=100 id="classification_name" value="#qClassification.classification_name#">
	</form>
	<a href="##" class="action" id="save301">#application.util.string.actionLinkFormat("save")#</a>
	<a href="##" class="action" id="cancel301">#application.util.string.actionLinkFormat("cancel")#</a>
</fieldset>
</cfoutput>

<script>
	$('#cancel301').click( function() {
	  window.location = "listClassification.cfm";
	});

	$('#save301').click( function() {
		if ( $.trim($('#classification_name').val()) ) {
	  	$("#form226").submit();
		}
		else {
			alert( 'Please enter a classification name.' );
	  }
	});
</script>
</cfmodule>