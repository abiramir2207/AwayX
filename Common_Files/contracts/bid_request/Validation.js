/*
 Show hide Script START
*/
    function hide(id) {
       var e = document.getElementById(id);
          e.style.display = 'none';
       }
    function show(id) {
    	var e = document.getElementById(id);
          e.style.display = 'block';
    }
/*
Show hide Script END
*/
    

 
    
/*
This function will slect checkboxes based on select dropdown option value START 
*/  
    function displayResult(form)
	{
		var x=document.getElementById("mySelect").selectedIndex;
		var y=document.getElementById("mySelect").options;
		var svalue = y[x].value;

	selectedGroups = new Array();
	// first uncheck all the checkboxes
	for (var i = 0; i < form.elements.length; i++ ) {
			if ((form.elements[i].type == 'checkbox')  && (form.elements[i].group_id != 'shared') && (form.elements[i].group_id != 'incremental') && (form.elements[i].group_id != 'specd')) 
			{
		    	form.elements[i].checked = false;
			}
		}
	
  	for (var i = 0; i < y.length; i++)
	{
	    if (y[i].selected)
		{
			selectedGroups.push(y[i].value);
		}
	}
	for (var j = 0; j < selectedGroups.length; j++) 
	{
		for (var i = 0; i < form.elements.length; i++ ) {
			if ((form.elements[i].type == 'checkbox') && (form.elements[i].checked == false) && (form.elements[i].group_id == selectedGroups[j])) 
			{
		               form.elements[i].checked = true
		    }
					   /*D34404: Bulkpak Incremental Flag Disappeared from Program... 
					      Added extra else logic not to overwrite Shared, Incremental, Spec'd Check box values */
		 /*  else if ((form.elements[i].type == 'checkbox') && (form.elements[i].checked == true) &&(form.elements[i].group_id != svalue)) 
			           {
							   	if((form.elements[i].group_id == 'shared') || (form.elements[i].group_id == 'incremental') || (form.elements[i].group_id == 'specd')){
									
								}
								else{
					           			form.elements[i].checked = false;
							   }
			    } // if*/
			}
	} 
	for (var j = 0; j < selectedGroups.length; j++) 
	{
		for (var i = 0; i < form.elements.length; i++ ) {
			if ((form.elements[i].type == 'checkbox') && (form.elements[i].checked == false) && (selectedGroups[j] == -1) && (form.elements[i].group_id != 'shared') && (form.elements[i].group_id != 'incremental') && (form.elements[i].group_id != 'specd')) 
			{
		    	form.elements[i].checked = true;
			}
		}
	}		
} //function ends
/*
This function will slect checkboxes based on select dropdown option value END
*/   




/*
This function will slect all checkboxes and assign a value to hidden textbox to say apply MASS APPLY for ALL items START  
*/
  function checkAll(form)
{

    for (var i = 0; i < form.elements.length; i++)
    {
    	if ((form.elements[i].type=='checkbox') && (form.elements[i].value != 1) && (form.elements[i].value != 1) && (form.elements[i].name != 'Allbox'))     
                {
					form.elements[i].checked = document.thsForm.Allbox.checked;
					document.thatForm.mass_apply_All.value = "massapply_all";
                }
    }
 }
/*
This function will slect all checkboxes and assign a value to hidden textbox to say apply MASS APPLY for ALL items END
*/

  
/*
This function will add SOURCE and SOURCE TYPE and DATE values to hidden textboxs START  
*/
 function changevalue()
 {
 document.thisForm.source.value = document.thatForm.source.value;
 document.thisForm.sourcetype.value = document.thatForm.sourcetype.value;
 //document.thisForm.sourcedate.value = document.thatForm.sourcedate.value;
 }
 /*
This function will add SOURCE and SOURCE TYPE and DATE values to hidden textboxs END 
*/  



/*
this function validates fields which are mandatory while client using individual Apply Start
*/

