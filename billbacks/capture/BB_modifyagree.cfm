<cfset useLakebaseForupdatemodifyagree = application.oLakebase.isEnabled() AND application.oLakebase.isTableMigrated("billback")>
<cfif useLakebaseForupdatemodifyagree>
	<cftry>
		<cfset application.oLakebase.updateRows("billback",
			{
				"billback_id" = "eq.#url.BBID#"
			},
			{
				"bb_modify_agree" = "1",
				"bb_modify_agree_user" = "#request.AccessStructure.user_id#"
			}
		)>
		<cfcatch type="any">
			<cfset useLakebaseForupdatemodifyagree = false>
		</cfcatch>
	</cftry>
</cfif>
<cfif NOT useLakebaseForupdatemodifyagree>
<CFQUERY NAME="updatemodifyagree" DATASOURCE="#application.datasource#">
update Billback
set BB_modify_agree = 1,
BB_Modify_Agree_User = '#request.AccessStructure.user_id#'
where Billback_Id = '#url.BBID#'
</CFQUERY>
</cfif>
	
<CFQUERY NAME="updatemodifyagree" DATASOURCE="#application.datasource#">
update BB_Agreed_Info
set deleted = 1
where Billback_Id = '#url.BBID#'
and user_id = '#request.AccessStructure.user_id#'
</CFQUERY>

<cfquery name="getBBOldProgramList" datasource="#application.datasource#">
	select program_id,contract_number
	from billback_program
	inner join contract_main on
	contract_main.contract_main_id = billback_program.program_id
	where Billback_Id = '#url.BBID#'
	and billback_program.deleted = 0
	order by program_id asc
</cfquery>
<cfif getBBOldProgramList.recordcount GT 0>
<cfset oldprogram_list = valuelist(getBBOldProgramList.program_id,",")>
<cfset oldprogramnum_list = valuelist(getBBOldProgramList.contract_number,",")>
<cfelse>
<cfset oldprogram_list = "">
<cfset oldprogramnum_list = "">
</cfif>

<cfquery name="updateBBModifyAgreeprogramList" datasource="#Application.Datasource#">
SET NOCOUNT ON
insert into BB_ModifyAgree_ProgramChanges
	(Billback_Id,From_ProgramId_List,From_ProgramNum_List,To_ProgramId_List,User_Id,active)
		values
	('#url.BBID#','#oldprogram_list#','#oldprogramnum_list#','','#request.AccessStructure.user_id#',1)
	
SELECT BB_ModifyAgree_PrgId = @@IDENTITY
SET NOCOUNT OFF
</cfquery>

<cfquery name="updateBBModifyAgreeproductList" datasource="#Application.Datasource#">
insert into BB_ModifyAgree_Productchanges
	(Billback_Id,BB_ModifyAgree_PrgId,Product_Id,Program_Id,From_BB_Rate,
	From_BB_Prod_Qty,BB_Prod_Type,From_BB_Prod_UOM)
	select '#url.BBID#','#updateBBModifyAgreeprogramList.BB_ModifyAgree_PrgId#',
	product_id,program_id,BB_Rate,BB_Product_Quantity,
	BB_Product_Type_Id,BB_Product_UOM
	FROM
	Billback_Product_Detail
	INNER JOIN Billback_Product
	ON Billback_Product.Billback_Product_ID = 	
	Billback_Product_Detail.Billback_Product_ID
	AND Billback_Product.Deleted = 0
	INNER JOIN Billback_Program
	ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
	and Billback_Program.deleted = 0
	where Billback_Product_Detail.Billback_ID = '#url.BBID#' 
	AND Billback_Product_Detail.Deleted = 0
	
	insert into BB_ModifyAgree_Productchanges
	(Billback_Id,BB_ModifyAgree_PrgId,Product_Id,Program_Id,From_BB_Rate,
	BB_Prod_Type)
	select '#url.BBID#','#updateBBModifyAgreeprogramList.BB_ModifyAgree_PrgId#',
	Program_Lump_Sum_Id,Billback_Program.program_id,Amount,3
	FROM
	Billback_Program_Lumpsum_Component
	INNER JOIN Billback_Program
	ON Billback_Program.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID
	and Billback_Program.deleted = 0
	where Billback_Program_Lumpsum_Component.Billback_ID = '#url.BBID#' 
	AND Billback_Program_Lumpsum_Component.Deleted = 0
</cfquery>

<cflocation url="/billbacks/capture/index.cfm?BBID=#url.BBID#&modifyagree=1">