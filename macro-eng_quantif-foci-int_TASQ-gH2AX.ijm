///////////////////////////// Entry of quantification features /////////////////////////////
Dialog.create("!!!Before using macro!!!");
Dialog.addMessage("You have to set several parameters before using the macro:");
Dialog.addMessage("");
Dialog.addMessage("- DAPI adjustable watershed to separate nuclei,");//Adjustable watershed is able to separate badly segmented nuclei
Dialog.addMessage("- DAPI threshold (with MaxEntropy),");//segmentation of nuclei with MaxEntropy threshold
Dialog.addMessage("- DAPI threshold (with Li, for stack-by-stack),");//segmentation of nuclei with MaxEntropy threshold
Dialog.addMessage("- min size of nucleus,");//minimal size of nucleus to analyze
Dialog.addMessage("- max size of nucleus,");//minimal size of nucleus to analyze
Dialog.addMessage("- gH2AX threshold (with RenyiEntropy),");//segmentation of gH2AX foci with RenyiEntropy threshold
Dialog.addMessage("");
Dialog.addMessage("For colocalization analysis only:");
Dialog.addMessage("- TASQ threshold (with RenyiEntropy),");//segmentation of TASQ foci with RenyiEntropy threshold
Dialog.addMessage("- min size of TASQ foci,");//minimal size of TASQ foci to eliminate background noise
Dialog.addMessage("- max size of TASQ foci.");//maximal size of TASQ foci to eliminate nucleolus staining
Dialog.show();


Dialog.create("!!!Warning!!!");
Dialog.addMessage("Be sure to have installed *3D Object Counter* and *Adjustable Watershed* plugins!");//this macro needs additionnal plugins
Dialog.addMessage("Open images to analyze with *Bioformats Importer* plugin!");//images need to open
Dialog.addMessage("Be sure you have calibrated (in µm) composite images with different color channels");//this macro works with confocal images
Dialog.show();



///////// Define save directory
Dialog.create("Define save directory");
Dialog.addMessage("Choose save directory");
Dialog.show();

save_directory=getDirectory("Choose save directory");



///////// Define analysis to process
Dialog.create("Define which analysis to process");
Dialog.addMessage("Define which analysis to process (you can do both):");
Dialog.addCheckbox("Intensity analysis ", true);
Dialog.addCheckbox("Colocalization analysis ", true);
Dialog.show();

Int=Dialog.getCheckbox();
Coloc=Dialog.getCheckbox();



///////// Selection of images to process
name="name";
Dialog.create("Enter the name of images and the number of images to process");
Dialog.addMessage("Enter the name of images,");
Dialog.addString("without incremental numbers: ", name);//images from the same condition should have the same name 
Dialog.addMessage("the number of images to process,");
Dialog.addNumber("number: ", 2);//number of images with the same name
Dialog.addMessage("and the resolution of images (in px).");
resolution = newArray("512", "1024", "2048");//choice of resolution
Dialog.addChoice("lowest w or l, in px:", resolution);//if the images are not square, choose the smallest size in pixels
Dialog.show();

name= Dialog.getString();
i=Dialog.getNumber();
res=Dialog.getChoice();
r=getNumber("Confirm resolution choice:", res)/512;



///////// Selection of channel parameters
Dialog.create("Enter channels parameters");
Dialog.addNumber("DAPI channel number", 4);///value assignment for DAPI channel number
Dialog.addNumber("gH2AX channel number", 1);///value assignment for gH2AX channel number
Dialog.addNumber("TASQ channel number", 3);///value assignment for TASQ channel number
Dialog.show();

Cdapi=Dialog.getNumber();///value assignment for DAPI channel number
CgH2AX=Dialog.getNumber();///value assignment for gH2AX channel number
Ctasq=Dialog.getNumber();///value assignment for TASQ channel number



///////// Entry of quantification parameters 
Dialog.create("Enter quantification parameters");
Dialog.addNumber("DAPI MaxEntropy threshold", 24);///value assignment for dts
Dialog.addNumber("DAPI Li threshold stack-by-stack", 43);///value assignment for dsts
Dialog.addNumber("DAPI watershed", 5);///value assignment for ws
Dialog.addNumber("nucleus min size (µm)", 30);///value assignment for TASQ foci min size
Dialog.addNumber("nucleus max size (µm)", 400);///value assignment for TASQ foci max size
Dialog.addNumber("gH2AX threshold", 54);///value assignment for gts
if (Coloc){
Dialog.addNumber("TASQ threshold", 35);///value assignment for TASQ
Dialog.addNumber("TASQ foci min size (µm)", 0.08);///value assignment for TASQ foci min size
Dialog.addNumber("TASQ foci max size (µm)", 0.50);///value assignment for TASQ foci max size
}
Dialog.show();

