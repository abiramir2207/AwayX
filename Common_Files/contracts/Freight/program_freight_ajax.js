	function warehouseChanged(sDistributorId)	
	{
		var distributorIdRE = getInputNameSuffix(sDistributorId);
		var distributorId = getDistributorIdFromInputNameSuffix(sDistributorId);
		var warehouseId = getWarehouse(distributorIdRE);
		var zipCode = getZipCode(distributorIdRE);
		
		SetOverride(getWarehouseObject(distributorIdRE));
		
		DWREngine.setAsync(true);
		DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'warehouseChanged', globalFreightComponentType, globalFreightDate, distributorId, warehouseId, zipCode, globalDefaultBracket, warehouseChangeComplete);
		return false;			
	}
	
	function bracketChanged(sDistributorId)	
	{
		var distributorIdRE = getInputNameSuffix(sDistributorId);
		var distributorId = getDistributorIdFromInputNameSuffix(sDistributorId);
		var warehouseId = getWarehouse(distributorIdRE);
		var zipCode = getZipCode(distributorIdRE);
		var bracketId = getBracket(distributorIdRE);
		
		DWREngine.setAsync(true);
		DWREngine._execute(_ajaxConfig._cfscriptLocation, null, 'bracketChanged', globalFreightComponentType, globalFreightDate, distributorId, warehouseId, zipCode, bracketId, bracketChangeComplete);
		return false;			
	}
	
	function warehouseChangeComplete(r)
	{	
		setIBFRate(r[2] + "", r[4] + "");
		if(r[0] == "1")
		{
			setBracket(r[2] + "", r[5] + "");
			setOBFRate(r[2] + "", r[6] + "");
			setPUARate(r[2] + "", r[6] + "");
		}
	}
	
	function bracketChangeComplete(r)
	{	
		setOBFRate(r[2] + "", r[6] + "");
		setPUARate(r[2] + "", r[6] + "");
	}
	
	function setIBFRate(distributorId, ibfRate)
	{
		var objDefaultIBFRate = getDefaultIBFObject(distributorId);
		if(objDefaultIBFRate)
		{
			objDefaultIBFRate.value = ibfRate;			
		}
		var objIBFRate = getIBFObject(distributorId);
		if(objIBFRate)
		{
			ibfRate = formatToDecimalPlaces(ibfRate, 2, 1);
			objIBFRate.value = ibfRate;
			FormatInputValue(objIBFRate);
		}		
	}
	
	function setBracket(distributorId, bracketId)
	{
		var selIndex = -1;
		var objBracket = getBracketObject(distributorId);		
		var objDefaultBracket = getDefaultBracketObject(distributorId);
		if(objDefaultBracket)
		{
			objDefaultBracket.value = bracketId;			
		}
		if(objBracket)
		{
			selIndex = Get_Select_Index(objBracket, bracketId);
			if(selIndex != -1)
			{
				objBracket.selectedIndex = selIndex;
				SetOverride(objBracket);
			}
		}
	}
	
	function setOBFRate(distributorId, obfRate)
	{
		var objOBFRate = getOBFObject(distributorId);
		var objDefaultOBFRate = getDefaultOBFObject(distributorId);
		if(objDefaultOBFRate)
		{
			objDefaultOBFRate.value = obfRate;
		}
		if(objOBFRate)
		{
			obfRate = formatToDecimalPlaces(obfRate, 2, 1);
			objOBFRate.value = obfRate;
			FormatInputValue(objOBFRate);
		}
	}
	
	function setPUARate(distributorId, obfRate)
	{
		var objPUARate = getPUAObject(distributorId);
		var objDefaultPUARate = getDefaultPUAObject(distributorId);
		if(objDefaultPUARate)
		{
			objDefaultPUARate.value = obfRate;
		}
		if(objPUARate)
		{
			obfRate = formatToDecimalPlaces(obfRate, 2, 1);
			objPUARate.value = obfRate;
			FormatInputValue(objPUARate);
		}
	}
