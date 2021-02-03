//+------------------------------------------------------------------+
//|                                                   BaseScript.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "5.00"
#property strict

#include <Mql4Book\Timer.mqh>
#include <NNFX\Indicators\Baseline\NiKijun.mqh>
#include <NNFX\Indicators\Baseline\NiMA.mqh>
#include <NNFX\Indicators\NiSSLActivator.mqh>
#include <NNFX\Indicators\Confirmation\NiASH.mqh>
#include <NNFX\Indicators\Volumen\NiWAE.mqh>
#include <NNFX\Indicators\Exit\NiRex.mqh>
#include <NNFX\Indicators\NiNone.mqh>
#include <NNFX\Money\NiMoney.mqh>
#include <NNFX\Money\NiMoneyScaleOut.mqh>

#include <NNFX\NExpert.mqh>
#include <NNFX\functions.mqh>
#include <NNFX\Rules\NRules.mqh>




//--- inputs
input int InpMagic = 1024;
input int Deviation = 50;

input string x7 = "------Special Rules-----";
input bool ApplySevenCandleRule = true;
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


IBaseline        *baseline;
IConfirmation    *c1;
IConfirmation    *c2;
IVolume          *volumeIndicator;
IExit            *exitIndicator;

IMoney           *money;
NExpert          *expert;

/*
NiNone *c1;
NiNone *c2;
NiNone *volumeIndicator;
NiNone *exitIndicator;
*/

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

   symbol = _Symbol;
   period = _Period;

   baseline = new NiKijun(InpKijun_b);
 //baseline = new NiMA(30,0,MODE_SMA,PRICE_CLOSE);

   c1 = new NiSSLActivator(InpPeriods_C1,InpMethod_C1);
   c2 = new NiASH(InpModeStr_C2,InpMode_C2,InpLength_C2,InpSmooth_Length_C2,InpPrice_C2,InpMethod_C2);
   volumeIndicator = new NiWAE(InpSensetive_v,InpDeadZonePip_v,InpExplosionPower_v,InpTrendPower_v);
   exitIndicator = new NiRex(InpSmoothing_Length_x,InpSmoothing_Method_x,InpSignal_Length_x,InpSignal_Method_x);
   money = new NiMoneyScaleOut(InpLotSize,InpMagic,Deviation);

   /*
   c1 = new NiNone();
   c2 = new NiNone();
   volumeIndicator = new NiNone();
   exitIndicator = new NiNone();
   */
     
   baseline.InitIndicator(symbol,period);
   c1.InitIndicator(symbol,period);
   c2.InitIndicator(symbol,period);
   volumeIndicator.InitIndicator(symbol,period);
   exitIndicator.InitIndicator(symbol,period);


   expert = new NExpert(baseline,c1,c2,exitIndicator,volumeIndicator,money,InpMagic,
                        ApplyPullbackRule,ApplySevenCandleRule,ApplyContinuationRule,ApplyOneCandleRule);




//money = new NiMoney(InpLotSize,InpTakeProfit,InpStopLoss,InpMagic,Deviation);



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
   delete expert;
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
   if(!isNewBar)
     {
      return;
     }

//Print("On new Bar");
   expert.OnBar();

  }
