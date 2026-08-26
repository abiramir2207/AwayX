<cfoutput>
<TABLE width="70%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<TD>
			Component: <b>#qGetCompRebate.Program_Rebates_Component_Name#</b>
			<hr color="navy">
		Check which rule you want to apply to <b>#qGetCompRebate.Program_Rebates_Component_Name#</b>, 
		then click <B><FONT COLOR="FF0000">[</FONT><font color="##0000FF"> apply rule </font><FONT COLOR="FF0000">]</FONT> . 
		<p>
		</TD>
	</TR>
	<tr>
		<TD nowrap>
			<B><FONT COLOR="FF0000">[</FONT>
			<a HREF="##" onClick="javaScript: return applyRules('#form.compId#');">
				apply rule
			</a>
			<FONT COLOR="FF0000">]</FONT>
			</B>
			&nbsp;&nbsp;
			<select name="required">
				<option value="0">Optional</option>
				<option value="1" <cfif qGetCompRebate.Rule_Required eq 1>selected</cfif>>Required</option>
			</select>
		</TD>
	</tr>
</TABLE>
</cfoutput>
<TABLE width="70%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD STYLE="font-size:11px;">
			&nbsp;
			<!--- <INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this, 'rule_ids');"> --->
		</TD>
		<TD STYLE="font-size:11px;" width="100%" nowrap>
			<b>Business Rule</b>
		</TD>
	</TR>
	<CFOUTPUT QUERY="qGetCompRules">
	
		<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF>>
			<TD>
				<!--- <INPUT NAME="rule_ids" TYPE="checkbox" value="#Program_Rebates_Component_Rule_ID#" <cfif Len(trim(Joined_Rule_Id))>checked</cfif>> --->
				<INPUT NAME="rule_ids" TYPE="radio" value="#Program_Rebates_Component_Rule_ID#" <cfif Len(trim(Joined_Rule_Id))>checked</cfif>>
			</td>
			<TD STYLE="font-size:11px;" width="100%" nowrap>
				#Rebates_Component_Rule_Desc#
			</TD>	
		</TR>
		
	</CFOUTPUT>
</TABLE>