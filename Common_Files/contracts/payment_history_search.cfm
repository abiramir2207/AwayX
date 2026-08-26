<cfparam name="request.addDoctype" default=true>
<cfif request.addDocType>
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
	<title>Untitled</title>
</head>
<body >
</cfif>
<SCRIPT SRC="/Script/javascript/dhtml.js"></SCRIPT>
<CFSET Layer_ID = 9999>
<script>
	var bNoPrevSearch = true;
	function showSearchResult(bchangeMode, pageNum)
	{
		document.SearchForm.startrow.value = pageNum;
		if(arguments.length > 2)
		{
			document.SearchForm.frompage.value = arguments[2];
		}
		var searhFormHideImg = document.all.image_<CFOUTPUT>#Layer_ID#</CFOUTPUT>;
		if(bchangeMode)
		{
			searhFormHideImg.click();
		}
		document.SearchForm.submit();
		bNoPrevSearch = false;
}
function start_End_Date(start_D,thisObj)
	{
		var spName;
		if(start_D == 1)
		{
			spName = "SP_Start_date";
		}
		else
		{
			spName = "SP_End_date";
		}
		var bDis = (thisObj.selectedIndex == 0)? true: false;
		disableDiv(spName,bDis,false);
	}

	function disable_start_End_Date()
	{
		start_End_Date(1,SearchForm.Start_date_Operator);
		start_End_Date(2,SearchForm.End_date_Operator);
		SearchForm.Start_date.style.fontSize=10;
		SearchForm.End_date.style.fontSize=10;
	}

function clearFormElements(ele) {
    var i, j, tags = ele.getElementsByTagName('input');

    for(i = 0; i < tags.length; i++) {
        switch(tags[i].type) {
            case 'password':
            case 'text':
                tags[i].value = '';
                break;
            case 'checkbox':
            case 'radio':
                tags[i].checked = false;
                break;
        }
    }

    tags = ele.getElementsByTagName('select');
    for(i = 0; i < tags.length; i++) {
        if(tags[i].type == 'select-one') {
            tags[i].selectedIndex = 0;
            // reset payee type to All
    				if (tags[i].name.toLowerCase() == "payee_type") {
            	tags[i].selectedIndex = 2;
    				}
        }
        else {
            for(j = 0; j < tags[i].options.length; j++) {
                tags[i].options[j].selected = false;
            }
        }
    }

    tags = ele.getElementsByTagName('textarea');
    for(i = 0; i < tags.length; i++) {
        tags[i].value = '';
    }
}
</script>
<CFSCRIPT>
	Border="Yes";
	BorderSize=0;
	BorderColor="";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="No";
	WIDTH="100%";
</CFSCRIPT>

<FORM STYLE="margin-bottom: 0px;margin-top: 0px;" ACTION="view_contract_payment_history.cfm?ContractId=<cfoutput>#url.ContractId#</cfoutput>" METHOD="post" NAME="SearchForm" ID="SearchForm">
<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Search Criteria"
	TitleClosed="Search Criteria"
	TitleTooltip="Click here to toggle the view"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="No"
	Width="#width#"
	layerid="#Layer_ID#">
<table>
<CFSET Date_Operators=" ,Greater_Or_Equal,Equal,Less_Or_Equal">
	<CFSET Date_Operator_Symbols=" ,>=,=,<=">
<TR>
			<TD><B>Payee Id</B><BR><INPUT TYPE="Text" NAME="payee_id" SIZE="20" VALUE="<cfoutput>#FORM.payee_id#</cfoutput>"> </TD>
			<td><B>Payee Name</B><BR><INPUT TYPE="Text" NAME="payee_name" SIZE="20" VALUE="<cfoutput>#FORM.payee_name#</cfoutput>"></td>
			<TD>
			<span ID="searchItemLabel"><B>Paid Date - From</B></span><BR>
				<CFOUTPUT>
				<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR><TD>
				<CFPARAM NAME="FORM.Start_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(1,this);" NAME="Start_date_Operator" ID="Start_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.Start_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.Start_date" DEFAULT="#Now()#">
				<SPAN ID="SP_Start_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="Start_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.Start_date#">
				</SPAN>
				</TD>
			</TR></TABLE>
				</CFOUTPUT>
			</TD>
			<TD>
			<span ID="searchItemLabel"><B>Paid Date - To</B></span><BR>
			<CFOUTPUT>
			<TABLE CELLPADDING="0" CELLSPACING="0">
				<TR><TD>
				<CFPARAM NAME="FORM.End_date_Operator" DEFAULT="">
				<SELECT OnChange="JavaScript: start_End_Date(2,this);" NAME="End_date_Operator" ID="End_date_Operator" STYLE="WIDTH:45px">
					<CFSET cnt=0>
					<CFLOOP LIST="#Date_Operators#" INDEX="thisOperator">
						<CFSET cnt=cnt+1>
						<OPTION VALUE="#Trim(thisOperator)#"<CFIF FORM.End_date_Operator EQ Trim(thisOperator)> SELECTED</CFIF>>#Trim(ListGetAt(Date_Operator_Symbols,cnt))#</OPTION>
					</CFLOOP>
				</SELECT>
				</TD>
				<TD>
				<CFPARAM NAME="FORM.End_date" DEFAULT="#Now()#">
				<SPAN ID="SP_End_date">
				<CF_EASYDATE FORMNAME="SearchForm" FIELDNAME="End_date" FORMAT="mm/dd/yyyy" DEFAULT="#FORM.End_date#">
				</SPAN>
				</TD>
				</TR></TABLE>
			</CFOUTPUT>		</TD>
				<cfoutput><td><B>Payee Type</B><BR><SELECT NAME="Payee_Type" STYLE="WIDTH:100px">
						<OPTION VALUE="1"<CFIF FORM.Payee_Type EQ 1> SELECTED</CFIF>>#lcase(application.returned_customer_setting.distributor_label_singular)#</OPTION>
						<OPTION VALUE="2"<CFIF FORM.Payee_Type EQ 2> SELECTED</CFIF>>#lcase(application.returned_customer_setting.operator_label_singular)#</OPTION>
						<OPTION VALUE="0"<CFIF FORM.Payee_Type EQ 0> SELECTED</CFIF>>All</OPTION>
				</SELECT></td></cfoutput>
		</TR>
		<TR>
		<TD>
			<B><FONT COLOR="#FF0000">[</FONT><a HREF="##" ONCLICK="javascript:showSearchResult(true, 1);"> search </a><FONT COLOR="#FF0000">]</FONT></B>			&nbsp;&nbsp;
				<B><FONT COLOR="FF0000">[</FONT><a HREF="##" ONCLICK="javascript:clearFormElements(document.getElementById('SearchForm'));disable_start_End_Date();"> reset form </a><FONT COLOR="FF0000">]</FONT></B>
			</TD>
</TR>
</table>
			<INPUT TYPE="HIDDEN" NAME="startrow" VALUE="1">
			<INPUT TYPE="HIDDEN" NAME="frompage" VALUE="1">
			<input type="hidden" name="generatexlsreport" value="0">
			 <input type="hidden" name="printonly" value="0">
			<cfoutput><INPUT TYPE="HIDDEN" NAME="sort_by" VALUE="#form.sort_by#">
			<INPUT TYPE="HIDDEN" NAME="sort_Order" VALUE="#form.sort_Order#"></cfoutput>
</CF_openLayer>
</FORM>


<cfif request.addDocType>
</body>
</html>
</cfif>