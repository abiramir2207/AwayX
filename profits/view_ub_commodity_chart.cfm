<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">
<HTML>
<HEAD>
	<TITLE>Commodity Pricing</TITLE>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="5" TOPMARGIN="5">

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_ub_commodity_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<BR><BR><BR><BR><BR><BR>

<CFOUTPUT QUERY="Get_UB_Data">
	<TABLE border="0" cellspacing="10" cellpadding="0" ALIGN="center">
		<TR>
			<TD nowrap align="right"><B>Commodity Description</B></TD>
			<TD bgcolor="EE9C00" rowspan="7" nowrap><IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="1" BORDER="0" ALT=""></TD>
			<TD nowrap><B>#UB_Symbol_Description#</B></TD>
		</TR>
		<TR>
			<TD nowrap align="right"><B>Category Code:</B></TD>
			<TD nowrap>#UB_Category_Code#</TD>
		</TR>
		<TR>
			<TD nowrap align="right"><B>Category Code Description:</B></TD>
			<TD nowrap>#UB_Category_Description#</TD>
		</TR>
		<TR>
			<TD nowrap align="right"><B>Unit of Measurement:</B></TD>
			<TD nowrap>#UB_UOM#</TD>
		</TR>
		<TR>
			<TD nowrap align="right"><B>Close Price:</B></TD>
			<TD nowrap>#numberformat(Close_Price, '.000')#</TD>
		</TR>
		<TR>
			<TD nowrap align="right"><B>Close Date:</B></TD>
			<TD nowrap>#dateformat(Close_Date, 'm/d/yyy')#</TD>
		</TR>
		<TR>
			<TD nowrap align="right"></TD>
			<TD nowrap></TD>
		</TR>
	</TABLE>
</CFOUTPUT>

<BR><BR><BR><BR><BR><BR><BR><BR><BR><BR><BR>



<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="view_commodity_footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->

</BODY>
</HTML>
