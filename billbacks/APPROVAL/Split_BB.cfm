<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dhtml.js"/>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">

<STYLE>
TABLE.underline TD
{
	border-bottom:solid #C0C0C0 1px;
}
</STYLE>

<CFIF Form_Submitted EQ "">
	<CFSET PassedBBID = Billback_ID>
	<CFQUERY NAME="Get_BB_Details" DATASOURCE="#Application.Datasource#">
		SELECT 		*
		FROM 		Billback
		INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE 		Billback.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
	</CFQUERY>

	<!--- START: D41801:  Billback Sales Tax/Anand Rao/26-Mar-2014
	  Check if the Billback's program template has sales tax on it.
	--->
	<cfif not isDefined("BBProgramManager")>
		<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />
	</cfif>
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
	<!--- END: D41801:  Billback Sales Tax/Anand Rao/26-Mar-2014 --->

	<CFIF Get_BB_Details.BB_Is_Child EQ 1>
		<CFSET Parent = Get_BB_Details.BB_Parent_ID>
		<CFQUERY NAME="Get_BB_Details" DATASOURCE="#Application.Datasource#">
			SELECT 		*
			FROM 		Billback
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
			WHERE 		Billback.Billback_ID = <cfqueryparam value="#Parent#" cfsqltype="CF_SQL_VARCHAR">
		</CFQUERY>
	<CFELSE>
		<CFSET Parent = Billback_ID>
	</CFIF>

	<CFQUERY NAME="Get_all_Children" DATASOURCE="#Application.Datasource#">
		SELECT 		*
		FROM 		Billback
		LEFT JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		WHERE 		BB_Parent_ID = <cfqueryparam value="#Parent#" cfsqltype="CF_SQL_VARCHAR"> AND
					Billback.Deleted = 0
		ORDER BY 	BB_Split_Number
	</CFQUERY>

	<CFIF Get_all_Children.RecordCount GT 0>
		<CFSET Record_count = Get_all_Children.RecordCount>
	</CFIF>

	<CFQUERY NAME="GetMaxSPNumber" DATASOURCE="#Application.Datasource#">
		SELECT Max(BB_Split_Number) MaxSP FROM Billback WHERE BB_Parent_ID = <cfqueryparam value="#Parent#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
	</CFQUERY>

	<CFIF GetMaxSPNumber.recordcount GT 0>

		<!--- D31229: BBK 1199999 Splits <> Parent cannot add split... START --->
			<!---<CFSET LastSPNumber = Replace(GetMaxSPNumber.MaxSP,"0","","All")>	--->
		<CFSET LastSPNumber = VAL(GetMaxSPNumber.MaxSP)>
		<cfif LastSPNumber EQ 0>
			<cfset LastSPNumber = 1>
		</cfif>
		<!--- D31229: BBK 1199999 Splits <> Parent cannot add split... END --->
		<CFSET LastSPNumber = TRIM(LastSPNumber)>
	<CFELSE>
		<CFSET LastSPNumber = 0>
	</CFIF>
	<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/string_functions.js"/>
		<BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="600">
			<CFIF Get_all_Children.RecordCount GT 0>
			<TR>
				<TD>
					<CFIF Parent NEQ PassedBBID AND application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><CFOUTPUT><A Href="/GL_Code/GL_Code_In_Billback/Allocation_layout.cfm?Billback_ID=#Billback_ID#">allocation summary</A></CFOUTPUT><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					</CFIF>
					<B><FONT COLOR="Red" SIZE="2">[ </FONT><CFOUTPUT><A Href="Split_BB_History.cfm?Billback_ID=#Billback_ID#">split detail</A></CFOUTPUT><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
				</TD>
			</TR>
			<CFELSEIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>
			<TR>
				<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><CFOUTPUT><A Href="/GL_Code/GL_Code_In_Billback/Allocation_layout.cfm?Billback_ID=#Billback_ID#">allocation summary</A></CFOUTPUT><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
			</TR>
			</CFIF>
			<TR>
				<TD ALIGN="Center"><B>SPLIT BILLBACK </B><BR><BR></TD>
			</TR>
			<TR>
				<TD>
					<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
						<TR>
							<TD WIDTH="125">ORIGINAL BILLBACK:</TD>
							<TD><B><CFOUTPUT>#Get_BB_Details.BB_Code#</CFOUTPUT></B></TD>
						</TR>
						<TR>
							<TD>ORIGINAL AMOUNT:</TD>
							<TD><CFOUTPUT><B>$ #NumberFormat(Get_BB_Details.Paid_Amount,"_,___.__")#</B></CFOUTPUT></TD>
						</TR>
						<TR>
							<TD ID="SPTotText">SPLIT TOTAL AMOUNT:</TD>
							<CFSET SP_Total = 0>
							<CFIF Isdefined("Record_count")>
							<CFOUTPUT QUERY="Get_all_Children">
								<CFSET SP_Total = SP_Total + Paid_Amount>
							</CFOUTPUT>
							</CFIF>

							<TD ID="DySPTotal"><CFIF SP_Total LT Get_BB_Details.Paid_Amount><FONT COLOR="Red"></CFIF><B><CFOUTPUT>$ #NumberFormat(SP_Total,"_,___.__")#</CFOUTPUT></B><CFIF SP_Total LT Get_BB_Details.Paid_Amount></FONT></CFIF></TD>

						</TR>
						<TR ID="SPTR">
							<TD ID="SPText">
								<CFIF SP_Total LT Get_BB_Details.Paid_Amount><FONT COLOR="Red">TO SPLIT AMOUNT:</FONT></CFIF>&nbsp;
							</TD>
							<TD ID="SPResult">
								<CFIF SP_Total LT Get_BB_Details.Paid_Amount>
									<CFSET AmtDiff = Get_BB_Details.Paid_Amount - SP_Total>
									<FONT COLOR="Red"><B>ADD&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<CFOUTPUT>$ #NumberFormat(AmtDiff,"_,___.__")#</CFOUTPUT></B></FONT>&nbsp;
								</CFIF>
							</TD>
						</TR>
					</TABLE>
				</TD>
			</TR>
		</TABLE>
		<CFSET SetTRCount = 2>
		<CFIF isDefined("Record_count")>
			<CFSET SetTRCount = Record_count + 1>
		</CFIF>

		<FORM NAME="Sp_Parent" ACTION="Split_BB.cfm" METHOD="Post">
		<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" ID="SP_Main_Table" CLASS="underline" WIDTH="600">

		<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">

		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="InsertRowAt" VALUE="#SetTRCount#">
		<INPUT TYPE="Hidden" NAME="CurLargeSPNumber" VALUE="#LastSPNumber#">
		<INPUT TYPE="Hidden" NAME="FromSplit" VALUE="1">
		<INPUT TYPE="Hidden" NAME="BBID" VALUE="#URL.Billback_ID#">
		<!---
		<INPUT TYPE="Hidden" NAME="DD_Number" VALUE="#Get_DD_Details.DD_DedID#">
		 --->
		<INPUT TYPE="Hidden" NAME="BB_Amount" VALUE="#Get_BB_Details.Paid_Amount#">

		</CFOUTPUT>
			<TR BGCOLOR="FFE083">
				<TD>&nbsp;</TD>
				<TD><B>AMOUNT</B></TD>
				<TD><B>CLOSING METHOD</B></TD>
				<TD><B>SPLIT REASON</B></TD>
				<TD><A HREF="Javascript: addRow(document.all.InsertRowAt.value);"><img src="/images/plus4.gif" border="0" title="Add another child"></A></TD>
			</TR>
			<CFIF Get_all_Children.RecordCount EQ 0>
			<INPUT TYPE="Hidden" NAME="IsDeleted_1" VALUE="0">
			<INPUT TYPE="Hidden" NAME="IsCreated_1" VALUE="1">
			<INPUT TYPE="Hidden" NAME="NoOfChildren" VALUE="1">
			<CFSET CheckThis = "">
				<!--- Milan-11142 (If the app setting ("billback closing method is deduction by default") is on, then the checkbox is checked by default,
							unless the user unchecks it for the billback) --->
			<CFIF Get_all_Children.BB_Closing_Method EQ 2 OR (Get_all_Children.BB_Closing_Method EQ "" AND appSettings.getBillbackClosingMethod() eq 1)>
				<CFSET CheckThis = "Checked">
			</CFIF>
			<cfoutput>
			<TR>
				<TD><B>01</B></TD>
				<TD ONMOUSEOVER="Javascript: ToolTip(1)"><INPUT TYPE="Text" NAME="Amt_Child_1" VALUE="" SIZE="8" onKeyUp="clenseText(this, '-0123456789.');limitXdecimalplaces(2, Amt_Child_1);DispTotal();"></TD>
				<TD><INPUT TYPE="CheckBox" NAME="Closing_Method_1" VALUE="2" #checkThis#><B>Deduction</B></TD>
				<TD><TEXTAREA NAME="Split_Reason_1" COLS="55" ROWS="2"></TEXTAREA></TD>
				<TD><A HREF="Javascript: undo_redoRow(1,'c0c0c0',1);"><img  src="/Images/scissor.gif" width="14" height="9" title="Remove split" border="0"></A>&nbsp;</TD>
			</TR>
			</cfoutput>
			<CFELSE>
				<INPUT TYPE="Hidden" NAME="Mode" VALUE="Edit">
				<CFIF Get_all_Children.recordcount EQ 0>
				<INPUT TYPE="Hidden" NAME="IsDeleted_1" VALUE="0">
				<INPUT TYPE="Hidden" NAME="IsCreated_1" VALUE="1">
				<INPUT TYPE="Hidden" NAME="NoOfChildren" VALUE="1">
					<TR>
						<TD><B>01</B></TD>
						<TD ONMOUSEOVER="Javascript: ToolTip(1)"><INPUT TYPE="Text" NAME="Amt_Child_1" VALUE="" SIZE="8" onKeyUp="clenseText(this, '-0123456789.');limitXdecimalplaces(2, Amt_Child_1);DispTotal();"></TD>
						<TD><TEXTAREA NAME="Split_Reason_1" COLS="55" ROWS="2"></TEXTAREA></TD>
						<TD><A HREF="Javascript: undo_redoRow(1,'c0c0c0',1);"><img src="Images/scissor.gif" width="14" height="9" title="Remove child" border="0"></A>&nbsp;</TD>
					</TR>
				<CFELSE>
					<INPUT TYPE="Hidden" NAME="CurChildren" VALUE=<CFOUTPUT>"#LastSPNumber#"</CFOUTPUT>>
					<INPUT TYPE="Hidden" NAME="NoOfChildren" VALUE=<CFOUTPUT>"#Get_all_Children.RecordCount#"</CFOUTPUT>>
					<CFOUTPUT QUERY="Get_all_Children">
						<CFQUERY NAME="CheckLock" DATASOURCE="#Application.Datasource#">
							SELECT * FROM Billback_Allied WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND BB_Is_Locked = 1 AND BB_Locked_By_User_ID <> '#request.AccessStructure.User_ID#'
						</CFQUERY>
						<!--- D31229: BBK 1199999 Splits <> Parent cannot add split... START --->
						<!---<CFSET LastDigitSPNumber = Replace(BB_Split_Number,"0","","All")>--->
						<CFSET LastDigitSPNumber = VAL(BB_Split_Number)>
						<!--- D31229: BBK 1199999 Splits <> Parent cannot add split... END --->
						<CFSET LastDigitSPNumber = TRIM(LastDigitSPNumber)>

						<CFSET AccessPremission = 0>
						<CFIF CheckLock.RecordCount EQ 0 AND Billback_Status_ID NEQ 4 AND Billback_Status_ID NEQ 5 AND Billback_Status_ID NEQ 7>
							<CFSET AccessPremission = 1>
						</CFIF>

						<!--- <cfset Distributor = Distributor_ID> --->
						<INPUT TYPE="Hidden" NAME="Child_ID_#LastDigitSPNumber#" VALUE=<CFOUTPUT>"#BB_Split_Number#"</CFOUTPUT>>
						<INPUT TYPE="Hidden" NAME="Child_UUID_#LastDigitSPNumber#" VALUE="#Billback_ID#">
						<INPUT TYPE="Hidden" NAME="IsDeleted_#LastDigitSPNumber#" VALUE="0">
						<INPUT TYPE="Hidden" NAME="IsCreated_#LastDigitSPNumber#" VALUE="0">
						<TR bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#"><!--- <CFIF AccessPremission EQ 0>BGCOLOR="Silver"<CFELSE></CFIF> --->
							<TD><B>#BB_Split_Number#</B></TD>
							<TD <CFOUTPUT>ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#)"</CFOUTPUT>>
								<CFIF AccessPremission EQ 1>
									<INPUT TYPE="Text" NAME="Amt_Child_#LastDigitSPNumber#" VALUE="#Paid_Amount#" SIZE="8" onKeyUp="clenseText(this, '-0123456789.');DispTotal();">
								<CFELSE>
									#DOLLARFORMAT(Paid_Amount)#
									<INPUT TYPE="Hidden" NAME="Amt_Child_#LastDigitSPNumber#" VALUE="#Paid_Amount#">
								</CFIF>
							</TD>
							<CFSET CheckThis = "">
							<!--- Milan-11142 (If the app setting ("billback closing method is deduction by default") is on, then the checkbox is checked by default,
										unless the user unchecks it for the billback) --->
							<CFIF BB_Closing_Method EQ 2 OR (BB_Closing_Method EQ "" AND appSettings.getBillbackClosingMethod() eq 1)>
								<CFSET CheckThis = "Checked">
							</CFIF>
							<TD>
								<CFIF AccessPremission EQ 1 AND BB_Associated_To_DD EQ 0>
									<INPUT TYPE="CheckBox" NAME="Closing_Method_#LastDigitSPNumber#" VALUE="2" #CheckThis#><B>Deduction</B>
								<CFELSE>
									<INPUT TYPE="CheckBox" NAME="Closing_Method_#LastDigitSPNumber#" VALUE="2" #CheckThis# DISABLED><B>Deduction</B>
									<INPUT TYPE="Hidden" NAME="Closing_Method_#LastDigitSPNumber#" VALUE="#BB_Closing_Method#">
								</CFIF>
							</TD>
							<TD>
								<CFIF AccessPremission EQ 1>
									<TEXTAREA NAME="Split_Reason_#LastDigitSPNumber#" COLS="55" ROWS="2">#BB_Split_Reason#</TEXTAREA>
								<CFELSE>
									<INPUT TYPE="Hidden" NAME="Split_Reason_#LastDigitSPNumber#" VALUE="#BB_Split_Reason#">
									<CFIF BB_Split_Reason NEQ "">
										#BB_Split_Reason#
									<CFELSE>
										None.
									</CFIF>
								</CFIF>
							</TD>
							<TD>
								<CFIF AccessPremission EQ 0>
									<!--- <img src="/Images/scissor.gif" width="14" height="9" alt="Remove entry" border="0"> --->
								<CFELSE>
									<A HREF="Javascript: undo_redoRow(#currentrow#,'c0c0c0',#LastDigitSPNumber#);"><img src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0"></A>
								</CFIF>&nbsp;
							</TD>
						</TR>
					</CFOUTPUT>
				</CFIF>
			</CFIF>
		</TABLE>
		</FORM>
		<BR><BR>
		<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
			<TR>
				<TD COLSPAN="100%">
					<div id="SaveSplitLink" style="display:inline">
					<CF_button
						button_name	=	""
						button_caption	=	"save split"
						button_action	=	"validate('SaveSplitLink')"
						button_type		=	"javascript_link"
						button_width	=	"100"
						button_color	=	"Navy"
						button_tip		=	""
						font_color		=	"White"
						font_size		=	"12"
						font_weight	=	"bold"
									>
					</div>
				</TD>
			</TR>
		</TABLE>

		<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/format_functions.js"/>
		<SCRIPT language="JavaScript">
		function DispTotal()
		{
			var loopCount = document.all.CurLargeSPNumber.value;
			var parentAmt = document.all.BB_Amount.value;
			var totAmount = 0;
			if (loopCount == "")
			{
				loopCount = 1;
			}
			//alert(document.all.CurLargeSPNumber.value)
			for (i=1;i<=loopCount;i++)
			{
				if(eval("document.all.IsDeleted_"+i))
				{
					Deleted = eval("document.all.IsDeleted_"+i+".value");
					childAmount = eval("document.all.Amt_Child_"+i+".value");


					if(childAmount != "" && Deleted == 0)
					{
						totAmount = totAmount + parseFloat(childAmount);
					}
				}
			}
			/*document.all.DySPTotal.innerHTML = "<B>$ " + totAmount + "</B>";
			document.all.DySPTotal.style.color = "red";
			document.all.DySPTotal.style.background = "BBBBFF";*/


			if (parentAmt < formatToDecimalPlaces(totAmount,2))
			{
				showAmount = totAmount - parentAmt;
				showAmount = formatToDecimalPlaces(showAmount, 2);
				showAmount =formatWithComma(showAmount, 3, 1);
				document.all.SPText.innerHTML = "FROM SPLIT AMOUNT:";
				document.all.SPResult.innerHTML = "<B>SUBRACT&nbsp;&nbsp;&nbsp;&nbsp; $ " + showAmount + "</B>";
				document.all.SPText.style.color = "red";
				document.all.SPResult.style.color = "red";
				/*document.all.SPText.style.background = "FAD3FE";
				document.all.SPResult.style.background = "FAD3FE";*/
				totAmount = formatToDecimalPlaces(totAmount, 2);
				totAmount =formatWithComma(totAmount, 3, 1);
				document.all.DySPTotal.innerHTML = "<B>$ " + totAmount + "</B>";
				document.all.DySPTotal.style.color = "red";
				/*document.all.SPTotText.style.background = "BE82F4";
				document.all.DySPTotal.style.background = "BE82F4";*/
			}
			else if (formatToDecimalPlaces(totAmount,2) < parentAmt)
			{
				showAmount = parentAmt - totAmount;
				showAmount = formatToDecimalPlaces(showAmount, 2);
				showAmount =formatWithComma(showAmount, 3, 1);
				document.all.SPText.innerHTML = "TO SPLIT AMOUNT:";
				document.all.SPResult.innerHTML = "<B>ADD&nbsp;&nbsp;&nbsp;&nbsp; $ " + showAmount + "</B>";
				document.all.SPText.style.color = "red";
				document.all.SPResult.style.color = "red";
				/*document.all.SPText.style.background = "FAD3FE";
				document.all.SPResult.style.background = "FAD3FE";*/
				totAmount = formatToDecimalPlaces(totAmount, 2);
				totAmount =formatWithComma(totAmount, 3, 1);
				document.all.DySPTotal.innerHTML = "<B>$ " + totAmount + "</B>";
				document.all.DySPTotal.style.color = "red";
				/*document.all.SPTotText.style.background = "BE82F4";
				document.all.DySPTotal.style.background = "BE82F4";*/
			}
			else
			{
				totAmount = formatToDecimalPlaces(totAmount, 2);
				totAmount =formatWithComma(totAmount, 3, 1);
				document.all.DySPTotal.innerHTML = "<B>$ " + totAmount + "</B>";
				/*document.all.SPTotText.style.background = "";
				document.all.DySPTotal.style.background = "";
				document.all.SPText.style.background = "";
				document.all.SPResult.style.background = "";*/
				document.all.DySPTotal.style.color = "black";
				document.all.SPTR.height="14";
				document.all.SPText.innerHTML = "";
				document.all.SPResult.innerHTML = "";
			}
			//document.all.DySPTotal.style.background = "black";
			//alert(totAmount)
		}
		function ToolTip(rowNumber)
		{
			var loopCount = document.all.CurLargeSPNumber.value;
			var parentAmt = document.all.BB_Amount.value;
			var trObj = document.all.SP_Main_Table.rows[rowNumber];
			var totAmount = 0;
			var childAmount,showAmount,withInLimit;
			var trTitle = "";

			for (i=1;i<=loopCount;i++)
			{
				if(eval("document.all.IsDeleted_"+i))
				{
					Deleted = eval("document.all.IsDeleted_"+i+".value");
					childAmount = eval("document.all.Amt_Child_"+i+".value");

					if (childAmount != "" && Deleted == 0)
					{
						totAmount = totAmount + parseFloat(childAmount);
					}
				}
			}
			if (parentAmt < totAmount)
			{
				showAmount = totAmount - parentAmt;
				showAmount = showAmount.toFixed(2); /// D31229: BBK 1199999 Splits <> Parent cannot add split
				trTitle = "subract: $" + showAmount;
			}
			else if (totAmount < parentAmt)
			{
				showAmount = parentAmt - totAmount;
				showAmount = showAmount.toFixed(2); /// D31229: BBK 1199999 Splits <> Parent cannot add split
				trTitle = "add: $" + showAmount;
			}
			trObj.title = trTitle;
		}

		function validate(divName)
		{
			var Children = document.all.CurLargeSPNumber.value;
			var parentAmt = document.all.BB_Amount.value;
			var Deleted,Amount;
			var totAmount = 0;
			var amountDiff = 0;
			var noOfDeleted = 0;

			for (i=1;i<=Children;i++)
			{
				if(eval("document.all.IsDeleted_"+i))
				{
					Deleted = eval("document.all.IsDeleted_"+i+".value");
					AmountObj = eval("document.all.Amt_Child_"+i)
					Amount = AmountObj.value;
					if (Deleted == 0)
					{
						if(Amount == "" || Amount == 0)
						{
							alert("'Amount' canot be null or zero.");
							AmountObj.focus();
							return;
						}
						else
						{
							totAmount = totAmount + parseFloat(Amount);
						}
					}
					else
					{
						noOfDeleted = noOfDeleted + 1;
					}
				}
			}
			//round amount to two decimal
			totAmount = Math.round(totAmount*100)/100;
			parentAmt = Math.round(parentAmt*100)/100;

			if (parentAmt == totAmount)
			{
				Children = Children - noOfDeleted;
				document.all.NoOfChildren.value = Children;
				document.Sp_Parent.Form_Submitted.value=1;
				document.Sp_Parent.submit()
				disableButton(divName, true, false);
			}
			else if (totAmount < parentAmt)
			{
				amountDiff = parentAmt - totAmount;
				amountDiff = Math.round(amountDiff*100)/100;

				alert("The sum of the split billbacks must equal "+parentAmt+". It is currently "  + amountDiff +  " less than that amount.")
				return;
			}
			else if (totAmount > parentAmt)
			{
				amountDiff = totAmount - parentAmt;
				amountDiff = Math.round(amountDiff*100)/100;

				alert("The sum of the split billbacks must equal "+parentAmt+". It is currently " + amountDiff +  " more than that amount.")
				return;
			}

		}

		function addRow(rowNum)
		{
			var rowNumber = parseInt(rowNum);

			var tabObj = document.all.SP_Main_Table;
			var trObj = tabObj.insertRow(rowNumber);
			var spCount = document.all.CurLargeSPNumber.value;

			if (spCount == "")
			{
				spCount = 2;
			}
			else
			{
				spCount = parseInt(spCount) + 1;
			}

			var chAmt = "Amt_Child_"+spCount;
			var chClosing = "Closing_Method_"+spCount;
			var chShipTo = "Split_Reason_"+spCount;
			var selectString = "";
			var nextRow = rowNumber + 1;
			var passcolor = "c0c0c0";
			var hiddenName = "IsDeleted_"+spCount;
			var isCreatedHidden = "IsCreated_"+spCount;
			var curNoOfChildren = document.all.NoOfChildren.value;

			/* On IE 10, the below line does not work. */
			/* var isCreatedHidden = document.createElement('<input type="hidden" name="'+isCreatedHidden+'" value="1">'); */

			/* On IE 10 and all versions of IE, the below lines works instead */
			var isCreated_Hidden = document.createElement("input");
				isCreated_Hidden.setAttribute("type", "hidden");
				isCreated_Hidden.setAttribute("id", ''+isCreatedHidden+'');
				isCreated_Hidden.setAttribute("name",''+isCreatedHidden+'');
				isCreated_Hidden.setAttribute("value", "1");
			var existingObj = document.getElementById("Form_Submitted"); 
			document.Sp_Parent.insertBefore(isCreated_Hidden,existingObj);

			/* On IE 10, the below line does not work. */
			/* var isdeletedHidden = document.createElement('<input type="hidden" name="'+hiddenName+'" value="0">'); */

			/* On IE 10 and all versions of IE, the below lines works instead */
			var isdeleted_Hidden = document.createElement("input");
				isdeleted_Hidden.setAttribute("type", "hidden");
				isdeleted_Hidden.setAttribute("id", ''+hiddenName+'');
				isdeleted_Hidden.setAttribute("name",''+hiddenName+'');
				isdeleted_Hidden.setAttribute("value", "0");

			document.Sp_Parent.insertBefore(isdeleted_Hidden,existingObj);

			<CFSET CheckThis = "">
			/* Milan-11142 (If the app setting ("billback closing method is deduction by default") is on, then the checkbox is checked by default,
				 unless the user unchecks it for the billback) */
			<CFIF Get_all_Children.BB_Closing_Method EQ 2 OR (Get_all_Children.BB_Closing_Method EQ "" AND appSettings.getBillbackClosingMethod() eq 1)>
				<CFSET CheckThis = "Checked">
			</CFIF>
			//alert(chAmt)


			if (!(rowNumber%2))
			{
				trObj.style.background  = "C6FFC6";
			}

			if (spCount > 9)
			{
				splitNumber = spCount;
			}
			else
			{
				splitNumber = "0"+spCount;
			}

			for(i=0;i<5;i++)
			{
				chNum = i + 1;
				cellObj = trObj.insertCell(i);
				if (i==0)
				{
					cellObj.innerHTML = "<B>" + splitNumber + "</B>";
				}
				else if (i==1)
				{
					cellObj.innerHTML = "<INPUT TYPE=\"text\" SIZE=\"8\" NAME=\""+chAmt+"\" onKeyUp=\"Javascript: clenseText(this, '-0123456789.');limitXdecimalplaces(2, "+chAmt+");DispTotal();\">"//ONCHANGE=\"Javascript: incrementByOne("+i+","+loopEnd+")\"
				}
				else if (i==2)
				{
					cellObj.innerHTML = "<INPUT TYPE=\"checkbox\" VALUE=\"2\" NAME=\""+chClosing+"\" <cfoutput>#CheckThis#</cfoutput>><B>Deduction</B>"//ONCHANGE=\"Javascript: incrementByOne("+i+","+loopEnd+")\"
				}
				else if (i==3)
				{
					cellObj.innerHTML = "<TEXTAREA NAME=\""+ chShipTo +"\" COLS=\"55\" ROWS=\"2\"></TEXTAREA>";
				}
				else if (i==4)
				{
					cellObj.innerHTML = "<A HREF=\"Javascript: undo_redoRow("+rowNum+",'"+passcolor+"',"+spCount+")\"><img src='/Images/scissor.gif' width='14' height='9' title='Remove child' border='0'></A>"
				}
			}
			trObj.cells[1].onmouseover = new Function("ToolTip("+rowNum+")");
			document.all.InsertRowAt.value = nextRow;
			document.all.NoOfChildren.value = parseInt(curNoOfChildren) + 1;
			document.all.CurLargeSPNumber.value = spCount;

	       try { window.parent.dyniframesize(); } catch (err) { };
		}


		function undo_redoRow(rowNum,color,spNum)
		{
			var rowNumber = parseInt(rowNum);
			var AmtObj = "Amt_Child_"+spNum;
			var ShipToObj = "Split_Reason_"+spNum;
			//var AmtObj = eval("document.all."+AmtObj);
			//var ShipToObj = eval("document.all."+ShipToObj);
			//var hiddenName = eval("document.all.IsDeleted_"+spNum);
			
			/// CrhomeFix D57213 replaced above 3 lines
			var AmtObj = document.getElementsByName(AmtObj)[0];//
			var ShipToObj =  document.getElementsByName(ShipToObj)[0];// 		
			var hiddenName =   document.getElementsByName("IsDeleted_"+spNum)[0];//

			trObj= document.all.SP_Main_Table.rows[rowNumber];
			if (color == "c0c0c0")
			{
				passcolor = "ffffff";
			}
			else
			{
				passcolor = "c0c0c0";
			}
			for(i=0;i<5;i++)
			{
				if (i!=4)
				{
					if (color == "c0c0c0")
					{
					trObj.cells[i].style.background  = ""+color+"";
					}
					else
					{
						if (rowNumber%2)
						{
							trObj.cells[i].style.background  = ""+color+"";
						}
						else
						{
							trObj.cells[i].style.background  = "C6FFC6";
						}
					}
				}
				else
				{
					if (color == "c0c0c0")
					{
						trObj.cells[i].innerHTML = "<A HREF=\"Javascript: undo_redoRow("+rowNum+",'"+passcolor+"',"+spNum+")\"><img src='/images/undo.gif' title='Restore child' border='0'></A>"
					}
					else
					{
						trObj.cells[i].innerHTML = "<A HREF=\"Javascript: undo_redoRow("+rowNum+",'"+passcolor+"',"+spNum+")\"><img src='/Images/scissor.gif' width='14' height='9' title='Remove child' border='0'></A>"

					}
				}
				if (i==0)
				{
					if (color == "c0c0c0")
					{
						trObj.cells[i].style.textDecoration = "line-through";
					}
					else
					{
						trObj.cells[i].style.textDecoration = "none";
					}
				}
			}
			AmtObj.style.background  = ""+color+"";
			ShipToObj.style.background  = ""+color+"";

			if (color == "c0c0c0")
			{
				hiddenName.value = 1;
			}
			else
			{
				hiddenName.value = 0;
			}
			DispTotal()
			ToolTip(1)
		}
		</SCRIPT>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Action Part --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFELSE>

	<CFIF FORM.FromSplit EQ 1>


		<CFSET AliveChildCount = 0>
		<CFIF Isdefined("FORM.CurChildren")>
			<CFSET AliveChildCount = FORM.CurChildren>
		</CFIF>

		<cfset BillbackSplitManager = CreateObject("component", "components.billback.BillbackSplitManager").init() />

		<cfset Parent_ID = BillbackSplitManager.SplitBillback(
				billbackID = FORM.BBID,
				form = form,
				splitCount = FORM.CurLargeSPNumber,
				existingChildCount = AliveChildCount
				)>
<!--- START: D41801:  Billback Sales Tax/Anand Rao/26-Mar-2014
	  Check if the Billback's program template has sales tax on it.
--->
	<cfif not isDefined("BBProgramManager")>
		<cfset BBProgramManager = CreateObject("component", "components.Billback.Programs.BillbackProgramsManager") />
	</cfif>
	<cfif not isDefined("Billback_ID")>
		<cfset Billback_ID = FORM.BBID>
	</cfif>
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
	<!--- END: D41801:  Billback Sales Tax/Anand Rao/26-Mar-2014 --->

		<CFQUERY NAME="GetParentInfo" DATASOURCE="#Application.Datasource#">
			SELECT 		ROUND(ISNULL(LumpSum_Amt,0),0) LumpSum_Amt,
						LumpSum_Only,
						BB_Approved.Paid_Amount
			FROM 		Billback_Program
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback_Program.Billback_ID
			WHERE 		Billback_Program.Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
			AND 		Billback_Program.Deleted = 0
		</CFQUERY>

		<CFQUERY NAME="EligibleChildren" DATASOURCE="#Application.Datasource#">
			SELECT 		Billback.Billback_ID,
						BB_Approved.Paid_Amount
			FROM 		Billback
			INNER JOIN 	Billback_Program ON Billback_Program.Billback_ID = Billback.Billback_ID
			INNER JOIN	Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
			INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
			WHERE 		Billback.BB_parent_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND
						Billback.Billback_Status_ID NOT IN (4,5,7) AND
						( 	Billback_Allied.BB_Is_Locked <> 1 OR
							(	Billback_Allied.BB_Is_Locked = 1 AND
								BB_Locked_By_User_ID = <cfqueryparam value="#request.AccessStructure.User_ID#" cfsqltype="CF_SQL_VARCHAR">
							)
						) AND
						Billback.Deleted = 0
			AND 		Billback_Program.Deleted = 0
		</CFQUERY>

		<CFSET EligibleBBList = VALUELIST(EligibleChildren.Billback_ID)>


		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Calculate Sales Tax Split --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<CFIF bBillbackSalesTax EQ 1>
		<!--- <CFIF appSettings.getBillbacksSalesTax() eq 1> --->
			<CFQUERY NAME="ParentSalesTax" DATASOURCE="#Application.Datasource#">
				SELECT 	TotalTaxAmount
				FROM 	Billback
				WHERE 	Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>

			<cfset useLakebaseForParentBBTaxInfo = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
			<cfif useLakebaseForParentBBTaxInfo>
				<cftry>
					<cfset ParentBBTaxInfo = application.oLakebase.toQuery(
						application.oLakebase.selectRows("bb_tax_info", { "billback_id" = "eq.#Parent_ID#", "deleted" = "eq.false" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForParentBBTaxInfo = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForParentBBTaxInfo>
				<CFQUERY NAME="ParentBBTaxInfo" DATASOURCE="#Application.Datasource#">
					SELECT * FROM BB_Tax_Info WHERE Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
				</CFQUERY>
			</cfif>

			<CFLOOP QUERY="EligibleChildren">
				<CFIF ParentSalesTax.TotalTaxAmount NEQ "" OR ParentSalesTax.TotalTaxAmount EQ 0>
					<CFQUERY NAME="UpdateClaimed" DATASOURCE="#Application.Datasource#">
						UPDATE Billback
						SET TotalTaxAmount = ROUND(((#Paid_Amount# * #ParentSalesTax.TotalTaxAmount#) / #GetParentInfo.Paid_Amount#),2)
						WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>
				 </CFIF>
			</CFLOOP>

			<CFIF ParentSalesTax.TotalTaxAmount NEQ "" OR ParentSalesTax.TotalTaxAmount EQ 0>
				<CFQUERY NAME="SplitTotSalesTax" DATASOURCE="#Application.Datasource#">
					SELECT 	SUM(CAST((ISNULL(TotalTaxAmount, 0)) AS decimal(20,0))) Tot_Sales_Tax
					FROM 	Billback
					WHERE 	Billback_ID IN ( SELECT Billback_ID FROM Billback WHERE BB_Parent_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0) AND
							Deleted = 0
				</CFQUERY>

				<CFIF SplitTotSalesTax.Tot_Sales_Tax NEQ ParentSalesTax.TotalTaxAmount>
					<CFSET SalesTaxDiffMakeUp = ParentSalesTax.TotalTaxAmount - SplitTotSalesTax.Tot_Sales_Tax>

					<CFQUERY NAME="MakeUpDiff" DATASOURCE="#Application.Datasource#">
					 	UPDATE Billback
						SET TotalTaxAmount = CAST(TotalTaxAmount AS Decimal(20,0)) + <cfqueryparam value="#SalesTaxDiffMakeUp#" cfsqltype="CF_SQL_FLOAT">
						WHERE Billback_ID = (	SELECT 	TOP 1 Billback_ID FROM Billback
												WHERE 	TotalTaxAmount = (	SELECT MAX(TotalTaxAmount) FROM Billback
																				WHERE Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
																				Deleted = 0
																			) AND

														Billback_ID IN (#LISTQUALIFY(EligibleBBList,"'",",","All")#) AND
														Deleted = 0
													)
					</CFQUERY>
				</CFIF>
			</CFIF>
			<CFIF ParentSalesTax.TotalTaxAmount NEQ "" OR ParentSalesTax.TotalTaxAmount EQ 0>
				<CFLOOP QUERY="EligibleChildren">
					<cfset useLakebaseForCheckforExistance = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
					<cfif useLakebaseForCheckforExistance>
						<cftry>
							<cfset CheckforExistance = application.oLakebase.toQuery(
								application.oLakebase.selectRows("bb_tax_info", { "billback_id" = "eq.#Billback_ID#", "deleted" = "neq.true" })
							)>
							<cfcatch type="any">
								<cfset useLakebaseForCheckforExistance = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForCheckforExistance>
						<CFQUERY NAME="CheckforExistance" DATASOURCE="#Application.Datasource#">
							SELECT * FROM BB_Tax_Info WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted <> 1
						</CFQUERY>
					</cfif>
					<CFIF CheckforExistance.RecordCount EQ 0>
						<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
						<!--- Insert Sales tax info --->
						<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
						<!--- Lakebase migration: intentionally left on SQL Server. This block dynamically
						      discovers BB_Tax_Info's column list via information_schema and copies every
						      column from the parent row via EVALUATE() -- there's no safe mechanical
						      equivalent without re-verifying every column against the Lakebase DDL by hand. --->
						<CFQUERY NAME="Get_Tax_Columns" DATASOURCE="#Application.Datasource#">
							SELECT 		column_name
							FROM 		information_schema.columns
							WHERE 		table_name = 'BB_Tax_Info' AND
										column_name NOT IN ('BB_Tax_Info_ID','Created_Date','Deleted')
						</CFQUERY>

						<CFSET Tax_Column_List = VALUELIST(Get_Tax_Columns.column_name)>
						<CFSET Tax_Column_List_Len = LISTLEN(Tax_Column_List,",")>
						<CFSET TaxColLoopCount = 0>
						<CFSET TaxValueLoopCount = 0>


						<CFQUERY NAME="Parent_Tax_Data" DATASOURCE="#Application.Datasource#">
							SELECT * FROM BB_Tax_Info WHERE Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
						</CFQUERY>

						<CFQUERY NAME="InsertProgData" DATASOURCE="#Application.Datasource#">
							INSERT INTO
							BB_Tax_Info		(
														<CFLOOP LIST="#Tax_Column_List#" INDEX="TaxCount">
															<CFSET TaxColLoopCount = TaxColLoopCount + 1>
															<CFIF TaxCount NEQ "BB_Tax_Info_ID" AND TaxCount NEQ "Created_Date" AND TaxCount NEQ "Deleted">
																<CFIF TaxColLoopCount NEQ Tax_Column_List_Len>
																	#TaxCount#,
																<CFELSE>
																	#TaxCount#
																</CFIF>
															</CFIF>
														</CFLOOP>
													)
							VALUES					(
														<CFLOOP LIST="#Tax_Column_List#" INDEX="TaxCount">
															<CFSET TaxValueLoopCount = TaxValueLoopCount + 1>
															<CFIF TaxCount NEQ "BB_Tax_Info_ID" AND TaxCount NEQ "Created_Date" AND TaxCount NEQ "Deleted">
																<CFIF TaxCount NEQ "Billback_ID" AND TaxCount NEQ "Created_By">
																	<CFIF EVALUATE("Parent_Tax_Data.#TaxCount#") EQ "">
																		NULL<CFIF TaxValueLoopCount NEQ Tax_Column_List_Len>,</CFIF>
																	<CFELSE>
																		'#EVALUATE("Parent_Tax_Data.#TaxCount#")#'<CFIF TaxValueLoopCount NEQ Tax_Column_List_Len>,</CFIF>
																	</CFIF>
																<CFELSE>
																	<CFIF TaxCount EQ "Billback_ID">
																		'#Billback_ID#'<CFIF TaxValueLoopCount NEQ Tax_Column_List_Len>,</CFIF>
																	<CFELSEIF TaxCount EQ "Created_By">
																		'#request.AccessStructure.User_ID#'<CFIF TaxValueLoopCount NEQ Tax_Column_List_Len>,</CFIF>
																	</CFIF>
																</CFIF>
															</CFIF>
														</CFLOOP>
													)
						</CFQUERY>
						<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
					</CFIF>
					<CFQUERY NAME="ChildTotTax" DATASOURCE="#Application.Datasource#">
						SELECT TotalTaxAmount FROM Billback WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
					</CFQUERY>
					<cfparam name="Parent_Tax_Code_1_Domestic_Amount" default="0">
					<cfparam name="Parent_Tax_Code_2_Domestic_Amount" default="0">
					<cfparam name="Parent_Tax_Code_3_Domestic_Amount" default="0">
					<cfparam name="Parent_Tax_Code_1_Domestic_Taxable_Amount" 	default="0">
					<cfparam name="Parent_Tax_Code_2_Domestic_Taxable_Amount" 	default="0">
					<cfparam name="Parent_Tax_Code_3_Domestic_Taxable_Amount" 	default="0">
					<cfparam name="Parent_Tax_Code_1_Foreign_Taxable_Amount"	default="0">
					<cfparam name="Parent_Tax_Code_2_Foreign_Taxable_Amount"	default="0">
					<cfparam name="Parent_Tax_Code_3_Foreign_Taxable_Amount"	default="0">

					<cfif ParentBBTaxInfo.recordCount gt 0>
						<cfset Parent_Tax_Code_1_Domestic_Amount = ParentBBTaxInfo.Tax_Code_1_Domestic_Amount >
						<cfset Parent_Tax_Code_2_Domestic_Amount = ParentBBTaxInfo.Tax_Code_2_Domestic_Amount >
						<cfset Parent_Tax_Code_3_Domestic_Amount = ParentBBTaxInfo.Tax_Code_3_Domestic_Amount >
						<cfset Parent_Tax_Code_1_Domestic_Taxable_Amount = ParentBBTaxInfo.Tax_Code_1_Domestic_Taxable_Amount >
						<cfset Parent_Tax_Code_2_Domestic_Taxable_Amount = ParentBBTaxInfo.Tax_Code_2_Domestic_Taxable_Amount >
						<cfset Parent_Tax_Code_3_Domestic_Taxable_Amount = ParentBBTaxInfo.Tax_Code_3_Domestic_Taxable_Amount >
						<cfset Parent_Tax_Code_1_Foreign_Taxable_Amount = ParentBBTaxInfo.Tax_Code_1_Foreign_Taxable_Amount >
						<cfset Parent_Tax_Code_2_Foreign_Taxable_Amount = ParentBBTaxInfo.Tax_Code_2_Foreign_Taxable_Amount >
						<cfset Parent_Tax_Code_3_Foreign_Taxable_Amount = ParentBBTaxInfo.Tax_Code_3_Foreign_Taxable_Amount >
					</cfif>
					<!--- Lakebase migration: intentionally left on SQL Server. The ROUND()/division math
					      below executes server-side in T-SQL; re-implementing it in CFML risks subtle
					      floating-point rounding mismatches in tax figures without real data to verify against. --->
					<CFQUERY NAME="UpdateTaxValue" DATASOURCE="#Application.Datasource#">
						UPDATE BB_Tax_Info
						SET Tax_Code_1_Domestic_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_1_Domestic_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_2_Domestic_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_2_Domestic_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_3_Domestic_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_3_Domestic_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_1_Domestic_Taxable_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_1_Domestic_Taxable_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_2_Domestic_Taxable_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_2_Domestic_Taxable_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_3_Domestic_Taxable_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_3_Domestic_Taxable_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_1_Foreign_Taxable_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_1_Foreign_Taxable_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_2_Foreign_Taxable_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_2_Foreign_Taxable_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>,
							Tax_Code_3_Foreign_Taxable_Amount = <cfif ParentSalesTax.TotalTaxAmount gt 0>ROUND(((#ChildTotTax.TotalTaxAmount# * #Parent_Tax_Code_3_Foreign_Taxable_Amount#) / #ParentSalesTax.TotalTaxAmount#),2)<cfelse>0</cfif>
						WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
					</CFQUERY>

					<cfset useLakebaseForCheckSum = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
					<cfif useLakebaseForCheckSum>
						<cftry>
							<cfset CheckSum = application.oLakebase.toQuery(
								application.oLakebase.selectRows("bb_tax_info", {
									"select"      = "tax_code_1_domestic_amount,tax_code_2_domestic_amount,tax_code_3_domestic_amount",
									"billback_id" = "eq.#Billback_ID#",
									"deleted"     = "eq.false"
								}),
								"tax_code_1_domestic_amount,tax_code_2_domestic_amount,tax_code_3_domestic_amount"
							)>
							<!--- Lakebase has no ISNULL(); coerce nulls to 0 here to match the original SQL. --->
							<cfset querySetCell(CheckSum, "Tax_Code_1_Domestic_Amount", val(CheckSum.Tax_Code_1_Domestic_Amount))>
							<cfset querySetCell(CheckSum, "Tax_Code_2_Domestic_Amount", val(CheckSum.Tax_Code_2_Domestic_Amount))>
							<cfset querySetCell(CheckSum, "Tax_Code_3_Domestic_Amount", val(CheckSum.Tax_Code_3_Domestic_Amount))>
							<cfcatch type="any">
								<cfset useLakebaseForCheckSum = false>
							</cfcatch>
						</cftry>
					</cfif>
					<cfif NOT useLakebaseForCheckSum>
						<CFQUERY NAME="CheckSum" DATASOURCE="#Application.Datasource#">
							SELECT 	ISNULL(Tax_Code_1_Domestic_Amount,0) Tax_Code_1_Domestic_Amount,
									ISNULL(Tax_Code_2_Domestic_Amount,0) Tax_Code_2_Domestic_Amount,
									ISNULL(Tax_Code_3_Domestic_Amount,0) Tax_Code_3_Domestic_Amount
							FROM 	BB_Tax_Info
							WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
						</CFQUERY>
					</cfif>

					<CFSET ChTotTaxAmount = 0>
					<CFSET ChTotTaxAmount = CheckSum.Tax_Code_1_Domestic_Amount + CheckSum.Tax_Code_2_Domestic_Amount + CheckSum.Tax_Code_3_Domestic_Amount>

					<CFIF ChTotTaxAmount NEQ ChildTotTax.TotalTaxAmount>
						<CFSET ChTaxDiffMakeUp = ChildTotTax.TotalTaxAmount - ChTotTaxAmount>

						<CFSET HighTax = 1>
						<CFSET HighTaxAmt = CheckSum.Tax_Code_1_Domestic_Amount>
						<CFIF CheckSum.Tax_Code_2_Domestic_Amount GT CheckSum.Tax_Code_1_Domestic_Amount>
							<CFSET HighTax = 2>
							<CFSET HighTaxAmt = CheckSum.Tax_Code_2_Domestic_Amount>
						</CFIF>
						<CFIF CheckSum.Tax_Code_3_Domestic_Amount GT HighTaxAmt>
							<CFSET HighTax = 3>
							<CFSET HighTaxAmt = CheckSum.Tax_Code_3_Domestic_Amount>
						</CFIF>

						<cfset NewDomestic1 = CheckSum.Tax_Code_1_Domestic_Amount + (HighTax EQ 1 ? ChTaxDiffMakeUp : 0)>
						<cfset NewDomestic2 = CheckSum.Tax_Code_2_Domestic_Amount + (HighTax EQ 2 ? ChTaxDiffMakeUp : 0)>
						<cfset NewDomestic3 = CheckSum.Tax_Code_3_Domestic_Amount + (HighTax EQ 3 ? ChTaxDiffMakeUp : 0)>

						<cfset useLakebaseForTotMakeUp = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
						<cfif useLakebaseForTotMakeUp>
							<cftry>
								<cfset application.oLakebase.updateRows("bb_tax_info",
									{ "billback_id" = "eq.#Billback_ID#", "deleted" = "eq.false" },
									{
										"tax_code_1_domestic_amount" = NewDomestic1,
										"tax_code_2_domestic_amount" = NewDomestic2,
										"tax_code_3_domestic_amount" = NewDomestic3
									}
								)>
								<cfcatch type="any">
									<cfset useLakebaseForTotMakeUp = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForTotMakeUp>
							<CFIF HighTax EQ 1>
								<CFQUERY NAME="TotMakeUp" DATASOURCE="#Application.Datasource#">
									UPDATE BB_Tax_Info
									SET Tax_Code_1_Domestic_Amount = Tax_Code_1_Domestic_Amount + <cfqueryparam value="#ChTaxDiffMakeUp#" cfsqltype="CF_SQL_FLOAT">
									WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
								</CFQUERY>
							<CFELSEIF HighTax EQ 2>
								<CFQUERY NAME="TotMakeUp" DATASOURCE="#Application.Datasource#">
									UPDATE BB_Tax_Info
									SET Tax_Code_2_Domestic_Amount = Tax_Code_2_Domestic_Amount + <cfqueryparam value="#ChTaxDiffMakeUp#" cfsqltype="CF_SQL_FLOAT">
									WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
								</CFQUERY>
							<CFELSE>
								<CFQUERY NAME="TotMakeUp" DATASOURCE="#Application.Datasource#">
									UPDATE BB_Tax_Info
									SET Tax_Code_3_Domestic_Amount = Tax_Code_3_Domestic_Amount + <cfqueryparam value="#ChTaxDiffMakeUp#" cfsqltype="CF_SQL_FLOAT">
									WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
								</CFQUERY>
							</CFIF>
						</cfif>

						<cfset useLakebaseForUpdateForeign = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_tax_info")>
						<cfif useLakebaseForUpdateForeign>
							<cftry>
								<cfset application.oLakebase.updateRows("bb_tax_info",
									{ "billback_id" = "eq.#Billback_ID#", "deleted" = "eq.false" },
									{
										"tax_code_1_foreign_amount" = NewDomestic1,
										"tax_code_2_foreign_amount" = NewDomestic2,
										"tax_code_3_foreign_amount" = NewDomestic3
									}
								)>
								<cfcatch type="any">
									<cfset useLakebaseForUpdateForeign = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForUpdateForeign>
						<CFQUERY NAME="UpdateForeign" DATASOURCE="#Application.Datasource#">
							UPDATE BB_Tax_Info
							SET Tax_Code_1_Foreign_Amount = Tax_Code_1_Domestic_Amount,
								Tax_Code_2_Foreign_Amount = Tax_Code_2_Domestic_Amount,
								Tax_Code_3_Foreign_Amount = Tax_Code_3_Domestic_Amount
							WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
						</CFQUERY>
						</cfif>
					</CFIF>
				</CFLOOP>
			</CFIF>
		</CFIF>
		<!--- vvvvvvvvvvvvvvvvvv End Sales Tax Split vvvvvvvvvvvvvvvvvvvvvv --->


		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- AllowanceCode_Allocation Start --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- Ana: Commented it based on label 9892 --->
		<!--- <CFIF appSettings.getOperatingGroupOn()>
			<cfif appSettings.getBillbacksSalesTax()>
				<cfset BillbackAllowanceCodeManager = CreateObject("component", "components.Billback.BillbackAllowanceCodeManager").init() />
			</cfif>
			<CFLOOP QUERY="EligibleChildren">
				<CFQUERY NAME="DeletePre" DATASOURCE="#Application.Datasource#">
					DELETE FROM BB_AllowanceCode_Allocation_Summary WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
				</CFQUERY>
				<CFQUERY NAME="InsBAAS" DATASOURCE="#Application.Datasource#">
					INSERT INTO BB_AllowanceCode_Allocation_Summary (Billback_ID,
					Allowance_Code_ID,AllowanceCode_level_Sum,
					Allocated_Amount)
					SELECT '#Billback_ID#',
					Allowance_Code_ID,AllowanceCode_level_Sum,
					(Allocated_Amount * #Paid_Amount#)/#GetParentInfo.Paid_Amount#
					FROM BB_AllowanceCode_Allocation_Summary BAAS
					WHERE BAAS.Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
					AND AllowanceCode_level_Sum = 1 AND Deleted = 0
				</CFQUERY>

				<CFQUERY NAME="AllocatedAmt_Rounding" DATASOURCE="#Application.Datasource#">
					UPDATE BB_AllowanceCode_Allocation_Summary
					SET Allocated_Amount = (
					Allocated_Amount + (CAST(Paid_Amount AS Decimal(18,2)) -
					(
					SELECT SUM(Allocated_Amount)
					FROM BB_AllowanceCode_Allocation_Summary BAAS1
					WHERE BAAS1.Billback_ID = BAAS.Billback_ID AND AllowanceCode_level_Sum = 1 AND Deleted = 0
					)))
					FROM BB_AllowanceCode_Allocation_Summary BAAS
					INNER JOIN BB_Approved ON BB_Approved.Billback_ID = BAAS.Billback_ID
					WHERE BAAS.Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND AllowanceCode_level_Sum = 1 AND Deleted = 0 AND
					BAAS.BB_AllowanceCode_Allocation_Summary_ID = (SELECT TOP 1(BB_AllowanceCode_Allocation_Summary_ID)
					FROM BB_AllowanceCode_Allocation_Summary BAAS2 WHERE BAAS2.Billback_ID = BAAS.Billback_ID AND BAAS2.AllowanceCode_level_Sum = 1 AND
					BAAS2.Deleted = 0 AND Allocated_Amount = (SELECT MAX(Allocated_Amount) FROM BB_AllowanceCode_Allocation_Summary BAAS3
					WHERE BAAS3.Billback_ID = BAAS2.Billback_ID AND BAAS3.AllowanceCode_level_Sum = 1 AND
					BAAS3.Deleted = 0)
					)
				</CFQUERY>
				<cfif appSettings.getBillbacksSalesTax()>
					<CFSET BillbackAllowanceCodeManager.AllocateTaxAmount(Billback_ID) />
				</cfif>
			</CFLOOP>
		</CFIF> --->
		<!--- vvvvvvvvvvvvvvvvv End AllowanceCode Allocationvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvv Automatically allocate GL Code values - Start vvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!----TODO: need to spend some more time to move inside splitbillback function ----->
		<CFIF application.returned_customer_setting.Show_Fund_Settings EQ 1 AND application.returned_customer_setting.Upload_GL_Code EQ 1>

			<CFQUERY NAME="CheckFundAllocation" DATASOURCE="#Application.Datasource#">
				SELECT TOP 1 * FROM Gl_Code_Allocation
				WHERE 	Billback_ID = <cfqueryparam value="#Parent_ID#" cfsqltype="CF_SQL_VARCHAR">
				AND		Allocation_Method = 3
				AND 	Deleted = 0
			</CFQUERY>
			<CFIF CheckFundAllocation.RecordCount GT 0>
			<cfinclude template="/GL_Code/GL_Code_IN_Billback/Fund_Allocation_For_Split_Child.cfm" />
			</CFIF>
		</CFIF>
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvv Automatically allocate GL Code values - End vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
		<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->



		<CFQUERY NAME="checkThisBillbackDeletedBit" DATASOURCE="#Application.Datasource#">
			SELECT * FROM Billback WHERE Billback_ID = <cfqueryparam value="#BBID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted=0
		</CFQUERY>

		<cfif NOT IsDefined("fromBBDedAssoc") OR fromBBDedAssoc EQ 0>
		<CFIF checkThisBillbackDeletedBit.recordcount EQ 0>
			<SCRIPT language="JavaScript">
				function relocate()
				{
					window.parent.location.href="/Billbacks/scorecard/scorecard_main.cfm?SECTION_TO_OPEN=3";
				}
				relocate();
			</SCRIPT>
		<CFELSE>
			<SCRIPT language="JavaScript">
				function relocate()
				{
					window.location.href="Split_BB_History.cfm?<CFOUTPUT>Billback_ID=#BBID#</CFOUTPUT>";
				}
				relocate();
			</SCRIPT>
		</CFIF>
		</cfif>

	</CFIF><!----- <CFIF FORM.FromSplit EQ 1> ----->
</CFIF>
<script>
	try { window.parent.dyniframesize(); } catch (err) { };
</script>
</body>
</html>

