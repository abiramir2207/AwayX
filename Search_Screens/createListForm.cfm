<!-----------------------------------------------------------------------------

FILE NAME:		createListForm.cfm
DESCRIPTION:	Used for create list functionality inside the Add group functionality
				in Planning groups
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

			Anand Rao	20-Nov-2014

------------------------------------------------------------------------------>

<html>
<head>
<title>Create List Form</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
	<cfparam NAME="form.ListVal" 	DEFAULT="">
	<cfparam name="form.passObj" 	DEFAULT="">
	<cfparam name="form.hiddenForm" DEFAULT="">
	<cfparam name="form.GroupLevelID" default="">
	<cfparam name="currObj"			default="" >
	<cfparam name="url.textareadata" default="">
	<cfparam name="url.passObj"		 default="">
	<cfparam name="url.passForm"	 default="">
	<cfparam name="url.GroupLevelID" default="">

	<script src="/Common_Files/createList.js"  language="JavaScript"></script>

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
	<cfif isDefined("url.GroupLevelID") and URL.GroupLevelID NEQ "">
		<cfset form.GroupLevelID = URL.GroupLevelID>
	</cfif>

	<CFSET objHandle = CreateObject("component", "components.general.Create_List")>
	<cfoutput>
	<BR>
	<FORM action="validateInput.cfm" METHOD="post" NAME="comCreateListForm" ID="comCreateListForm" STYLE="DISPLAY:INLINE" target="_self">
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
					<input type="hidden" name="GroupLevelID" ID="GroupLevelID" value="#url.GroupLevelID#">
				</td>
			</tr>
			<tr>
				<td ALIGN="center">
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

    <cfinclude template="/common_files/jQuery.cfm">

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
		oElem = document.getElementById("passedItemList");
            oElem.value = itemCollection;
            oPrg = document.getElementById("passedPrgList");
            oPrg.value = prgCollection;
            comCreateListForm.submit();
        }
    </script>

</body>
</html>
