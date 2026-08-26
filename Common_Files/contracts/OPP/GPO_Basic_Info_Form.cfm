
<cfsilent>
<!---
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
   Template: /Common_Files/contracts/OPP/GPO_Basic_Info_Form.cfm
   Author: Mark Saunderss
   Date: 3/6/2019
 
   Usage: basic Info module for One Page Program Creation.  Custom feature.
   		  Called from  /Common_Files/contracts/OPP/GPO_One_Page_Programm.cfm
       
xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx 
--->
</cfsilent>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<!--- ================================== START/END DAte Logic ======================================= --->
<cfset startDateDisabled = 0 />
<cfset EndDateDisabled = 0 />

<cfscript>
	isCPA = 'hidden';
	oOPP		= CreateObject("component", "mvc.Models.Program.OnePageProgramManager");
	qGetParentPerf = oOPP.getPerfReqs(variables.ContractMainID,'parentChild');
	qGetAcutePerf = oOPP.getPerfReqs(variables.ContractMainID,'acute');
	if(GetDiscountIdentifier.Discount_Identifier_Number == 'CPA'){
		isCPA = '';
		if(qGetParentPerf.recordcount == 0){
			oOPP.updPerfReq(1,'parentChild',variables.ContractMainID);
			qGetParentPerf = oOPP.getPerfReqs(variables.ContractMainID,'parentChild');
		}
		if(qGetAcutePerf.recordcount == 0){
			oOPP.updPerfReq(3,'Acute',variables.ContractMainID);
			qGetAcutePerf = oOPP.getPerfReqs(variables.ContractMainID,'acute');
		}
	}
	
</cfscript>

<!--- ================================== START/END DAte Logic ======================================= --->

