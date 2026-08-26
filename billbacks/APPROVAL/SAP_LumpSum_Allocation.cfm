<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<STYLE>
TABLE.BorderTable TD 
{
	border-bottom:solid #93BEE2 1px;
}
</STYLE>


<CFIF NOT IsDefined("URL.Edit")>
	<CFQUERY NAME="GetProgramInfo" DATASOURCE="#Application.Datasource#">
		SELECT * FROM Billback_Program WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Deleted = 0
	</CFQUERY>
	
	<cfquery name="getParentIDs" datasource="#application.datasource#">
		select	*
		from	dbo.udf_program_revision_detail(#GetProgramInfo.Program_ID#)
		ORDER By Contract_Main_ID
	</cfquery>
	<CFSET getParentIDs_List = valuelist(getParentIDs.contract_main_id)>
	<CFSET FORM.FromBBProgProdForm = 1>
	<cfset FORM.Program_ID = getParentIDs_List>
	<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
	<cfset appSettings = genSettingsManager.get()>
	<cfset stStruct = Form>
	<cfset stStruct.appSettings = appSettings>
	
	<cfset productManager = CreateObject("component", "components.products.ProductManager").init()>
	
	<cfset searchProducts = productManager.search(stStruct)>
<CFELSE>	
	<CFQUERY NAME="searchProducts" DATASOURCE="#Application.Datasource#">
		SELECT 		BB_Lump_Sum_Allocation.Product_Hierarchy_ID,
					Allocated_Amount,
					Product_Hierarchy,
					Product_Hierarchy_Name
					
		FROM 		BB_Lump_Sum_Allocation
		INNER JOIN	Product_Hierarchy ON Product_Hierarchy.Product_Hierarchy_ID = BB_Lump_Sum_Allocation.Product_Hierarchy_ID
		WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND BB_Lump_Sum_Allocation.Deleted = 0
	</CFQUERY>	
</CFIF>

<CFQUERY NAME="BBApprovedAmt" DATASOURCE="#Application.Datasource#">
	SELECT Paid_Amount FROM BB_Approved WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">
</CFQUERY>

<FORM NAME="LumpSumAllocation" ACTION = "SAP_LumpSum_Allocation_Action.cfm" METHOD="POST">
<CFOUTPUT><INPUT TYPE="hidden" NAME="Billback_ID" VALUE="#Billback_ID#"></CFOUTPUT>
<INPUT TYPE="Hidden" NAME="Product_Hierarchy_List" VALUE="">
<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" WIDTH="600" ALIGN="Center">
	<TR>
		<TD COLSPAN="100%"><B><FONT COLOR="Navy" SIZE="2">LUMPSUM ALLOCATION:</FONT></B></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="Right"><B><FONT COLOR="NAVY" SIZE="2">Billback Approved Amount:</FONT> <FONT COLOR="Red" SIZE="2"><CFOUTPUT>#DOLLARFORMAT(BBApprovedAmt.Paid_Amount)#</CFOUTPUT></FONT></B><BR><BR></TD>
	</TR>
	<TR BGCOLOR="ffce84">
		<TD STYLE="Border-Bottom: solid 93BEE2 1px; font-size: 12px"><B>Prod Hierarchy</B></TD>
		<TD STYLE="Border-Bottom: solid 93BEE2 1px; font-size: 12px"><B>Prod Hierarchy Name</B></TD>
		<TD STYLE="Border-Bottom: solid 93BEE2 1px; font-size: 12px"><B>$ Amount</B></TD>
	</TR>
	<CFSET allList="">
	<CFSET ProductGroupCount = 0>
	<CFOUTPUT QUERY="searchProducts" GROUP="Product_Hierarchy_ID">
		<CFSET allList = LISTAPPEND(allList,Product_Hierarchy_ID,",")>
		<CFSET ProductGroupCount = ProductGroupCount + 1>
		<TR BGCOLOR="#IIf(ProductGroupCount Mod 2, DE('ffffff'), DE('C6FFC6'))#">
			<TD STYLE="Border-Bottom: solid 93BEE2 1px"><B>#Product_Hierarchy#</B></TD>
			<TD STYLE="Border-Bottom: solid 93BEE2 1px">#Product_Hierarchy_Name#&nbsp;</TD>
			<CFSET HieraID = REPLACE(Product_Hierarchy_ID,"-","_","All")>
			<TD STYLE="Border-Bottom: solid 93BEE2 1px"><INPUT TYPE="TEXT" NAME="Amount_#HieraID#" <CFIF IsDefined("Allocated_Amount")>VALUE="#Allocated_Amount#"<CFELSE>VALUE=""</CFIF> onKeyUp="clenseText(this, '0123456789.')"></TD>	
		</TR>
	</CFOUTPUT>
		<TR>
			<TD COLSPAN="100%" ALIGN="Center"><BR><BR>
				<CF_button
					button_name	=	""
					button_caption	=	"save allocation"
					button_action	=	"validate()"
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
</FORM>
<SCRIPT SRC="/Script/javascript/string_functions.js"></SCRIPT>	
<SCRIPT language="JavaScript">
function validate()
{
	var allHierarID = "<CFOUTPUT>#REPLACE(allList,"-","_","All")#</CFOUTPUT>";
	var totBBAmt = "<CFOUTPUT>#BBApprovedAmt.Paid_Amount#</CFOUTPUT>";
	var thisAmount;
	var totAmt = 0;
	var amtDiff;
	
	var hierarchyID = new Array();
	hierarchyID = allHierarID.split(",");
	document.all.Product_Hierarchy_List.value="<CFOUTPUT>#allList#</CFOUTPUT>";
	
	
	for (i=0; i<hierarchyID.length; i++)
	{
		//alert(hierarchyID[i])		
		thisAmount = eval("document.all.Amount_"+hierarchyID[i]);
		if (!isNaN(parseFloat(thisAmount)))
		{			
			totAmt = totAmt + parseFloat(thisAmount);
		}		
	}
	totAmt = Math.round(totAmt*100)/100;
	totBBAmt = Math.round(totBBAmt*100)/100;
	if (totAmt == totBBAmt)
	{
		document.all.LumpSumAllocation.submit()
	}
	else
	{
		amtDiff = totBBAmt - totAmt;
		if (amtDiff > 0)
		{
			alert("There is a amount difference between billback approved amount and the allocated amount.\n\n - Add $" +amtDiff)
		}
		else
		{
			alert("There is a amount difference between billback approved amount and the allocated amount.\n\n - Subract $" +amtDiff)
		}
	}
}
</SCRIPT>

</body>
</html>
