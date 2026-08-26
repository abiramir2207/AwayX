

<!--- 
	Dev Note: Ana; D17928: UpdateRecalc link so takes the user to a page to change AR 
	"Recalculate Allocation" Link will be used to manually override the AR automation methodology. 
	So when user clicks this link we will be showing the AR selection dropdown just like the older way perior to D17664.	
 --->

<!--- 
	Dev Note: KAL; D17664: Heinz AR auto assignment methodology
	Removed the code in here and moved to a stored procedure.
	This page now runs the procedure will selects the matching AR and updates the table and returns the value for variable RecalcFund which is used in the redirect.
 --->
<CFPARAM NAME="FORM.Submitted" DEFAULT="">
 
<CFIF NOT IsDefined("URL.Recal_Fund") AND FORM.Submitted NEQ 1>
	<CFSET RecalcFund = 0>

	<cfstoredproc procedure="BB_Auto_AR_Selection" datasource="#Application.Datasource#">
		<cfprocparam cfsqltype="cf_sql_idstamp" type="in" value="#Billback_ID#"   />
		<cfprocparam cfsqltype="cf_sql_integer" type="out" variable="RecalcFund" />
	</cfstoredproc>
					
	<CFIF RecalcFund EQ 1>
		<CFSET Recal_Fund = 1>
	</CFIF>

	<CFSET URLString = "Billback_ID=#Billback_ID#&FromARSelection=1">
	<CFIF IsDefined("Deduction_ID")>
		<CFSET URLString = "#URLString#&Deduction_ID=#Deduction_ID#">
	</CFIF>
	<CFIF IsDefined("Recal_Fund") OR RecalcFund EQ 1>
		<CFSET URLString = "#URLString#&Recal_Fund=#Recal_Fund#"> 
	</CFIF>

	<CFLOCATION URL="Allocation.cfm?#URLString#" ADDTOKEN="No">
<CFELSE>
	<!--- D17928: UpdateRecalc link so takes the user to a page to change AR  --->
	<SCRIPT LANGUAGE="JavaScript" SRC="/Script/javascript/dhtml.js"></SCRIPT>
	
	<!--- <CFPARAM NAME="FORM.Submitted" DEFAULT=""> --->

	<CFIF FORM.Submitted EQ 1>
		<CFSET RecalcFund = 0>
		<CFLOOP LIST="#FORM.BB_Program_ID#" INDEX="ItemID">		
			<CFSET ReplacedProgID = REPLACE(ItemID,"-","_","All")>
			<CFSET Sel_AR_Value = EVALUATE("FORM.AR_For_#ReplacedProgID#")>
			<CFSET Template_ID = EVALUATE("FORM.Template_ID_#ReplacedProgID#")>
			<CFSET A_R_Fiscal_Year = LEFT(Sel_AR_Value,4)>
			<CFSET FormARlength = len(Sel_AR_Value)>
			<CFSET right_Len = FormARlength - 5>
			<CFSET A_R_Number = RIGHT(Sel_AR_Value,right_Len)>	
			
			<cfset useLakebaseForGetAllocation = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("gl_code_ar_for_progtemp")>
