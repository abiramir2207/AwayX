/*
<SCRIPT SRC="/common_Files/contracts/group_functions.js"></SCRIPT>
*/

//validate if level 2 and level 3 is under level 1
function validateProductsUnderGroupAtLevel1(thisForm)
{
	var level1 = thisForm.Level_1.value;
	var level2 = thisForm.Level_2.value;
	var level3 = thisForm.Level_3.value;
	
	var sIsValid = "";

	var delimiter = ",";	
	var currentLevel = level2;
	var Arr = currentLevel.split(delimiter);
	var i, arrLen, productIdReplaced, objProductGroupForThisProduct, productGroupForThisProduct;
	var re = /-/g;
	
	arrLen = Arr.length;
	for(i=0;i<arrLen;i++)
	{
		productIdReplaced = Arr[i].replace(re, "_");
		if(trim(productIdReplaced) != "")
		{
			objProductGroupForThisProduct = eval("thisForm.productGroupForThisProduct_" + productIdReplaced);
			if(objProductGroupForThisProduct)
			{
				productGroupForThisProduct = objProductGroupForThisProduct.value;
				if(trim(productGroupForThisProduct) != "")
				{
					if(ListFindItem(level1, delimiter, productGroupForThisProduct) < 0) //not found
					{
						alert("Products at " + Pricing_Level_2_Desc + " and " + Pricing_Level_3_Desc + " should be a subset of " + Pricing_Level_1_Desc + ".");
						return false;
					}
				}
			}
		}
	}
	
	return true;
	
}