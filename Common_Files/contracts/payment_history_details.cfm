<!--- 
THIS FILE WAS BEING CALLED BY "VIEW_CONTRACT_PAYMENT_HISTORY.CFM", BUT IS NOT BEING USED ANYMORE, AS WE ARE NOW USING THE DATA TABLES GRID CODE.
--->

<cfparam name="form.finalpaymentlist" 	default="">
<cfparam name="form.check_billback" 	default="">
<cfparam name="form.alreadyselectedpayments" 	default="">
<cfparam name="form.end_date" default="">
<cfparam name="form.start_date" default="">
<cfparam name="form.payee_name" default="">
<cfparam name="form.payee_id" default="">
<cfparam name="form.payee_type" default="0">
<cfparam name="form.allpaymentsselected" default="0">
<cfparam name="form.generatexlsreport" default="0">
<cfparam name="url.print" default="0">
<cfparam name="startrow" default="1">
<cfparam name="frompage" default="1">
<cfparam name="allpayments" default="">

<cfset listofpaymentstodelete = "">
<STYLE>
 thead { display: table-header-group }
</STYLE>

	<cfif url.print eq 0 and form.generatexlsreport eq 0>
		 <span class="title2" id="pleasewaitmessage" align="center">
			 <br><br><br>
			 <center><cfinclude template="/includes/please_wait.cfm"></center>
			 <br><br><br>
		</span>
	<cfflush>
		<script>
			document.all.pleasewaitmessage.style.display='none';
		</script>
	</cfif>
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>

<cfset PaymentHistoryManager = CreateObject("component","components.programs.paymenthistory.PaymentHistoryManager") />
<cfset getpaymentdetails = PaymentHistoryManager.getpaymentdetails(getcontractInfo.contract_number,form) />
<cfset qGetOperatorOffInvoiceDetails = PaymentHistoryManager.getOperatorOffInvoiceDetails(getcontractInfo.contract_number,form)>
<cfset qGetBudgetActual = PaymentHistoryManager.getbudgetactual(getcontractInfo.contract_number,form)><!--- D36686 --->

<cfif url.PRINT EQ 0 and form.generatexlsreport EQ 0>
<cf_Number_of_Rows maxrows=100>
<cfelse>
<cf_Number_of_Rows maxrows= #getpaymentdetails.recordcount#>
</cfif>

<cfif url.PRINT EQ 0>
<cf_cryp type="en" string ="#url.ContractId#" key="#request.key#">
<CFSET URL.CID = cryp.value>
</cfif>

<cfif getpaymentdetails.recordcount GT 0 OR qGetOperatorOffInvoiceDetails.recordCount OR qGetBudgetActual.recordCount>
<CFSET AllPayments = ValueList(getpaymentdetails.billback_id)>
<CFSET listofitemstodelete = "">
<!--- loop through the pages selected items and if it is not in the selected list that means it was removed to queue it for deletion --->
<CFLOOP INDEX="ListItem" LIST="#FORM.AlreadySelectedPayments#" DELIMITERS=",">
		<CFIF listfind(FORM.check_billback, ListItem, ",") EQ 0>
			<CFSET listofitemstodelete = listappend(listofitemstodelete, ListItem, ",")>
		</CFIF>
</CFLOOP>

<!--- if a selected payment isnt already in the final list then add it  --->
<CFLOOP INDEX="ListItem" LIST="#FORM.check_billback#" DELIMITERS=",">
	<CFIF listfind(Form.FinalPaymentList, ListItem, ",") EQ 0>
		<CFSET Form.FinalPaymentList = listappend(FinalPaymentList, ListItem, ",")>
	</CFIF>
</CFLOOP>
<!--- delete the queued payments --->
<CFLOOP INDEX="ListItem" LIST="#listofitemstodelete#" DELIMITERS=",">
	<CFIF listfind(FORM.FinalPaymentList,ListItem, ",") GT 0>
		<CFSET Form.FinalPaymentList = listdeleteat(FORM.FinalPaymentList, listfind(FORM.FinalPaymentList,ListItem, ","), ",")>
	</CFIF>
