
<cfsilent>
<!---
* ==================================================================================================== 
*    @File: Programs\product\Rate_Items_Popup.cfm
*  @Author: Sharon Harris
*    @Date: Jan-2020
* 
* @Remarks: Display popup window with Invalid Item IDs
*           
*
* ==================================================================================================== 
--->
</cfsilent>
<cfinclude template="/common_files/dhx_windows.cfm">

<script>

function showItemIds(arrInvalidItemsList){

	if (arrInvalidItemsList.length) {
		
		// Store invalid items array for use in the popup
		sessionStorage.setItem("invalidItems", JSON.stringify(arrInvalidItemsList));

		// unfocus the upload button, otherwise the tooltip was obscuring the popup
		document.getElementById("uploadRates").blur();

		dhx_popupInCenter( "/Programs/product/Rate_Items.cfm?invalidItems"
										,"Invalid Items"
										,440	// width
										,300	// height
									);
	}
}

</script>