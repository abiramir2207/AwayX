<!---import the custom tag lib--->
<cfimport prefix="layout" taglib="/CustomTags"> 

<TABLE width="60%" border="0" cellpadding="1" cellspacing="0">
	<TR>
		<CFIF qGetCompRebates.recordCount GT 0>
			<TD ALIGN="left" WIDTH="130" nowrap>
			<CFIF form.display eq "inActive">
			<B><FONT COLOR="FF0000">[</FONT><a HREF="#" onClick="javaScript: return activateSelComps();">
			activate selected</a>
			<CFELSE>
			<B><FONT COLOR="FF0000">[</FONT><a HREF="" onClick="javaScript: return deactivateSelComps();">
			deactivate selected</a>
			</b></b></CFIF><B><B>
			<FONT COLOR="FF0000">]</FONT></B>
			</b></TD>
		</CFIF>
		<TD WIDTH="">&nbsp;</TD>
	</TR>
</TABLE>
<br>
<TABLE width="60%" BORDER="0" CELLPADDING="1" CELLSPACING="0" CLASS="MAINTABLE">
	<!---- HEAD ----->
	<TR ID="HEADER" BGCOLOR="#FFCE84">
		<TD width="10">
			<INPUT TYPE="checkbox" NAME="CheckAll" onClick="javaScript: selectAll(this);">
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Name</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Reference</b>
		</TD>
		<TD STYLE="font-size:11px;">
			<b>Use to calculate TPA?</b>
		</td>
		<TD STYLE="font-size:11px;" align="left"><B>Allow Billbacks&nbsp; </B></TD>
		<td>&nbsp;</td>
		
		<TD WIDTH="65" STYLE="font-size:11px;"><B>
		<cfif form.display eq "active">
			DeActivate
		<cfelse>
			Activate
		</cfif>&nbsp;</B></TD>
		<TD WIDTH="50" STYLE="font-size:11px;"><B>Delete</B></TD>
	</TR>
	
	<CFOUTPUT QUERY="qGetCompRebates">
		<!---check to see if we can delete this component--->
		<cfscript>
			bCanDelete = compRebate.canDelete(qGetCompRebates.Accounting_Program_Type_ID);
		</cfscript>
	
	<TR <CFIF CURRENTROW MOD 2>BGCOLOR="CCFFCC"</CFIF> HEIGHT="21">
		<TD width="10"><INPUT TYPE="checkbox" NAME="CID" value="#Accounting_Program_Type_ID#"></TD>
		<TD>
			#APT_Name#&nbsp; 
		</TD>
		<TD>
			#APT_Reference_Number# &nbsp; 
		</TD>
	
		<TD>
			<cfif APT_Use_For_TPA IS 1> Yes <cfelse> No </cfif>								
		</TD>
		<!--- Dev Note: KAL; 8665: Dont allow BB if flagged --->
		<TD ALIGN="left"><cfif APT_Allow_Billbacks IS 1>Yes<cfelse>No</cfif>&nbsp;</TD>
			
		<TD>
			<a href="" onClick="JavaScript: return submitDataForm('edit','#Accounting_Program_Type_ID#');">Edit &nbsp;</a>
		</TD>
		
		
		<CFIF form.display EQ "active">
			<TD TITLE="Deactivate #APT_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deactivateComp('#Accounting_Program_Type_ID#');"><img src="/images/not_allowed.gif" TITLE="Deactivate #APT_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD TITLE="Activate #APT_Name#" ALIGN="center"><a href="" onClick="JavaScript: return activateComp('#Accounting_Program_Type_ID#');"><img src="/images/on_the_program_item.gif" TITLE="Activate #APT_Name#" BORDER="0"></a></TD>
		</CFIF>	
				
		<CFIF bCanDelete >
			<TD TITLE="Delete #APT_Name#" ALIGN="center"><a href="" onClick="JavaScript: return deleteComp('#Accounting_Program_Type_ID#');"><img src="/images/no_small.gif" TITLE="Delete #APT_Name#" BORDER="0"></a></TD>
		<CFELSE>
			<TD ALIGN="center">&nbsp;<FONT COLOR="Red">N/A</FONT></TD>
		</CFIF>	
	</TR>	
	</CFOUTPUT>
</TABLE>

