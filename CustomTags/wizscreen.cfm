<!---
Id: wizscreen.cfm, v1.0.1 8/24/00 2:25:03 PM dbabbitt
Description: This child tag is similar to the 
             wizfield tag except that we collect 
			 only one attribute, the URL. Also, we 
			 save the attributes in an array called 
			 ScreenArray rather than the FieldArray 
			 we specified for the wizfield tag.
--->

<CFPARAM Name="Attributes.URL" Default="">
<CFASSOCIATE BASETAG="CF_WIZARD" DATACOLLECTION="ScreenArray">

<!---
	Log: wizscreen.cfm
	Revision 1.0 8/24/00 2:20:04 PM dbabbitt
	This child tag is similar to the 
	wizfield tag except that we collect only 
	one attribute, the URL. Also, we save 
	the attributes in an array called 
	ScreenArray rather than the FieldArray 
	we specified for the wizfield tag.
	--->