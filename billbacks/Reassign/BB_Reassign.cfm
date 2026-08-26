<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	
<title>BB Reassign</title>

<script language="javascript">
function showDistSearchWindow() 
{	
	document.BB_Reassign.action = "<CFOUTPUT>#CGI.PATH_INFO#</CFOUTPUT>";		
	NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=BB_Reassign&SelectSingleSearchResultOnly=0", "BB_Reassign", 800, 600, "yes", "yes");
}

function showOperSearchWindow() 
{	
	document.BB_Reassign.action = "<CFOUTPUT>#CGI.PATH_INFO#</CFOUTPUT>";		
	NewWindow("/Billbacks/search_Screens/PM_select_operators.cfm?Formname=BB_Reassign&SelectSingleSearchResultOnly=0", "BB_Reassign", 800, 600, "yes", "yes");
}

function showVendorSearchWindow() 
{
	document.BB_Reassign.SelectSingleSearchResultOnly.value = 0;
	document.BB_Reassign.action = "<CFOUTPUT>#CGI.PATH_INFO#</CFOUTPUT>";		
	NewWindow("/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=BB_Reassign", "BB_Reassign", 800, 600, "yes", "yes")	
}

function ValidateSearch()
{
	var ErrorString;
	ErrorString = '';
	if(document.all.Distributor_ID.value !='' && document.all.Distributor_Name.value !='')
	{
		ErrorString = 'You cannot use both - Distributor ID and Distributor Name';
	}

	if(ErrorString != ''){
		ErrorString = ErrorString + '\n' + ' ';
	}

	if(document.all.Operator_ID.value !='' && document.all.Operator_Name.value !='')
	{
		ErrorString = 'You cannot use both - Operator ID and Operator Name';
	}

	if(ErrorString != ''){
		ErrorString = ErrorString + '\n' + ' ';
	}
	
	if(document.all.Vendor_ID.value !='' && document.all.VendorID.value !='')
	{
		ErrorString = ErrorString + 'You cannot use both - Vendor ID and Vendor Name';
	}

	if(ErrorString != '')
	{
		alert(ErrorString);
	}
	else
	{
		SubmittoBBSelection();
	}
}

</script>
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery.multiselect.css" type="text/css" />
<link rel="stylesheet" href="/styles/jQueryUI_18/jquery-ui-1.8.10.custom.css" type="text/css" />




</head>

<body>

<STYLE>
TABLE.BorderTable TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>

<CFPARAM NAME="FORM.Billback_ID" 		DEFAULT="">
<CFPARAM NAME="FORM.Src_Analyst" 		DEFAULT="">
<CFPARAM NAME="FORM.Tar_Analyst" 		DEFAULT="">
<CFPARAM NAME="FORM.Src_Status" 		DEFAULT="">
<CFPARAM NAME="FORM.Distributor_ID"		DEFAULT="">
<CFPARAM NAME="FORM.Operator_ID" 		DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List"		DEFAULT="">
<CFPARAM NAME="FORM.Operator_List" 		DEFAULT="">
<CFPARAM NAME="FORM.Vendor_ID" 		DEFAULT="">
<CFPARAM NAME="FORM.VendorID" 		DEFAULT="">
<CFPARAM NAME="Selected_Distributor" 		DEFAULT="">
<CFPARAM NAME="Selected_Operator" 		DEFAULT="">
<CFPARAM NAME="Selected_Vendor" 		DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Status"	DEFAULT="A">
<CFPARAM NAME="FORM.Operator_Status"	DEFAULT="A">
<CFPARAM NAME="FORM.Vendor_Status" 		DEFAULT="A">
<cfparam name="FORM.Payable_Number" 	default="">
<cfparam name="FORM.payable_list" 	default="">  
<cfparam name="FORM.pageOrigin" 	default="">  

<cfif ((FORM.pageOrigin EQ "BB_Reassign") OR (isDefined("URL.BBIDs") AND URL.BBIDs NEQ ""))>
	<cfset FORM.Billback_ID = URL.BBIDs />
