<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Untitled</title>
</head>

<body>

<CFPARAM NAME="URL.BBID" DEFAULT="">

<CFPARAM NAME="FORM.SubmitForm" DEFAULT="">
<CFPARAM NAME="FORM.BBID" DEFAULT="#URL.BBID#">

<CFSET InfoBar_BBID = FORM.BBID>
<cfinclude template="/billbacks/capture/billback_load_infobar.cfm">


<CFIF FORM.SubmitForm EQ "">
	<CFQUERY NAME="CheckFixed" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 *
		FROM 	Billback_Product_Detail 
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
				BB_Product_Type_ID = 1 AND
				CAST(BB_Rate AS Float) > 0 AND
				Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="CheckRebate" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 *
		FROM 	Billback_Product_Detail 
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
				BB_Product_Type_ID = 2 AND
				CAST(BB_Rate AS Float) > 0 AND
				Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="CheckLumpSum" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 *
		FROM 	Billback_Program_Lumpsum_Component
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
				Component_Type_ID = 1 AND
				CAST(Amount As Float) > 0 AND
				Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="CheckGrowth" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 *
		FROM 	Billback_Product_Detail 
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
				BB_Product_Type_ID = 4 AND
				CAST(BB_Rate AS Float) > 0 AND
				Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="CheckFormula" DATASOURCE="#Application.Datasource#">
		SELECT 	Top 1 *
		FROM 	Billback_Product_Detail 
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
				BB_Product_Type_ID = 5 AND
				CAST(BB_Rate AS Float) > 0 AND
				Deleted = 0
	</CFQUERY>
	
	<BR><BR><BR><BR>
	
		
	
	<FIELDSET STYLE="padding:8px; width: 400px; border: 1px solid Blue;" ALIGN="Center">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;"></LEGEND>
	<FORM NAME="DiscountTypeSel" ACTION="Select_DiscountType.cfm" METHOD="POST">
	
	<CFOUTPUT>
	<INPUT TYPE="Hidden" NAME="BBID" VALUE="#FORM.BBID#">
	<INPUT TYPE="Hidden" NAME="SubmitForm" VALUE="1">
	</CFOUTPUT>
	<CFSET IsAnyDiscountTypeAvailable = 0>
	<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">	
		<TR>
			<TD COLSPAN="3" NOWRAP><FONT COLOR="Red" SIZE="2"><B>Select Discount Types to be Part of this Billback:</B></FONT></TD>
		</TR>
		<TR>
			<TD COLSPAN="3"><BR></TD>
		</TR>
		<CFIF CheckFixed.RecordCount GT 0>
			<CFSET IsAnyDiscountTypeAvailable = 1>
			<TR>
				<TD WIDTH="100">&nbsp;</TD>
				<TD><INPUT TYPE="CheckBox" NAME="Discount_Fixed" VALUE="1">&nbsp;&nbsp;<FONT SIZE="3"><B>Fixed</B></FONT></TD>				
				<TD WIDTH="20">&nbsp;</TD>
			</TR>
		</CFIF>
		
		<CFIF CheckRebate.RecordCount GT 0>
		<CFSET IsAnyDiscountTypeAvailable = 1>
		<TR>
			<TD>&nbsp;</TD>
			<TD><INPUT TYPE="CheckBox" NAME="Discount_Rebate" VALUE="1">&nbsp;&nbsp;<FONT SIZE="3"><B>Rebate</B></FONT></TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFIF>
		
		<CFIF CheckLumpSum.RecordCount GT 0>
		<CFSET IsAnyDiscountTypeAvailable = 1>
		<TR>
			<TD>&nbsp;</TD>
			<TD><INPUT TYPE="CheckBox" NAME="Discount_LumpSum" VALUE="1">&nbsp;&nbsp;<FONT SIZE="3"><B>Lump Sum</B></FONT></TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFIF>
		
		<CFIF CheckGrowth.RecordCount GT 0>
		<CFSET IsAnyDiscountTypeAvailable = 1>
		<TR>
			<TD>&nbsp;</TD>
			<TD><INPUT TYPE="CheckBox" NAME="Discount_Growth" VALUE="1">&nbsp;&nbsp;<FONT SIZE="3"><B>Growth</B></FONT></TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFIF>
		
		<CFIF CheckFormula.RecordCount GT 0>
		<CFSET IsAnyDiscountTypeAvailable = 1>
		<TR>
			<TD>&nbsp;</TD>
			<TD><INPUT TYPE="CheckBox" NAME="Discount_Formula" VALUE="1">&nbsp;&nbsp;<FONT SIZE="3"><B>Formula</B></FONT></TD>
			<TD>&nbsp;</TD>
		</TR>
		</CFIF>
		
		<CFIF IsAnyDiscountTypeAvailable EQ 1>
		<TR>
			<TD COLSPAN="3" ALIGN="Center"><BR><BR>
				<CF_button
					button_name		=	""
					button_caption	=	"save data"
					button_action	=	"Validate()"
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
		<CFELSE>
			<CFQUERY NAME="UpdateBB" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback
				
				SET 	BB_Amount = '0'						
				
				WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
						Deleted = 0
			</CFQUERY>

			<CFLOCATION URL="/billbacks/capture/billback_summary.cfm?BBID=#FORM.BBID#" ADDTOKEN="No">
		</CFIF>
	</TABLE>
	</FORM>
	</FIELDSET>
