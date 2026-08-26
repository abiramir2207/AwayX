<!---------------------------------------------------------------------------------------------------------------------
      Template: \Common_Files\Volume\Summary\classSegment.cfm
      Date:     2013 July
      Author:   Chris Nguyen
      Purpose:  This include template displays VF classes drop-down, segments drop-down (when applicable)

      Parameters:
      		URL.byClassIDs  - optional = volume forecast fiscal year ( numeric )
      		URL.bySegmentID - optional = business segment ID ( numeric )
----------------------------------------------------------------------------------------------------------------------->

<cfparam name="url.byClassIDs"   default="">
<cfparam name="url.bySegmentID"  default="">

<cfscript>
	// default to show only VF for current year
	if ( url.byClassIDs eq "" ) {
	  vars.currentClasses = application.oVfManager.getClasses( activeOnly=true, currentYearOnly=true );
		url.byClassIDs = valueList( vars.currentClasses.vf_Class_ID );
	}
  vars.classes = application.oVfManager.getClasses();
</cfscript>


<div id="classSegment">
	 <b>Class:</b>&nbsp;
	 <select name="byClassIDs" id="byClassIDs">
		<cfoutput query="vars.classes">
			<option <cfif listFindNoCase(url.byClassIDs, vars.classes.vf_class_id)>selected=selected</cfif> value="#vars.classes.vf_class_id#">#vars.classes.vf_class_number# - #vars.classes.vf_class_desc#</option>
		</cfoutput>
	 </select>

	<!---when business segments exist display a segment drop-down--->
	 <cfif structKeyExists(request.AccessStructure, "User_Business_Segments") and len(request.AccessStructure.User_Business_Segments)>
		   <cfquery name="qSegments" Datasource="#application.datasource#">
		     SELECT Business_Unit_desc
		           ,Business_Segment_Id
		       FROM Business_Segment
		      WHERE Business_Segment_Id IN ( #request.AccessStructure.User_Business_Segments# )
		      ORDER BY Business_Unit_desc
		   </cfquery>

	     &nbsp;&nbsp;&nbsp;<b><cfoutput>#application.appSettingsGet.getbusiness_segment_label()#</cfoutput>:</b>&nbsp;
	 		 <select name="bySegmentID" id="bySegmentID" multiple="multiple" size="1">
	 		   <!---<option  <cfif url.bySegmentID eq "">selected</cfif> value="">All</option>--->
	 		   <cfoutput query="qSegments">
	 		     <option <cfif listFindNoCase(url.bySegmentID, qSegments.Business_Segment_Id) or url.bySegmentID eq "">selected</cfif> value="#qSegments.Business_Segment_Id#">#qSegments.Business_Unit_desc#</option>
	 		   </cfoutput>
			 </select>
	 </cfif>

	 <!---hide this refresh button until a change in class or segment is made--->
	 &nbsp;<button id="refresh" style="visibility:hidden;">Refresh</button>
</div>  <!---id="classSegment">--->

