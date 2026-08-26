<cfparam name="form.Delete_Product_ID" default="">
<cfparam name="form.Is_Like_Product_Exist" default="0">
<cfparam name="form.thisItemID" default="">

<cf_cryp type="de" key="#request.key#" string="#URL.CID#">

	<cfset ProdManager = CreateObject("component", "components.products.ProductManager").init()>

<!---  Delete previous products only if the same product existed in lumpsum discount type --->
		<cfif form.Is_Like_Product_Exist eq 1>
						<cfloop list="#form.thisItemID#" index="LikeProd">
							<cfset Existing_LikeProduct = ProdManager.getSimilarExistingProduct('#cryp.value#', '#ListgetAt(LikeProd,2,"_")#')>
								<cfif Existing_LikeProduct.Recordcount neq 0>
											<cfset ProdManager.setDeleteSimilarExistingProduct('#cryp.value#','#ListgetAt(LikeProd,2,"_")#')>
								</cfif>
						</cfloop>	

<!--- Add Products (These products are generic and not related to any discount type) --->
					<cfloop list="#form.thisItemID#" index="LikeProd">
							<cfloop list="#Delete_Product_ID#" index="DeleteProdID">
									<cfif ListgetAt(LikeProd,1,"_") eq DeleteProdID>
										<cfset ProdManager.setSimilarExistingProduct('#cryp.value#','#ListgetAt(LikeProd,2,"_")#')>
									</cfif>
							</cfloop>
					</cfloop>
		</cfif>

	<CFLOCATION URL="select_lumpsum_products.cfm?CID=#URL.CID#&Program_Lump_Sum_ID=#FORM.Program_Lump_Sum_ID#">