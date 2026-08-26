<cfinclude template="/get_access_profile.cfm">

<!---Finds out if the program is PNF or UP--->
<cfquery name="UPorPNF" datasource="#application.datasource#">
SELECT BB_UP, BB_PNF
FROM Billback
WHERE Billback_ID = '#Billback_ID#'
</cfquery>

<!-------------- Show Buttons ------------->

<CFIF NOT isDefined("Billback_Amount_Match")>
	<CFQUERY  dataSource="#application.datasource#" NAME="Billback_Amount_Match">
		SELECT	 CONVERT(Char(10),Billback.Deviation_Ran_Date,101) Deviation_Ran_Date, Billback.Deviation_Ran_By,_Users.Name_First + ' '+ _Users.Name_Last Ran_By,
		Billback.BB_Amount - 
		-----------------Total Amount claimed for this program
		(IsNUll((SELECT	SUM(CAST(Billback_Product_Detail.BB_Rate AS FLOAT))
		FROM	Billback_Program
			INNER JOIN	Billback_Product
			ON
			(  (Billback_Product.Billback_ID = '#Billback_ID#') 
				AND
				(Billback_Product.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				(Billback_Product.Deleted = 0)
			)
			INNER JOIN	Billback_Product_Detail
			ON
			(	Billback_Product_Detail.Billback_ID = '#Billback_ID#' 
				AND
				(Billback_Product_Detail.Billback_Product_ID = Billback_Product.Billback_Product_ID)
				AND
				(Billback_Product_Detail.Deleted = 0)
				AND
				(Billback_Product_Detail.BB_Rate IS NOT NULL)
				AND
				(LEN(Billback_Product_Detail.BB_Rate) > 0)
				AND
				(ISNUMERIC(Billback_Product_Detail.BB_Rate) = 1)
				AND
				(CAST(Billback_Product_Detail.BB_Rate AS Float) > 0)
			)
		WHERE
		Billback_Program.Billback_ID = Billback.Billback_ID
		AND
		Billback_Program.Deleted = 0
		), 0)  + 
		IsNull((SELECT	SUM(CAST(Billback_Program_Lumpsum_Component.Amount AS FLOAT))
		FROM	Billback_Program
			INNER JOIN	 Billback_Program_Lumpsum_Component
			ON
			(
				(Billback_Program_Lumpsum_Component.Billback_Program_ID = Billback_Program.Billback_Program_ID)
				AND
				( Billback_Program_Lumpsum_Component.Deleted = 0)
			)
		WHERE
			Billback_Program.Billback_ID = Billback.Billback_ID
			AND
			Billback_Program.Deleted = 0
		), 0)
		) AS BB_Dollar_Amount_Mismatch
		-----------------Total Amount claimed for this program
		FROM	Billback
		LEFT JOIN _Users ON _Users.User_ID = Billback.Deviation_Ran_By
		WHERE	
			Billback.Billback_ID = '#Billback_ID#'
			AND
			Billback.Deleted = 0
	</CFQUERY>
</CFIF>
	
<CFIF BB_Status LT 3>
	<TABLE ALIGN="CENTER" WIDTH="80%">
	<CFIF Billback_Amount_Match.recordCount GT 0>
		<CFIF Billback_Amount_Match.BB_Dollar_Amount_Mismatch NEQ 0>
		<TR ALIGN="CENTER">
			<TD COLSPAN="100%">
			<CFOUTPUT>
			<B><FONT COLOR="Red">
			Billback Amount is <CFIF Billback_Amount_Match.BB_Dollar_Amount_Mismatch LT 0>less<CFELSE>greater</CFIF>
			 than calculated Billback amount by #NumberFormat(Abs(Billback_Amount_Match.BB_Dollar_Amount_Mismatch), "(_.__)")#
			<BR>You can approve a Billback only if it matches. 
			</FONT></B>
			</CFOUTPUT>
			</TD>
		</TR>
		</CFIF>
	</CFIF>	
	<CFIF THIS_STEP_LEVEL_IN_LIST LT MAX_LEVEL>
	<TR ALIGN="CENTER">
		<TD COLSPAN="100%">
		<CFOUTPUT>
		<B>Next Step: Validate #ListGetAt(VALIDATION_STEPS_DESC, Evaluate("#THIS_STEP_LEVEL_IN_LIST#+1"), ",")#</B>
		</CFOUTPUT>
		</TD>
	</TR>
	</CFIF>
	<TR ALIGN="CENTER">	
	<TD WIDTH="50%">
	<CFIF THIS_STEP_LEVEL_IN_LIST GT 1>
	<CF_button
				button_name		=	""
				button_caption	=	"<&nbsp;Previous&nbsp;Step"
				button_action	=	"window.location.href='View_Deviation.cfm?BBID=#Billback_ID#&STEP_LEVEL=#ListGetAt(VALIDATION_STEPS, Evaluate("#THIS_STEP_LEVEL_IN_LIST#-1"), ",")#'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"< Previous Step"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
	</CFIF>
	</TD>	
	<CFIF THIS_STEP_LEVEL_IN_LIST LT MAX_LEVEL>
	<TD WIDTH="50%">
	<CF_button
				button_name		=	""
				button_caption	=	"Next&nbsp;Step&nbsp;>"
				button_action	=	"window.location.href='View_Deviation.cfm?BBID=#Billback_ID#&STEP_LEVEL=#ListGetAt(VALIDATION_STEPS, Evaluate("#THIS_STEP_LEVEL_IN_LIST#+1"), ",")#'"
				button_type		=	"javascript_link"
				button_width	=	"50"
				button_color	=	"Navy"
				button_tip		=	"Next Step >"
				font_color		=	"White"
				font_size		=	"12"
				font_weight		=	"bold"
			>
	</TD>
	</CFIF>
	<!--- temporary code for approval--->
	<CFIF THIS_STEP_LEVEL_IN_LIST GT 1 AND THIS_STEP_LEVEL_IN_LIST EQ MAX_LEVEL AND BB_Status LT 3>
	
		<CFIF Billback_Amount_Match.recordCount GT 0>
			<CFIF Billback_Amount_Match.BB_Dollar_Amount_Mismatch EQ 0>
			<!---If user can approve the billback--->
			<cfif Get_Profile_Settings.BB_Approve GT 0>
			<cfif (UPorPNF.BB_UP IS 0 OR UPorPNF.BB_PNF IS 0) AND (Get_Profile_Settings.BB_Approve_Critical) GT 0>
			
			<TD WIDTH="50%">
				<!----button_action	=	"document.ApprovalForm.submit();"----->
				<CF_button
							button_name		=	""
							button_caption	=	"Approve&nbsp;Billback"							
							button_action	=	"/Billbacks/Approval/populate_table.cfm?BBID=#Billback_ID#"
							button_type		=	"link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	"Approve&nbsp;Billback"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>			
			</TD>
			<CFELSE>
				<TD WIDTH="50%">
				<CF_button
							button_name		=	""
							button_caption	=	"Edit Billback"
							button_action	=	"/billbacks/capture/basic_information_form.cfm?BBID=#Billback_ID#"
							button_type		=	"link"
							button_width	=	"100"
							button_color	=	"Navy"
							button_tip		=	"Edit Billback"
							font_color		=	"White"
							font_size		=	"12"
							font_weight		=	"bold"
						>	
				</TD>
			</CFIF>
			
			<!---User can approve the billback--->
			<cfelse>
			<TD WIDTH="50%"></TD>
			</cfif>
			</cfif>
		<CFELSE>
			<TD WIDTH="50%"></TD>
		</CFIF>
	
	</CFIF>
	</TR>
	</TABLE>

</CFIF>