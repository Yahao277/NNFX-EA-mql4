//+------------------------------------------------------------------+
//|                                              AlphaStrategyV1.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

#include <Mql4Book\Timer.mqh>
#include <NNFX\Indicators\Baseline\NiKijun.mqh>
#include <NNFX\Indicators\NiSSLActivator.mqh>
#include <NNFX\Indicators\Confirmation\NiASH.mqh>
#include <NNFX\Indicators\Volumen\NiWAE.mqh>
#include <NNFX\Indicators\Exit\NiRex.mqh>
#include <NNFX\Indicators\NiNone.mqh>
#include <NNFX\Money\NiMoney.mqh>
#include <NNFX\Money\NiMoneyScaleOut.mqh>
#include <NNFX\functions.mqh>


//--- inputs
input int InpMagic = 1024;
input int Deviation = 50;

input string x7 = "------Special Rules-----";
input bool ApplySevenCandleRule = false;
input bool ApplyOneCandleRule = true;
input bool ApplyPullbackRule = true;
input bool ApplyContinuationRule = true;

 
input string  x = "----Baseline-----";
input int   InpKijun_b = 26; //InpKijun

input string  x2 = "------C1-----------";
input int InpPeriods_C1 = 14; // InpPeriods
input ENUM_MA_METHOD InpMethod_C1 = MODE_SMA; //InpMethod

input string x3 = "------C2-----------";
input string InpModeStr_C2="Mode: 0 - RSI, 1 - Stoch";
input int InpMode_C2=0;  // InpMode
input int InpLength_C2=9; //InpLength
input int InpSmooth_Length_C2=2; // InpSmooth_Length
input int InpPrice_C2=0;    // InpPrice
                       // Applied price
                       // 0 - Close
                       // 1 - Open
                       // 2 - High
                       // 3 - Low
                       // 4 - Median
                       // 5 - Typical
                       // 6 - Weighted  
input int InpMethod_C2=0;  
                      // 0 - SMA
                      // 1 - EMA
                      // 2 - SMMA
                      // 3 - LWMA
input string x4 = "---------Volumen------";
input int  InpSensetive_v = 150; //InpSensitive
input int  InpDeadZonePip_v = 30; // InpDeadZonePip
input int  InpExplosionPower_v = 15; // InpExplosionPower
input int  InpTrendPower_v = 15; // InpTrendPower                   

input string x5 = "---------Exit---------";
input int InpSmoothing_Length_x=14; // InpSmoothing_Length
input int InpSmoothing_Method_x=0;  // InpSmoothing_Method
                                // 0 - SMA
                                // 1 - EMA
                                // 2 - SMMA
                                // 3 - LWMA
input int InpSignal_Length_x=14; // InpSignal_Length
input int InpSignal_Method_x=0;  // InpSignal_Method
                             // 0 - SMA
                             // 1 - EMA
                             // 2 - SMMA
                             // 3 - LWMA
input string x6 = "---------Monet management------";
input int InpTakeProfit = 100;
input int InpStopLoss = 100;
input double InpLotSize = 0.05;

//--- global variables
CNewBar NewBar;
string symbol;
int   period;

bool longPosition;
bool shortPosition;
bool isPositionOpened;
bool OneCandleForLong;
bool OneCandleForShort;
OrderState orderState;

EnterTime forLong;
EnterTime forShort;
TrendStatus trendStatus;

NiKijun        *baseline;
/*
NiSSLActivator *c1;
NiASH          *c2;
NiWAE          *volumeIndicator;
NiRex          *exitIndicator;
*/

NiNone *c1;
NiNone *c2;
NiNone *volumeIndicator;
NiNone *exitIndicator;


NiMoneyScaleOut        *money;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   orderState.LongPosition = false;
   orderState.ShortPosition = false;
   orderState.OrderStatus = false;
   
   symbol = _Symbol;
   period = _Period;
   
   baseline = new NiKijun(InpKijun_b);
   /*
   c1 = new NiSSLActivator(InpPeriods_C1,InpMethod_C1);
   c2 = new NiASH(InpModeStr_C2,InpMode_C2,InpLength_C2,InpSmooth_Length_C2,InpPrice_C2,InpMethod_C2);
   volumeIndicator = new NiWAE(InpSensetive_v,InpDeadZonePip_v,InpExplosionPower_v,InpTrendPower_v);
   exitIndicator = new NiRex(InpSmoothing_Length_x,InpSmoothing_Method_x,InpSignal_Length_x,InpSignal_Method_x);
   */
   
   c1 = new NiNone();
   c2 = new NiNone();
   volumeIndicator = new NiNone();
   exitIndicator = new NiNone();
   
   baseline.InitIndicator(symbol,period);
   c1.InitIndicator(symbol,period);
   c2.InitIndicator(symbol,period);
   volumeIndicator.InitIndicator(symbol,period);
   exitIndicator.InitIndicator(symbol,period);
   
   //money = new NiMoney(InpLotSize,InpTakeProfit,InpStopLoss,InpMagic,Deviation);
   money = new NiMoneyScaleOut(InpLotSize,InpMagic,Deviation);

   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   delete baseline;
   delete c1;
   delete c2;
   delete volumeIndicator;
   delete exitIndicator;
   delete money;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---Detect New Bar
   bool isNewBar = NewBar.checkNewBar(_Symbol,_Period);
   //datetime t = iTime(_Symbol,_Period,0);
   
   //Print("now: " + t);
   if(!isNewBar){
      return;
   }
   
   //Print("On new Bar");
   OnBar();
   
  
  }