<cfif useLakebaseForGetAllocation>
	<cftry>
		<cfset GetAllocation = application.oLakebase.toQuery(
			application.oLakebase.selectRows("gl_code_ar_for_progtemp", {
				"template_id" = "eq.#Template_ID#",
				"fiscal_year" = "eq.#A_R_Fiscal_Year#",
				"a_r" = "eq.#A_R_Number#",
				"deleted" = "eq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForGetAllocation = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForGetAllocation>
<CFQUERY NAME="GetAllocation" DATASOURCE="#Application.Datasource#">
				SELECT 	* 
				FROM 	GL_Code_AR_For_ProgTemp 
				WHERE 	Template_ID = '#Template_ID#' AND 
						Fiscal_Year = '#A_R_Fiscal_Year#' AND 
						A_R = '#A_R_Number#' AND 
						Deleted = 0	
			</CFQUERY>
</cfif>
			
			<CFSET Final_Allocation_Method = GetAllocation.Allocation_Method>
				
			<cfset useLakebaseForCheckForLumpsum = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("bb_lump_sums")>
<cfif useLakebaseForCheckForLumpsum>
	<cftry>
		<cfset CheckForLumpsum = application.oLakebase.toQuery(
			application.oLakebase.selectRows("bb_lump_sums", {
				"billback_id" = "eq.#Billback_ID#",
				"billback_program_id" = "eq.#ItemID#",
				"ls_paid_amount" = "neq.0"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckForLumpsum = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckForLumpsum>
<CFQUERY NAME="CheckForLumpsum" DATASOURCE="#Application.Datasource#">
				SELECT * FROM BB_Lump_Sums 
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Billback_Program_ID = '#ItemID#' AND 
						LS_Paid_Amount <> 0
			</CFQUERY>
</cfif>
			
			<cfset useLakebaseForCheckAnyClaimedProduct = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_product")>
<cfif useLakebaseForCheckAnyClaimedProduct>
	<cftry>
		<cfset CheckAnyClaimedProduct = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_product", {
				"billback_id" = "eq.#Billback_ID#",
				"billback_program_id" = "eq.#ItemID#",
				"deleted" = "eq.0",
				"limit" = "1"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForCheckAnyClaimedProduct = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForCheckAnyClaimedProduct>
<CFQUERY NAME="CheckAnyClaimedProduct" DATASOURCE="#Application.Datasource#">
				SELECT 	Top 1 * FROM Billback_Product 
				WHERE 	Billback_ID = '#Billback_ID#' AND 
						Billback_Program_ID = '#ItemID#' AND 
						Deleted = 0
			</CFQUERY>
</cfif>
	
			<CFQUERY NAME="UpdateProg" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Program
				SET 	A_R 				= '#A_R_Number#',
						AR_From_Fiscal_Year = '#A_R_Fiscal_Year#',
						<CFIF Final_Allocation_Method NEQ 3 AND CheckForLumpsum.RecordCount GT 0>
						LumpSum_Amt			= #CheckForLumpsum.LS_Paid_Amount#,
						LumpSum_Only		= <CFIF CheckAnyClaimedProduct.RecordCount EQ 0>1<CFELSE>0</CFIF>,
						<CFELSE>
						LumpSum_Amt			=	NULL,
						LumpSum_Only		=	0,
						</CFIF>
						Allocation_Method 	= #Final_Allocation_Method#
						
				WHERE 	Billback_Program_ID = '#ItemID#' AND Deleted = 0
			</CFQUERY>
			
			<CFIF Final_Allocation_Method NEQ 3 AND CheckForLumpsum.RecordCount GT 0>
				<CFSET RecalcFund = 1>
			</CFIF>
			<!--- 
			<CFIF CheckForLumpsum.RecordCount GT 0 AND RecalcFund EQ 0>
				<CFQUERY NAME="CheckTemplateType" DATASOURCE="#Application.Datasource#">
					SELECT 		* 
					FROM 		Billback_Program
					INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
					INNER JOIN 	Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
					--INNER JOIN	Program_Lump_Sums ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID AND Program_Lump_Sums.Deleted = 0
					WHERE 		Billback_Program_ID = '#ItemID#' AND
								Program_Control_Panel_Options.Generic_Type LIKE 'Operator-Deviated Pricing'
				</CFQUERY>
				
				<CFIF CheckTemplateType.RecordCount GT 0 OR (CheckAnyClaimedProduct.RecordCount EQ 0 AND GetAllocation.Allocation_Method EQ 1)>
					<CFSET Final_Allocation_Method = 3>			
					<CFQUERY NAME="CheckAlreadySaved" DATASOURCE="#Application.Datasource#">
						SELECT 	* FROM Billback_Program
						WHERE 	A_R = '#A_R_Number#' AND
								AR_From_Fiscal_Year = '#A_R_Fiscal_Year#' AND
								Allocation_Method = 3 AND 
								Billback_Program_ID = '#ItemID#' AND 
								Deleted = 0
					</CFQUERY>
					<CFIF CheckAlreadySaved.RecordCount EQ 0>
						<CFSET RecalcFund = 1>
					</CFIF>			
				</CFIF>
			</CFIF>
			 --->
			
			
			<!--- 
			<CFIF CheckAnyClaimedProduct.RecordCount EQ 0>
				<CFSET Final_Allocation_Method = 3>		
				<CFQUERY NAME="CheckAlreadySaved" DATASOURCE="#Application.Datasource#">
					SELECT 	* FROM Billback_Program
					WHERE 	A_R = '#A_R_Number#' AND
							AR_From_Fiscal_Year = '#A_R_Fiscal_Year#' AND
							Allocation_Method = 3 AND 
							Billback_Program_ID = '#ItemID#' AND 
							Deleted = 0
				</CFQUERY>
				<CFIF CheckAlreadySaved.RecordCount EQ 0>
					<CFSET RecalcFund = 1>
				</CFIF>
			<CFELSE>
				<CFIF CheckForLumpsum.RecordCount GT 0 AND RecalcFund EQ 0>
					<CFQUERY NAME="CheckTemplateType" DATASOURCE="#Application.Datasource#">
						SELECT 		* 
						FROM 		Billback_Program
						INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
						INNER JOIN 	Program_Control_Panel_Options ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
						--INNER JOIN	Program_Lump_Sums ON Program_Lump_Sums.Program_ID = Contract_Main.Contract_Main_ID AND Program_Lump_Sums.Deleted = 0
						WHERE 		Billback_Program_ID = '#ItemID#' AND
									Program_Control_Panel_Options.Generic_Type LIKE 'Operator-Deviated Pricing'
					</CFQUERY>
					<CFIF CheckTemplateType.RecordCount GT 0>
						<CFSET Final_Allocation_Method = 3>			
						<CFQUERY NAME="CheckAlreadySaved" DATASOURCE="#Application.Datasource#">
							SELECT 	* FROM Billback_Program
							WHERE 	A_R = '#A_R_Number#' AND
									AR_From_Fiscal_Year = '#A_R_Fiscal_Year#' AND
									Allocation_Method = 3 AND 
									Billback_Program_ID = '#ItemID#' AND 
									Deleted = 0
						</CFQUERY>
						<CFIF CheckAlreadySaved.RecordCount EQ 0>
							<CFSET RecalcFund = 1>
						</CFIF>
					</CFIF>
				</CFIF> 
			</CFIF>
			 --->
			
			<!--- 
			<CFQUERY NAME="UpdateProg" DATASOURCE="#Application.Datasource#">
				UPDATE 	Billback_Program
				SET 	A_R = '#A_R_Number#',
						AR_From_Fiscal_Year = '#A_R_Fiscal_Year#',
						Allocation_Method = #Final_Allocation_Method#
						
				WHERE 	Billback_Program_ID = '#ItemID#' AND Deleted = 0
			</CFQUERY>
			 --->
		</CFLOOP>
	
		<CFIF RecalcFund EQ 1>
			<CFSET Recal_Fund = 1>
		</CFIF>
	
		<CFSET URLString = "Billback_ID=#Billback_ID#&FromARSelection=1">
		<CFIF IsDefined("Deduction_ID")>
			<CFSET URLString = "#URLString#&Deduction_ID=#Deduction_ID#">
		</CFIF>
		<CFIF IsDefined("Recal_Fund") OR RecalcFund EQ 1>
			<CFSET URLString = "#URLString#&Recal_Fund=#Recal_Fund#"> 
		</CFIF>
	
		<CFLOCATION URL="Allocation.cfm?#URLString#" ADDTOKEN="No">
		
	<CFELSE>
		<CFQUERY NAME="GetEligibleAR" DATASOURCE="#Application.Datasource#">
			SELECT 		DISTINCT 	Program_Latest_Template_ID.Latest Template_ID,
									Billback_Program.Billback_Program_ID,
									Contract_Main.Contract_Number,
									Contract_Main.Contract_Title
			
			FROM 		Billback_Program 
			INNER JOIN 	Contract_Main ON Contract_Main.Contract_Main_ID = Billback_Program.Program_ID
			INNER JOIN 	Program_Latest_Template_ID ON Program_Latest_Template_ID.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID	
			WHERE 		Billback_ID = '#Billback_ID#' AND Billback_Program.Deleted = 0
			ORDER BY 	Contract_Number
		</CFQUERY>
		<CFSET BB_Program_ID_List = VALUELIST(GetEligibleAR.Billback_Program_ID)>
		
		<!--- <CFDUMP VAR="#GetEligibleAR#"> --->
		<BR><BR>
		<FORM NAME="AR_Sel" ACTION="AR_Selection.cfm" METHOD="Post">
		<CFOUTPUT>
		<INPUT TYPE="Hidden" NAME="Submitted" VALUE="0">
		<INPUT TYPE="Hidden" NAME="Billback_ID" VALUE="#Billback_ID#">
		<INPUT TYPE="Hidden" NAME="BB_Program_ID" VALUE="#BB_Program_ID_List#">
		<CFIF IsDefined("Deduction_ID")>
			<INPUT TYPE="Hidden" NAME="Deduction_ID" VALUE="#Deduction_ID#">
		</CFIF>
		<CFIF IsDefined("Recal_Fund")>
			<INPUT TYPE="Hidden" NAME="Recal_Fund" VALUE="#Recal_Fund#">
		</CFIF>
		</CFOUTPUT>
			<TABLE BORDER="0" CELLPADDING="5" CELLSPACING="0" ALIGN="Center">
				<TR BGCOLOR="FFE083">
					<TD><B>Program</B></TD>
					<TD><B>Select A/R</B></TD>
				</TR>
				<CFLOOP QUERY="GetEligibleAR">
					<CFSET ReplacedBBProgramID = "">
					<CFSET ReplacedBBProgramID = REPLACE(Billback_Program_ID,"-","_","All")>
					<CFQUERY NAME="GetActiveAR" DATASOURCE="#Application.Datasource#">
						SELECT 		DISTINCT GL_Code_AR_For_ProgTemp.A_R, 
									GL_Code_AR_For_ProgTemp.Fiscal_Year,
									A_R_Description
									
						FROM 		GL_Code_AR_For_ProgTemp 
						INNER JOIN 	GL_Code_Activation ON GL_Code_Activation.Fiscal_Year = GL_Code_AR_For_ProgTemp.Fiscal_Year AND 
									GL_Code_Activation.A_R = GL_Code_AR_For_ProgTemp.A_R AND
									GL_Code_Activation.Current_Active_Data = 1 AND 
									GL_Code_Activation.Deleted = 0
									
						WHERE 		Template_ID = #Template_ID# AND GL_Code_AR_For_ProgTemp.Deleted = 0
						ORDER BY	GL_Code_AR_For_ProgTemp.Fiscal_Year,GL_Code_AR_For_ProgTemp.A_R
					</CFQUERY>
					
					<cfset useLakebaseForAlreadySelAR = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback_program")>
<cfif useLakebaseForAlreadySelAR>
	<cftry>
		<cfset AlreadySelAR = application.oLakebase.toQuery(
			application.oLakebase.selectRows("billback_program", {
				"billback_program_id" = "eq.#Billback_Program_ID#"
			})
		)>
		<cfcatch type="any">
			<cfset useLakebaseForAlreadySelAR = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForAlreadySelAR>
<CFQUERY NAME="AlreadySelAR" DATASOURCE="#Application.Datasource#">
						SELECT * FROM Billback_Program WHERE Billback_Program_ID = '#Billback_Program_ID#'
					</CFQUERY>
</cfif>
					
					<CFSET AlreadySelectedAR = "">
					<CFIF AlreadySelAR.A_R NEQ "">
						<CFSET AlreadySelectedAR = "#AlreadySelAR.AR_From_Fiscal_Year#_#AlreadySelAR.A_R#">
					</CFIF>
					<CFOUTPUT><INPUT TYPE="Hidden" NAME="Template_ID_#ReplacedBBProgramID#" VALUE="#Template_ID#"></CFOUTPUT>
					<TR <CFOUTPUT>BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#"</CFOUTPUT>>
						<TD><CFOUTPUT><B>#Contract_Number#</B> - #Contract_Title#</CFOUTPUT></TD>
						<TD>
							<CFOUTPUT><SELECT NAME="AR_For_#ReplacedBBProgramID#"></CFOUTPUT>
								<OPTION VALUE=""></OPTION>
								<CFOUTPUT QUERY="GetActiveAR">
									<CFSET Option_Value = "#Fiscal_Year#_#A_R#">
									<OPTION VALUE="#Fiscal_Year#_#A_R#" <CFIF Option_Value EQ AlreadySelectedAR>SELECTED</CFIF>>#Fiscal_Year# - #A_R_Description# (#A_R#)</OPTION>
								</CFOUTPUT>
							</SELECT>
						</TD>
					</TR>
				</CFLOOP>
				<TR>
					<TD COLSPAN="100%" ALIGN="Center"><BR>
						<CF_button
							button_name	=	"save_ar"
							button_caption	=	"save A/R selection"
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
	
	
		<SCRIPT language="JavaScript">
		function validate()
		{
			var BB_Prog_List = "<CFOUTPUT>#REPLACE(BB_Program_ID_List,"-","_","All")#</CFOUTPUT>"
			var ThisArVar,progWithoutAR;
			var BBProgListArr = new Array();
			BBProgListArr = BB_Prog_List.split(",");	
			for (i=0; i<BBProgListArr.length; i++)
			{
				ThisArVar = eval("document.all.AR_For_"+BBProgListArr[i]+".value");
				if (ThisArVar == "")
				{
					progWithoutAR = 1;
					break;
				}		
			}
			if (progWithoutAR == 1)
			{
				alert("Please select an AR for listed program(s).")
			}
			else
			{
				document.all.Submitted.value=1;
				document.AR_Sel.submit()
				disableButton("save_ar_table", true, false);
			}
		}
		</SCRIPT>
	</CFIF>

</CFIF> 	