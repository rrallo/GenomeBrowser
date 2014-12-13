GenomeBrowser
=============

## Synopsis

This is a bundle of tools for analyzing any given VCF file and viewing relevant information about individual's SNPs (Single Nucleotide Polymorphosms).
The bundle first runs a set of Python instructions to read the given VCF file, then queries SNPedia for additional information and finally outputs all gathered data into a readable JSON format for the Mac OS X GUI to read and process.

## Requirements

Python 2.7.x to run the mkII.py script.
Mac OS X 10.8 or newer, with Xcode installed. 
Strong and reliable internet connection.

## Code Example

To begin the pipeline from the given VCF file into the required JSON formatted file you will first need to run the mkII.py program.

First cd into the GenomeBrowser/GenomeBrowser folder, where you will see the rest of the source code files.
Then run the following command:
    
    $python mkII.py [VCF input file]

Example run with our provided example data file:
    
    $python mkII.py data/example.vcf

This process can take a couple of hours depending on the size of the VCF file and your internet speed. Average runs range from 2-3 hours for a 7 million line VCF file.

This will create a file named 'snpediaMap.json' in the GenomeBrowser/GenomeGenomeBrowser directory, which will be read by the Xcode application as a database. Don't change the name of this file or the Xcode project will not be able to find the data. Once the snpediaMap.json file is completed, open GenomeBrowser/GenomeBrowser.xcodeproj with Xcode and select Run from the Product menu (command + R) to build and run the application. A window will pop up soon after when the project is done loading.

Note that the snpediaMap.json file is not formatted nicely, if you'd like to view it in standard JSON format you can run the following command:
    $python -mjson.tool snpediaMap.json

This will overwrite your current snpediaMap.json file and format it as standard JSON.


## Motivation

We built this application to easily browse and analyze important facts gathered from a specific person's VCF. Our goal was to extract phenotypic information from the individual's genotype, aiming to find as much relevant information as possible.

## Installation

Most Mac OS X systems come with python 2.7.x installed, this is an absolute requirement to run if you want to browse your own VCF File. If you don't have your own VCF File you can use ours, GenomeBrowser/GenomeBrowser/data/snpediaMap.json. Check the Alternate Options section for more information.
To install the Xcode developer tools simply go to the Mac App Store and search for 'Xcode'. Download the application and installation will be very straight-forward. Make sure to let it install it's command line tools.
To open the project simply open GenomeBrowser/ with Xcode and it should automatically find the project within.

## Additional Options

If you do not have a VCF file to provide, you can pull the snpediaMap.json file from the GenomeBrowser/GenomeBrowser/data folder into the GenomeBrowser/GenomeBrowser directory and run the Xcode applocation on our provided example data.

The bundled mkII.py will store data pulled from SNPedia locally in order to make future runs faster. If you want to remove those files for any reason, for example if you want to make sure you are getting the most up to date information from SNPedia, simply use the following command 

    $python mkII.py clean

mkII.py defaults to running in 10 processes. If you want to try to increase or decrease the amount or parrelelization, simply change the global variable NUM_OF_PROCESSES. We recommend a setting of 5-20

mkII.py supports running in the python interpreter or in other python code easily. Simply use the function mineVCF(filename) where filename is the path/name of the VCF file you want to analyze after you have imported mkII.py.

## Contributors

This project was created by Andrew Walters, Nolan Hartwick, Ellexi Snover, and Rodrigo Rallo (rrallo).
Feel free to post any issues and questions on this GitHub page!

## Contents of folder

mkII.py - 
    This file contains all code used in the data mining stage of our project.

data - 
    A folder that mkII writes and stores files in
example.vcf -
    A file in data. It contains a short example vcf file.

wikitools - 
    Third party open source python tools whose use is recomended by SNPedia.


mkII - 	This is written in python 2.7. It can be easily run from command line by 
typing...

Remaining Files - Any remaining files are part of the Xcode project structure and should not be modified or edited without appropriate technical knowledge.

   
##Additional Notes

Each entry in the vcf file should follow the form...

    CHROM	POSITION	ID	REF	ALT	QUAL FILTER FORMAT DATA

    ...Where the first entry in the DATA field contains genotype information 
    formatted as (0 or 1)/(0 or 1). Here is an example of a correctly 
    formatted VCF entry...

    1	88338	rs55700207	G	A	150.67	PASS	GT:AD:DP:GQ:PL	0/0:10,0:10:24.07:0,24,268

    ...If the VCF entry has a header, all lines in the header must be 
    prefaced by the '#' symbol.

If you want to run the program from the interpreter or another python 
file, use the mineVCF() function. This function takes a single param, 
filename, which is the path/name of the vcf file you are trying to 
analyze.


This mkII.py program will produce a large number of files including.:

    localsnpedia.json - 
    A file which locally stores information collected from SNPedia in order 
    to make repeated runs of the program more fast. It is created and stored 
    in the data folder.

    localrsnums.txt - 	
    A file which contains a list of all rs numbers that map to SNPedia. 
    Created and stored in the data folder.

    snpediaMap.json - 	
    The output file which contains all information found by mkII.

A large number of other temporary files will be generated and 
temporarily stored in the data folder. The program will remove all of 
these temp files before completion.

If you want to remove the local files for any reason, for example to 
ensure that you are getting the most up to date info from SNPedia, 
simply use the command line arguement 'clean' or call the cleanLocal() 
function. 

These local data files serve to speed up the program on repeated runs. 
The first run will take approximately two hours with a real VCF file. A 
second run with a different VCF file will take less time depending on 
how similar the genotypes for the two individuals are. For example, if 
you run an identical VCF, the program will take approximately a minute 
to complete. If use a different VCF file, in which this individual shares 
half of the SNP genotypes, the program will take aproximately an hour. 



## License

We'd like to leave this project open sourced under the Apache License for anyone to view and modify.
