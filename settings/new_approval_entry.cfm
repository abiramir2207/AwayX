<script>
	function assignTypeCodesToGroup(oTD){
		if(oTD.GROUP_ID != null){
			NewWindow("type_code_to_group_assignment.cfm?group_id="+oTD.GROUP_ID, "typecodegroup", 800, 600, "yes", "yes")
		}
	//type_code_to_group_assignment.cfm
	}
</script>

<CFLOOP INDEX="GroupCount" FROM="1" TO="5" STEP="1">
	<CFLOOP INDEX="ProfileCount" FROM="1" TO="6" STEP="1">
		<CFQUERY NAME="getApprovalMargin" datasource="#application.datasource#">
			SELECT Amount
			FROM Margin_Group_Profile_Approval_Margins
			WHERE Group_ID='#GroupCount#' AND Profile_ID='#ProfileCount#'
		</CFQUERY>
		<CFSET "FORM.Group_#GroupCount#_Profile_#ProfileCount#" = getApprovalMargin.Amount>
	</CFLOOP>
</CFLOOP>

<CFOUTPUT>
<FORM ACTION="new_Approval_entry_Action.cfm" METHOD="post">
<table>
	<TR>
		<TD>&nbsp;</TD>
		<TD>Broker</TD>
		<TD>FS1</TD>
		<TD>FS2</TD>
		<TD>HQ1</TD>
		<TD>HQ2</TD>
		<TD>HQ3</TD>
	</TR>
	<TR>
		<TD STYLE="cursor:pointer;" GROUP_ID="1" ONCLICK="assignTypeCodesToGroup(this)">Group I</TD>
		<TD><input TYPE="text" NAME="Group_1_Profile_1" SIZE="5" VALUE="#FORM.Group_1_Profile_1#"></TD>
		<TD><input TYPE="text" NAME="Group_1_Profile_2" SIZE="5" VALUE="#FORM.Group_1_Profile_2#"></TD>
		<TD><input TYPE="text" NAME="Group_1_Profile_3" SIZE="5" VALUE="#FORM.Group_1_Profile_3#"></TD>
		<TD><input TYPE="text" NAME="Group_1_Profile_4" SIZE="5" VALUE="#FORM.Group_1_Profile_4#"></TD>
		<TD><input TYPE="text" NAME="Group_1_Profile_5" SIZE="5" VALUE="#FORM.Group_1_Profile_5#"></TD>
		<TD><input TYPE="text" NAME="Group_1_Profile_6" SIZE="5" VALUE="#FORM.Group_1_Profile_6#"></TD>
	</TR>
	<TR>
		<TD STYLE="cursor:pointer;" GROUP_ID="2" ONCLICK="assignTypeCodesToGroup(this)">Group II</TD>
		<TD><input TYPE="text" NAME="Group_2_Profile_1" SIZE="5" VALUE="#FORM.Group_2_Profile_1#"></TD>
		<TD><input TYPE="text" NAME="Group_2_Profile_2" SIZE="5" VALUE="#FORM.Group_2_Profile_2#"></TD>
		<TD><input TYPE="text" NAME="Group_2_Profile_3" SIZE="5" VALUE="#FORM.Group_2_Profile_3#"></TD>
		<TD><input TYPE="text" NAME="Group_2_Profile_4" SIZE="5" VALUE="#FORM.Group_2_Profile_4#"></TD>
		<TD><input TYPE="text" NAME="Group_2_Profile_5" SIZE="5" VALUE="#FORM.Group_2_Profile_5#"></TD>
		<TD><input TYPE="text" NAME="Group_2_Profile_6" SIZE="5" VALUE="#FORM.Group_2_Profile_6#"></TD>
	</TR>
	<TR>
		<TD STYLE="cursor:pointer;" GROUP_ID="3" ONCLICK="assignTypeCodesToGroup(this)">Group III</TD>
		<TD><input TYPE="text" NAME="Group_3_Profile_1" SIZE="5" VALUE="#FORM.Group_3_Profile_1#"></TD>
		<TD><input TYPE="text" NAME="Group_3_Profile_2" SIZE="5" VALUE="#FORM.Group_3_Profile_2#"></TD>
		<TD><input TYPE="text" NAME="Group_3_Profile_3" SIZE="5" VALUE="#FORM.Group_3_Profile_3#"></TD>
		<TD><input TYPE="text" NAME="Group_3_Profile_4" SIZE="5" VALUE="#FORM.Group_3_Profile_4#"></TD>
		<TD><input TYPE="text" NAME="Group_3_Profile_5" SIZE="5" VALUE="#FORM.Group_3_Profile_5#"></TD>
		<TD><input TYPE="text" NAME="Group_3_Profile_6" SIZE="5" VALUE="#FORM.Group_3_Profile_6#"></TD>
	</TR>
	<TR>
		<TD STYLE="cursor:pointer;" GROUP_ID="4" ONCLICK="assignTypeCodesToGroup(this)">Group IV</TD>
		<TD><input TYPE="text" NAME="Group_4_Profile_1" SIZE="5" VALUE="#FORM.Group_4_Profile_1#"></TD>
		<TD><input TYPE="text" NAME="Group_4_Profile_2" SIZE="5" VALUE="#FORM.Group_4_Profile_2#"></TD>
		<TD><input TYPE="text" NAME="Group_4_Profile_3" SIZE="5" VALUE="#FORM.Group_4_Profile_3#"></TD>
		<TD><input TYPE="text" NAME="Group_4_Profile_4" SIZE="5" VALUE="#FORM.Group_4_Profile_4#"></TD>
		<TD><input TYPE="text" NAME="Group_4_Profile_5" SIZE="5" VALUE="#FORM.Group_4_Profile_5#"></TD>
		<TD><input TYPE="text" NAME="Group_4_Profile_6" SIZE="5" VALUE="#FORM.Group_4_Profile_6#"></TD>
	</TR>
	<TR>
		<TD STYLE="cursor:pointer;" GROUP_ID="5" ONCLICK="assignTypeCodesToGroup(this)">Group V</TD>
		<TD><input TYPE="text" NAME="Group_5_Profile_1" SIZE="5" VALUE="#FORM.Group_5_Profile_1#"></TD>
		<TD><input TYPE="text" NAME="Group_5_Profile_2" SIZE="5" VALUE="#FORM.Group_5_Profile_2#"></TD>
		<TD><input TYPE="text" NAME="Group_5_Profile_3" SIZE="5" VALUE="#FORM.Group_5_Profile_3#"></TD>
		<TD><input TYPE="text" NAME="Group_5_Profile_4" SIZE="5" VALUE="#FORM.Group_5_Profile_4#"></TD>
		<TD><input TYPE="text" NAME="Group_5_Profile_5" SIZE="5" VALUE="#FORM.Group_5_Profile_5#"></TD>
		<TD><input TYPE="text" NAME="Group_5_Profile_6" SIZE="5" VALUE="#FORM.Group_5_Profile_6#"></TD>
	</TR>
</table>
<input TYPE="submit">
</FORM></CFOUTPUT>