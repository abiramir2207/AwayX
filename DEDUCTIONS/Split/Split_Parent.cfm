<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
	<script type="text/javascript" language="JavaScript1.2" src="/script/javascript/dhtml.js"></script>
</head>

<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>

<body>

<CFINCLUDE TEMPLATE="/get_access_profile.cfm">

<cfset useLakebaseForDeductionsProfilesSettings = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions_profiles_settings")>
<cfif useLakebaseForDeductionsProfilesSettings>
	<cftry>
		<cfset DeductionsProfilesSettings = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions_profiles_settings", { "profiles_id" = "eq.#Get_Profile_Settings.Profiles_ID#" })
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeductionsProfilesSettings = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeductionsProfilesSettings>
	<cfquery name="DeductionsProfilesSettings" datasource="#application.datasource#">
		SELECT * FROM Deductions_Profiles_Settings WHERE Profiles_ID = '#Get_Profile_Settings.Profiles_ID#'
	</cfquery>
</cfif>

<CFPARAM NAME="FORM.Form_Submitted" DEFAULT="">

<CFIF Form_Submitted EQ "">
	
	<cfparam name="variables.validSplits" default="1" />

	<cfset useLakebaseForGetDDDetails = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForGetDDDetails>
		<cftry>
			<cfset Get_DD_Details = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#URL.Deduction_ID#", "deleted" = "eq.false" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForGetDDDetails = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForGetDDDetails>
		<cfset useLakebaseForGet_DD_Details = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForGet_DD_Details>
	<cftry>
		<cfset Get_DD_Details = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"deduction_id" = "eq.#URL.Deduction_ID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGet_DD_Details = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGet_DD_Details>
<CFQUERY NAME="Get_DD_Details" DATASOURCE="#Application.Datasource#">
			SELECT 	*
			FROM 	Deductions
			WHERE 	Deduction_ID = '#URL.Deduction_ID#' AND
					Deleted = 0
		</CFQUERY>
