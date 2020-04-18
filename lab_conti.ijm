//Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
//Inspired by Will Armour, 2018 (https://willarmour.science/how-to-automate-image-particle-analysis-by-creating-a-macro-in-imagej/)

method="_conti"; //Used method

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
Dialog.addCheckbox("White Balance", true); 
Dialog.show();
disPix = Dialog.getNumber();
disKnown = Dialog.getNumber();
minArea = Dialog.getNumber();
watershed = Dialog.getCheckbox();
whiteBalance = Dialog.getCheckbox();

//Set a watershed and white balance labels for the output names
watershedLabel = ""; 
if(watershed!=false) watershedLabel="_ws";
whiteBalancelabel ="";
if(whiteBalance!=false) whiteBalancelabel="wb_";

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
		currentNResults = nResults; //Save the number of the last result
		if(whiteBalance!=false) autoWhite(); //Ajust automatically the white balance
		getRoi(); //Add all the particles to the ROI manager
		selectWindow(whiteBalancelabel+list[i]);
		getB(); //Creates a grey image with LAB-b* channel (green particles)
		getMes(); //Measure the values of all particles and creates green/red overlay
		//This add the file name in a row 
		for (row = currentNResults; row < nResults; row++) 
		{
			setResult("Image", row, list[i]);
		}
		//Transfer the ROI overlay to the original image and save
		selectWindow(whiteBalancelabel+list[i]);
		roiManager("Show All without labels"); 
		run("Flatten");
		saveAs("Jpeg", outputPath+method+watershedLabel+".jpg");
		roiManager("Delete"); //Clear the ROI manager
		close("*"); //Close all images	
	}
	showProgress(i, list.length);  //Shows a progress bar  
}
saveAs("results", outputFolder+"results"+method+watershedLabel+ ".csv"); 
closeWin("Results"); closeWin("ROI Manager");

function getRoi()
{
	run("Duplicate...", " ");
	rename(whiteBalancelabel+list[i]+"_ori");
	run("Duplicate...", " ");
	run("8-bit");
	run("Gaussian Blur...", "sigma=2"); //Blur the particles to select the objects and not the sub-objects
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

function autoWhite()
{
	// Original code by Vytas Bindokas; Oct 2006, Univ. of Chicago
	// Code modified by Patrice Mascalchi, 2014, Univ. of Cambridge UK
	run("Select None");
	origBit = bitDepth;
	if (bitDepth() != 24) exit("Active image is not RGB");
	run("RGB Stack");
	run("Restore Selection");

	val = newArray(3);
	for (s=1;s<=3;s++) 
	{
		setSlice(s);
		run("Measure");
		val[s-1] = getResult("Mean");
		Table.deleteRows(currentNResults, currentNResults);
	}

	run("Select None");
	run("16-bit");
	run("32-bit");
	Array.getStatistics(val, min, max, mean);

	for (s=1; s<=3; s++) 
	{
		setSlice(s);
		dR = val[s-1] - mean;
		if (dR < 0) 
		{
			run("Add...", "slice value="+ abs(dR));
		} else if (dR > 0) {
			run("Subtract...", "slice value="+ abs(dR));
		}
	}

	run("16-bit");
	run("Convert Stack to RGB");
	rename(whiteBalancelabel+list[i]);
	selectWindow(whiteBalancelabel+list[i]);
	selectWindow(list[i]);
	close();
}

function closeWin(winName)
{
	if (isOpen(winName)) 
	{
		selectWindow(winName);
		run("Close");
	}
}