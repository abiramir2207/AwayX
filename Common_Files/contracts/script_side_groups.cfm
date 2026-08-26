// initialize the qForm object
objForm = new qForm("frm");

// run the "selectGroup()" function everytime an option is clicked
// the false option makes sure the selectGroup() function is called immediately
objForm.nm_group_side.addEvent("onchange", "selectGroup();", false);

// run the "selectSubgroup1()" function everytime an option is clicked
// the false option makes sure the selectSubgroup1() function is called immediately
objForm.nm_sub1_group_side.addEvent("onchange", "selectSubgroup1();", false);

// run the "selectSubgroup2()" function everytime an option is clicked
// the false option makes sure the selectSubgroup2() function is called immediately
objForm.nm_sub2_group_side.addEvent("onchange", "selectSubgroup2();", false);

// run the "selectSubgroup3()" function everytime an option is clicked
// the false option makes sure the selectSubgroup3() function is called immediately
objForm.nm_sub3_group_side.addEvent("onchange", "selectSubgroup3();", false);

function selectGroup(){
	var value = objForm.nm_group_side.getValue();
	// Clear the other select groups
	objForm.nm_sub1_group_side.obj.length = 0 ;
	objForm.nm_sub2_group_side.obj.length = 1;
	objForm.nm_sub2_group_side.obj.options[0] = new Option("","",true);
	objForm.nm_sub3_group_side.obj.length = 1;
	objForm.nm_sub3_group_side.obj.options[0] = new Option("","",true);	
	objForm.nm_sub4_group_side.obj.length = 1;
	objForm.nm_sub4_group_side.obj.options[0] = new Option("","",true);	
	
	// Populate the nm_sub1_group_side field with the Subgroup 1
	objForm.nm_sub1_group_side.populate(stcGroups[objForm.nm_group_side.getValue()], true);
	
	if (objForm.nm_sub1_group_side.obj.length >= 1) {
	    
	    objForm.nm_sub1_group_side.obj.options[0].selected;
	    selectSubgroup1()
	}
}
		
function selectSubgroup1(){
	var value = objForm.nm_sub1_group_side.getValue();
	/// Clear the other select groups
	objForm.nm_sub2_group_side.obj.length = 0;
	objForm.nm_sub3_group_side.obj.length = 1;
	objForm.nm_sub3_group_side.obj.options[0] = new Option("","",true);	
	objForm.nm_sub4_group_side.obj.length = 1;
	objForm.nm_sub4_group_side.obj.options[0] = new Option("","",true);	
	
	// Populate the nm_sub2_group_side field with the Subgroup 2
	var sub1Group = objForm.nm_group_side.getValue() + "," + objForm.nm_sub1_group_side.getValue();
	objForm.nm_sub2_group_side.populate(stcGroups[sub1Group]);
	
	if (objForm.nm_sub2_group_side.obj.length >= 1) {
	    
	    objForm.nm_sub2_group_side.obj.options[0].selected;
	    selectSubgroup2()
	}
}
		
function selectSubgroup2(){
	var value = objForm.nm_sub2_group_side.getValue();
	/// Clear the other select groups
	objForm.nm_sub3_group_side.obj.length = 0;
	objForm.nm_sub4_group_side.obj.length = 1;
	objForm.nm_sub4_group_side.obj.options[0] = new Option("","",true);	
	
	// Populate the nm_sub3_group_side field with the Subgroup 3
	objForm.nm_sub3_group_side.populate(stcGroups[objForm.nm_group_side.getValue() + "," + objForm.nm_sub1_group_side.getValue() + "," + objForm.nm_sub2_group_side.getValue()], true);

	if (objForm.nm_sub3_group_side.obj.length >= 1) {
	    
	    objForm.nm_sub3_group_side.obj.options[0].selected;
	    selectSubgroup3()
	}
}

function selectSubgroup3(){
	var value = objForm.nm_sub3_group_side.getValue();
    /// Clear the other select groups
	objForm.nm_sub4_group_side.obj.length = 0;
		
	// Populate the nm_sub4_group_side field with the Subgroup 4
	objForm.nm_sub4_group_side.populate(stcGroups[objForm.nm_group_side.getValue() + "," + objForm.nm_sub1_group_side.getValue() + "," + objForm.nm_sub2_group_side.getValue() + "," + objForm.nm_sub3_group_side.getValue()], true);

	if (objForm.nm_sub4_group_side.obj.length >= 1) {
	    objForm.nm_sub4_group_side.obj.options[0].selected;
	}

}
		
// create a structure to store all the Groups
stcGroups = new Object();
<cfoutput query="GetGroups" group="nm_group_side">
  stcGroups["#nm_group_side#"] = new Object(); 
  
  // structure containing the Subgroup 1  
  <cfoutput group="nm_sub1_group_side">
    <cfif #nm_sub1_group_side# is " ">
      stcGroups["#nm_group_side#"]["#page_type#"] = "#page_type#"; 
	  stcGroups["#nm_group_side#,#page_type#"] = new Object();
    <cfelse>  
      stcGroups["#nm_group_side#"]["#nm_sub1_group_side#"] = "#nm_sub1_group_side#"; 
      stcGroups["#nm_group_side#,#nm_sub1_group_side#"] = new Object(); 
    
	  // structure containing the Subgroup 2
	  <cfoutput group="nm_sub2_group_side">
        <cfif #nm_sub2_group_side# is " ">
          stcGroups["#nm_group_side#,#nm_sub1_group_side#"]["#page_type#"] = "#page_type#"; 
        <cfelse>  
          stcGroups["#nm_group_side#,#nm_sub1_group_side#"]["#nm_sub2_group_side#"] = "#nm_sub2_group_side#"; 
          stcGroups["#nm_group_side#,#nm_sub1_group_side#,#nm_sub2_group_side#"] = new Object(); 
 
          // structure containing the Subgroup 3
          <cfoutput group="nm_sub3_group_side">
            <cfif #nm_sub3_group_side# is " ">
              stcGroups["#nm_group_side#,#nm_sub1_group_side#,#nm_sub2_group_side#"]["#page_type#"] = "#page_type#"; 
            <cfelse>  
              stcGroups["#nm_group_side#,#nm_sub1_group_side#,#nm_sub2_group_side#"]["#nm_sub3_group_side#"] = "#nm_sub3_group_side#"; 
              stcGroups["#nm_group_side#,#nm_sub1_group_side#,#nm_sub2_group_side#,#nm_sub3_group_side#"] = new Object();
			  
			  // structure containing the Subgroup 4
              <cfoutput group="nm_sub4_group_side">
                <cfif #nm_sub4_group_side# is " ">
                  stcGroups["#nm_group_side#,#nm_sub1_group_side#,#nm_sub2_group_side#,#nm_sub3_group_side#"]["#page_type#"] = "#page_type#"; 
                <cfelse>  
                  stcGroups["#nm_group_side#,#nm_sub1_group_side#,#nm_sub2_group_side#,#nm_sub3_group_side#"]["#nm_sub4_group_side#"] = "#nm_sub4_group_side#"; 
                  stcGroups["#nm_group_side#,#nm_sub1_group_side#,#nm_sub2_group_side#,#nm_sub3_group_side#, #nm_sub4_group_side#"] = new Object();
                </cfif>
			  </cfoutput>
            </cfif>
	      </cfoutput>	
        </cfif>
      </cfoutput> 
	</cfif> 
  </cfoutput> 
</cfoutput>
