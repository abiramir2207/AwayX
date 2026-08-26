<cfsilent>
    <!---
    * ====================================================================================================
    *    @File: Programs\product\Rate_Main_Grid.cfm
    *  @Author: Sharon Harris
    *    @Date: 03-Oct-2019
    *
    * @Remarks: Product Rate Main page Grid
    *
    * ====================================================================================================
    --->
    </cfsilent>

    <script>
    var fixed_name = "Fixed";
    var rebate_name = "Rebate";
    var price_header_name = "price";
    var fixed_type_id = 1;
    var rebate_type_id = 2;
    var fixed_cust_rate_type_id = 3;
    var selectedComponentStatus = 0;
    var payeeType = 0;
    var bFilterByRate = false;
    var bfilterByVarianceMP = false;
    var bfilterByMP = false;
    var bfilterByGroup = false;
    var bfilterByItem = false;
    var bfilterByProdStatus = false;
    var bfilterBySelectedRecords = false;
    var bfilterByNonePrtgrp = false;
    var uomList = [];
    var fmt_4_decimal_places = '(0,0.0000)'; // 4 decimal places
    var fmt_2_decimal_places = '(0,0.00)';	// 2 decimal places
    var fmt_no_decimal_places = '(0,0)'; // no decimal places
    var Rate_GridOptions = {};	// Global so can access API later
    var arrObjProducts = [];
    var arrObjComponentsDef = [];
    var arrObjSelectedComponent = [];
    var objProgram = {};
    var selectedDiscountType = 0;

    var columnDefs_ratesGrid = [
        {width:24, checkboxSelection:true, headerCheckboxSelection:true, headerCheckboxSelectionFilteredOnly:true, filter:false, resizable:false, suppressToolPanel:true, suppressMovable:true, sortable:false, pinned:"left", lockPosition:true,suppressNavigable: true},
        {headerName: "Item", suppressToolPanel:false, width:100, autoHeight: true,field: 'baItemDisplay',suppressNavigable: true},
        {headerName: "Description", suppressToolPanel:false, width:125, autoHeight: true ,field: 'Description',suppressNavigable: true},
        /* This column stores the "Price/MP rate" and is hidden. Whenever we add a component, we copy the data from here
        and add a new "Price" column for that component.
        Note:The product data loads on initial load, but we need to add the "Price" column per component. */
        {headerName: "Item UOM", suppressToolPanel:true, field: 'uomMP.uomId', hide:true},
        {headerName: "Market Price CS", suppressToolPanel:true, field: 'marketPriceCS', hide:true},
        {headerName: "Market Price LB", suppressToolPanel:true, field: 'marketPriceLB', hide:true}
    ]

    function Build_Rate_Grid() {
        Rate_GridOptions = {
            // blackSmith: { fullHeight: true, height_offset: -12 },
            blackSmith: { fullHeight: true, height_offset: -22 },
            columnDefs: columnDefs_ratesGrid
            ,floatingFilter: true
            ,rowData: arrObjProducts
            ,rowModelType: "clientSide"
            ,rowSelection: "multiple"
            ,suppressContextMenu: true
            ,enableBrowserTooltips: true
            ,isExternalFilterPresent: isExternalFilterPresent
            ,doesExternalFilterPass: showFilteredRecords
            ,getRowNodeId: function(data) { return data.itemGuid }
            ,defaultColDef:	{
                    editable:                      false
                    ,floatingFilterComponentParams: { suppressFilterButton: true }
                    ,singleClickEdit:				true
                    ,suppressMenu:                  true
                    ,suppressMovable:               false
                    ,unSortIcon:                    false
                    ,sortable:                      true
                    ,resizable:                     true
                    ,suppressToolPanel:				true	// Default to no show/hide col, override per column
                    ,filter:                        'agTextColumnFilter'
            }
            ,statusBar: footerbar("filtered_and_total")
            // ,stopEditingWhenGridLosesFocus: true
        };
        Rate_GridOptions.sideBar = { toolPanels: [
                {
                    id: 'columns',
                    labelDefault: 'Columns',
                    labelKey: 'columns',
                    iconKey: 'columns',
                    toolPanel: 'agColumnsToolPanel',
                    toolPanelParams: {
                        suppressColumnExpandAll: true,
                        suppressColumnFilter: true,
                        suppressColumnSelectAll: true,
                        suppressPivotMode: true,
                        suppressPivots: true,
                        suppressRowGroups: true,
                        suppressValues: true,
                    }
                }
            ]
        };

        ag_grid_default(Rate_GridOptions);		// set up default features
        init_ag_grid( Rate_GridOptions, "#Rate_Grid", false );   // false=setup as client side
    }

    function loadComponentData(discountType){
        /* Note: The loader is hidden at the end of"loadComponentDropDown"function, using "hide_loader" function. */
        show_loader("LOADING COMPONENT DROPDOWN, PLEASE WAIT...");
        let compDrpDown = "#cboCompName";

        /*It can take time for the dropdown data to be retrieved and so disable the "componennt" dropdown.
        We will enable it, once the dropdown gets populated in the "loadComponentDropDown" function.
        By disabling it, we can also prevent user selecting a wrong component. */
        $(compDrpDown).prop('disabled', true);

        $.ajax({
            url: "/mvc/models/Program/Component/ComponentDefManager.cfc"
            ,type: "POST"
            //,async: true
            ,dataType: "json"
            ,data: { method: "getComponentDefJSON"
                    ,programId: <cfoutput>'#url.programID#'</cfoutput>
                    ,bMarketPrice: 0
             }
            ,error: function(xhr, status, error) { hide_loader(); error_handler(arguments) }
            ,success: function( response ) {
                arrObjComponentsDef = response;
                selectedDiscountType = discountType;
                loadComponentDropDown();
            }
        });
    }

    function hide_loader() {
        $("div.loader").remove();
    }

    function loadRateData(){
        show_loader( "LOADING, PLEASE WAIT...");

        $.ajax({
            url: "/mvc/models/Item/ItemSearchService_Groups.cfc"
            ,type: "POST"
            ,dataType: "json"
            ,data: {
                ProgramId: <cfoutput>'#url.programID#'
                ,StatusFilterOn: #statusFilterOn#
                ,bAll:	1
                ,bMP:	0
                ,TemplateFiltersID:	#url.TemplateFiltersID#
            </cfoutput>
            ,method: "getAllItemsJSON"
            }
            ,error: function(xhr, status, error) { hide_loader(); error_handler(arguments) }
            ,success: function( response ) {
                $.ajax({
                    url: "/mvc/models/Program/ProgramManager.cfc"
                    ,type: "POST"
                    ,dataType: "json"
                    ,data: { ProgramId: <cfoutput>'#url.programID#'
                            ,bMarketPrice: 0
                    </cfoutput>
                    ,method: "getProgramJSON"
                    }
                    ,error: function(xhr, status, error) { $("div.loader").remove(); error_handler(arguments) }
                    ,success: function( responseProgram ) {
                        $("div.loader").remove();
                        /* add the product attribute columns */
                         responseProgram.arrPrdAttr.forEach(function(item){
                            columnDefs_ratesGrid.push({headerName: item.groupLevelDesc, field: item.productGroupAttributeNameField, suppressToolPanel:false, width:100,suppressNavigable:true,
                                // For these, filter via a list of choices
                                floatingFilterComponentParams: { suppressFilterButton: false },
                                /* "agSetColumnFilter" automatically adds the unique records on the column to the filter dropdown. */
                                filter: 'agSetColumnFilter',
                                filterParams: {cellHeight: 20}
                            })
                        });

                        /* Add the "volume" column */
                        columnDefs_ratesGrid.push({headerName:'Volume', field:'volume', editable:true, type:'numericColumn', width:70
                            ,cellClass: "editable"
                            ,filter:false
                            ,cellEditor:NumericCellEditor
                            ,cellEditorParams: { type: "integer" }
                            ,valueSetter: function(params) {
                                if (params.oldValue !== params.newValue) {
                                    params.data.volume = numberFormat(parseFloat(params.newValue),fmt_no_decimal_places);
                                    return true;
                                } else {
                                    return false;
                                }
                            }
                            ,onCellValueChanged: function(params) {
                                if(params.oldValue != params.newValue){
                                    updateVolume(params);
                                }
                            }
                        })

                        /* Create the grid */
                        Build_Rate_Grid();

                        arrObjProducts = response;

                        /* Add all the "item master" products to the grid.*/
                        Rate_GridOptions.api.setRowData(arrObjProducts);

                        setDefaultVolumeforAllProducts();

                        objProgram = responseProgram;

                        /* Based on which discount is ON on the template, show/hide discount types. */
                        hideShowDiscountTypes();

                        hideShowCADCurrencyOption();

                        if(objProgram.distributors.length == 0 && <cfoutput>#iMpId#</cfoutput> == 0){
                            alert('There are no Customers selected for this program. As a result, item prices (which are customer specific) are not available.');
                        }

                        /* Loop through the program components */
                        objProgram.components.forEach(function(item){
                                let bDistribututorRatesOn = false;
                                let bShowCustomPrintQuotes = false;

                                /* Check for "Distributor rates" feature */
                                bDistribututorRatesOn = getIsDistributorRatesOn(item);

                                /* Check for "Custom print" feature */
                                bShowCustomPrintQuotes = getIsCustomPrintOn(item);

                                /* Add components on the grid */
                                addComponent(item,'');

                                /* Loop through the product/component rates and populate the values for different columns on the grid */
                                item.prodRate.forEach(function(item1){
                                    let rowNode = Rate_GridOptions.api.getRowNode(item1.itemGuid);

                                    if(rowNode != undefined){

                                        /* In case "rateMP" does not exist in the prodrate, add to it. While saving data, we nedd thus value. */
                                        if(item1["rateMP"] == undefined){
                                            item1["rateMP"] = rowNode.data.marketPrice;
                                        }

                                        /* In case "rateMPOrig" does not exist in the prodrate, add to it. While saving data, we nedd thus value. */
                                        if(item1["rateMPOrig"] == undefined){
                                            item1["rateMPOrig"] = rowNode.data.rateMPOrig;
                                        }
                                        /* In case "rateMPCS" does not exist in the prodrate, add to it. While saving data, we nedd thus value. */
                                        if(item1["rateMPCS"] == undefined){
                                            item1["rateMPCS"] = rowNode.data.marketPriceCS;
                                        }

                                        /* In case "rateMPLB" does not exist in the prodrate, add to it. While saving data, we nedd thus value. */
                                        if(item1["rateMPLB"] == undefined){
                                            item1["rateMPLB"] = rowNode.data.marketPriceLB;
                                        }

                                        /* In case "rateMPCustom" does not exist in the prodrate, add to it. While working on this page, we need it. */
                                        if(item1["rateMPCustom"] == undefined){
                                            item1["rateMPCustom"] = 0; /* This does not get loaded from the db, but is needed to work on this page.*/
                                        }

                                        /* In case "customPrint" does not exist in the prodrate, add to it. While saving data, we nedd thus value. */
                                        if(item1["customPrint"] == undefined){
                                            item1["customPrint"] = new Object();
                                            item1["customPrint"].bCustomPrint = bShowCustomPrintQuotes;
                                        }

                                        rowNode.data['rate_'+item.type+'_'+item.componentId] = numberFormat(parseFloat(item1.rate),fmt_4_decimal_places);
                                        rowNode.data['uom_'+item.type+'_'+item.componentId] = item1.uom.uomId;
                                        rowNode.data['volume'] = numberFormat(parseFloat(item1.volume),fmt_no_decimal_places);

                                        let rateMPCS = numberFormat(parseFloat(rowNode.data.marketPriceCS),fmt_4_decimal_places);
                                        let rateMPLB =numberFormat(parseFloat(rowNode.data.marketPriceLB),fmt_4_decimal_places);

                                        /* If the UOM is "LB" */
                                        if(item1.uom.uomId == 2){
                                            rowNode.data['marketPrice_'+item.type+'_'+item.componentId] = rateMPLB;
                                        }
                                        else{
                                            rowNode.data['marketPrice_'+item.type+'_'+item.componentId] = rateMPCS;
                                        }

                                        /* fixed price */
                                        if(item.type == fixed_type_id){
                                            /* If the UOM is "LB" */
                                            if(item1.uom.uomId == 2 && rateMPLB != 0){
                                                rowNode.data['varianceMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat(rateMPLB - item1.rate),fmt_4_decimal_places);
                                                rowNode.data['variancePercMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat((((rateMPLB - item1.rate)/rateMPLB) * 100)),fmt_2_decimal_places);
                                            }
                                            /* If the UOM is "CS" */
                                            else if(item1.uom.uomId == 1 && rateMPCS != 0){
                                                rowNode.data['varianceMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat(rateMPCS - item1.rate),fmt_4_decimal_places);
                                                rowNode.data['variancePercMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat((((rateMPCS - item1.rate)/rateMPCS) * 100)),fmt_2_decimal_places);
                                            }
                                        }
                                        /* rebate */
                                        else if(item.type == rebate_type_id){
                                            /* If the UOM is "Percent" */
                                            if(item1.uom.uomId == 3 && rateMPCS != 0){
                                                rowNode.data['varianceMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat((rateMPCS * (item1.rate/100))),fmt_4_decimal_places);
                                                rowNode.data['variancePercMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat(item1.rate),fmt_4_decimal_places);
                                            }
                                            else{
                                                /* If the UOM is "LB" */
                                                if(item1.uom.uomId == 2 && rateMPLB != 0){
                                                    rowNode.data['varianceMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat(item1.rate),fmt_4_decimal_places);
                                                    rowNode.data['variancePercMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat((((item1.rate)/rateMPLB) * 100)),fmt_2_decimal_places);
                                                }
                                                /* If the UOM is "CS" */
                                                else if(item1.uom.uomId == 1 && rateMPCS != 0){
                                                    rowNode.data['varianceMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat(item1.rate),fmt_4_decimal_places);
                                                    rowNode.data['variancePercMP_'+item.type+'_'+item.componentId] = numberFormat(parseFloat((((item1.rate)/rateMPCS) * 100)),fmt_2_decimal_places);
                                                }
                                            }
                                        }

                                        /* Loop through the distributors and set the column's value */
                                        if(bDistribututorRatesOn == true){
                                            objProgram.distributors.forEach(function(itemDistributors){
                                                rowNode.data['rateCust_'+item.type+'_'+item.componentId +'_' + itemDistributors.shipTo] = numberFormat(parseFloat(item1['rateCust_'+ itemDistributors.shipTo]),fmt_4_decimal_places);
                                            });
                                        }
                                    }
                                });

                                /* Custom print -
                                Note: Below function will call data from the server - It will get "custom print" data for all products
                                for which the "custom print" data exists. "arrItems" below is to get data for specific items only and so
                                we send a blank array. */
                                if(bShowCustomPrintQuotes == true){
                                    item.customPrint.bCustomPrint = true;
                                    let arrItems = [];

                                    /* Here the assumption is that the selected component (dropdown) is the one for which the
                                    print data (custom print) is being retrieved. Reason - Client (IP) only adds one component
                                    to the "Custom print" programs, i.e. where a component has been added, which has "Custom print" feature ON. */
                                    getCustomPrintData(
                                        item.type,
                                        item.componentId,
                                        item.customPrint,
                                        arrItems
                                    );
                                }
                        });

                        Rate_GridOptions.api.refreshCells();

                        /* Hide the "LOADING, PLEASE WAIT..." message */
                        hide_loader();

                        /* (START) - Load the "component" dropdown. If we add below code above the 'bjProgram.components" loop, then the
                        "show_loader" does not work properly, because we have hide_loder being called which hides the "show_loader".
                        "hide_loder" gets called inside the "loadComponentDropDown" function. */
                        if(objProgram.components.length){
                            /* Pass the discount type of the first component on the program.
                            By default (provided there is at least one component on the program),
                            that discount type's component list will be populated on the component dropdown. */
                            selectedDiscountType = objProgram.components[0].type;

                            /* Check either the rebate or fixed price radio button */
                            if(selectedDiscountType == fixed_type_id){
                                $("#FIXED_TYPE_ID").attr('checked', true);
                            }
                            else if(selectedDiscountType == rebate_type_id){
                                $("#REBATE_TYPE_ID").attr('checked', true);
                            }

                            /* Get the component data for the component dropdown */
                            loadComponentData(selectedDiscountType);

                            /* Once all the component's get loaded on the grid, the component dropdown will
                            have one of them selected. Make that the first one on the grid. */
                            arrObjSelectedComponent = objProgram.components[0].componentDef;
                        }
                        /* (END) - Load the "component" dropdown.  */

                        /* Filter on initial load */
                        filterOnLoad();
                    }
                });
            }
        });

    }

    function loadComponentDropDown(){
        let compDrpDown = "#cboCompName";
        $(compDrpDown + " option").remove();//clear all the options

        /* Add the component entries to the "component" dropdown. */
        for(var i= 0; i< arrObjComponentsDef.length; i++){
            /* Only load those entries which belong to the selected discount type (radio button) */
            if(selectedDiscountType == arrObjComponentsDef[i].type){
                $(compDrpDown).append('<option value="' + arrObjComponentsDef[i].componentId + '">' + arrObjComponentsDef[i].name + "</option>'");
            }
        }

        /*  When a user changes the discount type by switching between the "discount type" radio buttons, loop though the existing
        program components to find the first component which matches the entire component list, for that particular discount type.
        Set the selected component (arrObjSelectedComponent) to the first one found. */
        let breakloop = 0;

        for(var i= 0; i< arrObjComponentsDef.length; i++){
            for(var j= 0; j< objProgram.components.length; j++){
                if(objProgram.components[j].type == selectedDiscountType){
                    if(objProgram.components[j].componentId == arrObjComponentsDef[i].componentId){
                        arrObjSelectedComponent = arrObjComponentsDef[i];
                        breakloop = 1;
                        break;
                    };
                }
            }
            /* Break out of the outer loop as well */
            if(breakloop == 1){
                break;
            }
        }

        /* If no component has been added to the program, then set the selected component to be the first one on the dropdown.*/
        if(breakloop == 0){
            for(var i= 0; i< arrObjComponentsDef.length; i++){
                if(arrObjComponentsDef[i].type == selectedDiscountType){
                    arrObjSelectedComponent = arrObjComponentsDef[i];
                    break;
                }
            }
            arrObjSelectedComponent = (typeof arrObjSelectedComponent.length !== 'undefined') ? arrObjSelectedComponent : arrObjComponentsDef[0];
        }

        $(compDrpDown).prop('disabled', false);

        /* Below code is useful when the page loads for the first time and the component dropdown selected option is the first component on the grid */
        $('#cboCompName').val(arrObjSelectedComponent.componentId);

        loadComponentAttributeDropDowns();

        /* Fire the change event, so that next steps can be taken. */
        $('#cboCompName').change();

        hide_loader();
    }

    $('#cboCompName').change(function(){
        callSelectedComponentDef($('#cboCompName').val());
    });

    function callSelectedComponentDef(selectedComponentID){
        setSelectedComponentDef(selectedComponentID);
        loadComponentAttributeDropDowns();
        enableDisableMassApplyOptions();
        checkComponentStatus();
        hideShowFilterOptions();
        loadMassApplyOptionsDropdown();
        setPaidToIdx();
        setPaymentCycleIdx();
        setClaimMechanicIdx();
        setGlAccountIdx();
        hideShowCustomPrintOptions();
        hideShowDistributorDropdown();
    }

    /* Whatever option was selected from the "Components" dropdown, becomes the "arrObjSelectedComponent" */
    function setSelectedComponentDef(componentId){
        for(var i= 0; i< arrObjComponentsDef.length; i++){
            if(selectedDiscountType == arrObjComponentsDef[i].type && componentId == arrObjComponentsDef[i].componentId){
                arrObjSelectedComponent = arrObjComponentsDef[i];
                break;
            }
        }
    }

    /* Gets called when user clicks on "Add", to add a new component. */
    function addNewComponent(Objcomp){
        let payCyc = Objcomp.paymentCycle[0];
        let pdTo = Objcomp.paidTo[0];

        //set default PaymentCycle (from template if there is one)
        for(var i= 0; i< Objcomp.paymentCycle.length; i++){
            if(Objcomp.paymentCycle[i].bDefault){
                payCyc = Objcomp.paymentCycle[i];
                break;
            }
        }

        //set default paid to (from template if there is one)
        for(var i= 0; i< Objcomp.paidTo.length; i++){
            if(Objcomp.paidTo[i].bDefault){
                pdTo = Objcomp.paidTo[i];
                break;
            }
        }

        let	comp = new Object();
        comp.bMarketPriceTemplate = objProgram.bMarketPriceTemplate;
        comp.name = Objcomp.name;
        comp.componentId = Objcomp.componentId;
        comp.claimMechanic = Objcomp.claimMechanic[0];
        comp.paidTo = pdTo;
        comp.paymentCycle = payCyc;
        comp.glAccount = Objcomp.glAccount[0];
        comp.fixedType = Objcomp.fixedType;
        comp.uom = Objcomp.uom;
        comp.type = Objcomp.type;

        comp.payee = new Object();
        comp.payee.payeeTypeId = 0;
        comp.payee.name = '';
        comp.payee.payeeId = '';
        comp.payee.address = '';

        comp.customPrint = new Object();
        comp.customPrint.bCustomPrint = getIsCustomPrintOn(comp);

        /* When a saved cinponent data is loaded from the db, "componentDef" is a part of it.
        Making sure that "componentDef" is a part of a new component added to the program.
        This is usefult to avoid an error while saving. It may be useful in other cases as well. */
        comp.componentDef = new Object();
        comp.componentDef = Objcomp;

        addComponent(comp,'add')
    }

    /* This gets called currently from two places -
        1. While adding a new component (user clicks on "Add" to add a new component_
        2. When existing components in the db, need to be displayed */
    function addComponent(comp,action){
        let compDrpDown = "#cboCompName";
        let selectedOptionValueName = $(compDrpDown + " option:selected").text();
        let bDistribututorRatesOn = false;
        let bShowCustomPrintQuotes = false;

        if(comp.bMarketPriceTemplate == true){
            price_header_name = 'MP rate';
        }

        /* Check for "Distributor rates" feature */
        bDistribututorRatesOn = getIsDistributorRatesOn(comp);

        /* Check for "Custom print" feature */
        bShowCustomPrintQuotes = getIsCustomPrintOn(comp);

        diacountName = getDiscountName(comp.type);

        columnDefs_ratesGrid.push({headerName: diacountName + "-" + comp.name
            ,suppressToolPanel:true
            ,headerGroupComponent: CutHeaderGroup
            ,headerGroupComponentParams: {
                title: "Remove this Component",
                discountTypeID: comp.type,
                compID: comp.componentId
            }
        ,children:
            [	{headerName: "rate", field: 'rate_'+comp.type+'_'+comp.componentId, editable:true, width:70
                    ,cellClass: "editable"
                    ,type:'numericColumn'
                    ,filter:false
                    ,cellEditor:NumericCellEditor
                    ,cellEditorParams: {
                        min: "0",
                        // max: "1000",
                        step: "0.0001"	// valid decimal places
                    }
                    ,valueSetter: function(params) {
                        if (params.oldValue !== params.newValue) {
                            let rateColumn = 'rate_'+ comp.type+'_'+comp.componentId;
                            params.data[rateColumn] = numberFormat(parseFloat(params.newValue),fmt_4_decimal_places)
                            return true;
                        } else {
                            return false;
                        }
                    }
                    ,onCellValueChanged: function(params) {
                        if(params.oldValue != params.newValue){
                            let uniqueColumnID = comp.type+'_'+comp.componentId;
                            setVarianceAndDiscountValue(comp.type,params.data,'varianceMP_'+uniqueColumnID, 'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);
                            updateRate(comp.type,comp.componentId,params);
                            /* While entring a rate. in case the user tabs from rate to UOM, below code (selectedUomIdx and updateUOM) is not needed , but in case the
                            user enters a rate and does not tab to the UOM column, then below code is needed to populate the UOM column.
                            "selectedUomIdx" populates the UOM column and "updateUOM" updates the program object, as that is what is sent to the server. */
                            selectedUomIdx(params,comp);
                            updateUOM(comp.type,comp.componentId,params.data.itemGuid,params.data['uom_'+uniqueColumnID]);
                        }
                    }
                }
            ]
        });

        /* Since we need to use conditonal logic before adding these columns, we could not add below
        columns directly in the "children" array above. */
        columnDefs_ratesGrid.forEach(function(itemCol){
            if(itemCol.hasOwnProperty("children")){
                /* First child column is "rate". Just verifying that these children are part of the component, since
                we do not want to add the "shipTo" columns for headers which are not a program component. */
                if(itemCol.children[0].headerName == "rate"){
                    /*  The digits(s) after the last underscore "_" is the component ID.
                    We are looking for index of 2 because the field is in the following format:
                    "rate_discountID_ComponentID" So, the last index will be 2 in this case. */
                    let compid = itemCol.children[0].field.split('_')[2];

                    /* Find the correct component. */
                    if(compid == comp.componentId){
                        if(action == 'add'){
                            itemCol.children.push(
                                {headerName: "uom", field: 'uom_'+comp.type+'_'+comp.componentId, editable:true, width:50
                                    ,cellClass: "editable"
                                    ,filter:false
                                    ,cellRenderer: newUOMCellRenderer
                                    ,cellEditor: 'agRichSelectCellEditor'
                                    ,cellEditorParams: {
                                        cellRenderer: newUOMCellRenderer
                                        ,values: getUOMList(arrObjComponentsDef,comp.type)
                                    }
                                    ,cellClass:'drop-down-arrow'
                                    ,onCellValueChanged: function(params) {
                                        setMarketPriceBasedOnUOM(params);
                                        let uniqueColumnID = comp.type+'_'+comp.componentId;
                                        /* In case UOM is blank, function "selectedUomIdx" will set the default UOM.
                                        Note: it is important to set UOM here using function selectedUomIdx.
                                        When "setVarianceAndDiscountValue" is fired, the correct UOM selected value is passed to the function. */
                                        selectedUomIdx(params,comp);
                                        setVarianceAndDiscountValue(comp.type,params.data,'varianceMP_'+uniqueColumnID, 'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);
                                        /* Sometimes, for some reason, "params.newValue" does not exist
                                        and that is why the updated value (params.data['uom_'+uniqueColumnID]) is being passed */
                                        updateUOM(comp.type,comp.componentId,params,params.data['uom_'+uniqueColumnID]);
                                    }
                                }
                            );
                        }
                        else{
                            itemCol.children.push(
                                {headerName: "uom", field: 'uom_'+comp.type+'_'+comp.componentId, editable:true, width:50
                                    ,cellClass: "editable"
                                    ,filter:false
                                    ,cellRenderer: existingUOMCellRenderer
                                    ,cellEditor: 'agRichSelectCellEditor'
                                    ,cellEditorParams: {
                                        cellRenderer: existingUOMCellRenderer
                                        ,values:	getUOMList(objProgram.components,comp.type)
                                    }
                                    ,cellClass:'drop-down-arrow'
                                    ,onCellValueChanged: function(params) {
                                        setMarketPriceBasedOnUOM(params);
                                        let uniqueColumnID = comp.type+'_'+comp.componentId;
                                        /* In case UOM is blank, function "selectedUomIdx" will set the defalt UOM.
                                        Note: it is important to set UOM here using function selectedUomIdx.
                                        When "setVarianceAndDiscountValue" is fired, the correct UOM selected value is passed to the function. */
                                        selectedUomIdx(params,comp);
                                        setVarianceAndDiscountValue(comp.type,params.data,'varianceMP_'+uniqueColumnID, 'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);
                                        /* Sometimes, for some reason, "params.newValue" does not exist
                                        and that is why the updated value (params.data['uom_'+uniqueColumnID]) is being passed */
                                        updateUOM(comp.type,comp.componentId,params,params.data['uom_'+uniqueColumnID]);
                                    }
                                }
                            );
                        }
                        if(objProgram.bHasConversionFactor){
                            itemCol.children.push(
                                {headerName: <cfoutput>"#GetCurrency.Currency_Code#"</cfoutput>, field: 'rateConverted_'+comp.type+'_'+comp.componentId
                                    ,editable:false,type:'numericColumn',width:70,hide:true,filter:false,suppressNavigable:true
                                    ,cellEditor:NumericCellEditor
                                    ,cellRenderer: function(params){
                                        let uniqueColumnID = comp.type+'_'+comp.componentId;
                                        let val = params.data['rate_'+uniqueColumnID] * objProgram.conversionFactor;
                                        let fmtVal = numberFormat(parseFloat(val),fmt_4_decimal_places);
                                        return fmtVal;
                                    }
                                }
                            );
                        }
                        if(bDistribututorRatesOn == true){
                            /* Loop through the distributors */
                            objProgram.distributors.forEach(function(itemDistributors){
                                let shipToColumnFound = 0;

                                for(var i= 0; i< itemCol.children.length; i++){
                                    if(itemCol.children[i].headerName == itemDistributors.shipTo){
                                        shipToColumnFound = 1;
                                        break;
                                    }
                                }
                                /* Add the ship to columns for distributors on the program. */
                                if(shipToColumnFound == 0){
                                    const UNDEFINED = "undefined";
                                    let tool_tip = [
                                                         (typeof itemDistributors.name === UNDEFINED) ? '' : itemDistributors.name
                                                        ,(typeof itemDistributors.address.addressLine1 === UNDEFINED) ? '' : itemDistributors.address.addressLine1
                                                        ,(typeof itemDistributors.address.city === UNDEFINED) ? '' : itemDistributors.address.city + ", "
                                                                                                                     + (typeof itemDistributors.address.state === UNDEFINED)
                                                                                                                            ? '' : itemDistributors.address.state + " "
                                                                                                                     + (typeof itemDistributors.address.zipCode === UNDEFINED)
                                                                                                                            ? '' : itemDistributors.address.zipCode
                                                    ];
                                    itemCol.children.push(
                                        {headerName: itemDistributors.shipTo, field: 'rateCust_'+comp.type+'_'+comp.componentId +'_' + itemDistributors.shipTo, editable:true, filter:false, width:75
                                            ,cellClass: "editable"
                                            ,cellEditor:NumericCellEditor
                                            ,onCellValueChanged: function(params) {
                                                updateDistRate(comp.type,comp.componentId,params,itemDistributors.shipTo);
                                            }
                                            ,headerTooltip: tool_tip.join("\n")
                                        }
                                    );
                                    if(objProgram.bHasConversionFactor){
                                        itemCol.children.push(
                                            {headerName: <cfoutput>"#GetCurrency.Currency_Code#"</cfoutput>, field: 'rateCustConverted_'+comp.type+'_'+comp.componentId +'_' + itemDistributors.shipTo
                                                ,editable:false, filter:false, type:'numericColumn', width:70, hide:true,suppressNavigable:true
                                                ,cellEditor:NumericCellEditor
                                                ,cellRenderer: function(params){
                                                    let uniqueDistColumnID = comp.type+'_'+comp.componentId +'_' + itemDistributors.shipTo;
                                                    let val = params.data['rateCust_'+uniqueDistColumnID] * objProgram.conversionFactor;
                                                    let fmtVal = numberFormat(parseFloat(val),fmt_4_decimal_places);
                                                    return fmtVal;
                                                }
                                            }
                                        );
                                    }
                                }
                            });
                        }

                        let priceHeaderColumnFound = 0;
                        let varianceColumnFound = 0;
                        let discountPercentColumnFound = 0;
                        let printColumsFound = 0;

                        for(var i= 0; i< itemCol.children.length; i++){
                            if(itemCol.children[i].headerName == price_header_name){
                                priceHeaderColumnFound = 1;
                                break;
                            }
                        }

                        for(var i= 0; i< itemCol.children.length; i++){
                            if(itemCol.children[i].headerName == "variance"){
                                varianceColumnFound = 1;
                                break;
                            }
                        }

                        for(var i= 0; i< itemCol.children.length; i++){
                            if(itemCol.children[i].headerName == "disc %"){
                                discountPercentColumnFound = 1;
                                break;
                            }
                        }

                        for(var i= 0; i< itemCol.children.length; i++){
                            if(itemCol.children[i].headerName == "print options"){
                                printColumsFound = 1;
                                break;
                            }
                        }

                        /* Add "price/market rate" column */
                        if(priceHeaderColumnFound == 0){
                            itemCol.children.push({headerName: price_header_name, field: 'marketPrice_'+comp.type+'_'+comp.componentId, editable:false, type:'numericColumn', cellEditor:NumericCellEditor, filter:false, width:50,suppressNavigable:true});
                        }
                        /* Add "variance" column */
                        if(varianceColumnFound == 0 && comp.type == fixed_type_id && comp.bMarketPriceTemplate){
                            itemCol.children.push({headerName: "variance",field: 'varianceMP_'+comp.type+'_'+comp.componentId, editable:false, type:'numericColumn', cellEditor:NumericCellEditor, filter:false, width:50,suppressNavigable:true});
                        }
                        /* Add "disc %" column */
                        if(discountPercentColumnFound == 0){
                            itemCol.children.push({headerName: 'disc %', field: 'variancePercMP_'+comp.type+'_'+comp.componentId, editable:false, type:'numericColumn', cellEditor:NumericCellEditor, filter:false, width:50,suppressNavigable:true});
                        }

                        /* Add "print options" and "mkRdy+plate+prePress=min" columns */
                        /* Note - Lokks like when "bShowCustomPrintQuotes" is ON (feature which IP uses), only one component exists on the program and that
                        is how it should be. */
                        if(printColumsFound == 0){
                            if(bShowCustomPrintQuotes == true){
                                itemCol.children.push(
                                    {headerName: 'print options', field: 'customPrint_'+comp.type+'_'+comp.componentId, editable:false,filter:false,suppressNavigable:true}
                                );
                                itemCol.children.push(
                                    {headerName: 'mkRdy+plate+prePress=min', field: 'customPrintCharge_'+comp.type+'_'+comp.componentId, editable:false,filter:false,suppressNavigable:true}
                                );
                            }
                        }
                    }//Find the correct component (end)
                }
            }
        });

        Rate_GridOptions.api.setColumnDefs(columnDefs_ratesGrid);

        setMarketPriceForAllProducts(comp,comp.type);

        /* For new component */
        if(action == 'add'){
            objProgram.components.push(comp);
            checkComponentStatus();
        }
    }

    /* This function copies the "MP Rate" column data to the newly added component, based on UOM. */
    function setMarketPriceForAllProducts(selectedComponent,discountType){
        /* "node.setValue" is slow. Using "rowNode.data" to update data. */
        arrObjProducts.forEach(function(item){
            let rowNode = Rate_GridOptions.api.getRowNode(item.itemGuid);

            if(item.uomMP.uomId == 2){
                rowNode.data['marketPrice_'+discountType+'_'+selectedComponent.componentId] = numberFormat(parseFloat(item['marketPriceLB']),fmt_4_decimal_places);
            }
            else{
                rowNode.data['marketPrice_'+discountType+'_'+selectedComponent.componentId] = numberFormat(parseFloat(item['marketPriceCS']),fmt_4_decimal_places);
            }
        });
        Rate_GridOptions.api.refreshCells();
    }

    function setDefaultVolumeforAllProducts(){
        /* "node.setValue" is slow. Using "rowNode.data" to update data. */
        arrObjProducts.forEach(function(item){
            let rowNode = Rate_GridOptions.api.getRowNode(item.itemGuid);
            let volumeValue = rowNode.data['volume'];

            /* Where there is no volume. */
            if(volumeValue == undefined){
                rowNode.data['volume'] = 1;
            }
        });
    }

    function setDefaultPrintOptionsAndChargesforProducts(discountType,componentID){
        /* "node.setValue" is slow. Using "rowNode.data" to update data. */
        arrObjProducts.forEach(function(item){
            let rowNode = Rate_GridOptions.api.getRowNode(item.itemGuid);
            let emptyPrintObject =  new Object();
            let objEmptyPrintDisplay = printDisplay(emptyPrintObject);

            let printOptions = rowNode.data['customPrint_'+discountType+'_'+componentID];

            /* Where the "print options" data is not set. */
            if(printOptions == undefined){
                rowNode.data['customPrint_'+discountType+'_'+componentID] = objEmptyPrintDisplay.printOptionsDisplay;
                rowNode.data['customPrintCharge_'+discountType+'_'+componentID] = objEmptyPrintDisplay.printChargesDisplay;
            }
        });

        Rate_GridOptions.api.refreshCells();
    }

    /* When a user changes the UOM, then the market price value based on UOM is set. */
    function setMarketPriceBasedOnUOM(params){
        let arrColName = params.colDef.field.split('_');

        /* arrColName[1] is the discount type id and arrColName[2] is the component id. */
        let id = 'marketPrice_'+arrColName[1] + '_' + +arrColName[2];

        if(params.newValue == 2){
            params.node.data[id] = numberFormat(parseFloat(params.node.data.marketPriceLB),fmt_4_decimal_places);
            params.node.data['marketPrice'] = numberFormat(parseFloat(params.node.data.marketPriceLB),fmt_4_decimal_places);
        }
        else{
            params.node.data[id] = numberFormat(parseFloat(params.node.data.marketPriceCS),fmt_4_decimal_places);
            params.node.data['marketPrice'] = numberFormat(parseFloat(params.node.data.marketPriceCS),fmt_4_decimal_places);
        }
        Rate_GridOptions.api.refreshCells(params);

        updateMarketPrice(arrColName[1],arrColName[2],params.data.itemGuid,params.node.data['marketPrice']);
    }

    /* "rateMP" in prodRate are used while saving data. It is important to update these values. */
    function updateMarketPrice(discountType,componentID,itemID,updatedMarketPrice){

        objProgram.components.some(function(item){
            /* Find the component passed to this function in "objProgram.components", based
                on discountType and componentID passed to this function. */
            if(item.prodRate !== undefined && item.type == discountType && item.componentId == componentID){
                item.prodRate.some(function(item1){
                    if(itemID == item1.itemGuid){
                        /* Updatimg "rateMP" is needed for save, as this value gets inserted as "market price"
                        for the record in the "Program_Fixed_Price_Product_Data" table */
                        item1.rateMP = updatedMarketPrice;
                        return true; /* exit the "prodRate" loop */
                    }
                });
            }
        });
    }

    /* Remove component from the grid */
    function deleteComponent(discountTypeID,compID){
        columnDefs_ratesGrid.forEach(function(item,index){
            /* Find the correct component */
            if(item.children){
                if(item.children[0].field == 'rate_'+discountTypeID+'_'+compID){
                    columnDefs_ratesGrid.splice(index,1);
                }
            }
        });
        Rate_GridOptions.api.setColumnDefs(columnDefs_ratesGrid);

        /* Remove component from "objProgram.components" */
        objProgram.components.forEach(function(item,index){
            if(item.type == discountTypeID && item.componentId == compID){
                objProgram.components.splice(index,1);
            }
        });

        checkComponentStatus();
    }

    /* We are using "arrObjSelectedComponent" here, because "mass apply" feature work only for the selected component. */
    function massApplyRatesAndUOM(){
        let tiRate = Number($("#tiRate").val());
        let cboUom = $('select[name=cboUom] option:selected').val();
        let applyRateOption = $('select[name=apply_rdoUomActionGrp] option:selected').val();
        let arrSelectedRecords = Rate_GridOptions.api.getSelectedRows();
        let uniqueColumnID;
        addProdRateObjForNewCompAndItemCombination(arrSelectedRecords);


        /* Loop through the selected records and do the following -
        a) update the "objProgram.components" object with the updated rate and/or UOM.
        b) update the grid  with the updated rate and/or UOM. */
        arrSelectedRecords.forEach(function(item){
            objProgram.components.forEach(function(item1){
                item1.prodRate.forEach(function(item2){
                    if(item.itemGuid == item2.itemGuid){
                        let rowNode = Rate_GridOptions.api.getRowNode(item.itemGuid);
                        if(item1.componentId == arrObjSelectedComponent.componentId && item1.type == arrObjSelectedComponent.type){

                            uniqueColumnID = item1.type+'_'+item1.componentId;
                            if(applyRateOption == '0' || applyRateOption == ''){ /* "abs" selection or no selection */
                                /* In cases where the user only wants to apply UOM and not rate, then in that case,
                                " applyRateOption == '0' and tiRate != '' " logic will be useful. */
                                if(applyRateOption == '0'){/* abs */
                                    if($('#tiRate').val().length != ''){
                                        item2.rate = tiRate;
                                    }

                                }
                                item1.uom.some(function(itemUOM){
                                    if(itemUOM.uomId == cboUom){
                                        item2.uom = itemUOM;
                                    }
                                });
                            }
                            else if(applyRateOption == '1'){ /* inc */
                                item2.rate = Number(item2.rate) + tiRate;
                            }
                            else if(applyRateOption == '2'){ /* % chg */
                                item2.rate = Number(item2.rate) + ((Number(item2.rate) * tiRate) / 100);
                            }
                            else if(applyRateOption == '3'){ /* % price chg */
                                if(selectedDiscountType == rebate_type_id){
                                    item2.rate = Number(item.marketPrice) - (Number(item.marketPrice) + ((Number(item.marketPrice) * tiRate) / 100));
                                }
                                else{
                                    item2.rate =  Number(item.marketPrice) + ((Number(item.marketPrice) * tiRate) / 100);
                                }
                            }
                            else if(applyRateOption == '4'){ /* inc price chg */
                                if(selectedDiscountType == rebate_type_id){
                                    item2.rate = (Number(item.marketPrice) + tiRate) - Number(item.marketPrice);
                                }
                                else{
                                    item2.rate =  Number(item.marketPrice) + tiRate;
                                }
                            }
                            else if(applyRateOption == '5'){ /* eq price rate */
                                item2.rate = Number(item.marketPrice);
                            }

                            rowNode.data['rate_'+uniqueColumnID] = item2.rate;


                            if(objProgram.bHasConversionFactor){
                                let newRate = item2.rate * objProgram.conversionFactor;
                                let fmtNewRate = numberFormat(parseFloat(newRate),fmt_4_decimal_places);

                                item2.rateConverted = fmtNewRate;
                                rowNode.data['rateConverted_'+uniqueColumnID] = fmtNewRate;
                            }

                            /* For mass apply, we can apply UOM only for the "Abs" option ("applyRateOption == '0' ").
                            "applyRateOption == '' when the default (no option) option is selected. That can be used
                            to just apply UOM, even if rate does not need to be applied. */
                            if(applyRateOption == '0' || applyRateOption == ''){
                                rowNode.data['uom_'+uniqueColumnID] = item2.uom.uomId;
                            }
                            /* For options other than "Abs", we will set the default UOM, if the UOM is not already set. */
                            else{
                                let colUOM = rowNode.data['uom_'+uniqueColumnID];
                                if(colUOM == undefined){
                                    colUOM = selectedUomIdx(rowNode,item1);
                                }
                                /* When the user selects the "Abs" option, there is code above in this function to update the UOM object in
                                "objProgram.components", but in this case we are setting the default UOM. Below code takes care of updating the
                                 UOM object in "objProgram.components" */

                                item1.uom.some(function(itemUOM){
                                    if(itemUOM.uomId == rowNode.data['uom_'+uniqueColumnID]){
                                        item2.uom = itemUOM;
                                    }
                                });
                            }
                            /* Call this function manually. If we would have used "setRowData", instead of "rowNode.data", then the "onCellValueChanged"
                            function would be automatically called and below function does not need to be called manually. We canot use "setRowData",
                            as it is very slow, when we are dealing with a lot of records. */
                            setVarianceAndDiscountValue(selectedDiscountType,rowNode.data,'varianceMP_'+uniqueColumnID, 'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);

                            /* NOTE: Do not call the "updateUOM" OR "updateRate" function from here. The "objProgram.components"
                            has already been updated in this function and so there is no need. In fact calling the "updateUOM"
                            from here will cause issues in the UOM object of "objProgram.components". */
                        }
                    }
                });
            });
        });
        Rate_GridOptions.api.refreshCells();
    }

    function addProdRate(objItem){
        objProgram.components.some(function(item){
            /* Create a new "prodRate" object for very component. */
            let prodRate = new Object();
            let arrProdRateList = [];

            prodRate["itemGuid"] = objItem.itemGuid;
            prodRate["itemNumber"] = objItem.baItem;
            prodRate["description"] = objItem.Description;
            prodRate["netWeight"] = 1;
            prodRate["bActive"] = objItem.bActive;
            prodRate["volume"] = 1;

            /* RATE */
            prodRate["rate"] = 0;
            prodRate["rateConverted"] = 0;
            prodRate["rateMP"] = objItem.marketPrice;
            //for custom price, rateMP is calculated based on MP price.  we need to store original MP
            prodRate["rateMPOrig"] = objItem.rateMPOrig;
            prodRate["rateMPCS"] = objItem.marketPriceCS;
            prodRate["rateMPLB"] = objItem.marketPriceLB;
            /* in custom price, ui needs to hold both the MP rate and the calculated rate.  rateMPCustom is calculated
            on save from ui, rateMp gets overwritten with rateMPcustom, so approval logic uses the "calculated mp rate" */
            prodRate["rateMPCustom"] = 0;

            /* VARIANCE */
            prodRate["varianceMP"] = 0;
            prodRate["variancePercMP"] = 0;
            prodRate["MPApprovalVariance"] = 0;

            /* UOM */
            prodRate["uom"] = new Object();
            prodRate["uom"].uomId = 0;
            prodRate["uom"].description = "";
            prodRate["uom"].abbreviation = "";

            /* UOMDP */
            prodRate["uomMP"] = new Object();
            prodRate["uomMP"].uomId = 0;
            prodRate["uomMP"].description = "";
            prodRate["uomMP"].abbreviation = "";

            /* CUSTOM PRINT */
            prodRate["customPrint"] = new Object();
            prodRate["customPrint"].bCustomPrint = getIsCustomPrintOn(item);;
            prodRate["customPrint"].iColors = 0;
            prodRate["customPrint"].sGraphics = "";
            prodRate["customPrint"].bDigital = false;

            /* Check for "Distributor rates" feature */
            bDistribututorRatesOn = getIsDistributorRatesOn(item);

            if(bDistribututorRatesOn == true){
                objProgram.distributors.forEach(function(itemDistributors){
                    prodRate['rateCust_'+itemDistributors.shipTo] = 0;
                    if(objProgram.bHasConversionFactor){
                        prodRate['rateCustConverted_'+itemDistributors.shipTo] = 0;
                    }
                });
            }

            /* If the "prodRate* array does NOT EXIST or the component, i.e., rate for no product
            has been added for that component. */
            if(item.prodRate == undefined){
                item["prodRate"] = [];
            }
            else{
                /* If the "prodRate* array EXISTS for the component, then create an array of products for which the
                "prodRate* array EXISTS. */
                item.prodRate.forEach(function(item1){
                    arrProdRateList.push(item1.itemGuid);
                });
            }

            /* if the prodRate UOM is 0 we have to set the UOM to 1. This is to handle for entries that have only a market price and not a fixed price */
            if(prodRate["uom"].uomId == 0){
                prodRate["uom"].uomId = 1;
            }
            /* If the item for which this function is called, does not exist in the "prodRate* array for the component,
            then add the placeholder "prodrate" array. */
            if($.inArray(objItem.itemGuid, arrProdRateList) == -1){
                item["prodRate"].push(prodRate);
            }
        });
    }

    function enableDisableMassApplyOptions(){
        let rateVal = $("#tiRate").val();
        let applyRateOption = $('select[name=apply_rdoUomActionGrp] option:selected').val();

        if(Number(rateVal) || rateVal == '0' || rateVal == '' || applyRateOption == 5){
            /* Rate cannot be applied, if a user has not selected any option - like "abs" etc.
            Rate also cannot be applied when "applyRateOption == 5", i.e. "eq price rate" option has been selected. */
            if(Number(rateVal) && applyRateOption == ''){
                    $("#setRateUomBtn").prop("disabled", true);
            }
            else{
                $("#setRateUomBtn").prop("disabled", false);
            }
        }
        else{
            $("#setRateUomBtn").prop("disabled", true);
        }
    }

    /* check to see if the component already exists on the program (combination of "Discount Type,Component ID and Paid To").
    If yes, then disable the "Add" button, so that the component cannot be added again. */
    function checkComponentStatus(){
        let EntryFound = 0;
        let selectedComponentStatus = 0;
        let componentStatusText;

        objProgram.components.forEach(function(item){
            if(item.type == selectedDiscountType
                && item.componentId == arrObjSelectedComponent.componentId
                ){
                EntryFound = 1;
                selectedComponentStatus = 1;
            }
            if(EntryFound == 0){
                selectedComponentStatus = 0;
            }
        });

        /* If the component already exists on the program */
        if(selectedComponentStatus == 1){
            componentStatusText = "EDITING";
            /* Disable the "Add" button, which adds the component, as the component is already added. */
            $("#submitLabel").attr("disabled", true);
            /* Enable the "upload rates" button, which the user can use to upload rates for the selected component (dropdown). */
            $("#uploadRates").attr("disabled", false);
            $("#downloadRates").attr("disabled", false);
        }
        else{
            componentStatusText = "ADD";
            $("#submitLabel").show();
            /* Enable the "Add" button, which adds the component. */
            $("#submitLabel").attr("disabled", false);
            /* Since the selected component (dropdown) has not been added (as yet), disable the "upload rates" button.
            "upload rates" button is only used for the selected component. */
            $("#uploadRates").attr("disabled", true);
            $("#downloadRates").attr("disabled", true);
        }
        /* Show Add or Editing for the component (above the component dropdown) */
        $("#componentStatus").addClass("ml-1 my-1 text-red");
        $("#componentStatus").html(componentStatusText + ' ' + arrObjSelectedComponent.name);
    }

    /* Populate the Distributor Rate multi-select dropdown */
    function loadCustomerDropDown(arrCustomers){
        $("#drpSelectedCustomers" + " option").remove();//clear all the options
        let compDrpDown = $("#drpSelectedCustomers");
        for (var i= 0; i< arrCustomers.length; i++) {
              compDrpDown.append($("<option></option>")
                            .attr("value", arrCustomers[i].shipTo)
                            .text( " (" + arrCustomers[i].shipTo + ") " + arrCustomers[i].name )
                            .attr('selected','selected')
            );
        }
        compDrpDown.multiselect('refresh');
    }

    function loadMassApplyOptionsDropdown(){
        $("#apply_rdoUomActionGrp" + " option").remove();//clear all the options

        let compDrpDown = $("#apply_rdoUomActionGrp");
        let arrMassApply = [];

        arrMassApply.push('Abs');
        arrMassApply.push('Inc');
        arrMassApply.push('% chg');
        arrMassApply.push('% price chg');
        arrMassApply.push('Inc price chg');
        if(objProgram.bMarketPriceTemplate && selectedDiscountType == fixed_type_id){
            arrMassApply.push('eq price rate');
        }

        $(compDrpDown).append('<option value="' + '' + '">' + 'Apply...' + "</option>'");
        for(var i= 0; i< arrMassApply.length; i++){
            $(compDrpDown).append('<option value="' + i + '">' + arrMassApply[i] + "</option>'");
        }
    }

    /* show the "options" and "convert" sections.
     We are using "arrObjSelectedComponent" here, because "Custom print" feature is at the component lavel and will
    be available on the GUI based on whether "Custom print" feature is ON for the selected component. */
    function hideShowCustomPrintOptions(){
        if(arrObjSelectedComponent.type == fixed_type_id && objProgram.template.bCustomPrint
        && arrObjSelectedComponent.fixedType != fixed_cust_rate_type_id
        && <cfoutput> #appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>
        ){
            $("#custOptions").show();
            $("#convert").show();
        }
        else{
            $("#custOptions").hide();
            $("#convert").hide();
        }
    }

    function hideShowDiscountTypes(){
         if($.inArray(1, objProgram.componentType) == -1){
            $("#FIXED_TYPE_ID").hide();
            $('label[for="FIXED_TYPE_ID"]').hide();
         }

         if($.inArray(2, objProgram.componentType) == -1){
            $("#REBATE_TYPE_ID").hide();
            $('label[for="REBATE_TYPE_ID"]').hide();
         }
    }

    function hideShowCADCurrencyOption(){
        if(objProgram.bHasConversionFactor){
            /* "Show CAD" checkbox should be visible now */
            $("#cadSection").show();
        }
    }

    function hideShowFilterOptions(){
        let bGroup = false;
        let allowInSearch = false;

        objProgram.arrPrdAttr.some(function(item){
            if(item.allowInGroupSearch == true){
                bGroup = true;
                return true; // exit the loop
            }
        });

        if(! bGroup && objProgram.template.bGroupDeal && <cfoutput>#appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>){
            $("#chFilterGroup").hide();
            $('label[for="chFilterGroup"]').hide();
            $("#chFilterItem").hide(); // Hide the "items" filter also, when groups do not exist. (all are items).
            $('label[for="chFilterItem"]').hide();// Hide the "items" filter also, when groups do not exist. (all are items).

            if(! objProgram.template.bCustomPrint && <cfoutput>#appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>){
                    $("#chFilterNone").hide();
                    $('label[for="chFilterNone"]').hide();
            }
        }
    }

    function getDiscountName(discountTypeID){
        let discountName;

        if(discountTypeID == fixed_type_id){
            discountName = fixed_name;
        }
        else if(discountTypeID == rebate_type_id){
            discountName = rebate_name;
        }

        return discountName;
    }

    function loadComponentAttributeDropDowns(){
        $("#cboPaymentCycle" + " option").remove();//clear all the options
        $("#cboPaidTo" + " option").remove();//clear all the options
        $("#cboClaimMechanic" + " option").remove();//clear all the options
        $("#cboGlAccount" + " option").remove();//clear all the options
        $("#cboUom" + " option").remove();//clear all the options

        /* Get the data for the selected component */
        let payment_cycle = arrObjSelectedComponent.paymentCycle;
        let claim_mechanic = arrObjSelectedComponent.claimMechanic;
        let gl_account = arrObjSelectedComponent.glAccount;
        let paid_to = arrObjSelectedComponent.paidTo;
        let uom = arrObjSelectedComponent.uom;

        /* Populate "payment cycle" dropdown. */
        for(var i= 0; i< payment_cycle.length; i++){
            $("#cboPaymentCycle").append('<option value="' + payment_cycle[i].paymentCycleId + '">' + payment_cycle[i].description + "</option>'");
        }

        /* Populate "paid to" dropdown. */
        for(var i= 0; i< paid_to.length; i++){
            $("#cboPaidTo").append('<option value="' + paid_to[i].paidToId + '">' + paid_to[i].description + "</option>'");
        }

        /* Populate "claim mechanic" dropdown. */
        for(var i= 0; i< claim_mechanic.length; i++){
            $("#cboClaimMechanic").append('<option value="' + claim_mechanic[i].claimMechanicId + '">' + claim_mechanic[i].description + "</option>'");
        }

        /* Populate "gl account" dropdown. */
        for(var i= 0; i< gl_account.length; i++){
            $("#cboGlAccount").append('<option value="' + gl_account[i].glAccountId + '">' + gl_account[i].description + "</option>'");
        }

        /* Populate "uom" dropdown. */
        for(var i= 0; i< uom.length; i++){
            $("#cboUom").append('<option value="' + uom[i].uomId + '">' + uom[i].abbreviation + "</option>'");
        }
    }

    /* This function sets the "Paid To" in the "Paid To" dropdown..
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being used below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function setPaidToIdx(){
        let selectedpaidToID = 0;

        objProgram.components.some(function(item){
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    selectedpaidToID = item.paidTo.paidToId;
                    return true;// exit the loop
                }
            }
        });

        if(selectedpaidToID > 0){
            $('#cboPaidTo').val(selectedpaidToID);
        }
    }

    /* This function sets the "Payment cycle" in the "Payment cycle" dropdown.
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being used below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function setPaymentCycleIdx(){
        let selectedPaymentCycleID = 0;

        objProgram.components.some(function(item){
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    selectedPaymentCycleID = item.paymentCycle.paymentCycleId;
                    return true; // exit the loop
                }
            }
        });

        if(selectedPaymentCycleID > 0){
            $('#cboPaymentCycle').val(selectedPaymentCycleID);
        }
    }

    /* This function sets the "Claim Mechanic" in the Claim Mechanic" dropdown.
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being used below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function setClaimMechanicIdx(){
        let selectedClaimMechanicID = 0;
        let selectedPayeeTypeID = 0;
        let selectedPayeeObject = new Object();

        /* Get the saved claim mechanics and payee */
        objProgram.components.some(function(item){
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    $('#cboClaimMechanic').val(item.claimMechanic.claimMechanicId);
                    hideShowPayeeOptions(item);
                    return true; // exit the loop
                }
            }
        });
    }
    /*
    Logic for claim mechanic and payee options (when "payee options" i.e. distributor or vendor) as payee exist -
    1) For the selected component, check the payeeTypeId in the "claimMechanic" object.
    If it is either 1 (distributor) or 5  (vendor), then show the "Payee options" section.
    2) If the payee options are visible, then check the selected component's payee object.
    If the "payeeTypeId" is greater than 0 (i.e. either 1 or 5), then "Select a single" radio button
    option should be selected, else the "Pay Each" option should be selected.
    3) If the "Select a single" radio button is selected, then the "Select Payee" button should be available.
    In this case, user needs to select a payee from the popup by clicking the "Select Payee" button.
    The selected payee should be shown above the "Select a single" radio button.*/
    function hideShowPayeeOptions(comp){
        if(comp.claimMechanic.payeeTypeId > 0){
            $("#payeeOption").show();
            setPayeeIdx(comp);
        }
        else{
            $("#payeeOption").hide();
        }
    }

    function setPayeeIdx(comp){
        if(comp.payee.payeeTypeId > 0){
            $('#rdoPayeeSingle').prop('checked', true);
        }
        else{
            $('#rdoPayeeEach').prop('checked', true);
        };

        hideShowPayeeOptionButton(comp);
    }

    function hideShowPayeeOptionButton(comp){
        if(comp.payee.payeeTypeId > 0){
            $("#selectPayee").show();
            if(comp.payee.name){
                $( "#selectedPayeeName" ).html( "Selected Payee: <br>" + "<span style='font-weight:bold'>" + comp.payee.name + "</span>");
            }
        }
        else{
            $("#selectPayee").hide();
            $( "#selectedPayeeName" ).html('');
        }

        payeeType = comp.claimMechanic.payeeTypeId; // Vendor or distributor
    }

    /* This function sets the "GL Account" in the "GL Account" dropdown.
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function setGlAccountIdx(){
        let selectedGlAccountID = 0;

        objProgram.components.some(function(item){
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    selectedGlAccountID = item.glAccount.glAccountId;
                    return true; // exit the loop
                }
            }
        });

        if(selectedGlAccountID > 0){
            $('#cboGlAccount').val(selectedGlAccountID);
        }
    }

    function saveData(){
        let bShowAlert = false;
        let bShowAlertCustomPrint = false;
        let sMessage = '';
        let i = 0;
        let gValIx;
        let bGVal;
        let gValItemsError = [];

        objProgram.components.some(function(tmpComp){
            if(tmpComp.payee && tmpComp.payee.payeeTypeId > 0 && tmpComp.payee.payeeId == ""){
                bShowAlert = true;
                sMessage = sMessage + tmpComp.name + ' has the Pay Single payee option without a selected payee. \n';
            }

            //Custom Print (for Fixed)
            if(tmpComp.customPrint.bCustomPrint){
                tmpComp.prodRate.some(function(tmpProdRate){
                    if(tmpProdRate.rateMPCustom > 0 && tmpProdRate.rate != 0){
                        tmpProdRate.rateMP =  tmpProdRate.rateMPCustom;
                        tmpProdRate.rateMPCS = tmpProdRate.rateMPCustom;
                        tmpProdRate.rateMPLB = tmpProdRate.rateMPCustom;
                    }
                    if(tmpProdRate.customPrint){
                        /*
                            103489:	Unable to create program / Anand Rao / 22-Jan-2021
                            The value in the tmpProdRate.customPrint.iColors was set to 0 and not picking the value set in the updatePrintCharge.
                            So adding the below code to handle this issue during Adding and Editing.
                        */

                        if ((tmpProdRate.customPrint.iColors == 0 && document.all.cboColors.options[document.all.cboColors.selectedIndex].value != 0)
                        || (tmpProdRate.customPrint.iColors != 0 && document.all.cboColors.options[document.all.cboColors.selectedIndex].value != 0 && tmpProdRate.customPrint.iColors != document.all.cboColors.options[document.all.cboColors.selectedIndex].value))
                        {
                            tmpProdRate.customPrint.iColors = document.all.cboColors.options[document.all.cboColors.selectedIndex].value;
                        }
                        if ((tmpProdRate.customPrint.sGraphics == 0 && document.all.cboGraphics.options[document.all.cboGraphics.selectedIndex].value != 0)
                        || (tmpProdRate.customPrint.sGraphics != 0 && document.all.cboGraphics.options[document.all.cboGraphics.selectedIndex].value != 0 && tmpProdRate.customPrint.sGraphics != document.all.cboGraphics.options[document.all.cboGraphics.selectedIndex].value))
                        {
                            tmpProdRate.customPrint.sGraphics = document.all.cboGraphics.options[document.all.cboGraphics.selectedIndex].value;
                        }
                        if ((!tmpProdRate.customPrint.bDigital && document.getElementById("rdoComplexTrue").checked)
                        || (tmpProdRate.customPrint.bDigital != document.getElementById("rdoComplexTrue").checked))
                        {
                            tmpProdRate.customPrint.bDigital = document.getElementById("rdoComplexTrue").checked;
                        }

                        if(tmpProdRate.customPrint.iColors == 0 && tmpProdRate.rate > 0 && tmpProdRate.customPrint.bCustomPrint){
							bShowAlertCustomPrint = true;
                        }
                    }
                    /*  check uom*/
                    if(tmpProdRate.uom.uomId == 0){   /* tmpProdRate is tmp var for loop over array of [mvc.Models.Item.vos.Item]*/
                        tmpComp.uom.some(function(tmpUom){    /* tmpComp var is from loop over array of [mvc.Models.Program.Component.vos.Component] -> objProgram.components.some(function(item).    */
                            if(tmpUom.bDefault == true){    /* */
                              tmpProdRate.uom = tmpUom;
                            }
                        });
                    }
                }); // some() over ProdRate [] -> loop item1
                if(bShowAlertCustomPrint){
                    sMessage = sMessage + tmpComp.name + ' contains custom print items that do not have print options (colors, graphics or digital art) applied. \n';
                }
            }

            // GREATEST PROGRAM VALUE
            if(tmpComp.componentDef.bGreatestValue){
                gValIx = i;//the index in acComponents of the gVal component
                bGVal = true;
            }
            i++;
        });

        // GREATEST PROGRAM VALUE LOGIC
        if(bGVal){
            gValComp = objProgram.components[gValIx];//Greatest Val Component "gVal"
            gValComp.prodRate.some(function(item){//Prodrates To check
                objProgram.components.some(function(item1){//loop over Components
                    if(item1.componentId != gValComp.componentId && item1.type == fixed_type_id){//if it is Fixed component and it is NOT the gVal Component
                        item1.prodRate.some(function(item2){//loop over non gVal Component rates -> "FOB" rates in pratcice
                            if(item2.itemGuid == item.itemGuid){ //compare like items
                                //check gval component rate against non gVal rate
                                if ( less_than_or_equal( item.rate, item2.rate ) && item.rate != 0 ) {
                                    gValItemsError.push(item.itemGuid);
                                }
                                //if customer level rates
                                if(gValComp.fixedType == fixed_cust_rate_type_id){
                                    objProgram.distributors.some(function(itemDistributors){//loop over customers and validate their rates
                                        if ( less_than_or_equal( item['rateCust_'+ itemDistributors.shipTo], item2.rate ) && item['rateCust_'+ itemDistributors.shipTo] != 0){
                                            gValItemsError.push(item.itemGuid);
                                            return true;// exit the loop
                                        }
                                    });
                                }
                            }
                        });
                    }
                });
            });
        }

        if(gValItemsError.length){
            bShowAlert = true;
            sMessage = sMessage + gValComp.name + ' has ' +  gValItemsError.length + ' rates that are not Greatest Program Value. \n';

            /* SELECT ITEMS IN THE "gValItemsError" array */
            Rate_GridOptions.api.forEachNode(function(node){
                node.setSelected( false ); // reset it
                gValItemsError.forEach(function(itemGuid){
                    if(node.id == itemGuid){
                        node.setSelected( true );
                    }
                });
            });
        }

        if(bShowAlert || bShowAlertCustomPrint){
            alert(sMessage);

            if(bShowAlert == true){
                /* Check the "Selected" filter checkbox */
                $('#chFilterSelected').prop('checked', true);

                /* Filter grid to show only the selected records (In this case it would be the items which have an assocaited error) */
                externalFilterChanged();
            }
        }
        else{
        // convert string rates with commas into numeric values
        for (let component_counter = 0; component_counter < objProgram.components.length; component_counter++) {
            for (let product_counter = 0; product_counter < objProgram.components[ component_counter ].prodRate.length; product_counter++) {
                let sanitized_rate = objProgram.components[ component_counter ].prodRate[ product_counter ].rate;
                if (typeof sanitized_rate === "string") {
                    // remove all commas, convert string value back into numeric value
                    sanitized_rate = +sanitized_rate.replace(/,/g, '');
                    objProgram.components[ component_counter ].prodRate[ product_counter ].rate = sanitized_rate;
                }
            }
        }
            show_loader("PLEASE WAIT...");
            $.ajax({
                url: "/mvc/Models/Program/Component/ComponentManager.cfc"
                ,type: "POST"
                ,dataType: "json"
                ,data: { method: "saveComponentDataJSON"
                        ,programId:
                        <cfoutput>'#url.programID#'</cfoutput>
                        ,acComponents:JSON.stringify(objProgram.components)
                        ,bMarketPrice: 0
                 }
                ,error: function(xhr, status, error) { hide_loader(); error_handler(arguments) }
                ,success: function( response ) {
                    <cfoutput>
                    window.location.href = '/Common_Files/contracts/contract_edit_menu.cfm?CID=#url.cid#';
                    </cfoutput>
                }
            });
        }
    }

    /* Calculate "variance" and "Discount %". These are the two columns. Both columns exist for "fixed price" components.
    Only the "Discount %" column exists for "Rebate" components. The "Variance" column does not. */
    function setVarianceAndDiscountValue(discountType,paramsData, varianceColumn, variancePercentColumn, marketPriceColumn, rateColumn, uomColumn){
        if(paramsData[marketPriceColumn] != 0 && paramsData[marketPriceColumn] !== undefined){
            /* fixed price */
            if(discountType == fixed_type_id){
                paramsData[varianceColumn] = numberFormat(parseFloat(paramsData[marketPriceColumn] - paramsData[rateColumn]),fmt_4_decimal_places);
                paramsData[variancePercentColumn] = numberFormat(parseFloat((((paramsData[marketPriceColumn] - paramsData[rateColumn])/paramsData[marketPriceColumn]) * 100)),fmt_2_decimal_places);
            }
            /* rebate */
            else if(discountType == rebate_type_id){
                /* If the UOM is "Percent" */
                if(paramsData[uomColumn] == 3){
                    paramsData[varianceColumn] = numberFormat(parseFloat((paramsData[marketPriceColumn] * (paramsData[rateColumn]/100))),fmt_4_decimal_places);
                    paramsData[variancePercentColumn] = numberFormat(parseFloat(paramsData[rateColumn]),fmt_2_decimal_places);
                }
                /* If the UOM is "Case" or "LB". */
                else{
                    paramsData[varianceColumn] = numberFormat(parseFloat(paramsData[rateColumn]),fmt_4_decimal_places);
                    paramsData[variancePercentColumn] = numberFormat(parseFloat((((paramsData[rateColumn])/paramsData[marketPriceColumn]) * 100)),fmt_2_decimal_places);
                }
            }
            Rate_GridOptions.api.refreshCells();
        }
    }

    function isExternalFilterPresent() {
        let filterOptionChecked = false;
            bFilterByRate = false;
            bfilterByVarianceMP = false;
            bfilterByMP = false;
            bfilterByGroup = false;
            bfilterByItem = false;
            bfilterByProdStatus = false;
            bfilterBySelectedRecords = false;
            bfilterByNonePrtgrp = false;

        if($('#chFilterRates').is(":checked") || $('#chFilterSelected').is(":checked")
            || $('#chFilterVarianceMP').is(":checked") || $('#chFilterMP').is(":checked")
            || $('#chFilterItem').is(":checked") || $('#chFilterGroup').is(":checked")
            || $('#chFilterNone').is(":checked") || $('#cboProductStatus').val() != 'All Status'){
                filterOptionChecked = true;
        }

        if($('#chFilterRates').is(":checked")){
            bFilterByRate = true;
        }
        if($('#chFilterSelected').is(":checked")){
            bfilterBySelectedRecords = true;
        }
        if ($('#chFilterVarianceMP').is(":checked")){
            bfilterByVarianceMP = true;
        }
        if ($('#chFilterMP').is(":checked")){
            bfilterByMP = true;
        }
        if ($('#chFilterItem').is(":checked")){
            bfilterByItem = true;
        }
        if ($('#chFilterGroup').is(":checked")){
            bfilterByGroup = true;
        }
        if ($('#chFilterNone').is(":checked")){
            bfilterByNonePrtgrp = true;
        }
        if($('#cboProductStatus').val() != 'All Status'){
            bfilterByProdStatus = true;
        }

        return filterOptionChecked;
    }

    function showFilteredRecords(node) {
        /* Note: The reason why a second variable for every filter (wg: bFilterByRate and bFilterRate)
        is created is to filter fast. This way we can just use the boolean value to decide whether records
        need to be filtered or not.Without it, it is quite slow. */

        let bFilterRate = true;
        let bfilterSelectedRecords = true;
        let bFilterVarianceMP = true;
        let bfilterMP = true;
        let bfilterItem = true;
        let bfilterGroup = true;
        let bfilterNonePrtgrp = true;
        let bfilterProdStatus = true;

        if(bFilterByRate){
            objProgram.components.some(function(item){
                if(item.prodRate){
                    if(item.prodRate.length){
                        item.prodRate.some(function(item1){
                            if(item1.rate != 0 && item1.itemGuid == node.data.itemGuid){
                                bFilterRate = true;
                                return true;// exit the "prodrate" loop
                            }
                            else if(item.hasOwnProperty("fixedType") && item.fixedType == fixed_cust_rate_type_id){
                                objProgram.distributors.some(function(itemDistributors){
                                    let distRate = item1['rateCust_'+ itemDistributors.shipTo];
                                    if(distRate != 0 && item1.itemGuid == node.data.itemGuid){
                                        bFilterRate = true;
                                        return true;// exit the "distributors" loop
                                    }
                                    else{
                                        bFilterRate = false;
                                    }
                                });
                                if(bFilterRate == true){
                                    return true;// exit the "prodrate" loop
                                }
                            }
                            else{
                                bFilterRate = false;
                            }
                        });
                    }
                    else{
                        bFilterRate = false;
                    }
                    if(bFilterRate == true){
                        return true;// exit the "objProgram.components" loop
                    }
                }
                else{
                    bFilterRate = false;
                }
            });
        }

        if(bfilterBySelectedRecords){
            if(node.selected == false){
                bfilterSelectedRecords = false;
            }
        }

        if(bfilterByVarianceMP){
            objProgram.components.some(function(item){
                if(item.prodRate){
                    if(item.prodRate.length){
                        item.prodRate.some(function(item1){
                            if((item1.rate != node.data.marketPrice) && item1.itemGuid == node.data.itemGuid){
                                bFilterVarianceMP = true;
                                return true;// exit the loop
                            }
                            else{
                                bFilterVarianceMP = false;
                            }
                        });
                        if(bFilterVarianceMP == true){
                            return true;// exit the loop
                        }
                    }
                    else{
                        bFilterRate = false;
                    }
                }
                else{
                    bFilterRate = false;
                }
            });
        }

        if(bfilterByMP){
            if(node.data.marketPrice == '' || node.data.marketPrice == 0){
                bfilterMP = false;
            }
        }

        if(bfilterByItem){
            if(node.data.isGroup == true){
                bfilterItem = false;
            }
        }

        if(bfilterByGroup){
            if(node.data.isGroup == false){
                bfilterGroup = false;
            }
        }

        if(bfilterByNonePrtgrp){
            if(node.data.Type_Group_desc != 'NONE'){
                bfilterNonePrtgrp = false;
            }
        }

        if(bfilterByProdStatus){
            if(node.data.Item_Status != $('#cboProductStatus').val()){
                bfilterProdStatus = false;
            }
        }

        return (bFilterRate == true && bfilterSelectedRecords == true && bFilterVarianceMP == true && bfilterMP == true && bfilterItem == true
                && bfilterGroup == true && bfilterNonePrtgrp == true && bfilterProdStatus == true
                );
    }

    function externalFilterChanged(){
       Rate_GridOptions.api.onFilterChanged();
    }

    /* This gets called when adding a new component.
    This loops through "arrObjComponentsDef". */
    function newUOMCellRenderer() {}
        newUOMCellRenderer.prototype.init = function (params) {

            this.eGui = document.createElement('span');
            if (params.value !== "" || params.value !== null) {
                let uomStr = '';
                /* Loop through "arrObjComponentsDef" and get the "abbreviation"
                for the "uomId". Then show the "abbreviation" on the cell. */
                arrObjComponentsDef.some(function(item){
                        item.uom.some(function(item1){
                            if(params.value == item1.uomId){
                                uomStr = item1.abbreviation;
                                return true;// exit the loop
                            }
                        });
                        if(uomStr != ''){
                            return true;// exit the loop
                        }
                });
                this.eGui.innerHTML = uomStr;
            }
        };
    newUOMCellRenderer.prototype.getGui = function () {
        return this.eGui;
    };

    /* This gets called on the initial load.
    This loops through "objProgram.components". */
    function existingUOMCellRenderer() {}
        existingUOMCellRenderer.prototype.init = function (params) {

            this.eGui = document.createElement('span');
            if (params.value !== "" || params.value !== null) {
                let uomStr = '';
                /* Loop through "objProgram.components" and get the "abbreviation"
                for the "uomId". Then show the "abbreviation" on the cell. */
                objProgram.components.some(function(item){
                        item.uom.some(function(item1){
                            if(params.value == item1.uomId){
                                uomStr = item1.abbreviation;
                                return true;// exit the loop
                            }
                        });
                        if(uomStr != ''){
                            return true;// exit the loop
                        }
                });
                this.eGui.innerHTML = uomStr;
            }
        };
    existingUOMCellRenderer.prototype.getGui = function () {
        return this.eGui;
    };

    /* Get a list of UOM's for the component */
    function getUOMList(compObj,discountType){
        let uomList = [];
        compObj.some(function(item){
            if(item.type == discountType){
                item.uom.some(function(item1){
                    uomList.push(item1.uomId);
                });
            }
            if(uomList.length > 0){
                return true;// exit the loop
            }
        });
        return uomList;
    }

    /* Set the default UOM -
    Note: It is possible for the UOM list to vary by component.
    e.g - The "%" UOM is for rebates and not for fixed price. */
    function selectedUomIdx(params,comp){
        let defaultUOM = 1;//default is CS
        let uniqueColumnID = comp.type+'_'+comp.componentId;

        if(params.data['uom_'+uniqueColumnID] == undefined){
            arrObjComponentsDef.some(function(item){
                if(item.type == comp.type){
                    item.uom.some(function(item1){
                        if(item1.bDefault == true){
                            defaultUOM = item1.uomId;
                        }
                    });
                }
            });
            params.data['uom_'+uniqueColumnID] = defaultUOM;
            Rate_GridOptions.api.refreshCells(params);
            /* do not call the "updateuom" function from here.
            let it be called from wherever the "selecteduomidx" function is being called (if needed) .
            This is important to avoid issues, in some cases. */
        }
    }
    /* We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function hideShowDistributorDropdown(){
        if(selectedDiscountType == fixed_type_id || objProgram.bMarketPriceTemplate){
            if(objProgram.distributors.length > 0 && arrObjSelectedComponent.hasOwnProperty("fixedType")
                && arrObjSelectedComponent.fixedType == fixed_cust_rate_type_id){
                    $('#selectedCustomers').show();
                    loadCustomerDropDown(objProgram.distributors);
            }
            else{
                $('#selectedCustomers').hide();
            }
        }
        else{
            $('#selectedCustomers').hide();
        }
    }

    /* Show/Hide "Customer rate" columns. The header is the "ship to". */
    function showHideCustRates(){
    /* Get a list of "checked" distributors on the dropdown */
    let arrObjDistributors = $('#drpSelectedCustomers').multiselect('getChecked');
    let arrDistributors = [];

    /* Store list of "checked" distributors in an array */
    $.each(arrObjDistributors, function( index, obj ) {
        arrDistributors.push(obj.value);
    });

        /* Loop through the grid columns */
        columnDefs_ratesGrid.forEach(function(itemCol){
            if(itemCol.hasOwnProperty("children")){
                itemCol.children.forEach(function(itemCol1){
                    /*First child column of a component is "rate". Just verifying that these children are part of the component, since
                    we do not want to add the "shipTo" columns for headers which are not a program component. */
                    if((itemCol1.field.indexOf('rateCust_') != -1) || itemCol1.field.indexOf('rateCustConverted_') != -1){
                        let arrRateCustField = itemCol1.field.split("_");
                        /*The "field" is in this format:
                        "rateCust_discountType_componentID_shipTo".
                        So, the last index will be 3 (ship_to) in this case. */
                        let ship_to = arrRateCustField[3];
                        let showColumn = false;
                        let chBoxVal;

                         /* Sometimes, "shipto" can have an underscore. In that case, the length of arrRateCustField will be more
                        than 3. We want to get the value of the entire shipto, including the underscore (if it does exist).*/
                        if(arrRateCustField.length > 4){
                            arrRateCustField.forEach(function(rateCustField, idx){
                                if(idx > 3){
                                    ship_to = ship_to + "_" + arrRateCustField[idx];
                                }
                            });
                        }

                        /* If the distributor is not included in the "distributor "dropdown", hide the "Distributor rate"
                        and  "Distributor rate (Canadian Currency)" columns (if exists) for all the components. */
                        if($.inArray(ship_to, arrDistributors) == -1){
                            showColumn = false;
                        }
                        else{
                            /* Show the "Distributor rate" column for all the components.  */
                            if(itemCol1.field.indexOf('rateCust_') != -1){
                                showColumn = true;
                            }
                            /* Show the "Distributor rate (Canadian Currency)" columns for all the components, only if the "show CAD" checkbox is checked. */
                            else if(itemCol1.field.indexOf('rateCustConverted_') != -1){
                                if($("input:checkbox[name=chCAD]:checked").val() == true){
                                    showColumn = true;
                                }
                            }
                        }
                        Rate_GridOptions.columnApi.setColumnVisible(itemCol1.field, showColumn);
                    }
                });
            }
        });
    }
    /* Check for "Distributor rates" feature */
    function getIsDistributorRatesOn(comp){
        let isDistribututorRatesOn = false;

        if(comp.type == fixed_type_id || comp.bMarketPriceTemplate){
            if(comp.hasOwnProperty("fixedType") && comp.fixedType == fixed_cust_rate_type_id){
                isDistribututorRatesOn = true;
            }
        }
        return isDistribututorRatesOn;
    }

    /* Check for "Custom print" feature */
    function getIsCustomPrintOn(comp){
        let isShowCustomPrintQuotes = false;

        if(comp.type == fixed_type_id && objProgram.template.bCustomPrint
            && <cfoutput> #appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput> == 1
            && comp.fixedType != fixed_cust_rate_type_id){
                isShowCustomPrintQuotes = true;
        }
        return isShowCustomPrintQuotes;
    }

    function enableDisableUOMOptions(){
        let applyRateOption = $('select[name=apply_rdoUomActionGrp] option:selected').val();

        if(applyRateOption != 0 && applyRateOption != ''){
            $("#cboUom").prop("disabled", true);
        }
        else{
            $("#cboUom").prop("disabled", false);
        }
    }

    function showPayeeSearch(){
        if(payeeType == 1){//distributor
            NewWindowTopLeft("/billbacks/search_Screens/PM_select_distributors.cfm?Formname=frmSelectedPayee&ReloadForm=0&FieldName=Payee_ID&PageSource=ProgramRatesGrid&OnlyDistributorsUnderMe=1", "distributorsearchwindow", 850, 600, "yes", "yes");
        }
        else if (payeeType == 5){//vendor
            NewWindowTopLeft("/GL_Code/Vendor_Management/Vendor_Master_Search.cfm?Formname=frmSelectedPayee&ReloadForm=0&FieldName=Vendor_ID&PageSource=VendorSearch", "vendorsearchwindow", 850, 600, "yes", "yes");
        }
    }

    /* This gets called from the "distributor" popup page. */
    function getDistributorInfo(distributor_id,is_guid){
        $.ajax({type    : "post"
                ,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
                ,dataType: "json"
                ,data: { method: "getDistributorInfoJSON"
                        ,distributorID: distributor_id
                        ,isGUID:is_guid
                        }
                ,success : function (response) {
                    let distributor_info = '';

                    if(response.name != ''){
                        distributor_info = '<span style="font-weight:bold">'+response.name+'</span>';
                    }

                    $('#selectedPayeeName').html(distributor_info);
                    updatePayee(distributor_id,response.name);
                }
        });
    }

    function getVendorInfo(vendor_id){
        $.ajax({type    : "post"
            ,url: "/mvc/Models/Admin/Alias/AliasManager.cfc"
            ,dataType: "json"
            ,data: { method: "getVendorInfoJSON"
                    ,vendorID: vendor_id
                    }
            ,success : function (response) {
                let vendor_info = '';
                if(response.NAME != ''){
                    vendor_info = '<span style="font-weight:bold">'+response.NAME+'</span>';
                }

                $('#selectedPayeeName').html(vendor_info);
                updatePayee(vendor_id,response.NAME);
            }
        });
    }

    function filterOnLoad(){
        if(objProgram.components.length){
            $('#chFilterRates').prop('checked', true);
        }
        else{
            if(objProgram.template.bGroupDeal && <cfoutput>#appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>){
                $('#chFilterGroup').prop('checked', true);

                if(objProgram.template.bCustomPrint){
                    $('#chFilterNone').prop('checked', true);
                }
            }
            if(objProgram.bMarketPriceTemplate){
                $('#chFilterMP').prop('checked', true);
            }
        }
        externalFilterChanged();
    }

    /* This function sets the "paid to" in the "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function updatePaidTo(){
        let objPaidTo = new Object();
        objPaidTo.paidToId = $("#cboPaidTo").val();
        objPaidTo.description = $("#cboPaidTo option:selected").text();

        objProgram.components.some(function(item){
            /* For the selected component, set the updated "paid To". */
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    item.paidTo = objPaidTo;
                    return true;//exit the loop
                }
            }
        });
    }

    /* This function sets the "payment cycle" in the "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function updatePaymentCycle(){
        let objPaymentCycle = new Object();
        objPaymentCycle.paymentCycleId = $("#cboPaymentCycle").val();
        objPaymentCycle.description =  $("#cboPaymentCycle option:selected").text();

        objProgram.components.some(function(item){
            /* For the selected component, set the updated "payment cycle". */
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    item.paymentCycle = objPaymentCycle;
                    return true;//exit the loop
                }
            }
        });
    }

    /* This function sets the "GL Accounr" in the "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function updateGlAccount(){
        let objGlAccount = new Object();
        objGlAccount.glAccountId =  $("#cboGlAccount").val();
        objGlAccount.description = $("#cboGlAccount option:selected").text();

        objProgram.components.some(function(item){
            /* For the selected component, set the updated "GL Account". */
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    item.glAccount = objGlAccount;
                    return true;//exit the loop
                }
            }
        });
    }

    /* This function sets the "Clsim Mechanic" in the "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function updateClaimMechanic(){
        let exitLoop = 0;
        objProgram.components.some(function(item){
            /* Look for the selected component in the "objProgram.components" array.
            Then loop through the "claimMechanic" object to find the selected claim mechanic.
            Set the "claimMechanic" object in "objProgram.components" to be the new "claimMechanic". */
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    arrObjSelectedComponent.claimMechanic.some(function(item1){
                        if($('#cboClaimMechanic').val() == item1.claimMechanicId){
                            item.claimMechanic = item1;
                            item.payee.payeeTypeId = item1.claimMechanicId.payeeTypeId;
                            hideShowPayeeOptions(item);
                            exitLoop = 1
                            return true;// exit the loop
                        }
                    });
                }
            }
            if(exitLoop == 1){
                return true;// exit the outer loop as well
            }
        });
    }

    /* This function sets the "payee type" in the "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function updatePayeeType(){
        let exitLoop = 0;
        let payeeTypeSelectedValue =  $("input:radio[name=rdoPayeeOptGroup]:checked").val();

        objProgram.components.some(function(item){
            /* Look for the selected component in the "objProgram.components" array.
            Then loop through the "claimMechanic" object to find the selected claim mechanic.
            Update the "payee" object in "objProgram.components" to have the new "payeeTypeId".
            "payeeTypeId" from the "claimMechanic" object is used to set "payeeTypeId" in the
            "payee" object. */
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    arrObjSelectedComponent.claimMechanic.some(function(item1){
                        if($('#cboClaimMechanic').val() == item1.claimMechanicId){

                            /* If the user selects the "Select a Single" option */
                            if(payeeTypeSelectedValue == 1){
                                item.payee.payeeTypeId = item1.payeeTypeId;
                                payeeType = item1.payeeTypeId;
                            }
                            /* If the user selects the "Pay Each" option, remove the selected payee.  */
                            else{
                                item.payee.payeeTypeId = 0;
                                item.payee.payeeId = '';
                                item.payee.name= '';
                            }

                            payeeType = 0;//Reset it to 0;

                            hideShowPayeeOptionButton(item);

                            exitLoop = 1;
                            return true;//exit the loop
                        }
                    });
                }
            }
            if(exitLoop == 1){
                return true;//exit the outer loop as well
            }
        });
    }

    /* This function is called when the payee is updated from either the "distributor" or the "vendor" popup.
    This function sets the "payee type" in the "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop.
    We are using "arrObjSelectedComponent" and "selectedDiscountType" here, because the function gets called for the
    "selected" component, i.e. component selected on the "Components" dropdown and for the selected discount type (radio button). */
    function updatePayee(payee_id,payee_name){
        let objPayee = new Object();
            objPayee.payeeId = payee_id;
            objPayee.name = payee_name;
            objPayee.payeeTypeId = payeeType;

        objProgram.components.some(function(item){
            if(item.type == arrObjSelectedComponent.type){
                if(item.componentId == arrObjSelectedComponent.componentId){
                    item.payee = objPayee;
                    return true;//exit the loop
                }
            }
        });
    }

    /* This function sets the "volume" in the "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Even though volume is actually at the product level and is the same for all the components and discount types,
    but since the "prodRate" object, which is per component, has a "volume" property, the volume property
    is updated for every component (it is the same volume stored for every component and discount type)
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop. */
    function updateVolume(params){
        let arrItem = [];
        arrItem.push(params.data);
        addProdRateObjForNewCompAndItemCombination(arrItem);

        if(params.oldValue != params.newValue){
            objProgram.components.some(function(item){
                item.prodRate.some(function(item1){
                    if(params.data.itemGuid == item1.itemGuid){
                        /* For every component regardless of discount type, set the volume to be the new volume for the product.
                        This is how the "prodRate" stores data. Actually, volume is stored at the product level and not the
                        component level, but this is how it was done on Flex.
                        Normally, the update is for a specifoc component. Here, it is being done for all components.
                        */
                        item1.volume = Number(params.newValue.replace(/,/g, ""));

                        let bShowCustomPrintQuotes = false;

                        /* Just check whether the component on the program is has "custom print" ON.
                        Note: For programs with custom print, users add only one component to the program. */
                        bShowCustomPrintQuotes = getIsCustomPrintOn(item);

                        if(bShowCustomPrintQuotes == true){
                            /* If the component has "custom print" ON, change the print charges based on new volume. */
                            setCustomPrintCharges(item,item1,params);
                            return true; //exit loop
                        }
                        else{
                            return true; //exit loop
                        }
                    }
                });
            });
        }
    }

    /* Update the rate in the "objProgram" object. "objProgram" is sent to the server for saving.*/
    function updateRate(discountType,componentID,params){
        let exitLoop = 0;
        let arrItem = [];
        arrItem.push(params.data);
        /* In case the "prodRate" object does not already exist for the product, add the "prodRate" object first. */
        addProdRateObjForNewCompAndItemCombination(arrItem);

        if(params.oldValue != params.newValue){
            /* For currency conversion (if any) */
            if(objProgram.bHasConversionFactor){
                let rowNode = Rate_GridOptions.api.getRowNode(params.data.itemGuid);

                /* Update the "cad/cnd" (Canadian currency) column to show the converted rate (if any) */
                let val = params.newValue * objProgram.conversionFactor;
                let fmtVal = numberFormat(parseFloat(val),fmt_4_decimal_places);
                rowNode.data['rateConverted_'+discountType+'_'+componentID] = fmtVal;

                Rate_GridOptions.api.refreshCells(params);
            }

            objProgram.components.some(function(item){
                /* Find the component passed to this function in "objProgram.components", based
                    on discountType and componentID passed to this function.
                */
                if(item.prodRate !== undefined && item.type == discountType && item.componentId == componentID){
                    item.prodRate.some(function(item1){
                        if(params.data.itemGuid == item1.itemGuid){
                            item1.rate = params.newValue; // update the rate
                            if(objProgram.bHasConversionFactor){
                                let val = params.newValue * objProgram.conversionFactor;
                                let fmtVal = numberFormat(parseFloat(val),fmt_4_decimal_places);
                                item1.rateConverted = fmtVal; // update currency converted value(canadian currency)
                            }
                            exitLoop = 1;
                            return true; //exit loop
                        }
                    });
                }
                if(exitLoop == 1){
                    return true;//exit the outer loop as well
                }
            });
        }
    }

    /* Update the UOM in the "objProgram" object. "objProgram" is sent to the server for saving.
    Because this function gets called from different places, the parameters passed in differ, but the objective remains the same -
    We need to update the component in "objProgram.components" with the new value. */
    function updateUOM(discountType,componentID,params,updatedValue){
        let exitLoop = 0;
        let itemID;
        let arrItem = [];

        if(params.data){
            itemID = params.data.itemGuid;
            arrItem.push(params.data);
            /* In case the "prodRate" object does not already exist for the product, add the "prodRate" object first. */
            addProdRateObjForNewCompAndItemCombination(arrItem);
        }
        else{
            itemID = params;//Here "params" is the "itemGuid"
        }

        /* We actually pass "updatedValue" to this function, but in case the params.newValue exists,
        use the value instead. */
        if(params.newValue){
            updatedValue = params.newValue;
        }

        /*Currently, when the user tabs off the UOM column, the "OnCellValueChanged" event is fired,which sets the default UOM on the UOM column.
        Note: Here the params.oldValue and params.newValue are the same and so we cannot use the if(params.oldValue != params.newValue) logic. */
        objProgram.components.some(function(item){
            /* Find the component passed to this function in "objProgram.components" based on "discountType" and  "componentID" passed to this function */
            if(item.prodRate !== undefined && item.type == discountType && item.componentId == componentID){
                item.prodRate.some(function(item1){
                    if(itemID == item1.itemGuid){
                        item.uom.some(function(item2){
                            if(item2.uomId == updatedValue){
                                item1.uom = item2; // update UOM
                                exitLoop = 1;
                                return true; //exit loop
                            }
                        });
                        if(exitLoop == 1){
                            let bShowCustomPrintQuotes = false;

                            /* Just check whether the component on the program is has "custom print" ON.
                            Note: For programs with custom print, users add only one component to the program. */
                            bShowCustomPrintQuotes = getIsCustomPrintOn(item);

                            if(bShowCustomPrintQuotes == true){
                                /* If the component has "custom print" ON, change the print charges based on new UOM. */
                                setCustomPrintCharges(item,item1,params);
                            }
                        }
                    }
                    if(exitLoop == 1){
                        return true;//exit the outer loop as well
                    }
                });
            }
            if(exitLoop == 1){
                return true;//exit the outermost loop as well
            }
        });
    }

    /* Update the "Distributor Rate" in the "objProgram" object. "objProgram" is sent to the server for saving.*/
    function updateDistRate(discountType,componentID,params,shipTo){
        let exitLoop = 0;
        let arrItem = [];
        arrItem.push(params.data);
        /* In case the "prodRate" object does not already exist for the product, add the "prodRate" object first. */
        addProdRateObjForNewCompAndItemCombination(arrItem);

        if(params.oldValue != params.newValue){
            /* For currency conversion (if any) */
            if(objProgram.bHasConversionFactor){
                let rowNode = Rate_GridOptions.api.getRowNode(params.data.itemGuid);

                /* Update the "cad/cnd" (Canadian currency) column for the distributor to show the converted rate */
                let val = Number(params.newValue) * objProgram.conversionFactor;
                let fmtVal = numberFormat(parseFloat(val),fmt_4_decimal_places);
                /* Update the "distributor rates" (currency converted) on the grid, sicne the user has
                updated the "distributor rates" on the grid. */
                rowNode.data['rateCustConverted_'+discountType+'_'+componentID +'_'+shipTo] = fmtVal;

                Rate_GridOptions.api.refreshCells(params);
            }

            objProgram.components.some(function(item){
                /* Find the component passed to this function in "objProgram.components" */
                if(item.prodRate !== undefined && item.type == discountType && item.componentId == componentID){
                    item.prodRate.some(function(item1){
                        if(params.data.itemGuid == item1.itemGuid){
                            /* Update the "distributor rates" in the "objProgram" object */
                            item1['rateCust_'+shipTo] = numberFormat(parseFloat(Number(params.newValue)),fmt_4_decimal_places);
                            if(objProgram.bHasConversionFactor){
                                let val = Number(params.newValue) * objProgram.conversionFactor;
                                let fmtVal = numberFormat(parseFloat(val),fmt_4_decimal_places);
                                /* Update the "distributor rates" (currency converted) in the "objProgram" object */
                                item1['rateCustConverted_'+shipTo] = fmtVal;
                            }
                            exitLoop = 1;
                            return true; //exit loop
                        }
                    });
                }
                if(exitLoop == 1){
                    return true;//exit the outer loop as well
                }
            });
        }
    }

    /* It gets called to check whether the item is already added to the "prodRate" array.
    If not, then this function calls the "addProdRate" function to add that product to the "prodRate" array. */
    function addProdRateObjForNewCompAndItemCombination(arrItems){
        let arrayProdList = [];

        /* Loop through the products */
        arrItems.forEach(function(item){

            /* Loop through the components in the program */
            objProgram.components.forEach(function(item1){

                /* If the "prodRate" exists, i.e. rate has already been added for at least
                one product for this component. */
                if(item1.prodRate){
                    let prodRatesGUID = [];

                    /* Get a list of products for this component, which already have a rate. */
                    item1.prodRate.forEach(function(item2){
                        prodRatesGUID.push(item2.itemGuid);
                    })

                    /* If the product does not not already have a rate for this component. */
                    if($.inArray(item.itemGuid, prodRatesGUID) == -1){
                        if($.inArray(item.itemGuid, arrayProdList) == -1){
                            /* Create an array of products from the products passed to this function, for which rates does not
                            already exist for any component which exist in the program. */
                            arrayProdList.push(item.itemGuid);
                        }
                    }
                }
                /* If rate does not exist for any product for this component. */
                else{
                    if($.inArray(item.itemGuid, arrayProdList) == -1){
                        /* "arrayProdList" will store list of products for which rate does not exist for any
                        component added to the progran (including the action of clicking "add component") */
                        arrayProdList.push(item.itemGuid);
                    }
                }
            });

        });

        /* Loop through the selected records and call the "addProdRate" function
        for the products in the "arrayProdList" array. */
        arrItems.forEach(function(item){
            if($.inArray(item.itemGuid, arrayProdList) != -1){
                addProdRate(item);
            }
        });
    }

    function showHideCurrencyConversion(){
        let chBoxVal = $("input:checkbox[name=chCAD]:checked").val();

        columnDefs_ratesGrid.forEach(function(item){
            if(item.children){
                item.children.forEach(function(item1){
                    /* Hide/Show the "cad/cnd" (Canadian currency) column for the "rates"  and "distrbutor rates" columns (if any)*/
                    if(item1.headerName == <cfoutput>'#GetCurrency.Currency_Code#'</cfoutput>){
                        if(chBoxVal){
                            Rate_GridOptions.columnApi.setColumnVisible(item1.field, true);
                        }
                        else{
                            Rate_GridOptions.columnApi.setColumnVisible(item1.field, false);
                        }
                    }
                });
            }
        });
    }

    function sanitize( str ) {
        return ( typeof str === "string" )
                    ? str.replace(/,/g, '')
                    : str;
    }

    /* We are using "arrObjSelectedComponent" here, because we download rates only for the selected component. */
    function downloadRates(){
        let s = '';
        let cr  = '|||';
        let pattern = /,/g;
        let prodRateList;

        /* Build the string */
        s = 'Item,Description,Rate,UOM,Volume,Price' + ',';
        if(arrObjSelectedComponent.fixedType == fixed_cust_rate_type_id){
             objProgram.distributors.forEach(function(cust){
                s = s + "Cust Rate " + cust.shipTo + ',';
             });
        }

        objProgram.arrPrdAttr.forEach(function(item){
            s = s + item.groupLevelDesc.toString().replace(pattern," ") + ',';
        });

        if(objProgram.template.bGroupDeal == true && <cfoutput>#appSettings.getTemplateMultipleProductAttrGroups()#</cfoutput>){
            s = s + 'Key' + cr;
        }
        else{
            s = s + 'Key' + cr; //s = s + cr;
        }
        Rate_GridOptions.api.forEachNodeAfterFilter(function(node, index){
            s = s + '="' + node.data.baItemDisplay + '"' + ',';

            let sDesc = node.data.Description.toString().replace(pattern,"");
            s = s + sDesc + ',';

            let nRateColumn = "rate_" + arrObjSelectedComponent.type + "_" + arrObjSelectedComponent.componentId;
            /* remove all commas to avoid validation problem */
            let nRate = sanitize( node.data[nRateColumn] );

            if ( isDollars( nRate ) === false ) {
                nRate = 0;
            }

            s = s + nRate + ',';

            let nUOMColumn = "uom_" + arrObjSelectedComponent.type + "_" + arrObjSelectedComponent.componentId;
            let nUOM = sanitize( node.data[nUOMColumn] );

            if ( isDollars( nUOM ) === false ) {
                sUOM = '';
            }
            else{
                /* Get the abbreviation for the UOM */
                arrObjComponentsDef.some(function(item){
                        item.uom.some(function(item1){
                            if(nUOM == item1.uomId){
                                sUOM = item1.abbreviation;
                                return true;// exit the loop
                            }
                        });
                        if(sUOM != ''){
                            return true;// exit the loop
                        }
                });
            }

            s = s + sUOM + ',';

            let nVolume = sanitize( node.data.volume );
            if ( isDollars( nVolume ) === false ) {
                nVolume = 1;
            }

            s = s + nVolume + ',';

            s = s + node.data.marketPrice + ',';

            if(arrObjSelectedComponent.fixedType == fixed_cust_rate_type_id){
                objProgram.distributors.forEach(function(itemDistributors){
                    let nDistRateColumn = "rateCust_" + arrObjSelectedComponent.type + "_" + arrObjSelectedComponent.componentId + "_" + itemDistributors.shipTo;
                    let nDistRate = sanitize( node.data[nDistRateColumn] );
                    if ( isDollars( nDistRate ) === false ) {
                        nDistRate = 0;
                    }
                    s = s + nDistRate + ',';
                });
            }

            objProgram.arrPrdAttr.forEach(function(item){
                s = s + node.data[item.productGroupAttributeNameField].toString().replace(pattern," ") + ',';
            });
            s = s + node.data.itemGuid + cr;
        });

        prodRateList = s;
        let sFilename = "Prod_Rates_" + objProgram.number + "_" + arrObjSelectedComponent.name +".csv";

        // Remove chars not allowed in Windows filename \ / : * ? " < > |
        sFilename = sFilename.replace(/[~\\\/:\*\?"<>\|]/g, "");

        // Trim leading and trailing whitespace.
        sFilename = sFilename.trim();

        document.frmProdRate.fileName.value = sFilename;
        document.frmProdRate.prodRateList.value = prodRateList;
        document.frmProdRate.submit();
    }

    function printDisplay(item){
        let objPrint = new Object();
        let objCustomPrint = item.customPrint;
        let objCustomprintCharge = item.customPrintCharge;

        let printColor = 0;
        let printGraphics = "";
        let printDigital = 0;
        let bGraphics = 'no';
        let printMakeReadyCharge = '0.00';
        let printPlateCharge = '0.00';
        let printPrePressCharge = '0.00';
        let printMinPriceCharge = '0.0000';

        if(item.customPrint != undefined && item.customPrintCharge != undefined){
            printColor = objCustomPrint.iColors;
            printGraphics = objCustomPrint.sGraphics;
            printDigital = objCustomPrint.bDigital;
            bGraphics = 'no';
            printMakeReadyCharge = objCustomprintCharge.printMakeReady;
            printPlateCharge = objCustomprintCharge.printPlate;
            printPrePressCharge = objCustomprintCharge.printPrePress;
            printMinPriceCharge = objCustomprintCharge.printMinPrice;
        }

        if(printDigital){
            bGraphics = 'yes';
        }

        printOptionsDisplay = 'color:' + printColor;

        printOptionsDisplay = printOptionsDisplay + ' graphics:' + printGraphics;

        printOptionsDisplay = printOptionsDisplay + ' digital:' + bGraphics;

        objPrint.printOptionsDisplay = printOptionsDisplay;

        let printChargesDisplay = printMakeReadyCharge
            + ' + ' + printPlateCharge+ ' + ' + printPrePressCharge
            + ' = ' + printMinPriceCharge;

        objPrint.printChargesDisplay = printChargesDisplay;

    return objPrint;
    }

    function updatePrintCharge(objItem){
        /* On data load */
        if(objItem != undefined){
            let objprintDisplay = printDisplay(objItem);
            return objprintDisplay;
        }

        /* On data update by the user (click "calculate") */
        else{
            /* Note: Below code will get called for the "selected" component (component dropdown) only.
            We are using "arrObjSelectedComponent" here, because "Custom print" feature is at the component lavel and will
            be available on the GUI based on whether "Custom print" feature is ON for the selected component. */

            let discountType = selectedDiscountType;
            let componentID = arrObjSelectedComponent.componentId;
            let printColor = $('select[name=cboColors] option:selected').val();
            let printGraphics = $('select[name=cboGraphics] option:selected').val();
            let printDigital = $("input:radio[name=rdoComplexGrp]:checked").val();

            let b = true;
            let s = 'Missing selections:';
            if(printColor == 0){
                s = s + '\n Please select # of colors.';
                b = false;
            }

            if(printGraphics == 0){
                s = s + '\n Please select a graphics complexity.';
                b = false;
            }

            if(printDigital == undefined){
                s = s + '\n Please select Yes or No for digital art.';
                b = false;
            }

            let arrSelectedRecords = Rate_GridOptions.api.getSelectedRows();
            let arrItems = [];

            /* Loop through selected records */
            arrSelectedRecords.forEach(function(item){
                if(item.customPrint.bCustomPrint == true){
                    let obj = new Object();
                    obj.itemGuid = item.itemGuid;
                    obj.volume	= item.volume;
                    arrItems.push(obj);
                }
            });

            if(arrItems.length == 0){
                s = s + "\n Please select (check ) Local Print products to apply custom print options to.";
                b = false;
            }

            if(b){
                let objComponentCustomPrint = new Object();

                objProgram.components.some(function(item){
                    /* Here the assumption is that the selected component (dropdown) is the one for which the
                        print rates are being updated. Reason - Client (IP) only adds one component to the "Custom print" programs.
                        "objComponentCustomPrint" in the below code gets updated with the options selected by the user. */
                    if(discountType == item.type){
                        if(componentID == item.componentId){
                            objComponentCustomPrint = item.customPrint;
                            objComponentCustomPrint.bCustomPrint = true;
                            objComponentCustomPrint.iColors = printColor;
                            objComponentCustomPrint.sGraphics = printGraphics;
                            objComponentCustomPrint.bDigital = printDigital;
                            return true; // exit loop
                        }
                    }
                });

                getCustomPrintData(
                    discountType,
                    componentID,
                    objComponentCustomPrint,
                    arrItems
                );
            }
            else{
                alert(s);
            }
        }
    }

    /* This function updates a number of objects and variables realed to custom print,custom print charges and some market price variables
    like RateMP etc in "objProgram.components" object.
    "objProgram.components" gets sent to the database, when the user clicks on "Save".
    Note: Technically, "forEach" is not considered a loop in javascript and so we cannot use a "break" statement.
    Instead of "forEach", "some" is being uzsed below. Using "return true" with ".some" works as a "break" statement
    and stops the loop. */
    function updatePrintOptions(discountType,componentID,responseCustomPrint){
        let objCPC = responseCustomPrint.customPrintCharge;
        let objCP = responseCustomPrint.customPrint;
        let exitLoop = 0;

        objProgram.components.some(function(item){
            /* For the selected component, set the updated "paid To". */
            if(discountType == item.type){
                if(componentID == item.componentId){
                    item.prodRate.some(function(item1){
                        if(item1.itemGuid == responseCustomPrint.itemGuid){
                            item1.rateMPOrig = responseCustomPrint.rateMPOrig;
                            /*set PrintMinPrice based on UOM
                                * only if it has an MP Rate
                                * if it is a new component (no rates set yet, default the rate to the min Price	*/
                            //If we found an upcharge
                            if( objCPC.printMinPrice > 0){
                                item1.customPrint = objCP;
                                item1.customPrintCharge = objCPC;

                                //converted items do not have a MP so use the one stored on the program
                                if(item1.rateMP == 0 || isNaN(item1.rateMP) == true){
                                    item1.rateMP 	= responseCustomPrint.marketPrice;
                                    item1.rateMPCS 	= responseCustomPrint.marketPriceCS;
                                    item1.rateMPLB 	= responseCustomPrint.marketPriceLB;
                                }
                                if(item1.uom.uomId == 0){
                                    item1.uom = item1.uomMP;
                                }
                                if(item1.uom.uomId == 1){
                                    item1.rateMPCustom = objCPC.printMinPriceCS;
                                }
                                else{
                                    item1.rateMPCustom = objCPC.printMinPriceLB;
                                }
                                exitLoop = 1;
                                return true; // exit loop
                            }
                        }
                    });
                }
            }
            if(exitLoop == 1){
                return true;//exit the outer loop as well
            }
        });
    }

    function getPrintGroups(){
        let arrItems = [];
        let arrItemsTmp = [];
        let arrItemsPartType= [];

            /* Get Type_Code_desc (Part Type) for the groups with rates and "None" */
            objProgram.components.forEach(function(item1){
                /* Only loop through products which have a rate */
                item1.prodRate.forEach(function(item2){
                    let rowNode = Rate_GridOptions.api.getRowNode(item2.itemGuid);
                        if(rowNode.data.isGroup && item2.rate > 0 && arrItemsPartType.indexOf(rowNode.data.Type_Code_desc) == -1
                            && rowNode.data.Type_Group_desc == "NONE"){
                            arrItemsPartType.push(rowNode.data.Type_Code_desc);
                        }
                })
            })

            Rate_GridOptions.api.forEachNode(function(node){
                let rowNode = Rate_GridOptions.api.getRowNode(node.data.itemGuid);

                    if(rowNode.data.isGroup && rowNode.data.Brand_Name == 'Local Print'){
                        if(arrItemsTmp.indexOf(rowNode.data.Type_Group_desc)== -1 &&
                            arrItemsPartType.indexOf(rowNode.data.Type_Code_desc) != -1 &&
                            rowNode.data.Type_Group_desc != "NONE"){
                                arrItems.push(rowNode.data.Type_Group_desc);
                                arrItemsTmp.push(rowNode.data.Type_Group_desc);
                        }
                    }

            })

            assignPrintGroups(arrItems);
    }

    function assignPrintGroups(arrItems){
        arrItems = arrItems.sort();

        $("#cboToPrinGroup" + " option").remove();//clear all the options
        $("#cboToPrinGroup").append('<option value="0">Print Group</option>');

        /* Populate "Print Group" dropdown. */
        for(let i= 0; i< arrItems.length; i++){
            $("#cboToPrinGroup").append('<option value="' + arrItems[i] + '">' + arrItems[i] + '</option>');
        }
    }

    /* We are using "arrObjSelectedComponent" here, because "Custom print" feature is at the component lavel and will
    be available on the GUI based on whether "Custom print" feature is ON for the selected component. */
    function convertItems(TypeGroupDesc){
        let stopProcessing = 0;
        let emptyPrintObject =  new Object();
        let objEmptyPrintDisplay = printDisplay(emptyPrintObject);
        let n = 0;

        objProgram.components.forEach(function(comp){
            if(comp.type == arrObjSelectedComponent.type){
                if(comp.componentId == arrObjSelectedComponent.componentId){

                    /* Only loop through products which have a rate */
					let prObjlen = comp.prodRate.length;
                    for (let i = 0; i < prObjlen; i++){
						let prodRate = comp.prodRate[i];
                        let noneRowNode = Rate_GridOptions.api.getRowNode(prodRate.itemGuid);

                        if(prodRate.rate > 0 && noneRowNode.data.Type_Group_desc == "NONE"){ //Print Group

                            Rate_GridOptions.api.forEachNode(function(newPGRowNode){
                                /* Since we cannot break loop inside "forEachNode", use the "stopProcessing" (bit column)  logic
                                to not process below code unnecessarily. */
                                if(stopProcessing == 0){
                                    let newPGRow = Rate_GridOptions.api.getRowNode(newPGRowNode.data.itemGuid);
                                    /* Find the entry where the "part type" matches */
                                    if(newPGRow.data.isGroup && newPGRow.data.Type_Code_desc == noneRowNode.data.Type_Code_desc){ //Part Type
                                        /* Find the entry where the "Print Group" matches the selected (dropdown) "Print Group". */
                                        if(newPGRow.data.Type_Group_desc == TypeGroupDesc){//Print Group
                                            /* Find the entry where the "Print Type" matches */
                                            if(newPGRow.data.Brand_Name == noneRowNode.data.Brand_Name){ // Print Type

                                                /* Get the item (prodRate) for which we have a rate but "Print Group" is "NONE".
                                                Note: To clone an object, use below code. By using new object(), the memory refernce stays. */
                                                let prodRateNew = JSON.parse(JSON.stringify(prodRate));

                                                /* Get the itemGuid,Description of the matching entry */
                                                prodRateNew.itemGuid = newPGRow.data.itemGuid;
                                                prodRateNew.itemNumber = newPGRow.data.baItem;
                                                prodRateNew.description = newPGRow.data.Description;

                                                /* Add an entry to the "prodRate" pbject with the new data.
                                                This is the Objective -
                                                1. First we take the prodRate object of the item for which we have a rate but "Print Group" is "NONE".
                                                2. Then for the matching entry (based on "Part Type","Print Type" and "Print Group" from
                                                the selected (dropdown) "Print Group".
                                                3. The matching item is the real item (added recently in the database). The old item (for which there is a rate) was added
                                                temporarily earlier. We now need to take the "prodRate" object of the old item and add it to the matching comp.
                                                Then we need tp set the rate of the old item to 0, as we do not need the old item anymore. We will also reset
                                                the print options and print charges of the old item by removing the "customPrint" and "customPrintCharge" objects
                                                from thge mathching comp. */
                                                comp["prodRate"].push(prodRateNew);

                                                //stopProcessing = 1;

                                                /* Update the rate and related data on the grid for the matching entry */
                                                newPGRow.data['rate_'+comp.type+'_'+comp.componentId] = numberFormat(parseFloat(prodRateNew.rate),fmt_4_decimal_places);
                                                newPGRow.data['uom_'+comp.type+'_'+comp.componentId] = prodRateNew.uom.uomId;
                                                newPGRow.data['volume'] = numberFormat(parseFloat(prodRateNew.volume),fmt_no_decimal_places);

                                                //does this get updated before or do we ned the logic to look for cs or lb??
                                                newPGRow.data['marketPrice_'+comp.type+'_'+comp.componentId] = numberFormat(parseFloat(prodRateNew.rateMP),fmt_4_decimal_places);
                                                newPGRow.data['varianceMP_'+comp.type+'_'+comp.componentId] = numberFormat(parseFloat((prodRateNew.rateMP * (prodRateNew.rate/100))),fmt_4_decimal_places);

                                                let objprintDisplay = printDisplay(prodRateNew);
                                                newPGRow.data['customPrint_'+comp.type+'_'+comp.componentId] = objprintDisplay.printOptionsDisplay;
                                                newPGRow.data['customPrintCharge_'+comp.type+'_'+comp.componentId] = objprintDisplay.printChargesDisplay;

                                                /* Call "setCustomPrintCharges" to show the "variance" and "Disc%" on the grid based on the
                                                difference between rate and custom print charges. */
                                                setCustomPrintCharges(comp,prodRate,newPGRow);

                                                /* Update the rate and related data on the grid for the old entry (zero rates and no print options and no print display) */
                                                noneRowNode.data['rate_'+comp.type+'_'+comp.componentId] = 0;
                                                noneRowNode.data['customPrint_'+comp.type+'_'+comp.componentId] = objEmptyPrintDisplay.printOptionsDisplay;
                                                noneRowNode.data['customPrintCharge_'+comp.type+'_'+comp.componentId] = objEmptyPrintDisplay.printChargesDisplay;

                                                /* Set the rate to zero for the old item. We do not need this item anymore.
                                                It was just a temporary placeholder for the mathcing item. */
                                                prodRate.rate = 0;

                                                /* We do not need the "customPrint" and "customPrintCharge" objects for the old item.
                                                We do not need this item anymore. It was just a temporary placeholder for the mathcing item. */
                                                delete prodRate["customPrint"];
                                                delete prodRate["customPrintCharge"];

                                                n = n + 1;

                                                Rate_GridOptions.api.refreshCells();
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    }
                }
            }
        })
        alert( n + ' group(s) converted to: ' + TypeGroupDesc);
        /* Rerun Filter to show records with "Rates". Note: We now need to show the records which was updated with the rate.
        The old record which now has a rate of 0, will automatically filter out, once the "rate" filter in ON. The old record will
        also get deleted, once the user clicks on "Save", as records with zero rates are deleted on save. */
        filterOnLoad();
    }

    /* When a user changes the volume, we call this function to update the custom print charges. */
    function getPrintMinPrice(objProdRate){
        let customPrintCharges = new Object();
        let printMakeReady = objProdRate.customPrintCharge.printMakeReadyBase / (objProdRate.volume);
        let printPlate = objProdRate.customPrintCharge.printPlateBase * objProdRate.customPrint.iColors/(objProdRate.volume);
        let printPrePress =  objProdRate.customPrintCharge.printPrePressBase / (objProdRate.volume);
        let printMinPrice =  (printMakeReady + printPlate + printPrePress + objProdRate.rateMP);

        customPrintCharges.printMakeReady = numberFormat(parseFloat(printMakeReady),fmt_2_decimal_places);
        customPrintCharges.printPlate = numberFormat(parseFloat(printPlate),fmt_2_decimal_places);
        customPrintCharges.printPrePress = numberFormat(parseFloat(printPrePress),fmt_2_decimal_places);
        customPrintCharges.printMinPrice = numberFormat(parseFloat(printMinPrice),fmt_4_decimal_places);

    return customPrintCharges;
    }

    function getCustomPrintData(discountType,componentID,objComponentCustomPrint,arrItems){
        $.ajax({
            url: "/mvc/models/Item/ItemSearchService_Groups.cfc"
            ,type: "POST"
            ,dataType: "json"
            ,data: {ProgramId: <cfoutput>'#url.programID#'
                    ,StatusFilterOn: #statusFilterOn#
                    ,bAll: 0
                    ,bMP: 0
                    ,TemplateFiltersID: #url.TemplateFiltersID#
                    ,customPrint: JSON.stringify(objComponentCustomPrint)
                    ,aItems: JSON.stringify(arrItems)
            </cfoutput>
            ,method: "getCustomPrintItemsJSON"
            }
            ,success: function( responseCustomPrint ) {
                responseCustomPrint.forEach(function(item2){
                    let rowNode = Rate_GridOptions.api.getRowNode(item2.itemGuid);

                    item2.customPrintCharge.printMakeReady = numberFormat(parseFloat(item2.customPrintCharge.printMakeReady),fmt_2_decimal_places);
                    item2.customPrintCharge.printPlate = numberFormat(parseFloat(item2.customPrintCharge.printPlate),fmt_2_decimal_places);
                    item2.customPrintCharge.printPrePress = numberFormat(parseFloat(item2.customPrintCharge.printPrePress),fmt_2_decimal_places);
                    item2.customPrintCharge.printMinPrice = numberFormat(parseFloat(item2.customPrintCharge.printMinPrice),fmt_4_decimal_places);

                    if(rowNode != undefined){
                        let objPrint = updatePrintCharge(item2);
                        rowNode.data['customPrint_'+discountType+'_'+componentID] = objPrint.printOptionsDisplay;
                        rowNode.data['customPrintCharge_'+discountType+'_'+componentID] = objPrint.printChargesDisplay;
                        Rate_GridOptions.api.refreshCells(rowNode);

                        updatePrintOptions(discountType,componentID,item2);
                    }
                });
                /* Call this function for initial load only */
                if(arrItems.length){
					//
                    // setDefaultPrintOptionsAndChargesforProducts(discountType,componentID);
                }
            }
        });
    }
    function setCustomPrintCharges(comp,prodRate,newPGRowNode){
        /* Look for whether the print options already exist */
        if(prodRate.customPrint && ('iColors' in prodRate.customPrint != 0)){
            let objPrint = new Object();
            let updatedPrintChargesObject = new Object();

            /* Since "objPrint" does not have a "customPrint" object, add the customPrint" object. This is actually not needed for
            updating the "print options", but it is needed as the "printDisplay" needs a "customPrint" object.
            Note: Changing volume only updates the print charges which is based on print options, volume and market price. */
            objPrint.customPrint = prodRate.customPrint;
            objPrint.customPrintCharge = prodRate.customPrintCharge;

            /* Here we get the updated "customPrintCharge" Object.
            Note: For some reason, the "getPrintMinPrice" is made to update 4 properties only - printMakeReady,printPlate,printPrePress,printMinPrice.*/
            updatedPrintChargesObject.customPrintCharge = getPrintMinPrice(prodRate);

            objPrint.customPrintCharge.printMakeReady = updatedPrintChargesObject.customPrintCharge.printMakeReady;
            objPrint.customPrintCharge.printPlate = updatedPrintChargesObject.customPrintCharge.printPlate;
            objPrint.customPrintCharge.printPrePress = updatedPrintChargesObject.customPrintCharge.printPrePress;
            objPrint.customPrintCharge.printMinPrice = updatedPrintChargesObject.customPrintCharge.printMinPrice;

            /* Pass the updated object */
            let objprintDisplay = printDisplay(objPrint);

            let rowNode = Rate_GridOptions.api.getRowNode(newPGRowNode.data.itemGuid);

            /* Note: IP (Client) only has one component on the program, when "custom print" feature is ON and so we
            could have used the "arrObjSelectedComponent" logic, rather than "comp". Both should work. */
            rowNode.data['customPrintCharge_'+comp.type+'_'+comp.componentId] = objprintDisplay.printChargesDisplay;

            /* Update the "customPrintCharge" object in "prodRates". This is sent to the server. */
            prodRate.customPrintCharge = objPrint.customPrintCharge;

            prodRate.rateMPCustom = prodRate.customPrintCharge.printMinPrice;

            /* fixed price */
            if(comp.type == fixed_type_id){
                /* Variance is now based on "rateMPCustom", rather than "rateMP" */
                prodRate.varianceMP = prodRate.rateMPCustom - prodRate.rate;
                prodRate.variancePercMP = (prodRate.varianceMP/prodRate.rateMPCustom)*100;
            }
            /* Rebate */
            else{
                prodRate.varianceMP = prodRate.rate;
                prodRate.variancePercMP = (prodRate.varianceMP/prodRate.rateMPCustom)*100;
            }

            /* set the new variance values on the grid */
            rowNode.data['varianceMP_'+comp.type+'_'+comp.componentId] = numberFormat(parseFloat(prodRate.varianceMP),fmt_4_decimal_places);
            rowNode.data['variancePercMP_'+comp.type+'_'+comp.componentId] = numberFormat(parseFloat(prodRate.variancePercMP),fmt_2_decimal_places);

            Rate_GridOptions.api.refreshCells();
        }
    }

    var uploadfileWindow;
    function uploadCSV(){
        uploadfileWindow = NewWindow("uploadfile.cfm", "upload","600","300","yes","yes","0");
    }

    function processFileData(arrInput){
        let arrInvalidItemsList = [];

        /* If we just use "show_loader("PLEASE WAIT...");" at the top of this function, the show_loader code will not work, as expected.
        To see show_loader before heavy duty javasscript code like this function, we need to use "loadChain". This will make sure
        step 1 is called first and then step 2 and so on. Using loadChain, show_loader actually works.*/
            var loadChain = new LoadChain();

            /* STEP 1 */
            loadChain.push(function() { show_loader("PLEASE WAIT..."); });

            /* STEP 2. Deleted - it created SCRIPT18 error in IE, spinner would not stop */

            /* STEP 3. Note - This step actually should be a function by itself, but "loadChain" required that the code be put here directly and
            not call any function, which had below code.
            */
            loadChain.push(function() {
                let arrayOfarrInput = [];
                let arrayOfarrFinal = [];
                let bDistribututorRatesOn = false;
                let arrColumnHeaders = [];
                let shipTo;
                let uniqueColumnID;
                let arrItem = [];
                let item_Guid;
                let UOMAbbreviation;
                let rateCustConversionValue;
                let objArrayItem;
                let ObjArrayItemList = [];
                let guidIndex = 0;

                /* Loop through the data aray and create an array for every element of the array. This is important so that
                we can loop through the data easily.
                */
                arrInput.forEach(function(item){
                    arrayOfarrInput.push(item.split(","));
                });

                /* The first element of the "arrayOfarrInput" array, contains the column headers. */
                arrColumnHeaders = arrayOfarrInput[0];
                arrColumnHeaders[arrColumnHeaders.length -1] = arrColumnHeaders[arrColumnHeaders.length -1].replace(/[\n\r]/g, '');  //remove carriage return
                guidIndex = arrColumnHeaders.indexOf("Key");
                /* Get a list of GUID's, which the user is trying to upload. */
                arrayOfarrInput.forEach(function(data,index){
                    /* Skip the first element, as it contains the header. */
                    if(index > 0 && data[2] != 0){
                        objArrayItem = new Object();
                        /* Data from the last column in the CSV file. It is the "key" column and has the GUID.
                        The replace function removes the new line character from the GUID column. It has the new line
                        character, as it is the last column on the file. */
                        objArrayItem.itemGuid = data[guidIndex].replace(/[\n\r]/g, '');
                        arrItem.push(objArrayItem);
                        /* This array (arrayOfarrFinal) will only have those entries, which have a rate. We do not want to
                        loop through all the rows of the file. */
                        arrayOfarrFinal.push(data);
                    }
                });
                /* arrItem only has the "itemGuid" property, but the "addProdRateObjForNewCompAndItemCombination" function
                (actually the "addProdRate" function, which is called by "addProdRateObjForNewCompAndItemCombination") needs
                all the item attributes and so we loop through the grid and get those pproperties. */
                arrItem.forEach(function(item){
                    Rate_GridOptions.api.forEachNode(function(node){
                        if(node.data.itemGuid == item.itemGuid){
                            ObjArrayItemList.push(node.data);
                        }
                    })
                })
                /* In case the "prodRate" object does not already exist for any product, add the "prodRate" object first. */
                addProdRateObjForNewCompAndItemCombination(ObjArrayItemList);

                arrayOfarrFinal.some(function(data,index){
                    /* Data from the last column in the CSV file. It is the "key" column and has the GUID.
                    The replace function removes the new line character from the GUID column. It has the new line
                    character, as it is the last column on the file. */
                    item_Guid = data[guidIndex].replace(/[\n\r]/g, '');
                    objProgram.components.some(function(item){
                        if(item.prodRate !== undefined){
                        item.prodRate.some(function(item1){
                            if(item_Guid == item1.itemGuid){
                                /* We are using "arrObjSelectedComponent", because the upload is for the selected component on the dropdown. */
                                if(item.type == arrObjSelectedComponent.type){
                                    if(item.componentId == arrObjSelectedComponent.componentId){

                                        let rowNode = Rate_GridOptions.api.getRowNode(item1["itemGuid"]);

                                        let objInvalidItemsList = new Object();

                                        if(rowNode != undefined){
                                            // remove special characters in data
                                            item1[ "rate" ] = sanitize( numberFormat(parseFloat(data[2]),fmt_4_decimal_places) );

                                            UOMAbbreviation = data[3];
                                            /* Get the UOM object based on UOM description */
                                            arrObjComponentsDef.some(function(itemComp){
                                                item.uom.some(function(itemUOM){
                                                    if(UOMAbbreviation == itemUOM.abbreviation || UOMAbbreviation == itemUOM.description){
                                                        item1["uom"] = itemUOM;
                                                        return true;// exit the loop
                                                    }
                                                });
                                            });
                                            // remove special characters in data
                                            item1["volume"] = sanitize( numberFormat(parseFloat(data[4]),fmt_no_decimal_places) );

                                            bDistribututorRatesOn = getIsDistributorRatesOn(item);

                                            if(bDistribututorRatesOn == true){
                                                /* Look through the column headers. */
                                                arrColumnHeaders.some(function(itemDist,indexDist){
                                                    /* Look for the Customer rate column headers */
                                                    if(itemDist.indexOf('Cust Rate') != -1){
                                                        shipTo = itemDist.split(" ");
                                                        shipTo = shipTo[2];
                                                        objProgram.distributors.some(function(itemDistributors){
                                                            /* Verify that the distributor is on the program. */
                                                            if(itemDistributors.shipTo == shipTo){
                                                                /* "indexDist" is index of the column for the shipTo.  */
                                                                item1['rateCust_'+shipTo] = sanitize( numberFormat(parseFloat(Number(data[indexDist])),fmt_4_decimal_places) );
                                                                if(objProgram.bHasConversionFactor){
                                                                    let rateCustConversionValue = Number(data[indexDist]) * objProgram.conversionFactor;
                                                                    // remove special characters in data
                                                                    item1['rateCustConverted_'+shipTo] = sanitize( numberFormat(parseFloat(rateCustConversionValue),fmt_4_decimal_places) );
                                                                }
                                                                return true;// exit the loop
                                                            }
                                                        });
                                                    }
                                                });
                                            }

                                            uniqueColumnID = arrObjSelectedComponent.type+'_'+arrObjSelectedComponent.componentId;
                                            rowNode.data['volume'] = item1["volume"];
                                            rowNode.data['rate_'+uniqueColumnID] = item1["rate"];
                                            rowNode.data['uom_'+uniqueColumnID] = item1["uom"].uomId;

                                            let customerRate;
                                            objProgram.distributors.forEach(function(itemDistributors){
                                                customerRate = item1['rateCust_' + itemDistributors.shipTo];
                                                if(customerRate != undefined){
                                                    rowNode.data['rateCust_'+uniqueColumnID +'_' + itemDistributors.shipTo] = customerRate;
                                                    if(objProgram.bHasConversionFactor){
                                                        rowNode.data['rateCustConverted_'+uniqueColumnID +'_' + itemDistributors.shipTo] = customerRate * objProgram.conversionFactor;
                                                    }
                                                }
                                            });

                                            /* Every component has a prodrate array. The prodrate stores data at a product level. When updating rate, uom etc, the change is
                                            made to the prodrate for the selected component. Volume is an exception. Once volume is modified for a component, it needs to
                                            be updated for all the componnets on the program. This way we can be sure that the data will be saved correctly, always.
                                            Below code updates volume for all the components.
                                            Note: We are looping through "objProgram.components" a second time. */
                                            objProgram.components.some(function(itemComp){
                                                itemComp.prodRate.some(function(itemProdRate){
                                                    if(item_Guid == itemProdRate.itemGuid){
                                                        /* For every component regardless of discount type, set the volume to be the new volume for the product.
                                                        This is how the "prodRate" stores data. Actually, volume is stored at the product level and not the
                                                        component level, but this is how it was done on Flex. */
                                                        itemProdRate.volume = item1["volume"];
                                                    }
                                                });
                                            });

                                            /* Call this function manually. If we would have used "setRowData", instead of "rowNode.data", then the ",onCellValueChanged"
                                            function would be automatically called and below function does not need to be called manually. We canot use "setRowData",
                                            as it is very slow, when we are dealing with a lot of records. */
                                            setVarianceAndDiscountValue(arrObjSelectedComponent.type,rowNode.data,'varianceMP_'+uniqueColumnID, 'variancePercMP_'+uniqueColumnID, 'marketPrice_'+uniqueColumnID, 'rate_'+uniqueColumnID, 'uom_'+uniqueColumnID);
                                            Rate_GridOptions.api.refreshCells();
                                        }
                                        else{
                                            /* If the item is not available on the grid, then it is an invalid item. */
                                            objInvalidItemsList.itemNumber = data[0];
                                            objInvalidItemsList.description =  data[1],
                                            objInvalidItemsList.rate = data[2];
                                            /* Populate the array with invalid items (if any) */
                                            arrInvalidItemsList.push(objInvalidItemsList);
                                        }
                                    }
                                }
                                /* exit the inner loop (item.prodrate). */
                                return true;
                            }
                        });
                    }
                    });
                });
                    hide_loader();
            });  // Load chain (STEP 3 ends)

                /* STEP 4 - Close the popup page woich uploads the file. If we do this as a first step, then
                the file data does not get processed (the main lofic of this function), i.e. STEP 3 */
                loadChain.push(function() { uploadfileWindow.close(); });

                /* STEP 5 - 	Rerun Filter to show records with "Rates". If the user added products which did not have a rate earlier, then we can
                view those records as well. */
                loadChain.push(function() { filterOnLoad()});

                /* STEP 6 -  Show the invalid products popup. (If there any invalid products). */
                loadChain.push(function() { showItemIds(arrInvalidItemsList)});

            /* THis step starts the sequence of steps from STEP 1. */
            loadChain.start();
    }
    function less_than_or_equal( str_1, str_2 ) {
		if ( parseFloat( str_1.replace(/,/g, '') ) <= parseFloat( str_2.replace(/,/g, '') ) ) {
			return true;
		}
        return false;
    }
    </script>

    <form name="frmProdRate" id="frmProdRate" method="post" action="/flex/csv_Report.cfm">
        <input type="hidden" name="fileName" />
        <input type="hidden" name="prodRateList" />
    </form>