
<CFSET PAGE_TITLE=	"Tutorials">
<CFSET GROUP=		"Tutorials">

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">

<!--- <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx ---> --->

<TABLE CELLSPACING="5" CELLPADDING="0" ALIGN="center" valign="center">
	<TR NOWRAP>
		<TD>
		<strong>Tutorial Files:</strong>
		<ul>
			<li><a href="shockwave/Auto_Program/Auto_Program_6_viewlet_swf.html">Auto Program</a></li>
			<li><a href="shockwave/chain_operator/Chain_Operator_Program_viewlet_swf.html">Chain <cfoutput>#application.returned_customer_setting.operator_label_singular#</cfoutput> Program</a></li>
			<li><a href="shockwave/distributor_program/Dist_ST_Program_viewlet_swf.html"><cfoutput>#application.returned_customer_setting.distributor_label_singular#</cfoutput> Program</a></li>
			<li><a href="shockwave/fees_program/Fees_Program_viewlet_swf.html">Fees Program</a></li>
			<li><a href="shockwave/growth_program/Growth_Program_viewlet_swf.html">Growth Program</a></li>
			<li><a href="shockwave/marketing_program/Marketing_Program_viewlet_swf.html">Marketing Program</a></li>
			<li><a href="shockwave/off_invoice_program/Off_Invoice_Program_viewlet_swf.html">Off Invoice Program</a></li>
			<li><a href="shockwave/samples_program/Samples_Program_viewlet_swf.html">Samples Program</a></li>
			<li><a href="shockwave/search_programs/Search_Programs_viewlet_swf.html">Search Programs</a></li>
		</ul>
		
			
		</TD>
	</TR>
</table>

</BODY>
</HTML>
