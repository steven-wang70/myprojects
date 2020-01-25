#!/bin/bash

# Author : Steven Wang

# The tool to convert CSV to JSON and verse vica.
# Command line format:
# jsoncsv.sh -[fromJson|fromCSV] [-i inputFile] [-o outputFile] [-log [NONE|ERROR|WARN|INFO|DEBUG]]

display_usage() {
	echo "\nUsage:\njsoncsv.sh -[fromJson|fromCSV] [-i inputFile] [-o outputFile] [-log [NONE|ERROR|WARN|INFO|DEBUG]]\n" >&2
	exit 1
	}

# Parse parameters
for (( i=1; i<=$#; i++)); do
    VAR=${!i}
	if [ $VAR == "-fromJson" ]
	then
		if [ -n "$SOURCE_FORMAT" ]
		then
			display_usage
		else
			SOURCE_FORMAT=$VAR
		fi
	elif [ $VAR == "-fromCSV" ]
	then
		if [ -n "$SOURCE_FORMAT" ]
		then
			display_usage
		else
			SOURCE_FORMAT=$VAR
		fi
	elif [ $VAR == "-i" ]
	then
		if [ -n "$INPUT_FILE" ]
		then
			display_usage
		else
			if [ $((i)) -eq $# ]
			then
				display_usage
			fi

		    nextArg=$((i+1))
			INPUT_FILE=${!nextArg}
			i=$((i+1))
		fi
	elif [ $VAR == "-o" ]
	then
		if [ -n "$OUTPUT_FILE" ]
		then
			display_usage
		else
			if [ $((i)) -eq $# ]
			then
				display_usage
			fi

		    nextArg=$((i+1))
			OUTPUT_FILE=${!nextArg}
			i=$((i+1))
		fi
	elif [ $VAR == "-log" ]
	then
		if [ -n "$LOG_LEVEL" ]
		then
			display_usage
		else
			if [ $((i)) -eq $# ]
			then
				display_usage
			fi

		    nextArg=$((i+1))
			LOG_LEVEL=${!nextArg}
			i=$((i+1))
		fi
	else
		display_usage
	fi
done

# Make sure source format is set.
if [ -z "$SOURCE_FORMAT" ]
then
	display_usage
fi

# Make sure log level is set.
if [ -z "$LOG_LEVEL" ]
then
	LOG_LEVEL=NONE
fi

# Make sure input file exists and readable
if [ -n "$IPUT_FILE" ]
then
	if ! [ -r "$INPUT_FILE" ]
	then
		echo "Input file does not exist or is not readable" >&2
		exit 2
	fi
fi

# Make sure output file writable
if [ -n "$OUTPUT_FILE" ] && [ -e  "$OUTPUT_FILE" ]
then
	if ! [ -w "$OUTPUT_FILE" ]
	then
		echo "Output file is not writable" >&2
		exit 3
	fi
fi

CLASSPATH=jsoncsv.jar:jsoncsv/libs/commons-csv-1.7.jar:jsoncsv/libs/gson-2.6.2.jar

if [ -z $INPUT_FILE ]
then
	if [ -z $OUTPUT_FILE ]
	then
		java -cp $CLASSPATH jsoncsv.JsonCSV $SOURCE_FORMAT -log $LOG_LEVEL
	else
		java -cp $CLASSPATH jsoncsv.JsonCSV $SOURCE_FORMAT -log $LOG_LEVEL > $OUTPUT_FILE
	fi
else
	if [ -z $OUTPUT_FILE ]
	then
		java -cp $CLASSPATH jsoncsv.JsonCSV $SOURCE_FORMAT -log $LOG_LEVEL < $INPUT_FILE
	else
		java -cp $CLASSPATH jsoncsv.JsonCSV $SOURCE_FORMAT -log $LOG_LEVEL < $INPUT_FILE > $OUTPUT_FILE
	fi
fi
