/// ____ Initialize _________________________________________________________ ///

	run("ROI Manager...");

	setBatchMode(true);

	run("Open...");
	getDimensions(width,height,channels,slices,frames);
	getPixelSize (unit, pixelWidth, pixelHeight);
	
	fullname_ridge_tif = getTitle();
	fullname_ridge = File.nameWithoutExtension;
	folder = File.directory;

/// ____ Dialog box _________________________________________________________ ///

	Dialog.create("Ridge_Diameter_Analysis");
	Dialog.setInsets(10, 0, 0);
	Dialog.addMessage("> ridge channel", 12, "#0b5394");
	Dialog.setInsets(-10, 0, 0);
	Dialog.addMessage("_____________________________________");
	
	Dialog.setInsets(5, 0, 0);
	Dialog.addMessage(fullname_ridge_tif, 12, "#6aa84f");
	name_ridge = Dialog.addString("name", "cd31");

	// ---------------------------------------------------------------------
	
	Dialog.setInsets(10, 0, 0);
	Dialog.addMessage("> test channel", 12, "#0b5394");
	Dialog.setInsets(-10, 0, 0);
	Dialog.addMessage("_____________________________________");	

	Dialog.setInsets(5, 0, 0);
	name_test = Dialog.addString("name", "iba1");

	// ---------------------------------------------------------------------

	Dialog.setInsets(10, 0, 0);
	Dialog.addMessage("> add/sub another channel", 12, "#0b5394");
	Dialog.setInsets(-10, 0, 0);
	Dialog.addMessage("_____________________________________");	

	Dialog.setInsets(5, 0, 0);
	name_addsub = Dialog.addString("name", "none"); // select "none" to ignore

	choices = newArray("add", "subtract");
	choice_addsub = Dialog.addChoice("operation", choices, "add");
	
	// ---------------------------------------------------------------------

	Dialog.setInsets(10, 0, 0);
	Dialog.addMessage("> binary masks", 12, "#0b5394");
	Dialog.setInsets(-10, 0, 0);
	Dialog.addMessage("_____________________________________");	

	Dialog.addMessage("threshold (A.U.)  .................................................", 12, "#000000");
	Dialog.setInsets(5, 0, 0);
	thresh_ridge = Dialog.addNumber("ridge", 30.0000); // parameters
	thresh_test = Dialog.addNumber("test", 30.0000); // parameters
	thresh_addsub = Dialog.addNumber("add/sub", 30.0000); // parameters 
	
	Dialog.addMessage("min. size (number of pixels)  ............................", 12, "#000000");
	Dialog.setInsets(5, 0, 0);
	minsize_ridge = Dialog.addNumber("ridge", 250.0000); // parameters (pixel)
	minsize_test = Dialog.addNumber("test", 50.0000); // parameters (pixel)  
	minsize_addsub = Dialog.addNumber("add/sub", 50.0000); // parameters (pixel) 

	// ---------------------------------------------------------------------	

	Dialog.setInsets(10, 0, 0);
	Dialog.addMessage("> ridge map", 12, "#0b5394");
	Dialog.setInsets(-10, 0, 0);
	Dialog.addMessage("_____________________________________");

	Dialog.setInsets(5, 0, 0);
	max_filt = Dialog.addNumber("max filt. size (pixels)", 15.0000); // parameters 	
	proxmap_dist = Dialog.addNumber("analysis distance (µm)", 50.0000); // parameters (µm)
	bin_size = Dialog.addNumber("size of bins (µm)", 10.0000); // parameters
	bin_count = Dialog.addNumber("number of bins", 5.0000); // parameters	

	// ---------------------------------------------------------------------

	Dialog.show();

	name_ridge = Dialog.getString();
	name_test = Dialog.getString();
	name_addsub = Dialog.getString();
	choice_addsub = Dialog.getChoice();
	thresh_ridge = Dialog.getNumber();
	thresh_test = Dialog.getNumber();
	thresh_addsub = Dialog.getNumber();
	minsize_ridge = Dialog.getNumber();
	minsize_test = Dialog.getNumber();
	minsize_addsub = Dialog.getNumber();
	max_filt = Dialog.getNumber();
	proxmap_dist = Dialog.getNumber();
	bin_size = Dialog.getNumber();
	bin_count = Dialog.getNumber();

