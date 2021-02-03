//+------------------------------------------------------------------+
//|                                                 SSLActivator.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_plots 3

//--- indicator settings

/*
#property indicator_type1 DRAW_COLOR_LINE
#property indicator_color1  clrDeepPink,clrDarkOrange
#property indicator_label1  "SSL"
#property indicator_width1  2

#property indicator_type2 DRAW_LINE
#property indicator_color2 clrBlue

#property indicator_type3 DRAW_LINE
#property indicator_color3 clrBlue


#property indicator_type2  DRAW_LINE
#property indicator_color2 clrDeepPink
#property indicator_width2 1

#property indicator_type3  DRAW_LINE
#property indicator_color3 clrDarkOrange
#property indicator_width3 1
*/

//---input settings
input int InpPeriods = 14;
input ENUM_MA_METHOD InpMethod= MODE_SMA;

double ExtHighBuffer[];
double ExtLowBuffer[];
double ExtSSLBuffer[]; // in short color
double trend_direction[];
double SSLine[];
int activator,aux;

//--- global variables
bool ExtParameters;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit(void)
  {
   IndicatorDigits(Digits);
//--- drawing settings
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2,clrAqua);
   SetIndexStyle(1,DRAW_LINE,STYLE_DOT,1,clrCadetBlue);
   SetIndexStyle(2,DRAW_LINE,STYLE_DOT,1,clrCadetBlue);
   SetIndexStyle(3,DRAW_NONE);
   SetIndexDrawBegin(1,InpPeriods);
//--- indicator buffers mapping
   SetIndexBuffer(0,ExtSSLBuffer);
   SetIndexBuffer(1,ExtHighBuffer);
   SetIndexBuffer(2,ExtLowBuffer);
   SetIndexBuffer(3,trend_direction);

//--- name for DataWindow and indicator subwindow label
   IndicatorShortName("SSL Activator("+IntegerToString(InpPeriods)+","+IntegerToString(InpMethod)+")");
   SetIndexLabel(0,"SSL Line");
   SetIndexLabel(1,"High");
   SetIndexLabel(2,"Low");
   SetIndexLabel(3,"Direction");
   
//--- check for input parameters
   if(InpPeriods<=1)
     {
      Print("Wrong input parameters");
      ExtParameters=false;
      return(INIT_FAILED);
     }
   else
      ExtParameters=true;
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   
   int i,limit;
   if(rates_total<=InpPeriods || !ExtParameters)
      return(0);
   
//--- last counted bar will be recounted
   limit=rates_total-prev_calculated;
   if(prev_calculated>0)
      limit++;
/*

      int bars = rates_total - 1;
   if(prev_calculated == 0){
      //--- set first candle
      bars = bars - 1;
      
   }
  
   if(prev_calculated > 0) bars = rates_total - (prev_calculated -1);
   
   */
   
   int old_trend;
   for(int i=limit - 1;i>=0;i--){

      double smaHigh = iMA(_Symbol,_Period,InpPeriods,0,InpMethod,PRICE_HIGH,i+1);
      double smaLow = iMA(_Symbol,_Period,InpPeriods,0,InpMethod,PRICE_LOW,i+1);
      
      ExtLowBuffer[i] = smaLow;
      ExtHighBuffer[i] = smaHigh;
      

         if (Close[i] > smaHigh) {
         activator = 1; // buy
            
         }else if (Close[i] < smaLow) 
         {
            activator = 2; // sell
            
         }else{
            activator = 0;
         }
      
      
      //---draw
      if(activator != 0){
         aux = activator;
      }

      if(aux == 2){
         ExtSSLBuffer[i] = smaHigh;
         trend_direction[i] = 0;
      }else
      {
         ExtSSLBuffer[i] = smaLow;
         trend_direction[i] = 1;
      }
   }
   
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+


