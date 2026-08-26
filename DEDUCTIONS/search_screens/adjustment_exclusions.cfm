<!---
/deductions/search_screens/adjustment_exclusion.cfm
Brenda Flynn
July 10, 2003

--->

<!---Sends them home if they're not allowed to use this --->

<!--------------------------------------------------------
Start Search Form
--------------------------------------------------------->

<STYLE>
	SELECT,INPUT
	{
		font-size : 10px;
	}
	SELECT
	{
		font-size : 10px;
		WIDTH:200px;
	}
</STYLE>

<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
			<CFSET Date_Operator_Symbols=" ,>=,=,<=">


<CFSET PAGE_TITLE="Exclusions and Adjustments Search">
<CFSET GROUP="Deployment">

<CFPARAM NAME="startrow"		DEFAULT="1">
<CFPARAM NAME="frompage" 		DEFAULT="1">
<CFPARAM NAME="searchstring" 	DEFAULT="">
<CFPARAM NAME="DoSearch" 		DEFAULT="0">

<CFPARAM NAME="selectedReasons" DEFAULT="">
<CFPARAM NAME="finishedselecting" DEFAULT="0">

<CFPARAM NAME="BB_Numbers" 		DEFAULT="">
<CFPARAM NAME="BB_Dollar"		DEFAULT="">
<CFPARAM NAME="Prog_numbers"	DEFAULT="">
<CFPARAM NAME="Prog_name"		DEFAULT="">
<CFPARAM NAME="Dist_name"		DEFAULT="">
<CFPARAM NAME="Brok_name"		DEFAULT="">
<CFPARAM NAME="Adj_Exc_Amount"	DEFAULT="">

<CFPARAM NAME="sort_by" 		DEFAULT="Amount">
<CFPARAM NAME="sort_order" 		DEFAULT="DESC">

<CFPARAM NAME="highlight" 		DEFAULT="0">

<cf_Number_of_Rows maxrows=13>


<cfif finishedselecting IS 0 AND isDefined("Distributor_ID")>
<cfset useLakebaseForDistributorName = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bsa_foodservice_customers")>
<cfif useLakebaseForDistributorName>
	<cftry>
		<cfset DistributorName = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bsa_foodservice_customers", {
				"select" = "name",
				"bsa_foodservice_customers_id" = "eq.#Distributor_ID#"
			}),
			"name"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDistributorName = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDistributorName>
<cfquery name="DistributorName" datasource="#application.datasource#">
SELECT Name 
FROM BSA_Foodservice_Customers
WHERE BSA_Foodservice_Customers_ID = '#Distributor_ID#'
</cfquery>
</cfif>

<cfset Dist_Name = DistributorName.Name>
<cfset Highlight = 1>
</cfif>


<CFIF finishedselecting IS 1>

