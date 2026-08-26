function GTE_Operator(Op_Type,thisObj)
{
	var spName;
	if(Op_Type == 1)
	{
		spName = "SP_Start_Date";
	}
	else if(Op_Type == 2)
	{
		spName = "SP_BB_DeliverStart";
	}
	else if(Op_Type == 3)
	{
		spName = "SP_BB_DeliverEnd";
	}
	else if(Op_Type == 4)
	{
		spName = "SP_Amount";
	}
	else if(Op_Type == 5)
	{
		spName = "SP_Deviation_Amount";
	}
	var bDis = (thisObj.selectedIndex == 0)? true: false;
	disableDiv(spName,bDis,false);
}
	

function disableDiv(divName,bDis,bHide)
{
	if(typeof divName === 'object')
	{
		oDiv = divName;
	}
	else
	{
		oDiv =	document.getElementById(divName);
	}
	if(oDiv)
	{
		oDiv.disabled = bDis;

/* $(oDiv).find('*') is equivalent to "oDiv.all". ".all" for objects has been removed from IE 11 onwards. */
$(oDiv).find('*').each(function() {

		$(this).attr('disabled', bDis);
		
		/* If this is an input box */
		if($(this).is("input"))
		{
			if(bDis){				
				/* Note: "input" below needs to be in lower case. */
				$(this).css("background-color","cccccc");
			}
			else{
				$(this).css("background-color","ffffff");
			}
		}
		
		/* If this is an select box */
		if($(this).is("select"))
		{
			if(bDis){
				$(this).css("background-color","cccccc");
				$(this).prop('selectedIndex', 0);
			}
			else{
				$(this).css("background-color","ffffff");
				
					if($(this).children('option').length > 0)
					{
						$(this).prop('selectedIndex', 0); 
					}
			}
		}
});


	var args = arguments;
	var argLen = args.length;
	if(argLen <3)
	{
		return;
	}
	if(args[2])
	{
		oDiv.style.display = "none";
	}
	else
	{
		oDiv.style.display = "";		
	}
	if(argLen <4)
	{
		return;
	}
	var parObj = document.getElementById(args[3]);
	
	if(args[2])
	{
		parObj.style.display = "none";
	}
	else
	{
		parObj.style.display = "";
	}

  }
}

function disable_Comparsion_Operators(srcIndex)
{
	GTE_Operator(1,document.getElementById("BB_Operator"));
	GTE_Operator(2,document.getElementById("BB_DeliverStart_Operator"));
	GTE_Operator(3,document.getElementById("BB_DeliverEnd_Operator"));
	GTE_Operator(4,document.getElementById("Amount_Operator"));
	
	if(srcIndex)
	{		
		GTE_Operator(5,document.getElementById("deviationAmountOperator"));
	}
}
