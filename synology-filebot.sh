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
input="/volume1/Downloads"
output="/volume1/Video"

# Scan the folders to find new files
sf-init() {
	# Loop over our input folder to get the first level folders
	for i in "$input"/*
	do
		# Set path and directory variables
		path=$i
		folder=$(basename $path)

		# Call our rename and move script with the path
		sf-move $folder

		# Get missing subtitles
		sf-subtitles $folder

		# Delete the old downloaded files once completed
		sf-cleanup $folder
	done

	exit 0
}

# Moves the movie or TV show and renames it properly
sf-move() {
	folder=$1

	# Check if we have a series folder
	if [ $folder == "Series" ]
	then
		# Filebot command for series
		filebot -rename $input/$folder/* --format "$output/$folder/{n}/Season {s}/{n} - {s00e00} - {t}" --db TheTVDB
	else
		# Filebot command for movies
		filebot -rename $input/$folder/* --format "$output/$folder/{n}/{n} - ({y})" --db TheMovieDB
	fi

	# Delete all files that are below 100M so we remain with only video files
	find $output/$folder -type f ! -size +100M -delete
}

# Downloads the subtitles for the movie or TV show
sf-subtitles() {
	folder=$1
	media=$output/$folder/*

	# Check if we have a series folder
	if [ $folder == "Series" ]
	then
		media=$output/$folder/*/*
	fi

	# Download the subtitles in specified folder
	filebot -get-missing-subtitles $media -non-strict

	# Cleanup the subtitle name
	filebot -script fn:replace --def "e=.eng.srt" "r=.srt" $media
}

# Deletes the old remaining files and folders
sf-cleanup() {
	folder=$1

	# Cleanup leftover files
	filebot -script fn:cleaner $input/$folder
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