<CFELSE>
	<CFSET SelectedDiscountList = 0>
	<CFSET IsLumpsumSelected = 0>
	
	<CFIF IsDefined("FORM.Discount_Fixed")>
		<CFSET SelectedDiscountList = "#SelectedDiscountList#,1">
	</CFIF> 
	
	<CFIF IsDefined("FORM.Discount_Rebate")>
		<CFSET SelectedDiscountList = "#SelectedDiscountList#,2">
	</CFIF>
	
	<CFIF IsDefined("FORM.Discount_LumpSum")>
		<CFSET IsLumpsumSelected = 1>
	</CFIF>
	
	<CFIF IsDefined("FORM.Discount_Growth")>
		<CFSET SelectedDiscountList = "#SelectedDiscountList#,4">		
	</CFIF>
	
	<CFIF IsDefined("FORM.Discount_Formula")>
		<CFSET SelectedDiscountList = "#SelectedDiscountList#,5">
	</CFIF>
	
	
	<CFQUERY NAME="DeleteUnSelected" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product_Detail
		
		SET 	Deleted = 1
		
		WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND
				BB_Product_Type_ID NOT IN (#SelectedDiscountList#) AND
				Deleted = 0
	</CFQUERY>
	
	<CFIF IsLumpsumSelected EQ 0>
		<CFQUERY NAME="DeleteLumpsum" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Program_Lumpsum_Component
			
			SET 	Deleted = 1
			
			WHERE	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND
					Deleted = 0
		</CFQUERY>
		
	<CFELSEIF IsLumpsumSelected EQ 1 AND Not IsDefined("FORM.Discount_Growth")>
		<CFQUERY NAME="DeleteGrowthLumpSum" DATASOURCE="#Application.Datasource#">
			UPDATE 	Billback_Program_Lumpsum_Component
			
			SET		Deleted = 1
			
			WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND
					Component_Type_ID = 3 AND
					Deleted = 0
		</CFQUERY>
		
	</CFIF>
	
	
	

<!--- Calculate Billback Amount --->
<CFQUERY NAME="ProductType1245" DATASOURCE="#Application.Datasource#">
	SELECT 	SUM(CAST(BB_Rate AS Float)) AS TotOf1245
	
	FROM  	Billback_Product_Detail
	
	WHERE   Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
			Deleted = 0
</CFQUERY>


	
<CFQUERY NAME="LumpSumAmount" DATASOURCE="#Application.Datasource#">
	SELECT  SUM(CAST(Amount AS Float)) TotOf3
	
	FROM 	Billback_Program_Lumpsum_Component
	
	WHERE   Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
			Deleted = 0
</CFQUERY>

<CFSET BB_Amount = 0>
<CFIF ProductType1245.RecordCount GT 0 AND ProductType1245.TotOf1245 NEQ "">
	<CFSET BB_Amount = ProductType1245.TotOf1245>
</CFIF>

<CFIF LumpSumAmount.RecordCount GT 0 AND LumpSumAmount.TotOf3 NEQ "">
	<CFSET BB_Amount = BB_Amount + LumpSumAmount.TotOf3>
</CFIF>

<!--- Update Billback Amount --->
<CFQUERY NAME="UpdateBB" DATASOURCE="#Application.Datasource#">
	UPDATE 	Billback
	
	SET 	BB_Amount = <cfqueryparam value="#BB_Amount#" cfsqltype="CF_SQL_FLOAT">
	
	WHERE 	Billback_ID = <cfqueryparam value="#FORM.BBID#" cfsqltype="CF_SQL_VARCHAR"> AND 
			Deleted = 0
</CFQUERY>


<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- Product Hierarchy Details --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<CFSET Billback_ID = FORM.BBID>
<CFQUERY NAME="getGroupLevelBB" DATASOURCE="#Application.Datasource#">
	SELECT 		aaa.GroupLevelBB
	
	FROM 		Billback_Program 
	INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
	INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
	INNER JOIN 	Program_Control_Panel_Options aaa ON aaa.ProgramControl_Panel_Options_ID = Program_Latest_Template_ID.Latest
	WHERE 		Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR"> AND Billback_Program.Deleted = 0	
</CFQUERY>

<CFIF getGroupLevelBB.GroupLevelBB EQ 1>
	<CFQUERY NAME="SetPHBB" DATASOURCE="#Application.Datasource#">
		UPDATE Billback_Program
		SET Display_Product_Hierarchy = 1
		WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND Deleted = 0
	</CFQUERY>
	<CFQUERY NAME="UpdateDeleted" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product
		SET 	Deleted = 1
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND 
				Deleted = 0 AND
				Billback_Product_ID NOT IN ( 	SELECT DISTINCT Billback_Product_ID 
												FROM Billback_Product_Detail 
												WHERE Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND Deleted = 0 
											)
	</CFQUERY>
	<CFQUERY NAME="GetHierarchy" DATASOURCE="#Application.Datasource#">
		UPDATE 	Billback_Product
		SET 	Product_Hierarchy_ID = (SELECT Product_Hierarchy_ID FROM BSA_Foodservice_Items_Master WHERE BSA_Foodservice_Items_Master_ID = Product_ID)
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND Billback_Product.Deleted = 0
	</CFQUERY>
	
	<CFQUERY NAME="GetDistinctPG" DATASOURCE="#Application.Datasource#">
		SELECT 	DISTINCT Product_Hierarchy_ID
		FROM 	Billback_Product 
		WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND Deleted = 0
	</CFQUERY>
	
	<CFLOOP QUERY="GetDistinctPG">
		<CFIF Product_Hierarchy_ID NEQ "">
			<CFQUERY NAME="Updatevolume" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Product
				SET 	Product_Hierarchy_Volume = (	SELECT 	SUM(Cast(BB_product_Quantity AS FLoat)) 
														FROM 	Billback_Product 
														WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND 
																Deleted = 0 AND 
																Product_Hierarchy_ID = '#Product_Hierarchy_ID#'	)
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND 
						Deleted = 0 AND 
						Product_Hierarchy_ID = <cfqueryparam value="#Product_Hierarchy_ID#" cfsqltype="CF_SQL_VARCHAR">
			</CFQUERY>
			
			<CFQUERY NAME="UpdatePHRate" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Product_Detail
				SET 	Product_Hierarchy_Rate = (	SELECT  SUM(CAST(BB_Rate AS Float)) 
													FROM 	Billback_Product_Detail
													WHERE 	Deleted = 0 AND 
															Billback_Product_ID IN (	SELECT 	Billback_Product_ID 
																						FROM 	Billback_Product 
																						WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND 
																								Deleted = 0 AND 
																								Product_Hierarchy_ID = '#Product_Hierarchy_ID#'
																					) 
													)
				WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND 
						Deleted = 0 AND 
						Billback_Product_ID IN (	SELECT 	Billback_Product_ID 
													FROM 	Billback_Product 
													WHERE 	Billback_ID = <cfqueryparam value="#Billback_ID#" cfsqltype="CF_SQL_VARCHAR">' AND 
															Deleted = 0 AND 
															Product_Hierarchy_ID = <cfqueryparam value="#Product_Hierarchy_ID#" cfsqltype="CF_SQL_VARCHAR">
												)
			</CFQUERY>
		</CFIF>
	</CFLOOP>
</CFIF>
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->
<!--- End Product Hierarchy Details --->
<!--- vvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvvv --->

	
<cfset local_bbid = FORM.BBID>
<cfinclude template="/billbacks/capture/bb_menu_stats.cfm">

<script>
if(window.parent.payee_program_tab)
{
	window.parent.current_menu_item = "payee_program";
	window.parent.assignActiveTab();
	window.parent.buildMenu();
}
</script>
	

<CFLOCATION URL="/billbacks/capture/billback_summary.cfm?BBID=#FORM.BBID#" ADDTOKEN="No">

	

</CFIF>

<SCRIPT language="JavaScript">
function Validate()
{
	var x = document.DiscountTypeSel;
	var IsSelectedAny = 0;
	if (x.Discount_Fixed)
	{
		if (x.Discount_Fixed.checked)
		{
			IsSelectedAny = 1;		
		}
	}
	if (x.Discount_Rebate)
	{
		if (x.Discount_Rebate.checked)
		{
			IsSelectedAny = 1;	
		}
	}
	if (x.Discount_LumpSum)
	{
		if (x.Discount_LumpSum.checked)
		{
			IsSelectedAny = 1;	
		}
	}
	if (x.Discount_Growth)
	{
		if (x.Discount_Growth.checked)
		{
			IsSelectedAny = 1;	
		}
	}
	if (x.Discount_Formula)
	{
		if (x.Discount_Formula.checked)
		{
			IsSelectedAny = 1;	
		}
	}
	if(IsSelectedAny == 1)
	{
		document.all.SubmitForm.value=1;		
		document.DiscountTypeSel.submit()
	}
	else
	{
		alert("Please select at least a discount type and try again.")
	}
}
</SCRIPT>
</body>
</html>
