<!--- 
FILE: 		
FILENAME: 	Common_Files/contracts/Letters/minimal_contract_info.cfm
CREATED: 	12/19/2007 - RBL
EDITED:		10/29/2008 - RBL [D17386]

FUNCTIONALITY:
- This file displays the list of generated letters to the user. It also offers options to email or print one or more selected letters from same list...
--->
<cfparam name="request.style" default="classic">

<cfif request.style is "classic">
    <!--- 17386 [begin] --->
    <cfparam name="variables.authorRSPID" type="string" default="">
    <!--- 17386 [end] --->

    <cfquery name="GetContractInfo" datasource="#application.datasource#">
        SELECT Program_Control_Panel_Options.Created_Type as CreatedType, Program_Control_Panel_Options.*,Contract_Main.*
        FROM Contract_Main
        INNER JOIN Program_Control_Panel_Options
                ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = Contract_Main.ProgramType_ID
        WHERE Contract_Main_ID = '#FORM.Contract_Main_ID#'
        and Program_Control_Panel_Options.deleted = 0
    </cfquery>
    <cfset programDesc = GetContractInfo.CreatedType >
    <cfset MAXLENGTH = 60 >
    <cfset MAXLENGTHTITLE = 110 >
    <cfif request.accessStructure.User_ID EQ variables.authorRSPID>
        <cfparam name="width" default="830">
    <cfelse>
        <cfparam name="width" default="800">
    </cfif>
    <HR class="top_header" COLOR="Blue" SIZE="1" width=<cfoutput>"#width#"</cfoutput> ALIGN="left">
    <TABLE class="top_header" BORDER="0" CELLSPACING="0" CELLPADDING="1" width=<cfoutput>"#width#"</cfoutput>>
        <TR BGCOLOR="#ffce84">
            <TD>
            <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0"  width=<cfoutput>"#width#"</cfoutput> >
            <TR>
            <!---- new enhancement for mcCain:
                    1:	Change label from Contract Number to Program Number
                    2:	Add program template information beside Program Number
            --->
            <TD align="left" nowrap>&nbsp;&nbsp;&nbsp;<B><FONT style="font-size: 12px"><cfoutput>#GetContractInfo.Contract_Number#</cfoutput></FONT></B></TD>
            <cfoutput><TD align="right" nowrap title="#GetContractInfo.CreatedType#"><FONT style="font-size: 11px">Template: <cfif Len(GetContractInfo.CreatedType) GT MAXLENGTH >#Left(GetContractInfo.CreatedType,MAXLENGTH)#...<cfelse>#GetContractInfo.CreatedType#</cfif></FONT>&nbsp;&nbsp;&nbsp;</TD></cfoutput>
            </TR>
            </TABLE>
            </TD>
        </TR>
        <TR BGCOLOR="#ffce84">
            <TD>
            <TABLE BORDER="0" CELLSPACING="0" CELLPADDING="0" width=<cfoutput>"#width#"</cfoutput> >
            <TR>
            <TD align="left" nowrap>&nbsp;&nbsp;&nbsp;<FONT style="font-size: 11px"><cfoutput><cfif Len(GetContractInfo.Contract_Title) GT MAXLENGTHTITLE >#Left(GetContractInfo.Contract_Title,MAXLENGTHTITLE)#...<cfelse>#GetContractInfo.Contract_Title#</cfif></cfoutput></FONT></TD>
            <TD align="right" nowrap ><cfoutput><FONT style="font-size: 11px">#DateFormat(GetContractInfo.Contract_Start_Date, 'MM/DD/YYYY')# - #DateFormat(GetContractInfo.Contract_End_Date, 'MM/DD/YYYY')#</FONT></cfoutput>&nbsp;&nbsp;&nbsp;</TD>
            </TR>
            </TABLE>
            </TD>
        </TR>
    </TABLE>
    <HR class="top_header" COLOR="Blue" SIZE="1" width=<cfoutput>"#width#"</cfoutput> ALIGN="left">


<cfelse>        <!--- <cfif request.style is "classic"> --->

    <!--- 2020 optimized, responsive style --->
    <cfquery name="GetContractInfo" datasource="#application.datasource#">
        SELECT Program_Control_Panel_Options.Created_Type as CreatedType, 
               cm.Contract_Number,
               cm.Contract_Title,
               cm.Contract_Start_Date, 
               cm.Contract_End_Date,
               cm.Approved,
               cm.Deleted
        FROM Contract_Main cm
        INNER JOIN Program_Control_Panel_Options
                ON Program_Control_Panel_Options.ProgramControl_Panel_Options_ID = cm.ProgramType_ID
        WHERE cm.Contract_Main_ID = <cfqueryparam value='#FORM.Contract_Main_ID#'>
                and Program_Control_Panel_Options.deleted = 0
    </cfquery>

    <style>
        .prg-header {
            border: 1px solid blue;
            border-right: none;
            border-left: none;
            padding: 0px;
            display: flex;
            margin-top: 3px;
            box-sizing: border-box;
            background-color: #ffce84;
            width: 100%;
        }
        .prg-header div {
            width: 50%;
            max-width: 50%;
            padding: 5px;
            font-size: 11px;
            line-height: 13px;
        }
        .prg-header div:nth-child(2) {
            text-align: right;
        }
        .prg-header b {
            font-size: 12px;
        }
    </style>

    <cfoutput>
    <section class="prg-header">
        <div class="truncate">
            <b>#GetContractInfo.Contract_Number#</b><br>
            #GetContractInfo.Contract_Title#
        </div>
        <div class="truncate">
            Template: <b>#GetContractInfo.CreatedType#</b><br>
            #application.util.dateTime.DateSpanFormat(GetContractInfo.Contract_Start_Date, GetContractInfo.Contract_End_Date)#
        </div>
    </section>    
    </cfoutput>

</cfif>             <!--- <cfif request.style is "classic"> --->