<cfset useLakebaseForDeletePrevious = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_relationships")>
<cfif useLakebaseForDeletePrevious>
	<cftry>
		<cfset application.oLakebase.deleteRows("dd_relationships",
			{ "dd_relationship_type_id" = "in.(1,2)", "deduction_id" = "eq.#Deduction_ID#" }
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForDeletePrevious = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForDeletePrevious>
<cfquery name="DeletePrevious" datasource="#application.datasource#">
DELETE FROM DD_Relationships 
WHERE 
( DD_Relationship_Type_ID = 1 OR DD_Relationship_Type_ID = 2)
AND Deduction_ID = '#Deduction_ID#'
</cfquery>
</cfif>

<CFLOOP INDEX="ListItem" LIST="#SelectedReasons#" DELIMITERS=",">

	<cfset SelectedReason = replace(ListItem, '_', '-', "all")>
<cfoutput>
	#evaluate("Type_#ListItem#")#<br>
	'#ListItem#'<p></p>
</cfoutput>	

	<cfset useLakebaseForInsertValues = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_relationships")>
	<cfif useLakebaseForInsertValues>
		<cftry>
			<cfset application.oLakebase.insertRow("dd_relationships", {
				"deduction_id" = Deduction_ID,
				"dd_relationship_type_id" = evaluate("Type_#ListItem#"),
				"dd_key_to_relationship" = SelectedReason
			})>
			<cfcatch type="any">
				<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
				<cfset useLakebaseForInsertValues = false>
			</cfcatch>
		</cftry>
	</cfif>
	<cfif NOT useLakebaseForInsertValues>
  <cfquery name="InsertValues" datasource="#application.datasource#">
	INSERT INTO DD_Relationships
	(
		Deduction_ID,
		DD_Relationship_Type_ID,
		DD_Key_to_Relationship
	)
	VALUES
	(
		'#Deduction_ID#',
		#evaluate("Type_#ListItem#")#,
		'#SelectedReason#'
	)
	</cfquery> 
	</cfif>
</CFLOOP>

<!---Submit the form--->
	<cfoutput>
	<script>
		window.close()		
		opener.document.Refresh.submit()
	</script>
	</cfoutput>
	<cfabort>
</CFIF>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
	<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
		<SCRIPT>
		function sortByThisItem(thisObj, thisSortItem, thisSortOrder)
		{ 	
			isSearching = 1;
			var formObj;
			formObj = document.all.adjandexcl;
			formObj.sort_by.value = thisSortItem;
			formObj.sort_Order.value = thisSortOrder;
			if(formObj.frompage.value.length == 0)	formObj.frompage.value = 1;
			if(formObj.startrow.value.length == 0)	formObj.startrow.value = 1;
			
			formObj.submit();
			return false;
		}	 	
		
		function reset_form()
		{ 
		if(confirm("Are you sure you want to reset these search criteria?"))
			{
				document.adjandexcl.BB_Numbers.value = "";
				document.adjandexcl.BB_Dollar.value = "";
				document.adjandexcl.Prog_Numbers.value = "";
				document.adjandexcl.Prog_Name.value = "";
				document.adjandexcl.Dist_Name.value = "";
				document.adjandexcl.Brok_Name.value = "";
				document.adjandexcl.Adj_Exc_Amount.value = "";
			}
		}
		
		function selectAll(){
		
			if(window.checkallReasons != null){
				for(var x=0; x<checkallReasons.length;x++){
					box = getFirstChild(checkallReasons[x])
					box.checked = document.all.checkall.checked
				}
			}
		}
		
		function finishedSearching() {
			document.all.finishedselecting.value = 1
			document.all.adjandexcl.submit();
		}

</SCRIPT>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!---Spinner--->
<SPAN CLASS="title2" ID="PleaseWaitMessage" ALIGN="CENTER">
 <br><br><br>
 <center><CFINCLUDE TEMPLATE="/includes/please_wait.cfm"></center>
 <br><br><br>
</SPAN>
<CFFLUSH>
<SCRIPT LANGUAGE="JavaScript">

function hide_PleaseWaitMessage()
{ 
 document.all.PleaseWaitMessage.style.display='none';
}
hide_PleaseWaitMessage();


</SCRIPT>


<script>


</script>
				
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

<blockquote>

	<FORM ACTION="adjustment_exclusions.cfm" METHOD="post" NAME="adjandexcl" ID="adjandexcl">

	<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width:855px">
	    <cfoutput><LEGEND STYLE="font: bold 14px sans-serif; color: Red;">adjustments and exclusions search</LEGEND></cfoutput>
			<TABLE border="0"  WIDTH="855px" cellpadding="0" cellspacing="0">
			<cfoutput>
			<tr><td colspan="2" valign="center"> <strong>#application.returned_customer_setting.distributor_label_singular# Criteria</strong></td>
				<td colspan="2" valign="center"><strong>Program Criteria</strong></td>
			</tr>
			<tr>
					<TD COLSPAN="1"><!--- Distributor Name --->
					<span ID="searchItemLabel">#application.returned_customer_setting.distributor_label_singular# Name</span><BR>
						<input type="text" size="35" name="Dist_Name" value="#Dist_Name#" <cfif highlight IS 1>style="background: lightsteelblue;"</cfif>>		&nbsp; &nbsp; 		
					</TD>
					
					<TD><!--- Billback Amount --->
						<span ID="searchItemLabel">Broker Name</span><BR>
					<input type="text" size="35" name="Brok_Name" value="#Brok_Name#">&nbsp; &nbsp; 					
					</TD>
					
					<TD COLSPAN="1"><!--- Program Numbers --->
					<span ID="searchItemLabel">Number and Reference Number</span><BR>
						<input type="text" size="35" name="Prog_Numbers" value="#Prog_Numbers#">&nbsp; &nbsp; 				
					</TD>
					
					<TD><!--- Program Nmae --->
						<span ID="searchItemLabel">Program Name</span><BR>
					<input type="text" size="35" name="Prog_Name" value="#Prog_Name#">	&nbsp; &nbsp; 				
					</TD>
					
				</TR>
				
				<tr><td colspan="2" valign="center"> <strong>Billback Criteria</strong></td>
				<td colspan="2" valign="center"><strong>Adjustment and Exclusion Criteria</strong></td>
				</tr>
				<tr>
				
				<TD ><!--- Billback Numbers --->
					<span ID="searchItemLabel">Number and Reference Number</span><BR>
						<input type="text" size="35" name="BB_Numbers" value="#BB_Numbers#">	&nbsp; &nbsp; 			
					</TD>
					
					<TD valign="top"><!--- Billback Amount --->
						<span ID="searchItemLabel">$ Claimed</span><BR>
					$<input type="text" size="8" name="BB_Dollar" value="#BB_Dollar#" onKeyUp="clenseText(this, '.0123456789'); allowonlytwodecimalplaces(this);">					&nbsp; &nbsp; 
					</TD>
					
					
					<TD valign="top"><!--- Adjustment/Exclusion amount --->
					<span ID="searchItemLabel">Adjustment/Exclusion Amount</span><BR>
						$<input type="text" size="8" name="Adj_Exc_Amount" value="#Adj_Exc_Amount#" onKeyUp="clenseText(this, '0123456789'); allowonlytwodecimalplaces(this);">				
					</TD>
					
					<TD>
					&nbsp; &nbsp; 
					<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" ONCLICK="reset_form();">reset</a><FONT COLOR="##FF0000">]</FONT></B>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10">
					&nbsp;&nbsp;
					<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" ONCLICK="javascript:document.adjandexcl.submit();">search</a><FONT COLOR="##FF0000">]</FONT></B>		
					</TD>
					
				</TR>
				</cfoutput>
					</table>
			<input type="Hidden" name="DOSEARCH" value="1">
			</TABLE>

<CFIF DOSEARCH EQ 1>

<!------ Get application settings ----->
<cfset genSettingsManager = CreateObject("component", "components.settings.ApplicationSettingsManager").init() />
<cfset appSettings = genSettingsManager.get()>


<cfoutput><cfsavecontent variable="guts">
INNER JOIN Billback_Distributor 
		ON 
			(
				Billback_Distributor.Billback_ID = Billback.Billback_ID
				OR
				Billback_Distributor.Billback_ID = D_Billback.Billback_ID
			)
		AND Billback_Distributor.Deleted = 0
		INNER JOIN BSA_Foodservice_Customers
			ON BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID = Billback_Distributor.Distributor_ID
			<cfif len(trim(Dist_Name)) GT 0>
			AND
			(
				BSA_Foodservice_Customers.Name LIKE '%#Dist_Name#%'
			)
			</cfif>
			<cfif len(trim(Brok_Name)) GT 0>
				<cfif appSettings.getDistributorMultiPosition()>
				INNER JOIN Market_Distributor
				ON
				Market_Distributor.Deleted = 0
				AND Market_Distributor.Distributor_ID = BSA_FoodService_Customers.BSA_FoodService_Customers_ID
				</cfif>
				INNER JOIN BSA_Foodservice_Brokers			
				<cfif appSettings.getDistributorMultiPosition()>
				ON BSA_Foodservice_Brokers.Service_Market_ID = Market_Distributor.Service_Market_ID
				<cfelse>
				ON BSA_Foodservice_Brokers.BSA_Foodservice_Brokers_ID = BSA_Foodservice_Customers.BSA_Foodservice_Brokers_ID
				</cfif>
				AND	BSA_Foodservice_Brokers.Broker_Name LIKE '%#Brok_Name#%'
			</cfif>
		INNER JOIN Billback_Program 
		ON 
			(
				Billback_Program.Billback_ID = Billback.Billback_ID
				OR
				Billback_Program.Billback_ID = D_Billback.Billback_ID
			)
		AND Billback_Program.Deleted = 0
		INNER JOIN Contract_Main ON
			Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			<cfif len(trim(Prog_Numbers)) GT 0>
			AND
			(
				Contract_Main.Contract_Number LIKE '%#Prog_Numbers#%'
				OR
				Contract_Main.Contract_Reference_Number LIKE '%#Prog_Numbers#%'
			)
			</cfif>
			<cfif len(trim(Prog_Name)) GT 0>
			AND
			(
				Contract_Main.Contract_Number LIKE '%#Prog_Name#%'
				OR
				Contract_Main.Contract_Title LIKE '%#Prog_Name#%'
			)
			</cfif>
	WHERE 0 = 0
	<cfif len(trim(BB_Numbers)) GT 0>
	AND
	(
		Billback.BB_Reference LIKE '%#BB_Numbers#%'
		OR
		D_Billback.BB_Reference LIKE '%#BB_Numbers#%'
		OR
		Billback.BB_Code LIKE '%#BB_Numbers#%'
		OR
		D_Billback.BB_Code LIKE '%#BB_Numbers#%'
		OR 
		Billback.BB_Title LIKE '%#BB_Numbers#%'
		OR
		D_Billback.BB_Title LIKE '%#BB_Numbers#%'
	)
	</cfif>
	<cfif len(trim(BB_Dollar)) GT 0>
	AND
	(
		Billback.BB_Amount LIKE '%#BB_Dollar#%'
		OR 
		D_Billback.BB_Amount LIKE '%#BB_Dollar#%'
	)
	</cfif>
</cfsavecontent></cfoutput>


	<CFQUERY NAME="TheQuery" DATASOURCE="#application.datasource#">
	SELECT DISTINCT BSA_Foodservice_Customers.Name, BB_Adjustment.Adjustment_Amount AS Amount, BB_Adjustment.Adjustment_Deducted_From_BB_ID AS Applied_To, Type = 1, BB_Adjustment.Date_Applied AS Date_Applied, Billback.BB_Title, D_Billback.BB_Title AS Applied_Billback_Name, BB_Adjustment.BB_Adjustment_ID AS Identifier
	FROM Billback
		INNER JOIN BB_Adjustment 
		ON BB_Adjustment.Billback_ID = Billback.Billback_ID
			LEFT JOIN Billback D_Billback
			ON D_Billback.Billback_ID = BB_Adjustment.Adjustment_Deducted_From_BB_ID
		#PreserveSingleQuotes(guts)#
		<cfif len(trim(Adj_Exc_Amount))>
		AND BB_Adjustment.Adjustment_Amount LIKE '%#Adj_Exc_Amount#%'
		</cfif>
		AND BB_Adjustment.Applied = 1
	 UNION
	SELECT DISTINCT BSA_Foodservice_Customers.Name, (SELECT SUM(BB_Product_Exclusion.Dollar_Amount) FROM BB_Product_Exclusion WHERE BB_Product_Exclusion.BB_Program_Exclusion_ID = BB_Program_Exclusion.BB_Program_Exclusion_ID) AS Amount, BB_Program_Exclusion.Exclusion_Deducted_From_BB_ID AS Applied_To, Type = 2, BB_Program_Exclusion.Date_Applied AS Date_Applied, Billback.BB_Title, D_Billback.BB_Title AS Applied_Billback_Name, BB_Program_Exclusion.BB_Program_Exclusion_ID AS Identifier
	FROM Billback
		INNER JOIN BB_Program_Exclusion 
		ON BB_Program_Exclusion.Billback_ID = Billback.Billback_ID
			LEFT JOIN Billback D_Billback
			ON D_Billback.Billback_ID = BB_Program_Exclusion.Exclusion_Deducted_From_BB_ID
		#PreserveSingleQuotes(guts)#
		<cfif len(trim(Adj_Exc_Amount))>
		AND (SELECT SUM(BB_Product_Exclusion.Dollar_Amount) FROM BB_Product_Exclusion WHERE BB_Product_Exclusion.BB_Program_Exclusion_ID = BB_Program_Exclusion.BB_Program_Exclusion_ID) LIKE '%#Adj_Exc_Amount#%'
		</cfif>
		AND BB_Program_Exclusion.Applied = 1
		ORDER BY #sort_by# #sort_order#
	</CFQUERY>
	
	<!--- 	<cfdump var="#TheQuery#">
<cfabort> --->

	<SCRIPT>
	<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
			function CA() {
				if(<CFIF TheQuery.RecordCount GTE 100>confirm("Your browser may seem to lock up if there are too many exclusions and adjustments in the list below while selecting them all.")<CFELSE>0==0</CFIF>) {
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

</fieldset>

<cfset useLakebaseForAlreadySelectedItems = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("dd_relationships")>
<cfif useLakebaseForAlreadySelectedItems>
	<cftry>
		<cfset AlreadySelectedItems = application.oLakebase.toQuery(
			application.oLakebase.selectRows("dd_relationships", {
				"select" = "dd_key_to_relationship",
				"deduction_id" = "eq.#Deduction_ID#",
				"dd_relationship_type_id" = "in.(1,0)"
			}),
			"dd_key_to_relationship"
		)>
		<cfcatch type="any">
			<!--- Lakebase is momentarily unavailable (e.g. serverless compute scaling) -- fall back to SQL Server for this request rather than surface an error. --->
			<cfset useLakebaseForAlreadySelectedItems = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAlreadySelectedItems>
<cfquery name="AlreadySelectedItems" datasource="#application.datasource#">
SELECT DISTINCT DD_Key_To_Relationship
FROM DD_Relationships
WHERE Deduction_ID = '#Deduction_ID#'
AND 
(
	DD_Relationship_Type_ID = 1
	OR
	DD_Relationship_Type_ID = 0
)
</cfquery>
</cfif>

<cfset AlreadySelected =  listqualify(valuelist(AlreadySelectedItems.DD_Key_To_Relationship), chr(39))>


	<FIELDSET STYLE="padding:8px; border: 1px solid Blue; width:855px" >
	    <LEGEND STYLE="font: bold 14px sans-serif; color: Red;">There <CFIF TheQuery.recordcount EQ 1>is<CFELSE>are</CFIF> <CFOUTPUT>#TheQuery.recordcount#</CFOUTPUT> <CFIF TheQuery.recordcount EQ 1>adjustment/exclusion<CFELSE>adjustments/exclusions</CFIF> that <CFIF TheQuery.recordcount EQ 1>matched<CFELSE>match</CFIF> the above criteria</LEGEND>

<br>

		<CFSET FORM.AlreadySelectedItems = "">
		<CFIF TheQuery.recordcount GT 0>
			<TABLE border="0" cellspacing="0" cellpadding="3" WIDTH="855px" CLASS="Maintable">
				<TR ID="header" BGCOLOR="#ffce84">
				<td><input TYPE="checkbox" NAME="checkall" ONCLICK="selectAll();"></td>
				
									<cfoutput>
							
				
				<CFSET HeaderNameList = "$ Amount, #application.returned_customer_setting.distributor_label_singular#, Type, Creating Billback, Date Applied, Billback Applied To">
				<CFSET HeaderColumnList = "Amount,Name,Type,BB_Title,Date_Applied,Applied_Billback_Name">
			
				
				<CFSET Counter = 1>
				<CFLOOP LIST="#HeaderNameList#" INDEX="this_Header" DELIMITERS=",">
				<CFSET sortImage="">	
					
				<CFIF listgetat(HeaderColumnList,Counter) EQ sort_by>
					<CFIF SORT_ORDER EQ "DESC">
						<CFSET New_Sort_Order="ASC">
						<CFSET sortImage="up_1.gif">
					<CFELSE>
						<CFSET New_Sort_Order="DESC">
						<CFSET sortImage="down_1.gif">
					</CFIF>
					<CFELSE>
						<CFSET New_Sort_Order="ASC">
					</CFIF>
					<TD ID="header" <cfif this_Header IS " Total $">align="right"<cfelse>align="left"</cfif>><strong><A HREF="##" OnClick="javaScript: return sortByThisItem(this,'#listgetat(HeaderColumnList,Counter)#','#New_Sort_Order#');">#this_Header#<CFIF Len(sortImage) GT 0> <IMG BORDER="0" SRC="/Images/#sortImage#"></CFIF></A></strong></TD>
					<CFSET Counter = Counter + 1>
					</CFLOOP>
				</cfoutput>
		
				</TR>
			
		
			<CFOUTPUT QUERY="TheQuery" startrow="#StartRow#" maxrows="#MaxRows#">
				<TR  STYLE="cursor:pointer;" <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>


 <cfset IdentifierReplaced = replace(Identifier, '-', '_', "all")>
					<td><span ID="checkallReasons"><input TYPE="checkbox" NAME="selectedReasons" value="#IdentifierReplaced#" ONCLICK="if(!this.checked) document.all.checkall.checked = false;"  <cfif Listcontains(AlreadySelected, Identifier, ",")> Checked</cfif> ></span></td>
					<TD onclick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#Identifier#&Type=#Type#','De','850','600','Yes', 'Yes');return false;"  NOWRAP>#LSCurrencyFormat(Amount)#&nbsp;</TD>
					<TD onclick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#Identifier#&Type=#Type#','De','850','600','Yes', 'Yes');return false;"  NOWRAP>#Name#&nbsp;</TD>
					<TD onclick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#Identifier#&Type=#Type#','De','850','600','Yes', 'Yes');return false;" NOWRAP><cfif Type IS 1>Adjustment<input type="hidden" name="Type_#IdentifierReplaced#" value="1"><cfelse>Exclusion<input type="hidden" name="Type_#IdentifierReplaced#" value="2"></cfif>&nbsp; </TD>
					<TD onclick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#Identifier#&Type=#Type#','De','850','600','Yes', 'Yes');return false;" NOWRAP>#BB_Title#&nbsp; </TD>
					<TD onclick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#Identifier#&Type=#Type#','De','850','600','Yes', 'Yes');return false;" NOWRAP><cfif len(trim(Date_Applied)) GT 0>#DateFormat(Date_Applied, 'MM/DD/YYYY')#<cfelse>N/A</cfif>&nbsp; </TD>
					<TD onclick="NewWindow('/deductions/search_screens/adjustment_exclusions_detail.cfm?ID=#Identifier#&Type=#Type#','Details','850','600','Yes', 'Yes');return false;" NOWRAP>#Applied_Billback_Name#&nbsp; </TD>

 				</TR> 
			</CFOUTPUT>
			
			<tr><td colspan="100%" align="center"><a HREF="#" onClick="javascript: javascript: finishedSearching()"><strong>[ add to deduction ]</strong></a></tr>
			</TABLE>

			<DIV ALIGN="center" STYLE="font-size: 12px; color: Red;">
			<CF_Next_Previous_For_Forms
				formname="adjandexcl"
				query="TheQuery"
				maxpages="40"
				previous		=	"<IMG SRC=""/images/previous.gif"" ALIGN=""middle"" BORDER=""0"">"
				next			=	"<IMG SRC=""/images/next.gif"" ALIGN=""middle"" BORDER=""0"">"
				previousseries	=	"<IMG SRC=""/images/previous_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				nextseries		=	"<IMG SRC=""/images/next_series.gif"" ALIGN=""middle"" BORDER=""0"">"
				addparams=""
			>
		</CFIF>
	</FIELDSET>
	
</CFIF>

<Cfoutput>
<INPUT TYPE="hidden" name="sort_by" value="#sort_by#">
<INPUT TYPE="hidden" name="sort_Order" value="#sort_Order#">
<input type="hidden" name="ParentForm" value="#ParentForm#">
<INPUT TYPE="hidden" name="Deduction_ID" value="#Deduction_ID#">
</CFOUTPUT>
<INPUT TYPE="Hidden" NAME="startrow" VALUE="1">
<INPUT TYPE="Hidden" NAME="frompage" VALUE="1">
<INPUT TYPE="hidden" NAME="finishedselecting" 	VALUE="">



</FORM>

</blockquote>


</BODY>
</HTML>