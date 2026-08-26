/*
<SCRIPT SRC="/Script/javascript/Queue.js"></SCRIPT>
<SCRIPT LANGUAGE="JavaSCript">
	var my_queue = new Queue();
	my_queue.addToQueue(key, val);
	my_queue.deleteFromQueue(key);
	my_queue.getValue(key);
</SCRIPT>
*/
function Queue()
{ 	
	
	/////local variables
	this.queueValueHolder = new Array();	
	/////call constructor
	this.myClass_Iniitialise 	= myClass_Initialize;
	this.myClass_Iniitialise();
	
	this.addToQueue 			= addToQueue;
	this.deleteFromQueue 		= deleteFromQueue;
	this.addObjValueToQueue		= addObjValueToQueue;
	this.deleteAndSetObjValueFromQueue		= deleteAndSetObjValueFromQueue;
	
	return this;
}


function myClass_Initialize()
{
	///any initialise code
	
}

function addToQueue(key, val)
{
	var queLen = this.queueValueHolder.length;
	this.queueValueHolder[queLen] = new Array;
	this.queueValueHolder[queLen][0] = key;
	this.queueValueHolder[queLen][1] = val;
}

function deleteFromQueue(key)
{
	var retVal = null;
	var i, queLen = this.queueValueHolder.length;
	for(i=0;i<queLen;i++)
	{
		if(this.queueValueHolder[i])
		{
			if(this.queueValueHolder[i][0] == key)
			{
				retVal = this.queueValueHolder[i][1];
				this.queueValueHolder.splice(i, 1);
				break;
			}
		}
	}
	return retVal;
}


function addObjValueToQueue(key, objExpression)
{
	var obj = eval(objExpression);
	if(obj.tagName == "INPUT")
	{
		this.addToQueue(key, obj.value);
	}
	else if(obj.tagName == "SELECT")
	{
		this.addToQueue(key, obj.selectedIndex);
	}
}

function deleteAndSetObjValueFromQueue(key, objExpression)
{
	var obj = eval(objExpression);
	if(obj.tagName == "INPUT")
	{
		obj.value = this.deleteFromQueue(key);
	}
	else if(obj.tagName == "SELECT")
	{
		obj.selectedIndex = this.deleteFromQueue(key);
	}
}
