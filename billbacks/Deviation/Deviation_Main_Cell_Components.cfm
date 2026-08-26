<cfsilent>
    <!---
    * ==================================================================================================== 
    *    @File: billbacks\Deviation\Deviation_Main_Cell_Components.cfm
    *  @Author: Sharon Harris
    *    @Date: 19-Aug-2019
    * 
    * @Remarks: Billback Deviation Main - Cell components for the ag-Grid
    *			See https://www.ag-grid.com/javascript-grid-cell-editor/
    *           
    * ==================================================================================================== 
    --->
</cfsilent>
<script>
function maxLengthCellEditor() {}

maxLengthCellEditor.prototype.init = function(params) {
  this.eGui = document.createElement('div');
  this.eGui.innerHTML = '<input value='+params.value+' />';
  this.eInput = this.eGui.querySelector('input');
  this.eInput.addEventListener('input', this.inputChanged.bind(this));
  this.maxLength = params.maxLength;
}

maxLengthCellEditor.prototype.inputChanged = function(event) {
  // If too long, truncate it
  let val = event.target.value;
  if (this.isTooLong(val)) {
    event.target.value = val.substr(0, this.maxLength);
    alert("Only "+this.maxLength+" characters are allowed!");
  }
}
maxLengthCellEditor.prototype.isTooLong = function(value) {
  return (value.length > this.maxLength ? true : false);
}


maxLengthCellEditor.prototype.getValue = function() {
  return this.eInput.value;
}

maxLengthCellEditor.prototype.isCancelAfterEnd = function() {
  return false;
}

maxLengthCellEditor.prototype.getGui = function() {
  return this.eGui;
}
// focus and select the cell after the gui is attached
maxLengthCellEditor.prototype.afterGuiAttached = function() {
    this.eInput.focus();
    this.eInput.select();
};

maxLengthCellEditor.prototype.destroy = function() {
  this.eInput.removeEventListener('input', this.inputChanged);
}


</script>