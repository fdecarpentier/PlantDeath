inputFolder=getDirectory("Choose input folder");
//outputFolder=getDirectory("Choose output folder for the results");

imgPath=inputFolder+"eb.tif"

run("Clear Results"); 
run("Set Measurements...", "area mean min redirect=None decimal=4");
open(imgPath);
run("Duplicate...", " ");
getRoi();
selectWindow("eb.tif");
getB();
getGrey();

function getRoi()
{
	run("8-bit");
	run("Gaussian Blur...", "sigma=1.5"); //Blur the particles to be sure to select the objects and not the sub-objects
	setAutoThreshold("Default");
	run("Convert to Mask");
	run("Watershed");
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
}