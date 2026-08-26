



<CFPARAM NAME="FORM.Items_OnThis_Page" DEFAULT="">
<CFPARAM NAME="FORM.Billback_ID" DEFAULT="">
<CFPARAM NAME="FORM.Items_OnThis_Page" DEFAULT="">
<CFPARAM NAME="FORM.Already_Selected_List" DEFAULT="">

<CFPARAM NAME="FORM.Distributor_List" DEFAULT="">
<CFPARAM NAME="FORM.Operator_List" DEFAULT="">
<CFPARAM NAME="FORM.Broker_List" DEFAULT="">

<CFIF FORM.Distributor_List NEQ "">
	<CFQUERY NAME="GetApprovedBB" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback.Billback_ID,
					BB_Code,
					BB_Title,
					Paid_Amount,
					BB_Reference,
					BB_Date,
					BB_Start_Date,
					BB_End_Date,
					Name Name,
					BB_Is_Locked,
					Name_First,
					Name_Last
					
		FROM 		Billback
		INNER JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		INNER JOIN	Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
		LEFT JOIN 	_Users ON _Users.User_ID = Billback_Allied.BB_Locked_By_User_ID AND 
					_Users.Deleted = 0
		INNER JOIN 	Billback_Distributor ON Billback_Distributor.Billback_ID = Billback.Billback_ID AND
					Billback_Distributor.Distributor_ID = '#FORM.Distributor_List#' AND
					Billback_Distributor.Deleted = 0
		INNER JOIN	BSA_Foodservice_Customers ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID AND
					BSA_Foodservice_Customers.Deleted = 0						
					
		WHERE 		Billback_Status_ID = 3	AND
					Paid_Amount > 0 AND
					Billback.Deleted = 0
					
		ORDER BY	BB_Code
	</CFQUERY>
	
<CFELSEIF FORM.Operator_List NEQ "">
	<CFQUERY NAME="GetApprovedBB" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback.Billback_ID,
					BB_Code,
					BB_Title,
					Paid_Amount,
					BB_Reference,
					BB_Date,
					BB_Start_Date,
					BB_End_Date,
					Operator_Name Name,
					BB_Is_Locked,
					Name_First,
					Name_Last
		
		FROM 		Billback
		INNER JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
		INNER JOIN	Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
		LEFT JOIN 	_Users ON _Users.User_ID = Billback_Allied.BB_Locked_By_User_ID AND 
					_Users.Deleted = 0
		INNER JOIN 	Billback_Operator ON Billback_Operator.Billback_ID = Billback.Billback_ID AND
					Billback_Operator.Operator_ID = '#FORM.Operator_List#' AND
					Billback_Operator.Deleted = 0
		INNER JOIN	BSA_Operator ON BSA_Operator.BSA_Operator_ID = Billback_Operator.Operator_ID AND
					BSA_Operator.Deleted = 0
							
		WHERE 		Billback_Status_ID = 3 AND
					Paid_Amount > 0 AND
					Billback.Deleted = 0	
		
		ORDER BY	BB_Code
	</CFQUERY>

<CFELSEIF FORM.Broker_List NEQ "">	
	<CFQUERY NAME="GetApprovedBB" DATASOURCE="#Application.Datasource#">
		SELECT 		Billback.Billback_ID,
					BB_Code,
					BB_Title,
					Paid_Amount,
					BB_Reference,
					BB_Date,
					BB_Start_Date,
					BB_End_Date,
					Broker_Name Name,
					BB_Is_Locked,
					Name_First,
					Name_Last
		
		FROM 		Billback	
		INNER JOIN	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID	
		INNER JOIN	Billback_Allied ON Billback_Allied.Billback_ID = Billback.Billback_ID
		LEFT JOIN 	_Users ON _Users.User_ID = Billback_Allied.BB_Locked_By_User_ID AND 
					_Users.Deleted = 0
		INNER JOIN 	Billback_Broker ON Billback_Broker.Billback_ID = Billback.Billback_ID AND
					Billback_Broker.Broker_ID = '#FORM.Broker_List#' AND
					Billback_Broker.Deleted = 0
		INNER JOIN	BSA_Foodservice_Brokers ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = Billback_Broker.Broker_ID AND
					BSA_Foodservice_Brokers.Deleted = 0 
		
					
		WHERE 		Billback_Status_ID = 3 AND
					Paid_Amount > 0 AND
					Billback.Deleted = 0	
		
		ORDER BY	BB_Code		
	</CFQUERY>
</CFIF>



<STYLE>
TABLE.BorderTable TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>