</CFLOOP>


	<TABLE ID="Table_Header3" CELLPADDING="2" CELLSPACING="0" border="0" WIDTH="100%" CLASS="Maintable" BGCOLOR="FFE083">
		<cfif url.PRINT EQ 1 or form.generatexlsreport EQ 1>
			<cfoutput>
				<THEAD>
					<tr>
						<td width="#CI_Width#" class="tableheaders" valign="top" nowrap><B>Billback##</B><br><B>[Billback Title]</B></td>
						<td width="#BB_Width#" class="tableheaders" valign="top" ID="TD_CN" nowrap><B>Payable##</B></td>
						<td width="#Payee_Width#" class="tableheaders" valign="top" nowrap><B>Payee Name</B><br><B>Payee Id</B></td>
						<td width="#Evaluate(SD_Width+ED_Width)#" class="tableheaders center" valign="top" nowrap><B>Start</B> <br><B>End</B></td>
						<td width="#Paid_Width#" class="tableheaders right" valign="top" nowrap><B>Amount<br>Paid</B></td>
						<td width="#Piaddate_Width#" class="tableheaders center" valign="top" nowrap><B>Date Paid</B></td>
						<td width="#LB_Width#" class="tableheaders right" valign="top" nowrap><B>LB <br> Avg Rate</B></td>
						<td width="#CS_Width#" class="tableheaders right" valign="top" nowrap><B>CS <br> Avg Rate</B></td>
					</tr>
				</thead>
			</cfoutput>
	</cfif>
<cfset form.alreadyselectedpayments = "">
<cfset appsettings = application.oapplicationappsettingsmanager.getapplicationappsettings()>
<cfset refmaxlength = appsettings.getbb_ref_num_max_length()>
<cfset ref2maxlength = appsettings.getbb_2ref_num_max_length()>

<cfoutput query="getpaymentdetails" startrow="#StartRow#" maxrows="#MaxRows#">
<cfif currentrow mod 2>
	<cfset bg_color = "white">
<cfelse>
	<cfset bg_color = "ccffcc">
