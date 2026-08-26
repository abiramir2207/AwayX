function findProduct(BigBillbackID)
{
	NewWindow("/billbacks/bigbillbacks/find_product.cfm?Big_Billback_ID=" + BigBillbackID, "productwindow", 450, 300, "yes", "yes");
	return false;		
}

function findDistributor(BigBillbackID)
{
	NewWindow("/billbacks/bigbillbacks/find_distributor.cfm?Big_Billback_ID=" + BigBillbackID, "productwindow", 450, 300, "yes", "yes");
	return false;
}

function showDistributorSearchWindow()
{
	NewWindow("/billbacks/search_screens/PM_select_distributors.cfm?FormName=DistributorAlias&SelectSingleSearchResultOnly=1", "distributorAliaswindow", 800, 600, "yes", "yes");	
return false;	
}

function showProductSearchWindow() {
				NewWindow("/common_files/contracts/product_Select_V1.cfm?Formname=ProductAlias&SelectSingleSearchResultOnly=1", "productAliaswindow", 810, 600, "yes", "yes");		
return false;	
		}

function deleteAndReenter(BillbackID,Big_Billback_Summary_ID)
{
	if(confirm("Are you sure you want to delete this entry and re-enter? If you've fixed any entries, they will also be lost.")) 
	{
		window.location = "delete_big_billbacks.cfm?Billback_ID=" + BillbackID + "&Big_Billback_Summary_ID=" + Big_Billback_Summary_ID;
	}
}

function billbackContinue(BillbackID,Big_Billback_Summary_ID)
{
	window.location = "enterBBstoBillbacks.cfm?Billback_ID=" + BillbackID + "&Big_Billback_Summary_ID=" + Big_Billback_Summary_ID;
}

function backToBulkInsert(BillbackID)
{
	window.location = "enter_bulk_information.cfm?Billback_ID=" + BillbackID;
}


function submitBulkData()
{
	document.BigBillbackForm.action = "bulkupload.cfm";
	document.BigBillbackForm.submit();
	return false;
}
	
	function SearchPrograms(ApplyFilter,Billback_Payee_Type_ID,Payee_ID) 
	{
			document.BigBillbackForm.Program_List.value 			= "";
			document.BigBillbackForm.FilterSearchPrograms.value 	= ApplyFilter;

			document.BigBillbackForm.FilterType.value 				= 0;
			document.BigBillbackForm.FilterDataList.value 			= "";
			document.BigBillbackForm.runsearchonfirstload.value 	= 0;
			
			if(ApplyFilter == 1)
			{
				
					document.BigBillbackForm.FilterType.value 		= Billback_Payee_Type_ID;
					document.BigBillbackForm.FilterDataList.value 	= Payee_ID;
					document.BigBillbackForm.runsearchonfirstload.value = 1;
				
			}
		NewWindow("/billbacks/search_screens/search_programs.cfm?Formname=BigBillbackForm&fieldname=Program_List&SelectSingleSearchResultOnly=1&FromBillbacks=1", "programswindow", 810, 600, "yes", "yes")
			
		}
		
		function CreateUnknownProgram() {
			document.BigBillbackForm.Data_Action_ID.value = 4;
			NewWindow("/billbacks/capture/program_add_unknown.cfm?Formname=BigBillbackForm", "productwindow", 500, 300, "yes", "yes")
		}