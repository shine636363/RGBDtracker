/*
  Use SLIC to segment the target.
  Jingjing Xiao 05/2013

  Usage 
  -----
  [Img, Label] = slic_segmentation(RawImg, SupNum);


  Inputs
  ------
  RawImg        Raw Image;
  SupNum        Numbers of superpixel;

  Ouputs
  -------
  Img           Segmented Img;
  Label         Clusters of superpixel
  	  
*/

#include <math.h>
#include <string>

#include "mex.h"
#include "SLIC.h"

void DoubletoUINT(int s, double* RawImg, unsigned int* Img)
{
	for (int i = 0; i < s; i++)
		{
			Img[i] = (unsigned int)(RawImg[i]);
		}
}

void UINTtoDouble(int s, double* RawImg, unsigned int* Img)
{
	for (int i = 0; i < s; i++)
		{
			RawImg[i] = (double)(Img[i]);
		}
}

void INTtoDouble(int s, double* RawImg, int* Img)
{
	for (int i = 0; i < s; i++)
		{
			RawImg[i] = (double)(Img[i]);
		}
}

void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{	
	double *RawImg, *SupNum;  //input
	double *SegImg, * Label = NULL;   //output	
	int    *DimsBin1 = NULL, *DimsBin2 = NULL;
	const int*    DimsImg;
	int    WidthImg, HeightImg;	
	int    numDimsBin1, numDimsBin2;

	/*----------- Input 1 ---------------*/
	    
    RawImg           = mxGetPr(prhs[0]);                  //get the image data
	DimsImg          = mxGetDimensions(prhs[0]);          //get the image size
	HeightImg        = DimsImg[0];                        
	WidthImg         = DimsImg[1];

	/*----------- Input 2 ---------------*/
	
	SupNum            = mxGetPr(prhs[1]);                 //Desired number of superpixels.
	int SupNumInt= (int)(*SupNum);

	/*----------- Output 1 ---------------*/

	numDimsBin1     = 3;
	DimsBin1        = (int *)mxMalloc(numDimsBin1*sizeof(int));
	DimsBin1[0]     = HeightImg;
    DimsBin1[1]     = WidthImg;
	DimsBin1[2]     = 3;
	plhs[0]         = mxCreateNumericArray(numDimsBin1, DimsBin1, mxDOUBLE_CLASS, mxREAL);
	SegImg          = mxGetPr(plhs[0]);      //segmented image

	/*----------- Output 2 ---------------*/

	numDimsBin2      = 2;
	DimsBin2        = (int *)mxMalloc(numDimsBin2*sizeof(int));
	DimsBin2[0]     = HeightImg;
    DimsBin2[1]     = WidthImg;
	plhs[1]         = mxCreateNumericArray(numDimsBin2, DimsBin2, mxDOUBLE_CLASS, mxREAL);
	Label           = mxGetPr(plhs[1]);      // image clusters
	 
	//============ main ===============	

	//----------------------------------
	// Initialize parameters
	//----------------------------------
	double m = 20;//Compactness factor. use a value ranging from 10 to 40 depending on your needs. Default is 10	
	int numlabels(0);

	//----------------------------------
	// Perform SLIC on the image buffer
	//----------------------------------
	int sz = HeightImg * WidthImg ;
	unsigned int* Img = (unsigned int*)(malloc(sizeof(unsigned int)*sz*3));
	DoubletoUINT(sz*3, RawImg, Img);


	 int* klabels = (int*)(malloc(sizeof(int)*sz));

	SLIC segment;
	segment.PerformSLICO_ForGivenK(Img, HeightImg, WidthImg,  klabels, numlabels, SupNumInt, m);
	//----------------------------------
	// Draw boundaries around segments
	//----------------------------------
	segment.DrawContoursAroundSegments(Img, klabels, HeightImg, WidthImg, 0xff0000);

	UINTtoDouble(sz*3, SegImg, Img);
	INTtoDouble(sz,Label, klabels);


	/* Free Memory */
	mxFree(DimsBin1);
	mxFree(DimsBin2);
}