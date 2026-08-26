<cfsilent>
	<!---
	  * ====================================================================================================
	  *    @File: \billbacks\2020\edit_billback_menu_events.cfm
	  *  @Author: Sharon Harris
	  *    @Date: March 2020
	  *
	  * @Remarks: GM Billbacks - menu functions for Edit Billback page.
	  * 		  Based on FlexDev\Forge\src\com\Billback\Edit\models\BBEditManager.as and
	  *					   FlexDev\Forge\src\com\Billback\Edit\views\pm\BBEditPModel.as
	  *
	  * ====================================================================================================
	--->
	</cfsilent>

	<form class="hidden" name='saveReset' id='saveReset' action='javascript:saveReset();'>
		<input type="hidden" name="bbId" id="bbId"  value="" >
	</form>

	<script>


	// -----------------------------------------------------------------------------
	// -------------------------  LOG MENU -----------------------------------------
	// -----------------------------------------------------------------------------

	/*................. HISTORY ......................*/
	function showHistory() {
		NewWindowTopLeft("/billbacks/common/bb_history.cfm?BBID="+bb.bbheader.billbackidguid, "historyWindow", 800, 600, "yes", "yes");
	}

	/*................. WORKFLOW ......................*/
	function showWorkFlow() {
		// "BB_Workflow.cfm?Billback_ID=#url.Billback_ID#"
		if(bb.bbheader.billbackidguid != '')
		{
			NewWindowTopLeft("/workflow//Billback/BB_Workflow.cfm?Billback_ID="+bb.bbheader.billbackidguid, "workflow", 900, 640, "yes", "yes");
		}	
		else
		{
			alert("The Workflow can be viewed only after saving the Billback!");
		}	
	}

	/*................. EDI DUPLICATE ......................*/
	function showDuplicates() {
		NewWindowTopLeft("/billbacks/common/Billback_Dup_Checker.cfm?Billback_ID="+bb.bbheader.billbackidguid, "duplicates", 800, 600, "yes", "yes");
	}


	// -----------------------------------------------------------------------------
	// -------------------------  COMMUNICATIONS MENU ------------------------------
	// -----------------------------------------------------------------------------


	/*.............. BUSINESS CONSIDERATIONS ...............*/
	function showBizCon() {
		// if (bizConMode){
			// winjscommand = winjscommand+"&MODE="+bizConMode;
		// }
		if(bb.bbheader.billbackidguid != '')
		{
			NewWindowTopLeft("/billbacks/common/BB_Business_Consideration.cfm?EDIT=1&BBID="+bb.bbheader.billbackidguid, "bizConWindow", 900, 600, "yes", "yes");
		}	
		else
		{
			alert("The Business Considerations is available only after saving the Billback!");
		}	
	}

	/*.............. EMAIL FUNCTION ...............*/
	function emailBB() {
		if(bb.bbheader.billbackidguid != '')
		{
			NewWindowTopLeft("/billbacks/common/bb_email_create.cfm?BBID="+bb.bbheader.billbackidguid, "winprint", 900, 600, "yes", "yes");
		}
		else
		{
			alert("The Billback can be Emailed only after it is saved!");
		}	
	}

	/*............ DISCREPANCY REPORT .............*/
	/*.............open BB statement.............*/
	function showBBStatement() {

		// var sBBStatementType = this.oSettings.appSettings.BillBack_Statement_Type;
		var sBBStatementType = "excel-v3";
		var sBBStatementFile = "";

		if ( sBBStatementType ==  'claim-summary' ) {
			sBBStatementFile = 'summaryReport.cfm';						// claim auto print setting is on
		}
		else if ( sBBStatementType == 'pdf-v2' ) {
			sBBStatementFile = 'create_summary_statement.cfm';			// Solo statement type
		}
		else if ( sBBStatementType == 'excel-v3' ) {
			sBBStatementFile = 'xls_statement.cfm';						// GM excel statement
		}
		// else {
			// sBBStatementFile = 'claimsummary_report.cfm';				// Heinz claim summary statement
		// }

		NewWindowTopLeft("/billbacks/"+sBBStatementFile+"?Billback_ID="+bb.bbheader.billbackidguid, "statement", 1030, 600, "yes", "yes");
	}

	/*............. PRINT function .............*/
	function printBB() {
		NewWindowTopLeft("/billbacks/common/bb_printer_friendly.cfm?BBID="+bb.bbheader.billbackidguid, "winPrint", 1000, 600, "yes", "yes");
	}

	/*............. COMPLIANCE REPORT .............*/
	function showComplianceReport() {
		let UploadedBillback = bb.bbheader.uploadedbillback;
		NewWindowTopLeft("/billbacks/capture/EDIDownload.cfm?Billback_ID="+bb.bbheader.billbackidguid+ "&Type=" + UploadedBillback, "winDuplicate", 1000, 600, "yes", "yes");
	}

	// -----------------------------------------------------------------------------
	// -------------------------  ACTIONS MENU -------------------------------------
	// -----------------------------------------------------------------------------

	/*................	ADJUST Billback	................*/
	function adjustBillback() {
		// TODO What should the parameters be???
		// 	var winjscommand:String = "/billbacks/common/BB_Adjust_Business_Consideration.cfm?EDIT=1&mode=11&BBID="+this.billback.bbHeader.billbackIDGUID+"&Formname=flex&FlexAppName="+currentAppName;
		NewWindowTopLeft("/billbacks/common/BB_Adjust_Business_Consideration.cfm?EDIT=1&mode=11&BBID="+bb.bbheader.billbackidguid, "bizConWindow", 900, 600, "yes", "yes");
	}

	/*................	BUDGETS ........................*/
	function showBudget() {
		NewWindowTopLeft("/billbacks/APPROVAL/advanced_budget_billback.cfm?Billback_ID="+bb.bbheader.billbackidguid, "winBudget", 900, 600, "yes", "yes");
	}

	/*................	COPY ...........................*/
	function copyBillback() {
		// TODO - how to handle remote invoker with result and fault handlers???
		//console.log(bb);
		show_loader('Copying Billback...');
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	method: "copyBillbackJSON",
									billbackIDInt: bb.bbheader.billbackidint,
									userId: <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>
								}
						,success: function (obj) {
							//console.log(obj);
							$("div.loader").hide();
							parent.parent.create_tab( obj.bbheader.billbackidint, obj.bbheader.bbcode );

						}
						,error: function (data) {
							alert('An error occurred.  ' + JSON.stringify(data) );
						}
						,type: "post"
						,url: "/mvc/Models/Billback/BillbackEditManager.cfc"
			});

	}

	/*................	DELETE ...........................*/
	function deleteConfirm() {
		let confirmdelete = confirm("Do you really want to delete the Billback?");
		if (confirmdelete == true) {

		show_loader('Deleting Billback...');
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	method: "checkBBEligibleForDeleteJSON",
									userId: <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>,
									billbackList: bb.bbheader.billbackidint
								}
						,success: function (obj) {
							//console.log(obj);
							$("div.loader").hide();
							parent.parent.closeIFrame( 'tab' + obj.bbheader.bbcode );

						}
						,error: function (data) {
							alert('An error occurred.  ' + JSON.stringify(data) );
						}
						,type: "post"
						,url: "/mvc/Models/Billback/BillbackManager.cfc"
			});

		}
	}

	/*................	RE-INTERFACE ...........................*/
	function reInterface() {
		show_loader('Updateing Billback for Re-interface...');
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	method: "setBBForReinterfaceJSON",
									billbackIDInt: bb.bbheader.billbackidint
								}
						,success: function (obj) {
							//console.log(obj);
							bb.bbheader = obj;
							show_billback();	// in edit_billback_events.cfm
							$("div.loader").hide();


						}
						,error: function (data) {
							alert('An error occurred.  ' + JSON.stringify(data) );
						}
						,type: "post"
						,url: "/mvc/Models/Billback/BillbackManager.cfc"
			});
	}


	/*............. RESET .............*/
	function showBBReset() {
		// TODO - need to do anything like this?
		// if (ExternalInterface.available)
				// ExternalInterface.addCallback("bbDisagreed", bbDisagreed);
			// var winjscommand:String = "/Billbacks/common/BB_DisagreeFlx.cfm?bbReset=1&BBID=" + this.billback.bbHeader.billbackIDGUID + "&userID=" + this.oSettings.userId + "&source=flexBB" + "&FlexAppName="+currentAppName + "&IsBillbackApproved=1";

		NewWindowTopLeft("/Billbacks/common/BB_DisagreeFlx.cfm?bbReset=1&BBID="+bb.bbheader.billbackidguid+ "&userID=<cfoutput>#request.AccessStructure.User_ID#</cfoutput>&source=AgGridBB&IsBillbackApproved=1&FlexAppName=cfbbedit&parentName="+window.name, "bbDisagreeWindow", 900, 600, "yes", "yes");

		//http://mwsdev.com/Billbacks/common/BB_DisagreeFlx.cfm?bbReset=1&BBID=C14D3DDE-2492-4D65-B0BF-2DA1CC5FA714&userID=&source=AgGridBB&FlexAppName=BillbackMain&IsBillbackApproved=1
	}

	function saveReset() {
		bb.bbheader.status.id = 1;
		bb.bbheader.status.abbreviation = "WIP";
		bb.bbheader.status.description = "Work In progress";
		bb.bbheader.requestapproval.fullname = "";
		bb.bbheader.requestapproval.id = "";
		bb.bbheader.requestapproval.idint = 0;
		show_billback();	// in edit_billback_events.cfm
	}

	/*............. REVERSE BILLBACK .............*/
	function reverseBB() {

		NewWindowTopLeft("/billbacks/common/BB_Business_Consideration.cfm?EDIT=1&MODE=11&BBID="+bb.bbheader.billbackidguid, "bizConWindow", 900, 600, "yes", "yes");
		//	/billbacks/common/BB_Business_Consideration.cfm?EDIT=1&BBID=616699EB-BD71-4DC9-9D5E-28A117CEC599&MODE=11

		// reverseBillback       1160762   6B5884CB-19B9-E720-22ADE5291257DFEC
		$.ajax({
						async: true
						,dataType: 'json'
						,data: { 	method: "reverseBillbackJSON",
									billbackIDInt: bb.bbheader.billbackidint,
									userId: <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>
								}
						,success: function (obj) {
							//console.log(obj);
							bb.bbheader = obj.bbheader;
							show_billback();	// in edit_billback_events.cfm
							$("div.loader").hide();
							//bb.bbheader.notacknowledged = 0;

						}
						,error: function (data) {
							alert('An error occurred.  ' + JSON.stringify(data) );
						}
						,type: "post"
						,url: "/mvc/Models/Billback/BillbackManager.cfc"
			});
	}

	/*................	SUM BY ........................*/
	function sumBy() {

		NewWindow("/billbacks/2020/Sum_By.cfm?EDIT=1&MODE=11&BBID="+bb.bbheader.billbackidguid, "sumBy", 620, 420, "yes", "yes");
	}
	// -----------------------------------------------------------------------------
	// -------------------------  DOCUMENTS MENU -------------------------------------
	// -----------------------------------------------------------------------------

	/*.....................	UPLOAD .....................*/
	function uploadAndAddDocs() {
		// NewWindowTopLeft("/common_files/documents/create_multiple_document_details.cfm?BBID="+bbid, "winUpload", 810, 600, "yes", "yes");
		NewWindow("/common_files/documents/upload_mass_documents.cfm?BBID="+bb.bbheader.billbackidguid,"winUpload","600","300","yes","yes");
	}


	/*.....................	SEARCH .....................*/
	function searchAndAddAndDeleteDocs() {
		NewWindow("/billbacks/capture/Attachments_Form.cfm?BBID="+bb.bbheader.billbackidguid,"winSearch","600","810","yes","yes");
	}

	/*.....................	VIEW .....................*/
	function openDocAttachment(fileName) {
		let fileURL = `/getDocument.cfm?filepath=data_files/uploaded/documents/uploaded_doc/${escape(fileName)}`;
		NewWindow(fileURL);
	}

	function buildViewDocsMenu() {
		if (bb.bbheader.billbackidint){
			$.ajax({
				url: "/mvc/Models/Billback/BillbackManager.cfc"
				, type: "POST"
				, async: true
				, dataType: "json"
				, data: {
					method: "getBillbackAttachmentList",
					returnformat: 'json',
					billbackIDInt: bb.bbheader.billbackidint,
					userId: <cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>
				}
			})
			.then(data => {
				// selector for view menu item
				let menuViewDocs = $("div#searchSection div.menuArea div nav.nav ul.menu li.menu-item.has-children ul.sub-menu li.menu-item.has-children ul.sub-menu li.menu-item.has-children ul.sub-menu");

				// loop over data.uniqueFileName array and create a link like above and append to css selector.
				let filesListHTML = '';
				data.uniqueFileName.forEach(filenname => {
					filesListHTML += `<li class="menu-item"> <a class="" href="javascript:openDocAttachment('${filenname}')"> ${filenname} </a> </li>`;
				});
				// if files exist add to view
				filesListHTML.length
					? menuViewDocs.html(filesListHTML)
					: '';
			})
			.fail(data => {
				$("div.loader").hide();
				alert('An error occurred.  ' + JSON.stringify(data));
			});
		}
	}

	</script>