</cfif>
	</cfif>

	<cfset useLakebaseForCheckForChild = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForCheckForChild>
		<cftry>
			<cfset Check_for_Child = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", { "dd_dedid" = "eq.#Get_DD_Details.DD_DedID#", "deleted" = "eq.false" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForCheckForChild = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForCheckForChild>
		<cfset useLakebaseForCheck_for_Child = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForCheck_for_Child>
	<cftry>
		<cfset Check_for_Child = application.oLakebase.toQuery(
			application.oLakebase.selectRows("deductions", {
				"dd_dedid" = "eq.#Get_DD_Details.DD_DedID#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheck_for_Child = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheck_for_Child>
<CFQUERY NAME="Check_for_Child" DATASOURCE="#Application.Datasource#">
			SELECT 	*
			FROM 	Deductions
			WHERE 	DD_DedID = '#Get_DD_Details.DD_DedID#' AND
					Deleted = 0
		</CFQUERY>
</cfif>
	</cfif>
	
	<CFIF Check_for_Child.recordcount GT 1>
		<CFPARAM NAME="URL.Mode" DEFAULT="Edit">
	<CFELSE>
		<CFPARAM NAME="URL.Mode" DEFAULT="">
	</CFIF>
	
	<CFIF URL.Mode NEQ "">
		<CFSET Parent = Get_DD_Details.DD_Parent_ID>
		<CFIF Get_DD_Details.SP_Number NEQ "">
			<CFSET URL_DD_IsParent = 0>
		<CFELSE>
			<CFSET URL_DD_IsParent = 1>
		</CFIF>
		
		<CFIF URL_DD_IsParent EQ 0>
			<cfset useLakebaseForGetDDDetailsParent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
			<cfif useLakebaseForGetDDDetailsParent>
				<cftry>
					<cfset Get_DD_Details = application.oLakebase.toQuery(
						application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#Parent#", "deleted" = "eq.false" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForGetDDDetailsParent = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForGetDDDetailsParent>
				<CFQUERY NAME="Get_DD_Details" DATASOURCE="#Application.Datasource#">
					SELECT 	*
					FROM 	Deductions
					WHERE	Deduction_ID = '#Parent#' AND
							Deleted = 0
				</CFQUERY>
			</cfif>
		</CFIF>
		<CFQUERY NAME="Get_all_Children" DATASOURCE="#Application.Datasource#">
			SELECT 		*
			FROM 		Deductions
			<!--- LEFT JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Deductions.Distributor_ID AND BSA_Foodservice_Customers.deleted=0 --->
			WHERE 		DD_DedID = '#Get_DD_Details.DD_DedID#' AND 
						Deductions.Deleted = 0 AND 
						SP_Number is not null 
			ORDER BY 	SP_Number
		</CFQUERY>
		
		<!---TSF - Label 14245: Set up a validSplits variable and default it to 1. Set it to 0 if spits are not allowed to be deleted--->
		<CFLOOP QUERY="Get_all_Children">
			<CFIF DD_Status GT 3 AND DD_Status NEQ 7 and DD_Status NEQ 8>
				<cfset variables.validSplits = 0 />
				<cfbreak />
			</CFIF>
		</CFLOOP>
	
		<CFSET Record_count = Get_all_Children.RecordCount>	
	</CFIF>
	
	<CFQUERY NAME="GetMaxSPNumber" DATASOURCE="#Application.Datasource#">
		SELECT Max(cast(SP_Number as int)) MaxSP FROM Deductions WHERE DD_DedID = '#Get_DD_Details.DD_DedID#' AND Deleted = 0
	</CFQUERY>	
	
	<CFIF GetMaxSPNumber.recordcount GT 0>
		<CFSET LastSPNumber = Val(GetMaxSPNumber.MaxSP) />	
		<cfif LastSPNumber EQ 0>
			<cfset LastSPNumber = "" />
		</cfif>
		<CFSET LastSPNumber = TRIM(LastSPNumber)>
	<CFELSE>
		<CFSET LastSPNumber = 0>
	</CFIF>
	
</CFIF>

<STYLE>
TABLE.underline TD 
{
	border-bottom:solid #C0C0C0 1px; 
}
td
{
	font-size: 9px;
}
input, select
{
	font-size: 9px;
}
</STYLE>
<CFIF Form_Submitted EQ "">

	<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>
	<BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="100%">
	
		<TR>
			<TD ALIGN="Center" colspan="100%"><B>SPLIT <CFIF Get_DD_Details.Is_Credit EQ 1>CREDIT<CFELSE>DEDUCTION</CFIF> </B><BR><BR></TD>
		</TR>
			
		<TR>
			<TD>
				<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0">
					<TR>
						<TD WIDTH="125">ORIGINAL DEDUCTION:</TD>
						<TD><B><CFOUTPUT>#Get_DD_Details.DD_DedID#</CFOUTPUT> - 000</B></TD>
					</TR>
					<TR>
						<TD>ORIGINAL AMOUNT:</TD>
						<TD><CFOUTPUT><B> #DollarFormat(Get_DD_Details.DD_Amount)#</B></CFOUTPUT></TD>
					</TR>	
					<TR>
						<TD ID="SPTotText">SPLIT TOTAL AMOUNT:</TD>
						<CFSET SP_Total = 0>	
						<CFIF Isdefined("Record_count")>	
						<CFOUTPUT QUERY="Get_all_Children">
							<CFSET SP_Total = SP_Total + DD_Amount>	
						</CFOUTPUT>			
						</CFIF>		
										
						<TD ID="DySPTotal">
							<CFIF SP_Total LT Get_DD_Details.DD_Amount><FONT COLOR="Red"></CFIF><B><CFOUTPUT>#DollarFormat(SP_Total)#</CFOUTPUT></B><CFIF SP_Total LT Get_DD_Details.DD_Amount></FONT></CFIF>
						</TD>
					</TR>	
					<TR ID="SPTR">				
						<TD ID="SPText">
							<CFIF SP_Total LT Get_DD_Details.DD_Amount><FONT COLOR="Red">TO SPLIT AMOUNT:</FONT></CFIF>&nbsp;
						</TD>
						<TD ID="SPResult">
							<CFIF SP_Total LT Get_DD_Details.DD_Amount>
								<CFSET AmtDiff = Get_DD_Details.DD_Amount - SP_Total>
								<FONT COLOR="Red"><B>ADD&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<CFOUTPUT>$ #DollarFormat(AmtDiff)#</CFOUTPUT></B></FONT>&nbsp;
							</CFIF>
						</TD>
					</TR>
				</TABLE>
			</TD>
			<td align="center" valign="bottom">
				<A HREF="Javascript: addRow(document.all.InsertRowAt.value);"><img src="/images/plus4.gif" border="0" title="Add another child"></A><br>
				<b>Click to add rows</b>
			</td>
		</TR>			
	</TABLE>
	<br />
	<CFSET SetTRCount = 2>					
	<CFIF isDefined("Record_count")>				
		<CFSET SetTRCount = Record_count + 1>
	</CFIF>
			
	<CFQUERY NAME="GetAllClass" DATASOURCE="#Application.Datasource#">
		SELECT * FROM DD_Classification WHERE Deleted = 0 ORDER BY DD_Classification_Desc
	</CFQUERY>
	<cfset useLakebaseForSavedClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
	<cfif useLakebaseForSavedClass>
		<cftry>
			<cfset SavedClass = application.oLakebase.toQuery(
				application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#Get_DD_Details.Deduction_ID#", "select" = "dd_classification_id" })
			)>
			<cfcatch type="any">
				<cfset useLakebaseForSavedClass = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForSavedClass>
		<CFQUERY NAME="SavedClass" DATASOURCE="#Application.Datasource#">
			SELECT DD_Classification_ID FROM Deductions WHERE Deduction_ID = '#Get_DD_Details.Deduction_ID#'
		</CFQUERY>
	</cfif>
	
	<FORM NAME="Sp_Parent" ACTION="/deductions/split/Split_Parent.cfm" METHOD="Post" onSubmit="return validate()">
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center" ID="SP_Main_Table" CLASS="underline" WIDTH="100%">		
	<INPUT TYPE="Hidden" NAME="Form_Submitted" VALUE="0">		
	
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="InsertRowAt" VALUE="#SetTRCount#">
	<INPUT TYPE="Hidden" NAME="CurLargeSPNumber" VALUE="#LastSPNumber#">
	<INPUT TYPE="Hidden" NAME="FromSplit" VALUE="#URL.FromSplit#">
	<INPUT TYPE="Hidden" NAME="DD_ID" VALUE="#URL.Deduction_ID#">
	<INPUT TYPE="Hidden" NAME="DD_Number" VALUE="#Get_DD_Details.DD_DedID#">
	<INPUT TYPE="Hidden" NAME="DD_Amount" VALUE="#Get_DD_Details.DD_Amount#">
	<INPUT TYPE="Hidden" NAME="DeleteAll" VALUE="0">		
	</CFOUTPUT>
	
		<TR BGCOLOR="FFE083">
			<TD>
				<!---TSF - Label 14245: Display the remove all splits only if all the splits are not closed--->
				<cfif variables.validSplits>
					<A HREF="Javascript: undo_redoAll(1);"><img src="/Images/scissor.gif" width="14" height="9" title="Remove All" border="0"></A>
				</cfif>
			</TD>
			<td>&nbsp;
				 
			</td>
			<TD><B>Amount</B></TD>
			<TD><B>Split Reason</B></TD>
			<cfif appSettings.getDD_Show_Classification()><TD><B>Classification</B></TD></cfif>	
		</TR>				
		<CFIF URL.Mode EQ "">
			<INPUT TYPE="Hidden" NAME="IsDeleted_1" VALUE="0">
			<INPUT TYPE="Hidden" NAME="IsCreated_1" VALUE="1">
			<INPUT TYPE="Hidden" NAME="NoOfChildren" VALUE="1">
			<TR sp_number="1">
				<TD><A HREF="Javascript: undo_redoRow(1,'c0c0c0',1);"><img  src="/Images/scissor.gif" width="14" height="9" title="Remove split" border="0"></A>&nbsp;</TD>
				<TD><B>001</B></TD>
				<TD ONMOUSEOVER="Javascript: ToolTip(1)"><INPUT TYPE="Text" NAME="Amt_Child_1" VALUE="" SIZE="8" <CFIF Get_DD_Details.Is_Credit EQ 1 AND NOT appSettings.getDD_Negative_Splits()>onKeyUp="clenseText(this, '0123456789.-');limitXdecimalplaces(2, Amt_Child_1);DispTotal();" ONBLUR="checkNeg(this)"<CFELSEIF appSettings.getDD_Negative_Splits()>onKeyUp="clenseText(this, '0123456789.-');limitXdecimalplaces(2, Amt_Child_1);DispTotal();";<CFELSE>onKeyUp="clenseText(this, '0123456789.');limitXdecimalplaces(2, Amt_Child_1);DispTotal();"</CFIF>></TD>
				<TD><TEXTAREA NAME="Split_Reason_1" COLS="40" ROWS="2" onPaste="javaScript: return textareaChecklength('500', this);"  onkeyPress="javaScript: return textareaChecklength('500', this);"></TEXTAREA></TD>	
			
			<cfif appSettings.getDD_Show_Classification()>	
			<td>
				<SELECT NAME="DD_Classification_ID_1">
					<cfoutput QUERY="GetAllClass">
						<OPTION VALUE="#DD_Classification_ID#" <CFIF DD_Classification_ID EQ SavedClass.DD_Classification_ID>SELECTED</CFIF>>#DD_Classification_Desc#</OPTION>						
					</cfoutput>
				</SELECT>
			</td>
			</cfif>						
			</TR>	
		<CFELSE>	
			<INPUT TYPE="Hidden" NAME="Mode" VALUE="Edit">							
			<CFIF Get_all_Children.recordcount EQ 0>
				<INPUT TYPE="Hidden" NAME="IsDeleted_1" VALUE="0">
				<INPUT TYPE="Hidden" NAME="IsCreated_1" VALUE="1">
				<INPUT TYPE="Hidden" NAME="NoOfChildren" VALUE="1">
				<TR sp_number="1">
					<TD><A HREF="Javascript: undo_redoRow(1,'c0c0c0',1);"><img src="Images/scissor.gif" width="14" height="9" title="Remove child" border="0"></A>&nbsp;</TD>
					<TD><B>001</B></TD>
					<TD ONMOUSEOVER="Javascript: ToolTip(1)"><INPUT TYPE="Text" NAME="Amt_Child_1" VALUE="" SIZE="8" <CFIF Get_DD_Details.Is_Credit EQ 1 AND NOT appSettings.getDD_Negative_Splits()>onKeyUp="clenseText(this, '0123456789.-');limitXdecimalplaces(2, Amt_Child_1);DispTotal();" ONBLUR="checkNeg(this);"<CFELSEIF appSettings.getDD_Negative_Splits()>onKeyUp="clenseText(this, '0123456789.-');limitXdecimalplaces(2, Amt_Child_1);DispTotal();";<CFELSE>onKeyUp="clenseText(this, '0123456789.');limitXdecimalplaces(2, Amt_Child_1);DispTotal();"</CFIF>></TD>
					<TD><TEXTAREA NAME="Split_Reason_1" COLS="40" ROWS="2" onPaste="javaScript: return textareaChecklength('500', this);"  onkeyPress="javaScript: return textareaChecklength('500', this);"></TEXTAREA></TD>	
		
					<cfif appSettings.getDD_Show_Classification()>	
					<td>
						<SELECT NAME="DD_Classification_ID_1">
							<cfoutput QUERY="GetAllClass">
								<OPTION VALUE="#DD_Classification_ID#" <CFIF DD_Classification_ID EQ SavedClass.DD_Classification_ID>SELECTED</CFIF>>#DD_Classification_Desc#</OPTION>						
							</cfoutput>
						</SELECT>
					</td>
					</cfif>				
				</TR>	
			<CFELSE>
				<CFOUTPUT>							
					<INPUT TYPE="Hidden" NAME="CurChildren" VALUE="#LastSPNumber#">				
					<INPUT TYPE="Hidden" NAME="NoOfChildren" VALUE="#Get_all_Children.RecordCount#">
				</CFOUTPUT>
				<CFOUTPUT QUERY="Get_all_Children">		
					<CFSET LastDigitSPNumber = Val(SP_Number) />	
					<CFSET LastDigitSPNumber = TRIM(LastDigitSPNumber)>

					<CFSET AccessPremission = 0>
					<CFIF (DD_Status GT 3 AND DD_Status NEQ 7 and DD_Status NEQ 8) OR DD_Closure_ID NEQ "">
						<CFSET AccessPremission = 0>	
					<CFELSE>
						<CFIF Analyst_User_ID EQ request.AccessStructure.User_ID>
							<CFIF Is_Locked EQ 1>
								<CFIF Locked_By EQ request.AccessStructure.User_ID>
									<CFSET AccessPremission = 1>
								</CFIF>
							<CFELSE>
								<CFSET AccessPremission = 1>					
							</CFIF>
						<CFELSEIF DeductionsProfilesSettings.DD_Approve EQ 1>
							<cfset useLakebaseForIsDeductionAnalyst = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_analyst")>
<cfif useLakebaseForIsDeductionAnalyst>
	<cftry>
		<cfset IsDeductionAnalyst = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_analyst", {
				"analyst_user_id" = "eq.#request.AccessStructure.User_ID#",
				"deleted" = "eq.0",
				"is_supervisor" = "neq.1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForIsDeductionAnalyst = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForIsDeductionAnalyst>
<CFQUERY NAME="IsDeductionAnalyst" DATASOURCE="#Application.Datasource#">
								SELECT * FROM DD_Analyst WHERE Analyst_User_ID = '#request.AccessStructure.User_ID#' AND Deleted=0 AND Is_Supervisor <> 1
							</CFQUERY>
</cfif>
							<CFIF IsDeductionAnalyst.Recordcount EQ 0>
								<CFSET AccessPremission = 1>
							</CFIF>						
						</CFIF>
					</CFIF>
					<cfset Distributor = Distributor_ID>
					<INPUT TYPE="Hidden" NAME="Child_ID_#LastDigitSPNumber#" VALUE="#SP_Number#">
					<INPUT TYPE="Hidden" NAME="IsDeleted_#LastDigitSPNumber#" VALUE="0">
					<INPUT TYPE="Hidden" NAME="IsCreated_#LastDigitSPNumber#" VALUE="0">
					<TR sp_number="#LastDigitSPNumber#" <CFIF AccessPremission EQ 0>BGCOLOR="Silver"<CFELSE>bgcolor="#iif(CurrentRow Mod 2, de('ffffff'), de('C6FFC6'))#"</CFIF>>
						<TD>
							<CFIF AccessPremission EQ 0>
								<img src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0">
							<CFELSE>									
								<A HREF="Javascript: undo_redoRow(#currentrow#,'c0c0c0', '#LastDigitSPNumber#');"><img src="/Images/scissor.gif" width="14" height="9" title="Remove entry" border="0"></A>
							</CFIF>&nbsp;
						</TD>	
						<TD><B>#SP_Number#</B></TD>
						<TD <CFOUTPUT>ONMOUSEOVER="Javascript: ToolTip(#CurrentRow#)"</CFOUTPUT>>
							<CFIF AccessPremission EQ 1>
								<INPUT TYPE="Text" NAME="Amt_Child_#LastDigitSPNumber#" VALUE="#DD_Amount#" SIZE="8" <CFIF Get_DD_Details.Is_Credit EQ 1 AND NOT appSettings.getDD_Negative_Splits()>onKeyUp="clenseText(this, '0123456789.-');DispTotal();" ONBLUR="checkNeg(this)"<CFELSEIF appSettings.getDD_Negative_Splits()>onKeyUp="clenseText(this, '0123456789.-');DispTotal();";<CFELSE>onKeyUp="clenseText(this, '0123456789.');DispTotal();"</CFIF>>
							<CFELSE>
								#DD_Amount#
								<INPUT TYPE="Hidden" NAME="Amt_Child_#LastDigitSPNumber#" VALUE="#DD_Amount#">
							</CFIF>															
						</TD>							
						<TD>
							<CFIF AccessPremission EQ 1>
								<TEXTAREA NAME="Split_Reason_#LastDigitSPNumber#" COLS="40" ROWS="2" onPaste="javaScript: return textareaChecklength('500', this);"  onkeyPress="javaScript: return textareaChecklength('500', this);">#SP_Reason#</TEXTAREA>
							<CFELSE>
								<INPUT TYPE="Hidden" NAME="Split_Reason_#LastDigitSPNumber#" VALUE="#SP_Reason#">
								<CFIF SP_Reason NEQ "">
									#SP_Reason#
								<CFELSE>
									None.
								</CFIF>
							</CFIF>																
						</TD>
						
						<cfset useLakebaseForChildSavedClass = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
						<cfif useLakebaseForChildSavedClass>
							<cftry>
								<cfset ChildSavedClass = application.oLakebase.toQuery(
									application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#Get_all_Children.Deduction_ID#", "select" = "dd_classification_id" })
								)>
								<cfcatch type="any">
									<cfset useLakebaseForChildSavedClass = false>
								</cfcatch>
							</cftry>
						</cfif>
						<cfif NOT useLakebaseForChildSavedClass>
							<CFQUERY NAME="ChildSavedClass" DATASOURCE="#Application.Datasource#">
							SELECT DD_Classification_ID FROM Deductions WHERE Deduction_ID = '#Get_all_Children.Deduction_ID#'
							</CFQUERY>
						</cfif>
						
						<cfif appSettings.getDD_Show_Classification()>	
						<td>
							<SELECT NAME="DD_Classification_ID_#LastDigitSPNumber#">
								<cfloop QUERY="GetAllClass">
									<OPTION VALUE="#DD_Classification_ID#" <CFIF DD_Classification_ID EQ ChildSavedClass.DD_Classification_ID>SELECTED</CFIF>>#DD_Classification_Desc#</OPTION>						
								</cfloop>
							</SELECT>
						</td>
						</cfif>										
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
				<CF_button
					button_name	=	""
					button_caption	=	"save"
					button_action	=	"validate(1, '_table')"
					button_type		=	"javascript_link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight	=	"bold"
								>
			</TD>
		</TR>
	</TABLE>
			
	<SCRIPT SRC="/Script/javascript/format_functions.js"></SCRIPT>
	<SCRIPT language="JavaScript">
	function checkNeg(thisObj)
	{		
		if (parseFloat(thisObj.value) > 0)
		{				
			thisObj.value = -thisObj.value
			DispTotal()
		}
	}
	function DispTotal()
	{
		var loopCount = document.all.CurLargeSPNumber.value;
		var parentAmt = document.all.DD_Amount.value;	
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
		
		if (parentAmt < totAmount)
		{
			showAmount = totAmount - parentAmt;
			showAmount = formatToDecimalPlaces(showAmount, 2);
			showAmount =formatWithComma(showAmount, 3, 0);
			document.all.SPText.innerHTML = "FROM SPLIT AMOUNT:";
			document.all.SPResult.innerHTML = "<B>SUBTRACT&nbsp;&nbsp;&nbsp;&nbsp; $ " + showAmount + "</B>";					
			document.all.SPText.style.color = "red";
			document.all.SPResult.style.color = "red";
			/*document.all.SPText.style.background = "FAD3FE";
			document.all.SPResult.style.background = "FAD3FE";*/
			totAmount = formatToDecimalPlaces(totAmount, 2);
			totAmount =formatWithComma(totAmount, 3, 0);
			document.all.DySPTotal.innerHTML = "<B>$ " + totAmount + "</B>";		
			document.all.DySPTotal.style.color = "red";				
			/*document.all.SPTotText.style.background = "BE82F4";
			document.all.DySPTotal.style.background = "BE82F4";*/
		}
		else if (totAmount < parentAmt)
		{
			showAmount = parentAmt - totAmount;
			showAmount = formatToDecimalPlaces(showAmount, 2);
			showAmount =formatWithComma(showAmount, 3, 0);
			document.all.SPText.innerHTML = "TO SPLIT AMOUNT:";
			document.all.SPResult.innerHTML = "<B>ADD&nbsp;&nbsp;&nbsp;&nbsp; $ " + showAmount + "</B>";					
			document.all.SPText.style.color = "red";
			document.all.SPResult.style.color = "red";
			/*document.all.SPText.style.background = "FAD3FE";
			document.all.SPResult.style.background = "FAD3FE";*/
			totAmount = formatToDecimalPlaces(totAmount, 2);
			totAmount =formatWithComma(totAmount, 3, 0);
			document.all.DySPTotal.innerHTML = "<B>$ " + totAmount + "</B>";		
			document.all.DySPTotal.style.color = "red";
			/*document.all.SPTotText.style.background = "BE82F4";
			document.all.DySPTotal.style.background = "BE82F4";*/
		}
		else
		{
			totAmount = formatToDecimalPlaces(totAmount, 2);
			totAmount =formatWithComma(totAmount, 3, 0);
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
		var parentAmt = document.all.DD_Amount.value;			
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
			trTitle = "subract: $" + showAmount;				
		}
		else if (totAmount < parentAmt)
		{
			showAmount = parentAmt - totAmount;
			trTitle = "add: $" + showAmount;
		}
		trObj.title = trTitle;			
	}
	
	function validate(disableClickedButton, disableClickedButtonName)
	{
		var Children = document.all.CurLargeSPNumber.value;
		var parentAmt = document.all.DD_Amount.value;
		var bDeleteAllOn = document.Sp_Parent.DeleteAll.value;
		var Deleted,Amount; 
		var totAmount = 0;
		var amountDiff = 0;
		var noOfDeleted = 0;
		var deleteAll = 1;
		
		<cfif GetMaxSPNumber.recordcount EQ 1>
			if (Children == "")
			{
			Children = 1;
			}
		</cfif>	
		for (i=1;i<=Children;i++)
		{
			if(eval("document.all.IsDeleted_"+i))
			{
				Deleted = eval("document.all.IsDeleted_"+i+".value");
				AmountObj = eval("document.all.Amt_Child_"+i)
				Amount = AmountObj.value;
				
				if (Deleted == 0 && deleteAll == 1)
				{
					deleteAll = 0;
				}
				
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
						//round amount to two decimal
						totAmount = Math.round(totAmount*100)/100;				
					}
				}	
				else
				{
					noOfDeleted = noOfDeleted + 1;
				}	
			}
		}
		
		/*
		if(deleteAll == 1 && Children == noOfDeleted) //if all are deleted
		{
			bDeleteAllOn = 1;
		}
		*/

		//if they've deleted all splits
		//if(deleteAll == 1 && bDeleteAllOn == 1)
		if(deleteAll == 1)
		{
			Children = Children - noOfDeleted;
			document.all.NoOfChildren.value = Children;
			document.Sp_Parent.Form_Submitted.value=1;
			document.Sp_Parent.submit();
			if(disableClickedButton)
			{
				disableButton(disableClickedButtonName, true, false);		
			}
		}
		
		else if (totAmount == parentAmt)
		{
			Children = Children - noOfDeleted;
			document.all.NoOfChildren.value = Children;
			document.Sp_Parent.Form_Submitted.value=1;
			document.Sp_Parent.submit();
			if(disableClickedButton)
				{
					disableButton(disableClickedButtonName, true, false);		
				}
		}
		else if (totAmount < parentAmt)
		{
			amountDiff = parentAmt - totAmount; 
			amountDiff = Math.round(amountDiff*100)/100;
			alert("The sum of the split deductions must equal "+parentAmt+". It is currently "  + amountDiff +  " less than that amount.")					
			return false;
		}
		else if (totAmount > parentAmt)
		{
			amountDiff = totAmount - parentAmt; 
			amountDiff = Math.round(amountDiff*100)/100;
			alert("The sum of the split deductions must equal "+parentAmt+". It is currently "+ amountDiff+  " more than that amount.")
			return false;
		}			
	}
	function addRow(rowNum)
	{
		var rowNumber = parseInt(rowNum); 
		var allowNeg = "<CFOUTPUT>#Get_DD_Details.Is_Credit#</CFOUTPUT>";
		var allowMixed = "<cfoutput>#appSettings.getDD_Negative_Splits()#</cfoutput>"
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
		var chShipTo = "Split_Reason_"+spCount;
		var selectString = "";
		var nextRow = rowNumber + 1;
		var passcolor = "c0c0c0";
		var hiddenName = "IsDeleted_"+spCount;
		var ClassificationCode = "DD_Classification_ID_"+spCount;
		var isCreatedHidden = "IsCreated_"+spCount;			
		var curNoOfChildren = document.all.NoOfChildren.value;	
		
		/* On IE 10, the below line does not work. */
		//var isCreatedHidden = document.createElement('<input type="hidden" name="'+isCreatedHidden+'" value="1">');
		/* On IE 10, the below lines worked instead */
		var isCreated_Hidden = document.createElement("input");
			isCreated_Hidden.setAttribute("type", "hidden");
			isCreated_Hidden.setAttribute("id", ''+isCreatedHidden+'');
			isCreated_Hidden.setAttribute("name",''+isCreatedHidden+'');
			isCreated_Hidden.setAttribute("value", "1");
		var existingObj = document.getElementById("Form_Submitted"); 
		document.Sp_Parent.insertBefore(isCreated_Hidden,existingObj);	/// CrhomeFix D57213 added existingObj to func call

		/* On IE 10, the below line does not work. */
		//var isdeletedHidden = document.createElement('<input type="hidden" name="'+hiddenName+'" value="0">');	
		/* On IE 10, the below lines worked instead */
		var isdeleted_Hidden = document.createElement("input");
			isdeleted_Hidden.setAttribute("type", "hidden");
			isdeleted_Hidden.setAttribute("id", ''+hiddenName+'');
			isdeleted_Hidden.setAttribute("name",''+hiddenName+'');
			isdeleted_Hidden.setAttribute("value", "0");

		document.Sp_Parent.insertBefore(isdeleted_Hidden,existingObj);  /// CrhomeFix D57213 added existingObj to func call

		trObj.sp_number = spCount;
		//alert(chAmt)


		
		if (!(rowNumber%2))
		{
			trObj.style.background  = "C6FFC6";
		}
		
		if (spCount > 99)
		{
			splitNumber = spCount;
		}
		else if (spCount > 9)
		{
			splitNumber = "0"+spCount;
		}
		else
		{
			splitNumber = "00"+spCount;
		}
		
		<cfif appSettings.getDD_Show_Classification()>	
		var numberOfRows = 5;
		<cfelse>
		var numberOfRows = 4;
		</cfif>	
			
		for(i=0;i<numberOfRows;i++)
		{
			chNum = i + 1;		
			cellObj = trObj.insertCell(i);
			if (i==0)
			{
				cellObj.innerHTML = "<A HREF=\"Javascript: undo_redoRow("+rowNum+",'"+passcolor+"',"+spCount+")\"><img src='/Images/scissor.gif' width='14' height='9' title='Remove child' border='0'></A>";
			}
			else if (i==1)
			{
				cellObj.innerHTML = "<B>" + splitNumber + "</B>";			
			}
			else if (i==2)
			{
				
				if (allowMixed == 1)
				{
					if (allowNeg == 1)
					{
						cellObj.innerHTML = "<INPUT TYPE=\"text\" SIZE=\"8\" NAME=\""+chAmt+"\" onKeyUp=\"Javascript: clenseText(this, '0123456789.-');limitXdecimalplaces(2, "+chAmt+");DispTotal();\" onBlur=\"Javascript: checkNeg(this);\">"//ONCHANGE=\"Javascript: incrementByOne("+i+","+loopEnd+")\"
					}
					else
					{
						cellObj.innerHTML = "<INPUT TYPE=\"text\" SIZE=\"8\" NAME=\""+chAmt+"\" onKeyUp=\"Javascript: clenseText(this, '0123456789.');limitXdecimalplaces(2, "+chAmt+");DispTotal();\">"//ONCHANGE=\"Javascript: incrementByOne("+i+","+loopEnd+")\"
					}
				}
					cellObj.innerHTML = "<INPUT TYPE=\"text\" SIZE=\"8\" NAME=\""+chAmt+"\" onKeyUp=\"Javascript: clenseText(this, '-0123456789.');limitXdecimalplaces(2, "+chAmt+");DispTotal();\">"//ONCHANGE=\"Javascript: incrementByOne("+i+","+loopEnd+")\"
			}	
			else if (i==3)
			{								
				cellObj.innerHTML = "<TEXTAREA NAME=\""+ chShipTo +"\" COLS=\"40\" ROWS=\"2\" onPaste=\"javaScript: return textareaChecklength('500', this);\"  onkeyPress=\"javaScript: return textareaChecklength('500', this);\"></TEXTAREA>";	
			}
			<cfif appSettings.getDD_Show_Classification()>								
			else if (i==4)
			{	
				cellObj.innerHTML = "<td><SELECT NAME=\""+ClassificationCode+"\"><cfoutput QUERY="GetAllClass"><OPTION VALUE=\"#DD_Classification_ID#\"<CFIF DD_Classification_ID EQ SavedClass.DD_Classification_ID> SELECTED</CFIF>>#DD_Classification_Desc#</OPTION></cfoutput></SELECT></td>" ;
			}
			</cfif>
<!--- 		else if (i==4)
			{
				cellObj.innerHTML = "<A HREF=\"Javascript: undo_redoRow("+rowNum+",'"+passcolor+"',"+spCount+")\"><img src='/Images/scissor.gif' width='14' height='9' alt='Remove child' border='0'></A>";
			}

		<cfelse>
		else if (i==3)
			{
				cellObj.innerHTML = "<A HREF=\"Javascript: undo_redoRow("+rowNum+",'"+passcolor+"',"+spCount+")\"><img src='/Images/scissor.gif' width='14' height='9' alt='Remove child' border='0'></A>";
			}
		
		</cfif> --->
		}		
		trObj.cells[1].onmouseover = new Function("ToolTip("+rowNum+")");
		document.all.InsertRowAt.value = nextRow;	
		document.all.NoOfChildren.value = parseInt(curNoOfChildren) + 1;
		document.all.CurLargeSPNumber.value = spCount;
	}
	
	function undo_redoRow(rowNum,color,spNum)
	{

		var rowNumber = parseInt(rowNum);
		var AmtObj = "Amt_Child_"+spNum;				
		var ShipToObj = "Split_Reason_"+spNum;
		//var AmtObj =  eval("document.Sp_Parent."+AmtObj);  
		//var ShipToObj =  eval("document.Sp_Parent."+ShipToObj);		
		//var hiddenName =    eval("document.Sp_Parent.IsDeleted_"+spNum);  
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
		
		<cfif appSettings.getDD_Show_Classification()>	
		var numberOfRows = 5;
		<cfelse>
		var numberOfRows = 4;
		</cfif>
		
		for(i=0;i<numberOfRows;i++)
		{
			//if (i!=numberOfRows-1)
			if (i!=0)
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
			if (i==1)
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
		
		DispTotal();
		ToolTip(1);
	}
	
	function undo_redoAll(bDelete)
	{
		
		var	spMainTable 	= document.all.SP_Main_Table;
		var totalRows 		= spMainTable.rows.length;
		var strColor		= '';
		var ddBillbackMessage = 'In order to delete the deduction split you must remove the billback from the split.\nThe following deduction splits have billbacks associated to them:\n';
		var ddBillbackSplits = '';
		tdObj= spMainTable.rows[0];

		<cfif variables.validSplits and isDefined("Get_all_Children")>
			<CFOUTPUT QUERY="Get_all_Children">
				<cfif DD_Closure_ID NEQ "">
					ddBillbackSplits = ddBillbackSplits + '#SP_Number#\n';
				</cfif>
			</CFOUTPUT>
		</cfif>
		if (ddBillbackSplits != '')
		{
			ddBillbackMessage = ddBillbackMessage + ddBillbackSplits;
			alert(ddBillbackMessage);
			return;
		}
		
		if (bDelete == 1)
		{
			var strColor = 'c0c0c0';
			tdObj.cells[0].innerHTML = "<A HREF=\"Javascript: undo_redoAll(0)\"><img src='/images/undo.gif' title='Restore All' border='0'></A>";
			document.Sp_Parent.DeleteAll.value=1;
		}
		else
		{
			strColor = 'ffffff';
			tdObj.cells[0].innerHTML = "<A HREF=\"Javascript: undo_redoAll(1)\"><img src='/Images/scissor.gif' width='14' height='9' title='Remove All' border='0'></A>";
			document.Sp_Parent.DeleteAll.value=0;
		}
		
		for(n=1;n<totalRows;n++)
		{
			undo_redoRow(n,strColor,spMainTable.rows[n].getAttribute('sp_number'));
		}
	}
	</SCRIPT>
		
		
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Action Part --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFELSE>

		<CFIF FORM.FromSplit EQ 1>
	
			<Cfif IsNumeric(FORM.CurLargeSPNumber) AND FORM.CurLargeSPNumber IS NOT "">
				<CFSET LoopTill = FORM.CurLargeSPNumber>
			<cfelse>
				<cfset LoopTill = 1>
			</CFIF>
			
			<CFQUERY NAME="Get_DD_Columns" DATASOURCE="#Application.Datasource#">
				SELECT 		column_name 
				FROM 		information_schema.columns 
				WHERE 		table_name = 'Deductions' 		
				ORDER BY column_name	
			</CFQUERY>		
			<CFSET Column_List = VALUELIST(Get_DD_Columns.column_name)>		
			<CFSET Column_List_Len = LISTLEN(Column_List,",")>		
			<cfset useLakebaseForGetDDValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
			<cfif useLakebaseForGetDDValues>
				<cftry>
					<cfset Get_DD_Values = application.oLakebase.toQuery(
						application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#FORM.DD_ID#", "deleted" = "eq.false" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForGetDDValues = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForGetDDValues>
				<CFQUERY NAME="Get_DD_Values" DATASOURCE="#Application.Datasource#">
					SELECT 	*
					FROM 	Deductions
					WHERE 	Deduction_ID='#FORM.DD_ID#' AND
							Deleted=0
				</CFQUERY>
			</cfif>

			<cfset useLakebaseForGetDefaultAction = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_stage")>
			<cfif useLakebaseForGetDefaultAction>
				<cftry>
					<cfset GetDefaultAction = application.oLakebase.toQuery(
						application.oLakebase.selectRows("dd_stage", { "is_default" = "eq.true", "deleted" = "eq.false" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForGetDefaultAction = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForGetDefaultAction>
				<CFQUERY NAME="GetDefaultAction" DATASOURCE="#Application.Datasource#">
					SELECT * FROM DD_Stage WHERE Is_Default = 1 AND Deleted = 0
				</CFQUERY>
			</cfif>
			<CFSET DefaultActionID = GetDefaultAction.DD_Stage_ID>
			
			
			<CFIF Get_DD_Values.SP_Number EQ "">
				<CFSET Parent_ID = Get_DD_Values.Deduction_ID>
			<CFELSE>
				<CFSET Parent_ID = Get_DD_Values.DD_Parent_ID>
			</CFIF>
			
			<!--- Check Parent has any BB or Credit associated and if any update it with null --->
			<CFQUERY NAME="CheckAssociation" DATASOURCE="#Application.Datasource#">
				SELECT * FROM Deductions WHERE Deduction_ID = '#Parent_ID#' AND (DD_Closure_ID IS NOT NULL OR LEN(LTRIM(RTRIM(DD_Closure_ID))) > 0)
			</CFQUERY>
			<CFIF CheckAssociation.RecordCount GT 0>
				<CFIF CheckAssociation.DD_Closure_Type EQ 1>
					<CFQUERY NAME="DisAssocBB" DATASOURCE="#Application.Datasource#">
						UPDATE Billback 
						SET BB_Associated_To_DD = 0
						WHERE Billback_ID = '#CheckAssociation.DD_Closure_ID#'
					</CFQUERY>
				<CFELSEIF CheckAssociation.DD_Closure_Type EQ 5 OR CheckAssociation.DD_Closure_Type EQ 6>
					<CFQUERY NAME="" DATASOURCE="#Application.Datasource#">
						UPDATE Deduction 
						SET <CFIF CheckAssociation.DD_Closure_Type EQ 5>DD_Status=8,</CFIF>
							DD_Closure_ID = NULL,
							DD_Closure_Type = NULL
						WHERE Deduction_ID = '#CheckAssociation.DD_Closure_ID#'
					</CFQUERY>			
				</CFIF>			
				<cfset useLakebaseForUpdateDD = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdateDD>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#Parent_ID#"
			},
			{
				"dd_closure_id" = javaCast("null",""),
				"dd_closure_type" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdateDD = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdateDD>
<CFQUERY NAME="UpdateDD" DATASOURCE="#Application.Datasource#">
					UPDATE Deductions 
					SET DD_Closure_ID = NULL,
						DD_Closure_Type = NULL 				
					WHERE Deduction_ID = '#Parent_ID#'
				</CFQUERY>
</cfif>
			</CFIF>
			<!--- END Check Parent has any BB or Credit associated and if any update it with null --->
			<CFSET AliveChildCount = 0>
			<CFSET InitalAliveChildCount = 0>
			<CFIF Isdefined("FORM.CurChildren")>
				<CFSET AliveChildCount = #FORM.CurChildren#>
			</CFIF>
			<CFQUERY NAME="DedCrdPrefix" DATASOURCE="#Application.Datasource#">
				SELECT 	ISNULL(Rtrim(Deduction_Number_Prefix),'') Deduction_Number_Prefix, 
						ISNULL(Rtrim(DD_Credit_Number_Prefix),'') DD_Credit_Number_Prefix
				FROM   _application_Settings
			</CFQUERY>
			
			<cfset useLakebaseForGetParentAttach = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
			<cfif useLakebaseForGetParentAttach>
				<cftry>
					<cfset GetParentAttach = application.oLakebase.toQuery(
						application.oLakebase.selectRows("contract_attachments", { "deduction_id" = "eq.#Form.DD_ID#", "deleted" = "eq.false", "select" = "deduction_id,doc_id" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForGetParentAttach = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForGetParentAttach>
				<CFQUERY NAME="GetParentAttach" DATASOURCE="#Application.Datasource#">
					select Deduction_ID,Doc_ID
					from Contract_Attachments
					where Deduction_ID = '#Form.DD_ID#'
					and deleted = 0
				</CFQUERY>
			</cfif>

			<cfsilent>
			<CFSET ResetParentReasonCode = 0>
			<CFSET CheckSplitNumber= 0>
			<CFLOOP INDEX="LoopCount" FROM="1" TO="#LoopTill#">						
				<!--- Milan (17586) If a user refreshed the page, then we would have duplicate records, and so I am checking for the
							existence of the split number. If that already exists, then we do not go through this process again.
							The variables "InitalAliveChildCount" and "CheckSplitNumber" are just being used to check for duplicate records.
				--->
				<cfset InitalAliveChildCount = AliveChildCount + 1>

				<CFIF InitalAliveChildCount GT 99>
					<CFSET CheckSplitNumber= '#InitalAliveChildCount#'>
				<CFELSEIF InitalAliveChildCount GT 9>
					<CFSET CheckSplitNumber= '0#InitalAliveChildCount#'>
				<CFELSE>
					<CFSET CheckSplitNumber= '00#InitalAliveChildCount#'>
				</CFIF>

		<!--- Does the split number already exist --->
			<CFQUERY NAME="Check_Split_Info" DATASOURCE="#Application.Datasource#">
				SELECT SP_Number
				FROM Deductions
				WHERE Deductions.Deleted = 0 
				AND Deductions.DD_DedID = '#FORM.DD_Number#'
				AND SP_Number = '#CheckSplitNumber#'
				AND SP_Number IS NOT NULL
			</CFQUERY>

			<!--- If there are no duplicate records --->
			<cfif Check_Split_Info.recordcount eq 0>

				<CFIF Isdefined("FORM.IsDeleted_#Loopcount#")>			
					<CFSET CurLoopCount = 0>
					<CFSET CurColLoopCount = 0>			
					<CFIF EVALUATE("FORM.IsCreated_#Loopcount#") EQ 1>			
						<CFIF EVALUATE("FORM.IsDeleted_#Loopcount#") EQ 0>
							<CFSET CreateSplitReason = EVALUATE("FORM.Split_Reason_#LoopCount#")>
							<CFSET CreateSplitReason = REPLACE(CreateSplitReason,"''","'","All")>
							<CFSET ResetParentReasonCode = 1>
							<CFSET AliveChildCount = AliveChildCount + 1>
							<CFOUTPUT><BR>
							<CFQUERY NAME="Insert_Data" DATASOURCE="#Application.Datasource#">
								INSERT INTO 
								Deductions 	(
												<CFLOOP LIST="#Column_List#" INDEX="Count">
													<CFSET CurColLoopCount = CurColLoopCount + 1>																								
													<CFIF  Count NEQ "Split_Count" AND  Count NEQ "Deduction_ID" AND Count NEQ "Created_Date" AND Count NEQ "Deleted" AND Count NEQ "DD_Forge_ID"><!---  --->
														<CFIF CurColLoopCount NEQ Column_List_Len>
															#Count#,
														<CFELSE>
															#Count#
														</CFIF>													
													</CFIF>
												</CFLOOP>	
											)
											
								VALUES		(
												<CFLOOP LIST="#Column_List#" INDEX="Count">
													<CFSET CurLoopCount = CurLoopCount + 1>	
													<CFIF  Count NEQ "Split_Count" AND  Count NEQ "Deduction_ID" AND Count NEQ "Created_Date" AND Count NEQ "Deleted" AND Count NEQ "DD_Forge_ID"><!---   --->												
														<CFIF COUNT NEQ "Is_Credit" AND Count NEQ "DD_IsParent" AND Count NEQ "DD_Parent_ID" AND Count NEQ "DD_IsChild" AND Count NEQ "DD_Amount" AND Count NEQ "SP_Number" AND Count NEQ "DD_Status" AND Count NEQ "DD_Stage" AND Count NEQ "DD_Resolution_Code" AND Count NEQ "SP_Reason" AND Count NEQ "DD_DedID_SP_Number" AND Count NEQ "SP_Date" AND Count NEQ "Parent_Balance_Amt"><!---  Count NEQ "Distributor_ID" AND --->
															<CFIF EVALUATE("Get_DD_Values.#Count#") EQ "">
																NULL<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF> 
															<CFELSE>
																<cfqueryparam value="#EVALUATE("Get_DD_Values.#Count#")#"><CFIF CurLoopCount NEQ Column_List_Len>,</CFIF> 
															</CFIF>													
														<CFELSE>
															<!---
															 <CFIF Count EQ "Distributor_ID">
																NULL<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															 --->
															 <cfif Count EQ "DD_Customer_RefNo">
																'#preservesinglequotes(DD_Customer_RefNo)#'
															 </cfif>
															<CFIF Count EQ "SP_Reason"> 														
																'#CreateSplitReason#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "DD_IsParent">
																'0'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "DD_Parent_ID">	
																'#Parent_ID#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "DD_IsChild">
																'1'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>	
															<CFELSEIF Count EQ "DD_Amount">
																'#EVALUATE("FORM.Amt_Child_#LoopCount#")#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "SP_Number">
																<CFIF AliveChildCount GT 99>
																	'#AliveChildCount#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
																<CFELSEIF AliveChildCount GT 9>
																	'0#AliveChildCount#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
																<CFELSE>
																	'00#AliveChildCount#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
																</CFIF>
															<CFELSEIF Count EQ "SP_Date">
																getdate()<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "DD_Status">		
																<CFIF EVALUATE("FORM.Amt_Child_#LoopCount#") LT 0>
																'8'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
																<CFELSE>										
																'1'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
																</CFIF>
															<CFELSEIF COUNT EQ "Is_Credit">
																<CFIF EVALUATE("FORM.Amt_Child_#LoopCount#") LT 0>
																'1'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
																<CFELSE>										
																'0'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
																</CFIF>
															<CFELSEIF Count EQ "DD_Stage">
																'#DefaultActionID#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "DD_Resolution_Code">
																NULL<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "DD_DedID_SP_Number">
																<CFIF AliveChildCount GT 99>
																	<CFSET SPNUM = AliveChildCount>
																<CFELSEIF AliveChildCount GT 9>
																	<CFSET SPNUM = "0#AliveChildCount#">
																<CFELSE>
																	<CFSET SPNum = "00#AliveChildCount#">
																</CFIF>
																<CFSET DDNum = TRIM(Get_DD_Values.DD_DedID) />
																<cfif DedCrdPrefix.Deduction_Number_Prefix NEQ "" AND DedCrdPrefix.DD_Credit_Number_Prefix NEQ "">
																<CFIF EVALUATE("FORM.Amt_Child_#LoopCount#") LT 0>
																	<CFSET DDNum = Replace(TRIM(Get_DD_Values.DD_DedID),DedCrdPrefix.Deduction_Number_Prefix,DedCrdPrefix.DD_Credit_Number_Prefix)>
																<CFELSE>
																	<CFSET DDNum = Replace(TRIM(Get_DD_Values.DD_DedID),DedCrdPrefix.DD_Credit_Number_Prefix,DedCrdPrefix.Deduction_Number_Prefix)>
																</CFIF>
																</cfif>
																'#DDNum# - #TRIM(SPNum)#'<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															<CFELSEIF Count EQ "Parent_Balance_Amt">
																0<CFIF CurLoopCount NEQ Column_List_Len>,</CFIF>
															</CFIF>
														</CFIF>																																																		
													</CFIF>
												</CFLOOP>
											)
							</CFQUERY>
							<cfif appSettings.getDD_Show_Classification()>	
								<CFQUERY NAME="UpdateDeductions" DATASOURCE="#Application.Datasource#">
									UPDATE Deductions
									SET DD_Classification_ID = '#evaluate("DD_Classification_ID_#LoopCount#")#'
									WHERE Deduction_ID = '#Insert_Data.Deduction_ID#'
								</CFQUERY>			
							</cfif>
						
							<!--- 20884 Have the document attachments from the parent follow onto the splits --->
							<cfif  GetParentAttach.recordcount GT 0>
								<CFLOOP QUERY="GetParentAttach">
									<cfset useLakebaseForInsertDDAttach = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
									<cfif useLakebaseForInsertDDAttach>
										<cftry>
											<cfset application.oLakebase.insertRow("contract_attachments", {
												"deduction_id" = Insert_Data.Deduction_ID,
												"doc_id" = GetParentAttach.Doc_ID,
												"deleted" = false
											})>
											<cfcatch type="any">
												<cfset useLakebaseForInsertDDAttach = false>
											</cfcatch>
										</cftry>
									</cfif>
									<cfif NOT useLakebaseForInsertDDAttach>
										<cfset useLakebaseForInsert_DDAttach = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("contract_attachments")>
<cfif useLakebaseForInsert_DDAttach>
	<cftry>
		<cfset application.oLakebase.insertRow("contract_attachments", {
			"deduction_id" = "#Insert_Data.Deduction_ID#",
			"doc_id" = "#GetParentAttach.Doc_ID#"
		})>
		<cfcatch type="any">
			<cfset useLakebaseForInsert_DDAttach = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForInsert_DDAttach>
<CFQUERY NAME="Insert_DDAttach" DATASOURCE="#Application.Datasource#">
											INSERT	INTO Contract_Attachments (Deduction_ID,Doc_ID)
											VALUES  ('#Insert_Data.Deduction_ID#','#GetParentAttach.Doc_ID#')
										</CFQUERY>
</cfif>
									</cfif>
								</CFLOOP>
							</cfif>
							</CFOUTPUT>	<BR>						
						</CFIF>			
						
					<CFELSE>
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
					<!--- FOR EDIT --->				
					<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
						<CFSET SplitReason = EVALUATE("FORM.Split_Reason_#LoopCount#")>
						<CFSET SplitReason = REPLACE(SplitReason,"''","'","All")>
						
						<CFQUERY NAME="Update_Child" DATASOURCE="#Application.Datasource#">
							UPDATE 	Deductions
							SET		DD_Amount 		= 	'#Val(EVALUATE("FORM.Amt_Child_#LoopCount#"))#',
									SP_Reason		=	'#SplitReason#',									
									<CFIF EVALUATE("FORM.Amt_Child_#LoopCount#") LT 0>
										DD_DedID_SP_Number = 
											<cfif DedCrdPrefix.Deduction_Number_Prefix NEQ "" AND DedCrdPrefix.DD_Credit_Number_Prefix NEQ ""> 
											REPLACE(DD_DedID_SP_Number,'#DedCrdPrefix.Deduction_Number_Prefix#','#DedCrdPrefix.DD_Credit_Number_Prefix#'),
											<cfelse>
											DD_DedID_SP_Number,
											</cfif>											
										Is_Credit = 1,
										DD_Status = CASE WHEN DD_Status NOT IN (8,9) THEN 8 ELSE DD_Status END,
									<CFELSE>
										DD_DedID_SP_Number =
											<cfif DedCrdPrefix.Deduction_Number_Prefix NEQ "" AND DedCrdPrefix.DD_Credit_Number_Prefix NEQ ""> 
											REPLACE(DD_DedID_SP_Number,'#DedCrdPrefix.DD_Credit_Number_Prefix#','#DedCrdPrefix.Deduction_Number_Prefix#'),
											<cfelse>
											DD_DedID_SP_Number,
											</cfif>											
										Is_Credit = 0,
										DD_Status = CASE WHEN DD_Status IN (8,9) THEN 2 ELSE DD_Status END,
									</CFIF>																										
									Deleted			=	<CFIF EVALUATE("FORM.IsDeleted_#Loopcount#") EQ 1>
															1
														<CFELSE>
															0
														</CFIF>
									<cfif appSettings.getDD_Show_Classification()>	
														,
									DD_Classification_ID = '#evaluate("DD_Classification_ID_#LoopCount#")#'
									</cfif>
							WHERE 	DD_DedID 		= 	'#FORM.DD_Number#' AND 
									SP_Number 		= 	'#EVALUATE("FORM.Child_ID_#LoopCount#")#' AND 
									Deleted			=	0
						</CFQUERY>
	
					</CFIF>
				</CFIF>
			</CFIF>
			</CFLOOP>
			</cfsilent>
			<!----
			<!--- Update reason code of the parent --->	
			<CFIF (Get_DD_Values.DD_Status GT "2" AND Get_DD_Values.DD_Status NEQ 7) OR Get_DD_Values.DD_Resolution_Code NEQ "">
				<CFIF ResetParentReasonCode EQ 1>
					<cfset useLakebaseForUpdate_Parent = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
<cfif useLakebaseForUpdate_Parent>
	<cftry>
		<cfset application.oLakebase.updateRows("deductions",
			{
				"deduction_id" = "eq.#DD_Parent_ID#"
			},
			{
				"dd_status" = "2",
				"dd_resolution_code" = javaCast("null","")
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForUpdate_Parent = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForUpdate_Parent>
<CFQUERY NAME="Update_Parent" DATASOURCE="#Application.Datasource#">
						UPDATE 	Deductions
						
						SET 	DD_Status 			=	'2',
								DD_Resolution_Code 	=	NULL
								
						WHERE 	Deduction_ID='#DD_Parent_ID#'
					</CFQUERY>
</cfif>
				</CFIF>		
			</CFIF>
			--->
			<CFQUERY NAME="SetSplitCount" DATASOURCE="#Application.Datasource#">
				UPDATE Deductions 
				SET Split_Count = (SELECT Count(*) FROM Deductions WHERE DD_Parent_ID = '#Parent_ID#' AND DD_IsChild = 1 AND Deleted = 0)
				WHERE Deduction_ID = '#Parent_ID#'
			</CFQUERY>
			
			<CFQUERY NAME="SetParentStatus" DATASOURCE="#Application.Datasource#">
				IF (SELECT 	COUNT(*) 
					FROM 	Deductions 
					WHERE 	DD_Parent_ID = '#Parent_ID#'
					AND 	DD_IsChild = 1 
					AND 	DD_Status != 4 
					AND 	DD_Status != 9 
					AND 	Deleted = 0
					) = 0
				BEGIN
					UPDATE	Deductions 
					SET		DD_Status = CASE WHEN IS_CREDIT = 1 THEN 9 ELSE 4 END,
							DD_Date_Closed = getdate(),
							DD_Closed_By = 'Split Save',
							Cleared_Amount = DD_Amount
					WHERE	Deduction_ID = '#Parent_ID#'
					AND		Split_Count <> 0 -- Is still a parent
				END
			</CFQUERY>
			
			<!----- D16950 C. Parent balance amount should update on split creation ----->
			<cfset DeductionManager = CreateObject("component", "components.deduction.DeductionManager") />
			<cfset DeductionManager.updateParentBalanceAmount(parentDeductionId = Parent_ID) />
			
			<cfset useLakebaseForCheckThisDeductionDeletedBit = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("deductions")>
			<cfif useLakebaseForCheckThisDeductionDeletedBit>
				<cftry>
					<cfset checkThisDeductionDeletedBit = application.oLakebase.toQuery(
						application.oLakebase.selectRows("deductions", { "deduction_id" = "eq.#DD_ID#", "deleted" = "eq.false" })
					)>
					<cfcatch type="any">
						<cfset useLakebaseForCheckThisDeductionDeletedBit = false>
					</cfcatch>
				</cftry>
			</cfif>
			<cfif NOT useLakebaseForCheckThisDeductionDeletedBit>
				<CFQUERY NAME="checkThisDeductionDeletedBit" DATASOURCE="#Application.Datasource#">
					SELECT * FROM Deductions WHERE Deduction_ID = '#DD_ID#' AND Deleted=0
				</CFQUERY>
			</cfif>
			<!--- <CFABORT> --->
			<CFIF checkThisDeductionDeletedBit.recordcount EQ 0>
				<SCRIPT language="JavaScript">
					function relocate()
					{
						window.parent.location.href="/deductions/index.cfm";
					}
					relocate();
				</SCRIPT>			
			<CFELSE>
				<SCRIPT language="JavaScript">
					function relocate()
					{
						window.parent.location.href="/deductions/deduction.cfm?<CFOUTPUT>Deduction_ID=#DD_ID#</CFOUTPUT>&CenterToShow=SplitResult";
					}
					relocate();
				</SCRIPT>	
				<!--- <CFLOCATION URL="/deductions/deduction.cfm?Deduction_ID=#DD_ID#&CenterToShow=SplitResult" ADDTOKEN="No"><!--- Split_Result.cfm? ---> --->
			</CFIF>
		</CFIF>
		
</CFIF>

</body>
</html>

