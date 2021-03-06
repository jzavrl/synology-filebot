#!/bin/bash

# This script renames a movie or TV show using filebot,
# moves it to the desired location inside a NAS
# and downloads subtitles.

# Show help information about the script
sf-help() {
cat <<"USAGE"
This script will automatically rename and move movies and TV series from the download folder to the designated folder. Download subtitles afterwards and cleanup any remaining files and folders from the download folder.

Usage: synology-filebot

	-h, --help        Show this help screen

Examples:

	synology-filebot
	synology-filebot --help
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

	# Delete all files that are below 100M so we remain with only video files
	find $input/$folder -type f ! -size +100M -delete

	# Check if we have a series folder
	if [ $folder == "Series" ]
	then
		# Filebot command for series
		filebot -rename $input/$folder/* --format "$output/$folder/{n}/Season {s}/{n} - {s00e00} - {t}" --db TheTVDB -non-strict
	else
		# Filebot command for movies
		filebot -rename $input/$folder/* --format "$output/$folder/{n}/{n} - ({y})" --db TheMovieDB -non-strict
	fi
}

# Downloads the subtitles for the movie or TV show
sf-subtitles() {
	folder=$1

	# Download the subtitles in output folder
	filebot -script fn:suball $output/$folder -non-strict --def maxAgeDays=1

	# Cleanup the subtitle name
	filebot -script fn:replace --def "e=.eng.srt" "r=.srt" $output/$folder
}

# Deletes the old remaining files and folders
sf-cleanup() {
	folder=$1

	# Cleanup leftover files
	filebot -script fn:cleaner $input/$folder
}

# Check if we have arguments
if [ ! -z $1 ]
then
	if [ $1 == "--help" ] || [ $1 == "-h" ]
	then
		sf-help
	else
		sf-help
	fi
else
	sf-init
fi
