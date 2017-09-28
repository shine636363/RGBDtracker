/*
  get the histogram from provided bins.
  Jingjing Xiao 6/2014

  Usage 
  -----
  [Score] = patch_sp(PatchHis, SpHis, BackScore)

  Inputs
  ------
  PatchHis       Patch histogram
  SpHis          Superpixel histogram

  Ouputs
  -------
  Score       Similarity score from patches to superpixel
  	  
*/

#include <math.h>
#include "mex.h"


void mexFunction( int nlhs, mxArray *plhs[] , int nrhs, const mxArray *prhs[] )
{	
	double *PatchHis , *SpHis;  //Input
	double *Score ;        //Output	
	int    *DimsPatch, *DimsSp;	
	int    *DimsBin=NULL ;
	int    WeightPatch, WidthPatch, WeightSp, WidthSp, numDimsBin, DimHist;
	int    i, j, k;
	
	/*----------- Input 1 ---------------*/
	    
    PatchHis         = mxGetPr(prhs[0]);                  //get the patch histogram 
	DimsPatch        = mxGetDimensions(prhs[0]);          //get the patch dimention
	WeightPatch      = DimsPatch[1]; 

	/*----------- Input 2 ---------------*/	
	SpHis            = mxGetPr(prhs[1]);   
	DimsSp           = mxGetDimensions(prhs[1]);          //get the superpixel histgram
	WeightSp         = DimsSp[1];                         //get the superpixel dimmention
	DimHist          = DimsSp[0];                         //get histogram dimention


	/*----------- Output 1 ---------------*/
	numDimsBin      = 2;
	DimsBin         = (int *)mxMalloc(numDimsBin*sizeof(int));
	DimsBin[0]      = WeightSp;
    DimsBin[1]      = WeightPatch;
	plhs[0]         = mxCreateNumericArray(numDimsBin, DimsBin, mxDOUBLE_CLASS, mxREAL);
	Score           = mxGetPr(plhs[0]);

	//============ main ===============	
	for (i = 0 ; i < WeightPatch ; i++)
	{
		for (j = 0 ; j < WeightSp ; j++)
		{
			Score[j+i*WeightSp] = 0;
			for (k = 0 ; k < DimHist ; k++)
			{
				Score[j+i*WeightSp] = Score[j+i*WeightSp] + sqrt(PatchHis[i*DimHist+k]*SpHis[j*DimHist+k]);
			}
		}
	}

	/* Free Memory */
	mxFree(DimsBin);	

}