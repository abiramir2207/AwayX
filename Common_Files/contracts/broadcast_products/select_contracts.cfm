<CFSET PAGE_TITLE="Product Blaster! - Select Contracts">
<CFSET GROUP="Contracts">

<CFQUERY NAME="GetActiveAndPreactiveContracts" datasource="#application.datasource#">
SELECT dbo.Contract_Main.*, 
    dbo.Units_of_Measure.Unit_Of_Measure_Desc
FROM dbo.Contract_Main INNER JOIN
    dbo.Units_of_Measure ON 
    dbo.Contract_Main.Contract_Quantity_UOM_IDX = dbo.Units_of_Measure.Unit_Of_Measure_ID
WHERE 
			Owner_Company_ID = '#request.AccessStructure.Company_Main_ID#'
			and
			template = 0
			and
			deleted =0
			AND
			(
				(
					Contract_Start_Date <= #createodbcdatetime(now())#
					and
					Contract_End_Date >= #createodbcdatetime(now())#
					and 
					Approval_Date IS NOT NULL
				)
			OR
				(
					Contract_Start_Date > #createodbcdatetime(now())#
					and
					Approval_Date IS NOT NULL				
				)
			)
			
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

</HEAD>

<BODY BACKGROUND="/images/background_gray_lines.gif" BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">



<style>
TABLE.Maintable TD 
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;
}
#header 
{
	font-size: 12px;
}
</style>




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<BLOCKQUOTE><BLOCKQUOTE>
<SCRIPT>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
		function CA() {
			if(<CFIF GetActiveAndPreactiveContracts.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many products in the list below while selecting them all. Press OK If You Wish To Continue")<CFELSE>0==0</CFIF>) {
				for (var i=0;i<MyForm.elements.length;i++)
					{
						var e = MyForm.elements[i];
						if ((e.name != 'allbox') && (e.type=='checkbox') && (e.name != 'ALLINCATEGORY')) {
							e.checked = MyForm.allbox.checked;
						}
					}
			//toggleRowColors()
			}
			else {
				document.all.allbox.checked = false;
			}
		}
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</SCRIPT>	
<FORM ACTION="enter_rebate_amounts.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<TABLE CLASS="Maintable" WIDTH="85%" CELLPADDING="3" CELLSPACING="0">
<CFIF GetActiveAndPreactiveContracts.Recordcount NEQ 0>
<TR BGCOLOR="#FFCE84" VALIGN="bottom">
	<TD><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Products"></TD>
	<TD ID="header"><B>Contract #</B></TD>
	<TD ID="header"><B><cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Name</B></TD>
	<TD ID="header"><B>Contract Title</B></TD>
	<TD ID="header"><B>Start Date</B></TD>
	<TD ID="header"><B>End Date</B></TD>
	<TD ID="header"><B>Quantity</B></TD>
	<TD ID="header"><B>UOM</B></TD>
</TR>
<TR>
	<TD BGCOLOR="Orange" COLSPAN="10"></TD>
</TR>
</CFIF>






<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Defines the number of rows to display per "page"										       --->
	<cf_Number_of_Rows maxrows="10">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFOUTPUT QUERY="GetActiveAndPreactiveContracts">




<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Decide what to show: operator name or a generic Multiple										 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

<CFIF isnumeric(GetActiveAndPreactiveContracts.Operator_ID)>
		<CFQUERY NAME="Get_Operator_Name" datasource="#application.datasource#">
			Select		BSA_Operator.operator_name
			From		BSA_Operator
			Where		BSA_Operator_ID	=	'#GetActiveAndPreactiveContracts.Operator_ID#'
		</CFQUERY>
		<CFSET operatorname=Get_Operator_Name.operator_name>
	<CFELSE>
		<CFSET operatorname="Multiple">
</CFIF>








<!--- Encrypt the CID (Contract record ID) --->
<cf_cryp type="en" string="#contract_main_id#" key="#request.key#">
<CFSET CID = cryp.value>


<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
	<TD><INPUT type="Checkbox" NAME="SelectedContracts" VALUE="#GetActiveAndPreactiveContracts.Contract_Main_ID#"></TD>
	<TD NOWRAP>
		<FONT SIZE="2" COLOR="Red"><B>[</B></FONT>
		
		<!--- <A HREF="/common_files/contracts/contract_view_master.cfm?CID=#CID#" STYLE="FONT-SIZE:12PX;" TITLE="View the details for contract #Contract_Number#">#Contract_Number#</A> --->
		<A HREF="/common_files/contracts/contract_edit_menu.cfm?CID=#CID#" STYLE="FONT-SIZE:12PX;" TITLE="View the details for contract #Contract_Number#">#Contract_Number#</A>
		<FONT SIZE="2" COLOR="Red"><B>]</B></FONT>
	</TD>
	<TD>#operatorname#&nbsp;</TD>
	<TD>#Contract_Title#&nbsp;</TD>
	<TD NOWRAP>#dateformat(Contract_Start_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD NOWRAP>#dateformat(Contract_End_Date, 'm/d/yyyy')#&nbsp;</TD>
	<TD NOWRAP>#numberformat(Contract_Quantity, '_,___,___,___,___')#&nbsp;</TD>
	<TD NOWRAP>#Unit_of_Measure_Desc#&nbsp;</TD>
</TR>
</CFOUTPUT>
<TR>
	<TD BGCOLOR="Orange" COLSPAN="10"></TD>
</TR>
</TABLE>
<BR>

<DIV ALIGN="center">
	<CF_button
		button_name		=	""
		button_caption	=	"enter prices"
		button_action	=	"Javascript: document.all.MyForm.submit()"
		button_type		=	"link"
		button_width	=	"150"
		button_color	=	"Navy"
		button_tip		=	""
		font_color		=	"White"
		font_size		=	"12"
		font_weight		=	"bold">	
</DIV>
<INPUT TYPE="hidden" NAME="UPC_LIST" VALUE="<CFOUTPUT>#FORM.UPC_LIST#</CFOUTPUT>">
</FORM>

</BLOCKQUOTE></BLOCKQUOTE>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
