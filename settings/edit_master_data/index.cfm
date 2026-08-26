<cfparam name="url.type" default="Product" >

<cfmodule template="/customTags/layout.cfm"
							layoutID = "editMasterData"
							margin = "10px;"
							selectedIndex = "#(url.type eq 'product' ? 0 : 1)#" >

<style type="text/css">
#header{background-color:#ccc;border:1px solid #CDCDCD;width:100%;height:20px;font-weight: bold;margin-top:10px;}
#link{float:left;width:150px;text-align:center;border-right:1px solid #CDCDCD;padding-top:2px;padding-bottom:2px;}
#current{background-color:#FFCE84; color:black;float:left;width:150px;text-align:center;border-right:1px solid #CDCDCD;padding-top:2px;padding-bottom:2px;}
</style>
		<cfoutput>
			<cfif url.type EQ "Distributor">
				<cfinclude template="Edit_distributor_Master_Data.cfm" >
			<cfelse>
				<cfinclude template="Edit_product_Master_Data.cfm" >
			</cfif>
		</cfoutput>
</cfmodule>