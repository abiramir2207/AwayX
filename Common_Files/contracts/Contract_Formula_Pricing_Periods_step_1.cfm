<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

<CFSET PAGE_TITLE="Formula pricing Period : Step 1">
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.0 Transitional//EN">

<HTML>
<HEAD>
	<TITLE><CFOUTPUT>#PAGE_TITLE#</CFOUTPUT></TITLE>
	<LINK REL="STYLESHEET" TYPE="text/css" HREF="/common_files/main_style.css">

	<script SRC="/script/javascript/string_functions.js">
		<!--- <cfinclude TEMPLATE="/script/javascript/string_functions.js"> --->
	</script>
</HEAD>

<BODY BGCOLOR="White" TEXT="Black" LINK="Blue" VLINK="Blue" ALINK="Red" LEFTMARGIN="0" TOPMARGIN="0">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/top_header.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->


<CFIF len(URL.CID) EQ 0><CFSET temp = 0><CFELSE><CFSEt temp = cryp.value></CFIF>
<CFSET CSL_Contract_Main_ID = temp>
<CFSET CSL_CallingPageCode = "formula">

<cfif application.programlayout EQ 1>
<div id="Layer2" style="position:absolute; width: 180px; height: 400px; z-index: 1; left: 10px; top: 0px">
  <CFINCLUDE TEMPLATE="contract_status_legend.cfm"></div>
<cfelse>
<CFINCLUDE TEMPLATE="contract_status_legend.cfm">
</cfif>
<BLOCKQUOTE><BLOCKQUOTE>
<cfif application.programlayout EQ 1>
<div id="Layer1" style="position:relative; height:430px; width:200px; z-index:1; left: 80px; top: 10px;"></cfif>
<CFSET URL.Contract_Main_ID = cryp.value>
<CFSET FORM.Contract_Main_ID = cryp.value>

<cfinclude template="minimal_contract_info.cfm">

<BR>

<script>
	function submitForm(){
		if(document.all.Number_Of_Periods.value.length == 0 || parseInt(document.all.Number_Of_Periods.value) == 0){
			//alert("Please supply the number of periods.")
			alert("Invalid value for the number of periods.")
		}
		else{
			document.all.MyForm.submit();
		}
	}
</script>

<FORM ACTION="Contract_Formula_Pricing_Periods_step_2.cfm?CID=<CFOUTPUT>#URL.CID#</CFOUTPUT>" METHOD="post" NAME="MyForm" ID="MyForm">
<table ALIGN="left" BORDER="0" WIDTH="800">
	<TR>
		<TD STYLE="font-weight:bold;" ALIGN="center">How many periods are there?&nbsp;<input TYPE="text" NAME="Number_Of_Periods" SIZE="1" MAXLENGTH="3" ONKEYUP="clenseText(this, '0123456789');"></TD>
	</TR>
	<TR>
		<TD COLSPAN="100%" ALIGN="center"><BR>
		<CF_button
			button_name		=	""
			button_caption	=	"continue"
			button_action	=	"submitForm();"
			button_type		=	"javascript_link"
			button_width	=	"75"
			button_color	=	"Navy"
			button_tip		=	""
			font_color		=	"White"
			font_size		=	"12"
			font_weight		=	"bold"
		>
		</TD>
	</TR>
</table>


</FORM>
<cfif application.programlayout EQ 1></div></cfif>

<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
<CFINCLUDE TEMPLATE="/includes/footer.cfm">
<!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
</BLOCKQUOTE></BLOCKQUOTE>

</BODY>
</HTML>
