* Global Directories for MacBook 
global DirData "/Users/paulhax/Desktop/Behavioral-Economics-/Data/"
global DirResults "/Users/paulhax/Desktop/Behavioral-Economics-/Results/"
global DirDo "/Users/paulhax/Desktop/Behavioral-Economics-/"


* Global Directories for Windows 
global DirData "C:\Users\pah.fi\Desktop\Irrationality\Data\"
global DirResults "C:\Users\pah.fi\Desktop\Irrationality\Results\"
global DirDo "C:\Users\pah.fi\Desktop\Irrationality\"

* Data creation 
do "$DirDo\Create_data.do"

* Data analysis
do "$DirDo\Analysis.do" 
