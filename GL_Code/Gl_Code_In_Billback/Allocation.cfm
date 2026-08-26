<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<STYLE>
TABLE.UNDERLINED TD 
{
	border-bottom:solid 93BEE2 1px; 
}
</STYLE>

<CFQUERY NAME="CheckIsChild" DATASOURCE="#Application.Datasource#">
	SELECT 		* 
	FROM 		Billback 
	INNER JOIN 	BB_Approved ON BB_Approved.Billback_ID = Billback.Billback_ID
	WHERE 		Billback.Billback_ID = '#Billback_ID#'
</CFQUERY>

<CFQUERY NAME="CheckSavedAlloc" DATASOURCE="#Application.Datasource#">
	SELECT TOP 1 * FROM Gl_Code_Allocation 
	WHERE Billback_ID = '#Billback_ID#' AND
		DELETED = 0 AND
		ISNULL(Allocated_Amount,0) > 0
</CFQUERY>

<CFIF CheckIsChild.BB_Is_Child EQ 1>
	<CFSET FromARSelection = 1>
</CFIF>

<CFIF Not IsDefined("FromARSelection")>
	<CFSET URLString = "Billback_ID=#Billback_ID#">
	<CFIF IsDefined("Deduction_ID")>
		<CFSET URLString = "#URLString#&Deduction_ID=#Deduction_ID#">
	</CFIF>
	<CFIF IsDefined("Recal_Fund")>
		<CFSET URLString = "#URLString#&Recal_Fund=#Recal_Fund#"> 
	</CFIF>
	
	<CFLOCATION URL="AR_Selection.cfm?#URLString#" ADDTOKEN="No">
</CFIF>

<CFIF CheckSavedAlloc.RecordCount GT 0>
	<CFSET Dont_Recal_Fund = 1>
<CFELSE>
	<CFSET Dont_Recal_Fund = 0>
</CFIF>


<CFIF IsDefined("URL.Recal_Fund")>
	<CFIF URL.Recal_Fund EQ 0>
		<CFSET Dont_Recal_Fund = 1>
	</CFIF>
</CFIF>


<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
	UPDATE 	GL_Code_Item_Allocation_Cal
	SET 	Deleted = 1
	WHERE 	Billback_ID = '#Billback_ID#' AND			
			Deleted = 0
</CFQUERY>

<CFQUERY NAME="DeletePrevious" DATASOURCE="#Application.Datasource#">
	UPDATE 	GL_Code_Fixed_Fund_Allocation_Cal
	SET 	Deleted = 1
	WHERE 	Billback_ID = '#Billback_ID#' AND
			<CFIF Dont_Recal_Fund EQ 1>
				Allocation_Method <> 3 AND 
			</CFIF>
			Deleted = 0
</CFQUERY>


<CFQUERY NAME="DeleteAllo" DATASOURCE="#Application.Datasource#">
	UPDATE 	Gl_Code_Allocation
	SET 	Deleted = 1
	WHERE 	Billback_ID = '#Billback_ID#' AND
			<CFIF Dont_Recal_Fund EQ 1>
				Allocation_Method <> 3 AND 
			</CFIF>
			Deleted = 0
</CFQUERY>

<CFIF Dont_Recal_Fund EQ 1>
	<CFQUERY NAME="UpdateSave" DATASOURCE="#Application.Datasource#">
		UPDATE 	Gl_Code_Allocation
		SET 	Allocation_Saved = 0
		WHERE 	Billback_ID = '#Billback_ID#' AND
				Allocation_Method = 3 AND 
				Deleted = 0 AND
				Allocation_Saved = 1
	</CFQUERY>
</CFIF>

<CFQUERY NAME="GetDinstAllocation" DATASOURCE="#Application.Datasource#">
	SELECT 		DISTINCT Allocation_Method,
				ISNULL(LumpSum_Amt,0) AS LumpSum_Amt,
				LumpSum_Only
	FROM 		Billback_Program 
	WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0
	ORDER BY 	Billback_Program.Allocation_Method
