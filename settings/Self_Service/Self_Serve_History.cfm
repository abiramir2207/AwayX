<!---
  * ====================================================================================================
  *    @File: AwayX\settings\Self_Service\Self_Serve_History.cfm
  *    @Author: Anand Rao
  *    @Date: 16 Sep 2024
  *
  *    @Remarks: Self Serve Upload History
  *
  * ====================================================================================================
--->
<!doctype html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
</head>
<body>
    <cfset request.agGrid2022 = 1>
    <cfset request.ag_grid_dense = 0>
    <cf_include files="/common_files/ag-Grid.cfm, /styles/reset2.css, /common_files/popup2022.cfm">
    

    <style>

        div.filter {
            margin: 7px;
            display: flex;
            gap: 1rem;
            align-items: center;
            display: none;
        }
        /* override ag-grid default height */
        div#ag_grid {
            height: calc( 100vh - 145px );
            margin: inherit;
            width: 95%;
        }

    </style>

	<cfoutput>

     <cfscript>
        /* Check if Business Segments are enabled */
        /* segment.cfc = new mvc.Models.Planner.PlannerManager();
        segment.enabled = segment.cfc.getSegmentFilter();
        */
        selfServeMgr = createObject("component","mvc.Models.Admin.SelfServe.SelfServeManager");
        final_destination = application.doc_path & "\Data_Files\Uploaded\settings\self_serve\";
     </cfscript>

    <button class="button" onclick="reloadGrid()" title="click to refresh data on this page">refresh data</button>

	<div id="ag_grid" class="ag-theme-balham ag-grid"></div>

    <cf_include files="/styles/css-loader.css, /common_files/jQuery.cfm">

	<script>
        'use strict';

        const grid = { id: "##ag_grid" };
        const final_destination = "#URLEncodedFormat( final_destination )#";
