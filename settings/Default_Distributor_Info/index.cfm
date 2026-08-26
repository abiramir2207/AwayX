<style>
TABLE.Maintable TD
{
	border-bottom:solid #93BEE2 1px; font-size : 10px;font-weight:bold;
}
#header
{
	font-size: 12px;
	background-color:FFE083;
}
.sort {
   cursor: pointer;
}
</style>
<SCRIPT SRC="/script/javascript/string_functions.js"></SCRIPT>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.5.1-min.js"></script>   <!---26298--->

<CFQUERY NAME="Get_All_Vendor_Data" DATASOURCE = "#Application.Datasource#">
	SELECT 	Vendor_ID
	FROM 	Vendor_Master
	WHERE 	Deleted = 0
	AND		Active_Code = 'A'
</CFQUERY>

<cfset VendorList = ValueList(Get_All_Vendor_Data.Vendor_ID)>

<CF_MessageWindow>

<SCRIPT LANGUAGE="JavaScript">

/* Here FieldName is used to assign the return value */
function showDistSearchWindow()
{
	document.SearchForm.target = "_self";
	document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";
	NewWindow("/Billbacks/search_Screens/PM_select_distributors.cfm?Formname=SearchForm&FieldName=AllDistributors&SelectSingleSearchResultOnly=0&ShowVendorAndBBClosingMethod=0", "searchwindow", 800, 600, "yes", "yes")
}

function showVendSearchWindow( row_number ) {
  // row_number is the current row number in the distributors query

  //document.SearchForm.target = "_self";
  //document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";

  // 26298 2/28/2011 - ChrisN
  // 1. changed to use Dataform instead of SearchForm, this way
  //    the popup vendor master search can update the vendor info
  //    on this page,
  // 2. added reloadform= 0 so popup search would not reload this
  //    page which would wipe out all entered values for vendor &
  //    bb closing methods
  // 3. added descfieldname so popup search can refresh the vendor
  //    name based on the selected vendor
  var windowcmd = "/GL_code/Vendor_Management/vendor_master_search.cfm?"
                  + "Formname=DataForm"
                  + "&FieldName=Vendor_ID_" + row_number
                  + "&DescFieldName=Vendor_Name_" + row_number
                  + "&ReloadForm=0";
  DisableSorts();
  NewWindow(windowcmd, "Vensearchwindow", 800, 600, "yes", "yes")
}

/* Multi- assign vendor id */
function applyVendorID() {
  $(".vendor_id").each(function(index) {
    // is this distributor selected to update?
    if ( $("#distributor_" + index).attr('checked') ) {
      DisableSorts();
      // assign new vendor id
      $(this).val(apply_vendor_id.value);
      var row_number = index + 1;
      // new vendor name is not available, replace the old vendor name with ..
      // user needs to click save to see the new vendor name
      $("#Vendor_Name_" + row_number).html('..');
    }
  });
}

/* Multi- assign billback closing method */
function appBBClosingMethod() {
  $(".bb_closing_meth").each(function(index) {
    // is this distributor selected to update?
    if ( $("#distributor_" + index).attr('checked') ) {
      DisableSorts();
      // assign new bb closing method
      $(this).val(apply_bb_closing_method.value);
    }
  });
}

/* Validate vendor ids */
function validate_entries() {
  var ErrorCount = 0;
  var DataFormList = document.forms['DataForm'].elements;
  var i=DataFormList.length;
  var name_, elem, counter = 0, errorID = '';

  <cfoutput>
  for (var i=0, il= DataFormList.length; i<il; i++) {
      elem =DataFormList[i];
      name_ = elem.name;

      if ( elem.type=='text' && name_.startsWith('Vendor_ID_') ) {
        errorID = eval('document.all.error_InvalidVendor_'+counter);
        /*26298 consider empty value as valid, allow users to save selected vendor IDs and
                leave the unselected as empty */
        if ( elem.value.replace(/\s/g,"") == "" )
          clearQueue(errorID);
        else if ( ListFindItem('#VendorList#',',',elem.value) == -1 ) {
          ErrorCount++;
          queueMessage("The vendor id is not valid.\n", errorID)
        }
        else
          clearQueue(errorID);
        counter = counter + 1;
      }
  }
  if (ErrorCount != 0)
    showMessageWindow();
  else
    DataForm.submit();
  </cfoutput>
}

