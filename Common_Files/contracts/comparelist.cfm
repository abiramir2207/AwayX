<cfscript>
/**
 * Compares one list against another to find the elements in the first list that don't exist in the second list.
 * 
 * @param List1 	 Full list of delimited values. 
 * @param List2 	 Delimited list of values you want to compare to List1. 
 * @param Delim1 	 Delimiter used for List1.  Default is the comma. 
 * @param Delim2 	 Delimiter used for List2.  Default is the comma. 
 * @param Delim3 	 Delimiter to use for the list returned by the function.  Default is the comma. 
 */
function ListCompare(List1, List2)
{
  var TempList = "";
  var Delim1 = ",";
  var Delim2 = ",";
  var Delim3 = ",";
  var i = 0;
  // Handle optional arguments
  switch(ArrayLen(arguments)) {
    case 3:
      {
        Delim1 = Arguments[3];
        break;
      }
    case 4:
      {
        Delim1 = Arguments[3];
        Delim2 = Arguments[4];
        break;
      }
    case 5:
      {
        Delim1 = Arguments[3];
        Delim2 = Arguments[4];          
        Delim3 = Arguments[5];
        break;
      }        
  } 
   /* Loop through the full list, checking for the values from the partial list.
    * Add any elements from the full list not found in the partial list to the
    * temporary list
    */  
  for (i=1; i LTE ListLen(List1, "#Delim1#"); i=i+1) {
    if (NOT ListFindNoCase(List2, ListGetAt(List1, i, Delim1), Delim2)){
     TempList = ListAppend(TempList, ListGetAt(List1, i, Delim1), Delim3);
    }
  }
  Return TempList;
}


function uniqueList(List)
{
var notuniquelist = List;
var uniquelist = "";

for (i=1; i LTE ListLen(List, ","); i=i+1) {
   if (NOT listContains(uniquelist, ListGetAt(List, i))){
  		uniquelist = listAppend(uniquelist, ListGetAt(List, i), "," );
		}
 }
 Return uniquelist;
}
</cfscript>