<cfoutput>
<FORM ACTION="GPO_One_Page_Program.cfm?CID=#EncrypCID#" METHOD="post" NAME="BasicInfoForm" id="BasicInfoForm">
<!--- =================================================================================================================================================================== --->
 <h5 class="sectionHeader">BASIC INFO</h5>
    <div class="flex sectionContents text-xs">

        <div class="flex-column ml-4">
            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">#application.returned_customer_setting.Program_Number_Label#:</label>
                <span class="font-semibold pl-1 table-cell">#FORM.Contract_Number#</span>
            </div>
            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">#application.returned_customer_setting.reference_number_label#:</label>
                <span class="table-cell"><INPUT type="text"MAXLENGTH="200" name="Contract_Reference_Number" size="15" VALUE="#FORM.Contract_Reference_Number#" size="25" class="border mb-1 pl-1"></span>
            </div>
			<div class="table-row">
				<cfif isGPO EQ 1>
					<label class="opacity-75 pr-3 table-cell text-right">GPO Contract Name:</label>
				<cfelse>
					<label class="opacity-75 pr-3 table-cell text-right">CPA Title:</label>
				</cfif>
                <span class="table-cell"><INPUT type="text" MAXLENGTH="200" NAME="Contract_Title" VALUE="#FORM.Contract_Title#" size="50" class="border mb-1 pl-1"/> </span>
            </div>

            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">Start Date:</label>
                <span class="table-cell"><input type="text" id="Contract_start_date" name="start_date" class="date border mb-1 pl-1" VALUE="#FORM.start_date#" size="8"></span>
            </div>
            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">End Date:</label>
                <span class="table-cell"><input type="text" id="Contract_end_date" name="end_date" class="date border mb-1 pl-1" VALUE="#FORM.end_date#" size="8"></span>
            </div>
            <div class="table-row">
                <label class="opacity-75 pr-3 table-cell text-right">Incremental $ Sales:</label>
                <span class="table-cell"><INPUT type="text" MAXLENGTH="200" NAME="Incremental_Sales" size="15" VALUE="#FORM.Incremental_Sales#" class="border mb-1 pl-1" data-type="currency"/></span>
            </div>  
            <!---  ==============================
            	Incremental_Sales = Contract_main.Fixed_Rebate_Amount
			 	xxxContract_Main_Aux_Data.reject_Comments   **** 
			==========================================---> 
            <div class="table-row">
                <label class="align-top opacity-75 pr-3 table-cell text-right">Notes:</label>
                <span class="table-cell text-grey italic"><textarea name="notes" rows="3" cols="52" id="notes" class="border pl-1"><cfoutput>#FORM.Notes#</cfoutput></textarea></span>
            </div>
          <!---   <cfdump var="#variables#">
            <cfdump var="#form#"><cfabort> --->
            <cfif CSLGETCONTRACTINFO.CONTRACT_STATUS_TYPE_IDX eq 2>
	            <div class="table-row">
	            	<button type="button" class="button" onclick="selectCRA();return false;">Select CRA</button> 
	            </div>
            </cfif>
            <cfif CSLGETCONTRACTINFO.CONTRACT_STATUS_TYPE_IDX GT 0 AND isGPO EQ 0>
            	<cfoutput>
	            <div class="table-row" #isCPA# >
	            </cfoutput>
	            <label class="align-top opacity-75 pr-3 table-cell text-right">Letters:</label>
	            <span class="table-cell">
	            	<button type="button" class="button" onclick="CreateCpaPDF();return false;">Create End User PDF</button> 
	            	<button type="button" class="button" onclick="CreateCpaDistPDF();return false;">Create Distributor PDF</button> 
	            </span>
	            </div>
            </cfif>                       
        </div>
       <!---  <cfif isGPO EQ 1 and isAdminFee EQ 0>
	        <div class="flex-column ml-32">
			    <div class="table-row">
			    	<button type="button" class="button" onclick="createAdminFeea();return false;">Create Admin Fee</button>
			    </div>
			    <br>
		      <!---   <div class="table-row">
		        	<button type="button" class="button" onclick="selectCRA();return false;">Edit Users To Approve</button>
				</div> --->
	        </div>
    	</cfif> --->
        <!--- CPA has another column set style="height:140px; border-style: solid;border-width: 5px;"--->
        <cfoutput>
        <div class="flex-column ml-32" #isCPA# >
		</cfoutput>
		
			<fieldset class="fieldGroup p-1" style="width:120px">
				<legend>Parent/Child:</legend>
				<div class="table-row">
					<!--- <label class="opacity-75 pr-3 table-cell text-right">Parent/Child:</label> --->
					<input type="radio" name="parentChild" value="1"<cfif qGetParentPerf.Requirement_Name EQ 'Parent'> checked</cfif> class="align-middle"> Parent<br>
					<input type="radio" name="parentChild" value="2"<cfif qGetParentPerf.Requirement_Name EQ 'Child'> checked</cfif> class="align-middle"> Child
				</div>
			</fieldset>
			<fieldset class="fieldGroup mt-3 p-1" style="width:120px">
				<legend>Acute/Non-Acute:</legend>
				<div class="table-row">
					<!--- <label class="opacity-75 pr-3 table-cell text-right">Acute/Non-Acute:</label> --->
					<input type="radio" name="acute" value="1"<cfif qGetAcutePerf.Requirement_Name EQ 'Acute'> checked</cfif> class="align-middle"> Acute<br>
					<input type="radio" name="acute" value="2"<cfif qGetAcutePerf.Requirement_Name EQ 'Non-Acute'> checked</cfif> class="align-middle"> Non-Acute<br>
					<input type="radio" name="acute" value="3"<cfif qGetAcutePerf.Requirement_Name EQ 'N/A'> checked</cfif> class="align-middle"> N/A
				</div>
			</fieldset>
            <div class="table-row">
				<label class="opacity-75 pt-2 table-cell text-left">Bracket Price Override:</label>
			</div>
			<div class="table-row">
				<select name="Override_Price_List_Id" id="Override_Price_List_Id" class="border rounded" style="width: 250px">
					<option value="NULL">Standard Rebate</option>
                </select>
			</div>
        </div>
    </div>
    <!--- =================================================================================================================================================================== --->
    <cfquery name="GetDefaultCurrency" datasource="#application.datasource#">
		SELECT a.CurrencyDefaultOption, b.Currency_Name, b.Currency_Code
		FROM Program_Control_Panel_Options a, Currency b
		WHERE a.CurrencyDefaultOption = b.Currency_ID
			AND ProgramControl_Panel_Options_ID = '#FORM.ProgramType_ID#'
	</cfquery>
    <input name="Currency" type="hidden" value="#GetDefaultCurrency.CurrencyDefaultOption#">
    <INPUT TYPE="hidden" NAME="PaymentCycle" VALUE="#FORM.PaymentCycle#">
    <INPUT TYPE="hidden" NAME="Contract_Number" VALUE="#FORM.Contract_Number#">
	<INPUT TYPE="hidden" NAME="TemplateFiltersId" VALUE="#FORM.TemplateFiltersId#">
	<input type="hidden" name="PerfRequirements" id="PerfRequirements" value="" />
	<input type="hidden" name="NoPerfRequirements" id="NoPerfRequirements" value="" />
	<input type="hidden" name="Dist_Brand_Eligibility" value="1">
	<input type="hidden" name="Quantity" value="<cfif len(Form.Quantity) NEQ 0>#trim(val(Form.Quantity))#<cfelse>0</cfif>">
	<input type="hidden" name="Contract_Quantity_UOM_IDX" value="1">
	<input type="hidden" name="ClaimMechOption" value="0">
	<input type="hidden" value="" name="Effective_Date_for_Price" />
	<input type="hidden" value="" name="Price_Protection_Date" />
	<CF_CRYP type="en" string="#URL.CID#" key="#request.key#">
	<CFIF len(trim(URL.CID)) GT 0><CFSET URL.CID = cryp.value><input type="hidden" name="CID" value="#cryp.value#"><CFELSE><input type="hidden" name="CID" value=""></CFIF>
	<input type="hidden" name="Document_ID" value="contract_create_1_form">

	<!---this code will tell queries.cfm whether to insert or update--->
	<CFIF len(trim(URL.CID)) EQ 0>
		<input type="hidden" name="Query_Type" value="INSERT">
		<input type="hidden" name="ProgramType_ID" value="#FORM.ProgramType_ID#">

	<CFELSE>
		<input type="hidden" name="Query_Type" value="UPDATE">
		<input type="hidden" name="ProgramType_ID" value="#FORM.ProgramType_ID#">
	</CFIF>

	 <cfif FORM.Created_Type neq "">
		<input type="hidden" name="Created_Type" id="Created_Type" value="#FORM.Created_Type#">
	<cfelse>
		<input type="hidden" name="Created_Type" id="Created_Type" value="">
	</cfif>

	<INPUT TYPE="hidden" NAME="On_Release_Contract_Status_Type_IDX" ID="On_Release_Contract_Status_Type_IDX" VALUE="#FORM.On_Release_Contract_Status_Type_IDX#">


	<!--- if the GL is high then use the DB data --->
	<Cfif FORM.Global_GL_Assign_Setting EQ 1>
	<input name="GL_Assignment_ID" type="hidden" value="#FORM.Global_GL_Assign_Choice_Setting#">
	</CFIF>
	<CFIF isdefined("FORM.CONTRACT_RENEWAL_PACKETS_ID")>
		<input name="CONTRACT_RENEWAL_PACKETS_ID" type="hidden" value="#FORM.CONTRACT_RENEWAL_PACKETS_ID#">
	</CFIF>
	<INPUT TYPE="Hidden" NAME="Do_Revise_Copy" value="#form.Do_Revise_Copy#">
	<INPUT TYPE="Hidden" NAME="Program_ID_To_Replicate" value="#Program_ID_To_Replicate#">
	<INPUT TYPE="hidden" NAME="Program_ID" VALUE="#form.Program_ID#" ><!--- D50711 Program Date Changes  --->
	<!---if we are coming from Trade Planner then set variables needed--->
	<cfif isDefined("form.bIsFromTradePlan") and form.bIsFromTradePlan>
		<INPUT TYPE="Hidden" NAME="tpFileName" VALUE="#Form.tpFileName#">
		<INPUT TYPE="Hidden" NAME="bIsFromTradePlan" VALUE="#FORM.bIsFromTradePlan#">
		<INPUT TYPE="Hidden" NAME="tradePlanId" VALUE="#Form.tradePlanId#">
	</cfif>

	<!--- revision indicator --->
	<input name="ISREVISIONOFEXISTINGCONTRACT"	type="hidden" value="#FORM.ISREVISIONOFEXISTINGCONTRACT#">
	<input name="parentStartDate" 				type="hidden" value="#DateFormat(form.parentStartDate,'mm/dd/yyyy')#">
	<input name="checkParentStartDate" 			type="hidden" value="#form.checkParentStartDate#">
	<INPUT name="Limited_Revise" type="hidden" value="#form.Limited_Revise#" >
	<!--- rollover indicator --->
	<input name="IsRollOver" type="hidden" value="#FORM.IsRollOver#">
	<input name="businessSegmentsOn" type="hidden" value="#form.businessSegmentsOn#">
	<input name="Business_Segment_ID" type="hidden" value="#form.Business_Segment_ID#">
	<input name="EZTemplate" type="hidden" value="#getFieldSettings.EZButton_on#">

