public function applyFilter():Void
{	//alert("Term filter:: " + filterInput.text);	
	var filterTerm = filterInput.text.toLowerCase();
	if(filterTerm.length > 0)
	{	
		if(_global.unfilteredData == undefined) 
		{
			_global.unfilteredData = cloneData(Programs.dataProvider);
		}
		var filteredData = [];
		
		for(var i = 0; i< _global.unfilteredData.length; i++)
		{
			var item =  _global.unfilteredData[i];
			var added = false;
			//Contract_Title  **************************
			if((filterTitle.value) && (item.Contract_Title != null))
			{
				var title = item.Contract_Title.toLowerCase();
				if(title.indexOf(filterTerm) != -1)
				{
					filteredData.push(item);
					continue;
				}
			}
			//Contract_Number  **************************
			if((filterNumber.value) && (item.Contract_Number != null))
			{
				var content = item.Contract_Number.toLowerCase();
				if(content.indexOf(filterTerm) != -1)
				{
					filteredData.push(item);
					continue;
				}
			}
			//Operator Number  **************************
			if((filterOper.value) && (item.OperatorID != null))
			{
				var content = item.OperatorID.toLowerCase();
				if(content.indexOf(filterTerm) != -1)
				{
					filteredData.push(item);
					continue;
				}
			}
			//Operator Name  **************************
		if((filterOper.value) && (item.Operator_Name != null))
			{
				var content = item.Operator_Name.toLowerCase();
				if(content.indexOf(filterTerm) != -1)
				{
					filteredData.push(item);
					continue;
				}
			}
				//Dist Num...ship_to  **************************
			if((filterDist.value) && (item.ship_to != null))
			{
				var content = item.ship_to.toLowerCase();
				if(content.indexOf(filterTerm) != -1)
				{
					filteredData.push(item);
					continue;
				}
			}
			//dist Name  **************************
			if((filterDist.value) && (item.Name != null))
			{
				var content = item.Name.toLowerCase();
				if(content.indexOf(filterTerm) != -1)
				{
					filteredData.push(item);
					continue;
				}
			}
			//created_Type ... program type   **************************
			if((filterTemplate.value) && (item.Created_Type != null))
			{
				var content = item.Created_Type.toLowerCase();
				if(content.indexOf(filterTerm) != -1)
				{
					filteredData.push(item);
					continue;
				}
			}
			
			
		}
		Programs.dataProvider = filteredData;
		if(Programs.dataProvider.length > 0)
		{
			Programs.selectedIndex = 0;
			//_global.showPreview();
		}
	}
	else
	{
		if(_global.unfilteredData != undefined) Programs.dataProvider = _global.unfilteredData;
	}
	display.text = '';  //clean up preview pane
}
public function cloneData(data):Array
{
	var clone = [];
	for(var i = 0; i< data.length; i++)
	{
		clone.push(data.getItemAt(i));
	}
	return clone;
}


