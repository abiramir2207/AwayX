<!-----------------------------------------------------------------------------

FILE NAME:		_pg_header.cfm
DESCRIPTION:
CREATED BY:		09-Sep-2010
MODIFICATION HISTORY:	BY		DATE		DESCRIPTION OF CHANGE

                  Anand Rao	  09-Sep-2010	Created the file
------------------------------------------------------------------------------>
<cfset TR_BORDER_WIDTH = 2>
<cfset TD_FORE_COLOR = "FFE083">
<cfset TD_FORE_COLORTOP = "999999">

<!---  TO DISPLAY THE TABS FOR PRODUCT, CUSTOMER,  OPERATOR THESE BELOW SWITCHES SHOULD BE ON --->
<cfset PageLevelSetting_Customer = 1/>
<cfset PageLevelSetting_Product = 1/>
<cfset PageLevelSetting_Operator = 1/>

<CFOUTPUT>
<STYLE TYPE="text/css">
    table.pgt852 tr, table##nav106 tr { height: 29px; }
    div.nav106 { background: ##a7caf2 url("/Images/gradient.jpg") repeat-y; }
    A.tablink_back, A:Hover.tablink_back
    {
        color: 				Black;
        font-family:		Arial;
        font-size :			11px;
        font-weight:		bold;
        text-decoration:	none;
    }
    A:visited.tablink_back
    {
        color: 				Black;
        font-family:		Arial;
        font-size :			11px;
        font-weight:		bold;
        text-decoration:	none;
    }
    A:visited.tablink_backtop
    {
        color: 				Black;
        font-family:		Arial;
        font-size :			12px;
        font-weight:		bold;
        text-decoration:	none;
    }
    A.tablink_fore
    {
        color: 				Red;
        font-family:		Arial;
        font-size :			11px;
        font-weight:		bold;
        text-decoration:	none;
    }
    A:visited.tablink_fore
    {
        color: 				Red;
        font-family:		Arial;
        font-size :			11px;
        font-weight:		bold;
        text-decoration:	none;
    }
    table##nav106 TD { font-size: 13px; }
    table##nav106 TD.headernotselected a { color: white; }
    table##nav106 TD.headernotselectedtop a { color: white; }
    table##nav106 TD.headerselectedtop a { color: black; background-color: white; padding: 3px 20px; }
    table##nav106 TD.headerselectedtop { }
    table##nav106 TD.headerspacer a { color: white; }

    table.pgt852 TD.headernotselected
    {
    background-color 	: dddddd;
    border-bottom		: solid #TR_BORDER_WIDTH#px black;
    cursor				: pointer;
    }
    table.pgt852 TD.headernotselectedtop
    {
    background-color 	: cfcfcf;
    border-bottom		: solid #TR_BORDER_WIDTH+2#px ##636363;
    cursor				: pointer;
    }
    table.pgt852 TD.headerselected
    {
    border-left			: solid #TR_BORDER_WIDTH#px black;
    border-top			: solid #TR_BORDER_WIDTH#px black;
    border-right			: solid #TR_BORDER_WIDTH#px black;
    background-color 	: #TD_FORE_COLOR#;
    cursor				: pointer;
    TEXT-TRANSFORM2		: uppercase;
    }
    table.pgt852 TD.headerselectedtop
    {
    border-left			: solid #TR_BORDER_WIDTH+2#px ##636363;
    border-top			: solid #TR_BORDER_WIDTH+2#px ##636363;
    border-right			: solid #TR_BORDER_WIDTH+2#px ##636363;
    background-color 	: #TD_FORE_COLORTOP#;
    cursor				: pointer;
    TEXT-TRANSFORM2		: uppercase;
    }
    table.pgt852 TD.headerspacer
    {
    border-bottom		: solid #TR_BORDER_WIDTH#px black;
    }
    table.pgt852 TD.headerspacertop
    {
    border-bottom		: solid #TR_BORDER_WIDTH+2#px ##636363;
    }
    td.pgtd {
        width: 140px;
        text-align: center;
        white-space: nowrap;
        font-weight: bold;
    }
</STYLE>
</CFOUTPUT>

<cfparam NAME="PLANNING_PAGE_NAME" DEFAULT=1>
<cfset PLANNING_PAGE_TITLES = "">
<cfset PLANNING_PAGE_ACTIONS = "">

<cfset PLANNING_PAGE_TITLES = ListAppend(PLANNING_PAGE_TITLES, "Type", ",")>
<cfset PLANNING_PAGE_ACTIONS = ListAppend(PLANNING_PAGE_ACTIONS, "type", ",")>

<cfif  (PageLevelSetting_Product EQ 1)>
  <cfset PLANNING_PAGE_TITLES = ListAppend(PLANNING_PAGE_TITLES, "#application.returned_customer_setting.Item_Label#", ",")>
  <cfset PLANNING_PAGE_ACTIONS = ListAppend(PLANNING_PAGE_ACTIONS, "product", ",")>
</cfif>

<cfif  (PageLevelSetting_Customer EQ 1)>
  <cfset PLANNING_PAGE_TITLES = ListAppend(PLANNING_PAGE_TITLES, "#application.returned_customer_setting.Distributor_Label_Singular#", ",")>
  <cfset PLANNING_PAGE_ACTIONS = ListAppend(PLANNING_PAGE_ACTIONS, "customer", ",")>
</cfif>

<cfif  (PageLevelSetting_Operator EQ 1)>
  <cfset PLANNING_PAGE_TITLES = ListAppend(PLANNING_PAGE_TITLES, "#application.returned_customer_setting.Operator_Label_Singular#", ",")>
  <cfset PLANNING_PAGE_ACTIONS = ListAppend(PLANNING_PAGE_ACTIONS, "operator", ",")>
</cfif>

<!--- D33532:Planning Group Research tools --->
<cfset PLANNING_PAGE_TITLES = ListAppend(PLANNING_PAGE_TITLES, "Research", ",")>
<cfset PLANNING_PAGE_ACTIONS = ListAppend(PLANNING_PAGE_ACTIONS, "research", ",")>
<!--- D33532:Planning Group Research tools --->
<cfif (FORM.display_type eq "Type")>
  <cfset PLANNING_PAGE_NAME = 1 />
<cfelseif FORM.display_type eq "Product" AND (PageLevelSetting_Product  EQ 1)>
    <cfset PLANNING_PAGE_NAME = 2 />
<cfelseif FORM.display_type eq "Customer" AND (PageLevelSetting_Customer  EQ 1)>
    <cfset PLANNING_PAGE_NAME = 3 />
<cfelseif FORM.display_type eq "Operator" AND (PageLevelSetting_Operator  EQ 1)>
    <cfset PLANNING_PAGE_NAME = 4 />
<!--- D33532:Planning Group Research tools --->
 <cfelseif FORM.display_type eq "Research" AND (PageLevelSetting_Operator  EQ 1)>
    <cfset PLANNING_PAGE_NAME = 5/>
</cfif>


<cfoutput>
<div class="nav106">
    <table border="0" cellspacing="0" cellpadding="1" id="nav106">
        <tr>
            <td colspan="5" style="color:white;font-weight:bold;font-size:.9em;letter-spacing:1.75px;"> &nbsp; PLANNING GROUPS</td>
        </tr>
        <tr>
            <cfset P_Counter = 1>
            <cfloop list="#PLANNING_PAGE_TITLES#" INDEX="ThisTopTabItem">
                <cfset class_name = P_Counter EQ PLANNING_PAGE_NAME ? "headerselectedtop" : "headernotselectedtop">
                <!---remove link if its edit or bus rules--->
                <td class="#class_name# pgtd">
                    <cfif PLANNING_PAGE_NAME eq 6 and P_Counter EQ PLANNING_PAGE_NAME>
                        #lcase(ThisTopTabItem)#
                    <cfelse>
                        <a class="tablink_backtop" HREF="##" onClick="JavaScript: return submitDataForm('#FORM.display_type#','#ListGetAt(PLANNING_PAGE_ACTIONS,P_Counter)#');">#lcase(ThisTopTabItem)#</A>
                    </cfif>
                </td>
                <cfset P_Counter = P_Counter + 1>
            </cfloop>
        </tr>
    </table>
</div>


<CFPARAM NAME="COMPONENT_PAGE_NAME" 	DEFAULT=1>

<cfset COMPONENT_PAGE_TITLES = "">
<cfset COMPONENT_PAGE_ACTIONS = "">

<!--- D33532:Planning Group Research tools --->
<cfif FORM.DISPLAY_TYPE EQ "Research">
    <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Empty Membership", ",")>
    <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "membership", ",")>

    <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Volume Forecast Duplicates", ",")>
    <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "volume", ",")>

    <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Accrual Budget Duplicates", ",")>
    <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "accrual", ",")>

    <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Program Segment Alignment", ",")>
    <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "segment", ",")>

    <cfif FORM.display eq "volume">
        <cfset COMPONENT_PAGE_NAME = 2 />
    <cfelseif FORM.display eq "accrual">
        <cfset COMPONENT_PAGE_NAME = 3 />
    <cfelseif FORM.display eq "segment">
        <cfset COMPONENT_PAGE_NAME = 4 />
    </cfif>

    <cfset width = "200">