</CFQUERY>

<CFSET IsThereItemAllocation = 0>
<CFSET IsThereFixedAllocation = 0>
<CFSET IsThereFundAllocation = 0>
<CFSET ItemProgram_List = "">
<CFSET FixedProgram_List = "">
<CFSET FundProgram_List = "">

<CFSET Billback_ID = Billback_ID>
<CFLOOP QUERY="GetDinstAllocation">
	<CFIF Allocation_Method EQ 1 AND LumpSum_Only EQ 0>		
		<CFSET IsThereItemAllocation = 1>
		<CFSET Allocation_Method = 1>		
		<CFQUERY NAME="GetARDetails" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT 	Billback_Program.A_R,
									Billback_Program.AR_From_Fiscal_Year
												
			FROM 		Billback_Program 
			WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0 AND
						Billback_Program.Allocation_Method = 1
			ORDER BY 	Billback_Program.AR_From_Fiscal_Year,Billback_Program.A_R
		</CFQUERY>

		<CFLOOP QUERY="GetARDetails">
			<CFQUERY NAME="GetProgramForEachAR" DATASOURCE="#Application.Datasource#">
				SELECT 		Billback_Program.Program_ID
				FROM 		Billback_Program 
				WHERE 		Billback_ID = '#Billback_ID#'
				AND 		Billback_Program.A_R <cfif Len(A_R) EQ 0>IS NULL<cfelse>= <cfqueryparam value="#A_R#" cfsqltype="CF_SQL_VARCHAR"></cfif>
				AND 		Billback_Program.AR_From_Fiscal_Year <cfif Len(AR_From_Fiscal_Year) EQ 0>IS NULL<cfelse>= <cfqueryparam value="#AR_From_Fiscal_Year#" cfsqltype="CF_SQL_VARCHAR"></cfif>
				AND 		Billback_Program.Allocation_Method = 1 
				AND			Billback_Program.Deleted = 0
			</CFQUERY>
			<CFSET Program_List = VALUELIST(GetProgramForEachAR.Program_ID)>
			<CFSET ItemProgram_List = Program_List>
			
			<CFINCLUDE TEMPLATE = "Item_Allocation_Cal.cfm">	
		</CFLOOP>
	<CFELSEIF Allocation_Method EQ 2>
		<CFSET IsThereFixedAllocation = 1>
		<CFSET Program_List = "">
		<CFSET Allocation_Method = 2>
		<CFQUERY NAME="GetARDetails2" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT 	Billback_Program.A_R,
									Billback_Program.AR_From_Fiscal_Year
												
			FROM 		Billback_Program 
			WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0 AND
						Billback_Program.Allocation_Method = 2
			ORDER BY 	Billback_Program.AR_From_Fiscal_Year,Billback_Program.A_R
		</CFQUERY>
		
		<CFLOOP QUERY="GetARDetails2">		
			<CFQUERY NAME="GetProgramForEachAR2" DATASOURCE="#Application.Datasource#">
				SELECT 		Billback_Program.Program_ID
				FROM 		Billback_Program 
				WHERE 		Billback_ID = '#Billback_ID#' AND 
							Billback_Program.A_R = '#A_R#' AND 
							Billback_Program.AR_From_Fiscal_Year = '#AR_From_Fiscal_Year#' AND 
							Billback_Program.Allocation_Method = 2 AND
							Billback_Program.Deleted = 0
			</CFQUERY>
			<CFSET Program_List = VALUELIST(GetProgramForEachAR2.Program_ID)>
			<CFSET FixedProgram_List = Program_List>
			<CFLOOP LIST = "#Program_List#" INDEX = "MainProgID">
				<CFINCLUDE TEMPLATE="Fixed_Fund_Allocation_Cal.cfm">
			</CFLOOP>
		</CFLOOP>
	</CFIF>

	<CFIF (Allocation_Method EQ 3 OR LumpSum_Amt NEQ 0) AND Allocation_Method NEQ 2 AND Dont_Recal_Fund EQ 0>
		<CFSET IsThereFundAllocation = 1>
		<CFSET Program_List = "">
		<CFSET Allocation_Method = 3>
		<CFQUERY NAME="GetARDetails3" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT 	Billback_Program.A_R,
									Billback_Program.AR_From_Fiscal_Year
												
			FROM 		Billback_Program 
			WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0 AND
						(Billback_Program.Allocation_Method = 3 OR ISNULL(Billback_Program.LumpSum_Amt,0) <> 0)
			ORDER BY 	Billback_Program.AR_From_Fiscal_Year,Billback_Program.A_R
		</CFQUERY>
		<CFLOOP QUERY="GetARDetails3">
			<CFQUERY NAME="GetProgramForEachAR3" DATASOURCE="#Application.Datasource#">
				SELECT 		Billback_Program.Program_ID,
							Allocation_Method,
							ISNULL(LumpSum_Amt,0) AS LumpSum_Amt,
							LumpSum_Only
							
				FROM 		Billback_Program 
				WHERE 		Billback_ID = '#Billback_ID#' AND 
							Billback_Program.A_R = '#A_R#' AND 
							Billback_Program.AR_From_Fiscal_Year = '#AR_From_Fiscal_Year#' AND 
							(Billback_Program.Allocation_Method = 3 OR ISNULL(Billback_Program.LumpSum_Amt,0) <> 0) AND
							Billback_Program.Deleted = 0
			</CFQUERY>
			<CFSET Program_List = VALUELIST(GetProgramForEachAR3.Program_ID)>
			<CFSET FundProgram_List = Program_List>
			<CFLOOP LIST = "#Program_List#" INDEX = "MainProgID">				
				<CFINCLUDE TEMPLATE="Fixed_Fund_Allocation_Cal.cfm">
			</CFLOOP>
		</CFLOOP>
	</CFIF>	
