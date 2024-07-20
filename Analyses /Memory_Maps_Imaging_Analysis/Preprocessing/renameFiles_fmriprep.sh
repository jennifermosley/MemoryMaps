#!/bin/bash

# When complete, paste into a nano script in terminal.
# Then, make the script executable (chmod +x renameFiles_fmriprep.sh)
# Run in the directory where your 'sub-##' dirs are located: code/renameFiles_fmriprep.sh

# Base directory where your "sub-" directories are located
base_dir="."

# Find directories with "sub-" in their names
for dir in $(find "$base_dir" -type d -name "*sub-*"); do

  # Create the "ses-01" directory if it doesn't exist
  mkdir -p "$dir/ses-01"

  ## Rename ANAT files##

  # Find files with "_T1w" in their names within each "sub-" directory
  find "$dir/anat" -type f -name "*_T1w*" | while read -r file; do

    # Construct the new filename
    newfile="${file/_T1w/_ses-01_T1w}"

    # Rename the file
    mv "$file" "$newfile"

  done

  ## Rename FUNC files##

  # Check if the "func" subdirectory exists
  if [ -d "$dir/func" ]; then

    # Handle files with 'run-01_bold', 'run-02_bold', and 'run-03_bold'
    for run in 01 02 03; do
      find "$dir/func" -type f -name "*run-${run}_bold*" | while read -r file; do

        # Construct the new filename
        newfile="${file/run-${run}_bold/ses-01_task-recall_run-${run}_bold}"
        
        # Rename the file
        mv "$file" "$newfile"
      done

    done
    
    # Handle files with 'run-04_bold'
    find "$dir/func" -type f -name "*run-04_bold*" | while read -r file; do

      # Construct the new filename
      newfile="${file/run-04_bold/ses-01_task-speak_run-04_bold}"
      
      # Rename the file
      mv "$file" "$newfile"

    done
  fi

  ## Rename FUNC files##

  # Check if the "fmap" subdirectory exists
  if [ -d "$dir/fmap" ]; then

    # Handle files with 'run-01_epi' and 'run-03_epi'
    for run in 01 03; do
      find "$dir/fmap" -type f -name "*run-${run}_epi*" | while read -r file; do

        # Construct the new filename
        newfile="${file/run-${run}_epi/ses-01_dir-AP_run-${run}_epi}"
        
        # Rename the file
        mv "$file" "$newfile"
      done
    done
    
    # Handle files with 'run-02_epi' and 'run-04_epi'
    for run in 02 04; do
      find "$dir/fmap" -type f -name "*run-${run}_epi*" | while read -r file; do

        # Construct the new filename
        newfile="${file/run-${run}_epi/ses-01_dir-PA_run-${run}_epi}"
        
        # Rename the file
        mv "$file" "$newfile"
      done
    done
  fi

  ## Move directories into ses-01 directories ##

  # Move 'anat', 'func', and 'fmap' directories into 'ses-01'
  for subdir in anat func fmap; do

    if [ -d "$dir/$subdir" ]; then
      mv "$dir/$subdir" "$dir/ses-01/"
    fi
  done

done