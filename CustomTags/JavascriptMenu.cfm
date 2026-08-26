<!--- 

All tag atrributes are case sensitive




Attribute Name						Description
------------					-------------------

OpenFolderImagePath				Enter the path of the image you would like to represent the open folder

ClosedFolderImagePath			Enter the path of the image you would like to represent the closed folder

FolderItemImagePath				Enter the path of the image you would like to represent the items of a sub folder

ShowMenuImages					True - Shows all the images, False - Shows only a text menu

RootFolderCaption				Enter what you would like to display as the root text
RootFolderURL					If the root is to link to another item, enter its location here

SubFolder_1_Caption				Enter the heading for the subfolder here
SubFolder_1_URL					If the subfolder root is linked to another item, enter its location here. NO COMMAS IN THE URL
SubFolder_1_Items				Enter the items of the subfolder here in a comma delimited  list
SubFolder_1_ItemURLS			Enter the corresponding URLs here for the folder items, must have the same element count as SubFolder_1_Items. NO COMMAS IN THE URL
SubFolder_1_FolderOpen			True - Expands the folder and displays its items on load, False - Collapses the folder on load

Example:

SubFolder_1_Caption="Products"
SubFolder_1_Items="Pearl Echo,Cyber Snoop,TakeMeHome,Private-I"
SubFolder_1_ItemURLS="../work/gim.html,../work/gim.html,../tmh/index.html,../pi/index101.html"
SubFolder_1_FolderOpen="true"

SubFolder_2_Caption="Downloads"
SubFolder_2_Items="Software,Starter List"
SubFolder_2_ItemURLS="www.download.com,www.xyz.com"
SubFolder_2_FolderOpen="false"

To add more sub folders, incriment the numeric value of the Attribute set. SubFolder_3_Caption and its appropiate Attributes.
 --->







<SCRIPT>

//**************************************************************** 
// Folder-Tree script
//**************************************************************** 
 
ImagesDirectory = "/images/Javascript_Menu_Images/"
ImagesOn=<CFOUTPUT>#Attributes.ShowMenuImages#</CFOUTPUT>
// Definition of class Folder 
// ***************************************************************** 

function Folder(folderDescription, hreference) //constructor 
{ 
  //constant data 
  this.desc = folderDescription 
  this.hreference = hreference 
  this.id = -1   
  this.navObj = 0  
  this.iconImg = 0  
  this.nodeImg = 0  
  this.isLastNode = 0 
 
  //dynamic data 
  this.isOpen = true 
  this.iconSrc = "<CFOUTPUT>#Attributes.OpenFolderImagePath#</CFOUTPUT>"   
  this.children = new Array 
  this.nChildren = 0 
 
  //methods 
  this.initialize = initializeFolder 
  this.setState = setStateFolder 
  this.addChild = addChild 
  this.createIndex = createEntryIndex 
  this.hide = hideFolder 
  this.display = display 
  this.renderOb = drawFolder 
  this.totalHeight = totalHeight 
  this.subEntries = folderSubEntries 
  this.outputLink = outputFolderLink 
} 
 
function setStateFolder(isOpen) 
{ 
  var subEntries 
  var totalHeight 
  var fIt = 0 
  var i=0 
 
  if (isOpen == this.isOpen) 
    return 
 
  if (browserVersion == 2)  
  { 
    totalHeight = 0 
    for (i=0; i < this.nChildren; i++) 
      totalHeight = totalHeight + this.children[i].navObj.clip.height 
      subEntries = this.subEntries() 
    if (this.isOpen) 
      totalHeight = 0 - totalHeight 
    for (fIt = this.id + subEntries + 1; fIt < nEntries; fIt++) 
      indexOfEntries[fIt].navObj.moveBy(0, totalHeight) 
  }  
  this.isOpen = isOpen 
  propagateChangesInState(this) 
} 
 
function propagateChangesInState(folder) 
{   
  var i=0 
 
  if (folder.isOpen) 
  { 
    if (folder.nodeImg) 
      if (folder.isLastNode) 
        folder.nodeImg.src = ImagesDirectory+"ftv2mlastnode.gif" 
      else 
	  folder.nodeImg.src = ImagesDirectory+"ftv2mnode.gif" 
    	if(ImagesOn){
		folder.iconImg.src = "<CFOUTPUT>#Attributes.OpenFolderImagePath#</CFOUTPUT>"}
		else{
		folder.iconImg.src = ImagesDirectory+"fill.gif"}
    for (i=0; i<folder.nChildren; i++) 
      folder.children[i].display() 
  } 
  else 
  { 
    if (folder.nodeImg) 
      if (folder.isLastNode) 
        folder.nodeImg.src = ImagesDirectory+"ftv2plastnode.gif" 
      else 
	  folder.nodeImg.src = ImagesDirectory+"ftv2pnode.gif" 
    	if(ImagesOn){
			folder.iconImg.src = ImagesDirectory+"ftv2folderclosed.gif"}
		else{
			folder.iconImg.src = ImagesDirectory+"fill.gif"}
    for (i=0; i<folder.nChildren; i++) 
      folder.children[i].hide() 
  }  
} 
 
