<CFPARAM NAME="invoicenumber"				DEFAULT="">
<CFPARAM NAME="invoicedate"					DEFAULT="">
<CFPARAM NAME="defaultdate"					DEFAULT="">
<CFPARAM NAME="datetype"					DEFAULT="">
<CFPARAM NAME="InvoiceDate_Operator" 		DEFAULT=">=">
<cfparam name="checked_history_period" 		default="">
<cfparam NAME="FORM.history_period" 		DEFAULT="fiscal_period,fiscal_quarter,fiscal_year">

<cfset defaultdate =  DateFormat(now(), "mm/dd/yyyy")>
<SCRIPT language="JavaScript" src="invoiceCommon.js"></SCRIPT>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaScript">
	<cfwddx action = "CFML2JS" input = "#defaultdate#" topLevelVariable = "defaultdate_js" >
	//document.body.onload=new Function ("disable_Comparsion_Operators()");
	function disable_Comparsion_Operators()
	{
		GTE_Operator(1,document.all.invoicedate_operator);
		//GTE_Operator(2,document.all.Date_Operator);
		//GTE_Operator(3,document.all.Start_Date_Operator);
		//GTE_Operator(4,document.all.End_Date_Operator);
		//document.all.BB_Date.style.fontSize=10;
		//document.all.Start_Date.style.fontSize=10;
		//document.all.End_Date.style.fontSize=10;
	}
	function GTE_Operator(Op_Type,thisObj)
	{
		var spName;
		if(Op_Type == 1)
		{
			spName = "INV_DATE";
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}
</SCRIPT>

<cfif invoicedate IS "">
	<cfset invoicedate = defaultdate>
</cfif>
<!---  --->
<cfoutput>
<!--- blue --->
<!--- Gainsboro --->
<!--- DarkGray --->
<FIELDSET STYLE="padding:10px; border: 5px outset LightGrey;" >
    <LEGEND STYLE="font: bold 12px arial; color: Red; background-color: ##FFFFCC;">Date Span Criteria</LEGEND>
		<TABLE border="0" cellspacing="0" cellpadding="10" STYLE="background-color: ##F5FFFA;" ALIGN="center">
			<TR>
				<td>
					<SPAN ID="INV_DATE">
						<CF_EASYDATE FORMNAME="MyInvoiceForm" FIELDNAME="invoicedate" FORMAT="mm/dd/yyyy" default="#invoicedate#"> 
					</SPAN>
				</td>
				<td NOWRAP>
					<Input TYPE="Checkbox" ID="history_period" NAME="history_period" VALUE="fiscal_period" <cfif ListFind(FORM.history_period, "fiscal_period", ",") GT 0 > CHECKED </cfif> readonly="true" onclick="javascript:this.checked = true;"> <B>Fiscal Period</B>
				</td>
				<td NOWRAP >
					<Input TYPE="Checkbox" ID="history_period" NAME="history_period" VALUE="fiscal_quarter" <cfif ListFind(FORM.history_period, "fiscal_quarter", ",") GT 0 > CHECKED </cfif> > <B>Fiscal Quarter</B>
				</td>
				<td NOWRAP>
					<Input TYPE="Checkbox" ID="history_period" NAME="history_period" VALUE="fiscal_year" <cfif ListFind(FORM.history_period, "fiscal_year", ",") GT 0 > CHECKED </cfif> > <B>Fiscal Year</B>
				</td>
				<TD>
					<IMG SRC="/images/fill.gif" WIDTH="1" HEIGHT="10">
					<B><FONT COLOR="##FF0000">[</FONT><a HREF="##" onClick="javascript: document.MyInvoiceForm.invoicedate.value = defaultdate_js;reset_Form_Fields(1);" > reset </a><FONT COLOR="##FF0000">]</FONT></B>
				</TD>
			</TR>
		</TABLE>
	</LEGAND>
</FIELDSET>
<input type="hidden" name="checked_history_period" 	value="<cfoutput>#checked_history_period#</cfoutput>"/>	
</cfoutput>

