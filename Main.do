set scheme s2color 

* Global Directories 
global DirData "C:\Users\pah.fi\Desktop\Irrationality\Data"
global DirResults "C:\Users\pah.fi\Desktop\Irrationality\Results"
global DirDo "C:\Users\pah.fi\Desktop\Irrationality"

* Data creation 
do "$DirDo\Create_data.do"

* Data analysis
do "$DirDo\Analysis.do" 