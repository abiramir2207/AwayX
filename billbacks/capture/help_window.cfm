<CFSET PAGE_TITLE="Create Payable">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<div align="center"><img src="/images/BB_Program_Help_Image.jpg" alt="" border="0"></div>
<hr color="orange">
	<div style="color: red; font-weight:bold;" align="center">NOTE:  No changes are permanently saved until pushing the save button at the bottom of the page.</div>
<hr color="orange">

<style>
	.label {
		color: blue;
		font-weight: bold;
		font-size: 12px;
	}
	
	.info {
		color: navy;
		font-size: 12px;	
	}
	

</style>

<table align="center">
	<TR>
		<TD class="label" valign="top" align="right">1.</TD>
		<TD rowspan="100%"><img src="/images/fill.gif" width="1"></TD>
		<TD class="info">Click on this image to add internal programs with a relationship to the billback Payee</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">2.</TD>
		<TD class="info">Click on this image to add a system program to the billback.</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">3.</TD>
		<TD class="info">Click on this image to add create a psuedo program with a limited amount of program information.</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">4.</TD>
		<TD>
			<TABLE>
				<TR>
					<TD class="info">Click on this image to expand the floating Information Summary window:</TD>
				</TR>
				<TR>
					<TD><img src="/images/floating_summary_image.gif"></TD>
				</TR>
				<TR>
					<TD class="info">
						This window displays a real-time sum of the pounds, cases, rates on the billback
					</TD>
				</TR>
			</TABLE>
		</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">5.</TD>
		<TD class="info">Program Status Icon followed by the Internal program number</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">6.</TD>
		<TD class="info">Program description, date span of program, and program quantity</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">7.</TD>
		<TD class="info">Click this image to add products on the program</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">8.</TD>
		<TD class="info">Click this image to add products NOT on the program</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">9.</TD>
		<TD class="info">Click this image to add a psuedo poduct with a limited amount of product information</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">10.</TD>
		<TD class="info">Click this image to remove the program and its products from the billback</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">11.</TD>
		<TD class="info">Product description</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">12.</TD>
		<TD class="info">Volume amount from the billback</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">13.</TD>
		<TD class="info">Unit of measure of the billback volume</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">14.</TD>
		<TD class="info">Input box for entering the total billback amount for the product of the rate type labeled above it. <BR>When red the indicated rate type is NOT on the program or the listed product is not part of the rate type.</TD>
	</TR>
	<TR>
		<TD class="label" valign="top" align="right">15.</TD>
		<TD class="info">Input box for entering the total billback amount for the product of the rate type labeled above it. <BR>When green the indicated rate type is on the program.</TD>
	</TR>
</table>
<hr color="orange">

<div align="center" onclick="window.close()" style="cursor:pointer;color:blue;font-size:13px;">close this window</div>
<BR>

</BODY>
</HTML>