</CFLOOP>

<!---
<CFIF IsThereItemAllocation EQ 1>
	<CFSET Program_List = ItemProgram_List>
	<CFINCLUDE TEMPLATE = "Display_Item_Allocation.cfm">
</CFIF>
<CFIF IsThereFixedAllocation EQ 1>
	<CFSET Program_List = FixedProgram_List>
	<CFINCLUDE TEMPLATE="Display_Fixed_Allocation.cfm">
</CFIF>

<CFIF IsThereFundAllocation EQ 1>
	<CFSET Program_List = FundProgram_List>
	<CFINCLUDE TEMPLATE="Display_Fund_Allocation.cfm">	
</CFIF>
--->
<CFIF IsThereFundAllocation EQ 1 AND Dont_Recal_Fund EQ 0>
	<CFIF IsDefined("Deduction_ID")>
		<CFLOCATION URL = "Display_Fund_Allocation.cfm?Billback_ID=#Billback_ID#&deduction_Id=#Deduction_ID#" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL = "Display_Fund_Allocation.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
	</CFIF>	
<CFELSE>
	<CFIF IsDefined("Deduction_ID")>
		<CFLOCATION URL = "Allocation_Layout.cfm?Billback_ID=#Billback_ID#&deduction_ID=#Deduction_ID#" ADDTOKEN="No">
	<CFELSE>
		<CFLOCATION URL = "Allocation_Layout.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
	</CFIF>	
</CFIF>

<!---
<CFIF IsThereFundAllocation EQ 0>
	<CFLOCATION URL = "Allocation_Layout.cfm" ADDTOKEN="No"> 
<CFELSE>
	<CFLOCATION URL = "Display_Fund_Allocation.cfm?Billback_ID=#Billback_ID#" ADDTOKEN="No">
</CFIF>
---->
<script>
	if(window.parent.payment_tab)
	{
		window.parent.current_menu_item = "payment";
		window.parent.assignActiveTab();
		window.parent.buildMenu();
	}
</script>
</body>
</html>
