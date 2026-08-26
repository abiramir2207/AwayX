<!---
Filename:		index.cfm
Description:	This file is the parent include of the general search tool
Author:			Eduardo Vazquez
Date Created:	12/3/2001
--->

<!--- The purpose of this file is to act as a framework for easily creating search tools --->

<!--- VARIABLES --->
<!---
	DESTINATION_PAGE 		: location of the file to submit the results of the search selection if any, otherwise the location of the next page a process
	ID						: a variable to hold an ID for any use later on in the process, maybe on the destination page
	SELECTION_OPTION		: tells the code to put select boxes,radio buttons or nothing next to each returned result
								OPTIONS:
									"CHECK" = checkbox
									"RADIO" = radio button
									"NONE" = nothing
 	RESULT_CODE_LOCATION	: the location of the code that returns the search reults
	POPUP_CODE_LOCATION 	: this variable holds the name of the code within in the popup that is the search form,
								  it is has to be the name of the filename from "RESULT_CODE_LOCATION" with popup appended to it
 --->

<!--- "initialize" variables --->
<CFPARAM NAME="Attributes.existing_hiddenidlist"	DEFAULT="">
<CFPARAM NAME="Attributes.destination_page" 		DEFAULT="">
<CFPARAM NAME="Attributes.id" 						DEFAULT="">
<CFPARAM NAME="Attributes.selection_option" 		DEFAULT="">
<CFPARAM NAME="Attributes.result_code_location" 	DEFAULT="">
<CFPARAM NAME="Attributes.popup_code_location" 		DEFAULT="">
<CFPARAM NAME="FORM.GoToDestinationPage" DEFAULT="0">
<CFPARAM NAME="FORM.FormSubmissionIndicator" DEFAULT="0">


<!--- this is a list of the required variables --->
<CFSET RequiredVariables = "selection_option,result_code_location">

<!--- convert all the supplied variables to lowercase and while at it check for data--->
<CFLOOP INDEX="VariableName" LIST="#structkeylist(attributes)#" DELIMITERS=",">
	<CFSET temp = StructUpdate(attributes, VariableName, lcase(evaluate("Attributes.#VariableName#")))>
	<!--- if there is no data in the variable do something--->
	<CFIF len(evaluate("Attributes.#VariableName#")) EQ 0>
		<!--- check for that var name in the required list --->
		<CFIF Listfind(RequiredVariables, lcase(VariableName)) GT 0>
				<CFOUTPUT><FONT SIZE="+2" COLOR="Red">"#VariableName#" NEEDS DATA</FONT></CFOUTPUT>
			<CFBREAK>
		</CFIF>
	</CFIF>
</CFLOOP>

<!--- if all is fine lets move on --->

<!--- get the filename from the path supplied --->
<!--- check the supplied path for a /, if none the file is local else parse it for the filename --->
<CFIF find("/", Attributes.result_code_location, 1) GT 0>
	<!--- need to parse it for a filename --->
	<CFSET actionpagename = listgetat(Attributes.result_code_location, listlen(Attributes.result_code_location))>
<CFELSE>
	<!--- The supplied filename is local --->
	<CFSET actionpagename = Attributes.result_code_location>
</CFIF>

<!--- save the location of the popup --->
<CFSET Attributes.popup_code_location = listgetat(actionpagename, 1, ".") & "_popup" & "." & listgetat(actionpagename, 2, ".")>


<!--- checkbox or radio or nothing --->
<CFSET GST_SELECTION_OPTION  = Attributes.selection_option>

<CFPARAM NAME="form.newidlist" DEFAULT="">
<CFPARAM NAME="FORM.SelectedIDList" DEFAULT="">
<CFSET Attributes.newidlist = form.newidlist>

<CFIF len(Attributes.existing_hiddenidlist) GT 0 and FORM.FormSubmissionIndicator EQ 0>
	<CFSET FORM.SelectedIDList	= Attributes.existing_hiddenidlist>
	<CFSET FORM.hiddenidlist		= Attributes.existing_hiddenidlist>
</CFIF>