<CFLOOP LIST="#FORM.Billback_ID#" INDEX="Item">		
	<CFIF NOT ListFindNoCase(FORM.Already_Selected_List,Item,",")>
		<CFSET FORM.Already_Selected_List = ListAppend(FORM.Already_Selected_List,Item,",")>
	</CFIF>
</CFLOOP> 



<CFLOOP LIST="#FORM.Items_OnThis_Page#" INDEX="Item">	
	<CFIF Not ListFindNoCase(FORM.Billback_ID,Item,",")>
		<CFSET DeleteItemPosition = ListFindNoCase(FORM.Already_Selected_List,Item,",")>
		<CFIF DeleteItemPosition GT 0>
			<CFSET FORM.Already_Selected_List = ListDeleteAt(FORM.Already_Selected_List,DeleteItemPosition,",")>
		</CFIF>
	</CFIF>
</CFLOOP>

<cfparam name="form.FinishedSelection" default="0">
<cfif form.FinishedSelection>
	<!-----  return to paren page ----->
	<script language="JavaScript">
		submitOpener();
		function submitOpener()
		{
			var op = window.opener;
			if(op)
			{
				var parentForm = op.document.MultiBB;
				if(parentForm)
				{
					var BBObj = parentForm.Billback_ID;
					if(BBObj)
					{
						<cfoutput>
						BBObj.value = "#FORM.Already_Selected_List#";
						</cfoutput>
					}
					parentForm.action = "Distributor_And_BB_Form.cfm";
					parentForm.submit();
					window.close();
				}
			}
		}
	</script>		
</cfif>

