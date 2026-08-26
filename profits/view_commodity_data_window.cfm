<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>xxxxxxxxxxxxxxxxxxxxxxxxx</TITLE>
</HEAD>
<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- header goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFINCLUDE TEMPLATE="view_commodity_queries.cfm">


<TABLE BGCOLOR="Silver" CELLPADDING="2" CELLSPACING="1">
	<CFOUTPUT QUERY="Get_Commodity_Data">
	<TR BGCOLOR="#IIf(Get_Commodity_Data.CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#">
		<TD BGCOLOR="White" WIDTH="65">#dateformat(Comm_Datetime, 'm/d/yyyy')#</TD>
		<TD BGCOLOR="White" WIDTH="65">#numberformat(Comm_Last, '_.____')#</TD>
		<TD BGCOLOR="White" WIDTH="65"><CFIF Comm_Previous NEQ "">#numberformat(Comm_Previous, '_.____')#</CFIF></TD>
		<TD BGCOLOR="White" WIDTH="60" ALIGN="right"><CFIF Comm_Last NEQ "" AND Comm_Previous NEQ "">#numberformat(evaluate(Comm_Last-Comm_Previous), '+_.____')#</CFIF></TD>
	</TR>
	</CFOUTPUT>
</TABLE>
	

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- footer goes here																				 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>



		

		