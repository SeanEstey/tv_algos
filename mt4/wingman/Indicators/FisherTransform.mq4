//+------------------------------------------------------------------+
//|                      Fisher Transform                            |
//|                        original Fisher routine by Yura Prokofiev |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2017, Macdulio"
#property link      "http://macdulio.blogspot.co.uk"

#property indicator_separate_window
#property indicator_minimum -2
#property indicator_maximum 2
#property indicator_buffers 2
#property indicator_color1 Blue
#property indicator_color2 Red

//---- input parameters
extern int FisherPeriod   = 10;

//---- indicator buffers
double FishBuffer1[];
double FishBuffer2[];

//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int deinit() {
   // ObjectsDeleteAll(0); 
   return(0);
}


//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
int init()  {
   string short_name;
   
   //---- indicator lines
   IndicatorBuffers(2);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(0, FishBuffer1);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,2);
   SetIndexBuffer(1, FishBuffer2);
 
   //ArrayResize(FishBuffer1, 300); 
   ArrayInitialize(FishBuffer1, 0);
   //ArrayResize(FishBuffer2, 300); 
   ArrayInitialize(FishBuffer2, 0);

   short_name="Fisher Transform";
   IndicatorShortName(short_name);
   //IndicatorDigits(3);
   
   SetIndexLabel(0, "Fish1");
   SetIndexLabel(1, "Fish2");
   
  // SetIndexDrawBegin(0, FisherPeriod);
  // SetIndexDrawBegin(1, FisherPeriod);
   
   return(0);
}

//+------------------------------------------------------------------+
int start() {
   int counted_bars = IndicatorCounted();
  
   if(counted_bars <  0) {
      Print("done calculating Fisher");
      //Print("Fish[]=", (string)FishBuffer1);
      return(0);
   }
   
   int i = Bars - FisherPeriod;
   
   if(counted_bars > FisherPeriod)
      i=Bars-counted_bars-1;
   
   double MinL=0, MaxH=0, Value=0, Value1=0, Value2=0, Fish=0, price=0;
   
   Print("while loop. counted_bars=", counted_bars, ", i=", i, ", Bars=", Bars);
   
   while(i>=0) {
      MaxH = High[Highest(NULL,0,MODE_HIGH,FisherPeriod,i)];
      MinL = Low[Lowest(NULL,0,MODE_LOW,FisherPeriod,i)];
      price = (High[i]+Low[i])/2;
      Value = 0.33*2*((price-MinL)/(MaxH-MinL)-0.5) + 0.67*Value1;    
      Value = MathMin(MathMax(Value,-0.999),0.999); 
      FishBuffer1[i] = 0.5*MathLog((1+Value)/(1-Value))+0.5*Fish;
      Value1 = Value;
      
      Fish = FishBuffer1[i];
      FishBuffer2[i] = Value; // NOT SURE ABOUT THIS
      i--;
   }
   
   if(counted_bars>0)
      counted_bars--;
   int limit=Bars-counted_bars;
   
   Print("Fish=", Fish);
   
   return(0);   
}