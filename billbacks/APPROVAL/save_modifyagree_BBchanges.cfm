 
<cfquery name="getBBNewProgramList" datasource="#application.datasource#">
	select program_id,contract_number
	from billback_program
	inner join contract_main on
	contract_main.contract_main_id = billback_program.program_id
	where Billback_Id = '#Billback_ID#'
	and billback_program.deleted = 0
	order by program_id asc
</cfquery>
<cfif getBBNewProgramList.recordcount GT 0>
<cfset newprogram_list = valuelist(getBBNewProgramList.program_id,",")>
<cfset newprogramnum_list = valuelist(getBBNewProgramList.contract_number,",")>
<cfelse>
<cfset newprogram_list = "">
<cfset newprogramnum_list = "">
</cfif>
<cfquery name="updateBBModifyAgreeprogramList" datasource="#Application.Datasource#">
	update BB_ModifyAgree_ProgramChanges
	set To_ProgramId_List = '#newprogram_list#',
	To_ProgramNum_List = '#newprogramnum_list#'
	where Billback_Id = '#Billback_ID#'
	and User_Id = '#request.AccessStructure.user_id#'
	and active = 1
</cfquery>

<cfquery name="updateBBModifyAgreeprogramList" datasource="#Application.Datasource#">
<!--- products updated or deleted --->
	update BB_ModifyAgree_Productchanges
	set To_BB_Rate = BB_Rate,
	To_BB_Prod_Qty = BB_Product_Quantity,
	To_BB_Prod_UOM = ISNULL(BB_Product_UOM,0),
	Prod_Changed = case when Billback_Product.product_id IS NULL
	then 2
	else Prod_Changed end
	from BB_ModifyAgree_Productchanges
	inner join BB_ModifyAgree_Programchanges on
	BB_ModifyAgree_Productchanges.BB_ModifyAgree_PrgId = 
	BB_ModifyAgree_Programchanges.BB_ModifyAgree_PrgId
	left join billback_product on
	billback_product.product_id = BB_ModifyAgree_Productchanges.product_id
	and billback_product.Billback_id = BB_ModifyAgree_Productchanges.Billback_id
	and billback_product.deleted = 0
	left join Billback_Program on
	Billback_Program.Billback_Program_Id = billback_product.Billback_Program_Id
	and Billback_Program.program_id = BB_ModifyAgree_Productchanges.program_id
	and Billback_Program.deleted = 0
	left join Billback_Product_Detail on
	Billback_Product_Detail.Billback_Id = BB_ModifyAgree_Productchanges.Billback_id
	and Billback_Product_Detail.billback_product_id = billback_product.billback_product_id
	and Billback_Product_Detail.deleted = 0
	and Billback_Product_Detail.BB_Product_type_Id = BB_ModifyAgree_Productchanges.BB_Prod_type
	where BB_ModifyAgree_Productchanges.Billback_id = '#Billback_ID#'
	and BB_ModifyAgree_Programchanges.Billback_id = '#Billback_ID#'
	and BB_ModifyAgree_Programchanges.active =1
	and User_Id = '#request.AccessStructure.user_id#'
	
	update BB_ModifyAgree_Productchanges
	set To_BB_Rate = Amount,
	Prod_Changed = 
	case when 
	Billback_Program_Lumpsum_Component.PROGRAM_LUMP_SUM_ID IS NULL
	then 2
	else 0 end
	from BB_ModifyAgree_Productchanges
	inner join BB_ModifyAgree_Programchanges on
	BB_ModifyAgree_Productchanges.BB_ModifyAgree_PrgId = 
	BB_ModifyAgree_Programchanges.BB_ModifyAgree_PrgId
	left join Billback_Program_Lumpsum_Component on
	BB_ModifyAgree_Productchanges.billback_id =
	Billback_Program_Lumpsum_Component.Billback_ID
	AND BB_ModifyAgree_Productchanges.PRODUCT_ID = 
	Billback_Program_Lumpsum_Component.PROGRAM_LUMP_SUM_ID
	and Billback_Program_Lumpsum_Component.deleted = 0 
	left join Billback_Program
	ON Billback_Program.Billback_Program_ID =
	Billback_Program_Lumpsum_Component.Billback_Program_ID
	AND Billback_Program.program_id = BB_ModifyAgree_Productchanges.program_id
	and Billback_Program.deleted = 0
	where BB_ModifyAgree_Productchanges.Billback_id = '#Billback_ID#'
	and BB_ModifyAgree_Programchanges.Billback_id = '#Billback_ID#'
	and BB_ModifyAgree_Programchanges.active =1
	and BB_ModifyAgree_Productchanges.BB_Prod_Type = 3
	and User_Id = '#request.AccessStructure.user_id#' 
	
	
	<!--- new products added --->
	insert into BB_ModifyAgree_Productchanges
	(Billback_Id,BB_ModifyAgree_PrgId,Product_Id,Program_Id,To_BB_Rate,
	From_BB_Prod_Qty,BB_Prod_Type,From_BB_Prod_UOM,prod_changed)
	select '#Billback_ID#',BB_ModifyAgree_Programchanges.BB_ModifyAgree_PrgId,
	Billback_Product.product_id,Billback_Program.program_id,
	BB_Rate,BB_Product_Quantity,
	BB_Product_Type_Id,BB_Product_UOM,1
	FROM
	Billback_Product_Detail
	INNER JOIN Billback_Product
	ON Billback_Product.Billback_Product_ID = 	
	Billback_Product_Detail.Billback_Product_ID
	AND Billback_Product.Deleted = 0
	INNER JOIN Billback_Program
	ON Billback_Program.Billback_Program_ID = Billback_Product.Billback_Program_ID
	and Billback_Program.deleted = 0
	left join BB_ModifyAgree_Productchanges on
	BB_ModifyAgree_Productchanges.billback_id =
	Billback_Product_Detail.Billback_ID
	and BB_ModifyAgree_Productchanges.program_id = Billback_Program.program_id
	and BB_ModifyAgree_Productchanges.BB_Prod_Type =
	Billback_Product_Detail.BB_Product_Type_Id
	and BB_ModifyAgree_Productchanges.product_id = Billback_Product.product_id
	left join BB_ModifyAgree_Programchanges on
	BB_ModifyAgree_Programchanges.billback_id = 
	Billback_Product_Detail.Billback_ID
	where Billback_Product_Detail.Billback_ID = '#Billback_ID#'
	AND Billback_Product_Detail.Deleted = 0
	AND BB_ModifyAgree_Productchanges.product_id is null
	AND BB_ModifyAgree_Programchanges.active = 1
	
	<!--- new lumpsum added --->
	insert into BB_ModifyAgree_Productchanges
	(Billback_Id,BB_ModifyAgree_PrgId,Product_Id,Program_Id,To_BB_Rate,
	BB_Prod_Type,prod_changed)
	select '#Billback_ID#',BB_ModifyAgree_Programchanges.BB_ModifyAgree_PrgId,
	Billback_Program_Lumpsum_Component.Program_Lump_Sum_Id,
	Billback_Program.program_id,Amount,3,1
	FROM
	Billback_Program_Lumpsum_Component
	INNER JOIN Billback_Program
	ON Billback_Program.Billback_Program_ID = Billback_Program_Lumpsum_Component.Billback_Program_ID
	and Billback_Program.deleted = 0
	left join BB_ModifyAgree_Productchanges on
	BB_ModifyAgree_Productchanges.billback_id =
	Billback_Program_Lumpsum_Component.Billback_ID
	and BB_ModifyAgree_Productchanges.program_id = Billback_Program.program_id
	and BB_ModifyAgree_Productchanges.BB_Prod_Type = 3
	AND BB_ModifyAgree_Productchanges.PRODUCT_ID = 
	Billback_Program_Lumpsum_Component.PROGRAM_LUMP_SUM_ID
	left join BB_ModifyAgree_Programchanges on
	BB_ModifyAgree_Programchanges.billback_id = 
	Billback_Program_Lumpsum_Component.Billback_ID
	where Billback_Program_Lumpsum_Component.Billback_ID = '#Billback_ID#'
	AND Billback_Program_Lumpsum_Component.Deleted = 0
	AND BB_ModifyAgree_Productchanges.product_id is null
	AND BB_ModifyAgree_Programchanges.active = 1
</cfquery>

 
<CFQUERY NAME="UpdateModifyPrgInfo" DATASOURCE="#Application.Datasource#">
	update BB_ModifyAgree_ProgramChanges
	set active = 0
	where Billback_Id = '#Billback_ID#'
	and user_id ='#request.AccessStructure.user_id#'
	and active = 1
</CFQUERY>