//+------------------------------------------------------------------+
//|OnBar function                                                    |
//+------------------------------------------------------------------+
void OnBar()
   {
   
//---Update Buffers
     Refresh();
//---Exit rules
     if(money.isOpenedPosition()){
         manageClose();
     }
     
//---Entry Rules
     if(!money.isOpenedPosition()){
         manageOpen();
     }
   }
//+------------------------------------------------------------------+
//|Open Positions: Entry rules                                       |
//+------------------------------------------------------------------+
void manageOpen()
{


   manageLong();
   
   manageShort();
   
   if(money.isOpenedPosition()) {
   //Print("Position openend...");
   //Print("position status: "+orderState.OrderStatus);
   }
  
}
/*
* Checks conditions if is possible open long positions
*/
bool manageLong()
{
   bool LongSignal = false;
   bool InSevenCandles = false;
   
   //--- Triggers an entry signal event, then checks all rules
  if(c1.entryLong() || c2.entryLong()|| baseline.entryLong() || (OneCandleForLong && ApplyOneCandleRule)){
        //--- Apply Seven Candle rule
   if(ApplySevenCandleRule)
      { InSevenCandles = SevenCandleRuleForLong(); }
   else{ InSevenCandles = false;}
   
   //-- Checks all Indicators for a long trade
   if((InSevenCandles && ApplySevenCandleRule) || !ApplySevenCandleRule ){ 
   LongSignal = checkLongConditions();
    if(OneCandleForLong && LongSignal) Print("Trade ok by one candle rule");
   }
   
         //--- Apply One candle Rule
   if(!LongSignal && !OneCandleForLong && ApplyOneCandleRule)
      { OneCandleForLong = true;}
   else if(OneCandleForLong == true)
      { OneCandleForLong = false;}

      
      //---Apply Continuation Trade Rule
   if(!LongSignal && ApplyContinuationRule && ((InSevenCandles && ApplySevenCandleRule) || !ApplySevenCandleRule))
      {  
         if(baseline.entryLong()) {
            trendStatus.EnteredInLong = Time[1];
         }
         if(trendStatus.EnteredInLong > trendStatus.EnteredInShort && trendStatus.EnteredInLong > Time[7])
         {
            LongSignal = checkContinuationLongConditions();
            if(LongSignal) Print("Continuation Trade ok");
         }
         
      }
  }
  
  if(LongSignal){
      money.OpenLong();
      Print("Open Signal Long");
  }
   return LongSignal;
}

/*
*  Use Special conditions in a continuation trade
*/
bool checkContinuationLongConditions()
{
   bool LongSignal = baseline.baselineDirection() > 0.0 && c1.confirmationLong() && c2.confirmationLong();
   return LongSignal;
}

/*
*  Checks if c1,c2 gives the signal with in seven candles
*/
bool SevenCandleRuleForLong()
{
   bool entrySignal = false;
   
   if(c1.entryLong()) forLong.c1EnteredTime = Time[1];
   if(c2.entryLong()) forLong.c2EnteredTime = Time[1];
   
   //Print("7 candle rule: c1:" + forLong.c1EnteredTime + ", c2:" + forLong.c2EnteredTime);
   //Print("7 candle rule: time: " + Time[7]);
   if(forLong.c1EnteredTime > Time[7] && forLong.c2EnteredTime > Time[7])
   {
      //Print("7 candle rule: entry");
      entrySignal = true;
   }
   return entrySignal;
}
//+------------------------------------------------------------------+
//|Check conditions for entry long position                          |
//+------------------------------------------------------------------+
bool checkLongConditions(){
   bool openSignal = false;
   double atr_value = iATR(symbol,period,14,1);
   if(volumeIndicator.confirmationLong()){ // Enough volumen to open a position
      if(baseline.baselineDirection() > 0.0 && (!ApplyPullbackRule || (ApplyPullbackRule && baseline.baselineDirection() < atr_value))){ // In long tendency
         if(c1.confirmationLong() && c2.confirmationLong()){
            openSignal = true;
         }
      }
   }
   
   Print("In long: " +volumeIndicator.confirmationLong() +" " + baseline.baselineDirection() + " "+ c1.confirmationLong() +  c2.confirmationLong());
   //openSignal = volumeIndicator.isAbleOpenPosition() && (baseline.baselineDirection(0) > 0.0) && c1.signalLong() && c2.signalLong();
   
   return openSignal;

}

