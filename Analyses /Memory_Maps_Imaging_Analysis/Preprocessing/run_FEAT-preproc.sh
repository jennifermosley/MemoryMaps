#!/bin/bash
#Don't forget to make executable: chmod +x run_FEAT-preproc.sh
# Run in subjects directory using: bash run_FEAT-preproc.sh

# Generate the subject list to make modifying this script
# to run just a subset of subjects easier.

# Define the list of subject IDs
subject_ids=("59" "61" "108")

for id in "${subject_ids[@]}" ; do
    subj="sub-$id"
    echo "===> Now Processing $subj..."
    echo
    cd $subj

        # If the brain mask doesn’t exist, create it
        if [ ! -f ses-01/anat/${subj}_ses-01_T1w_brain.nii.gz ]; then
		
	cd ses-01/anat

            echo "Skull-stripped brain not found, using bet with a fractional intensity threshold of 0.5"

            bet2 ${subj}_ses-01_T1w.nii.gz ${subj}_ses-01_T1w_brain.nii.gz -f 0.5

	cd ../..

        fi

	# If the corrected fieldmaps (AP_PA.nii.gz and AP_Cor_brain.nii.gz) don't exist, create them
	
	# Locate to fieldmap directory
	cd ses-01/fmap

	# echo "Current working directory:"
	# pwd
	# read

	if [ ! -f AP_PA.nii.gz ]; then

	echo "===> Skull-stripped and corrected fieldmaps not found, as expected - using top-up to generate processed fieldmaps"
	
	## Extract volumes of the EPI images at b-value of 0.
	fslroi ${subj}_ses-01_dir-AP_run-01_epi.nii.gz AP.nii.gz 0 1
	fslroi ${subj}_ses-01_dir-PA_run-02_epi.nii.gz PA.nii.gz 0 1

	# Merge EPIs
	fslmerge -t AP_PA AP.nii.gz PA.nii.gz
	
	# Lastly, create a file that indicates the phase-encoding direction (AP or PA) and the read-out time. Save as: acq_param.txt.

	fmap_file="acq_param.txt"

	# Create the file and add the encoding direction and TotalReadoutTime
	echo "===> Creating file $fmap_file and populating it with the encoding direction and TotalReadoutTime."

	touch "${fmap_file}"
	chmod 755 "$fmap_file"

	# Write the specified lines to the file
	echo "0 1 0 0.0278403" > $fmap_file
	echo "0 -1 0 0.0278403" >> $fmap_file

	echo "===> File $fmap_file created and populated successfully."

	# Run top-up tool:
	topup --imain=AP_PA.nii.gz --datain=acq_param.txt --config=b02b0.cnf --out=AP_PA_topup

	# Yields fieldmap magnitude image (AP_PA.nii.gz)

	# Apply new images to the original phase-encoded data
	applytopup --imain=${subj}_ses-01_dir-AP_run-01_epi.nii.gz --inindex=1 --datain=$fmap_file --topup=AP_PA_topup --method=jac --out=AP_Cor

	echo "===> Created corrected fieldmaps, now to skull-strip the corrected fieldmaps..."

	# Perform brain extraction on corrected fmap

	bet2 AP_Cor.nii.gz \
             AP_Cor_brain.nii.gz -f 0.5
	
	echo "===> Created corrected, skull-stripped fieldmaps"

	fi	

	cd ..

	# echo "Current working directory:"
	# pwd
	# read

        # Copy the design files into the subject directory, and then
        # change “sub-02” in the design files to the current subject number

        cp ../../FEAT-template/design_allruns.fsf .

	# Make these files executable in the subj directory
	chmod 755 design_allruns.fsf

        # Note that we are using the | character to delimit the patterns
        # instead of the usual / character because there are / characters
        # in the pattern.

	# Since all of our design templates have sub-02 in the file, we'll need to replace each of these with the current 
	# subject ID. 

        sed -i "s|sub-02|$subj|g" \
            "design_allruns.fsf"

        # Now everything is set up to run feat
	
	# Ask the user if they want to continue to FEAT before running (useful for troubleshooting)

    	read -p "Do you want to continue onto running FEAT for $subj? (Y/N): " answer
    
    	# Check the user's input
    	case "$answer" in
        	[Yy]* ) 
            	echo "Continuing to FEAT for $subj"
            	;;
        	[Nn]* ) 
            	echo "Exiting."
            	break
            	;;
        	* ) 
            	echo "Please answer Y or N."
            	;;
    	esac

        echo "===> Starting feat for functional runs 1 - 3"
        feat design_allruns.fsf
		echo

	echo "===> Initializing $subj FEAT processing..."

    	# Go back to the directory containing all of the subjects, and repeat the loop
    	cd ../..

	echo "Current working directory:"
	pwd

done
echo