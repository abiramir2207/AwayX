<!---
  * ====================================================================================================
  *    @File: AwayX\settings\Self_Service\Self_Serve_Detail.cfm
  *    @Author: Anand Rao
  *    @Date: 16 Sep 2024
  *
  * @Remarks: Excel upload detail for planner volume upload
  *
  * ====================================================================================================
--->
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Self Serve Detail</title>
</head>
 
<body>
    <cfset pagetitle = "SYSTEM ADMINISTRATION: Self Service Details Page">
    <!--- xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx --->
    <cfinclude template="/settings/settings_title.cfm">
    <cfset udf               = new components.udf() />
    <cfset selfServeMgr = CreateObject("component","mvc.Models.Admin.SelfServe.SelfServeManager") />
    <cfset qgetUploadHistory = selfServeMgr.getUploadByID(url.ssID) />
    <cfset qgetLookupByID = selfServeMgr.getLookupByID(qgetUploadHistory.Self_Serve_Action_Category_Type_Lookup_ID) />
    <cfset request.ag_grid_dense   = 0 />
    <!--- <cfset request.ag_grid_version = "20" /> ---> <!--- 29.1.0 --->
    <cfset request.ag_grid_version = "20">
    <cfset docFullName = replace( application.doc_path & "\Data_Files\Uploaded\settings\self_serve\" &  qgetUploadHistory.Upload_FileName, "\", "\\", "all" ) />
    <cf_include files="/common_files/ag-Grid.cfm, /styles/reset2.css, /common_files/jQuery.cfm" />
   
   <!---cfscript>
       writeOutput( udf.compress
                    ('
                     --->
    <style>
        div.document {
            font-size:12px;
            display:flex;
            align-content: space-evenly;
            justify-content: space-around;
        }
        .headerCenter {
            text-align: center;
            font-size: 14px; 
            font-weight: bold; 
        }
        .center {
            text-align: center;
        }
        span[title]:hover::after {
            background-color: yellow;
        }
        span.error {
            color: red;
        }
        /* override ag-grid default height */
        div##ag_grid2 {
            height: calc( 100vh - 110px );
            width: 98%;
            margin: 10px 1%;
        }
        div.centered-div {
            padding: 10px;               /* Add padding around the text */
            border: 2px solid red;       /* Red border */
            text-align: center;          /* Center the text inside the div */
            font-size: 12px;             /* Adjust the font size */
            box-align: center;
            height: 100%;
            margin: 0 auto;
            justify-content: center;   /* Center the div horizontally */
            align-items: center;       /* Center the div vertically */
            width:200px;
        }
    </style>
<style>
    #masterContainer, div.masterContainer {
        margin-top: 7px;
        width: 1200px;
    }
    #headerContainer {
        width: 100%;
        background-color: #ffce84;
        font-size: 10px;
        border-bottom: thin solid #990000;
        padding: 3px;
        height: auto;
    }
#innerheaderContainer,
    #innerHeaderContainer {
        width: 106px;
        padding: 3px;
        font-family: Century Gothic;
        font-size: 10px;
        font-weight: bold;
        color: #000099;
        text-align: left;
        display: inline;
        vertical-align: top;
        float: left;
    }
    #innerheaderContainerSM,
    #innerHeaderContainerSM {
        width: 50px;
        padding: 5px 5px 5px 0;
        font-family: Century Gothic;
        font-size: 12px;
        font-weight: bold;
        color: #000099;
        display: inline;
        float: left;
    }
    #bodyContainer {
        width: 1200px;
        font-size: 10px;
    }
    #innerbodyContainer,
    #innerBodyContainer {
        width: 150px;
        padding: 3px;
        text-align: left;
        font-size: 10px;
        display: inline;
        float: left;
    }
    #innerBodyContainerSM {
        width: 50px;
        padding: 2px;
        font-size: 10px;
        display: inline;
        float: left;
    }
    .rowBg1 {
        background-color: #ffffff;
    }
    .rowBg2 {
        background-color: #eaffea;
    }
    #headerContainer:after,
    #bodyContainer:after,
    .sortSection:after {
        content: "";
        display: table;
        clear: both;
    }    
</style>
 
<cfoutput>
    <h2 class="headerCenter">Self Serve Detailed Status</h2>
    <div class="document">
        <span><b>Document Name:</b> #qgetUploadHistory.Upload_FileName#</span>
        <span><b>Uploaded On:</b> #Dateformat(qgetUploadHistory.Created_Date, 'medium')# @  #Timeformat(qgetUploadHistory.Created_Date, 'short')#</span>
        <span><b>Uploaded By:</b> #qgetUploadHistory.User_code# <br></span>
    </div>

<cfif (qgetUploadHistory.Process_Flag EQ 2)>
   <!---  /* Completed Successfully */ --->
    <cfset tblName = qgetLookupByID.Success_Report_Table_Name />
    <cfset clnList = qgetLookupByID.Success_Report_Display_Columns />
<cfelseif (qgetUploadHistory.Process_Flag EQ 3)>
    <!--- /* Failed */ ---> 
    <cfset tblName = qgetLookupByID.Failed_Report_Table_Name />
    <cfset clnList = qgetLookupByID.Failed_Report_Display_Columns />
<cfelse>
    <br><br>
    <div class="centered-div" style="align:center;">
        The batch is in process!!
    </div>
    <br>
    <div style="margin:0 auto;text-align: center;"><br><br>
        <button style="cursor:pointer;" class="button" onclick="window.close()"> Close </button>
    </div>
    <cfabort>
</cfif>
<cfquery name="qGetUploadDetailHistory" datasource="#application.datasource#" returntype="query">
        SELECT  #clnList#
        FROM #tblName#
        WHERE Self_Serve_Log_ID = #url.ssID#
</cfquery>
  <br>
     <table width="100%" border="0" cellpadding="1" cellspacing="0" class="MAINTABLE">
        <caption align="left"><hr color="Navy"><B><font size="14px" color="Navy">Detail Rows</font></B>&nbsp;<hr color="Navy"></caption>
        <tr id="HEADER" bgcolor="##FFCE84">
            <cfloop list="#clnList#" index="colName">
                <TD STYLE="font-size:12px;color:Navy;font-family:Century Gothic;font-weight: bold;height:22px;" valign="top"><strong>#trim(colName)#</b></TD>
            </cfloop>
        </tr>
        <cfloop query="qGetUploadDetailHistory">
           <tr> 
                <!--- Get the column names dynamically --->
                <cfloop list="#clnList#" index="colName">
                    <cfloop list="#qGetUploadDetailHistory.columnList#" index="column">    
                        <cfif (CompareNoCase(trim(colName), trim(column)) EQ 0 )>
                            <td <cfif currentrow mod 2>bgcolor="white"<cfelse>bgcolor="ccffcc"</cfif> style="height:22px;">#trim(qGetUploadDetailHistory[column][qGetUploadDetailHistory.currentRow])#</td>
                            <cfbreak>
                        </cfif>
                    </cfloop>
                </cfloop>
            </tr>
        </cfloop>
    </table>
<br><br>
        <div>
            <div class="center">
                <!--- button style="cursor:pointer" class="button recommended" onclick="downloadFile( ''#docFullName#'' )"> Download </button --->
                <button style="cursor:pointer" class="button" onclick="window.close()"> Close </button>
            </div>
        </div>
    </cfoutput> 

 
<cfinclude template="/common_files/focus2.cfm">
</body>
</html>
