/// ----- Initialize ----- ///

	run("ROI Manager...");

	setBatchMode(true);

	run("Open...");
	getDimensions(width,height,channels,slices,frames);
	getPixelSize (unit, pixelWidth, pixelHeight);
	
	name_cd31_tif = getTitle();
	namecd31 = File.nameWithoutExtension;
	name_aSMA_tif = replace(name_cd31_tif, "cd31", "aSMA")
	name_aSMA = substring(name_aSMA_tif,0,lengthOf(name_aSMA_tif)-4);	
	name_iba1_tif = replace(name_cd31_tif, "cd31", "iba1")
	name_iba1 = substring(name_iba1_tif,0,lengthOf(name_iba1_tif)-4);
	name_mhc2_tif = replace(name_cd31_tif, "cd31", "mhc2")
	name_mhc2 = substring(name_mhc2_tif,0,lengthOf(name_mhc2_tif)-4);
	folder = File.directory;

	open(folder+name_aSMA_tif);
	open(folder+name_iba1_tif);
	open(folder+name_mhc2_tif);

/// ----- Thresholding segmentation ----- ///

	thresh_cd31 = 30; // parameters
	minSize_cd31 = 1000; // parameters (pixel)
	
	thresh_aSMA = 45; // parameters
	minSize_aSMA = 250; // parameters (pixel)

	thresh_iba1 = 30; // parameters
	minSize_iba1 = 50; // parameters (pixel)

	thresh_mhc2 = 30; // parameters
	minSize_mhc2 = 50; // parameters (pixel)

	// Thresholding cd31
	selectWindow(name_cd31_tif);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(thresh_cd31, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("RawMask_cd31"); RawMask_cd31 = getTitle();

	// Remove small objects cd31
	selectWindow(RawMask_cd31);
	run("Analyze Particles...", "size="+minSize_cd31+"-Infinity pixel show=Masks");
	run("Invert LUT"); rename("RawMask_cd31_filt"); RawMask_cd31_filt = getTitle();
	close(RawMask_cd31)

	// Thresholding aSMA
	selectWindow(name_aSMA_tif);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(thresh_aSMA, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("RawMask_aSMA"); RawMask_aSMA = getTitle();

	// Remove small objects aSMA
	selectWindow(RawMask_aSMA);
	run("Analyze Particles...", "size="+minSize_aSMA+"-Infinity pixel show=Masks");
	run("Invert LUT"); rename("RawMask_aSMA_filt"); RawMask_aSMA_filt = getTitle();
	close(RawMask_aSMA)

	// Thresholding iba1
	selectWindow(name_iba1_tif);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(thresh_iba1, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("RawMask_iba1"); RawMask_iba1 = getTitle();

	// Remove small objects iba1
	selectWindow(RawMask_iba1);
	run("Analyze Particles...", "size="+minSize_iba1+"-Infinity pixel show=Masks");
	run("Invert LUT"); rename("RawMask_iba1_filt"); RawMask_iba1_filt = getTitle();
	close(RawMask_iba1)

	// Thresholding mhc2
	selectWindow(name_mhc2_tif);
	run("Duplicate...", " ");
	run("Gaussian Blur...", "sigma=2");
	setThreshold(thresh_mhc2, 255);
	setOption("BlackBackground", true);
	run("Convert to Mask");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("RawMask_mhc2"); RawMask_mhc2 = getTitle();

	// Remove small objects mhc2
	selectWindow(RawMask_mhc2);
	run("Analyze Particles...", "size="+minSize_mhc2+"-Infinity pixel show=Masks");
	run("Invert LUT"); rename("RawMask_mhc2_filt"); RawMask_mhc2_filt = getTitle();
	close(RawMask_mhc2)

/// ----- Determine veins diameter ----- ///

	max_cd31 = 15; // parameters
	
	selectWindow(RawMask_cd31_filt);
	run("Options...", "iterations=1 count=1 black edm=8-bit");
	run("Distance Map");
	run("Multiply...", "value="+pixelWidth+""); // rescale in µm
	run("Multiply...", "value=2"); // get from vein radius to diameter 
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("EDMin_cd31"); EDMin_cd31 = getTitle();
	
	selectWindow(EDMin_cd31);
	run("Duplicate...", " ");
	run("Maximum...", "radius="+max_cd31+"");
	imageCalculator("AND create", "EDMin_cd31-1","RawMask_cd31_filt");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("EDMin_cd31_max"); EDMin_cd31_max = getTitle(); setMinAndMax(0, 100);	
	close("EDMin_cd31-1")

/// ----- Determine artery diameter ----- ///

	max_aSMA = 15; // parameters
	
	selectWindow(RawMask_aSMA_filt);
	run("Options...", "iterations=1 count=1 black edm=8-bit");
	run("Distance Map");
	run("Multiply...", "value="+pixelWidth+""); // rescale in µm
	run("Multiply...", "value=2"); // get from vein radius to diameter 
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("EDMin_aSMA"); EDMin_aSMA = getTitle();
	
	selectWindow(EDMin_aSMA);
	run("Duplicate...", " ");
	run("Maximum...", "radius="+max_aSMA+"");
	imageCalculator("AND create", "EDMin_aSMA-1","RawMask_aSMA_filt");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames=1 pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	rename("EDMin_aSMA_max"); EDMin_aSMA_max = getTitle(); setMinAndMax(0, 100);	
	close("EDMin_aSMA-1")

/// ----- Categorize veins according to diameter ----- ///	

	bin_size = 10; // parameters
	bin_count = 5; // parameters
	minSize_cat = 200; // parameters (pixel)
	proxmap_dist = 50; // parameters (µm)
	
	binrange = newArray(bin_count);
	for(i=0; i<bin_count; i++){
		binrange[i] = (i)*bin_size;
	}
	//Array.show(binrange) 

	newImage("veins_cat", "8-bit color-mode", width, height, 1, 1, bin_count);
	newImage("veins_cat_proxmap", "8-bit color-mode", width, height, 1, 1, bin_count);
	for(i=0; i<bin_count; i++){
		selectWindow(EDMin_cd31_max);
		run("Duplicate...", " ");
		if (i==0){
			
			// Threshold veins of interest
			setThreshold(binrange[i]+1, binrange[i+1]); 
			setOption("BlackBackground", true);
			run("Convert to Mask"); rename("temp");	
			run("Analyze Particles...", "size="+minSize_cat+"-Infinity pixel show=Masks"); // remove small objects					
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("veins_cat");
			setSlice(i+1); run("Paste"); // insert image in veins_cat (stack)

			// Make proxmap of veins of interest
			selectWindow("temp_filtered"); run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("veins_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in veins_cat_proxmap (stack)
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
		}
		if ((i>0) && (i<bin_count-1)){

			// Threshold veins of interest
			setThreshold(binrange[i], binrange[i+1]);
			setOption("BlackBackground", true);
			run("Convert to Mask");	rename("temp");	
			run("Analyze Particles...", "size="+minSize_cat+"-Infinity pixel show=Masks"); // remove small objects	
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("veins_cat");
			setSlice(i+1); run("Paste"); // insert image in veins_cat (stack)

			// Make proxmap of veins of interest
			selectWindow("temp_filtered");
			run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("veins_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in veins_cat_proxmap (stack)
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
		}	
		if (i==bin_count-1){

			// Threshold veins of interest
			setThreshold(binrange[i], 255);
			setOption("BlackBackground", true);
			run("Convert to Mask");	rename("temp");	
			run("Analyze Particles...", "size="+minSize_cat+"-Infinity pixel show=Masks");
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("veins_cat");
			setSlice(i+1); run("Paste"); // insert image in veins_cat (stack)
			run("Select None");

			// Make proxmap of veins of interest						
			selectWindow("temp_filtered");
			run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");		
			run("Select All"); run("Copy");
			selectWindow("veins_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in veins_cat_proxmap (stack)
			run("Select None");
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
			
		}		
	}

	selectWindow("veins_cat");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames="+bin_count+" pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	
	// Proxmaps thresholding
	selectWindow("veins_cat_proxmap");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames="+bin_count+" pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	run("Multiply...", "value="+pixelWidth+" stack"); // get distance in µm
	setThreshold(0, proxmap_dist);
	run("Convert to Mask", "method=Default background=Dark black");
	imageCalculator("Subtract stack", "veins_cat_proxmap","veins_cat");

/// ----- Categorize arteries according to diameter ----- ///	

	bin_size = 10; // parameters
	bin_count = 5; // parameters
	minSize_cat = 200; // parameters (pixel)
	proxmap_dist = 50; // parameters (µm)
	
	binrange = newArray(bin_count);
	for(i=0; i<bin_count; i++){
		binrange[i] = (i)*bin_size;
	}
	//Array.show(binrange) 

	newImage("arteries_cat", "8-bit color-mode", width, height, 1, 1, bin_count);
	newImage("arteries_cat_proxmap", "8-bit color-mode", width, height, 1, 1, bin_count);
	for(i=0; i<bin_count; i++){
		selectWindow(EDMin_aSMA_max);
		run("Duplicate...", " ");
		if (i==0){
			
			// Threshold arteries of interest
			setThreshold(binrange[i]+1, binrange[i+1]); 
			setOption("BlackBackground", true);
			run("Convert to Mask"); rename("temp");	
			run("Analyze Particles...", "size="+minSize_cat+"-Infinity pixel show=Masks"); // remove small objects					
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("arteries_cat");
			setSlice(i+1); run("Paste"); // insert image in arteries_cat (stack)

			// Make proxmap of arteries of interest
			selectWindow("temp_filtered"); run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("arteries_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in arteries_cat_proxmap (stack)
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
		}
		if ((i>0) && (i<bin_count-1)){

			// Threshold arteries of interest
			setThreshold(binrange[i], binrange[i+1]);
			setOption("BlackBackground", true);
			run("Convert to Mask");	rename("temp");	
			run("Analyze Particles...", "size="+minSize_cat+"-Infinity pixel show=Masks"); // remove small objects	
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("arteries_cat");
			setSlice(i+1); run("Paste"); // insert image in arteries_cat (stack)

			// Make proxmap of arteries of interest
			selectWindow("temp_filtered");
			run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("arteries_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in arteries_cat_proxmap (stack)
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
		}	
		if (i==bin_count-1){

			// Threshold arteries of interest
			setThreshold(binrange[i], 255);
			setOption("BlackBackground", true);
			run("Convert to Mask");	rename("temp");	
			run("Analyze Particles...", "size="+minSize_cat+"-Infinity pixel show=Masks");
			run("Invert LUT"); rename("temp_filtered");
			run("Select All"); run("Copy");
			selectWindow("arteries_cat");
			setSlice(i+1); run("Paste"); // insert image in arteries_cat (stack)
			run("Select None");

			// Make proxmap of arteries of interest						
			selectWindow("temp_filtered");
			run("Invert");
			run("Distance Map"); rename("EDM_temp_filtered");		
			run("Select All"); run("Copy");
			selectWindow("arteries_cat_proxmap");
			setSlice(i+1); run("Paste"); // insert image in arteries_cat_proxmap (stack)
			run("Select None");
			
			close("temp"); close("temp_filtered"); close("EDM_temp_filtered");
			
		}		
	}

	selectWindow("arteries_cat");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames="+bin_count+" pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	
	// Proxmaps thresholding
	selectWindow("arteries_cat_proxmap");
	Stack.setXUnit("micron");
	run("Properties...", "channels=1 slices=1 frames="+bin_count+" pixel_width="+pixelWidth+" pixel_height="+pixelHeight+" voxel_depth=1");
	run("Multiply...", "value="+pixelWidth+" stack"); // get distance in µm
	setThreshold(0, proxmap_dist);
	run("Convert to Mask", "method=Default background=Dark black");
	imageCalculator("Subtract stack", "arteries_cat_proxmap","arteries_cat");


/// ----- Get Results ----- ///	

	// Get iba1 in veins_proxmaps
	imageCalculator("AND create stack", "veins_cat_proxmap","RawMask_iba1_filt");
	rename("iba1_veins_proxmaps"); iba1_veins_proxmaps = getTitle();

	// Get mhc2 in veins_proxmaps
	imageCalculator("AND create stack", "veins_cat_proxmap","RawMask_mhc2_filt");
	rename("mhc2_veins_proxmaps"); mhc2_veins_proxmaps = getTitle();

	// Get iba1 in arteries_proxmaps
	imageCalculator("AND create stack", "arteries_cat_proxmap","RawMask_iba1_filt");
	rename("iba1_arteries_proxmaps"); iba1_arteries_proxmaps = getTitle();

	// Get mhc2 in arteries_proxmaps
	imageCalculator("AND create stack", "arteries_cat_proxmap","RawMask_mhc2_filt");
	rename("mhc2_arteries_proxmaps"); mhc2_arteries_proxmaps = getTitle();

	// Measure areas
	veins_cat_area = newArray(bin_count);
	veins_proxmap_area = newArray(bin_count);
	arteries_cat_area = newArray(bin_count);
	arteries_proxmap_area = newArray(bin_count);
	iba1_veins_proxmaps_area = newArray(bin_count);
	iba1_veins_proxmaps_ratio = newArray(bin_count);
	mhc2_veins_proxmaps_area = newArray(bin_count);
	mhc2_veins_proxmaps_ratio = newArray(bin_count);
	iba1_arteries_proxmaps_area = newArray(bin_count);
	iba1_arteries_proxmaps_ratio = newArray(bin_count);
	mhc2_arteries_proxmaps_area = newArray(bin_count);
	mhc2_arteries_proxmaps_ratio = newArray(bin_count);
	for(i=0; i<bin_count; i++){

		// Veins 
		selectWindow("veins_cat");
		setSlice(i+1); run("Select All"); run("Measure");
		veins_cat_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		selectWindow("veins_cat_proxmap");
		setSlice(i+1); run("Select All"); run("Measure");
		veins_proxmap_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		selectWindow("iba1_veins_proxmaps");
		setSlice(i+1); run("Select All"); run("Measure");
		iba1_veins_proxmaps_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		iba1_veins_proxmaps_ratio[i] = iba1_veins_proxmaps_area[i]/veins_proxmap_area[i];

		selectWindow("mhc2_veins_proxmaps");
		setSlice(i+1); run("Select All"); run("Measure");
		mhc2_veins_proxmaps_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		mhc2_veins_proxmaps_ratio[i] = mhc2_veins_proxmaps_area[i]/veins_proxmap_area[i];

		// Arteries
		selectWindow("arteries_cat");
		setSlice(i+1); run("Select All"); run("Measure");
		arteries_cat_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		selectWindow("arteries_cat_proxmap");
		setSlice(i+1); run("Select All"); run("Measure");
		arteries_proxmap_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		selectWindow("iba1_arteries_proxmaps");
		setSlice(i+1); run("Select All"); run("Measure");
		iba1_arteries_proxmaps_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		iba1_arteries_proxmaps_ratio[i] = iba1_arteries_proxmaps_area[i]/arteries_proxmap_area[i];

		selectWindow("mhc2_arteries_proxmaps");
		setSlice(i+1); run("Select All"); run("Measure");
		mhc2_arteries_proxmaps_area[i] = getResult("IntDen",0);
		run("Select None"); run("Clear Results");

		mhc2_arteries_proxmaps_ratio[i] = mhc2_arteries_proxmaps_area[i]/arteries_proxmap_area[i];
	
	}

	// Fill ResultsTable
	for (i=0; i<bin_count; i++) {
		setResult("veins_cat_area",i,veins_cat_area[i]);
		setResult("veins_proxmap_area",i,veins_proxmap_area[i]);
		setResult("arteries_cat_area",i,arteries_cat_area[i]);
		setResult("arteries_proxmap_area",i,arteries_proxmap_area[i]);
		setResult("iba1_veins_proxmaps_area",i,iba1_veins_proxmaps_area[i]);
		setResult("iba1_veins_proxmaps_ratio",i,iba1_veins_proxmaps_ratio[i]);
		setResult("mhc2_veins_proxmaps_area",i,mhc2_veins_proxmaps_area[i]);
		setResult("mhc2_veins_proxmaps_ratio",i,mhc2_veins_proxmaps_ratio[i]);
		setResult("iba1_arteries_proxmaps_area",i,iba1_arteries_proxmaps_area[i]);
		setResult("iba1_arteries_proxmaps_ratio",i,iba1_arteries_proxmaps_ratio[i]);
		setResult("mhc2_arteries_proxmaps_area",i,mhc2_arteries_proxmaps_area[i]);
		setResult("mhc2_arteries_proxmaps_ratio",i,mhc2_arteries_proxmaps_ratio[i]);
	}
	setOption("ShowRowNumbers", false);
	updateResults;			
	

/// ----- Display ----- ///	

	selectWindow(RawMask_cd31_filt);
	run("Duplicate...", " "); rename("RawMask_cd31_filt_outlines"); RawMask_cd31_filt_outlines = getTitle();
	run("Outline");
	run("Merge Channels...", "c2=RawMask_cd31_filt_outlines c4="+name_cd31_tif+" create");
	
	selectWindow(RawMask_aSMA_filt);
	run("Duplicate...", " "); rename("RawMask_aSMA_filt_outlines"); RawMask_aSMA_filt_outlines = getTitle();
	run("Outline");
	run("Merge Channels...", "c2=RawMask_aSMA_filt_outlines c4="+name_aSMA_tif+" create");

	selectWindow(RawMask_iba1_filt);
	run("Duplicate...", " "); rename("RawMask_iba1_filt_outlines"); RawMask_iba1_filt_outlines = getTitle();
	run("Outline");
	run("Merge Channels...", "c2=RawMask_iba1_filt_outlines c4="+name_iba1_tif+" create");

	selectWindow(RawMask_mhc2_filt);
	run("Duplicate...", " "); rename("RawMask_mhc2_filt_outlines"); RawMask_mhc2_filt_outlines = getTitle();
	run("Outline");
	run("Merge Channels...", "c2=RawMask_mhc2_filt_outlines c4="+name_mhc2_tif+" create");

	setBatchMode("exit and display");
	run("Tile");
	

	
	
	
	