function hideFolder() 
{ 
  if (browserVersion == 1) { 
    if (this.navObj.style.display == "none") 
      return 
    this.navObj.style.display = "none" 
  } else { 
    if (this.navObj.visibility == "hiden") 
      return 
    this.navObj.visibility = "hiden" 
  } 
   
  this.setState(0) 
} 
 
function initializeFolder(level, lastNode, leftSide) 
{ 
var j=0 
var i=0 
var numberOfFolders 
var numberOfDocs 
var nc 
      
  nc = this.nChildren 
   
  this.createIndex() 
 
  var auxEv = "" 
 
  if (browserVersion > 0) 
    auxEv = "<a href='javascript:clickOnNode("+this.id+")'>" 
  else 
    auxEv = "<a>" 
 
  if (level>0) 
    if (lastNode) //the last 'brother' in the children array 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' src='"+ImagesDirectory+"ftv2mlastnode.gif' width=16 height=22 border=0></a>") 
      leftSide = leftSide + "<img src='"+ImagesDirectory+"ftv2blank.gif' width=16 height=22>"  
      this.isLastNode = 1 
    } 
    else 
    { 
      this.renderOb(leftSide + auxEv + "<img name='nodeIcon" + this.id + "' src='"+ImagesDirectory+"ftv2mnode.gif' width=16 height=22 border=0></a>") 
      leftSide = leftSide  + "<img src='"+ImagesDirectory+"ftv2vertline.gif' width=16 height=22>" 
      this.isLastNode = 0 
    } 
  else 
    this.renderOb("") 
   
  if (nc > 0) 
  { 
    level = level + 1 
    for (i=0 ; i < this.nChildren; i++)  
    { 
      if (i == this.nChildren-1) 
        this.children[i].initialize(level, 1, leftSide) 
      else 
        this.children[i].initialize(level, 0, leftSide) 
      } 
  } 
} 
 
function drawFolder(leftSide) 
{ 
  if (browserVersion == 2) { 
    if (!doc.yPos) 
      doc.yPos=110 
    doc.write("<layer id='folder" + this.id + "' top=" + doc.yPos + " visibility=hiden>") 
  } 
   
  doc.write("<table ") 
  if (browserVersion == 1) 
    doc.write(" id='folder" + this.id + "' style='position:block;' ") 
  doc.write(" border=0 cellspacing=0 cellpadding=0>") 
  doc.write("<tr><td>") 
  doc.write(leftSide) 
  this.outputLink() 
  doc.write("<img name='folderIcon" + this.id + "' ") 
  doc.write("src='" + this.iconSrc+"' border=0></a>") 
  doc.write("</td><td valign=middle nowrap>") 
  if (USETEXTLINKS) 
  { 
    this.outputLink() 
    doc.write(this.desc + "</a>") 
  } 
  else 
    doc.write(this.desc) 
  doc.write("</td>")  
  doc.write("</table>") 
   
  if (browserVersion == 2) { 
    doc.write("</layer>") 
  } 
 
  if (browserVersion == 1) { 
    this.navObj = doc.all["folder"+this.id] 
    this.iconImg = doc.all["folderIcon"+this.id] 
    this.nodeImg = doc.all["nodeIcon"+this.id] 
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["folder"+this.id] 
    this.iconImg = this.navObj.document.images["folderIcon"+this.id] 
    this.nodeImg = this.navObj.document.images["nodeIcon"+this.id] 
    doc.yPos=doc.yPos+this.navObj.clip.height 
  } 
} 
 
function outputFolderLink() 
{ 
  if (this.hreference) 
  { 
    
	doc.write("<a href='" + this.hreference + "'  ") 
    if (browserVersion > 0) 
      doc.write("onClick='javascript:clickOnFolder("+this.id+")'") 
    doc.write(">") 
  } 
  else 
    doc.write("<a>") 
//  doc.write("<a href='javascript:clickOnFolder("+this.id+")'>")   
} 
 
function addChild(childNode) 
{ 
  this.children[this.nChildren] = childNode 
  this.nChildren++ 
  return childNode 
} 
 
function folderSubEntries() 
{ 
  var i = 0 
  var se = this.nChildren 
 
  for (i=0; i < this.nChildren; i++){ 
    if (this.children[i].children) //is a folder 
      se = se + this.children[i].subEntries() 
  } 
 
  return se 
} 
 
 
// Definition of class Item (a document or link inside a Folder) 
// ************************************************************* 
 