</cfif>
		<tr bgcolor="#bg_color#" valign="top" align="left">
			<cfif url.PRINT EQ 0 and form.generatexlsreport EQ 0>
			<td width="3%">
				<span ID="checkAllpayments">
					<input type="checkbox" name="check_billback" value="#billback_id#_#payee_unique_id#"
						<cfset check_billback_id = "#billback_id#_#payee_unique_id#">
						<CFIF listfind(Form.FinalPaymentList,check_billback_id)> CHECKED<CFSET FORM.AlreadySelectedPayments = listappend(AlreadySelectedPayments,check_billback_id,",")></CFIF> ONCLICK="if(!this.checked) document.all.payment_check_all.checked = false;"></span>
			</td>
			</cfif>
			<td width="17%" >
				<cfif url.PRINT EQ 1 or form.generatexlsreport EQ 1>
				#left(BB_reference,RefMaxLength)#
				<cfelse>
				<A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="NewWindow('/billbacks/capture/bb_preview.cfm?BBID=#billback_id#&byPassCache=1', 'bb_summary', 800, 600, 'yes', 'yes');">#left(BB_reference,RefMaxLength)#&nbsp;</span></A>
				</cfif><br>
				<cfset id = 'bbtitle'&#currentrow#>
				<cfif len(BB_Title) GT 15>
					#left(BB_Title, 15)#<span style="font-weight:bold;font-size:18px;cursor:hand;" title="#BB_Title#">&nbsp;...</span>

				<cfelse>
					[#BB_Title#]
				</cfif>
			</td>
			<td valign="top" width="10%">
				<cfif url.PRINT EQ 1 or form.generatexlsreport EQ 1>
				#left(BB_code,11)#
				<cfelse>
				<A href="##"><span style="cursor:pointer;  text-decoration: none;" onclick="NewWindow('/billbacks/capture/bb_preview.cfm?BBID=#billback_id#&byPassCache=1', 'bb_summary', 800, 600, 'yes', 'yes');" TITLE="#BB_Title#">#LEFT(BB_code,11)#</A>
				</cfif>
			</td>
	<!--- Dev Note: drachala; D27188: Formatting PoP-UP  START
	      Header and data are two different tables so they are not alligning properly modifed td width of second table to align with first table.--->
			<cfset new_width = Payee_Width - 20>
			<!--- D46174 Third line description on Payment view/Anand Rao/14-Nov-2014--->
			<td valign="top" width="19%">
				#payee_name#<br>
				<cfif City NEQ "" OR State NEQ "">
					#City#,#State#<br>
				</cfif>
				#payee_id#
			</td>
			<td valign="top" width="10%" class="center">#dateformat(BB_start_date,"mm/dd/yyyy")#<BR>#dateformat(BB_End_date,"mm/dd/yyyy")#</td>
			<td valign="top" width="10%" class="right">#dollarFormat(paid_amount)#<BR>
				<!---D42826 :: green dollar sign issue --->
				<cfif #FindNoCase(";",Check_Number)#>
					<span onmouseout="popUpTip(event,'Multiple_Checks');" onmouseover="popUpTip(event,'Multiple_Checks');"> Multiple <img src="/images/help_small.gif" /></span>
						<div id="Multiple_Checks" class="tip">
								#replace(Check_Number,";","<br/>","ALL")#
						</div>
					<cfelse>
					#Check_Number#
				</cfif>
				<!---D42826 :: green dollar sign issue --->
			</td>
			<td valign="top" width="10%" class="center"><cfif check_date NEQ "">#dateformat(check_date,"mm/dd/yy")#<cfelse>&nbsp;</cfif></td>
			<td valign="top" width="10%" class="right">#numberformat(volume_lb,'_,')#<br>#numberformat(avg_rate_lb,'$(_,.____')#</td>
			<td valign="top" width="10%" class="right">#numberformat(volume_cs,'_,')#<br>#numberformat(avg_rate_cs,'$(_,.____')#</td>
	</tr>
</cfoutput>
</tr>

<!--- OPERATOR OFF-INVOICE VOLUME --->
<cfif qGetOperatorOffInvoiceDetails.recordCount>
	<cfoutput>
	<tr BGCOLOR="E7FF9B" valign="TOP" align="left">
		<cfif url.PRINT EQ 0 and form.generatexlsreport EQ 0>
		<td>&nbsp;</td></cfif>
		<td colspan="4" align="left">
			<cfif url.PRINT EQ 1 or form.generatexlsreport EQ 1>
				Direct Shipment Volume
			<cfelse>
				<A href="##"><span style="cursor:pointer;  text-decoration: none;" align="left" onclick="getPaymentOperatorOffinvoiceDetails();">Operator Off-Invoice Volume&nbsp;</span></A>
			</cfif>
			<br>&nbsp;
		</td>
		<td valign="top" width="#Paid_Width#">$#numberformat(qGetOperatorOffInvoiceDetails.paid_amount,'_,___,___,___,___.__')#</td>
		<td valign="top" width="#Piaddate_Width#">&nbsp;</td>
		<td valign="top" width="#LB_Width#">#numberformat(qGetOperatorOffInvoiceDetails.volume_lb,'_,___,___,___,___')#</td>
		<td valign="top" width="#CS_Width#">#numberformat(qGetOperatorOffInvoiceDetails.volume_cs,'_,___,___,___,___')#</td>
	</tr>
	</cfoutput>
</cfif>

<!--- D36686 Actual Adjustment - Green $ Sign --->
<cfif qGetBudgetActual.recordCount>
	<cfoutput>
	<TR BGCOLOR="E7FF9B" valign="TOP" align="left">
	<cfif url.PRINT EQ 0 and form.generatexlsreport EQ 0>
	<td>&nbsp;</td></cfif>
	<td colspan="4" align="left">
		<cfif url.PRINT EQ 1 or form.generatexlsreport EQ 1>
		Budget Actual Adjustment
		<cfelse>
		<A href="##"><span style="cursor:pointer;  text-decoration: none;" align="left" onclick="getbudgetactual();">Budget Actual Adjustment&nbsp;</span></A>
		</cfif>
		<br>&nbsp;
	</td>
	<td valign="top" width="#Paid_Width#">$#numberformat(qGetBudgetActual.paid_amount,'_,___,___,___,___.__')#</td>
	<td valign="top" width="#Piaddate_Width#">&nbsp;</td>
	<td valign="top" width="#LB_Width#">0</td>
	<td valign="top" width="#CS_Width#">0</td>
	</tr>
	</cfoutput>
</cfif>
<!--- D36686 Actual Adjustment - Green $ Sign --->

</table>
<cfelse>
<br>
<table border="0" CELLSPACING="0" align="left" width="800"  class="nopaymentsfounds">
<TR><TD><b>No Payments found.</b></TD></TR>
</table>
</cfif>




<cfoutput><input type="hidden" name="ContractId" value="#url.ContractId#">
<INPUT TYPE="Hidden" NAME="startrow" VALUE="#startrow#">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="#frompage#">
<INPUT TYPE="Hidden" NAME="FinalPaymentList" VALUE="#form.FinalPaymentList#">
<INPUT TYPE="hidden" NAME="AlreadySelectedPayments" VALUE="#Form.AlreadySelectedPayments#">
<input type="hidden" name="Allpaymentsselected" value="#form.Allpaymentsselected#">
 <input type="hidden" name="payee_type" value="#form.payee_type#">
</cfoutput>
<cfif url.print EQ 0 and form.generatexlsreport EQ 0>
<script>
function getPaymentOperatorOffinvoiceDetails()
{
	NewWindow('/common_files/contracts/payment_history_operator_offinvoice_details.cfm?<cfoutput>contractID=#url.ContractId#</cfoutput>','paymentOperatorOffinvoiceDetails','870','620','Yes', 'No');
}
//D36686
function getbudgetactual()
{
	NewWindow('/common_files/contracts/Budget_Actual_Adjustment.cfm?<cfoutput>contractID=#url.ContractId#&contractnumber=#getcontractInfo.contract_number#</cfoutput>','paymentOperatorOffinvoiceDetails','870','620','Yes', 'No');
}
function getpaymentdetails(billbackid,distributorid)
{
document.PaymentHistory.check_billback.value = billbackid;
NewWindow('/common_files/contracts/payment_history_item_details.cfm?<cfoutput>contractID=#url.ContractId#</cfoutput>&issingleselection=1&paymentId='+billbackid+'&distributor_id='+distributorid,'paymentdetails','870','620','Yes', 'No');
}
function submitform()
{
	popupCenterByPercentages('/common_files/contracts/payment_history_item_details.cfm','paymentdetails','80','80','Yes', 'Yes');
	document.PaymentHistory.target = 'paymentdetails';
	document.PaymentHistory.action = 'payment_history_item_details.cfm';
	document.all.PaymentHistory.submit();
	document.PaymentHistory.target = '_self';
	document.PaymentHistory.action = 'view_contract_payment_history.cfm?ContractId=<cfoutput>#url.ContractId#</cfoutput>';
}

function printform()
{
NewWindow('print_payment_history.cfm','PrintEmailWin','760','600','Yes', 'Yes');
document.all.PrintForm.printonly.value=1;
document.all.PrintForm.FAX_EMAIL.value="";
document.all.PrintForm.submit();
}
function emailform(type)
{
NewWindow('print_payment_history.cfm','PrintEmailWin','720','600','Yes', 'Yes');
document.all.PrintForm.printonly.value=0;
document.all.PrintForm.FAX_EMAIL.value=type;
document.all.PrintForm.submit();
}

function continueapproval()
{
	opener.NewWindow('/clause_library/clause_approval.cfm?CID=<cfoutput>#URL.CID#</cfoutput>','name','1150','600','Yes', 'Yes');
	top.close();
}
</script>
<script>
function selectall(allpayments){
 var obj = window.checkAllpayments;
 if (allpayments == 1)
 {
 document.all.payment_check_all.checked = true;
 }

			if(obj != null){
				if(obj.length)
				{
					for(var x=0; x<obj.length;x++){
						box = getFirstChild(obj[x])
						if(box.disabled == false)
						{
						box.checked = document.all.payment_check_all.checked
						}
						else
						{
							box.disabled = true
						}
					}
				}
				else
				{
					box = getFirstChild(obj)
					box.checked = document.all.payment_check_all.checked
				}
			}
		if (allpayments == 1)
	{
		document.all.FinalPaymentList.value = "<cfoutput>#AllPayments#</cfoutput>";
		document.all.Allpaymentsselected.value = 1;
	}
		}

function checkifallpaymentsselected()
{
	if (document.all.Allpaymentsselected.value == 1)
	{
		selectall(1);
	}

}
</script>
</cfif>