<cfelse>

    <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Active", ",")>
    <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "active", ",")>

    <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Inactive", ",")>
    <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "inActive", ",")>
    <cfif Get_Profile_Settings.Planning_Groups_Create EQ 2>
        <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Add New", ",")>
        <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "add", ",")>
    </cfif>
    <!---display edit tab if in edit mode--->
    <cfif FORM.display eq "edit">
        <cfset COMPONENT_PAGE_TITLES = ListAppend(COMPONENT_PAGE_TITLES, "Edit Record", ",")>
        <cfset COMPONENT_PAGE_ACTIONS = ListAppend(COMPONENT_PAGE_ACTIONS, "update", ",")>
    </cfif>

    <!---highlight tabs according to action--->
    <cfif FORM.display eq "inActive">
        <cfset COMPONENT_PAGE_NAME = 2 />
    <cfelseif FORM.display eq "add">
        <cfset COMPONENT_PAGE_NAME = 3 />
        <cfif isDefined("SESSION.FormData")>
            <cfset StructDelete(Session, "FormData")>
        </cfif>
    <cfelseif FORM.display eq "edit">
        <cfset COMPONENT_PAGE_NAME = 4 />
    </cfif>

    <cfset width = "120">
</cfif>

<!--- D33532:Planning Group Research tools --->
<BR>
<table border="0" cellspacing="0" cellpadding="1" width="#(250 * listLen( component_page_titles ))#px" class="pgt852">
    <tr>
        <cfset C_Counter = 1>
        <cfloop list="#component_page_titles#" index="thismenuitem">
            <cfset class_name = c_counter eq component_page_name ? "headerselected" : "headernotselected">

            <td class="#class_name# pgtd">
                <!---remove link if its edit or bus rules--->
                <cfif COMPONENT_PAGE_NAME eq 4 and C_Counter EQ COMPONENT_PAGE_NAME>
                    #ThisMenuItem#
                <cfelse>
                    <A CLASS="tablink_back" HREF="##" onClick="JavaScript: return submitDataForm('#FORM.display_type#','#ListGetAt(COMPONENT_PAGE_ACTIONS,C_Counter)#');">#ThisMenuItem#</A>
                </cfif>
            </td>
            <cfset c_counter = c_counter + 1>
        </cfloop>
    </tr>
</table>
</cfoutput>