<!--- the list that matters --->
<CFIF isdefined("form.hiddenidlist")>

	<CFLOOP INDEX="ID" LIST="#FORM.HIDDENIDLIST#">
		<!--- add it --->
		<CFIF listfind(FORM.SelectedIDList,ID) AND NOT listfind(FORM.NewIDList,ID)>
			<CFIF Attributes.selection_option EQ "radio">
				<CFSET FORM.NewIDList = "">
			</CFIF>

			<CFSET FORM.NewIDList = listappend(FORM.NewIDList,ID)>
		</CFIF>

		<!--- delete it --->
		<CFIF NOT listfind(FORM.SelectedIDList,ID) AND listfind(FORM.NewIDList,ID)>
			<CFSET FORM.NewIDList = listdeleteat(FORM.NewIDList,listfind(FORM.NewIDList,ID))>
		</CFIF>
	</CFLOOP>
</CFIF>


<!---  Build the form i need --->
<FORM ACTION="<CFOUTPUT>#getfilefrompath(CGI.CF_TEMPLATE_PATH)#</CFOUTPUT><cfif len(cgi.query_String) GT 0>?<cfoutput>#cgi.Query_String#</cfoutput></cfif>" METHOD="post" NAME="GeneralSearchToolForm" ID="GeneralSearchToolForm">
<TABLE ALIGN="center">
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"search"
				button_action	=	"javascript: showSearchFormWindow();"
				button_type		=	"link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>

		<CFIF len(Attributes.destination_page) GT 0>
		<TD>
			<!--- <B><FONT SIZE="3" COLOR="RED">[</FONT><A HREF="javascript: showSearchFormWindow()" STYLE="cursor:pointer;">Search Again</A><FONT SIZE="3" COLOR="RED">]</FONT></B><BR> --->
				<CF_button
					button_name		=	""
					button_caption	=	"continue"
					button_action	=	"javascript: document.all.GOTODESTINATIONPAGE.value = 1; document.all.GeneralSearchToolForm.submit();"
					button_type		=	"link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
				<!--- <B><FONT SIZE="3" COLOR="RED">[</FONT><A HREF="javascript: document.all.GOTODESTINATIONPAGE.value = 1; document.all.GeneralSearchToolForm.submit();" STYLE="cursor:pointer;">Continue</A><FONT SIZE="3" COLOR="RED">]</FONT></B> --->
		</TD>
		</CFIF>
	</TR>
</TABLE>
<br>
	<INPUT NAME="GST_EXTERNALID" TYPE="Hidden" VALUE="<CFOUTPUT>#Attributes.id#</CFOUTPUT>">

	<!--- if this variable is not found by the javascript then it is the first time the code is run --->
	<INPUT NAME="FORMSUBMISSIONINDICATOR" TYPE="Hidden" VALUE="1">

	<!--- if this variable is high then the code knows to process the NewIDList One More time then move onto the destination page --->
	<INPUT NAME="GOTODESTINATIONPAGE" TYPE="Hidden" VALUE="0">


	<CFOUTPUT>
		<!---
			Loop through the variables in the list of structure:FORM; excpetions : FORM.STARTROW,FORM.FIELDNAMES; form.SELECTEDIDLIST
		--->
		<CFLOOP INDEX="variableName" LIST="#structkeylist(FORM)#">
			<CFIF NOT variablename EQ "SELECTEDIDLIST" AND NOT variablename EQ "FIELDNAMES" AND NOT variablename EQ "HIDDENIDLIST" AND NOT variablename EQ "FormSubmissionIndicator"  AND NOT variablename EQ "GoToDestinationPage" AND NOT variablename EQ "GST_ExternalID">
				<INPUT NAME="#variableName#" TYPE="Hidden" VALUE="#evaluate("FORM.#variableName#")#">
			</CFIF>
		</CFLOOP>
	</CFOUTPUT>

	<!---
		if this form element does not exist then page is being viewd for the first time; create defaults
		because after first search; they will always exist and this code wont run anymore
	--->
	<CFIF FORM.FormSubmissionIndicator EQ 0>
		<INPUT NAME="STARTROW" TYPE="Hidden" VALUE="1">
		<INPUT NAME="FROMPAGE" TYPE="Hidden" VALUE="1">
	</CFIF>

	<CFIF FORM.FormSubmissionIndicator EQ 1 AND FORM.GoToDestinationPage EQ 0>
		<!--- include the result code for display as part of the tag within tag data structure --->
		<CFINCLUDE TEMPLATE="#Attributes.result_code_location#">
	<CFELSE>
		<!--- <DIV ALIGN="center" STYLE="color: blue; font-size: 15pt;">Choose Your Search Criteria</DIV> --->
	</CFIF>
