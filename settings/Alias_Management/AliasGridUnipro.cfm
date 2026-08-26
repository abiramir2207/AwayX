<!---
  * ====================================================================================================
  *  @Author: Sharon Harris
  *  @Date: 24-Jan-2019
  *  Alias Management, configuring Grid for Unipro_450 source type
  *     Included as Template into AliasGridManager.cfm
  *     Unipro grids are different from all other source types, so handling is separated out into this file
  *
  *
  * ====================================================================================================
--->
<script>
    //------------------------------------------------------------------------------------------------------
    // Define UNIPRO-Specific Grid columns
    //------------------------------------------------------------------------------------------------------
    let c_u_aliasID =   { headerName:"DUN", field: "ALIASID", width: 50,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasRegion={ headerName:"Region", field: "ALIASREGION", width: 60,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasDesc = { headerName:"Name", field: "ALIASDESC", width: 100,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasAddress= { headerName:"Address", field: "ALIASADDRESS", width: 100,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasCity = { headerName:"City", field: "ALIASCITY", width: 60,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasState= { headerName:"State", field: "ALIASSTATE", width: 60,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasZip =  { headerName:"Zip", field: "ALIASZIP", width: 60,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasUniproNum =  { headerName:"Unipro Num", field: "ALIASUNIPRONUM", width: 60,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    let c_u_aliasLoc =  { headerName:"Loc", field: "ALIASLOC", width: 60,filter: 'agTextColumnFilter',filterParams:{filterOptions:['contains','startsWith','endsWith'],applyButton:true,suppressAndOrCondition:true,newRowsAction:'keep'}};
    
    //------------------------------------------------------------------------------------------------------
    // Define the Unipro Grid column Set
    //------------------------------------------------------------------------------------------------------
    // Unipro
    var UCols0 = /* distributor */
        [c_selectCol, c_u_aliasID, c_u_aliasRegion, c_u_aliasDesc, c_u_aliasAddress, c_u_aliasCity, c_u_aliasState, c_u_aliasZip, c_u_aliasUniproNum, c_u_aliasLoc, c_entityID, c_entityDesc, c_unknown];
    //------------------------------------------------------------------------------------------------------
    // Build the Unipro Grid for the tab requested
    //------------------------------------------------------------------------------------------------------
        function UniproBuildGridColsByID(tabIndex) {
        let cols = "UCols"+tabIndex;
        let countID = "#count"+tabIndex;
        GridOptions = buildGridCols(GridOptions, eval(cols), "#myAliasGrid", countID, tabIndex);
    }
</script>