<!--- Copied Search Sequence Indicators --->
	<INPUT TYPE="hidden" NAME="NewSearchSequence" VALUE="#Form.NewSearchSequence#" >
	<INPUT TYPE="hidden" NAME="suppressProductsDistributors" VALUE="#Form.suppressProductsDistributors#">
	<INPUT TYPE="hidden" NAME="ShowCid" VALUE="1" >
	</cfoutput>
</FORM>
<!--- <CF_button
				button_name		=	"save"
				button_caption	=	"#FORM.button_caption#"
				button_action	=	"confirmCompletion(1, 'save_table');"
				button_type		=	"javascript_link"
				button_width	=	"175"
				button_color	=	"Navy"
				button_tip		=	""
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"> --->

	<!--- 77539 :: Program Basic Info - additional field for reference # START--->
<!--- 	<cfif GetSettings.allow_Reference_2 EQ 1>  
			<TR>
				<TD align="right" nowrap><B><span id="error_Contract_Reference_Number_2"></span>#application.returned_customer_setting.reference_number_2_label#:</B></TD>
				<TD>
				<cfif application.returned_customer_setting.reference_number_2_editable>
				<INPUT MAXLENGTH="200" type="text" name="Contract_Reference_Number_2" size="15" VALUE="#FORM.Contract_Reference_Number_2#">
				<cfelse>
				<INPUT MAXLENGTH="200" type="text" size="15" VALUE="#FORM.Contract_Reference_Number_2#" style="color:silver; border:1px solid silver;" disabled>
				<INPUT MAXLENGTH="200" type="hidden" name="Contract_Reference_Number_2" size="15" VALUE="#FORM.Contract_Reference_Number_2#">
				</cfif>
				</TD>
			</TR>
	</cfif> --->
	<!--- 77539 :: Program Basic Info - additional field for reference # END--->
		<!----Display legacy id if it's on--->

		<!--- <cfif appSettings.getView_Legacy_ID() EQ 1>
			<cfset variables.legacyIDLabel 	= labelComp.GetGeneralLabels('Legacy ID').General_Labels_Label />
			<cfif FORM.legacy_id eq "NULL">
					<cfset FORM.legacy_id = "">
			</cfif>
			<TR>
				<TD align="right" nowrap><B>#variables.legacyIDLabel#:</B></TD>
				<TD><INPUT MAXLENGTH="50" type="text" name="legacy_id" size="15" VALUE="#FORM.legacy_id#" <cfif appSettings.getModify_Legacy_ID() EQ 0>style="color:silver; border:1px solid silver;" disabled</cfif>></TD>
			</TR>
		</cfif> --->

		<!--- <cfif application.returned_customer_setting.responsible_person>
			<cfset userManager = CreateObject("component", "components.user.UserManager") />
			<cfset FORM.Responsible_User_Id = ListLast(FORM.Responsible_User_Id_Position_Id, "_")>
			<cfset Users = userManager.getUser(FORM.Responsible_User_Id) />
			<TR>
				<TD align="right" nowrap><B>Responsible Sales Person:</B></TD>
				<TD>#Users.User_Full_Name#
				<input type="Hidden" name="Responsible_User_Id_Position_Id" value="#Form.Responsible_User_Id_Position_Id#">
				</TD>
			</TR>

		</cfif> --->
		
