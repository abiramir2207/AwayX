<!--- 
FILE: 		ERPDocuments.cfm
FILENAME:   DEDUCTIONS/Attachments/ERPDocuments.cfm									
CREATED:  	1/06/2012 MWS

FUNCTIONALITY: Document Viewer For Documents generated (and stored)
				in client ERP.  App Setting xxxx contains URL for Docs.
				If appsetting is null or empty, this feature is not available.
--->
<html xmlns="http://www.w3.org/1999/xhtml" >
<head>
    <title>OnBase Document Viewer</title>
</head>
<body onload="checkDocumentList();">
<cfsilent>

<!---form<br><cfdump var="#form#"/><br>url<br><cfdump var="#url#"/>--->
<cfparam name="Form.searchType" default="" >
<cfparam name="URL.searchType" default="#Form.searchType#" >
<cfparam name="form.Deduction_Id" default="" >
<cfparam name="Url.Deduction_Id" default="#form.Deduction_Id#" >

<cfscript>
	appSettings = application.appsettingsGet;
	
	//oDeductionDAO 	= createObject('component','mvc.Models.Deduction.DeductionDAO');  
	oDeductionDAO 	= createObject('component','components.deduction.DeductionManager');
	ostring 	= createObject('component','components.util.string');
	arrOptions = ArrayNew(1);
	noDocResponse = '';
	qDeduction 	= oDeductionDAO.getDeduction(Url.Deduction_Id);
	batchDate = dateFormat(qDeduction.DD_Accounting_Date,'MM/DD/YYYY');
	//if no dd refernce, then the user can not search by cust so default to check
	if(qDeduction.dd_reference EQ ""){
		URL.searchType = "check";
	}
	
	if(URL.searchType eq "check"){
		urlParams	= '?qs=LoginID|SessionID|148|Remittance%20Num=#qDeduction.DD_CHECK_NUMBER#,Batch%20Date=#batchDate#';
	}
	else if(URL.searchType eq "cust"){ //cust search
		urlParams	= '?qs=LoginID|SessionID|149|Customer%20Doc%20Num=#qDeduction.dd_reference#';
	}
	
</cfscript>

<cfif URL.searchType neq "">
	<!--- Call the ERP Server and get list of Docs for this deduction --->
	<cfhttp method="GET" url="#appSettings.getErpDeductionDocPath()#documents/GetDocumentList.aspx#urlParams#" timeout="30" />
	<!--- if we get a good response parse it --->
	<cfif cfhttp.FileContent NEQ 'Connection Timeout'>
		<!--- get array of <option> tags from doc --->
		<cfset arrOptions = reMatchNoCase("<option\b[^>]*>(.*?)</option>", cfhttp.fileContent)>
		<!--- if there are any build select box --->
		<cfif isArray(arrOptions) AND arrayLen(arrOptions) GT 0>
			<!--- The array will get used in the FORM DocumentList dropdown below --->
		<cfelse><!--- else no documents returned show message and log --->
			<cfset arrOptions = arraynew(1) />
			<cfsavecontent variable="noDocResponse">
				<h3>There are no documents in the system that match your request.</h3>
				<cfoutput>
				<h3>Response:</h3>
				<!---#cfhttp.fileContent#--->
				</cfoutput>
			</cfsavecontent>
			<cflog text="ERP Did not return any documents from GetDocumentList #urlParams#" >
		</cfif>
	<cfelse><!--- log and display error --->
		<cfsavecontent variable="noDocResponse">
			<h3>The system did not respond.  Please try again later.</h3>
		</cfsavecontent>
		<cflog text="ERP Error: #cfhttp.FileContent# :: GetDocumentList.aspx#urlParams#" >
	</cfif>
</cfif>
<!--- An entire html doc is returned.  Parse doc to get the <option> tags.
	 use option tags in entiretey in out own select box. results are not gauranteed
	 so check for valid results along the way --->