</FORM>






<!---

<TABLE ALIGN="center">
	<TR>
		<TD>
			<CF_button
				button_name		=	""
				button_caption	=	"search"
				button_action	=	"javascript: showSearchFormWindow();"
				button_type		=	"link"
				button_width	=	"100"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
		</TD>

		<CFIF len(Attributes.destination_page) GT 0>
		<TD>
			<!--- <B><FONT SIZE="3" COLOR="RED">[</FONT><A HREF="javascript: showSearchFormWindow()" STYLE="cursor:pointer;">Search Again</A><FONT SIZE="3" COLOR="RED">]</FONT></B><BR> --->
				<CF_button
					button_name		=	""
					button_caption	=	"continue"
					button_action	=	"javascript: document.all.GOTODESTINATIONPAGE.value = 1; document.all.GeneralSearchToolForm.submit();"
					button_type		=	"link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
				<!--- <B><FONT SIZE="3" COLOR="RED">[</FONT><A HREF="javascript: document.all.GOTODESTINATIONPAGE.value = 1; document.all.GeneralSearchToolForm.submit();" STYLE="cursor:pointer;">Continue</A><FONT SIZE="3" COLOR="RED">]</FONT></B> --->
		</TD>
		</CFIF>
	</TR>
</TABLE>

 --->







	<!--- if this variable is high then submit the for to the destination page --->

	<CFIF FORM.GoToDestinationPage EQ 1>
		<CFOUTPUT>
			<FORM ACTION="#Attributes.destination_page#" METHOD="post" NAME="finalForm" ID="finalForm">
				<INPUT NAME="GST_FinalSubmission" TYPE="Hidden" VALUE="1">
				<INPUT NAME="GST_ExternalID" TYPE="Hidden" VALUE="#Attributes.id#">
				<INPUT NAME="NEWIDLIST" TYPE="Hidden" VALUE="#FORM.NEWIDLIST#">
			</FORM>
			<SCRIPT>document.all.finalForm.submit();</SCRIPT>
		</CFOUTPUT>
	</CFIF>


