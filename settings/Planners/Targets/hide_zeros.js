/*
  * ==================================================================================================== 
  *    @File: \settings\planners\targets\hide_zeros.js
  *  @Author: Chris Nguyen
  *    @Date: July 2020
  * 
  * @Remarks: Hide zero original target revenue
  *
  * ==================================================================================================== 
*/
var show_what = 'non_zero'; 

function isExternalFilterPresent() {
    // if show_what is not all, then we are filtering
    return show_what != 'all';
}

function doesExternalFilterPass(node) {
    switch (show_what) {
        case 'non_zero': return glob.tab_name === "demos"
                                    ? node.data.SALES_TARGET_FINAL > 0
                                    : node.data.SALES_TARGET_ORIGINAL > 0 || node.data.SALES_TARGET_OVERRIDE > 0;
        default: return true;
    }
}

function externalFilterChanged(newValue) {
    show_what = newValue;
    glob.my_grid.api.onFilterChanged();
}

$("input[name=hide_zero]").click(function(){
    let selection = $(this).attr("checked") ? "non_zero" : "all";
    externalFilterChanged( selection );
});        

function numberParser(params) {
    return isNaN(params.newValue)
            ? null
            : Number(params.newValue);
}

function changes_made(p){
    if (Math.round(p.oldValue) !== Math.round(p.newValue)) {
        if (glob.tab_name) {
            parent.refresh_tab_name( glob.tab_name, 1 );
        }
        $("span.changes_made").show();
        $("div.ag-root-wrapper").addClass("grid_changed");
    }
}
