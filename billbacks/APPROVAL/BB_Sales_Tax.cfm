<!-----------------------------------------------------------------------------

FILE NAME:		BB_Sales_Tax.cfm
DESCRIPTION:	This file has teh 
CREATED BY:		???
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE
			
			Anand Rao	05-Mar-2014	

------------------------------------------------------------------------------> 


<cfparam  name="url.BBSalesTaxType" default="0">
<cfset pageIsPopup = 0 />
<cfif (isDefined("URL.BBID") AND URL.BBID NEQ "")>
	<cfset Billback_ID = URL.BBID />
	<cfset pageIsPopup = 1 />
</cfif>

<cfif url.BBSalesTaxType EQ 2>
	<cfparam name="form.save" 		default="0">
	<cfif form.save>
		<cfset useLakebaseForTaxInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>

		<cfif useLakebaseForTaxInfo>
			<cftry>
				<cfset Get_Tax_Info = application.oLakebase.toQuery(
					application.oLakebase.selectRows("bb_tax_info", {
						"billback_id" = "eq.#Billback_ID#",
						"deleted"     = "eq.false"
					})
				)>
				<cfif Get_Tax_Info.Recordcount>
					<cfset application.oLakebase.updateRows("bb_tax_info",
						{ "billback_id" = "eq.#Billback_ID#", "deleted" = "eq.false" },
						{ "tax_code_1_id" = form.Billbacks_Sales_Tax }
					)>
				<cfelse>
					<!--- unlike SQL Server, the Lakebase dbo.bb_tax_info.deleted column has no DEFAULT,
					      so it must be set explicitly here to avoid leaving it NULL. --->
					<cfset application.oLakebase.insertRow("bb_tax_info",
						{ "billback_id" = Billback_ID, "tax_code_1_id" = form.Billbacks_Sales_Tax, "deleted" = false }
					)>
				</cfif>
				<cfcatch type="any">
					<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
					<cfset useLakebaseForTaxInfo = false>
				</cfcatch>
			</cftry>
		</cfif>

		<cfif NOT useLakebaseForTaxInfo>
			<cfset useLakebaseForGet_Tax_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
<cfif useLakebaseForGet_Tax_Info>
	<cftry>
		<cfset Get_Tax_Info = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_tax_info", {
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_Tax_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_Tax_Info>
<cfquery name="Get_Tax_Info" datasource="#application.datasource#">
				SELECT *
				FROM BB_Tax_Info
				where Billback_ID = '#Billback_ID#'
				and deleted = 0
			</cfquery>
</cfif>
			<cfif Get_Tax_Info.Recordcount>
				<cfset useLakebaseForUpdate_Tax_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
