<!---
Id: wizfield.cfm, v1.0.1 8/24/00 2:15:07 PM dbabbitt
Description: This child tag collects information 
             about the fields we want the parent to 
			 track – specifically, the name of the 
			 field and a default value for each 
			 field.
--->

<CFPARAM NAME="Attributes.Name" DEFAULT="">
<CFPARAM NAME="Attributes.Default" DEFAULT="">
<CFASSOCIATE BASETAG="CF_WIZARD" DATACOLLECTION="FieldArray">

<!---
	Log: wizfield.cfm
	Revision 1.0 8/24/00 2:11:33 PM dbabbitt
	This child tag collects information about 
	the fields we want the parent to track – 
	specifically, the name of the field and 
	a default value for each field.
	--->