<style>
table.Maintable td
{
  border-bottom:solid #93BEE2 1px; font-size : 10px;font-weight:bold;
}
#header
{
  font-size: 12px;
  background-color:FFE083;
}
</style>
<script SRC="/script/javascript/string_functions.js"></script>
<script type="text/javascript" src="/Script/javascript/Ajax_JS/jquery-1.5.1-min.js"></script>   <!---26298--->


<cfquery name="Get_All_Vendor_Data" DATASOURCE = "#Application.Datasource#">
  select  Vendor_ID
  FROM  Vendor_Master 
  WHERE   Deleted = 0 
  AND   Active_Code = 'A'
</cfquery>

<cfset VendorList = ValueList(Get_All_Vendor_Data.Vendor_ID)>

<CF_MessageWindow>

<script LANGUAGE="JavaScript">

function showVendSearchWindow( row_number ) {
  // row_number is the current row number in the operators query
  
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
                  + "&DescFieldName=Vendor_Name_" + row_number + ""
                  + "&ReloadForm=0";
  DisableSorts();                  
  NewWindow(windowcmd, "Vensearchwindow", 800, 600, "yes", "yes")
}

/* Multi- assign vendor id */
 function applyVendorID() {
  $(".vendor_id").each(function(index) {
    // is this operator selected to update?
    if ( $("#operator_" + index).attr('checked') ) {
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
    if ( $("#operator_" + index).attr('checked') ) {
      DisableSorts();
      // assign new bb closing method
      $(this).val(apply_bb_closing_method.value);
    }
  });
}

/* Validate vendor id */
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

function openOperatorsWindow() {
    document.SearchForm.target = "_self";
    document.SearchForm.action = "<CFOUTPUT>#CGI.SCRIPT_NAME#</CFOUTPUT>";        
    NewWindow("/Billbacks/search_Screens/PM_select_operators.cfm?FormName=SearchForm&FieldName=Operator_List&SelectSingleSearchResultOnly=0&ShowVendorAndBBClosingMethod=0", "searchoperator", 900, 600, "yes", "yes")
}

String.prototype.startsWith = function(str)
{return (this.match("^"+str)==str)}
</script>

<cfset objBillbackManager = CreateObject("component","components.billback.BillbackManager") />
<cfset qBillbackClosingMethods = objBillbackManager.getBillbackClosingMethods()>

<cfparam name="Operator_List" default="">
<cfparam name="sort_by"       default="Operator_Name">
<cfparam name="sort_order"    default="ASC">

<div align="center">
<cfoutput>
<b>
<font color="Red">[</font>
<font color="Blue"><A HREF="javascript: void(0);" onClick="openOperatorsWindow();">select Operators</A></font>
<font color="Red">]</font>
</b>
</div>
</cfoutput>

<cfparam name="Distributor" default="">

<P>
<cfif Len(Operator_List)>
  <cfquery name="Operator_Search_Result" datasource = "#Application.Datasource#">
    select BSA_Operator_ID,
           Legacy_ID,
           Operator_Name,
           isnull(nullif(BSA_Operator.Legacy_ID,''), BSA_Operator.BSA_Operator_ID) As Operator_ID,
           BSA_Operator.Default_Vendor_ID,
           isnull(nullif(BSA_Operator.Default_Billback_Closing_Method_ID,''),0) As Default_Billback_Closing_Method_ID,
           Vendor_Master.Vendor_Name,
           Billback_Closing_Methods.vchBillback_Closing_Method_Desc
      FROM BSA_Operator
      LEFT JOIN Vendor_Master ON BSA_Operator.Default_Vendor_ID = Vendor_Master.Vendor_ID
             AND Vendor_Master.Deleted = 0              <!---26298 modified for consistency, vendor master search filters out deleted records--->
      LEFT JOIN Billback_Closing_Methods ON BSA_Operator.Default_Billback_Closing_Method_ID = Billback_Closing_Methods.iBillback_Closing_Method_ID  
     WHERE BSA_Operator_ID IN (#ListQualify(Operator_List, '''')#)
     ORDER BY <cfif sort_by eq "Default_Vendor_ID">Cast(#sort_by# As int)<cfelse>#sort_by#</cfif>  #sort_order#   
  </cfquery>

  <cfif Operator_Search_Result.recordCount>
    <!--- Multi assignment tool --->
    <cfscript>
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
    </cfscript>
    
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
            <b><font color="FF0000">[</font></b>
                <a onclick="javascript:applyVendorID();" STYLE="cursor: pointer;font-size:11;font-weight:bold;">apply vendor id</a>  
            <b><font color="FF0000">]</font></b>
          </span>
          </td>
        </tr>   
        <tr>
          <td valign="top">
            <select name="apply_bb_closing_method" STYLE="WIDTH:80px">
          <option selected value="0">None</option>
          <cfoutput query="qBillbackClosingMethods">
            <cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
              <option value="#iBillback_Closing_Method_ID#">#vchBillback_Closing_Method_DESC#</option>
            </cfif>
          </cfoutput>
          </select>
          <td>
          <td valign="top">
            <b><font color="FF0000">[</font></b>
                <a onclick="javascript:appBBClosingMethod();" STYLE="cursor: pointer;font-size:11;font-weight:bold;">apply billback closing method</a> 
            <b><font color="FF0000">]</font></b>
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

  <cfif sort_order eq "ASC">
    <cfset new_sort_order = "DESC">
    <cfset sortImage="up_1.gif">
  <cfelse>
    <cfset sortImage="down_1.gif">
    <cfset new_sort_order = "ASC">
  </cfif>
  
  <form name="DataForm" id="DataForm" ACTION="Default_Operator_Info_Action.cfm" METHOD="POST">
  <!--- Pass the list of operators to the action page for saving data --->
  <cfoutput>
  <input type="Hidden" name="Operator_List" value="#valueList(Operator_Search_Result.BSA_Operator_ID)#">
  </cfoutput>
  
  <table border="0" cellspacing="0" cellpadding="5" align="left" WIDTH="750" class="Maintable">
    <cfoutput>
    <tr>
      <td id="header"><input Name="allbox" type="Checkbox" onClick="CA()" title="Click here to select all Operators"></td>
      <td id="header"><a class="sort" href="index.cfm?sort_by=Operator_Name&Operator_List=#Operator_List#&sort_order=#new_sort_order#">Name <cfif sort_by eq "Operator_Name"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
      <td id="header"><a class="sort" href="index.cfm?sort_by=Operator_ID&Operator_List=#Operator_List#&sort_order=#new_sort_order#">Operator id <cfif sort_by eq "Operator_ID"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
      <td id="header"><a class="sort" href="index.cfm?sort_by=Default_Vendor_ID&Operator_List=#Operator_List#&sort_order=#new_sort_order#">Vendor id  <cfif sort_by eq "Default_Vendor_ID"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
      <td id="header"><a class="sort" href="index.cfm?sort_by=Vendor_Name&Operator_List=#Operator_List#&sort_order=#new_sort_order#">Vendor Name   <cfif sort_by eq "Vendor_Name"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
      <td id="header"><a class="sort" href="index.cfm?sort_by=vchBillback_Closing_Method_Desc&Operator_List=#Operator_List#&sort_order=#new_sort_order#">BB Closing Method   <cfif sort_by eq "vchBillback_Closing_Method_Desc"><IMG BORDER="0" SRC="/Images/#sortImage#"></cfif></a></td>
    </tr>
    </cfoutput>
  
    <cfoutput query="Operator_Search_Result">
    <tr <cfif currentrow mod 2>BGCOLOR="white"<cfelse>BGCOLOR="ccffcc"</cfif>>
      <td><input type="Checkbox" name="SelectedITEMS" id="operator_#Operator_Search_Result.currentrow-1#" value="#Operator_Search_Result.BSA_Operator_ID#"></td>
      <td>#Operator_Search_Result.Operator_Name#</td>
      <td>#Operator_Search_Result.Operator_ID#</td>
      <td><span id="error_InvalidVendor_#Operator_Search_Result.currentrow-1#"></span><input name="Vendor_ID_#Operator_Search_Result.currentrow#" size="10" type="text" value="#Default_Vendor_ID#" class="vendor_id">
      &nbsp;&nbsp;
      <span STYLE="font-size:11">
      <font color="Red">[</font>
      <font color="Blue">
  
      <!---  If the user clicks on the "search" link to modify the vendor, check that distributors checkbox, 
      pass the value to "Vendor_Master_Search" (popup) page, and then that page will pass it back to this page 
      in the "Distributor" variable
      --->
      <cfif Operator_Search_Result.recordcount GT 1>
      <A HREF="javascript: void(0);"  onClick="javaScript:DataForm.SelectedITEMS[#currentrow#-1].checked=true;SearchForm.Distributor.value=SelectedITEMS[#currentrow#-1].value; showVendSearchWindow(#Operator_Search_Result.currentrow#);">search</A></font>
      <cfelse>
      <A HREF="javascript: void(0);"  onClick="javaScript:DataForm.SelectedITEMS.checked=true;SearchForm.Distributor.value=SelectedITEMS.value; showVendSearchWindow(#Operator_Search_Result.currentrow#);">search</A></font>
      </cfif>
  
      <font color="Red">]</font>
      </span>
      </td>   
      <!---26298 added unique id so popup search can update its content--->
      <td id="Vendor_Name_#Operator_Search_Result.currentrow#"><cfif Operator_Search_Result.Vendor_Name neq "">#Operator_Search_Result.Vendor_Name#<cfelse><span style="color:red">--none--</span></cfif></td>   
      <td>  
        <select name="Default_BB_Closing_Method" STYLE="WIDTH:80px" class="bb_closing_meth">
        <option selected value="0">None</option>
        <cfloop query="qBillbackClosingMethods">
          <cfif qBillbackClosingMethods.iBillback_Closing_Method_ID eq 1 OR qBillbackClosingMethods.iBillback_Closing_Method_ID eq 2>
            <option value="#iBillback_Closing_Method_ID#" <cfif iBillback_Closing_Method_ID eq Operator_Search_Result.Default_Billback_Closing_Method_ID>selected</cfif>>#vchBillback_Closing_Method_DESC#</option>
          </cfif>
        </cfloop>
      </select>
      </td>
    </tr>
    </cfoutput>
    </cfif>
  
    <cfif IsDefined("Operator_Search_Result")>
    <tr>
    <td colspan="100%" STYLE="border-bottom:none;font-size:11" align="center">
    <b><font color="Red">[ </font><A OnClick="validate_entries();" onMouseOver="this.style.cursor='pointer'">save</A><font color="Red"> ]</font></b>
    </td>
    </tr>
    </cfif>
  </table>
  
  </form>
  
  <!--- Use this form to open vendor and distributor pop up windows --->
  <form name="SearchForm" ACTION="" METHOD="POST">
        <input type="Hidden" name="Vendor_ID">
        <input type="Hidden" name="Distributor">
        <!---<input type="Hidden" name="AllDistributors">--->
    <cfif IsDefined("Operator_Search_Result")>
  <!--- Pass the list of distributors to the vendor popup page, so that we know which distributors already existed on this page.--->
      <cfoutput>
        <input type="Hidden" name="Operator_List" value="#Operator_List#">
      </cfoutput>
  <cfelse>
        <input type="Hidden" name="Operator_List">
  </cfif>
</form>

<form method="post" name="operator_form" action="/settings/Default_Operator_Info/index.cfm">
  <!---<input type="hidden" name="AllDistributors" value="<cfif isDefined("Form.AllDistributors")><cfoutput>#Form.AllDistributors#</cfoutput></cfif>"--->
  <input type="Hidden" name="operator_id"                  value="">
  <input type="Hidden" name="SelectSingleSearchResultOnly" value="0">
</form>
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
</script>

<!---pop up the search box right away--->
<cfif IsDefined("URL.popUpSearch")>
  <script>
    openOperatorsWindow();
  </script>
</cfif>