<SCRIPT>
	function confirmCompletion(){
		document.BasicInfoForm.action="queries.cfm";
		BasicInfoForm.submit();
	}

	function insertNew(){
		var frm = $('#BasicInfoForm');
		data = frm.serialize();
		//alert('OK :: ' + data );
		$.ajax({
						async: true
						,data: data
						//,dataType: "json"
						,success: function (data) {
			                //console.log(data);
			                //alert('OK2 :: ' + data );
			                var pos = data.indexOf("<");
			                newCid = data.slice(0,pos);
			               // alert('OK3 :: ' + data );
			                document.location.href = '/Common_Files/contracts/OPP/GPO_One_Page_Program.cfm?CID=' + newCid + '&RO=1&RID=<CFOUTPUT>#createuuid()#</CFOUTPUT>';
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/Common_Files/contracts/queries.cfm"
			});
	}
	<CFIF form.Do_Revise_Copy EQ 0>  <!--- NOT A COPY/REVISE --->
		<CFIF len(trim(URL.CID)) EQ 0>  <!--- NEW PROGRAM --->
				insertNew();
				//document.location.href = contract_Edit_Menu.cfm?CID=#URL.CID#&RO=1&RID=#createuuid()#&ShowVolumePage=1
		</CFIF>
	</CFIF>

	 jQuery(".date").datepicker({
		    dateFormat: "mm/dd/yy",
		    changeMonth: true,
		    changeYear: true,
		});

	$("#BasicInfoForm :input").change(function() {
	  $(this).closest('form').data('changed', true);
	 saveBasicInfo($( this ).val(),$( this ).attr("name"));
	});


	function saveBasicInfo(val,field){
		var val = val;
		var field = field;
		//alert('OK :: ' + val );
		$.ajax({
						async: true
						,data: { 	val: 	val, 
									field: 	field,
									contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "saveBasicInfo" }
						//,dataType: "json"
						,success: function (data) {
			              //  console.log(data);
			               //alert('OK2 :: ' + data );
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	function getOverRideList(){
		//var frm = $('#OperatorSearchForm');
		//var gpoKey = $("#key_type").val();
		$.ajax({
						async: true
						,data: { 	contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									method: "getOverRidePriceList" }
						//,dataType: "json"
						,success: function (data) {
			             // console.log('Submission was successful.');
			             // console.log(data);
			             var res = JSON.parse(data);
			                 $.each(res, function (key, entry) {
			                 	//console.log(entry.price_list_header_id)
			                 	$("#Override_Price_List_Id").append($('<option></option>').attr('value', entry.price_list_header_id).text(entry.price_list_id));
							  })
	 						<cfoutput>$("##Override_Price_List_Id").val('#FORM.Override_Price_List_Id#');</cfoutput>
	 						$("#Override_Price_List_Id").chosen({search_contains: true,
    														enable_split_word_search: true});
			             // rowData_CPA_PriceList = JSON.parse(data);
			             // PriceList_GridOptions.api.setRowData(rowData_CPA_PriceList);
			            }
			            ,error: function (data) {
			                //console.log('An error occurred.');
			               // console.log(data);
			                alert('An error occurred.  ' + data );
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
	}

	// Functions to format a Text Input field as currency
	// To use just add the following to an input field:  data-type="currency"
	// Optionally, to restrict the input, add: pattern="^\$\d{1,3}(,\d{3})*(\.\d+)?$"
	$("input[data-type='currency']").on({
		// blur: function() { 
		change: function() { 
			CurrencyRenderer($(this));
		}
	});
	function CurrencyRenderer(input) {
		let input_val = input.val();
			if (isNaN (input_val) ) {
				// Strip out everything except minus sign, digits, period
				input_val = input_val.replace( /[^-\d+\.\d+]/g, '');
				if (input_val.length) {
					input_val = parseFloat(input_val);
				}
			}
		input_val = usdFormat.format(input_val);
		input.val(input_val);

		// alert("about to save "+$( input ).val()+" to "+$( input ).attr("name"));
		saveBasicInfo($( input ).val(),$( input ).attr("name"));
	}


	document.addEventListener("DOMContentLoaded", function () {
        //Build_CPAPriceListGrid();
        getOverRideList();
    });

    function createAdminFeea()
	{
		show_loader('Creating Admin Fee Program...');
		$.ajax({
						async: true
						,data: {
									contractId: <cfoutput>#variables.ContractMainID#</cfoutput>,
									createdBy: 	<cfoutput>'#request.AccessStructure.User_ID#'</cfoutput>,
									method: "createAdminFee" }
						//,dataType: "json"
						,success: function (data) {
			               // console.log(data);
			                window.location.href="/Common_Files/contracts/contract_edit_menu.cfm?CID=" + data;
			                //$("div.loader").hide();
			            }
			            ,error: function (data) {
			                alert('An error occurred.  ' + data );
			                $("div.loader").hide();
			            }
						,type: "post"
						,url: "/mvc/Models/Program/OnePageProgramManager.cfc"
			});
		
	}
	function selectCRA(){
		// _NoMargin
		<cfoutput>
			var sURL = "/Common_Files/contracts/manual_approval_selection_popup.cfm?Formname=MyForm&programID=#variables.ContractMainID#&templateID=#FORM.ProgramType_ID#"; 
		</cfoutput>
		NewWindowTopLeft(sURL, 'ManualApprovalSelection','800','600','Yes', 'Yes')
		return false;		
	}
	function CreateCpaPDF()
	{
		<cfoutput>
		NewWindow('/Common_Files/contracts/OPP/create_pdf_caller.cfm?Contract_Main_ID=#variables.ContractMainId#&type=2','cpaOutput','800','600','Yes', 'Yes');
		</cfoutput>
		return false;
	}
	function CreateCpaDistPDF()
	{
		<cfoutput>
		NewWindow('/Common_Files/contracts/OPP/create_pdf_caller.cfm?Contract_Main_ID=#variables.ContractMainId#&type=1','cpaOutput','800','600','Yes', 'Yes');
		</cfoutput>
		return false;
	}
</SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


