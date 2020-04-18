//Macro by Félix de Carpentier, 2020, CNRS / Sorbonne University / Paris-Saclay University, France
//Inspired by Will Armour, 2018 (https://willarmour.science/how-to-automate-image-particle-analysis-by-creating-a-macro-in-imagej/)

method="_thld"; //Used method

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
	//Open image
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
		getBBolean(); //Creates a mask with LAB-b* channel (green particles)
		getMes(); //Measure the values of all particles and creates green/red overlay
		//Add the file name in each row 
		for (row = currentNResults; row < nResults; row++)
		{
			setResult("Image", row, list[i]);
		}
		//Transfer the ROI overlay to the original image and save
		selectWindow(whiteBalancelabel+list[i]+"_ori");
		roiManager("Show All without labels"); 
		run("Flatten");
		saveAs("Jpeg", outputPath+method+watershedLabel+".jpg");
		roiManager("Delete"); //Clear the ROI manager
		close("*"); //Close all images
	}
	showProgress(i, list.length);  //Shows a progress bar 
}
saveAs("results",outputFolder+"results"+method+watershedLabel+".csv"); //Save results
closeWin("Results"); closeWin("ROI Manager");

function getRoi()
{
	run("Duplicate...", " ");
	rename(whiteBalancelabel+list[i]+"_ori");
	run("Duplicate...", " ");
	run("8-bit");
	run("Gaussian Blur...", "sigma=2"); //Blur the particles to be sure to select the objects and not the sub-objects
	setAutoThreshold("Default");
	run("Convert to Mask");
	if(watershed!=false) run("Watershed");
	run("Fill Holes");
	run("Analyze Particles...","size="+minArea+"-Infinity add");
}

function getBBolean()
{
	// Color Thresholder 2.0.0-rc-69/1.52p
	// Autogenerated macro, single images only!
	min=newArray(3);
	max=newArray(3);
	filter=newArray(3);
	a=getTitle();
	call("ij.plugin.frame.ColorThresholder.RGBtoLab");
	run("RGB Stack");
	run("Gaussian Blur...", "sigma=2"); //Blur the particles to be sure to select the objects and not the sub-objects
	run("Convert Stack to Images");
	selectWindow("Red");
	rename("0");
	selectWindow("Green");
	rename("1");
	selectWindow("Blue");
	rename("2");
	min[0]=0;
	max[0]=170;
	filter[0]="pass";
	min[1]=0;
	max[1]=255;
	filter[1]="pass";
	min[2]=140;
	max[2]=255;
	filter[2]="pass";
	for (i=0;i<3;i++)
	{
		selectWindow(""+i);
		setThreshold(min[i], max[i]);
		run("Convert to Mask");
		if (filter[i]=="stop")  run("Invert");
	}
	imageCalculator("AND create", "0","1");
	imageCalculator("AND create", "Result of 0","2");
	for (i=0;i<3;i++)
	{
		selectWindow(""+i);
		close();
	}
	selectWindow("Result of 0");
	close();
	selectWindow("Result of Result of 0");
	rename(a);
	run("Fill Holes");
}

function getMes()
{
	roiManager("Measure");
	roiManager("Deselect");
	roiManager("Set Color", "Red");  
	for (iRow = 0; iRow < nResults-currentNResults; iRow++)
	{
		meanParticle=getResult("Mean", iRow+currentNResults);
		if (meanParticle>30)
		{
			roiManager("Select", iRow); 
			roiManager("Set Color", "Green"); 
		}
	}
	roiManager("Show All without labels"); 
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