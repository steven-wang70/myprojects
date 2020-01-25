#!/bin/bash

# Author : Steven Wang

CLASSPATH=jsoncsv.jar:jsoncsv/libs/commons-csv-1.7.jar:jsoncsv/libs/gson-2.6.2.jar

java -cp $CLASSPATH test.TestCases -fromCSV < complicated.csv
