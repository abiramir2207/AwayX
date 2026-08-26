<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">

<html>
<head>
	<title><CFOUTPUT>#application.CompanyName#</CFOUTPUT> Documentation :: Create a New Program</title>
	<script language="JavaScript">
<!--
function change(html){
  description.innerHTML=html
  description2.innerHTML=html
}
//-->
</script>
</head>

<body>



<strong><div id="description">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<HR COLOR="Orange">

<div align="center">


<p></p>
<table align="center" width="90%">
<tr><th colspan="2"><strong>Create a New Program -- Documents</strong></th></tr>
<tr><td colspan="2">&nbsp;</td></tr>
<tr><td colspan="2">You can attach documents to any program using the documents tab.</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_documents.gif"></td></tr>
<tr><td valign="top" align="center"> <img src="../images/1.gif"></td><td>You can search for documents already in the system. For example if you are looking for a price list document which you are relatively sure has already been uploaded, you could enter information about it, including: what sort of document it is (MS Word document, MS Excel document, etc.), what type of document it is (cover letter, price list, etc.), what the title of the document is, who uploaded it and when.
</td></tr>
<tr><td valign="top"> <img src="../images/2.gif"></td><td>If the document you wish to attach is not yet in the system, you may upload it. Instructions on how to do this are below.
</td></tr>
<tr><td valign="top"> <img src="../images/3.gif"></td><td>Once you have found the document or documents you would like to attach, check the boxes on the right hand of those documents. You can see basic details about the document. If you wish to view the document, click on the blue link.
</td></tr>
<tr><td valign="top"> <img src="../images/4.gif"></td><td>When your selections are complete, click on [attach selected documents].
</td></tr>
<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_document_upload.gif"></td></tr>
<tr><td valign="top" align="center"> <img src="../images/1.gif"></td><td>All previously uploaded documents are displayed in this list, along with their status. A green check indicates that the document is active while a red x indicates inactivity.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/2.gif"></td><td><em>Select Upload File:</em> You need to find the file that you wish to upload on your hard drive. Click on the "browse" button. That will bring up this window:
</td></tr>

<tr><td valign="top" colspan="2" align="center"><img src="../images/cp_choose_file.gif"></td></tr>
<tr><td colspan="2">&nbsp;You will need to navigate through your hard drive to find the appropriate file. Please refer to MS Windows documentation if you have trouble finding the file.</td></tr>
<tr><td valign="top" align="center"> <img src="../images/3.gif"></td><td><em>File Name:</em> This is the name of the file. It is taken automatically from the upload process and cannot be changed.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/4.gif"></td><td><em>Title:</em> Enter the name of the document so that it is clear what the document is and how it is used.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/5.gif"></td><td><em>Description:</em> The description should offer further information on the document.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/6.gif"></td><td>Document Type: Options in the document type are established by administrators. Pick the one that best describes your document, or contact your administrator to have a new one added.
</td></tr>
<tr><td valign="top" align="center"> <img src="../images/7.gif"></td><td>Availability: If you would like the document you are uploading to be available for attaching immediately, mark it as active. Otherwise, mark it as inactive. You can return at a later time and make it active.
</td></tr>
<tr><td valign="top" align="center" colspan="2">When you have made all your selections click [save data]. It may take some time to upload the document. The document will now be available if you search for it.

</td></tr>
</table>
<p></p>
</div>



<HR COLOR="Orange">
<strong><div id="description2">&nbsp; </div></strong>
<CFINCLUDE TEMPLATE="createprogram_toc.cfm">
<CFINCLUDE TEMPLATE="createprogram_updated.cfm">
</body>
</html>