<SCRIPT>

	//code to open a new window
	function NewWindow(mypage, myname, w, h, scroll, resize)
	{
		var winl = (screen.width - w) / 2;
		var wint = (screen.height - h) / 2;
		winprops = 'height='+h+',width='+w+',top='+wint+',left='+winl+',scrollbars='+scroll+',resizable='+resize
		win = window.open(mypage, myname.replace(/\s/g, ''), winprops)
		if (parseInt(navigator.appVersion) >= 4) { win.window.focus(); }
	}

	function reSelectOptionsInSearchForm() {
		var arrayofcheckboxestoavoid = new Array()
		var arrayofradiostoavoid = new Array()

		if(document.all.GeneralSearchToolForm.elements.length != 5) {
			donerForm = win.document.all.SearchForm
			for(var x=0; x<donerForm.elements.length; x++){

				//this is current element from the search form
				currentElement = donerForm.elements[x]

				//if the name is not empty
				if(window.currentElement.name != null && window.currentElement.name.length != 0){
					GeneralSearchToolForm_Element = eval('document.all.GeneralSearchToolForm.' + currentElement.name.toUpperCase())
					if(GeneralSearchToolForm_Element){
						switch(currentElement.type){
							//TEXT BOX
							case "text":
								currentElement.value = GeneralSearchToolForm_Element.value
							break;

							//SELECT BOX
							case "select-one":
									theElements = currentElement.options
									for(var e=0; e<theElements.length;e++) {
										if(theElements[e].value == GeneralSearchToolForm_Element.value){
											theElements[e].selected = true;
										}
									}
							break;

							//CHECK BOXES
							case "checkbox":
								checkthisbox = true
								for(var a=0; a<=arrayofcheckboxestoavoid.length;a++){
									if(arrayofcheckboxestoavoid[a] == currentElement.name) {
										checkthisbox = false
										break;
									}
								}

								if(checkthisbox == true){
									arrayofcheckboxestoavoid[arrayofcheckboxestoavoid.length] = currentElement.name;
									objectwithCollection = eval('win.document.all.SearchForm.'+ currentElement.name);
									for(var e = 0; e<objectwithCollection.length; e++){
										if(listfind(GeneralSearchToolForm_Element.value, objectwithCollection[e].value)) {
											objectwithCollection[e].checked = true
										}
									}
								}
							break;

							//RADIO BUTTON
							case "radio":
								checkthisradio = true

								for(var a=0; a<=arrayofradiostoavoid.length;a++){

									if(arrayofradiostoavoid[a] == currentElement.name) {
										checkthisradio = false
										break;
									}
								}

								if(checkthisradio == true){
									arrayofradiostoavoid[arrayofradiostoavoid.length] = currentElement.name;
									objectwithCollection = eval('win.document.all.SearchForm.'+ currentElement.name);
									for(var e = 0; e<objectwithCollection.length; e++){
										if(objectwithCollection[e].value == GeneralSearchToolForm_Element.value) {
											objectwithCollection[e].checked = true
											break;
										}
									}
								}
							break;

							default:
								hiddenFieldName = "00"
						}

					}
				}
			}
		}

	}



	//returns position of value in a list, if not found returns -1
	function listfind(list,value) {
		//initialize value as a string
		value = value + "";

		ValueLocationArray = new Array()
		//FIND ",value,"
		listitemtofind = "," + value + ",";
		offsetforcomma = 1;
		ValueLocationArray[0] = list.indexOf(listitemtofind);

		//FIND ",value"
		listitemtofind = "," + value;
		offsetforcomma = 1;
		ValueLocationArray[1] = list.indexOf(listitemtofind);

		//FIND "value,"
		listitemtofind = value + ",";
		offsetforcomma = 0;
		ValueLocationArray[2] = list.indexOf(listitemtofind);

		//FIND "value"
		listitemtofind = value
		offsetforcomma = 0;
		ValueLocationArray[3] = list.indexOf(listitemtofind);

		for(var x = 0; x< ValueLocationArray.length; x++){
			if(ValueLocationArray[x] != -1) {
				return true
			}
		}
		return false
	}




	//opens search form in a popup
	function showSearchFormWindow() {
		NewWindow(<CFOUTPUT>'#Attributes.popup_code_location#'</CFOUTPUT>, "SearchWindow", '625','450','No', 'No')
	}


	//dynamically create hidden form elements locally from popup
	function transportFormElementsFromPopupToParentPage(){


		var hiddenFieldValue = ""
		var arrayofcheckboxestoavoid = new Array();
		var arrayofradiostoavoid = new Array()

		donerForm = win.document.all.SearchForm
		for(var x=0; x<donerForm.elements.length; x++){

			currentElement = donerForm.elements[x]

			listofselections = ""

			switch(currentElement.type){
				//TEXT BOX
				case "text":
					hiddenFieldName = currentElement.name
					hiddenFieldValue = currentElement.value
				break;

				//SELECT BOX
				case "select-one":
						hiddenFieldName = currentElement.name

						theElements = currentElement.options
						var listofselections = ""
						for(var e=0; e<theElements.length;e++) {
							if(theElements[e].selected){
								listofselections = listofselections + theElements[e].value + ","
								break;
							}
						}
						listofselections = listofselections.substring(0, listofselections.length - 1)

						hiddenFieldValue = listofselections
				break;

				//CHECK BOXES
				case "checkbox":
					hiddenFieldName = currentElement.name

					checkthisbox = true
					for(var a=0; a<arrayofcheckboxestoavoid.length;a++){
						if(arrayofcheckboxestoavoid[a] == hiddenFieldName) {
							checkthisbox = false
							break;
						}
					}

					if(checkthisbox){
						arrayofcheckboxestoavoid[arrayofcheckboxestoavoid.length] = hiddenFieldName


						currentElement = eval('win.document.all.SearchForm.' + hiddenFieldName)
						for(var e = 0; e<currentElement.length; e++){
							if(currentElement[e].checked) {
								listofselections = listofselections + currentElement[e].value + ","
							}
						}
						listofselections = listofselections.substring(0, listofselections.length - 1)
						hiddenFieldValue = listofselections
					}
						if(!checkthisbox) hiddenFieldName = 00

				break;

				//RADIO BUTTON
				case "radio":

					checkthisradio = true

					for(var a=0; a<=arrayofradiostoavoid.length;a++){

						if(arrayofradiostoavoid[a] == currentElement.name) {
							checkthisradio = false
							break;
						}
					}


					if(checkthisradio == true){
						arrayofradiostoavoid[arrayofradiostoavoid.length] = currentElement.name;
						objectwithCollection = eval('win.document.all.SearchForm.'+ currentElement.name);
						for(var e = 0; e<objectwithCollection.length; e++){
							if(objectwithCollection[e].checked){
								hiddenFieldName = objectwithCollection[e].name
								hiddenFieldValue = objectwithCollection[e].value
							}
						}
					}
				break;

				default:
					hiddenFieldName = "00"
			} //end switch


			if(hiddenFieldName != "00"){
				if(eval('document.all.GeneralSearchToolForm.' + hiddenFieldName.toUpperCase()) == null){
					var input =	document.createElement('INPUT');
					input.type = "hidden"
					input.name = hiddenFieldName;
					input.value = hiddenFieldValue;
					document.all.GeneralSearchToolForm.appendChild(input)
					hiddenFieldName = "00";
				}
				else {

					eval('document.all.GeneralSearchToolForm.' + hiddenFieldName.toUpperCase() + '.value="' + hiddenFieldValue + '"')
				}
			}
		}

		//if the search again button is pushed then grab the selected variables in the main form
		switch("<CFOUTPUT>#Attributes.selection_option#</CFOUTPUT>") {

		case "radio":
			if(document.all.GeneralSearchToolForm.SelectedIDList){
				for(var x=0; x<document.all.GeneralSearchToolForm.SelectedIDList.length;x++){
					button = document.all.GeneralSearchToolForm.SelectedIDList[x]
					if(button.checked){

					}
				}
			}
		break;

		}
		win.close();
		document.all.GeneralSearchToolForm.submit()
	}



	//if the form doesnt have any elements then it is the first time the page has loaded so open the form
	function checkFormForData(){

		if(document.all.GeneralSearchToolForm.elements.length == 6) {

			if(!window.inhibitpopup){
				//open popup
				showSearchFormWindow()
			}
			else {
				inhibitpopup = false;
			}
			//if no one objects may the window open in peace
		}
	}

	checkFormForData();

	//resubmit the form with a different sort by
	function newSortBy(newSortBy) {
		//if this page has already been sorted by the new sort then switch the order
		if(document.all.SORTBY.value.toLowerCase() == newSortBy.toLowerCase()){

			switch(document.all.GeneralSearchToolForm.SORTORDER.value.toLowerCase()){
				case "asc":
					document.all.GeneralSearchToolForm.SORTORDER.value = "desc";
				break;

				case "desc":
					document.all.GeneralSearchToolForm.SORTORDER.value = "asc";
				break;

			} //end switch
		}
		//change the sort variable
		document.all.GeneralSearchToolForm.SORTBY.value = newSortBy;
		//start at result page 1
		document.all.GeneralSearchToolForm.FROMPAGE.value = 1;
		document.all.GeneralSearchToolForm.STARTROW.value = 1;
		//submit
		document.all.GeneralSearchToolForm.submit()
	}
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(0==0) {
				for (var i=0;i<document.all.GeneralSearchToolForm.elements.length;i++)
					{
						var e = GeneralSearchToolForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = document.all.GeneralSearchToolForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</SCRIPT>