function individual_checker()
{
var G=document.getElementById("source").selectedIndex;
var H=document.getElementById("source").options;
var I=document.getElementById("sourcetype").selectedIndex;
var J=document.getElementById("sourcetype").options;
var list = 'All the following fields are mandatory' + '\n';
var list_length = list.length;

//var itemslist = 'Please select if you won or lost for following items' + '\n';
//var itemslist_length = itemslist.length;

document.thisForm.sourcedate.value = document.thatForm.sourcedate.value;

/* This code is not being used. Just commenting it, for now. */
//var str = document.thisForm.items_list_in_page.value;
//var splited = str.split(",", str.length);
//var itemslist = '';

if(H){
	if(H[G].value == 0)
	{
		var list = list.concat('Source');
		var list = list.concat('\n');
	}
}

if(J){
	if(J[I].value == 0)
	{
		var list = list.concat('Source Type');
		var list = list.concat('\n');
	}
}

if(thatForm.sourcedate.value.length == 0)
{
	var list = list.concat('Source Date');
	var list = list.concat('\n');
}

if (list.length > 39)
{
	 alert(list);
	 return (false);
}

/* This code is not being used. Just commenting it, for now. */
//for(i = 0; i < splited.length; i++)
//{
	//var A = splited[i];
	//var B = A.concat('_won_lost');
	//if (document.getElementById(B))
	//{
		//var won_lost_select = document.getElementById(B).selectedIndex;
    	//var won_lost_select_value = document.getElementById(B).options;
	
		//if (won_lost_select_value[won_lost_select].value == 0)
		//{
		
			//var itemslist = itemslist.concat(A);
       	 //var itemslist = itemslist.concat('\n');
			 /* 
		 	//Commented for 29102/Anand Rao/10-Nov-2011
		 	document.getElementById(B).style.backgroundColor='yellow';
			*/
		//}
	//}

/* if ((splited.length == i+1) && (itemslist.length > 0)) {
	alert("Please select won/lost status for all items");
 return (false);
} */
//}

return (true);

}
/*
this function validates fields which are mandatory while client using individual Apply END
*/



/*
this function validates fields which are mandatory while client using MASS APPLY Start
*/
function Mass_apply_checker()
{

/*var radio_choice = false;
var radio_choice2 = false;
var A=document.getElementById("mass_apply_category_type").selectedIndex;
var B=document.getElementById("mass_apply_category_type").options;
var C=document.getElementById("mass_apply_package_type").selectedIndex;
var D=document.getElementById("mass_apply_package_type").options;
var E=document.getElementById("mass_apply_won_lost").selectedIndex;
var F=document.getElementById("mass_apply_won_lost").options;*/

var G=document.getElementById("source").selectedIndex;
var H=document.getElementById("source").options;

var I=document.getElementById("sourcetype").selectedIndex;
var J=document.getElementById("sourcetype").options;




var list = 'All the following fields are mandatory' + '\n';

var list_length = list.length;

if(H[G].value == 0)

{
var list = list.concat('Source');
var list = list.concat('\n');
}

if(J[I].value == 0)
{
var list = list.concat('Source Type');
var list = list.concat('\n');
}
if(thatForm.sourcedate.value.length == 0)
{
var list = list.concat('Source Date');
var list = list.concat('\n');
}

/*for (counter = 0; counter < thatForm.mass_apply_incremetal.length; counter++)
{
if (thatForm.mass_apply_incremetal[counter].checked)
radio_choice = true; 
}

for (counter = 0; counter < thatForm.mass_apply_shared.length; counter++)
{
if (thatForm.mass_apply_shared[counter].checked)
radio_choice2 = true; 
}

if(F[E].value == 0)
{
var list = list.concat('Won Loss');
var list = list.concat('\n');
}
if(!radio_choice)
{
var list = list.concat('Incremental Business');
var list = list.concat('\n');
}
if(!radio_choice2) 
{
var list = list.concat('Shared Business');
var list = list.concat('\n');
}
if(B[A].value == 0) 
{
var list = list.concat('Category');
var list = list.concat('\n');
}
if(D[C].value == 0) 
{
var list = list.concat('Package');
var list = list.concat('\n');
}
*/
if (list.length > 39)
{
 alert(list);
 return (false);
}
return (true);
}
/*
this function validates fields which are mandatory while client using MASS APPLY END
*/




