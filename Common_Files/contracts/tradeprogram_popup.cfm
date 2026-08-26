<CFQUERY NAME="GetTradePrograms" datasource="#application.datasource#">
	SELECT *
	FROM Trade_Programs
</CFQUERY>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title>Trade Program Selection</title>
</head>

<body>

<style>
	body, table, td
		{font-family: Arial; font-size: 12px;}
	.data
		{font-size: 12px; font-weight: bold}
	select, TEXTAREA
		{width:	200px;font-size: 10px;}
	TEXTAREA
		{width:	400px;font-size: 10px;}

	TABLE.Maintable TD 
		{border-bottom:solid #93BEE2 1px; font-size : 10px;}
	
	Maintable
		{cellspacing: 0;}
	
	header 
		{font-size: 12px;}
</style>

<FORM ACTION="tradeprogram_popup_action.cfm" METHOD="post" NAME="MyForm" ID="MyForm">
<TABLE WIDTH="100%" BORDER="0" CELLSPACING="0" CELLPADDING="0">
	<TR>
		<TD>
			<TABLE CELLSPACING="0" CELLPADDING="2" ALIGN="left" CLASS="Maintable" WIDTH="100%">
				<TR BGCOLOR="FFCE84">
					<TD>&nbsp;</TD>
					<TD STYLE="font-weight: bold; font-size:12px;">Trade #</TD>
					<TD STYLE="font-weight: bold; font-size:12px;">Trade Program</TD>
				</TR>
			
				<TR BGCOLOR="C6FFC6">
					<TD><input NAME="tradeidlist" <CFIF listfind(URL.TRADEPROGRAMLIST,"all") NEQ 0>CHECKED</CFIF> VALUE="all" type="checkbox"></TD>
					<TD>&nbsp;</TD>
					<TD>ALL Programs</TD>
				</TR>
			<CFOUTPUT QUERY="GetTradePrograms">
				<TR BGCOLOR="#IIf(CurrentRow Mod 2, DE('ffffff'), DE('C6FFC6'))#" VALIGN="top">
					<TD><input NAME="tradeidlist" <CFIF listfind(URL.TRADEPROGRAMLIST,GetTradePrograms.trade_program_ID) NEQ 0>CHECKED</CFIF> VALUE="#GetTradePrograms.trade_program_ID#" type="checkbox"></TD>
					<TD>#GetTradePrograms.trade_offer_number#</TD>
					<TD>#GetTradePrograms.trade_program_name#</TD>
				</TR>
			</CFOUTPUT>
			</TABLE>
		</TD>
	</TR>

	<TR>
		<TD>
			<BR>
			
				<CF_button
					button_name		=	""
					button_caption	=	"save"
					button_action	=	"javascript: document.all.MyForm.submit();"
					button_type		=	"link"
					button_width	=	"100"
					button_color	=	"Navy"
					button_tip		=	""
					font_color		=	"White"
					font_size		=	"12"
					font_weight		=	"bold"
				>
			<!--- <INPUT TYPE="submit" VALUE="save programs"> --->
		</TD>
	</TR>
	
</TABLE>

</form>

</body>
</html>
