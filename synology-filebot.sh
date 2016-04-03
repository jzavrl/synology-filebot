#!/bin/bash

# This script renames a movie or TV show using filebot,
# moves it to the desired location inside a NAS
# and downloads subtitles.

# Show help information about the script
sf-help() {
cat <<"USAGE"
Write help text
USAGE
exit 0
}

# Define global variables
input="/Users/JanZavrl/Development/Temp/Downloads"
output="/Users/JanZavrl/Development/Temp/Videos"

# Scan the folders to find new files
sf-init() {
	# Loop over our input folder to get the first level folders
	for i in "$input"/*
	do
		# Call our rename and move script with the path
		sf-move $i
	done
}

# Moves the movie or TV show and renames it properly
sf-move() {
	path=$1
	folder=$(basename $path)

	echo "$input/$folder/*"

	# Check if we have a series folder
	if [ $folder == "Series" ]
	then
		# Filebot command for series
		filebot -rename $input/$folder/* --format "$output/$folder/{n}/Season {s}/{n} - {s00e00} - {t}" --db TheTVDB --action copy
	else
		# Filebot command for movies
		filebot -rename $input/$folder/* --format "$output/$folder/{n}/{n} - ({y})" --db TheMovieDB --action copy
	fi

	# Delete all files that are below 100M so we remain with only video files
	find $output/$folder -type f ! -size +100M -delete
}

# Downloads the subtitles for the movie or TV show
sf-subtitles() {

	exit 0
}

# Deletes the old remaining files and folders
sf-cleanup() {

	exit 0
}

# Loop to read options and arguments.
while [ $1 ]; do
	case "$1" in
		'-s')
			sf-init
			;;
	esac
	shift
done
