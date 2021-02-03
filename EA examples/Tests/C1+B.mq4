//+------------------------------------------------------------------+
//|                                          SingleIndicatorTest.mq4 |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict


#include <Mql4Book\Timer.mqh>

#include <NNFX\Indicators\Baseline\NiKijun.mqh>
#include <NNFX\Indicators\Baseline\NiMA.mqh>
#include <NNFX\Indicators\NiSSLActivator.mqh>
#include <NNFX\Indicators\Confirmation\NiASH.mqh>
#include <NNFX\Indicators\Volumen\NiWAE.mqh>
#include <NNFX\Indicators\Exit\NiRex.mqh>

#include <NNFX\Money\NiMoney.mqh>
#include <NNFX\Money\NiMoneyScaleOut.mqh>

#include <NNFX\NExpert.mqh>
#include <NNFX\functions.mqh>
#include <NNFX\Rules\NRules.mqh>


//--- inputs
input int InpMagic = 1024;
input int Deviation = 50;
input double InpLotSize = 0.05;
input double InpSLalpha = 1.5;
input double InpTPbeta = 1;

input string x7 = "------Special Rules-----";
input bool ApplySevenCandleRule = true;
input bool ApplyOneCandleRule = true;
input bool ApplyPullbackRule = true;
input bool ApplyContinuationRule = true;


input string  x = "----Baseline-----";
input int   InpKijun_b = 26; //InpKijun

input string x3 = "------C2-----------";
input string InpModeStr_C2="Mode: 0 - RSI, 1 - Stoch";
input int InpMode_C2=0;  // InpMode
input int InpLength_C2=9; //InpLength
input int InpSmooth_Length_C2=2; // InpSmooth_Length
input int InpPrice_C2=0;    // InpPrice
input int InpMethod_C2=0;

input string x5 = "---------Exit---------";
input int InpSmoothing_Length_x=14; // InpSmoothing_Length
input int InpSmoothing_Method_x=0;  // InpSmoothing_Method
input int InpSignal_Length_x=14; // InpSignal_Length
input int InpSignal_Method_x=0;  // InpSignal_Method

//--- global variables
CNewBar NewBar;
string symbol;
int   period;

IBaseline        *baseline;
IConfirmation    *c2;
IExit            *exitIndicator;
IMoney           *money;

IRules            *pullback_rule;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   symbol = _Symbol;
   period = _Period;

   baseline = new NiKijun(InpKijun_b);
   c2 = new NiASH(InpModeStr_C2,InpMode_C2,InpLength_C2,InpSmooth_Length_C2,InpPrice_C2,InpMethod_C2);
   exitIndicator = new NiRex(InpSmoothing_Length_x,InpSmoothing_Method_x,InpSignal_Length_x,InpSignal_Method_x);
   money = new NiMoneyScaleOut(InpLotSize,InpSLalpha,InpTPbeta,14,InpMagic,Deviation);
   
   //pullback_rule = new PullbackRule(ApplyPullbackRule);
   
   
   baseline.InitIndicator(symbol,period);
   c2.InitIndicator(symbol,period);
   
   
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
   delete c2;
   delete money;
   //delete pullback_rule;
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   //---Detect New Bar
   bool isNewBar = NewBar.checkNewBar(_Symbol,_Period);

   if(!isNewBar)
     {
      return;
     }

   OnBar();
  }
//+------------------------------------------------------------------+

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
   }
  
}

/*
* Checks conditions if is possible open long positions
*/
bool manageLong()
{
   bool LongSignal = false;
   
   //--- Triggers an entry signal event, then checks all rules
  if(baseline.entryLong() || c2.entryLong()){
  LongSignal = baseline.confirmationLong() && c2.confirmationLong();
  //LongSignal = true;
  }
  
  if(LongSignal){
      money.OpenLong();
      Print("Open Signal Long");
  }
   return LongSignal;
}


bool manageShort()
{
   bool ShortSignal = false;
   
 if(baseline.entryShort() || c2.entryShort()){
   ShortSignal = baseline.confirmationShort() && c2.confirmationShort();
   //ShortSignal = true;
  }
  
  if(ShortSignal){
      money.OpenShort();
      Print("Open Signal Short");
  }
  
  return ShortSignal;
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

   }
   

}


//+------------------------------------------------------------------+
//|Refresh indicators buffers data                                   |
//+------------------------------------------------------------------+
void Refresh()
{

   baseline.Refresh();
   c2.Refresh();
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