/// ____ Open data __________________________________________________________ ///	

	fullname_test_tif = replace(fullname_ridge_tif, name_ridge, name_test);
	fullname_test = substring(fullname_test_tif, 0, lengthOf(fullname_test_tif)-4);	
	open(folder+fullname_test_tif);

	if (name_addsub!="none"){
		fullname_addsub_tif = replace(fullname_ridge_tif, name_ridge, name_addsub);
		fullname_addsub = substring(fullname_addsub_tif, 0, lengthOf(fullname_addsub_tif)-4);	
		open(folder+fullname_addsub_tif);
	}

/// ____ Thresholding segmentation __________________________________________ ///

	// Thresholding ridge
	selectWindow(fullname_ridge_tif);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(thresh_ridge, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("RawMask_ridge"); RawMask_ridge = getTitle();

	// Remove small objects ridge
	selectWindow(RawMask_ridge);
	run("Analyze Particles...", "size="+minsize_ridge+"-Infinity pixel show=Masks");
	run("Invert LUT"); rename("RawMask_ridge_filt"); RawMask_ridge_filt = getTitle();
	close(RawMask_ridge);

	// ---------------------------------------------------------------------

	// Thresholding test
	selectWindow(fullname_test_tif);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(thresh_test, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("RawMask_test"); RawMask_test = getTitle();

	// Remove small objects test
	selectWindow(RawMask_test);
	run("Analyze Particles...", "size="+minsize_test+"-Infinity pixel show=Masks");
	run("Invert LUT"); rename("RawMask_test_filt"); RawMask_test_filt = getTitle();
	close(RawMask_test);

	// ---------------------------------------------------------------------

	if (name_addsub!="none"){

		// Thresholding addsub
		selectWindow(fullname_addsub_tif);
		run("Duplicate...", " ");
		run("Gaussian Blur...", "sigma=2");
		setThreshold(thresh_addsub, 255);
		setOption("BlackBackground", true);
		run("Convert to Mask");
		Stack.setXUnit("micron");
		run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
		rename("RawMask_addsub"); RawMask_addsub = getTitle();
	
		// Remove small objects addsub
		selectWindow(RawMask_addsub);
		run("Analyze Particles...", "size="+minsize_addsub+"-Infinity pixel show=Masks");
		run("Invert LUT"); rename("RawMask_addsub_filt"); RawMask_addsub_filt = getTitle();
		close(RawMask_addsub);
		
	}

/// ____ Add or subtract another channel _____________________________________ ///

	selectWindow(RawMask_test_filt);
	run("Duplicate...", " ");
	rename("RawMask_test_filt_backup"); 
	RawMask_test_filt_backup = getTitle();

	if (name_addsub!="none"){

		// Add addsub
		if (choice_addsub == "add"){

			imageCalculator("Add", RawMask_test_filt, RawMask_addsub_filt);
			
		}

		// Subtract addsub
		if (choice_addsub == "subtract"){

			imageCalculator("Subtract", RawMask_test_filt, RawMask_addsub_filt);
			
		}
				
	}

/// ____ Determine ridge diameter ___________________________________________ ///

	selectWindow(RawMask_ridge_filt);
	run("Options...", "iterations=1 count=1 black edm=8-bit");
	run("Distance Map");
	run("Multiply...", "value="+pixelWidth+""); // rescale in µm
	run("Multiply...", "value=2"); // get from ridge radius to diameter 
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("EDMin_ridge"); EDMin_ridge = getTitle();
	
	selectWindow(EDMin_ridge);
	run("Duplicate...", " ");
	run("Maximum...", "radius="+max_filt+"");
	imageCalculator("AND create", "EDMin_ridge-1","RawMask_ridge_filt");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("EDMin_ridge_max"); EDMin_ridge_max = getTitle(); setMinAndMax(0, 100);
	close("EDMin_ridge-1");

/// ____ Categorize ridge according to diameter _____________________________ ///	

	binrange = newArray(bin_count);
	for(i=0; i<bin_count; i++){
		binrange[i] = (i)*bin_size;
	}
	//Array.show(binrange) 

	newImage("ridge_cat", "8-bit color-mode", width, height, 1, 1, bin_count);
	ridge_cat = getTitle();
	newImage("ridge_cat_proxmap", "8-bit color-mode", width, height, 1, 1, bin_count);
	ridge_cat_proxmap = getTitle();
	for(i=0; i<bin_count; i++){
		selectWindow(EDMin_ridge_max);
		run("Duplicate...", " ");
		
		if (i==0){
			
			// Threshold ridge of interest
			setThreshold(binrange[i]+1, binrange[i+1]); 
			setOption("BlackBackground", true);
			run("Convert to Mask"); rename("temp");	
			run("Analyze Particles...", "size="+minsize_ridge+"-Infinity pixel show=Masks"); // remove small objects					
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("ridge_cat");
			setSlice(i+1); run("Paste"); // insert image in ridge_cat (stack)

			// Make proxmap of ridge of interest
			selectWindow("temp_filtered"); run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("ridge_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in ridge_cat_proxmap (stack)
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
		}
		
		if ((i>0) && (i<bin_count-1)){

			// Threshold ridge of interest
			setThreshold(binrange[i], binrange[i+1]);
			setOption("BlackBackground", true);
			run("Convert to Mask");	rename("temp");	
			run("Analyze Particles...", "size="+minsize_ridge+"-Infinity pixel show=Masks"); // remove small objects	
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("ridge_cat");
			setSlice(i+1); run("Paste"); // insert image in ridge_cat (stack)

			// Make proxmap of ridge of interest
			selectWindow("temp_filtered");
			run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("ridge_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in ridge_cat_proxmap (stack)
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
		}	
		
		if (i==bin_count-1){

			// Threshold ridge of interest
			setThreshold(binrange[i], 255);
			setOption("BlackBackground", true);
			run("Convert to Mask");	rename("temp");	
			run("Analyze Particles...", "size="+minsize_ridge+"-Infinity pixel show=Masks");
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("ridge_cat");
			setSlice(i+1); run("Paste"); // insert image in ridge_cat (stack)
			run("Select None");

			// Make proxmap of ridge of interest						
			selectWindow("temp_filtered");
			run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");		
			run("Select All"); run("Copy");
			selectWindow("ridge_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in ridge_cat_proxmap (stack)
			run("Select None");
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");			
		}
				
	}

	// ---------------------------------------------------------------------	

	// Convert pixels to µm
	selectWindow("ridge_cat");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames="+bin_count+" pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	
	// Proxmaps thresholding
	selectWindow("ridge_cat_proxmap");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames="+bin_count+" pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	run("Multiply...", "value="+pixelWidth+" stack"); // get distance in µm
	setThreshold(0, proxmap_dist);
	run("Convert to Mask", "method=Default background=Dark black");
	imageCalculator("Subtract stack", "ridge_cat_proxmap","ridge_cat");

/// ____ Get Results ________________________________________________________ ///	

	// Get test channel in ridge_proxmaps
	imageCalculator("AND create stack", "ridge_cat_proxmap","RawMask_test_filt");
	rename("test_ridge_proxmaps"); test_ridge_proxmaps = getTitle();	

	// ---------------------------------------------------------------------	

	// Measure areas
	ridge_cat_area = newArray(bin_count);
	ridge_proxmap_area = newArray(bin_count);
	test_ridge_proxmaps_area = newArray(bin_count);
	test_ridge_proxmaps_ratio = newArray(bin_count);

	if (name_addsub!="none"){
		
		addsub_ridge_proxmaps_area = newArray(bin_count);
		addsub_ridge_proxmaps_ratio = newArray(bin_count);	
		
	}

	run("Set Measurements...", "integrated redirect=None decimal=3");	
	for(i=0; i<bin_count; i++){

		selectWindow("ridge_cat");
		setSlice(i+1); run("Select All"); run("Measure");
		ridge_cat_area[i] = getResult("IntDen",0); // * (pixelWidth*pixelWidth);
		run("Select None"); run("Clear Results");

		selectWindow("ridge_cat_proxmap");
		setSlice(i+1); run("Select All"); run("Measure");
		ridge_proxmap_area[i] = getResult("IntDen",0); // * (pixelWidth*pixelWidth);
		run("Select None"); run("Clear Results");

		selectWindow("test_ridge_proxmaps");
		setSlice(i+1); run("Select All"); run("Measure");
		test_ridge_proxmaps_area[i] = getResult("IntDen",0); // * (pixelWidth*pixelWidth);
		run("Select None"); run("Clear Results");

		test_ridge_proxmaps_ratio[i] = test_ridge_proxmaps_area[i]/ridge_proxmap_area[i];

	}

	// ---------------------------------------------------------------------	

	// Fill ResultsTable
	for (i=0; i<bin_count; i++) {
		setResult("test_ridge_proxmaps_ratio", i, test_ridge_proxmaps_ratio[i]);
		setResult("ridge_cat_area", i, ridge_cat_area[i]);
		setResult("ridge_proxmap_area", i, ridge_proxmap_area[i]);
		setResult("test_ridge_proxmaps_area", i, test_ridge_proxmaps_area[i]);

	}
	setOption("ShowRowNumbers", false);
	updateResults;	

/// ____ Display ____________________________________________________________ ///	

	selectWindow(RawMask_ridge_filt);
	run("Duplicate...", " "); rename("RawMask_ridge_filt_outlines"); RawMask_ridge_filt_outlines = getTitle();
	run("Outline");
	run("Merge Channels...", "c2=RawMask_ridge_filt_outlines c4="+fullname_ridge_tif+" create");
	rename(name_ridge+"_mask_outlines");
	ridge_mask_outlines = getTitle();

	// ---------------------------------------------------------------------	
	
	selectWindow(RawMask_test_filt_backup);
	run("Duplicate...", " "); rename("RawMask_test_filt_outlines"); RawMask_test_filt_outlines = getTitle();
	run("Outline");
	run("Merge Channels...", "c2=RawMask_test_filt_outlines c4="+fullname_test_tif+" create");
	rename(name_test+"_mask_outlines");
	test_mask_outlines = getTitle();

	// ---------------------------------------------------------------------	

	if (name_addsub!="none"){

		selectWindow(RawMask_addsub_filt);
		run("Duplicate...", " "); rename("RawMask_addsub_filt_outlines"); RawMask_addsub_filt_outlines = getTitle();
		run("Outline");
		run("Merge Channels...", "c2=RawMask_addsub_filt_outlines c4="+fullname_addsub_tif+" create");
		rename(name_addsub+"_mask_outlines");
		addsub_mask_outlines = getTitle();

	}

/// ____ Rename _____________________________________________________________ ///

	if (name_addsub!="none"){

		selectWindow(RawMask_addsub_filt);
		rename(name_addsub+"_mask");

		selectWindow(RawMask_test_filt_backup);
		rename(name_test+"_mask");		

		selectWindow(RawMask_test_filt);						
		if (choice_addsub=="add"){
			rename(name_test+"+"+name_addsub+"_mask");
		}

		if (choice_addsub=="subtract"){
			rename(name_test+"-"+name_addsub+"_mask");
		}
		
	} else {

		selectWindow(RawMask_test_filt);
		rename(name_test+"_mask");

		close(RawMask_test_filt_backup);
				
	}

	selectWindow(RawMask_ridge_filt);
	rename(name_ridge+"(ridge)_mask");

	selectWindow(EDMin_ridge);
	rename("EDM_ridge");

	selectWindow(EDMin_ridge_max);
	rename("EDM_ridge_max");

	selectWindow(ridge_cat);
	rename("ridge_categories");

	selectWindow(ridge_cat_proxmap);
	rename("ridge_proxmap");

	selectWindow(test_ridge_proxmaps);
	rename(name_test+"_ridge_proxmap");

	if (name_addsub!="none"){

		selectWindow(addsub_mask_outlines);
		
	} else {

		selectWindow(test_mask_outlines);
		
	}

	// ---------------------------------------------------------------------

	setBatchMode("exit and display");
	run("Tile");

	/// ____ Close all __________________________________________________________ ///

	nextchoice = getBoolean("What next?", "Save", "CloseAll");

	if (nextchoice==0){
		
		macro "Close All Windows" { 
		while (nImages>0) { 
		selectImage(nImages); 
		close();
		}
		if (isOpen("Log")) {selectWindow("Log"); run("Close");} 
		if (isOpen("Summary")) {selectWindow("Summary"); run("Close");} 
		if (isOpen("Results")) {selectWindow("Results"); run("Close");}
		if (isOpen("ROI Manager")) {selectWindow("ROI Manager"); run("Close");}
		} 
		
	}

	