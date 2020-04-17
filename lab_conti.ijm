//Used method
method="_conti"

//Choose directories and create a list of files
inputFolder=getDirectory("Choose input folder");
outputFolder=getDirectory("Choose output folder for the results");
list=getFileList(inputFolder);

//Create an option dialog box
Dialog.create("Options");
Dialog.addNumber("Distance in pixels", 2.85);
Dialog.addNumber("Known distance", 1);
Dialog.addNumber("Minimum area (unit"+fromCharCode(0x00B2)+")", 10);
Dialog.addCheckbox("Activate Watershed", false);
Dialog.show();
disPix = Dialog.getNumber();
disKnown = Dialog.getNumber();
minArea = Dialog.getNumber();
watershed = Dialog.getCheckbox();

//Set a watershed label for the output names
watershedLabel = ""; 
if(watershed!=false) watershedLabel="_ws";

//Choose what you need to measure
run("Set Measurements...", "area mean min redirect=None decimal=4");
run("Clear Results"); 

//Processing loop of the images
for(i=0; i<list.length; i++)
{
	//Open the images
	imgPath=inputFolder+list[i];
	open(imgPath);
	//Setup output path	
	outputPath=outputFolder+list[i];
	fileExtension=lastIndexOf(outputPath,"."); 
	if(fileExtension!=-1) outputPath=substring(outputPath,0,fileExtension);
	//Set scale according to user inputs
	run("Set Scale...", "distance="+ disPix+ " known="+ disKnown);
	if(nImages>=1) 
	{
		currentNResults = nResults; //Save the numer of the last result
		getRoi(); //Add all the particles to the ROI manager
		selectWindow(list[i]);
		getB(); //Creates a grey image with LAB-b* channel (green particles)
		getMes(); //Measure the values of all particles and creates green/red overlay
		//This add the file name in a row 
		for (row = currentNResults; row < nResults; row++) 
		{
			setResult("Image", row, list[i]);
		}
		//Transfer the ROI overlay to the original image and save
		selectWindow(list[i]);
		roiManager("Show All without labels"); 
		run("Flatten");
		saveAs("Jpeg", outputPath+method+watershedLabel+".jpg");
		roiManager("Delete"); //Clear the ROI manager
		close("*"); //Close all images	
	}
	showProgress(i, list.length);  //Shows a progress bar  
}
saveAs("results", outputFolder+"results"+method+watershedLabel+ ".csv"); 
selectWindow("Results"); run("Close"); 
selectWindow("ROI Manager"); run("Close"); 

function getRoi()
{
	run("Duplicate...", " ");
	rename(list[i]+"_ori");
	run("Duplicate...", " ");
	run("8-bit");
	run("Gaussian Blur...", "sigma=2"); //Blur the particles to be sure to select the objects and not the sub-objects
	setAutoThreshold("Default");
	run("Convert to Mask");
	if(watershed!=false) run("Watershed");
	run("Fill Holes");
	run("Erode");
	run("Dilate");
	run("Analyze Particles...","size="+minArea+"-Infinity add");
}

function getB()
{
	run("RGB to CIELAB");
	for(i=0;i<2;i++)
	{
		run("Delete Slice");
	}
}

function getMes()
{
	roiManager("Measure");
	roiManager("Deselect");
	roiManager("Set Color", "red");
	for (iRow = 0; iRow < nResults-currentNResults; iRow++)
	{
		maxParticle=getResult("Max", iRow+currentNResults);
		if (maxParticle>40)
		{
			roiManager("Select", iRow); 
			roiManager("Set Color", "Green"); 
		}
	}	
	roiManager("Show All without labels"); //transfer the ROI
	run("Flatten");
	saveAs("Jpeg", outputPath+method+watershedLabel+"_LAB_b.jpg");
}