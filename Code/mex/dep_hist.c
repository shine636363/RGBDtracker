/*
  get the depth histogram from provided image region.
  Jingjing Xiao 04/2015

  Usage 
  -----
  [His]   = dep_his(Img, Position); from 0-255

  Inputs
  ------
  Img         Image (m x n) in double format
  Position    Particles (4 x Npf) :x, y, w, h

  Ouputs
  -------
  His         Histogram of each particle (Npf x 640)
  	  
*/

#include <math.h>
#include "mex.h"


void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{	
	double *Img , *Par;  //Input
	double *His=NULL , *Area=NULL;                 //Output	
	int    *DimsBin1=NULL, *DimsBin2=NULL  ;
	int    *DimsImg, *DimsPar, numDimsBin1, numDimsBin2;		
	int    WidthImg, HeightImg, Npf, Bin ;	
	int    x1, x2, y1, y2;
	int    x, y, w, h;
	int    i, j, m, n, k;
	
	/*----------- Input 1 ---------------*/	    
    Img              = mxGetPr(prhs[0]);                  //get the image data
	DimsImg          = mxGetDimensions(prhs[0]);          //get the image size
	HeightImg        = DimsImg[0];                        
	WidthImg         = DimsImg[1];

	/*----------- Input 2 ---------------*/
	
	Par              = mxGetPr(prhs[1]);                  //get Positions
    DimsPar          = mxGetDimensions(prhs[1]);	      //get number of Positions
	Npf              = DimsPar[1];
	
	/*----------- Output 1 ---------------*/
	numDimsBin1       = 2;
	DimsBin1         = (int *)mxMalloc(numDimsBin1*sizeof(int));
	DimsBin1[0]      = Npf;
    DimsBin1[1]      = 255;
	plhs[0]         = mxCreateNumericArray(numDimsBin1, DimsBin1, mxDOUBLE_CLASS, mxREAL);
	His             = mxGetPr(plhs[0]);

	/*----------- Output 2 ---------------*/
	numDimsBin2       = 2;
	DimsBin2         = (int *)mxMalloc(numDimsBin2*sizeof(int));
	DimsBin2[0]      = Npf;
    DimsBin2[1]      = 1;
	plhs[1]         = mxCreateNumericArray(numDimsBin2, DimsBin2, mxDOUBLE_CLASS, mxREAL);
	Area            = mxGetPr(plhs[1]);

	//============ main ===============	
		
	for (i = 0 ; i < Npf ; i++)
	{
		// get the data
		x       = Par[i * 4];
		y       = Par[i * 4 + 1];
		w       = Par[i * 4 + 2];
		h       = Par[i * 4 + 3];
		Area[i] = 0;
		
		for (j = 0 ; j < 255 ; j++)
			His[i + Npf * j] = 0;

		// test the range of particles
		if ((w >0) && (h>0))
		{
			if (x<1)
				x1 = 1;
			else
				x1 = x;

			if (y<1)
				y1 = 1;
			else
				y1 = y;

			x2 = x + w - 1;
			y2 = y + h - 1;
			
			if (x2 > WidthImg)
				x2 = WidthImg;
			if (y2 > HeightImg)
				y2 = HeightImg;		

			for (m =(x1 - 1); m <=( x2 - 1) ; m++)
			{
				for (n = (y1 - 1) ; n <=(y2 - 1) ; n++)
				{
					Bin = Img[n + m * HeightImg];
					His[i+ Npf * Bin] = His[i+ Npf * Bin] + 1;
					Area[i] = Area[i] + 1;
				}
			}
			for ( k = 0; k<255; k++)
			{
				if(Area[i] != 0)
					His[i + Npf * k] = His[i + Npf * k]/Area[i];
			}
		}		
	}

	/* Free Memory */
	mxFree(DimsBin1);	
	mxFree(DimsBin2);

}