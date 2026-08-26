<HTML>

<HEAD>
<TITLE>xxxxxxxxxxxxxxxx</TITLE>
</HEAD>

<BODY>


<style>
	TABLE.Maintable TD	{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	#header {font-size: 12px;}
</style>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Table options																					 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSET tableborder=0>
<CFSET bgcolor="Silver">
<CFSET tablewidth="550">
<CFSET cellpadding=3>
<CFSET cellspacing=0>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<!--- Open layer Options																			 --->
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFSCRIPT>
	Layerborder="Yes";
	BorderSize=1;  
	BorderColor="orange";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy"; 
	TitleFont="Arial";
	TitleSize=9;
	IsClosed="Yes";  
	Width=600;
</CFSCRIPT>


<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="GENERAL TYPES"  
	TitleClosed="GENERAL TYPES"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Operator Deviated Pricing</TD>
			<TD><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Distributor <cfoutput>#application.returned_customer_setting.Trade_Label#</cfoutput>/Shelter</TD>
			<TD><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Operator Direct or HQ</TD>
			<TD><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Field Execution</TD>
			<TD><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="BASICS"  
	TitleClosed="BASICS"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center" nowrap><B>Yes</B></TD>
			<TD align="center" nowrap><B>Entry</B></TD>
			<TD align="center" nowrap><B>UOM</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Duration Maximum</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap><INPUT type="text" name="T1" size="9"></TD>
			<TD nowrap>Months</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Duration Minimum</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap><INPUT type="text" name="T1" size="9"></TD>
			<TD nowrap>Months</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global Volume Maximum</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap><INPUT type="text" name="T1" size="9"></TD>
			<TD nowrap><INPUT type="radio" value="V1" checked name="R1">LBS&nbsp;&nbsp;&nbsp;
				<INPUT type="radio" value="V1" checked name="R1">CS</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global Volume Minimum</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap><INPUT type="text" name="T1" size="9"></TD>
			<TD nowrap><INPUT type="radio" value="V1" checked name="R1">LBS&nbsp;&nbsp;&nbsp;
				<INPUT type="radio" value="V1" checked name="R1">CS</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Allow Retroactive</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap><INPUT type="text" name="T1" size="9"></TD>
			<TD nowrap>Max duration</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Advanced Spending</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap><INPUT type="text" name="T1" size="9"></TD>
			<TD nowrap>Total $</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Growth Inclusion Flags</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Renewal Option</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rates -- By Category</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Rates -- By SKU/UPC</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Allow Advance Spending</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Controllable Flag</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global GL Assignment</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Program-specific GL</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Volume by SKU/UPC</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Volume - Min by SKU/UPC</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify <cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput>(s)</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Specify <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput>(s)</TD>
			<TD align="center" nowrap><INPUT type="radio" value="V1" checked name="R1"></TD>
			<TD align="center" nowrap>&nbsp;</TD>
			<TD nowrap>&nbsp;</TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="RATE TYPES"  
	TitleClosed="RATE TYPES"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Per pound</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Per case</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Per gallon</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Per liter</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Per case count (splits)</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">% of Gross Revenue</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">% of Revenue Net Discount</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">% Net of Common Programs</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="DISCOUNT TYPES"  
	TitleClosed="DISCOUNT TYPES"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> - Straight</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> - Step-wise</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.RebateLabel#</CFOUTPUT> - Retro</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Fixed Price</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> - Open</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> - Timed</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><CFOUTPUT>#Application.LumpsumLabel#</CFOUTPUT> - Growth</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Delivered Price</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">FOB Price</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Show both Del and FOB</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="CLAIM MECHANICS"  
	TitleClosed="CLAIM MECHANICS"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Off-Invoice</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Billback Request</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Payment</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Credit</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Build-up Invoice</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="EXCLUSION OPTIONS"  
	TitleClosed="EXCLUSION OPTIONS"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Global program adjustments</TD>
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Adjust by product/program</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Deduct Trade from Fixed</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Pullback from Trade</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Auto Deduct Notice</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="COMMUNICATION"  
	TitleClosed="COMMUNICATION"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Sales</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Brokers</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> - HQ</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> - Local</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="PAYMENT CYCLE"  
	TitleClosed="PAYMENT CYCLE"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Daily</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Weekly</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Monthly</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Quarterly</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Annual</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Use Fiscal Calendar</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<BR>
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CF_openLayer
	border="#layerborder#"
	BorderSize="#BorderSize#"  
	BorderColor="#BorderColor#"  
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="CLAIM / PERFORMANCE REQUIREMENTS"  
	TitleClosed="CLAIM / PERFORMANCE REQUIREMENTS"  
	TitleTooltip="Click here to toggle the view..."  
	TitleColor="#TitleColor#"  
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	width="#tablewidth#">
<BLOCKQUOTE>
	<CFOUTPUT><TABLE CLASS="Maintable" border="#tableborder#" bgcolor="#bgcolor#" width="#tablewidth#" CELLPADDING="#CELLPADDING#" CELLSPACING="#CELLSPACING#"></CFOUTPUT>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">&nbsp;</TD>
			<TD align="center"><B>Required</B></TD>
			<TD align="center"><B>Default</B></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Invoice / Billback</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Claim Period</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Items #'s w/Qty &amp; rates</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Total $'s and pounds</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Menu listing</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Branded Point of Sale</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Mandated Specification</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Optional Specification</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
		<TR BGCOLOR="White">
			<TD nowrap width="100%">Feature Sheet / Flyer</TD>
			<TD align="center"><INPUT type="checkbox" name="C1" value="ON"></TD>
			<TD align="center"><INPUT type="radio" value="V1" checked name="R1"></TD>
		</TR>
	</TABLE>
</BLOCKQUOTE>
</CF_openLayer>


</BODY>

</HTML>