<cfif useLakebaseForUpdate_Tax_Info>
	<cftry>
		<cfset application.oLakebase.updateRows("bb_tax_info",
			{
				"billback_id" = "eq.#Billback_ID#",
				"deleted" = "eq.0"
			},
			{
				"tax_code_1_id" = "#form.Billbacks_Sales_Tax#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Tax_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Tax_Info>
<cfquery name="Update_Tax_Info" datasource="#application.datasource#">
				UPDATE BB_Tax_Info
				SET Tax_Code_1_ID = #form.Billbacks_Sales_Tax#
				WHERE Billback_ID = '#Billback_ID#'
				AND deleted = 0
				</cfquery>
</cfif>
			<cfelse>
				<cfset useLakebaseForInsert_Tax_Info = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
<cfif useLakebaseForInsert_Tax_Info>
	<cftry>
		<cfset application.oLakebase.insertRow("bb_tax_info", {
			"billback_id" = "#Billback_ID#",
			"tax_code_1_id" = "#form.Billbacks_Sales_Tax#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_Tax_Info = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_Tax_Info>
<cfquery name="Insert_Tax_Info" datasource="#application.datasource#">
					INSERT INTO BB_Tax_Info (Billback_ID, Tax_Code_1_ID)
					VALUES('#Billback_ID#', #form.Billbacks_Sales_Tax#)
				</cfquery>
</cfif>
			</cfif>
		</cfif>
		<script>
			window.parent.location.href = "/Billbacks/capture/index.cfm?BBID=<CFOUTPUT>#billback_ID#</CFOUTPUT>";
		</script>
	<cfelse>
		<cfquery name="Get_Tax_Types" datasource="#application.datasource#">
			SELECT BB_Tax_Main_ID,Tax_Allowance_Code, Description, CAST(ISNULL(BB_Tax_Info.Tax_Code_1_ID, 0) AS INT) AS Tax_Type
			FROM BB_Tax_Main
			<cfif url.bb_status_id GTE 3>INNER<cfelse>LEFT</cfif> JOIN BB_Tax_Info
			ON BB_Tax_Info.Billback_ID = '#Billback_ID#'
			WHERE BB_Tax_Main.Deleted = 0
			Order by	Description
		</cfquery>
		<br>
	<form name="BBSalesTaxReassign" action="BB_Sales_Tax.cfm?<cfoutput>BBID=#Billback_ID#&BBSalesTaxType=#url.BBSalesTaxType#</cfoutput>" method="Post">
	<table border="0" cellpadding="0" cellspacing="0" width="100%" aligh="center">
		<tr>
			<td><font color="navy" size="3"><B>Billback Sales Tax</B></FONT><HR COLOR="Orange"></td>
		</tr>
		<tr>
			<td>
				<span id="error_Tax_Type"></span><strong>Tax Type:</strong> 
				<cfif url.bb_status_id GTE 3>
					<cfoutput>#Get_Tax_Types.Description# ( #Get_Tax_Types.Tax_Allowance_Code# )</cfoutput>
				<cfelse>
				<select name="Billbacks_Sales_Tax">
					<option value="0">Select a Tax Type</option>
					<cfoutput  query="Get_Tax_Types"> 
						<option value="#BB_Tax_Main_ID#" <cfif Tax_Type EQ BB_Tax_Main_ID>SELECTED</cfif>>#Description# ( #Tax_Allowance_Code# )</option>
					</cfoutput>
				</select>
				<input type="hidden" name="save" value="0">
				<br><br>
				<A HREF="javascript: Validate()"><cfoutput>#application.util.string.actionLinkFormat("save")#</cfoutput></A>		
			</td>
		</cfif>
		</tr>
		</table>
	</form>
	<script>
		function Validate(){
			if (document.all.Billbacks_Sales_Tax.value == "0"){
				alert("Please select a tax type.");
			}else{
				document.all.save.value = '1';
				BBSalesTaxReassign.submit();
			}
		}
	</script>
	</cfif>

<cfelse>




<SCRIPT language="JavaScript" src="/script/javascript/string_functions.js"></SCRIPT>
<SCRIPT language="JavaScript" src="/Common_Files/scripts/allowonlytwodecimalplaces.js"></SCRIPT>	


<CFPARAM NAME="FORM.TotalTaxAmount"						DEFAULT="0">
<CFPARAM NAME="FORM.TotalTaxableAmount_1"				DEFAULT="0">
<CFPARAM NAME="FORM.TotalTaxableAmount_2"				DEFAULT="0">
<CFPARAM NAME="FORM.TotalTaxableAmount_3"				DEFAULT="0">
<CFPARAM NAME="FORM.TotalTaxAmount_1"					DEFAULT="0">
<CFPARAM NAME="FORM.TotalTaxAmount_2"					DEFAULT="0">
<CFPARAM NAME="FORM.TotalTaxAmount_3"					DEFAULT="0">
<!--- "AddTax" is 1 (ON), when the user views this page from the "Sales Tax" Left NAV.
When "AddTax" is 1, "save" button is added for saving tax data.
Even without it, the tax data can be saved when this file is included from payment.cfm as
the save queries are on "payment_confirmation.cfm".
 --->
<CFPARAM NAME="AddTax"							DEFAULT="0">

<CFSET billbackMan = CreateObject("component", "components.billback.BillbackManager").init() />
<CFSET BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />

<cfset CheckTemplateSalesTax = BBProgramManager.getTemplateSalesTax(Billback_ID)>

<cfset bBillbackSalesTax = 0 />
<cfif (CheckTemplateSalesTax.RecordCount GTE 2)>
	<cfloop query = "CheckTemplateSalesTax">
		<cfif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
			<cfset bBillbackSalesTax = 1 />
		</cfif>
	</cfloop>
<cfelseif (CheckTemplateSalesTax.Billback_Sales_Tax EQ 1)>
	<cfset bBillbackSalesTax = 1 />
</cfif>
 
<cfquery name="GetBillbackInfo" datasource="#application.datasource#">
SELECT 	BB.*,BB_Approved.User_Approved,BB_Approved.BB_Check_Status_ID, BB_Approved.Paid_Amount
FROM Billback BB
LEFT JOIN BB_Approved
				ON
				BB_Approved.Billback_ID = BB.Billback_ID
WHERE BB.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</cfquery>

<cfif AddTax eq 1>
<form action="/billbacks/capture/save_tax_info.cfm" method="post" name="frmSalesTax">
</cfif>

<cfif bBillbackSalesTax eq 1>
	<cfset BillbackSalesTaxInfo = billbackMan.getBillbacksSalesTaxInfo()>
	<cfset BillbackSalesTaxAmountInfo = billbackMan.getBillbacksSalesTaxAmount(Billback_ID)> 
	<cfoutput>
		<tr>
			<td class="DataTitleCell">&nbsp;</TD>
			<td>
			    <table>
			      <tr>
					<td><b>Tax Type</b></td>
					<!---<td><b>Taxable Amount</b></td>--->
					<td><b>Tax Amount</b></td>
				      </tr>

				      <tr>
					<td>
					<span id="error_TaxCode_1"></span>
					    <select name="TaxCode_1" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif>>
						<option value="">--Please choose--</option>
						<cfloop query="BillbackSalesTaxInfo">
						 <option value="#Taxcode_ID#" <cfif BillbackSalesTaxInfo.Taxcode_ID eq BillbackSalesTaxAmountInfo.Tax_Code_1_ID>selected</cfif>>#Tax_Allowance_Code#</option>
						</cfloop>
					    </select>
					</td>
					<!---<td><span id="error_TaxableAmount_1"></span><input type="text" name="TaxableAmount_1" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif> size="10" value="#trim(numberformat(val(BillbackSalesTaxAmountInfo.Tax_Code_1_Domestic_Taxable_Amount), '_____________________.__'))#" onKeyUp="clenseText(this, '0123456789.'); allowonlytwodecimalplaces(this);" onBlur="TwoDecimalsOnBlur(this)"></TD>--->
					 <td><span id="error_TaxAmount_1"></span><input type="text" name="TaxAmount_1" id="TaxAmount_1" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif> size="10" value="#trim(numberformat(val(BillbackSalesTaxAmountInfo.Tax_Code_1_Domestic_Amount), '_____________________.__'))#" onKeyUp="clenseText(this, '0123456789.'); allowonlytwodecimalplaces(this);" onBlur="TwoDecimalsOnBlur(this)"></TD>
				      </tr>

				       <tr>
					    <td>
						<span id="error_TaxCode_2"></span>
						    <select name="TaxCode_2" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif>>
							<option value="">--Please choose--</option>
							<cfloop query="BillbackSalesTaxInfo">
							 <option value="#Taxcode_ID#"  <cfif BillbackSalesTaxInfo.TaxCode_ID eq BillbackSalesTaxAmountInfo.Tax_Code_2_ID>selected</cfif>>#Tax_Allowance_Code#</option>
							</cfloop>
						    </select>
					    </td>
					    <!---<td><span id="error_TaxableAmount_2"></span><input type="text" name="TaxableAmount_2" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif> size="10" value="#trim(numberformat(val(BillbackSalesTaxAmountInfo.Tax_Code_2_Domestic_Taxable_Amount), '_____________________.__'))#" onKeyUp="clenseText(this, '0123456789.'); allowonlytwodecimalplaces(this);" onBlur="TwoDecimalsOnBlur(this)"></TD>--->
					     <td><span id="error_TaxAmount_2"></span><input type="text" name="TaxAmount_2" id="TaxAmount_2" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif> size="10" value="#trim(numberformat(val(BillbackSalesTaxAmountInfo.Tax_Code_2_Domestic_Amount), '_____________________.__'))#" onKeyUp="clenseText(this, '0123456789.'); allowonlytwodecimalplaces(this);" onBlur="TwoDecimalsOnBlur(this)"></TD>
				      </tr>
				       <tr>
					    <td>
						<span id="error_TaxCode_3"></span>
							<select name="TaxCode_3" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif>>
							    <option value="">--Please choose--</option>
							    <cfloop query="BillbackSalesTaxInfo">
							     <option value="#Taxcode_ID#"  <cfif BillbackSalesTaxInfo.TaxCode_ID eq BillbackSalesTaxAmountInfo.Tax_Code_3_ID>selected</cfif>>#Tax_Allowance_Code#</option>
							    </cfloop>
							</select>
					    </td>
					<!---<td><span id="error_TaxableAmount_3"></span><input type="text" name="TaxableAmount_3" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif> size="10" value="#trim(numberformat(val(BillbackSalesTaxAmountInfo.Tax_Code_3_Domestic_Taxable_Amount), '_____________________.__'))#" onKeyUp="clenseText(this, '0123456789.'); allowonlytwodecimalplaces(this);" onBlur="TwoDecimalsOnBlur(this)"></TD>--->
					 <td><span id="error_TaxAmount_3"></span><input type="text" name="TaxAmount_3" id="TaxAmount_3" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif> size="10" value="#trim(numberformat(val(BillbackSalesTaxAmountInfo.Tax_Code_3_Domestic_Amount), '_____________________.__'))#" onKeyUp="clenseText(this, '0123456789.'); allowonlytwodecimalplaces(this);" onBlur="TwoDecimalsOnBlur(this)"></TD>
					</tr>
				        <tr>
					   <!---<td>&nbsp;</td>--->
					   <td align="right"><b>Total Tax: </b></td>
					   <td><input type="text" name="TotalTaxAmount" id="TotalTaxAmount" <cfif GetBillbackInfo.billback_status_id GTE 3>disabled</cfif> size="10" value="#trim(numberformat(val(GetBillbackInfo.TotalTaxAmount), '_____________________.__'))#" onKeyUp="clenseText(this, '0123456789.'); allowonlytwodecimalplaces(this);" onBlur="TwoDecimalsOnBlur(this)"></td>
				       </tr>
				       <cfif AddTax eq 1>
				       <tr>
					   <td>&nbsp;</td>
					   <td><input type="button" value="save" onClick="CheckForErrors()"></td>
				       </tr>
				       </cfif>
					</table>
				<td>
				</tr>
				<cfif AddTax eq 1>
				<input type="hidden" name="AddTax" value="1" />
				<input type="hidden" name="Billback_ID" value="#Billback_ID#" />
				</cfif>
				<!---<input type="hidden" name="saveTaxInfo" value="1" />--->
				
	</cfoutput>				
</cfif> <!--- <cfif bBillbackSalesTax eq 1> --->

<cfif AddTax eq 1>
</form>
</cfif>


<script language="JavaScript">

	function TwoDecimalsOnBlur(oObject){
		var nf = new NumberFormat();
		nf.setNumber(oObject.value);
		nf.setCommas(false);
		nf.setCurrency(false);
		nf.setPlaces(2);
		oObject.value = nf.toFormatted();
		<cfif bBillbackSalesTax eq 1>
		document.all.TotalTaxAmount.value = parseFloat(document.all.TaxAmount_1.value) + parseFloat(document.all.TaxAmount_2.value) + parseFloat(document.all.TaxAmount_3.value);
		document.all.TotalTaxAmount.value = parseFloat(document.all.TotalTaxAmount.value).toFixed(2);
			
			<!--- These elements exist on the approval page and not when when we view this page from the Left NAV. --->
			<cfif AddTax eq 0>
			document.getElementById('Total_Tax_Amount').innerHTML = document.getElementById('TotalTaxAmount').value;
			document.getElementById('Total_Payment_Amount_Taxes_Included').innerHTML = parseFloat(document.getElementById('Total_Payment_Amount').innerHTML) + parseFloat(document.getElementById('Total_Tax_Amount').innerHTML);
			</cfif>
		</cfif>
	}
		
	function CheckForErrors() {
		var ErrorCount = 0;
		<cfif bBillbackSalesTax eq 1>
			error_text 		= "You cannot choose the same Tax Code more than once";
			error_oSpan 	= document.all.error_TaxCode_1;
			

			if((document.all.TaxCode_1.value != '') && (document.all.TaxCode_1.value == document.all.TaxCode_2.value))
			{
				    ErrorCount++;
				    queueMessage(error_text, error_oSpan);
			}
			else
			{
				    clearQueue(error_oSpan);
			}

			error_text 		= "Please select a tax code";
			error_oSpan 	= document.all.error_TaxCode_1;

			//if(document.all.TaxCode_1.value == '' && (parseFloat(document.all.TaxableAmount_1.value) > 0 || parseFloat(document.all.TaxAmount_1.value) > 0))
			if(document.all.TaxCode_1.value == '' && parseFloat(document.all.TaxAmount_1.value) > 0)
			{

				    ErrorCount++;
				    queueMessage(error_text, error_oSpan);
			}
			else
			{
				    clearQueue(error_oSpan);
			}

			error_text 		= "You cannot choose the same Tax Code more than once";
			error_oSpan 	= document.all.error_TaxCode_2;
			if((document.all.TaxCode_2.value != '') && (document.all.TaxCode_2.value == document.all.TaxCode_3.value))
			{
				    ErrorCount++;
				    queueMessage(error_text, error_oSpan);
			}
			else
			{
				    clearQueue(error_oSpan);
			}

			error_text 		= "Please select a tax code";
			error_oSpan 	= document.all.error_TaxCode_2;

			//if(document.all.TaxCode_2.value == '' && (parseFloat(document.all.TaxableAmount_2.value) > 0 || parseFloat(document.all.TaxAmount_2.value) > 0))
			if(document.all.TaxCode_2.value == '' && parseFloat(document.all.TaxAmount_2.value) > 0)
			{

				    ErrorCount++;
				    queueMessage(error_text, error_oSpan);
			}
			else
			{
				    clearQueue(error_oSpan);
			}

			error_text 		= "You cannot choose the same Tax Code more than once";
			error_oSpan 	= document.all.error_TaxCode_3;
		
			if((document.all.TaxCode_1.value != '') && (document.all.TaxCode_1.value == document.all.TaxCode_3.value))
			{
				    ErrorCount++;
				    queueMessage(error_text, error_oSpan);
			}
			else
			{
				    clearQueue(error_oSpan);
			}

			error_text 		= "Please select a tax code";
			error_oSpan 	= document.all.error_TaxCode_3;

			//if(document.all.TaxCode_3.value == '' && (parseFloat(document.all.TaxableAmount_3.value) > 0 || parseFloat(document.all.TaxAmount_3.value) > 0))
			if(document.all.TaxCode_3.value == '' && parseFloat(document.all.TaxAmount_3.value) > 0)
			{

				    ErrorCount++;
				    queueMessage(error_text, error_oSpan);
			}
			else
			{
				    clearQueue(error_oSpan);
			}

		<!---
		<cfif IsDefined("GetBillbackInfo.Paid_Amount") AND GetBillbackInfo.Paid_Amount neq "" AND GetBillbackInfo.Paid_Amount neq 0>
			error_text  = "The value of the taxable amount cannot exceed the total approved amount";
			error_oSpan = document.all.error_TaxableAmount_1;
			if(parseFloat(document.all.TaxableAmount_1.value) > parseFloat(<cfoutput>#val(GetBillbackInfo.Paid_Amount)#</cfoutput>))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}

			error_text  = "The value of the taxable amount cannot exceed the total approved amount";
			error_oSpan = document.all.error_TaxableAmount_2;
			if(parseFloat(document.all.TaxableAmount_2.value) > parseFloat(<cfoutput>#val(GetBillbackInfo.Paid_Amount)#</cfoutput>))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}


			error_text  = "The value of the taxable amount cannot exceed the total approved amount";
			error_oSpan = document.all.error_TaxableAmount_3;
			if(parseFloat(document.all.TaxableAmount_3.value) > parseFloat(<cfoutput>#val(GetBillbackInfo.Paid_Amount)#</cfoutput>))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}
		<cfelse>
			error_text  = "The value of the taxable amount cannot exceed the total billback amount";
			error_oSpan = document.all.error_TaxableAmount_1;
			if(parseFloat(document.all.TaxableAmount_1.value) > parseFloat(document.all.claimAmount.value))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}

			error_text  = "The value of the taxable amount cannot exceed the total billback amount";
			error_oSpan = document.all.error_TaxableAmount_2;
			if(parseFloat(document.all.TaxableAmount_2.value) > parseFloat(document.all.claimAmount.value))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}


			error_text  = "The value of the taxable amount cannot exceed the total billback amount";
			error_oSpan = document.all.error_TaxableAmount_3;
			if(parseFloat(document.all.TaxableAmount_3.value) > parseFloat(document.all.claimAmount.value))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}
		</cfif>
			error_text  = "The value of the tax amount cannot exceed the taxable amount";
			error_oSpan = document.all.error_TaxAmount_1;
			if(parseFloat(document.all.TaxAmount_1.value) > parseFloat(document.all.TaxableAmount_1.value))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}

			error_text  = "The value of the tax amount cannot exceed the taxable amount";
			error_oSpan = document.all.error_TaxAmount_2;
			if(parseFloat(document.all.TaxAmount_2.value) > parseFloat(document.all.TaxableAmount_2.value))
			{
			    ErrorCount++;
			    queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}


			error_text  = "The value of the tax amount cannot exceed the taxable amount";
			error_oSpan = document.all.error_TaxAmount_3;
			if(parseFloat(document.all.TaxAmount_3.value) > parseFloat(document.all.TaxableAmount_3.value))
			{
			ErrorCount++;
			queueMessage(error_text, error_oSpan);
			}
			else
			{
			    clearQueue(error_oSpan);
			}
			--->
			</cfif>
	
	
			if(ErrorCount == 0) {
			<cfif AddTax eq 1>
			frmSalesTax.submit();
			</cfif>
			// BBForm.submit()
			/* if(disableClickedButton)
			{
				disableButton(disableClickedButtonName, true, false);
			}*/			
			return true; 
			}
			else
			{		
			showMessageWindow();
			return false;
			}
}					
</script>
<CF_MessageWindow>
</cfif>