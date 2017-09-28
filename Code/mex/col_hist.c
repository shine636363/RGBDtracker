/*
  get the histogram from provided bins.
  Jingjing Xiao 6/2014

  Usage 
  -----
  [His]   = get_his(Img, Position);

  Inputs
  ------
  Img         Image (m x n x 3) in double format
  Position    Particles (4 x Npf) :x, y, w, h

  Ouputs
  -------
  His         Histogram of each particle (Npf x 512)
  	  
*/

#include <math.h>
#include "mex.h"


void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{	
	double *Img , *Par;  //Input
	double *His, *Area = NULL ;                 //Output	
	int    *DimsBin = NULL, *DimsBin2 = NULL;
	int    *DimsImg, *DimsPar, numDimsBin, numDimsBin2;
	int    BinR, BinG, BinB;
	int    WidthImg, HeightImg, Npf ;	
	int    x1, x2, y1, y2;
	int    x, y, xy, w, h;
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
	numDimsBin       = 2;
	DimsBin         = (int *)mxMalloc(numDimsBin*sizeof(int));
	DimsBin[0]      = Npf;
    DimsBin[1]      = 512;
	plhs[0]         = mxCreateNumericArray(numDimsBin, DimsBin, mxDOUBLE_CLASS, mxREAL);
	His             = mxGetPr(plhs[0]);

	/*----------- Output 2 ---------------*/
	numDimsBin2 = 2;
	DimsBin2 = (int *)mxMalloc(numDimsBin2*sizeof(int));
	DimsBin2[0] = Npf;
	DimsBin2[1] = 1;
	plhs[1] = mxCreateNumericArray(numDimsBin2, DimsBin2, mxDOUBLE_CLASS, mxREAL);
	Area = mxGetPr(plhs[1]);

	//============ main ===============	
		
	for (i = 0 ; i < Npf ; i++)
	{
		// get the data
		x = Par[i * 4];
		y = Par[i * 4 + 1];
		w = Par[i * 4 + 2];
		h = Par[i * 4 + 3]; 
		Area[i] = 0;
		
		for (j = 0 ; j < 512 ; j++)
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

			for (m =(x1 - 1); m <( x2 - 1) ; m++)
			{
				for (n = (y1 - 1) ; n <(y2 - 1) ; n++)
				{
					BinR = floor(Img[n + m * HeightImg]/32);
					BinG = floor(Img[n + m * HeightImg + WidthImg * HeightImg]/32);
					BinB = floor(Img[n + m * HeightImg + 2 * WidthImg * HeightImg]/32);
					His[i+ Npf * (BinR + 8 * BinG + 64 * BinB)] = His[i+ Npf * (BinR + 8 * BinG + 64 * BinB)] + 1;
					Area[i] = Area[i] + 1;;
				}
			}
			for ( k = 0; k<512; k++)
			{
				if (Area[i] != 0)
					His[i + Npf * k] = His[i + Npf * k] / Area[i];
			}
		}		
	}

	/* Free Memory */
	mxFree(DimsBin);	

}