</cfif>

<cfset objSettingsService = createobject("component", "mvc.models.SettingsService") />

<cfset stBBLabels = objSettingsService.getBBLabels()>
		
<CFIF FORM.Distributor_List NEQ "">
			
	<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT	BSA_Foodservice_Customers_ID,Name 
		FROM 	BSA_Foodservice_Customers 
		WHERE	BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN ('#Replace(FORM.Distributor_List,chr(44), chr(39)&chr(44)&chr(39), "ALL")#')
		AND		BSA_Foodservice_Customers.Deleted = 0
		AND		BSA_Foodservice_Customers.Active_Code = 'A'
		ORDER BY Name
	</CFQUERY>
		
	<CFSET Selected_Distributor=ValueList(Dist_Search_Result.Name)>
		
</CFIF>

<CFIF FORM.Operator_List NEQ "">
			
	<CFQUERY NAME="Oper_Search_Result" DATASOURCE = "#Application.Datasource#">
		SELECT	BSA_Operator_ID, Operator_Name 
		FROM 	BSA_Operator
		WHERE	BSA_Operator_ID IN ('#Replace(FORM.Operator_List,chr(44), chr(39)&chr(44)&chr(39), "ALL")#')
		AND		Deleted = 0
		ORDER BY Operator_Name
	</CFQUERY>
		
	<CFSET Selected_Operator=ValueList(Oper_Search_Result.Operator_Name)>
		
</CFIF>


<CFIF FORM.Vendor_ID NEQ "">
		
	<cfset useLakebaseForGetVendorID = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("vendor_master")>
