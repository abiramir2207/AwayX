
// specify the columns
// Program Search-like data
var columnDefs = [
    {
        headerName: "Status", 
        field: "status",
        // headerCheckboxSelection: true,
        // headerCheckboxSelectionFilteredOnly: true,
        // checkboxSelection: true,
        unSortIcon: true
    },
    {headerName: "RFA", field: "rfa", unSortIcon: true},
    {headerName: "Program", field: "program", unSortIcon: true},
    {headerName: "Title", field: "title", unSortIcon: true},
    {headerName: "Type", field: "templateT", unSortIcon: true},
    {headerName: "Start Date", field: "startD", type: "dateColumn", unSortIcon: true},
    {headerName: "End Date", field: "endD", type: "dateColumn", unSortIcon: true},
    {headerName: "RSP", field: "rsp", unSortIcon: true},
    {headerName: "Committed", field: "committed", type: "numericColumn", unSortIcon: true},
    {headerName: "Payment $", field: "payment", type: "numericColumn", unSortIcon: true},
    {headerName: "Volume", field: "volume", type: "numericColumn", unSortIcon: true},
    {headerName: "More Info", field: "moreI"}
];

// specify the data
var rowData = [
    {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", endD: "01/01/2017", rsp: "Kelly Cole", committed: 0.00, payment: 0.00, volume: 0, moreI: "preview, details"},
    {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", endD: "01/01/2017", rsp: "Kelly Cole", committed: 0.00, payment: 0.00, volume: 0, moreI: "preview, details"},
    {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", endD: "01/01/2017", rsp: "Kelly Cole", committed: 0.00, payment: 0.00, volume: 0, moreI: "preview, details"},
    {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", endD: "01/01/2017", rsp: "Kelly Cole", committed: 0.00, payment: 0.00, volume: 0, moreI: "preview, details"},
    {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", endD: "01/01/2017", rsp: "Kelly Cole", committed: 0.00, payment: 0.00, volume: 0, moreI: "preview, details"},
    {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", endD: "01/01/2017", rsp: "Kelly Cole", committed: 0.00, payment: 0.00, volume: 0, moreI: "preview, details"},
    {status: "RFA", rfa: "119", program: "[PRG-10000281]", title: "National Pricing List", templateT: "PR00 National Price List", startD: "01/01/2017", endD: "01/01/2017", rsp: "Kelly Cole", committed: 0.00, payment: 0.00, volume: 0, moreI: "preview, details"},

];

// let the grid know which columns and what data to use
var gridOptions = {
    columnDefs: columnDefs,
    rowData: rowData,
    enableSorting: true,
    enableFilter: false,
    enableColResize: true,
    rowHeight: 20,
    headerHeight: 22,
    onGridReady: function () {
        gridOptions.api.sizeColumnsToFit();
    }
};

// used in our jasmine test
function selectAllRows() {
    gridOptions.api.selectAll();
}

// wait for the document to be loaded, otherwise ag-Grid will not find the div in the document.
document.addEventListener("DOMContentLoaded", function () {
    // lookup the container we want the Grid to use
    var eGridDiv = document.querySelector('#myGrid');

    // create the grid passing in the div to use together with the columns & data we want to use
    new agGrid.Grid(eGridDiv, gridOptions);
});