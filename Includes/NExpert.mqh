//+------------------------------------------------------------------+
//|                                                      NExpert.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


#include <NNFX\Indicators\Interfaces.mqh>
#include <NNFX\Rules\NRules.mqh>


class NExpert
{
private:
   IBaseline         *baseline;
   IConfirmation     *c1;
   IConfirmation     *c2;
   IExit             *exitIndicator;
   IVolume           *volumeIndicator;
   IMoney            *money;
   int               magic;
   bool              LongSignal;
   bool              ShortSignal;
   
   IRules            *pullback_rule;
   IRules            *sevencandle_rule;
   IRules            *continuation_rule;
   OneCandleRule     *onecandle_rule;
   
   bool              checkLongConditions();
   bool              checkShortConditions();
   
 
public:
   NExpert(){};
   NExpert(IBaseline *b,IConfirmation *c1, IConfirmation *c2, IExit *ex,IVolume *vol, IMoney *m,
            int InpMagic,bool ApplyPullbackRule,bool ApplySevenCandleRule, bool ApplyContinuationRule,bool ApplyOneCandleRule);
   ~NExpert(){
         delete pullback_rule;
         delete sevencandle_rule;
         delete continuation_rule;
         delete onecandle_rule;
   };
   
   IBaseline*         getBaseline() {return baseline;}
   IConfirmation*     getC1(){ return c1;}
   IConfirmation*     getC2(){ return c2;}
   IExit*             getExit() { return exitIndicator;}
   IVolume*           getVolume() { return volumeIndicator;}
   IMoney*            getMoney() { return money;}
   bool              getLongSignal() {return LongSignal;}
   bool              getShortSignal() {return ShortSignal;}
   ExpertVars        getVars();
      
   void              manageLong();
   void              manageShort();
   void              manageOpen();
   void              manageClose();
   void              OnBar();
   void              Refresh();
};

NExpert::NExpert(IBaseline *b,IConfirmation *c1, IConfirmation *c2, IExit *ex,IVolume *vol, IMoney *m,
                  int InpMagic,bool ApplyPullbackRule,bool ApplySevenCandleRule, bool ApplyContinuationRule,
                  bool ApplyOneCandleRule)
{
   this.baseline = b;
   this.c1 = c1;
   this.c2 = c2;
   this.exitIndicator = ex;
   this.volumeIndicator = vol;
   this.money = m;
   magic = InpMagic;
   
   pullback_rule = new PullbackRule(ApplyPullbackRule);
   sevencandle_rule = new SevenCandleRule(ApplySevenCandleRule);
   continuation_rule = new ContinuationRule(ApplyContinuationRule);
   onecandle_rule = new OneCandleRule(ApplyOneCandleRule);
}

ExpertVars NExpert::getVars()
{
   ExpertVars vars;
   
   vars.baseline = baseline;
   vars.c1 = c1;
   vars.c2 = c2;
   vars.LongSignal = LongSignal;
   vars.ShortSignal = ShortSignal;
   
   return vars;
}


void NExpert::OnBar()
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

void NExpert::manageOpen()
{
   manageLong();
   
   manageShort();
   
   /*
   if(money.isOpenedPosition()) {
      Print("Position openend...");
      Print("position status: "+orderState.OrderStatus);
   }
   */
}
void NExpert::manageClose()
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
   }

}

void NExpert::manageLong()
{
   LongSignal = false;
   
   if(onecandle_rule.isLong()){
      LongSignal = checkLongConditions();
      onecandle_rule.checkConditionsForLong(getVars());
   }
   else if(c1.entryLong() || c2.entryLong()|| baseline.entryLong()){
      LongSignal = checkLongConditions();
      
      // Special rules
      if(LongSignal){
         // When gives us the signal, checks if is too far from the baseline
         LongSignal = pullback_rule.checkConditionsForLong(getVars());
         
         // checks if some signals, gave us the signal seven candles ago
         LongSignal = LongSignal && sevencandle_rule.checkConditionsForLong(getVars());
      }else
      {
         //When the signal is false, checks if is a continuation trade
         LongSignal = continuation_rule.checkConditionsForLong(getVars());
         //Wait one candle
         if(!LongSignal) onecandle_rule.checkConditionsForLong(getVars());
      }
  }
  
  
  if(LongSignal){
      money.OpenLong();
      Print("Open Signal Long");
  }

}


void NExpert::manageShort()
{
   ShortSignal = false;
   
   if(onecandle_rule.isShort()){
      ShortSignal = checkShortConditions();
      onecandle_rule.checkConditionsForShort(getVars());
   }
   else if(c1.entryShort() || c2.entryShort()|| baseline.entryShort()){
      ShortSignal = checkShortConditions();
      
      //Special rules
      if(ShortSignal){
      // When gives us the signal, checks if is too far from the baseline
         ShortSignal = pullback_rule.checkConditionsForShort(getVars());
         
      // checks if some signals, gave us the signal seven candles ago
         ShortSignal = ShortSignal && sevencandle_rule.checkConditionsForShort(getVars());
      }else if(!ShortSignal){
         //When the signal is false, checks if is a continuation trade
         ShortSignal = continuation_rule.checkConditionsForShort(getVars());
         //Wait one candle
         if(!ShortSignal) onecandle_rule.checkConditionsForShort(getVars());
      }
  }
  
  if(ShortSignal){
      money.OpenShort();
      Print("Open Signal Short");
  }

}


bool NExpert::checkLongConditions(void)
{
   bool Signal = false;

   if(volumeIndicator.confirmationLong()){ // Enough volumen to open a position
   
      /*TODO: baselineDirection() => confirmationLong()*/
      if(baseline.baselineDirection() > 0.0){ // In long tendency
         if(c1.confirmationLong() && c2.confirmationLong()){
            Signal = true;
         }
      }
   }
   
   //Print("In long: " +volumeIndicator.confirmationLong() +" " + baseline.baselineDirection() + " "+ c1.confirmationLong() +  c2.confirmationLong());
   //openSignal = volumeIndicator.isAbleOpenPosition() && (baseline.baselineDirection(0) > 0.0) && c1.signalLong() && c2.signalLong();
   
   return Signal;
}



bool NExpert::checkShortConditions(void)
{
   bool Signal = false;
   
   if(volumeIndicator.confirmationShort()){
   
         /*TODO: baselineDirection() => confirmationShort()*/
      if(baseline.baselineDirection() < 0.0){
         if(c1.confirmationShort() && c2.confirmationShort()){
            Signal = true;
         }
      }
   }

   //Print("In short: " + volumeIndicator.confirmationShort() +" " + baseline.baselineDirection() + " "+ c1.confirmationShort() +  c2.confirmationShort());
   //openSignal = volumeIndicator.isAbleOpenPosition() && (baseline.baselineDirection(0) < 0.0) && c1.signalShort() && c2.signalShort();
   
   return Signal;
}


void NExpert::Refresh()
{
   baseline.Refresh();
   c1.Refresh();
   c2.Refresh();
   volumeIndicator.Refresh();
   exitIndicator.Refresh();
   money.Refresh();
   

   
   /*Maybe In NiMoney class*/
   int i = 0;
   bool flag = false;
   while(i< OrdersTotal() && !flag)
   {
      OrderSelect(i,SELECT_BY_POS);
      if(OrderMagicNumber() == magic)
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