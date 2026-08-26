<cfsilent>
<!---
* ==================================================================================================== 
*    @File: Programs/product/Rate_Header_Template.cfm
*  @Author: Sharon Harris
*    @Date: Dec-2019
* 
* @Remarks: This file displays the header bar for the Program Rates page, when coming from the Tempate area
*           
*			Based on Common_Files\contracts\minimal_contract_info.cfm
*
* ====================================================================================================
--->

<cfset MARKETPRICE_TITLE = 'Market Price Rates' >
</cfsilent>

<div id="header" class="flex font-semibold mb-1 p-2" style="background-color:#ffce84">
		<cfoutput>
		<span>
			<!--- #GetContractInfo.Contract_Number# &nbsp;&nbsp;|&nbsp;&nbsp;&nbsp;  --->
			Program Number &nbsp;&nbsp;|&nbsp;&nbsp;&nbsp; Program Title &nbsp;&nbsp;&nbsp; | &nbsp;&nbsp;&nbsp;

			#MARKETPRICE_TITLE#
		</span>
	</cfoutput>
</div>