</cfsilent>
<table width="100%" border="0" cellspacing="0" cellpadding="0">
    <tr>
        <td width="30%">
        	<form name="frmDeductionDocs" action="ERPDocuments.cfm">
			<!--- onChange() we use javascript to load iFrame ErpDocView with ErpDocView.cfm where we get the PDF --->
			<div <cfif arrayLen(arrOptions) EQ 0>style="visibility:hidden"</cfif> >
	        	<select name="DocumentList" id="DocumentList" size="1" onchange="callGetDoc()">
				<cfloop array="#arrOptions#" index="s" >
					<cfoutput>#s#</cfoutput> 
				</cfloop>
				</select>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp
			</div>
        </td>
		
        <td width="70%">
        	<table border="0" cellspacing="0" cellpadding="0">
			    <tr>
			        <td><!--- Show this when no search type has been selected or if the current search is Cust --->
			        	<cfif URL.searchType eq "cust" OR URL.searchType eq "">
							<cf_button name="searchErpView" 
				  			   button_type="javascript_link" 
				  			   button_caption="Search By Check Number" 
				  			   button_action="SelectSubmit('check');">
							<!---<input type="hidden" value="check" name="searchType" id="searchType" />--->
						</cfif>
			        </td>
					<!--- Formatting Hack since cf_button is a pain --->
					<cfif URL.searchType eq "cust" OR URL.searchType eq "">
					<td>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp</td>
					</cfif>
			        <td>
			        	<!--- We can only run doc num searches if we have a doc num --->
						<cfif qDeduction.dd_reference NEQ "">
							<cfif URL.searchType eq "check" OR URL.searchType eq "">
								<cf_button name="searchErpView" 
					  			   button_type="javascript_link" 
					  			   button_caption="Search By Customer Number" 
					  			   button_action="SelectSubmit('cust');">
								<!---<input type="hidden" value="cust" name="searchType" id="searchType" />--->
							</cfif>
						</cfif>
			        </td>
			    </tr>
			</table>

				<input type="hidden" value="" name="searchType" id="searchType" />
				<cfoutput>
					<input type="hidden" name="Deduction_Id" id="Deduction_Id" value="#Url.Deduction_Id#" />
				</cfoutput>
			</form>
        </td>
    </tr>
</table>
<!--- if we had an issue in the GetDocumentList.aspx http call, it is saved here --->
<cfoutput>#noDocResponse#</cfoutput>
<!---<cfoutput>#appSettings.getErpDeductionDocPath()#documents/GetDocumentList.aspx#urlParams#</cfoutput>--->
<iframe onresize="reSize()" id="ErpDocView" name="ErpDocView" src="blank.cfm?loader=0" frameborder="0" marginwidth="0" marginheight="0"  width="100%" ></iframe>

<cfoutput>
	<script>
		//this gets called from checkDocumentList() and DocumentList.onchange
		function callGetDoc()
		{
			//display the Loader spinner
			window.open("blank.cfm?loader=1", "ErpDocView", "", "true");
			//call getDoc()
			setTimeout("getDoc();", 500);
		}
		function getDoc()
		{
			//0 is the "select a doc" option
			if(document.getElementById("DocumentList").value != 0){
				//populate the iFrame.  ErpDocView.cfm calls the ERP for the selected doc
				window.open("ErpDocView.cfm?Deduction_Id=#Url.Deduction_Id#&qs=" + document.getElementById("DocumentList").value, "ErpDocView", "", "true");
			}
			else{
				window.open("blank.cfm?loader=0", "ErpDocView", "", "true");
			}
		}
		//this get called from onLoad()
		function checkDocumentList()
	    {
			<cfif isArray(arrOptions) AND arrayLen(arrOptions) GT 0>
				var documentList = document.getElementById("DocumentList");
				documentList.selectedIndex = 0;
				callGetDoc();
			</cfif>
	       /* if (documentList.length == 1)
	        {
	            documentList.selectedIndex = 0;
	            callGetDoc();
	        }*/
	    }
		//resubmit form.  we need to toggle the searchType
		function reSubmit(){
			var searchType = document.getElementById("searchType");
			if(searchType.value == 'cust'){	
				searchType.value = 'check';
			}
			else{
				searchType.value = 'cust';
			}
			callGetDoc();
		}
		
		//submit form.  set searchtype from button selection first
		function SelectSubmit(s){
			var searchType = document.getElementById("searchType");
			searchType.value = s;
			frmDeductionDocs.submit();
		}
		function reSize()
			{
				document.getElementById('ErpDocView').style.height = document.body.clientHeight-60;
			}
		reSize();
	</script>
</cfoutput>
</body>