/*
ID
Category
Action
Rec Count
Error count
Success Count
Date
Status
Action By
FileName
*/
        <!--- ~~ define ag-grid configuration ~~ --->
        grid.ag = {         
                            defaultColDef: {     editable:        false
                                                ,resizable:       true
                                                ,suppressMenu:    true
                                                ,suppressMovable: true
                                                ,sortable:        true
                                                ,unSortIcon:      false
                                            }
                            ,columnDefs: [
                                           /* { headerName:"Fiscal Year", field:"Fiscal_Year", filter: 'agSetColumnFilter', floatingFilter: true, width:65 , resizable: true }

                                           ,{ headerName:"Customer Type", field:"Customer_Type", filter: 'agSetColumnFilter', floatingFilter: true, width:90 , resizable: true }
                                           ,{ headerName:"Volume Type", field:"Volume_Type", filter:"agSetColumnFilter", floatingFilter: true, width:75 , resizable: true }
                                            */


                                            ,{ headerName:"ID", field:"Self_Serve_Log_ID", filter:false, width:20, resizable: true  }
                                            ,{ headerName:"Category", field:"Category_Type", filter:false, width:70, resizable: true  }
                                            ,{ headerName:"Action", field:"Action_Type", filter:false, width:130, resizable: true  }
                                            ,{ headerName:"Rec Count", field:"Record_Count", filter:false, width:55, resizable: true  }
                                            ,{ headerName:"Error count", field:"Error_Count", filter:false, width:60, resizable: true  }
                                            ,{ headerName:"Success Count", field:"Success_Count", filter:false, width:75, resizable: true  }
                                            ,{ headerName:"Date", field:"Created_Date", filter:false, width:95, resizable: true  }
                                           /*  ,{ headerName:"Status", field:"Upload_Status", filter:false, width:130, resizable: true  } */
                                            ,{ headerName:"Action By", field:"User_Code", filter:false, width:80, resizable: true  }
                                            ,{ headerName:"FileName", field:"Upload_FileName", filter:false, width:120, resizable: true, tooltipField:"Upload_FileName"  }

                                             ,{ headerName:"Status", field:"Process_Flag", filter:false, width:120, resizable:true, 
                                                cellRenderer:(p)=>{
                                                        const element = document.createElement('span');
                                                        let buttonElem;
                                                        let statusMsg = "no message";
                                                          if (p.data.Process_Flag == 1){
                                                                statusMsg = "Processing";
                                                        }
                                                        else if (p.data.Process_Flag == 2){
                                                            statusMsg = "Completed Successfully";
                                                        }
                                                        else if (p.data.Process_Flag == 3){
                                                                statusMsg = "Failed";
                                                        }  
                                                    buttonElem = "<button class=button>" + statusMsg + "</button>";
                                                    element.innerHTML = buttonElem;
                                                    return element;
                                                }
                                            } 
					                        ,{ headerName:"File", field:"fnm", filter:false, width:75, resizable: true
                                                ,cellRenderer:(p)=>{
                                                    const element = document.createElement('span');
                                                    let buttonElem = "&nbsp;&nbsp;&nbsp;&nbsp;<span>no file</span> ";

                                                        if (!(p.data.File_Size == '' || p.data.File_Size == null)){
                                                            buttonElem = "<button class='button dnload'>Download</button>";
                                                        }        
                                                    element.innerHTML = buttonElem;
                                                    return element;
                                                }
                                            }
                                            /* ,{ headerName:"",
                                                field:"cancel",
                                                filter:false,
                                                width:60,
                                                resizable: true,
                                                cellRenderer: (p) => {
                                                    const element = document.createElement('span');
                                                    let buttonElem;
                                                    if(p.data.Status == "Validation Success"){
                                                        buttonElem =  "<button class='button cancel'>Cancel</button>";
                                                    }
                                                    else{
                                                        buttonElem = "";
                                                    }
                                                    element.innerHTML = buttonElem;
                                                    return element;
                                                }
                                            } */
                                           
                                        ]
                            ,onCellClicked:( p )=>  {
                                                        if(p.colDef.field == 'fnm') {
                                                                getDownload( p.data.Self_Serve_Log_ID,  p.data.Upload_FileName);
                                                        }
                                                        else if(p.colDef.field == 'cancel') {
                                                                cancelUpoad( p.data.Self_Serve_Log_ID);
                                                        }
                                                        else if ( p.colDef.headerName === "Status") {
                                                            popup2022( "Self_Serve_Detail.cfm?ssID=" + p.data.Self_Serve_Log_ID, "Self Serve Detail", "MD", "MD", "center" );
                                                        }
                                                    }
                            ,enableRangeSelection:      false
                            ,floatingFilter:            true
                            ,pagination:                false
                            ,rowModelType:              "clientSide"
                            ,rowSelection:              false
                            ,suppressContextMenu:       true
                            ,suppressRowClickSelection: true
                        };

    ag_grid_default( grid.ag );
    init_ag_grid( grid.ag, grid.id );
    $.ajax( {  
                url: "/mvc/Models/Admin/SelfServe/SelfServeManager.cfc"
                ,data: { method: "getUploadHistory"}
                ,error: function( xhr, status, error ) { error_handler( arguments ) }
                ,success: function( response ) {

                                                    grid.ag.api.setRowData(response);
                                                    grid.ag.api.sizeColumnsToFit();
                                                }
            } );

        function getDownload( id, fName ) {

             $.ajax( {
                    async: true
                    ,url: "/mvc/Models/Planner/PlannerVolumeUploadManager.cfc"
                    ,dataType: 'json'
                    ,data: {
                                plannerVolumeUploadID: id,
                                fileName: fName,
                                method: "getHistoryDownload"
                            }
                    ,error: function( xhr, status, error ) { error_handler( arguments ) }
                    ,success: function( response ) {
                                                        generate_export( "/GetDocument.cfm?FilePath=" + final_destination + fName + ".xlsx" );
                                                    }
                } );
        }

        function cancelUpoad( id ) {
            $.ajax( {
                    async: true
                    ,url: "/mvc/Models/Planner/PlannerVolumeUploadManager.cfc"
                    ,dataType: 'json'
                    ,data: {
                                plannerVolumeUploadID: id,
                                method: "cancelUpload"
                            }
                    ,error: function( xhr, status, error ) { error_handler( arguments ) }
                    ,success: function( response ) {
                                                        $.ajax( {
                                                                    url: "/mvc/Models/Planner/PlannerVolumeUploadManager.cfc",
                                                                    data: { method: "getUploadHistory"},
                                                                    error: function( xhr, status, error ) { error_handler( arguments ) },
                                                                    success: function( response ) {
                                                                                                    grid.ag.api.setRowData(response);
                                                                                                    grid.ag.api.sizeColumnsToFit();
                                                                    }
                                                        } );
                                                    }
                    });
        }
        function reloadGrid(){
            location.reload();
        }
	</script>
	</cfoutput>

    <cfinclude template="/common_files/focus2.cfm">
</body>
</html>