function Item(itemDescription, itemLink) // Constructor 
{ 
  // constant data 
  this.desc = itemDescription 
  this.link = itemLink 
  this.id = -1 //initialized in initalize() 
  this.navObj = 0 //initialized in render() 
  this.iconImg = 0 //initialized in render() 
  	if(ImagesOn){
	this.iconSrc = "<CFOUTPUT>#Attributes.FolderItemImagePath#</CFOUTPUT>"}
	else{
	this.iconSrc = ImagesDirectory+"fill.gif"}
   
 
  // methods 
  this.initialize = initializeItem 
  this.createIndex = createEntryIndex 
  this.hide = hideItem 
  this.display = display 
  this.renderOb = drawItem 
  this.totalHeight = totalHeight 
} 
 
function hideItem() 
{ 
  if (browserVersion == 1) { 
    if (this.navObj.style.display == "none") 
      return 
    this.navObj.style.display = "none" 
  } else { 
    if (this.navObj.visibility == "hiden") 
      return 
    this.navObj.visibility = "hiden" 
  }     
} 
 
function initializeItem(level, lastNode, leftSide) 
{  
  this.createIndex() 
 
  if (level>0) 
    if (lastNode) //the last 'brother' in the children array 
    { 
      this.renderOb(leftSide + "<img src='"+ImagesDirectory+"ftv2lastnode.gif' width=16 height=22>") 
      leftSide = leftSide + "<img src=ImagesDirectory+'ftv2blank.gif' width=16 height=22>"  
    } 
    else 
    { 
      this.renderOb(leftSide + "<img src='"+ImagesDirectory+"ftv2node.gif' width=16 height=22>") 
      leftSide = leftSide + "<img src='"+ImagesDirectory+"ftv2vertline.gif' width=16 height=22>" 
    } 
  else 
    this.renderOb("")   
} 
 
function drawItem(leftSide) 
{ 
  if (browserVersion == 2) 
    doc.write("<layer id='item" + this.id + "' top=" + doc.yPos + " visibility=hiden>") 
     
  doc.write("<table ") 
  if (browserVersion == 1) 
    doc.write(" id='item" + this.id + "' style='position:block;' ") 
  doc.write(" border=0 cellspacing=0 cellpadding=0>") 
  doc.write("<tr><td>") 
  doc.write(leftSide) 
  doc.write("<a href=" + this.link + ">") 
  doc.write("<img id='itemIcon"+this.id+"' ") 
  doc.write("src='"+this.iconSrc+"' border=0 align='absmiddle'>") 
  doc.write("</a>") 
  doc.write("</td><td valign=middle nowrap>") 
  if (USETEXTLINKS) 
    doc.write("<a href=" + this.link + ">" + this.desc + "</a>") 
  else 
    doc.write(this.desc) 
  doc.write("</table>") 
   
  if (browserVersion == 2) 
    doc.write("</layer>") 
 
  if (browserVersion == 1) { 
    this.navObj = doc.all["item"+this.id] 
    this.iconImg = doc.all["itemIcon"+this.id] 
  } else if (browserVersion == 2) { 
    this.navObj = doc.layers["item"+this.id] 
    this.iconImg = this.navObj.document.images["itemIcon"+this.id] 
    doc.yPos=doc.yPos+this.navObj.clip.height 
  } 
} 
 
 
// Methods common to both objects (pseudo-inheritance) 
// ******************************************************** 
 
function display() 
{ 
  if (browserVersion == 1) 
    this.navObj.style.display = "block" 
  else 
    this.navObj.visibility = "show" 
} 
 
function createEntryIndex() 
{ 
  this.id = nEntries 
  indexOfEntries[nEntries] = this 
  nEntries++ 
} 
 
// total height of subEntries open 
function totalHeight() //used with browserVersion == 2 
{ 
  var h = this.navObj.clip.height 
  var i = 0 
   
  if (this.isOpen) //is a folder and _is_ open 
    for (i=0 ; i < this.nChildren; i++)  
      h = h + this.children[i].totalHeight() 
 
  return h 
} 
 
 
// Events 
// ********************************************************* 
 
function clickOnFolder(folderId) 
{ 
  var clicked = indexOfEntries[folderId] 
 
  if (!clicked.isOpen) 
    clickOnNode(folderId) 
 
  return  
 
  if (clicked.isSelected) 
    return 
} 
 
function clickOnNode(folderId) 
{ 
  var clickedFolder = 0 
  var state = 0 
 
  clickedFolder = indexOfEntries[folderId] 
  state = clickedFolder.isOpen 
 
  clickedFolder.setState(!state)   
} 
 
