<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Billbacks to Reassign</title>
</head>

<body>
<CFPARAM NAME="FORM.SORT_BY" 				DEFAULT="BB_Code">
<CFPARAM NAME="FORM.SORT_ORDER" 			DEFAULT="ASC">
<cfparam name="FORM.startrow"  				DEFAULT="1">
<CFPARAM NAME="FORM.frompage"   			DEFAULT="1">
<cfparam name="FORM.pageLength"  			DEFAULT=11>
<CFSET startrow=FORM.startrow>
<CFSET frompage=FORM.frompage>
<cf_Number_of_Rows maxrows="#FORM.pageLength#">


<CFPARAM NAME="FORM.Billback_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.Src_Analyst" 			DEFAULT="">
<CFPARAM NAME="FORM.Tar_Analyst" 			DEFAULT="">
<CFPARAM NAME="FORM.Items_OnThis_Page" 		DEFAULT="">
<CFPARAM NAME="FORM.Selected_Billbacks" 		DEFAULT="">
<CFPARAM NAME="FORM.Already_Selected_List"	 	DEFAULT="#FORM.Selected_Billbacks#">
<CFPARAM NAME="FORM.src_status" 			DEFAULT="">
<CFPARAM NAME="FORM.Distributor_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.Distributor_List" 		DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Status" 		DEFAULT="">
<CFPARAM NAME="FORM.Distributor_Name" 		DEFAULT="">
<CFPARAM NAME="FORM.Operator_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.Operator_List" 			DEFAULT="">
<CFPARAM NAME="FORM.Operator_Status" 		DEFAULT="">
<CFPARAM NAME="FORM.Operator_Name" 		DEFAULT="">
<CFPARAM NAME="FORM.Payee_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.Vend_ID" 			DEFAULT="">
<CFPARAM NAME="FORM.VendorID" 			DEFAULT="">
<CFPARAM NAME="FORM.Vendor_Status" 		DEFAULT="">
<CFPARAM NAME="FORM.Payee_List" 			DEFAULT="">
<CFPARAM NAME="FORM.Payee_Name" 			DEFAULT="">
<CFPARAM NAME="FORM.Payee_Status" 			DEFAULT="">
<cfparam name="FORM.Payable_Number" 	default="">
<cfparam name="FORM.payable_list" 	default="">  
<cfparam name="FORM.pageOrigin" 	default="">  

<CFIF isdefined("FORM.Undo_Seletion")>
	<CFIF FORM.Undo_Seletion EQ 1>
		<CFSET FORM.Items_OnThis_Page = "">
		<CFSET FORM.Already_Selected_List = "">
		<CFSET FORM.Billback_ID = "">
	</CFIF>
</CFIF> 

<CFIF Not Isdefined("FORM.Already_Selected_List")>
	<CFPARAM NAME="FORM.Already_Selected_List" DEFAULT="#FORM.Selected_Billbacks#">
	<CFSET FORM.Already_Selected_List = FORM.Billback_ID>
<CFELSE>	
	<CFLOOP LIST="#FORM.Billback_ID#" INDEX="Item">		
		<CFIF NOT ListFindNoCase(FORM.Already_Selected_List,Item,",")>
			<CFSET FORM.Already_Selected_List = ListAppend(FORM.Already_Selected_List,Item,",")>
		</CFIF>
	</CFLOOP> 
</CFIF>


<CFLOOP LIST="#FORM.Items_OnThis_Page#" INDEX="Item">	
	<CFIF Not ListFindNoCase(FORM.Billback_ID,Item,",")>
		<CFSET DeleteItemPosition = ListFindNoCase(FORM.Already_Selected_List,Item,",")>
		<CFIF DeleteItemPosition GT 0>
			<CFSET FORM.Already_Selected_List = ListDeleteAt(FORM.Already_Selected_List,DeleteItemPosition,",")>
		</CFIF>
	</CFIF>
</CFLOOP>

<cfparam name="form.finishedSearching" default="0">
<cfif form.finishedSearching>
	<!-----  return to paren page ----->
	<script language="JavaScript">
		submitOpener();
		function submitOpener()
		{
			var op = window.opener;
			if(op)
			{
				var parentForm = op.document.BB_Reassign;
				if(parentForm)
				{
					var bbObj = parentForm.Billback_ID;
					if(bbObj)
					{
						<cfoutput>
						bbObj.value = "#FORM.Already_Selected_List#";
						</cfoutput>
					}
					parentForm.action = "BB_Reassign.cfm";
					parentForm.submit();
					window.close();
				}
			}
		}
	</script>