dts=Dialog.getNumber();///value of DAPI threshold
dsts=Dialog.getNumber();///value of DAPI threshold stack-by-stack
ws=Dialog.getNumber();///value of DAPI watershed 
nmin=Dialog.getNumber();///min size value nucleus
nmax=Dialog.getNumber();///max size value nucleus
gts=Dialog.getNumber();///value of gH2AX threshold
if (Coloc){
cts=Dialog.getNumber();///value of TASQ threshold
smin=Dialog.getNumber();///min size value TASQ foci
smax=Dialog.getNumber();///max size value TASQ foci
}

///////// Print of all parameters 
print("Name:", name);
print("Number of images analyzed:", i);
print("Resolution of images:", res);
print("Channels of cells:", "Channel DAPI: "+Cdapi, "Channel gH2AX: "+CgH2AX, "Channel TASQ: "+Ctasq);
print("DAPI MaxEntropy threshold:", dts);
print("DAPI stack-by-stack Li threshold:", dsts);
print("DAPI adjustable watershed:", ws);
print("Size of nuclei (µm):", nmin+"-"+nmax);
print("gH2AX RenyiEntropy threshold:", gts);
print("Size of foci (voxels):", r+"-"+10*r);
if (Coloc){
	print("TASQ RenyiEntropy threshold:", cts);
	print("Size of Tasq foci (µm):", smin+"-"+smax);
}