function initializeDocument() 
{ 
  if (doc.all) 
    browserVersion = 1 //IE4   
  else 
    if (doc.layers) 
      browserVersion = 2 //NS4 
    else 
      browserVersion = 0 //other 
 
  foldersTree.initialize(0, 1, "") 
  foldersTree.display()
  
  if (browserVersion > 0) 
  { 
    doc.write("<layer top="+indexOfEntries[nEntries-1].navObj.top+">&nbsp;</layer>") 
 
    // close the whole tree 
    clickOnNode(0) 
    // open the root folder 
    clickOnNode(0) 
  } 
} 
 
// Auxiliary Functions for Folder-Treee backward compatibility 
// ********************************************************* 
 
function gFld(description, hreference) 
{ 
  folder = new Folder(description, hreference) 
  return folder 
} 
 
function gLnk(target, description, linkData) 
{ 
  fullLink = "" 
 
  if (target==0) 
  { 
    fullLink = "'"+linkData+"'" 
  } 
  else 
  { 
    if (target==1) 
       fullLink = "'http://"+linkData+"'" 
    else 
       fullLink = "'http://"+linkData+"'" 
  } 
 
  linkItem = new Item(description, fullLink)   
  return linkItem 
} 
 
function insFld(parentFolder, childFolder) 
{ 
  return parentFolder.addChild(childFolder) 
} 
 
function insDoc(parentFolder, document) 
{ 
  parentFolder.addChild(document) 
} 
 
// Global variables 
// **************** 
 
USETEXTLINKS = 1 
indexOfEntries = new Array 
nEntries = 0 
doc = document 
browserVersion = 0 
selectedFolder=0

<!--- ************************************************************************************************************************** --->

<!--- Flag to stop the loop which genereates the list text --->
<CFSET EndOfSubFolders=0>
<!--- An index for the subfolders --->
<CFSET FolderCount = 1>

<CFOUTPUT>

	foldersTree = gFld("#Attributes.RootFolderCaption#", "#Attributes.RootFolderURL#") <!--- Root object --->
		<CFSET MenuNodeCount = 1> <!--- An index for all objects in the list --->
		<CFSET ListOfFoldersToOpen = ""> <!--- Inititalize list of folder indexs to open --->
		
		<!--- Loop to build the folder list --->
		<CFLOOP CONDITION="EndOfSubFolders EQUAL 0">
			<!--- If the sequential attribute set exist, buildd the javascript menu listing--->
			<CFIF Isdefined("Attributes.SubFolder_"&FolderCount&"_Caption")>
					
					<!--- Initialize these items as list objects --->
					<CFSET ItemListName = "Attributes.SubFolder_"&FolderCount&"_Items">
					<CFSET QualifiedItemList = ListQualify(Evaluate(#ItemListName#), "")>
					<CFSET URLListName = "Attributes.SubFolder_"&FolderCount&"_ItemURLS">
					<CFSET QualifiedURLList = ListQualify(Evaluate(#URLListName#), "")>
					<CFSET FolderURL = "Attributes.SubFolder_"&FolderCount&"_URL">

					<!--- Create the sub folder object --->
					aux#FolderCount# = insFld(foldersTree, gFld("#Evaluate("Attributes.SubFolder_#FolderCount#_Caption")#"<CFIF isdefined(#FolderURL#)>, "#Evaluate("Attributes.SubFolder_#FolderCount#_URL")#"</CFIF>))
						<!--- Create the items within the folder--->
						<CFLOOP INDEX="LoopCount" FROM="1" TO="#ListLen(QualifiedItemList)#" STEP="1">
							insDoc(aux#FolderCount#, gLnk(0, "#ListGetAt(QualifiedItemList, LoopCount)#", "#ListGetAt(QualifiedURLList, LoopCount)#"))
						</CFLOOP>
				
					<!--- If the FolderOpen flag is tru, log the index of the menu item --->
					<CFIF evaluate("Attributes.SubFolder_#FolderCount#_FolderOpen") EQ true>
						<CFSET ListOfFoldersToOpen = ListAppend(ListOfFoldersToOpen, MenuNodeCount)>
					</CFIF>

					<CFSET FolderCount=IncrementValue(FolderCount)>
			<CFELSE>
				<CFSET EndOfSubFolders=1>
			</CFIF>
			
			<CFSET MenuNodeCount = MenuNodeCount+ListLen(QualifiedItemList) + 1>
		</CFLOOP>

	initializeDocument();
	
	<!--- Force the folders within the list open on load --->
	<CFLOOP INDEX="NodeItem" LIST="#ListOfFoldersToOpen#">
		clickOnNode(#NodeItem#);
	</CFLOOP>


</CFOUTPUT>

</SCRIPT>