<cfif useLakebaseForGetVendorID>
	<cftry>
		<cfset GetVendorID = application.oLakebase.toQuery(
			application.oLakebase.selectRows("vendor_master", {
				"vendor_id" = "eq.#Vendor_ID#",
				"select" = "vendor_id,vendor_name"
			}), "vendor_id,vendor_name"
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetVendorID = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetVendorID>
<CFQUERY NAME="GetVendorID" DATASOURCE = "#Application.Datasource#">
		SELECT Vendor_ID, Vendor_Name 
		FROM Vendor_Master 
		WHERE Vendor_ID = '#Vendor_ID#'
	</CFQUERY>
</cfif>
		
	<CFSET Selected_Vendor = GetVendorID.Vendor_Name>
		
</CFIF>

<CFQUERY NAME="Get_Analyst" DATASOURCE="#Application.Datasource#">
	SELECT 		Analyst_User_ID,
				Name_First,
				Name_Last
	FROM 		BB_Analyst
				INNER JOIN _Users ON _Users.User_ID = BB_Analyst.Analyst_User_ID
	WHERE 		BB_Analyst.Deleted=0
	AND			_Users.Deleted=0
	ORDER BY	_Users.Name_First,_Users.Name_Last
</CFQUERY>

<!---Get Possible statuses--->
<cfset useLakebaseForGetBBStatus = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_status")>
<cfif useLakebaseForGetBBStatus>
	<cftry>
		<cfset GetBBStatus = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_status", {})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetBBStatus = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetBBStatus>
<CFQUERY NAME="GetBBStatus" Datasource="#application.datasource#">
	SELECT * 
	FROM Billback_Status
</CFQUERY>
</cfif>

<CFINCLUDE TEMPLATE="/helpsystem/help_link.cfm">

<FORM NAME="BB_Reassign" ACTION="Select_BB_BulkReassign.cfm" METHOD="Post">

    <CFOUTPUT>
		<INPUT TYPE="Hidden" VALUE="#FORM.Billback_ID#" NAME="Billback_ID">
    </CFOUTPUT>

<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="85%" ALIGN="Center">
	<TR>
		<TD><FONT COLOR="navy" SIZE="3"><B>Reassign Billbacks</B></FONT><HR COLOR="Orange"></TD>
	</TR>
	<TR>
		<TD>
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="2" WIDTH="100%">
				<TR>
					<TD WIDTH="78%" BGCOLOR="ffce84">&nbsp;&nbsp;&nbsp;<B>Source:</B><BR></TD>
					<TD WIDTH="22%" BGCOLOR="ffce84">&nbsp;&nbsp;&nbsp;<B>Target:</B><BR></TD>
				</TR>
				<TR BGCOLOR="C6FFC6" HEIGHT="30">
					<TD>
						<table width="100%" BORDER="0">
							<tr>
								<td>		
									<B>Analyst:</B>&nbsp;&nbsp;
									<SELECT NAME="Src_Analyst" ONCHANGE="Javascript: ChangeBBID()" id="src_analyst"  multiple="multiple">
										<CFOUTPUT QUERY="Get_Analyst">
												<OPTION VALUE="#Analyst_User_ID#" <CFIF FORM.Src_Analyst EQ Analyst_User_ID>SELECTED</CFIF>>#Name_First# #Name_Last#</OPTION>
										</CFOUTPUT>
									</SELECT>
								</td>
								<td align="right">
									<strong>Billback Status:</strong>
									<select name="src_status"  id="src_status"  multiple="multiple">
										<cfoutput query="GetBBStatus">
											<option value="#Billback_Status_ID#" <CFIF FORM.Src_Status EQ Billback_Status_ID>SELECTED</CFIF>>#BB_Status_Description#
										</cfoutput>
										</select>
										&nbsp;&nbsp;
								</td>
							</tr>
						</table>
					</TD>
					<TD>
						<B>Analyst:</B>&nbsp;&nbsp;
						<SELECT NAME="Tar_Analyst" style="width:150px;">
							<CFOUTPUT QUERY="Get_Analyst">
								<OPTION VALUE="#Analyst_User_ID#" <CFIF FORM.Tar_Analyst EQ Analyst_User_ID>SELECTED</CFIF>>#Name_First# #Name_Last#</OPTION>
							</CFOUTPUT>
						</SELECT>
					</TD>
				</TR>			
				<TR style="padding-top:20px;">
					<TD>
						<!--- Payee --->
						<table  WIDTH="100%" BORDER="0">
						<cfoutput>
							<tr>
								<td WIDTH="19%"><B>#stBBLabels.Vendor# ID:</B></td>
								<td WIDTH="12%"><input type="text" name="VendorID" size="12"></td>
								<td WIDTH="14%"><B>#stBBLabels.Vendor#:</B></td>
								<!--- The reason why "Vendor_ID and not "Vendor_Name" is chosen as the field name is because "search_screens/Popup_Search.cfm", which populates the textbox, expects
								the field name to be "Vendor_ID". --->
								<td WIDTH="38%" nowrap><INPUT NAME="Vendor_ID" SIZE="35" ID="Vendor_ID" VALUE="#Selected_Vendor#" style="background-color: ##E9E9E9" READONLY>
									<a href="javascript: void(0);" onClick="javaScript: showVendorSearchWindow();"><IMG border="0" src="/images/searchtool.gif"></a>
							 		<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" ONCLICK="Javascript: document.all.BB_Reassign.Vendor_ID.value=''; document.all.BB_Reassign.Vend_ID.value='' ">reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
								</td>
								<td WIDTH="25%">
									<B>Status:</B>
									<SELECT NAME="Vendor_Status" id="Vendor_Status" size="1" style="width:70px;">
										<OPTION VALUE="">--select--</OPTION>
										<OPTION VALUE="A">Active</OPTION>
										<OPTION VALUE="N">Inactive</OPTION>
									</SELECT>
								</td>
							</tr>
						</cfoutput>
						</table>
					</TD>
				</TR>
				<TR>
					<TD>
						<!--- Distributor --->
						<table  WIDTH="100%" BORDER="0">
							<CFPARAM NAME="FORM.Distributor_Name" DEFAULT="">
							<cfoutput>
							<tr>
								<td WIDTH="19%"><B>#application.returned_customer_setting.distributor_label_singular# ID:</B></td>
								<td WIDTH="12%"><input type="text" id="Distributor_ID" name="Distributor_ID" size="12"></td>
								<td WIDTH="14%"><B>#application.returned_customer_setting.distributor_label_singular#:</B></td>
								<td WIDTH="38%" nowrap><INPUT NAME="Distributor_Name" SIZE="35" ID="Distributor_Name" VALUE="#Selected_Distributor#" style="background-color: ##E9E9E9" READONLY>
									<a href="javascript: void(0);" onClick="javaScript: showDistSearchWindow();"><IMG border="0" src="/images/searchtool.gif"></a>
									<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" ONCLICK="Javascript: document.all.BB_Reassign.Distributor_Name.value=''">reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
								</td>
								<td WIDTH="25%">
									<B>Status:</B>
									<SELECT NAME="Distributor_Status" id="Distributor_Status" size="1" style="width:70px;">
										<OPTION VALUE="">--select--</OPTION>
										<OPTION VALUE="A">Active</OPTION>
										<OPTION VALUE="N">Inactive</OPTION>
									</SELECT>
								</td>
							</tr>
											
							</cfoutput>
						</table>
					</TD>
				</TR>
				<TR>
					<TD>
						<!--- Operator --->
						<table  WIDTH="100%" BORDER="0">
							<CFPARAM NAME="FORM.Operator_Name" DEFAULT="">
							<cfoutput>
							<tr>
								<td WIDTH="19%"><B>#application.returned_customer_setting.operator_label_singular# ID:</B></td>
								<td WIDTH="12%"><input type="text" id="Operator_ID" name="Operator_ID" size="12"></td>
								<td WIDTH="14%"><B>#application.returned_customer_setting.operator_label_singular#:</B></td>
								<td WIDTH="38%" nowrap><INPUT NAME="Operator_Name" SIZE="35" ID="Operator_Name" VALUE="#Selected_Operator#" style="background-color: ##E9E9E9" READONLY>
									<a href="javascript: void(0);" onClick="javaScript: showOperSearchWindow();"><IMG border="0" src="/images/searchtool.gif"></a>
									<B><FONT COLOR="red" SIZE="2">[ </FONT><A HREF="##" ONCLICK="Javascript: document.all.BB_Reassign.Operator_Name.value=''">reset</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>
								</td>
								<td WIDTH="25%">
									<B>Status:</B>
									<SELECT NAME="Operator_Status" id="Operator_Status" size="1" style="width:70px;">
										<OPTION VALUE="">--select--</OPTION>
										<OPTION VALUE="A">Active</OPTION>
										<OPTION VALUE="N">Inactive</OPTION>
									</SELECT>
								</td>
							</tr>
							</cfoutput>
						</table>
					</TD>
				</TR>
				<cfoutput>
				<tr>
				<td>
					<table WIDTH="100%" BORDER="0">
					<tr>
								<td WIDTH="19%"><b>#stBBLabels.Payable# ##:</b><a href="javascript: createList2('BB_Code')" id="createlist13">#application.util.string.actionLinkFormat2("create list")#</a></td>
								<td WIDTH="12%"><input type="text" name="Payable_Number" ID="Payable_Number" value="#FORM.Payable_Number#" size="12"></td>
								<td WIDTH="14%">&nbsp;</td>
								<td WIDTH="38%" nowrap></td>
								<td WIDTH="25%"></td>
						</tr>					
				</cfoutput>
				<TR>
					<TD COLSPAN="100%" ALIGN="Center"><BR>
						<BR>			
						<SPAN ID="Resetall" <CFIF FORM.Billback_ID NEQ "">STYLE="DISPLAY:NONE"</CFIF>>
							<CF_button
								button_name		=	""
								button_caption	=	"select billbacks"
								button_action	=	"ValidateSearch(); return;"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold">
							</SPAN>
					</TD>
				</TR>
			</TABLE>
			<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" WIDTH="100%" CLASS="BorderTable" <CFIF FORM.Billback_ID EQ "">STYLE="DISPLAY:NONE"</CFIF> ID="SelBB_Disp">
			<CFIF FORM.Billback_ID NEQ "">
			
				<CFSET Selected_Items = ListQualify(FORM.Billback_ID,"'",",","All")>
			
				<CFQUERY NAME="GetBillbackInts" DATASOURCE="#Application.Datasource#">
					SELECT	Billback_ID_Int
					FROM	Billback       
					WHERE	Billback_ID IN (#PreserveSingleQuotes(Selected_Items)#)
				</CFQUERY>
				
				<cfset GetBillbacks = CreateObject("component", "mvc.Models.Billback.BillbackLoadManager").getBillbackHeaderData(userId = request.AccessStructure.User_ID, profiles_Id = request.AccessStructure.profiles_Id, timeZoneDiff = request.AccessStructure.timeZoneOffSet, billbackIdIntList = valueList(GetBillbackInts.Billback_ID_Int), includeAllStatus = "true") />

			
				<TR>
					<TD COLSPAN="100%" STYLE="Border: None">
						<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%">
							<TR>
								<TD STYLE="Border: None"><B>Billbacks selected for reassignment</B>&nbsp;&nbsp;<B><FONT COLOR="Red" SIZE="2">[ </FONT>
								<cfif (IsDefined("URL.pageOrigin") AND URL.pageOrigin EQ "BB_Reassign")>
									<a href="javascript: createList2('BB_Code')" id="createlist13">
								<cfelse>
									<A Href="##" OnClick= "SubmittoBBSelection()">
								</cfif>back to Billbacks list</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
							</TR>
						</TABLE>
					</TD>
				</TR>
				<TR BGCOLOR="ffce84">
					<TD><INPUT TYPE="CheckBox" NAME="allbox" ONCLICK="javaScript: selectAll(this);" CHECKED></TD>
					<TD><B>Payable #</B></TD>
					<TD><B>Status</B></TD>
					<TD><B>Date<BR>Billback #</B></TD>
					<TD><B>Payee<BR>Title</B></TD>
					<TD><B>Start Date<BR>End Date</B></TD>
					<TD><B>$ Amount</B></TD>
				</TR>
				<CFOUTPUT QUERY="GetBillbacks">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
					<TD><INPUT TYPE="CheckBox" NAME="Selected_Billback_ID" VALUE="#Billback_ID#" CHECKED></TD>
					<TD><B>[ #BB_Code# ]</B></TD>
					<TD>#BB_Status_Abbreviation#</TD>
					<TD>#DateFormat(BB_Date, "mm/dd/yyyy")#<BR>#BB_Code#</TD>
					<TD>#Payee#<BR>#BB_Title#</TD>
					<TD>#DateFormat(BB_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(BB_End_Date,"mm/dd/yyyy")#</TD>
					<TD>#DollarFormat(BB_Amount)#</TD>
				</TR>
				</CFOUTPUT>				
			</CFIF>
			</TABLE>
			
			<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" WIDTH="100%" ALIGN="Center" <CFIF FORM.Billback_ID EQ "">STYLE="DISPLAY:NONE"</CFIF> ID="SelBB_Button">
				<CFIF FORM.Billback_ID NEQ "">
					<TR>
						<TD COLSPAN="100%" ALIGN="Center"><HR COLOR="Orange">
							<BR>
							<CF_button
								button_name		=	""
								button_caption	=	"Reassign Billback"
								button_action	=	"Validate()"
								button_type		=	"javascript_link"
								button_width	=	"150"
								button_color	=	"Navy"
								button_tip		=	""
								font_color		=	"White"
								font_size		=	"12"
								font_weight		=	"bold">
						</TD>
					</TR>
				</CFIF>
			</TABLE>
			<CFOUTPUT>
				<INPUT TYPE="Hidden" ID="Distributor_List" NAME="Distributor_List" VALUE="#Form.Distributor_list#">
				<!--- "Vendor_ID" variable stores the "Vendor Name" --->
				<INPUT TYPE="Hidden" ID="Vend_ID" NAME="Vend_ID" VALUE="#Form.Vendor_ID#">
				<INPUT TYPE="Hidden" ID="Operator_List" NAME="Operator_List" VALUE="#Form.Operator_list#">
				<input type="hidden" name="payable_list" value="#form.payable_list#">
				<input type="hidden" name="pageOrigin" value="#form.pageOrigin#">
			</CFOUTPUT>
			<INPUT TYPE="Hidden" NAME="SelectSingleSearchResultOnly"	VALUE="0">
		</td>
	</tr>
</table>
</FORM>
<SCRIPT SRC="/Script/javascript/dom_common.js"></SCRIPT>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.5.1-min.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jqueryui-1.8.10.min.js"></script>
<script type="text/javascript" src="/Script/javascript/jQueryUI_18/jquery.multiselect.min.js"></script>
<SCRIPT language="JavaScript">
function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.Selected_Billback_ID;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}	
}

function selectAllForPer(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.PerReassign;
	if(chObjs.length)
	{
		var chObjLen = chObjs.length;
		var i;
		for(i=0;i<chObjLen;i++)
		{
			chObjs[i].checked = bCheck;
		}
	}
	else
	{
		chObjs.checked = bCheck;
	}	
}

function SubmittoBBSelection()
{
	if (document.all.Src_Analyst.value != ''
	|| document.all.Distributor_ID.value != '' 
	|| document.all.Distributor_Name.value !=''
	|| document.all.Operator_ID.value !='' 
	|| document.all.Operator_Name.value !=''
	|| document.all.Vendor_ID.value !='' 
	|| document.all.VendorID.value !=''
	|| document.all.Payable_Number.value !=''
	)
	{
		var formObj = document.BB_Reassign;
		var oldTarget = formObj.target;	
		formObj.target = "BBS";
		NewWindow("##", formObj.target, '870', '600', 'Yes', 'No', true);
		if(document.all.Distributor_Name.value == ''){
			document.all.Distributor_List.value = '';
		}
		if(document.all.Operator_Name.value == ''){
			document.all.Operator_List.value = '';
		}
		document.BB_Reassign.submit()
		formObj.target = oldTarget;
	}
	else
	{
		alert("Please select a search criteria");
	}
}

function Validate()
{
	var Submit_OK=1;
	var x=document.BB_Reassign;
	if (x.Tar_Analyst.value == "")
	{
		alert("Please select a 'Target' analyst.");
		Submit_OK=0;
		x.Tar_Analyst.focus();
		return;
	}
	else
	{
		if (x.Tar_Analyst.value == x.Src_Analyst.value)
		{
			alert("Source and target analyst canot be the same.");
			Submit_OK=0;
			x.Tar_Analyst.focus();
			return;
		}
	}
	if (!(Any_Object_Checked(x.Selected_Billback_ID)))
	{
		alert("Please select at least one billback to reassign.");
		Submit_OK=0;
		return;
	}
	
	if(Submit_OK)
	{
		x.action="BB_Reassign_Action.cfm";
		x.submit();
	}
}

function createList2(type){
	NewWindow('/common_files/createList2.cfm?parent=bb_search&type='+type<cfif (isdefined("URL.searchList") AND URL.searchList NEQ "")>+'&searchList=<cfoutput>#URL.searchList#</cfoutput>'</cfif>, 'bb_reassign_create_list', 350, 445, 'no', 'no'); //Reassign_BB_Code
}	
	
$("#src_analyst").multiselect();
$("#src_status").multiselect();	

</SCRIPT>
</body>
</html>