String.prototype.startsWith = function(str)
{return (this.match("^"+str)==str)}

</SCRIPT>

<cfset objBillbackManager = CreateObject("component","components.billback.BillbackManager") />
<cfset qBillbackClosingMethods = objBillbackManager.getBillbackClosingMethods()>

<div align="center">
<cfoutput>
<B>
<FONT COLOR="Red">[</FONT>
<FONT COLOR="Blue"><A HREF="javascript: void(0);" onClick="javaScript: showDistSearchWindow();">select #application.returned_customer_setting.distributor_label_plural#</A></FONT>
<FONT COLOR="Red">]</FONT>
</B>
</div>
</cfoutput>

<P>
<cfparam name="Distributor" default="">
<cfparam name="AllDistributors" default="">
<cfparam name="sort_by"  default="Name">
<cfparam name="sort_order"  default="ASC">


	<CFIF AllDistributors NEQ "">
		<CFQUERY NAME="Dist_Search_Result" DATASOURCE = "#Application.Datasource#">
    SELECT Bsa_foodservice_customers_id,
           Name,
           Shr_ship_to,
           Bsa_foodservice_customers.Default_vendor_id,
           Isnull(Nullif(Bsa_foodservice_customers.Default_billback_closing_method_id, ''), 0) AS Default_billback_closing_method_id,
           Vendor_master.Vendor_name,
           Billback_closing_methods.Vchbillback_closing_method_desc
      FROM Bsa_foodservice_customers
           LEFT JOIN Vendor_master
             ON Bsa_foodservice_customers.Default_vendor_id = Vendor_master.Vendor_id AND Vendor_master.Deleted = 0
           LEFT JOIN Billback_closing_methods
             ON Bsa_foodservice_customers.Default_billback_closing_method_id = Billback_closing_methods.Ibillback_closing_method_id
     WHERE BSA_Foodservice_Customers.BSA_Foodservice_Customers_ID IN (#ListQualify(AllDistributors, '''')#)
           AND Bsa_foodservice_customers.Deleted = 0
           AND Bsa_foodservice_customers.Active_code = 'A'
			ORDER BY <cfif sort_by eq "Default_Vendor_ID">Cast(#sort_by# As int)<cfelse>#sort_by#</cfif>  #sort_order#
		</CFQUERY>


<cfif IsDefined("Dist_Search_Result")>

<!--- Multi assignment tool --->
<CFSCRIPT>
	Border="Yes";
	BorderSize=0;
	BorderColor="";
	Image="/images/plus3.gif";
	ImageOpen="/images/minus3.gif";
	TitleColor="Navy";
	TitleFont="Arial";
	TitleSize=10;
	IsClosed="Yes";
	WIDTH="780";
</CFSCRIPT>

<CF_openLayer
	Border="#Border#"
	BorderSize="#BorderSize#"
	BorderColor="#BorderColor#"
	Image="#Image#"
	ImageOpen="#ImageOpen#"
	Title="Hide Multi Assign"
	TitleClosed="Show Multi Assign"
	TitleTooltip="Click here to toggle the view"
	TitleColor="#TitleColor#"
	TitleFont="#TitleFont#"
	TitleSize="#TitleSize#"
	IsClosed="#IsClosed#"
	Width="#width#"
	layerid="9999">

<table width="" border="0" cellpadding="3" cellspacing="0">
		<tr>
			<td valign="top">
				<input name="apply_vendor_id" type="text" size="10" ONKEYUP="clenseText(this,'0123456789.')">
			<td>
			<td valign="top">
			<span STYLE="font-size:11">
				<B><font color="FF0000">[</font></B>
						<a onclick="javascript:applyVendorID();" STYLE="cursor: pointer;font-size:11;font-weight:bold;">apply vendor id</a>
				<B><font color="FF0000">]</font></B>
			</span>
			</td>
		</tr>
		<tr>
			<td valign="top">
				<SELECT NAME="apply_bb_closing_method" STYLE="WIDTH:80px">
			<OPTION SELECTED value="0">None</OPTION>
			<cfoutput query="qBillbackClosingMethods">
				<cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
					<option value="#iBillback_Closing_Method_ID#">#vchBillback_Closing_Method_DESC#</option>
				</cfif>
			</cfoutput>
			</SELECT>
			<td>
			<td valign="top">
				<B><font color="FF0000">[</font></B>
						<a onclick="javascript:appBBClosingMethod();" STYLE="cursor: pointer;font-size:11;font-weight:bold;">apply billback closing method</a>
				<B><font color="FF0000">]</font></B>
			</span>
			</td>
		</tr>
</table>
</cf_openlayer>
</cfif>

<script language="javascript">
	function CA() {
		if(1==1) {
			for (var i=0;i<DataForm.elements.length;i++)
				{
					var e = DataForm.elements[i];
					if ((e.name != 'allbox') && (e.type=='checkbox')) {
						e.checked = DataForm.allbox.checked;
					}
				}
		}
		else {
			document.all.allbox.checked = false;
		}
	}
</script>

<CFSET FORM.Shr_Ship_To = Dist_Search_Result.Shr_Ship_To>
<CFSET FORM.Visible_Distributor=ValueList(Dist_Search_Result.Name)>
<CFSET AllDistributors = valueList(Dist_Search_Result.BSA_Foodservice_Customers_ID)>

<CFIF sort_order eq "ASC">
	<CFSET new_sort_order = "DESC">
	<CFSET sortImage="up_1.gif">
<CFELSE>
	<CFSET sortImage="down_1.gif">
	<CFSET new_sort_order = "ASC">
</CFIF>


<!--- 32623 created this sortform container to support a long list of distributors which exceeded the URL length limit--->
<form name="sortform" method="post">
<cfoutput>
  <input type="hidden" name="AllDistributors" value="#AllDistributors#">
  <input type="hidden" name="sort_order" value="#new_sort_order#">
  <input type="hidden" name="sort_by">
</cfoutput>
</form>

<FORM NAME="DataForm" ID="DataForm" ACTION="Default_Distributor_Info_Action.cfm" METHOD="POST">

<TABLE border="0" cellspacing="0" cellpadding="5" align="left" WIDTH="750" CLASS="Maintable">
<cfoutput>
	<TR>
		<TD ID="header"><INPUT Name="allbox" TYPE="Checkbox" onClick="CA()" TITLE="Click here to select all Distributors"></TD>
    <!--- 32623 changed to submit form using post method --->
    <TD ID="header"><a class="sort" sortby="Name">Name  <cfif sort_by eq "Name"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></TD>
    <TD ID="header"><a class="sort" sortby="Shr_Ship_To">Ship To <cfif sort_by eq "Shr_Ship_To"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></TD>
    <TD ID="header"><a class="sort" sortby="Default_Vendor_ID">Vendor ID  <cfif sort_by eq "Default_Vendor_ID"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></TD>
    <TD ID="header"><a class="sort" sortby="Vendor_Name">Vendor Name   <cfif sort_by eq "Vendor_Name"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></TD>
    <TD ID="header"><a class="sort" sortby="vchBillback_Closing_Method_Desc">BB Closing Method   <cfif sort_by eq "vchBillback_Closing_Method_Desc"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></TD>
	</TR>
</cfoutput>

	<cfoutput query="Dist_Search_Result">
	<TR <CFIF currentrow mod 2>BGCOLOR="white"<CFELSE>BGCOLOR="ccffcc"</CFIF>>
		<TD><INPUT type="Checkbox" NAME="SelectedITEMS" id="distributor_#Dist_Search_Result.currentrow-1#" value="#BSA_Foodservice_Customers_ID#"></TD>
		<TD>#Name#</TD>
		<TD>#Shr_Ship_To#</TD>
    <TD><span id="error_InvalidVendor_#Dist_Search_Result.currentrow-1#"></span><input name="Vendor_ID_#Dist_Search_Result.currentrow#" size="10" type="text" value="#Default_Vendor_ID#" class="vendor_id">   <!---26298--->
		&nbsp;&nbsp;
		<span STYLE="font-size:11">
		<FONT COLOR="Red">[</FONT>
		<FONT COLOR="Blue">

		<!---  If the user clicks on the "search" link to modify the vendor, check that distributors checkbox,
		pass the value to "Vendor_Master_Search" (popup) page, and then that page will pass it back to this page
		in the "Distributor" variable
		--->
		<cfif Dist_Search_Result.recordcount GT 1>
    <A href="##" onClick="javaScript:DataForm.SelectedITEMS[#currentrow#-1].checked=true;SearchForm.Distributor.value=SelectedITEMS[#currentrow#-1].value; showVendSearchWindow(#Dist_Search_Result.currentrow#);" class="search">search</A></FONT>
    <cfelse>
    <A href="##" onClick="javaScript:DataForm.SelectedITEMS.checked=true;SearchForm.Distributor.value=SelectedITEMS.value; showVendSearchWindow(#Dist_Search_Result.currentrow#);" class="search">search</A></FONT>
		</cfif>

		<FONT COLOR="Red">]</FONT>
		</span>
		</TD>
    <!---26298 added unique id so popup search can update its content--->
    <td id="Vendor_Name_#Dist_Search_Result.currentrow#">
      <cfif Dist_Search_Result.Vendor_Name neq "">#Dist_Search_Result.Vendor_Name#<cfelse><span style="color:red">--none--</span></cfif>
    </td>
    <td>
      <SELECT NAME="Default_BB_Closing_Method" STYLE="WIDTH:80px" class="bb_closing_meth">  <!---26298--->
			<OPTION SELECTED value="0">None</OPTION>
			<cfloop query="qBillbackClosingMethods">
				<cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
					<option value="#iBillback_Closing_Method_ID#" <cfif iBillback_Closing_Method_ID eq Dist_Search_Result.Default_Billback_Closing_Method_ID>selected</cfif>>#vchBillback_Closing_Method_DESC#</option>
				</cfif>
			</cfloop>
		</SELECT>
		</td>
	</TR>
	</cfoutput>
	</CFIF>

	<cfif IsDefined("Dist_Search_Result")>
	<TR>
	<TD colspan="100%" STYLE="border-bottom:none;font-size:11" align="center">
	<B><FONT COLOR="Red">[ </FONT><A OnClick="validate_entries();" onMouseOver="this.style.cursor='pointer'">save</A><FONT COLOR="Red"> ]</FONT></B>
	</TD>
	</TR>
	</cfif>
</TABLE>

<!--- Pass the list of distributors to the action page for saving data --->
	<cfif IsDefined("Dist_Search_Result")>
			<cfoutput>
			<INPUT TYPE="Hidden" NAME="AllDistributors" value="#valueList(Dist_Search_Result.BSA_Foodservice_Customers_ID)#">
			</cfoutput>
	</cfif>
</FORM>

<!--- Use this form to open vendor and distributor pop up windows --->
<FORM NAME="SearchForm" ACTION="" METHOD="POST">
			<INPUT TYPE="Hidden" NAME="Vendor_ID">
			<INPUT TYPE="Hidden" NAME="Distributor">
<cfif IsDefined("Dist_Search_Result")>
<!--- Pass the list of distributors to the vendor popup page, so that we know which distributors already existed on this page.--->
		<cfoutput>
			<INPUT TYPE="Hidden" NAME="AllDistributors" value="#AllDistributors#">
		</cfoutput>
<cfelse>
			<INPUT TYPE="Hidden" NAME="AllDistributors">
</cfif>
</FORM>
</P>
<script>
// if users made changes we would disable sorting columns
function DisableSorts() {
  // is this the first time the user make change?
  if ( changes_made == 0 ) {
    // turn off sorting columns
    $(".sort").attr('href', 'javascript:SaveFirst();');
  }
  changes_made = changes_made + 1;
}
function SaveFirst() {
  alert( "Before sorting the page, please click the save link to save your changes" );
}
// user made change indicator: 0 = no change made yet, 1 = changes were made
var changes_made = 0;
// handle changes made in vendor ids & bb closing methods
$(".vendor_id, .bb_closing_meth").change(function () {
  DisableSorts();
});

$('form[name=DataForm] .sort')
  // add title to each sort link
  .each (function () {
    $(this).attr('title', 'Sort by ' + $(this).text() );
  })
  // 32623 submit sortform using post method
  .click(function( e ) {
    e.preventDefault();
    if ( changes_made ) {
      SaveFirst();
    }
    else {
      $('form[name=sortform] input[name=sort_by]').val( $(this).attr('sortby') );
      $('form[name=sortform]').submit();
    }
  });
</script>

<!---pop up the search box right away--->
<cfif IsDefined("URL.popUpSearch")>
  <script>
    showDistSearchWindow();
  </script>
</cfif>
