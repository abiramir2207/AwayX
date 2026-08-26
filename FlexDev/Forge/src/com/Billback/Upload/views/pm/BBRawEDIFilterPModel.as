package com.Billback.Upload.views.pm
{
	import com.shared.vos.Settings;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IEventDispatcher;
	import com.Billback.Upload.models.vos.BBRawEDIFilterParams;
	public class BBRawEDIFilterPModel extends EventDispatcher
	{
		/*.......................  Constructor  .......................*/
		private var _dispatcher:IEventDispatcher;
		public function BBRawEDIFilterPModel( dispatcher:IEventDispatcher ):void
		{
			this._dispatcher = dispatcher;
		}
		
		
		/*.......................  Properties  .......................*/
		
		
		/*.................oSettings......................*/
		[Bindable]
		public var oSettings:Settings = new Settings();
		[Bindable]
		public var objBBFilterParams:BBRawEDIFilterParams = new BBRawEDIFilterParams();
 
		public function updateBBNumberKeyword(BBNumberKeyword:String):void
		{	
		//	this.objBBFilterParams.BBNumberKeyword = payableNumber;
		} 
		
	/*	private function FilterBillbacks(type:String):void
		{
			
			/* Set bGetFavorites = true, so that "saveBBFilterParams" function is  not fired before it should, when user either 
			saves the "Favorites" list OR loads "Archive" data.
			//
			if(type == 'userList')
			{
				this.pModel.bGetFavorites =  true;				
			}
				/* When user searches for "current including paid/void" data //
			else if(this.pModel.dataViewOption == 'current_including_paid')
			{
				this.pModel.bSearchData = true;
			}
			
		// /* All the selected values from the different textboxes and dropdowns or any other control are now a part of "BBFilterParams" object	 /
			this.pModel.updatePayableNumber(tiPayableNumber.text);
			this.pModel.updateBBNumber(tiBillbackNumber.text);
			this.pModel.updateProgram(tiProgram.text);
			this.pModel.updatePayee(tiPayee.text);
			this.pModel.updateAmountValue(drpAmountType.selectedItem,drpAmountCriteria.selectedItem,tiAmountValue.text);
			this.pModel.updateEntity(drpEntity.selectedItem,tiEntitySearch.text);
			this.pModel.updateCheckNumber(tiCheckNumber.text);
			
			this.pModel.updateStatus(drpStatus.arrSelectedItems);
			this.pModel.updateAnalyst(drpAnalyst.arrSelectedItems);
			this.pModel.updateClosingMethod(drpClosingMethod.arrSelectedItems);
			this.pModel.updateBBType(drpBBType.arrSelectedItems);
			this.pModel.updateDateRangeStartValue(drpDateRangeStartType.selectedItem,drpDateRangeStartCriteria.selectedItem,dtSearchDateRangeStart.text);
			this.pModel.updateDateRangeEndValue(drpDateRangeEndType.selectedItem,drpDateRangeEndCriteria.selectedItem,dtSearchDateRangeEnd.text);
			this.pModel.updateAmountValue(drpAmountType.selectedItem,drpAmountCriteria.selectedItem,tiAmountValue.text);
			this.pModel.updateEntity(drpEntity.selectedItem,tiEntitySearch.text);
			this.pModel.updateActions(drpActions.selectedItem);
			this.pModel.updateUser(drpHistory.selectedItem,drpUser.arrSelectedItems);
			this.pModel.updateConditionsValue(drpConditions.selectedItem);
			
			/* This is called for searching, whether it is "current" or "current including paid/void" //
			if(type == 'search'){
				
				this.pModel.updateSearchData();
				//this.pModel.saveBBFilterParams();	
			} 
				/* User saving "favorites" data //
			else{			  
				if(tListName.text.length == 0){
					Alert.show("Please enter a name for your favorites");
				}
				else{
					this.pModel.saveUserList(tListName.text);
					tListName.text = '';
				}			  	
			}			   
		}
		*/

		private function FilterBillbacks(type:String):void
		{
			
			/* Set bGetFavorites = true, so that "saveBBFilterParams" function is  not fired before it should, when user either 
			saves the "Favorites" list OR loads "Archive" data.
			*/
	/*		if(type == 'userList')
			{
				this.pModel.bGetFavorites =  true;				
			}
				 
			else if(this.pModel.dataViewOption == 'current_including_paid')
			{
				this.pModel.bSearchData = true;
			}*/
			
			/* All the selected values from the different textboxes and dropdowns or any other control are now a part of "BBFilterParams" object */
		/*	this.pModel.updatePayableNumber(tiPayableNumber.text);
			this.pModel.updateBBNumber(tiBillbackNumber.text);
			this.pModel.updateProgram(tiProgram.text);
			this.pModel.updatePayee(tiPayee.text);
			this.pModel.updateAmountValue(drpAmountType.selectedItem,drpAmountCriteria.selectedItem,tiAmountValue.text);
			this.pModel.updateEntity(drpEntity.selectedItem,tiEntitySearch.text);
			this.pModel.updateCheckNumber(tiCheckNumber.text);
			
			this.pModel.updateStatus(drpStatus.arrSelectedItems);
			this.pModel.updateAnalyst(drpAnalyst.arrSelectedItems);
			this.pModel.updateClosingMethod(drpClosingMethod.arrSelectedItems);
			this.pModel.updateBBType(drpBBType.arrSelectedItems);
			this.pModel.updateDateRangeStartValue(drpDateRangeStartType.selectedItem,drpDateRangeStartCriteria.selectedItem,dtSearchDateRangeStart.text);
			this.pModel.updateDateRangeEndValue(drpDateRangeEndType.selectedItem,drpDateRangeEndCriteria.selectedItem,dtSearchDateRangeEnd.text);
			this.pModel.updateAmountValue(drpAmountType.selectedItem,drpAmountCriteria.selectedItem,tiAmountValue.text);
			this.pModel.updateEntity(drpEntity.selectedItem,tiEntitySearch.text);
			this.pModel.updateActions(drpActions.selectedItem);
			this.pModel.updateUser(drpHistory.selectedItem,drpUser.arrSelectedItems);
			this.pModel.updateConditionsValue(drpConditions.selectedItem);*/
			
			/* This is called for searching, whether it is "current" or "current including paid/void" */
		/*	if(type == 'search'){
				
				this.pModel.updateSearchData();
				//this.pModel.saveBBFilterParams();	
			} */
				/* User saving "favorites" data */
		/*	else{			  
				if(tListName.text.length == 0){
					Alert.show("Please enter a name for your favorites");
				}
				else{
					this.pModel.saveUserList(tListName.text);
					tListName.text = '';
				}			  	
			}*/			   
		}
		
		
	}
}