</cfif>

	<cfset local.payable_numbers = [] />
	<cfset local.payable_numbers = listToArray( replace(FORM..payable_list, chr(13) & chr(10), " ", "all"), " " )>
	<cfset local.payable_numbers_list = replace(FORM..payable_list, chr(13) & chr(10), ",", "all")>
 
<!--- TODO: Tim Ford - Put this code into a cfc --->
<cfquery name="qGetBillbackIntIds" datasource="#application.datasource#">
	SELECT	DISTINCT Billback.Billback_ID_Int
	FROM	Billback
			LEFT JOIN _Users Analyst_User ON 	Analyst_User.User_ID = Billback.Analyst_User_ID
			LEFT JOIN Billback_Operator ON Billback_Operator.Billback_ID = Billback.Billback_ID
				AND Billback_Operator.Deleted = 0
			LEFT JOIN BSA_Operator ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID
			LEFT JOIN Billback_Distributor ON Billback_Distributor.Billback_ID = Billback.Billback_ID
				AND Billback_Distributor.deleted = 0
			LEFT JOIN BSA_Foodservice_Customers ON
			BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
			LEFT JOIN Billback_Broker ON Billback_Broker.Billback_ID = Billback.Billback_ID
				AND Billback_Broker.deleted = 0
			LEFT JOIN Vendor_Master VM ON 
			/* Look for the first "Non Null" value. */
			VM.vendor_Id = COALESCE(Billback_Operator.Uploaded_Vendor_ID, Billback_Distributor.Uploaded_Vendor_ID,Billback_Broker.Uploaded_Vendor_ID)
			LEFT JOIN BB_Approved
			ON BB_Approved.Billback_ID = Billback.Billback_ID
			/* This join is for autopay. */
			LEFT JOIN Vendor_Master VM2 ON  
			BB_Approved.Vendor_Master_Id = VM2.Vendor_Master_Id
	WHERE	Billback.Deleted = 0
	<!--- Billback Analyst --->
	<cfif trim(FORM.Src_Analyst) neq "">
	AND		Analyst_User.User_ID IN (#ListQualify(FORM.Src_Analyst, "'")#)
	</cfif>
	<!--- Billback Status --->
	<cfif trim(FORM.src_status) neq "">
	AND		Billback.Billback_Status_ID IN (#FORM.src_status#)
	</cfif>
	<!--- BB_code--->
	<cfif trim(FORM.Payable_Number) neq "">
	AND		Billback.BB_Code LIKE ('%#FORM.Payable_Number#%')
	</cfif>

    <cfif arrayLen(local.payable_numbers)>
   		AND ( 1 = 0 <cfloop from="1" to="#arrayLen(local.payable_numbers)#" index="local.payable_index"> OR Billback.BB_Code LIKE '%#trim(local.payable_numbers[ local.payable_index ])#%' </cfloop> )
    </cfif>	
	
	<!--- Handle for ID filters --->
	<!--- Billback Distributor, Operator, Payee ID and Vendor ID --->
	<cfif trim(FORM.Distributor_ID) neq "" or trim(FORM.Operator_ID) neq "" or trim(FORM.Payee_ID) neq "" or trim(FORM.VendorID) neq "" or trim(FORM.Vend_ID) neq "">
	AND	(
		1 = 2
		<cfif trim(FORM.Distributor_ID) neq "">
		OR LTRIM(RTRIM(BSA_Foodservice_Customers.Ship_To)) = '#trim(FORM.Distributor_ID)#'
		</cfif>
		<cfif trim(FORM.Operator_ID) neq "">
		OR 	LTRIM(RTRIM(BSA_Operator.Legacy_ID)) = '#FORM.Operator_ID#'
		</cfif>
		<cfif trim(FORM.Payee_ID) neq "">
		OR 	(LTRIM(RTRIM(BSA_Foodservice_Customers.Ship_To)) = '#trim(FORM.Payee_ID)#' OR LTRIM(RTRIM(BSA_Operator.Legacy_ID)) = '#FORM.Payee_ID#')
		</cfif>
		<cfif trim(FORM.Vend_ID) neq "">
		OR 	LTRIM(RTRIM(VM.Vendor_Id)) = '#trim(FORM.Vend_ID)#' OR LTRIM(RTRIM(VM2.Vendor_Id)) = '#trim(FORM.Vend_ID)#' 
		</cfif>
		<cfif trim(FORM.VendorID) neq "">
		OR 	LTRIM(RTRIM(VM.Vendor_Id)) = '#trim(FORM.VendorID)#' OR LTRIM(RTRIM(VM2.Vendor_Id)) = '#trim(FORM.VendorID)#' 
		</cfif>
		)
	</cfif>
	
	<!--- Handle for Name filters --->
	<!--- Billback Distributor, Operator and Payee Name --->
	<cfif trim(FORM.Distributor_Name) neq "" or trim(FORM.Operator_Name) neq "" or trim(FORM.Payee_Name) neq "">
	AND	(
		1 = 2
		<cfif trim(FORM.Distributor_Name) neq "">
		OR BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (<cfqueryparam value="#form.distributor_list#" cfsqltype="CF_SQL_VARCHAR" list="true">)
		</cfif>
		<cfif trim(FORM.Operator_Name) neq "">
		OR LTRIM(RTRIM(BSA_Operator.BSA_Operator_ID)) IN (<cfqueryparam value="#form.OPERATOR_LIST#" cfsqltype="CF_SQL_INTEGER" list="true">)
		</cfif>
		<cfif trim(FORM.Payee_Name) neq "">
		OR 	(LTRIM(RTRIM(BSA_Foodservice_Customers.Name)) = '#trim(FORM.Payee_Name)#' OR LTRIM(RTRIM(BSA_Operator.Operator_Name)) = '#FORM.Payee_Name#')
		</cfif>
		)
	</cfif>
	
	<!--- Handle for the Status filters --->
	<!--- Billback Distributor, Operator and Payee Status --->
	<cfif trim(FORM.Distributor_Status) neq "" or trim(FORM.Operator_Status) neq "" or trim(FORM.Payee_Status) neq "" or trim(FORM.Vendor_Status) neq "">
	AND	(
		1 = 2
		<cfif trim(FORM.Distributor_Status) neq "">
		OR 	BSA_Foodservice_Customers.Active_Code IN (#ListQualify(FORM.Distributor_Status, "'")#)
		</cfif>
		<cfif trim(FORM.Operator_Status) neq "">
		OR 	BSA_Operator.Display_Code IN (#ListQualify(FORM.Operator_Status, "'")#)
		</cfif>
		<cfif trim(FORM.Payee_Status) neq "">
		OR 	(BSA_Foodservice_Customers.Active_Code IN (#ListQualify(FORM.Payee_Status, "'")#) OR BSA_Operator.Display_Code IN (#ListQualify(FORM.Payee_Status, "'")#))
		</cfif>
		<cfif trim(FORM.Vendor_Status) neq "">
		OR 	VM.Active_Code IN (#ListQualify(FORM.Vendor_Status, "'")#)
		</cfif>
		)
	</cfif>
	
</cfquery>
<!--- Set the list of Billback_ID_Int --->
<cfset lBillbackIDInt  = ValueList(qGetBillbackIntIds.Billback_ID_Int) />
<!--- If the list is empty then set it to 0 so that getBillbackHeaderData() doesn't return anything ---> 
<cfif lBillbackIDInt eq "">
	<cfset lBillbackIDInt = 0 />
</cfif>

<cfset bbLoadObj = CreateObject("component", "mvc.Models.Billback.BillbackLoadManager") />
<cfset GetBBDetails = bbLoadObj.getBillbackHeaderData(userId = request.AccessStructure.User_ID, profiles_Id = request.AccessStructure.profiles_Id, timeZoneDiff = request.AccessStructure.timeZoneOffSet, billbackIdIntList=lBillbackIDInt, includeAllStatus = "true") />
<cfinclude template="/common_files/jQuery.cfm">
<cfset Billback_IDs = valueList(GetBBDetails.Billback_ID) />

<FORM NAME="Select_BB" ACTION="Select_BB_BulkReassign.cfm" METHOD="POST">
<CFOUTPUT>
<INPUT TYPE="hidden" VALUE = "#FORM.SORT_BY#" NAME="SORT_BY">
<INPUT TYPE="hidden" VALUE = "#FORM.SORT_ORDER#" NAME="SORT_ORDER">
<INPUT TYPE="hidden" VALUE = "#FORM.Src_Analyst#" NAME="Src_Analyst">
<INPUT TYPE="hidden" VALUE = "#FORM.Tar_Analyst#" NAME="Tar_Analyst">
<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">
<INPUT TYPE="Hidden" VALUE ="#FORM.Already_Selected_List#" NAME="Already_Selected_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.src_status#" NAME="src_status">
<INPUT TYPE="Hidden" VALUE ="#FORM.Distributor_ID#" NAME="Distributor_ID">
<INPUT TYPE="Hidden" VALUE ="#FORM.Distributor_List#" NAME="Distributor_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.Distributor_Status#" NAME="Distributor_Status">
<INPUT TYPE="Hidden" VALUE ="#FORM.Distributor_Name#" NAME="Distributor_Name">
<INPUT TYPE="Hidden" VALUE ="#FORM.Operator_ID#" NAME="Operator_ID">
<INPUT TYPE="Hidden" VALUE ="#FORM.Operator_List#" NAME="Operator_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.Operator_Status#" NAME="Operator_Status">
<INPUT TYPE="Hidden" VALUE ="#FORM.Operator_Name#" NAME="Operator_Name">
<INPUT TYPE="Hidden" VALUE ="#FORM.Payee_ID#" NAME="Payee_ID">
<INPUT TYPE="Hidden" VALUE ="#FORM.Payee_List#" NAME="Payee_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.Payee_List#" NAME="Payee_List">
<INPUT TYPE="Hidden" VALUE ="#FORM.Payee_Name#" NAME="Payee_Name">
<INPUT TYPE="Hidden" VALUE ="#FORM.Payable_Number#" NAME="Payable_Number">
<INPUT TYPE="Hidden" VALUE ="#FORM.payable_list#" NAME="payable_list">
<INPUT TYPE="Hidden" VALUE ="#FORM.pageOrigin#" NAME="pageOrigin">

</CFOUTPUT>

<cfif (FORM.pageOrigin EQ "BB_Reassign")>
	<INPUT TYPE="Hidden" VALUE ="#Billback_IDs#" NAME="Already_Selected_List">
	<cflocation url="BB_Reassign.cfm?BBIDs=#Billback_IDs#&pageOrigin=BB_Reassign&searchList=#local.payable_numbers_list#" />
</cfif>
<TABLE BORDER="0" CELLPADDING="1" CELLSPACING="0" WIDTH="100%" CLASS="datagrid" id="bbList">
	<thead>
	<cfset dt.aoColumns = []>
	<TR BGCOLOR="FFE083">
		<cfset arrayAppend(dt.aoColumns, '"bSearchable":false, "bSortable":false')>
		<TH><INPUT TYPE="CheckBox" NAME="allbox" ONCLICK="javaScript: selectAll(this);"></TH>
		<CFSET A_Header_Name_List = "PAYABLE ##,STATUS,DATE,BILLBACK ##,PAYEE,Title,Start Date,End Date,$ AMOUNT">
		<CFSET A_Header_Value_List = "BB_Reference,BB_Status_Abbreviation,BB_Date,BB_Code,Payee,BB_Title,BB_Start_Date,BB_End_Date,BB_Amount">
		<CFSET Counter = 1>
		<CFOUTPUT>
		<CFLOOP LIST="#A_Header_Value_List#" INDEX="ThisHeaderItem">
			<CFSET ThisHeaderItemName = ListGetAt(A_Header_Name_List, Counter, ",")>		
			<CFIF ThisHeaderItem NEQ "BB_Code" AND ThisHeaderItem NEQ "BB_Title" AND ThisHeaderItem NEQ "BB_End_Date">
			<cfset arrayAppend(dt.aoColumns, '"bSearchable":false, "bSortable":false')>			
			<th ID="header" STYLE="font-size : 8pt">
			<CFELSE>
			<BR>
			</CFIF>
				#ThisHeaderItemName#			
			<CFIF ThisHeaderItem NEQ "BB_Date" AND ThisHeaderItem NEQ "Payee" AND ThisHeaderItem NEQ "BB_Start_Date">
			</th>			
			</CFIF>						
			<CFSET Counter = Counter + 1>
		</CFLOOP>
		</CFOUTPUT>
	</TR>
	</thead>	
	<CFSET Items_OnThis_Page = "">
	<tbody>
	<CFOUTPUT QUERY="GetBBDetails">
		<CFSET Items_OnThis_Page = ListAppend(Items_OnThis_Page,Billback_ID,",")>	
		<!--- D100712: Excessive CPU spikes in CF server / Anand Rao / 28-Sep-2020 
			  Removed the below query and added the fields in the main query
		--->
		<!--- <CFQUERY NAME="CheckLock" DATASOURCE="#Application.Datasource#">
			SELECT	Billback_Allied.BB_Is_Locked as Is_Locked, BB_Locked_By_User_ID as Locked_By, _Users.Name_First, _Users.Name_Last
			FROM	Billback_Allied
					INNER JOIN Billback ON Billback.Billback_ID = Billback_Allied.Billback_ID
					INNER JOIN _Users ON _Users.User_ID = Billback_Allied.BB_Locked_By_User_ID
			WHERE	Billback.Billback_ID = '#Billback_ID#'
		
		</CFQUERY>
 --->
		<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD <CFOUTPUT><CFIF Is_Locked EQ 1>TITLE="This Billback is locked by #Name_First# #Name_Last#"</CFIF></CFOUTPUT>><INPUT TYPE="CheckBox" NAME="Billback_ID" VALUE="#Billback_ID#" <CFIF ListFindNoCase(FORM.Already_Selected_List,Billback_ID,",")>CHECKED</CFIF> <CFIF Is_Locked EQ 1>DISABLED</CFIF> ></TD>
			<TD NOWRAP><B>[ #BB_Code# ]</B></TD>
			<TD>#BB_Status_Abbreviation#</TD>
			<TD nowrap>#DateFormat(BB_Date, "mm/dd/yyyy")#<BR>#BB_Code#</TD>
			<TD>#Payee#<BR>#BB_Title#</TD>
			<TD>#DateFormat(BB_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(BB_End_Date,"mm/dd/yyyy")#</TD>			
			<TD>#DollarFormat(BB_Amount)#</TD>
			
		</TR>
	</CFOUTPUT>
	</tbody>
	<INPUT TYPE="Hidden" NAME="Items_OnThis_Page" VALUE=<CFOUTPUT>"#Items_OnThis_Page#"</CFOUTPUT>>	
	<TR>
		<TD COLSPAN="100%" STYLE="Border:None"></TD>
	</TR>
</TABLE>

<BR>
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center">
	<TR>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: SubmitToReBillbacks()">import selected Billbacks</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: UncheckAll()">undo selections</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B>&nbsp;&nbsp;&nbsp;</TD>
		<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A HRef="##" ONCLICK="Javascript: Closewindow()">back to reassign Billbacks</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
	</TR>
</TABLE>   

<input type="hidden" value="0" name="finishedSearching">
</FORM>
<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js, /Script/javascript/dhtml.js" />

<SCRIPT language="JavaScript">
function SubmitToReBillbacks()
{	
	if(Any_Object_Checked(document.all.Billback_ID))
	{
		document.Select_BB.finishedSearching.value = 1;
		document.Select_BB.submit();			
	}
	else
	{
		alert("Please select at least one Billback to import.")
	}
}
function selectAll(thisobj)
{
	var bCheck = thisobj.checked;
	var chObjs = document.all.Billback_ID;
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

function UncheckAll()
{
	/* true or false based on browser - IE 10 and above or IE 9 and below. 
	'0' as an argument below means "false". */
	document.all.allbox.checked = checkOrUncheckBeforeFireEvent(0);
	callfireEvent(document,document.all.allbox,'Click');

	document.Select_BB.Already_Selected_List.value="";
	document.Select_BB.Billback_ID.value="";
}
function Closewindow()
{
	window.close();
}

function sort_by_this_order(fieldName, sOrder)
{
	var oForm = document.Select_BB;
	oForm.SORT_BY.value = fieldName;
	oForm.SORT_ORDER.value = sOrder;
	oForm.submit();
	return false;
}	
</SCRIPT>

<cfscript>
	dt.sDom = 'ti';
	dt.tableId = "bbList";
</cfscript>

<cfinclude template="\common_files\datatable\viewDataTable.cfm">

</body>
</html>
