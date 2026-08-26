<cfparam name="qGetBusSegments.Business_Unit_ID" default="" />
<cfparam name="qGetBusSegments.Business_Unit_Desc" default="" />
<cfparam name="qGetBusSegments.Company_Code_ID" default="" />
<!---77265 :: Segment Settings Page - add new fields :: START--->
<cfparam name="qGetBusSegments.BS_Var_1" default="" />
<cfparam name="qGetBusSegments.BS_Var_2" default="" />
<cfparam name="qGetBusSegments.BS_Var_3" default="" />
<cfparam name="qGetBusSegments.BS_Var_4" default="" />
<cfparam name="qGetBusSegments.BS_Var_5" default="" />
<cfparam name="qGetBusSegments.BS_Var_6" default="" />
<!---77265 :: Segment Settings Page - add new fields :: END--->
<cfoutput>
<FIELDSET STYLE="padding:10px; width: 600px; border: 1px solid Blue;">
	<LEGEND STYLE="font: bold 14px sans-serif; color: Red;">#appSettings.getbusiness_segment_label()# Information</LEGEND>
	<table>
		<TR>
			<TD ALIGN="right"><B>Business Unit ID:</B></TD>
			<TD>
				<span id="Err_Sp_Unit_ID"></span>
				<INPUT NAME="Business_Unit_ID" TYPE="text" value="#HTMLEditFormat(trim(qGetBusSegments.Business_Unit_ID))#" SIZE="30" MAXLENGTH="25">
			</TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Business Unit Description:</B></TD>
			<TD><span id="Err_Sp_Desc"></span><INPUT NAME="Business_Unit_Desc" TYPE="text" VALUE="#HTMLEditFormat(trim(qGetBusSegments.Business_Unit_Desc))#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>
		<TR>
			<TD ALIGN="right"><B>Company Code:</B></TD>
			<TD><INPUT NAME="Company_Code_ID" TYPE="text" VALUE="#trim(qGetBusSegments.Company_Code_ID)#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>	
	<!---77265 :: Segment Settings Page - add new fields :: START--->
		<TR>
			<TD ALIGN="right"><B>Variable 1:</B></TD>
			<TD><INPUT NAME="Variable_1" TYPE="text" VALUE="#trim(qGetBusSegments.BS_Var_1)#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>	
				<TR>
			<TD ALIGN="right"><B>Variable 2:</B></TD>
			<TD><INPUT NAME="Variable_2" TYPE="text" VALUE="#trim(qGetBusSegments.BS_Var_2)#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>	
				<TR>
			<TD ALIGN="right"><B>Variable 3:</B></TD>
			<TD><INPUT NAME="Variable_3" TYPE="text" VALUE="#trim(qGetBusSegments.BS_Var_3)#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>	
				<TR>
			<TD ALIGN="right"><B>Variable 4:</B></TD>
			<TD><INPUT NAME="Variable_4" TYPE="text" VALUE="#trim(qGetBusSegments.BS_Var_4)#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>	
				<TR>
			<TD ALIGN="right"><B>Variable 5:</B></TD>
			<TD><INPUT NAME="Variable_5" TYPE="text" VALUE="#trim(qGetBusSegments.BS_Var_5)#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>	
				<TR>
			<TD ALIGN="right"><B>Variable 6:</B></TD>
			<TD><INPUT NAME="Variable_6" TYPE="text" VALUE="#trim(qGetBusSegments.BS_Var_6)#" SIZE="30" MAXLENGTH="25"></TD>
		</TR>	
<!---77265 :: Segment Settings Page - add new fields :: END--->
		<TR>
			<TD COLSPAN="100%" ALIGN="center">
			<CF_smallLink 
				title = "save" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('sBusinessSegment','#form.id#');"""
			>
			<CF_smallLink 
				title = "cancel" 
				url = "##"
				parameters = "onClick=""javascript: return submitForm('cancel');"""
			>
			</TD>
		</TR>
	</table>
</FIELDSET>
<cf_MessageWindow />
</cfoutput>