/*
This function concat checkbox value which are selected and added to a hidden form value START 
*/ 
function addvalue(id)
	{ 
			  
			  var e= document.thisForm.elements.length;
              var cnt=0;
			  var A = id;
			  var B = A.concat('_checkbox');
              			  
 for(cnt=0;cnt<e;cnt++)
  {
    if(document.thisForm.elements[cnt].name== B)
	{
	   if(document.thisForm.elements[cnt].checked == true)
	   {
    
	          var C = A.concat(',');
			  var D = document.thatForm.checkbox_value.value;
			  var E = D.concat(C);
			  document.thatForm.checkbox_value.value = E;
			  

	    }
		else if(document.thisForm.elements[cnt].checked == false)
		{
		     var F = document.thatForm.checkbox_value.value;
			 var G = F.replace(A,"");
			 document.thatForm.checkbox_value.value = G;
			
		}
    }
  }
			  
}
/*
 This function concat checkbox value which are selected and added to a hidden form value END  
*/
	
	
	
	

	
	
	
	
	
/*
This function is used to display wonby, won rate, won case, won delivery type based on user slection on won lost dropdown and shared sheck box  START
*/
	
	function toggle(id, Oid, it1, it2, it3, it4, it5, it6, it7) {
	   var x=document.getElementById(id).selectedIndex;
       var y=document.getElementById(id).options;
	   var e = document.getElementById(Oid);
	   var dummyspace = document.getElementById(it7);
	   if((y[x].value == 1) && (e.checked == true))
	   {
		   //alert('true both won and check box');
		   document.getElementById(it1).style.display = 'block';
		   document.getElementById(it2).style.display = 'none';
		   document.getElementById(it3).style.display = 'block';
		   document.getElementById(it4).style.display = 'block';
		   document.getElementById(it5).style.display = 'none';
			if(document.getElementById(it7))
			{
		   		document.getElementById(it7).style.display = 'none';
			}
	   }
	  if((y[x].value == 1) && (e.checked == false))
	   {
		   document.getElementById(it1).style.display = 'block';
		   document.getElementById(it2).style.display = 'none';
		   document.getElementById(it3).style.display = 'block';
		   document.getElementById(it4).style.display = 'none';		   
		   document.getElementById(it5).style.display = 'none';
		   
		   if( document.getElementById(it7))
		   {
		   		document.getElementById(it7).style.display = 'block';
			}
		   //alert('true only won and no check box');
	   }

	   else if((y[x].value == 2) && (e.checked == true))
	   {
	       //alert('lost and checked true');
		   document.getElementById(it1).style.display = 'block';
		   document.getElementById(it2).style.display = 'none';
		   document.getElementById(it3).style.display = 'none';
		   document.getElementById(it4).style.display = 'block';
		   document.getElementById(it5).style.display = 'block';
		   
		   document.getElementById(it7).style.display = 'none';
		   
	   }
   		else if((y[x].value == 2) && (e.checked == false))
	   {
	       //alert('true only lost and no check box');
		   document.getElementById(it1).style.display = 'block';// header WON BY//RATE//UOM//DELIVERY
		   document.getElementById(it2).style.display = 'block';// Fields SELECT WON BY//RATE//SELECT UOM//SELECET DELIVERY
		   document.getElementById(it3).style.display = 'none';//client WON information
		   document.getElementById(it4).style.display = 'none'; //don't need to show the plus icon to add more rows as it is not shared
		   document.getElementById(it5).style.display = 'block';
		   
		   document.getElementById(it7).style.display = 'block';
		  
	   }
	   if((y[x].value == 2) && (it6 == 0)){
		   document.getElementById(it2).style.display = 'block';// Fields SELECT WON BY//RATE//SELECT UOM//SELECET DELIVERY	   	
	   }
	   
    }

/*
This function is used to display wonby, won rate, won case, won delivery type based on user slection on won lost dropdown and shared sheck box  END
*/

/*
This function is called from Competitive_data.cfm file.
*/
function Mass_apply_checker_competitive_data()
{
	var groupSelectionIndex = document.getElementById("mySelect").selectedIndex;
	var groupOptions		= document.getElementById("mySelect").options;
	
	var G=document.getElementById("source").selectedIndex;
	var H=document.getElementById("source").options;
	
	var I=document.getElementById("sourcetype").selectedIndex;
	var J=document.getElementById("sourcetype").options;

	var list = 'All the following fields are mandatory:' + '\n';
	var list_length = list.length;

	selectedGroups = new Array();
  	for (var i = 0; i < groupOptions.length; i++)
	{
	    if (groupOptions[i].selected && groupOptions[i].value != 0)
		{
			selectedGroups.push(groupOptions[i].value);
		}
	}
 
	if (typeof(document.all.mySelect) != "undefined")
	{
		if (selectedGroups.length == 0)	
		{
			 list = list.concat('Select atleast one Product Group');
			 list = list.concat('\n');
		}
	}
//alert(H[G].value);
	if(H[G].value == 0)
	{
		var list = list.concat('Source');
		var list = list.concat('\n');
	}
//alert(J[I].value);
	if(J[I].value == 0)
	{
		var list = list.concat('Source Type');
		var list = list.concat('\n');
	}
//alert(thatForm.sourcedate.value.length);
	if(thatForm.sourcedate.value.length == 0)
	{
		var list = list.concat('Source Date');
		var list = list.concat('\n');
	}
	if (list.length > 40)
	{
		alert(list);
 		return (false);
	}
	return (true);
}
/*
this function validates fields which are mandatory while client using MASS APPLY END
*/
