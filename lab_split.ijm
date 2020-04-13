//as directories and create a list of files
inputFolder=getDirectory("Choose input folder");
outputFolder=getDirectory("Choose output folder for the results");
list=getFileList(inputFolder);

//Create an otion dialog box
Dialog.create("Options");
Dialog.addNumber("Distance in pixels", 1);
Dialog.addNumber("Known distance", 1);
Dialog.addCheckbox("Activate Watershed", false);
Dialog.show();
disPix = Dialog.getNumber();
disKnown = Dialog.getNumber();  
watershed = Dialog.getCheckbox();

watershedLabel = ""; 
if(watershed!=false) watershedLabel="_ws";

run("Clear Results"); 
run("Set Measurements...", "area mean min redirect=None decimal=4");
setBatchMode(true);

for(i=0; i<list.length; i++)
{
	//Open the images
	imgPath=inputFolder+list[i];
	if(endsWith(imgPath, ".jpg")) open(imgPath);

	run("Set Scale...", "distance="+ disPix+ " known="+ disKnown);

	//Processes of the image to measure the area of each particle and add an overlay
	if(nImages>=1) {
		currentNResults = nResults;
		outputPath=outputFolder+list[i];
		//The following two lines removes the file extension
		fileExtension=lastIndexOf(outputPath,"."); 
		if(fileExtension!=-1) outputPath=substring(outputPath,0,fileExtension);
		run("Duplicate...", " "); 
		getRoi();
		selectWindow(list[i]);
		getB();
		getGrey();	
		for (row = currentNResults; row < nResults; row++) //This add the file name in a row 
		{
		setResult("Label", row, list[i]);
		}
	}
	showProgress(i, list.length);  //Shows a progress bar  
}
setBatchMode(false);
saveAs("results", outputFolder+ "results"+ watershedLabel+ ".csv"); 
selectWindow("Results");
run("Close"); 
close("*");

function getRoi()
{
	run("Set Scale...", "distance="+ disPix+ " known="+ disKnown);
	open(imgPath);
	run("Duplicate...", " ");
	run("8-bit");
	run("Gaussian Blur...", "sigma=1.5"); //Blur the particles to be sure to select the objects and not the sub-objects
	setAutoThreshold("Default");
	run("Convert to Mask");
	if(watershed!=false) run("Watershed");
	run("Fill Holes");
	run("Analyze Particles...","size=0-Infinity add");
}

function getB()
{
	run("RGB to CIELAB");
	for(i=0;i<2;i++)
	{
		run("Delete Slice");
	}
}

function getGrey()
{
	roiManager("Show All without labels"); //transfer the ROI
	roiManager("Set Color", "ff5def");
	roiManager("Measure");
	run("Flatten");
	roiManager("Delete");
	saveAs("Jpg", outputPath+ watershedLabel+ "_LAB_b.jpg");
}