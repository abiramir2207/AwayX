<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
<title></title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
<style type="text/css">
TR.highlight
	{
	background-color: #EAFFEA;
	border-bottom: 1px solid #7575FF;
	align: right;
	}
TR.nothighlight
	{
	border-bottom: 1px solid #7575FF;
	}
</style>

<SCRIPT language="JavaScript">
function ClickToOpenLayer(TotalRows,Distributor_ID)
{
var DisplayObject;

	/* Loop through the rows of the Detailed report */
	for (i=1; i<=TotalRows; i++)
	{
	
	/* Get the row's ID */
	DisplayObject = document.getElementById(Distributor_ID+i)

	/* Show/Hide based on its visible status */
		if(DisplayObject.style.display == 'none')
		{
		DisplayObject.style.display = '';
		}
		else
		{
		DisplayObject.style.display = 'none';
		}
	}
}


function getDistributorForSearchPage()
{

var SeperatorPosition;
var StringLength;
if(DistributorFiscalYear.Distributor_ID_And_Name.length > 1)
{
	for(i=0; i< DistributorFiscalYear.Distributor_ID_And_Name.length; i++)
	{
		if(DistributorFiscalYear.Distributor_ID_And_Name[i].checked == true)
		{
		StringLength = DistributorFiscalYear.Distributor_ID_And_Name[i].length;
		SeperatorPosition = DistributorFiscalYear.Distributor_ID_And_Name[i].value.indexOf("--||--");
		window.opener.SearchForm.Distributor_ID_For_Fiscal_Year.value = DistributorFiscalYear.Distributor_ID_And_Name[i].value.substring(0,SeperatorPosition);
		window.opener.SearchForm.Distributor_Name_For_Fiscal_Year.value = DistributorFiscalYear.Distributor_ID_And_Name[i].value.substring(SeperatorPosition + 6,StringLength);
		}	
	}
}
else
{
		if(DistributorFiscalYear.Distributor_ID_And_Name.checked == true)
		{
		StringLength = DistributorFiscalYear.Distributor_ID_And_Name.length;
		SeperatorPosition = DistributorFiscalYear.Distributor_ID_And_Name.value.indexOf("--||--");
		window.opener.SearchForm.Distributor_ID_For_Fiscal_Year.value = DistributorFiscalYear.Distributor_ID_And_Name.value.substring(0,SeperatorPosition);
		window.opener.SearchForm.Distributor_Name_For_Fiscal_Year.value = DistributorFiscalYear.Distributor_ID_And_Name.value.substring(SeperatorPosition + 6,StringLength);
		}	
}

self.close();
}
</SCRIPT>
</head>

<cfquery name="getDistributorFiscalCalendar" datasource="#application.datasource#">
	SELECT Distributor_Fiscal_Year.*, BSA_Foodservice_Customers.Name
	FROM Distributor_Fiscal_Year INNER JOIN BSA_Foodservice_Customers
	ON Distributor_Fiscal_Year.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
	WHERE Distributor_Fiscal_Year.Deleted = 0 AND Distributor_Fiscal_Year.Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
	ORDER BY Distributor_Fiscal_Year.Distributor_ID,Distributor_Fiscal_Year.Start_Date 
</cfquery>


<body>
<SPAN CLASS="title2">Current Saved Settings</SPAN><BR>
<HR COLOR="Orange">

<!--- Number of columns to display --->
<cfset number_of_columns = 6>

<cfset Distributor_List = "">
<TABLE BORDER="0" CELLPADDING="0" CELLSPACING="2">

<cfoutput query="getDistributorFiscalCalendar">

	<cfif ListFind(Distributor_List,Distributor_ID) eq 0>
	
	<!--- Make a Unique Distributor List --->
		<cfset Distributor_List = ListAppend(Distributor_List,Distributor_ID)>
	<!--- If there are more than 6 Fiscal periods, then RowNumber will be 2 or 3 as the data will be shown in two rows/three rows. This is used	
		for DHTML purposes (we pass the total rows as RowNumber (1 or 2 or 3) for a distributor  --->
		<cfset RowNumber = 1>
		
	<!--- Get the count of Fiscal Periods for a distributor --->
	<cfquery name="getDistributorFiscalCalendarCount" datasource="#application.datasource#">
		SELECT Count(*) As FiscalCalendarPeriods
		FROM Distributor_Fiscal_Year INNER JOIN BSA_Foodservice_Customers
		ON Distributor_Fiscal_Year.Distributor_ID = BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID
		WHERE Distributor_Fiscal_Year.Deleted = 0 AND Distributor_Fiscal_Year.Company_Main_ID = '#request.AccessStructure.Company_Main_ID#'
		AND Distributor_Fiscal_Year.Distributor_ID = '#Distributor_ID#'
	</cfquery>
	
	<cfquery name="getDistributorName" datasource="#application.datasource#">
		SELECT Name 
		FROM BSA_Foodservice_Customers
		WHERE BSA_Foodservice_Customers_ID = '#Distributor_ID#'
	</cfquery>

	<!--- Since 1 to 6 Fiscal periods can be on one line AND more than 6 will be on two lines, we get either 1 or 2 or 3
	 (There can be upto 13 fiscal periods) --->
	<cfset NumberOfRows = Ceiling(getDistributorFiscalCalendarCount.FiscalCalendarPeriods / 6)>
	<form action="<cfoutput>#cgi.SCRIPT_NAME#</cfoutput>" method="post" name="DistributorFiscalYear">
	<TR onClick="ClickToOpenLayer(#NumberOfRows#,'#Distributor_ID#');">
		<TD colspan="#number_of_columns#"><input type="radio" name="Distributor_ID_And_Name" value="#Distributor_ID#--||--#getDistributorName.Name#"><a href="##">#Trim(Name)# (Periods)</a></TD>
	</TR>
	
		<cfset LoopCounter = 0>
	</cfif>
	
	<!--- If it's a new distributor OR there are more than 6 Fiscal periods --->
	<cfif LoopCounter eq 0  OR LoopCounter eq number_of_columns OR LoopCounter eq number_of_columns*2>
	<TR id="#Distributor_ID##RowNumber#" style="display:none;">
	</cfif>
	
	<cfset LoopCounter=LoopCounter + 1>
		<TD>#LoopCounter#.&nbsp;&nbsp;<INPUT STYLE="width: 75px; border: Solid 0px;" TYPE="text" READONLY value="#DateFormat(getDistributorFiscalCalendar.start_date,"mm/dd/yyyy")#"><br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;<INPUT STYLE="width: 75px; border: Solid 0px;" TYPE="text" value="#DateFormat(getDistributorFiscalCalendar.end_date,"mm/dd/yyyy")#"></TD>
	
	<!--- If It's the sixth Fiscal period OR the 12th Fiscal period(we had to account for this for the 13th fiscal period)
	 OR the last Fiscal period(for the distributor), end the Row --->
	<cfif LoopCounter eq number_of_columns OR LoopCounter eq number_of_columns*2 OR LoopCounter eq getDistributorFiscalCalendarCount.FiscalCalendarPeriods>
	<cfset RowNumber = RowNumber + 1>
	</TR>
	</cfif>
</cfoutput>
	<TR>
		<TD colspan="#number_of_columns#"><input type="submit" name="submit" value="submit" onClick="return getDistributorForSearchPage()"></TD>
	</TR>
	</form>
</TABLE>
</body>
</html>