<!--- <CFDUMP VAR="#GetApprovedBB#"> --->
<!--- <CFDUMP VAR="#FORM#"> --->
<FORM NAME="BB_Eligible_List" ACTION="Eligible_BB_List.cfm" METHOD="POST">
	
	<cfparam name="FORM.startrow"  default="1">
   	<CFPARAM NAME="FORM.frompage"   DEFAULT="1">
   	<cfparam name="FORM.pageLength"  default=12>
   	<CFSET startrow=FORM.startrow>
   	<CFSET frompage=FORM.frompage>
   	<cf_Number_of_Rows maxrows="#FORM.pageLength#">
	
	<CFOUTPUT>
	<INPUT TYPE="hidden" VALUE = "#FORM.frompage#" NAME="frompage">
	<INPUT TYPE="hidden" VALUE = "#FORM.StartRow#" NAME="startrow">	
	<INPUT TYPE="Hidden" NAME="Distributor_List" VALUE="#FORM.Distributor_List#">
	<INPUT TYPE="Hidden" NAME="Operator_List" VALUE="#FORM.Operator_List#">
	<INPUT TYPE="Hidden" NAME="Broker_List" VALUE="#FORM.Broker_List#">
	<INPUT TYPE="Hidden" NAME="FinishedSelection" VALUE="0">
	<INPUT TYPE="Hidden" NAME="Already_Selected_List" VALUE="#FORM.Already_Selected_List#"> 	
	</CFOUTPUT>
	<TABLE BORDER="0" CELLPADDING="3" CELLSPACING="0" ALIGN="Center" WIDTH="700" CLASS="BorderTable">	
		<TR>
			<TD COLSPAN="100%"><CFOUTPUT><B><FONT SIZE="2"><!--- There are #GetApprovedBB.Recordcount# --->Approved Billbacks for <CFIF FORM.Distributor_List NEQ ""> #application.returned_customer_setting.distributor_label_singular#: <CFELSEIF FORM.Operator_List NEQ "">#application.returned_customer_setting.operator_label_singular#: <CFELSEIF FORM.Broker_List NEQ "">BROKER: </CFIF>#GetApprovedBB.Name#</FONT></B></CFOUTPUT><BR><BR></TD>
		</TR>
		<TR BGCOLOR="FFE083">
			<TD><INPUT TYPE="CheckBox" NAME="allbox" ONCLICK="javaScript: selectAll(this);"></TD>
			<TD><B><FONT SIZE="2">Payable #</FONT></B></TD>
			<TD><B><FONT SIZE="2">Date<BR>Billback #</FONT></B></TD>
			<TD><B><FONT SIZE="2">Title</FONT></B></TD>
			<TD><B><FONT SIZE="2">Start<BR>End</FONT></B></TD>
			<TD><B><FONT SIZE="2">Amount</FONT></B></TD>
		</TR>
		<CFSET List_Items_OnThis_Page = "">
		<CFOUTPUT QUERY="GetApprovedBB" startrow="#StartRow#" maxrows="#MaxRows#">
			<CFSET List_Items_OnThis_Page = LISTAPPEND(List_Items_OnThis_Page,Billback_ID,",")>
			<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
				<TD VALIGN="Top" <CFIF BB_Is_Locked EQ 1>TITLE="This billback is locked by #Name_First# #Name_Last#"</CFIF>><INPUT TYPE="CheckBox" NAME="Billback_ID" VALUE="#Billback_ID#" <CFIF ListFindNoCase(FORM.Already_Selected_List,Billback_ID,",")>CHECKED</CFIF> <CFIF BB_Is_Locked EQ 1>DISABLED</CFIF>></TD>				
				<TD NOWRAP VALIGN="Top"><B><FONT SIZE="2">[ </FONT>#BB_Code#<FONT SIZE="2"> ]</FONT></B></TD>
				<CFSET Disp_Ref = BB_Reference>
				<CFSET Ref_Len = 30>
				<CFIF LEN(Disp_Ref) GT Ref_Len>
					<CFSET Disp_Ref = LEFT(Disp_Ref,Ref_Len)>
					<CFSET Disp_Ref = "#Disp_Ref#...">
				</CFIF>
				<TD VALIGN="Top">#DateFormat(BB_Date,"mm/dd/yyyy")#<BR>#Disp_Ref#</TD>			
				<TD VALIGN="Top">#BB_Title#</TD>
				<TD VALIGN="Top">#DateFormat(BB_Start_Date,"mm/dd/yyyy")#<BR>#DateFormat(BB_End_Date,"mm/dd/yyyy")#</TD>
				<TD VALIGN="Top">#DollarFormat(Paid_Amount)#</TD>
			</TR>
		</CFOUTPUT>	
		<CFOUTPUT><INPUT TYPE="Hidden" NAME="Items_OnThis_Page" VALUE="#List_Items_OnThis_Page#"></CFOUTPUT>
	</TABLE>
	<BR>
	<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="0" ALIGN="Center" WIDTH="700">
		<TR STYLE="border:none">
			<TD NOWRAP>
				<DIV ALIGN="left" STYLE="font-size: 12px; color: Red;">
					&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
					<CF_Next_Previous_For_Forms
					formname="BB_Eligible_List"
					query="GetApprovedBB"
					maxpages="15"
					previous  = "<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
					next   = "<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
					previousseries = "<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
					nextseries  = "<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
					addparams="">
				</DIV>
			</TD>
			<!--- <TD ALIGN="Right"><CFOUTPUT><B><FONT SIZE="2">There are #GetApprovedBB.Recordcount# approved billback for <CFIF URL.PayeeType EQ 1>DISTRIBUTOR: <CFELSEIF URL.PayeeType EQ 2>OPERATOR: <CFELSEIF URL.PayeeType EQ 3>BROKER: </CFIF>#GetApprovedBB.Name#.</FONT></B></CFOUTPUT>&nbsp;&nbsp;</TD>  --->
		</TR>
	</TABLE>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
		<TR>
			<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: importSelection()">import selected billbacks</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
			<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: UncheckAll()">undo selection</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
			<TD><B><FONT COLOR="Red" SIZE="2">[ </FONT><A Href="##" ONCLICK="Javascript: Closewindow()">back to payee selection</A><FONT COLOR="Red" SIZE="2"> ]</FONT></B></TD>
		</TR>
	</TABLE>
</FORM>

<cfmodule template="/customTags/include.cfm" file_to_include="/Script/javascript/dom_common.js, /Script/javascript/dhtml.js">
<SCRIPT language="JavaScript">
function importSelection()
{
	if((Any_Object_Checked(document.all.Billback_ID)) || (document.all.Already_Selected_List.value != ""))
	{
		document.BB_Eligible_List.FinishedSelection.value = 1;
		document.BB_Eligible_List.submit();			
	}	
	else
	{
		alert("Please select at least a billback to import.")
	}
	//document.BB_Eligible_List.target = _parent;
	/*document.BB_Eligible_List.action = "Distributor_And_BB_Form.cfm";	
	document.BB_Eligible_List.submit();*/
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
	document.all.allbox.checked = checkOrUncheckBeforeFireEvent(0)
	callfireEvent(document,document.all.allbox,'Click');

	document.BB_Eligible_List.Already_Selected_List.value="";
	document.BB_Eligible_List.Billback_ID.value="";
}

function Closewindow()
{
	window.close();
}

</SCRIPT>