<html>
<head>
<title>Create listContainsNoCase</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
	<cfparam NAME="form.ListVal" 	DEFAULT="">
	<cfparam name="form.passObj" 	DEFAULT="">
	<cfparam name="form.hiddenForm" DEFAULT="">
	<cfparam name="form.productGroupLevelTypes" default="">
	<cfparam name="currObj"			default="" >
	<cfparam name="url.textareadata" default="">
	<cfparam name="url.passObj"		 default="">
	<cfparam name="url.passForm"	 default="">
	<cfparam name="url.productGroupLevelTypes" default="">
	<cfparam name="url.labelSetDefault" default="">
	<cfparam name="url.CID" default = ""><!--- french translation --->
    <cfparam name="url.programID" default = ""><!--- french translation --->
    <!--- called from planner? --->
    <cfparam name="url.plannerID"		default="">
    <cfparam name="url.group_level_id"	default="">
    <cfparam name="url.callback"	    default="">
		<cfparam name="url.template_id"	    default="0">


	<script src="createList.js"  language="JavaScript"></script>

	<cfif isDefined("form.passObj") and form.passObj neq "" >
		<cfset url.passObj = form.passObj >
	</cfif>
	<cfif isDefined("form.hiddenForm") and form.hiddenForm neq "" >
		<cfset url.passForm = form.hiddenForm >
	</cfif>
	<cfif isDefined("form.validList") >
		<cfset url.textareadata = ListAppend(form.invalidList, form.validList) >
	</cfif>
	<cfif isDefined("url.passObj") and url.passObj NEQ "">
		<cfset currObj = trim(url.passObj) >
	</cfif>
	<cfif isDefined("url.passForm") and url.passForm NEQ "">
		<cfset form.hiddenForm = trim(url.passForm) >
	</cfif>
	<cfif isDefined("url.productGroupLevelTypes") and URL.productGroupLevelTypes NEQ "">
		<cfset form.productGroupLevelTypes = URL.productGroupLevelTypes>
	</cfif>

	<CFSET objHandle = CreateObject("component", "components.general.Create_List")>
    <cfinclude template="/Common_Files/jQuery.cfm">
	<cfoutput>
	<cfinclude template="/common_files/programTranslate.cfm">    <!--- french translation --->
    <BR>

    <cfset form_action = (val(url.plannerID) OR url.passForm EQ "planner_operators")
                            ? "savePlannerProductGroupList.cfm?group_level_id=#url.group_level_id#&plannerID=#url.plannerID#&callback=#url.callback#&passForm=#url.passForm#&template_id=#url.template_id#"
                            : "validateInput.cfm?CID=#URL.CID#&programID=#url.programID#">

	<FORM action="#form_action#" METHOD="post" NAME="comCreateListForm" ID="comCreateListForm" STYLE="DISPLAY:INLINE" target="_self">
		<!--- test area to enter the items needed --->
		<table ALIGN="center" CELLPADDING="5" CELLSPACING="">
			<tr>
				<td>
					<span ID="searchItemLabel" STYLE="color:navy;"><B>#objHandle.getListLabel(currObj)#</B></span>
				</td>
			</tr>
			<tr>
				<cfif url.textareadata neq "">
					<cfset url.textareadata = ListChangeDelims(url.textareadata, "#chr(13)##chr(10)#", ",")>
				</cfif>
				<td>
					<textarea ID="itemList" NAME="itemList"  ROWS="10" COLS="30" STYLE="width:250">#url.textareadata#</textarea>
				</td>
			</tr>
			<tr>
				<td>
					<input TYPE="Hidden" NAME="itemListVal" ID="itemListVal" VALUE="#form.ListVal#">
					<input TYPE="Hidden" NAME="hiddenForm" ID="hiddenForm" VALUE="#form.hiddenForm#">
					<input TYPE="Hidden" NAME="thisObject" ID="thisObject" VALUE="#currObj#">
					<input type="hidden" name="productGroupLevelTypes" ID="productGroupLevelTypes" value="#url.productGroupLevelTypes#">
				</td>
			</tr>
			<tr>
				<td ALIGN="center">
					<!---  57142 GM request for partial match & exact match--->
					<cfif (url.passObj eq "product") or (url.passObj eq "ProductGroup")>
						<b>Find using:</b>
						<cfif application.appSettingsget.getExact_List_Matching_On() eq "0">
							<input type="radio" name="match_type" value="partial"  <cfif application.appSettingsget.getExact_List_Matching_On() eq "0">checked</cfif>>Partial match
						</cfif>
						<input type="radio" name="match_type" value="exact" <cfif application.appSettingsget.getExact_List_Matching_On()>checked</cfif>>Exact match<br><br>
					<cfelse>
						<input type="hidden" name="match_type" value="">
					</cfif>
					<CF_button
						button_name		=	""
						button_caption	=	"Submit"
						button_action	=	"submitForm(document.all.comCreateListForm);"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight		=	"bold"
					>
				</td>
			</tr>
			<tr>
				<td>
					<HR>
						<span ID="searchItemLabel" STYLE="color:red;font-style:italic;font-weight:bold">Alphanumeric characters only: [A-Z] and [0-9]</span><!--- The only valid characters are Numeric and Alpha --->
					<HR>
				</td>
			</tr>

		</table>
	  	<input type="hidden" name="passedItemList" id="passedItemList" value="" >
   		<input type="hidden" name="passedPrgList" id="passedPrgList" value="" >
	</FORM>
	</cfoutput>

    <script>
        function submitForm(theForm) {
            var varsOnly;
            var matched;
            var oElem = jQuery( "textarea[name=itemList]").val(); // ChromeFix ::  OLD Syntax is IE only -> theForm.item("itemList");
        var oPrg =  jQuery( "textarea[name=itemList]"); // ChromeFix :: Old Syntax did not work...although this var is not used ?
            var currItemList = oElem;
            var matchPattern = new RegExp("\\s*(.*)\\s*", "g");
            var itemCollection= new Array();
            var prgCollection= new Array();
            var count = 0;
        var prgCount = 0;
        // alert(currItemList);
            matched = matchPattern.exec(currItemList);
            while ( RegExp.$1 != '') { // ChromeFix :: While loop never completed in Chrome -> OLD: while ((matched = matchPattern.exec(currItemList)) != null) {
                varsOnly = RegExp.$1;
                itemCollection[count++] = removeNull(trim(varsOnly));
                prgCollection[prgCount++] = "\'" + removeNull(trim(varsOnly)) +"\'";
                matched = matchPattern.exec(currItemList);  // ChromeFix :: Set matched inside loop
            }
            //document.all.getElementById("itemArray").value = itemCollection;
            oElem = document.getElementById("passedItemList");
            oElem.value = itemCollection;
            oPrg = document.getElementById("passedPrgList");
            oPrg.value = prgCollection;
            comCreateListForm.submit();
        }
    </script>

    <cfinclude template="/common_files/focus.cfm">
</body>
</html>