bool manageShort()
{
   bool ShortSignal = false;
   bool InSevenCandles = false;
   
 if(c1.entryShort() || c2.entryShort() || baseline.entryShort() || (OneCandleForShort && ApplyOneCandleRule) ){
         //--- Apply Seven Candle rule
   if(ApplySevenCandleRule)
      { InSevenCandles = SevenCandleRuleForShort(); }
   else{ InSevenCandles = false;}
         //--------------------
   
      //-- Checks all Indicators for a short trade
   if((InSevenCandles && ApplySevenCandleRule) || !ApplySevenCandleRule ){ 
      ShortSignal = checkShortConditions();
    if(OneCandleForShort && ShortSignal) Print("Short trade ok by one candle rule");
   }  //-----------
   
      //--- Apply One candle Rule
   if(!ShortSignal && !OneCandleForShort && ApplyOneCandleRule)
      { OneCandleForShort = true;}
   else if(OneCandleForShort == true)
      { OneCandleForShort = false;} 
      //--------
      
      //---Apply Continuation Trade Rule
   if(!ShortSignal && ApplyContinuationRule && ((InSevenCandles && ApplySevenCandleRule) || !ApplySevenCandleRule))
      {  
         if(baseline.entryShort()) {
            trendStatus.EnteredInShort = Time[1];
         }
         if(trendStatus.EnteredInShort > trendStatus.EnteredInLong && trendStatus.EnteredInShort > Time[7])
         {
            ShortSignal = checkContinuationShortConditions();
            if(ShortSignal) Print("Continuation short Trade ok");
         }
         
      }// end continuation trade rule
  }
  
  
  if(ShortSignal){
      money.OpenShort();
      Print("Open Signal Short");
  }
  
  return ShortSignal;
  
}

/*
*  Use Special conditions in a continuation trade
*/
bool checkContinuationShortConditions()
{
   bool ShortSignal = baseline.baselineDirection() < 0.0 && c1.confirmationShort() && c2.confirmationShort();
   
   return ShortSignal;
}

/*
*  Checks if c1,c2 gives the signal with in seven candles
*/
bool SevenCandleRuleForShort()
{
   bool entrySignal = false;
   
   if(c1.entryShort()) forShort.c1EnteredTime = Time[1];
   if(c2.entryShort()) forShort.c2EnteredTime = Time[1];
   
   if(forShort.c1EnteredTime > Time[7] && forShort.c2EnteredTime > Time[7])
   {
      entrySignal = true;
   }
   return entrySignal;
}


//+------------------------------------------------------------------+
//|Check conditions for entry short position                         |
//+------------------------------------------------------------------+
bool checkShortConditions(){
   bool openSignal = false;
   double atr_value = iATR(symbol,period,14,1);
   
   if(volumeIndicator.confirmationShort()){
      if(baseline.baselineDirection() < 0.0 && (!ApplyPullbackRule || (ApplyPullbackRule && baseline.baselineDirection() < -1*atr_value)) ){
         if(c1.confirmationShort() && c2.confirmationShort()){
            openSignal = true;
         }
      }
   }

   Print("In short: " + volumeIndicator.confirmationShort() +" " + baseline.baselineDirection() + " "+ c1.confirmationShort() +  c2.confirmationShort());
   //openSignal = volumeIndicator.isAbleOpenPosition() && (baseline.baselineDirection(0) < 0.0) && c1.signalShort() && c2.signalShort();
   
   return openSignal;
}

//+------------------------------------------------------------------+
//|Close Positions: Exit rules                                       |
//+------------------------------------------------------------------+
void manageClose()
{  
   bool closeSignal = false;
   
   if(money.isLongPosition()){
      closeSignal = exitIndicator.exitLong();
   }else if(money.isShortPosition()){
      closeSignal = exitIndicator.exitShort();
   }
   
   if(closeSignal)
   {
      if(money.isLongPosition()){
            money.CloseLongPosition();
      }else if(money.isShortPosition()){
            money.CloseShortPosition();
      }
      
      Print("Close Signal");
      //Print("Position closed...");
      //Print("position status: "+orderState.OrderStatus);
   }

}


//+------------------------------------------------------------------+
//|Refresh indicators buffers data                                   |
//+------------------------------------------------------------------+
void Refresh()
{

   baseline.Refresh();
   c1.Refresh();
   c2.Refresh();
   volumeIndicator.Refresh();
   exitIndicator.Refresh();
   money.Refresh();
   

   
   /*Maybe In NiMomey class*/
   int i = 0;
   bool flag = false;
   while(i< OrdersTotal() && !flag)
   {
      OrderSelect(i,SELECT_BY_POS);
      if(OrderMagicNumber() == InpMagic)
      {
         flag = true;
      }
      i++;
   }

   if(!flag){ /*No orders made by this EA founded*/
      money.InitTSParams();
   }

   //Print("Orders total :" + OrdersTotal());
   
}