///////////////////////////// Loop generation for quantification /////////////////////////////
for (k=1; k<=i; k++){
number=k;
img=name+number;//image name and number
path_DAPI_save=save_directory+"DAPI_"+number+".TIF";//save path for quantified image of DAPI
path_DAPI_project_save=save_directory+"DAPI-stack_"+number+".TIF";//save path for projected image of DAPI
path_gH2AX_save=save_directory+"gH2AX_"+number+".TIF";//save path for quantified image of gH2AX
if(Coloc){
path_tasq_coloc_save=save_directory+"tasq-coloc_"+number+".TIF";//save path for quantified image of TASQ
path_comb_save=save_directory+"comb_"+number+".TIF";//save path for quantified image of combo gH2AX and TASQ
}





///////// Renaming images
selectWindow(img);
run("Split Channels");//to separate color channels
selectWindow("C"+Ctasq+"-"+img);
rename("tasq_"+number+".TIF");//selection and renaming TASQ image
selectWindow("C"+Cdapi+"-"+img);
rename("DAPI_"+number+".TIF");//selection and renaming DAPI image
selectWindow("C"+CgH2AX+"-"+img);
rename("gH2AX_"+number+".TIF");//selection and renaming gH2AX image



///////// Thresholding of nuclei with DAPI image
selectWindow("DAPI_"+number+".TIF");
run("Z Project...", "projection=[Max Intensity]");//Z-projection of all stacks to detect nuclei
rename("stack_DAPI");
selectWindow("stack_DAPI");
	///Thresholding and converting to mask
	setAutoThreshold("MaxEntropy dark");
	setOption("BlackBackground", false);//detection of coloured element over a dark background
	setThreshold(dts, 255);//dts is value determined to select nuclei
	run("Convert to Mask");
run("Adjustable Watershed", "tolerance="+ws);//fragmentation of nuclei with ws determined
run("Analyze Particles...", "size="+nmin+"-"+nmax+" circularity=0.00-1.00 exclude clear add");//selection of ROIs
saveAs("Tiff", path_DAPI_project_save);
close("DAPI-stack_"+number+".TIF");


	///Thresholding of stack nuclei with DAPI image
	selectWindow("DAPI_"+number+".TIF");
	setAutoThreshold("Li dark");
	setOption("BlackBackground", false);//detection of coloured element over a dark background
	setThreshold(dsts, 255);
	run("Convert to Mask", "method=Li background=Dark");




///////// Thresholding of gH2AX foci
selectWindow("gH2AX_"+number+".TIF");
run("Smooth", "stack");//smooth signal
setAutoThreshold("RenyiEntropy dark");
setThreshold(gts, 255);//gts is value determined to select gH2AX signal
run("Convert to Mask", "method=RenyiEntropy background=Dark");
run("Adjustable Watershed", "tolerance=0.1 stack");

	//Loop to quantify number of gH2AX foci per nucleus
	for(c=0;c<roiManager("count");c++){
		selectWindow("gH2AX_"+number+".TIF");
		roiManager("Select",c);//selection of nucleus from ROI manager
		run("Duplicate...", "title=foci-gH2AX_"+c+1+"/"+number+" duplicate range=stack");//duplication of nucleus and renaming for quantification gH2AX_#cell/#image
		run("Clear Outside", "stack");//clear outside the ROI
		run("3D Objects Counter", "threshold=10 slice=1 min.="+r+" max.="+10*r+" objects summary");//count of gH2AX foci
		close("foci-gH2AX_"+c+1+"/"+number+"");
		close("Objects map of foci-gH2AX_"+c+1+"/"+number+"");
	}


	


if (Int){
/////////Measure of TASQ signal in nucleus
	for(c=0;c<roiManager("count");c++){
	//Duplicate of tasq
	selectWindow("tasq_"+number+".TIF");
	roiManager("Select",c);
	run("Duplicate...", "title=int-tasq-nuc_"+c+"/"+number+" duplicate range=stack");
	//Duplicate of nucleus
	selectWindow("DAPI_"+number+".TIF");
	roiManager("Select",c);
	run("Duplicate...", "title=DAPI_"+c+"/"+number+" duplicate range=stack");
	//Quantification in DAPI of TASQ fluorescence mean intensity
	selectWindow("DAPI_"+c+"/"+number);
	run("Set 3D Measurements", "volume integrated_density mean_gray_value median_gray_value maximum_gray_value dots_size=5 font_size=10 show_numbers white_numbers redirect_to=int-tasq-nuc_"+c+"/"+number+"");
	run("Clear Results");
	run("3D Objects Counter", "threshold=10 slice=1 min.="+15*r+" max.=200000 objects statistics");

	
		///Calculation of the mean result per gH2AX per nucleus
		selectWindow("Results");
		m=nResults();
		mean=0;
		if (m>0) {
			for(l=0; l<m; l++) {
    			mean=mean+getResult("Mean", l);}
    			Meannuc=mean/m;
		print("int-tasq-nuc_"+c+1+"/"+number+":", Meannuc);
		}


	//Close of duplicate of ROI
	close("int-tasq-nuc_"+c+"/"+number);
	close("DAPI_"+c+"/"+number);
	close("Objects map of DAPI_"+c+"/"+number+" redirect to int-tasq-nuc_"+c+"/"+number+"");
	
	//Save results of nuclei per image
	selectWindow("Results");
	saveAs("Results",save_directory+"int_tasq-nuc_"+name+number+"-"+c+1+".xls");//Save per nuclei
	run("Clear Results");
	}





/////////Loops to quantify fluorescence intensity in all gH2AX and mean per nucleus
for(c=0;c<roiManager("count");c++){
	//Duplicate of tasq
	selectWindow("tasq_"+number+".TIF");
	roiManager("Select",c);
	run("Duplicate...", "title=int-tasq_"+c+"/"+number+" duplicate range=stack");
	//Duplicate of gH2AX
	selectWindow("gH2AX_"+number+".TIF");
	roiManager("Select",c);
	run("Duplicate...", "title=gH2AX_"+c+"/"+number+" duplicate range=stack");
	//Quantification in gH2AX of TASQ fluorescence mean intensity
	run("Set 3D Measurements", "volume integrated_density mean_gray_value median_gray_value maximum_gray_value dots_size=5 font_size=10 show_numbers white_numbers redirect_to=int-tasq_"+c+"/"+number+"");
	selectWindow("gH2AX_"+c+"/"+number);
	run("Clear Outside", "stack");
	run("3D Objects Counter", "threshold=10 slice=1 min.="+r+" max.="+10*r+" objects statistics");

		///Calculation of the mean result per gH2AX per nucleus
		selectWindow("Results");
		n=nResults();
		totalVol=0;
		
		if (n>0) {
			for(j=0; j<n; j++) {
    			totalVol =totalVol + getResult("Mean", j);}
			Meanfoci=totalVol/n;
			print("int-tasq-gH2AX_"+c+1+"/"+number+":", Meanfoci);
		}
		
		else {
			print("int-tasq-gH2AX_"+c+1+"/"+number+":", n);
		}

	//Close of duplicate of ROI
	close("int-tasq_"+c+"/"+number);
	close("gH2AX_"+c+"/"+number);
	close("Objects map of gH2AX_"+c+"/"+number+" redirect to int-tasq_"+c+"/"+number+"");

	//Save results per nuclei
	selectWindow("Results");
	saveAs("Results",save_directory+"per-nuclei-results-int_tasq-gH2AX_"+name+number+"-"+c+1+".xls");//Save per nuclei
	run("Clear Results");
	}

}




else {
	print("* No fluorescence intensity quantification *");
}





if (Coloc){
///////// Thresholding of TASQ foci 
selectWindow("tasq_"+number+".TIF");
	///Creation of min/max filter
	run("Duplicate...", "title=tasq duplicate");//duplicate of image
	run("Minimum...", "radius="+r+" stack");//min filter
	run("Maximum...", "radius="+r+" stack");//max filter
	imageCalculator("Subtract stack", "tasq_"+number+".TIF", "tasq");//substract min/max filter image to raw image
	close("tasq");//close min/max filter image
run("Smooth", "stack");//smooth signal
	///Thresholding and converting to mask
	setAutoThreshold("RenyiEntropy dark");
	setThreshold(cts, 255);//cts is value determined to select TASQ signal
	run("Convert to Mask", "method=RenyiEntropy background=Dark");
run("Dilate", "stack");//dilate masked signal of 1px
run("Erode", "stack");//erode masked signal of 1px


	//Selection of TASQ foci in nucleus
	run("Analyze Particles...", "size="+smin+"-"+smax+" show=Masks stack");//size selection of TASQ mask
	rename("Mask of tasq_"+number+".TIF");
	imageCalculator("AND stack", "Mask of tasq_"+number+".TIF", "DAPI_"+number+".TIF");//creation of mask of colocalization between DAPI and TASQ
	run("Analyze Particles...", "size="+smin+"-"+smax+" show=Masks stack");//size selection of TASQ mask
	rename("tasq-nuc_"+number+".TIF");
	roiManager("select all");
	roiManager("Combine");//combination of ROI on mask of tasq in nucleus

	//Loop to quantify number of TASQ foci per nucleus
	for(c=0;c<roiManager("count");c++){
		selectWindow("tasq-nuc_"+number+".TIF");
		roiManager("Select",c);//selection of nucleus from ROI manager
		run("Duplicate...", "title=foci-tasq_"+c+1+"/"+number+" duplicate range=stack");//duplication of nucleus and renaming for quantification tasq_#cell/#image
		run("Clear Outside", "stack");//clear outside the ROI
		run("3D Objects Counter", "threshold=10 slice=1 min.="+r+" max.="+10*r+" objects summary");//count of colocalized foci
		close("foci-tasq_"+c+1+"/"+number+"");
		close("Objects map of foci-tasq_"+c+1+"/"+number+"");
	}



///////// Thresholding of TASQ foci colocalizing with gH2AX foci
imageCalculator("AND create stack", "tasq-nuc_"+number+".TIF", "gH2AX_"+number+".TIF");//creation of mask of colocalization between gH2AX and TASQ
rename("comb_"+number+".TIF");
roiManager("select all");
roiManager("Combine");//combination of ROI on mask of colocalization

	//Loop to quantify number of colocalized TASQ/gH2AX foci per nucleus
	for(c=0;c<roiManager("count");c++){
		selectWindow("comb_"+number+".TIF");
		roiManager("Select",c);//selection of nucleus from ROI manager
		run("Duplicate...", "title=foci-coloc_tasq-gH2AX_"+c+1+"/"+number+" duplicate range=stack");//duplication of nucleus and renaming for quantification tasq&gH2AX_#cell/#image
		run("Clear Outside", "stack");//clear outside the ROI
		run("3D Objects Counter", "threshold=10 slice=1 min.="+r+" max.="+10*r+" objects summary");//count of colocalized foci
		close("foci-coloc_tasq-gH2AX_"+c+1+"/"+number+"");
		close("Objects map of foci-coloc_tasq-gH2AX_"+c+1+"/"+number+"");
	}


	
///////// Save of results
	//Save and close TASQ images
	selectWindow("tasq-nuc_"+number+".TIF");
	saveAs("Tiff", path_tasq_coloc_save);
	close("tasq-coloc_"+number+".TIF");
	//Save and close colocalized images
	selectWindow("comb_"+number+".TIF");
	saveAs("Tiff", path_comb_save);
	close("comb_"+number+".TIF");
}



else {
	print("* No colocalization quantification *");
}



///////// Save of images and results gH2AX foci and colocalized foci per images
//Save and close DAPI images
selectWindow("DAPI_"+number+".TIF");
saveAs("Tiff", path_DAPI_save);
close("DAPI_"+number+".TIF");
//Save and close gH2AX images
selectWindow("gH2AX_"+number+".TIF");
saveAs("Tiff", path_gH2AX_save);
close("gH2AX_"+number+".TIF");
//Close of Tasq images
close("tasq_"+number+".TIF");
close("Mask of tasq_"+number+".TIF");


}




///////////////////////////// Save all quantification /////////////////////////////
selectWindow("Log");
saveAs("text",save_directory+"all-results-for-all-images-of_"+name+".txt");//Save all types of quantification for all images
run("Clear Results");
run("Close");
close("*");






///////////////////////////// Message box for macro restarting /////////////////////////////
messa= getBoolean("Do you have other images to analyze?");
Dialog.addMessage("!!!Macro should be save in macro file from ImageJ!!!");
if (messa==1){
//runMacro("name of Macro");
runMacro("macro-eng_quantif-foci-int_TASQ-gH2AX");
}
else if (messa==0) {
exit;
}
