<cfsilent>
<!---
* ==================================================================================================== 
*    @File: Programs\product\Rate_Main_Header_Components.cfm
*  @Author: Sharon Harris
*    @Date: 06-Dec-2019
* 
* @Remarks: ag-grid Header components for Program Rates
*           
* ==================================================================================================== 
--->
</cfsilent>

<script>

	// --------------------------------------------
	// Define the Group Header Component
	// Used to show the x icon in the group header, and to delete the component
	// 
	function CutHeaderGroup() {
	}

	// Append the "X" icon and show the title as the tooltip
	CutHeaderGroup.prototype.init = function (params) {
		this.params = params;
		this.eGui = document.createElement('div');
		this.eGui.className = 'ag-header-group-cell-label';
		this.eGui.innerHTML = '' +
			'<span class="ag-header-group-text center-text" ref="agLabel">' + this.params.displayName +
				'<i class="fa fa-times cursor-pointer btn-icon-red pl-1 pt-1" style="font-size:12px"' +
				'onclick="deleteComponent(' + this.params.discountTypeID+ "," + this.params.compID +')"' +
				'title="' + this.params.title + '"' +
			'</span>';	
	};

	CutHeaderGroup.prototype.getGui = function () {
		return this.eGui;
	};
	CutHeaderGroup.prototype.destroy = function () {
	};

</script>