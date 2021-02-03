//+------------------------------------------------------------------+
//|                                                       NRules.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\NExpert.mqh>
#include <NNFX\functions.mqh> //--- includes
#include <NNFX\Indicators\Interfaces.mqh>

struct ExpertVars
{
   IBaseline         *baseline;
   IConfirmation     *c1;
   IConfirmation     *c2;
   bool              LongSignal;
   bool              ShortSignal;
};

/*
   Note:
   SevenCandle, Pullback -> if apply = false then return true;
   
   Continuation_rule -> if apply = false then return false;
*/


interface IRules
{
public:
   virtual bool checkConditionsForLong(ExpertVars &vars);
   virtual bool checkConditionsForShort(ExpertVars &vars);
};

/*
* class for PullbackRule ====================================================================
*/

class PullbackRule: public IRules
{
private:
   double atr_value;
   bool   apply;
public:
   PullbackRule(bool apply){
      atr_value = iATR(_Symbol,_Period,14,0);
      this.apply = apply;
   }
   ~PullbackRule(){}
   
   bool checkConditionsForLong(ExpertVars &vars);
   bool checkConditionsForShort(ExpertVars &vars);   
};

bool PullbackRule::checkConditionsForLong(ExpertVars &vars)
{
   if(!apply) {
      return true;
   }
   
   bool signal = false;
   this.atr_value = iATR(_Symbol,_Period,14,0);
   IBaseline* baseline = vars.baseline;

   if(baseline.baselineDirection() >= 0.0 && 
      baseline.baselineDirection() < atr_value)
      {
         signal = true;
      }
   
   return signal;
}

bool PullbackRule::checkConditionsForShort(ExpertVars &vars)
{
   if(!apply) {
      return true;
   }
   
   bool signal = false;
   atr_value = iATR(_Symbol,_Period,14,0);
   IBaseline* baseline = vars.baseline;
   
   if(baseline.baselineDirection() <= 0.0 && 
      baseline.baselineDirection() > -1* atr_value)
      {
         signal = true;
      } 
   
   return signal;
}

/*
 * class for SevenCandleRule ====================================================================
*/
class SevenCandleRule : public IRules
{
private:
   EnterTime forLong;
   EnterTime forShort;
   bool      apply;

public:
   SevenCandleRule(bool apply){
      //Initialize time
      this.forLong.c1EnteredTime = 0;
      this.forLong.c2EnteredTime = 0;
      this.forShort.c1EnteredTime = 0;
      this.forShort.c2EnteredTime = 0;
      
      this.apply = apply;
      
   }
   ~SevenCandleRule(){}
   
   bool checkConditionsForLong(ExpertVars &vars);
   bool checkConditionsForShort(ExpertVars &vars);
};

bool SevenCandleRule::checkConditionsForLong(ExpertVars &vars)
{
   if(!apply) {
      return true;
   }
   
   bool signal = false;
   IConfirmation *c1 = vars.c1;
   IConfirmation *c2 = vars.c2;
   
   if(c1.entryLong()) this.forLong.c1EnteredTime = Time[1];
   if(c2.entryLong()) this.forLong.c2EnteredTime = Time[1];
   
   if(this.forLong.c1EnteredTime > Time[7] && this.forLong.c2EnteredTime > Time[7]) signal = true;
   
   return signal;
}

bool SevenCandleRule::checkConditionsForShort(ExpertVars &vars)
{
   if(!apply) {
      return true;
   }
   
   bool signal = false;
   IConfirmation *c1 = vars.c1;
   IConfirmation *c2 = vars.c2;
   
   if(c1.entryShort()) forShort.c1EnteredTime = Time[1];
   if(c2.entryShort()) forShort.c2EnteredTime = Time[1];
   
   if(forShort.c1EnteredTime > Time[7] && forShort.c2EnteredTime > Time[7]) signal = true;
   
   return signal;
}

/*
 * class for Continuation trades ====================================================================
 */
class ContinuationRule : public IRules
{
private:
   TrendStatus trend;
   bool        apply;
   bool        checkContinuationConditionsForLong(ExpertVars &vars);
   bool        checkContinuationConditionsForShort(ExpertVars &vars);
   
public:
   ContinuationRule(bool apply){
      trend.EnteredInLong = 0;
      trend.EnteredInShort = 0;
      this.apply = apply;
   }
   ~ContinuationRule(){}
   
   bool checkConditionsForLong(ExpertVars &vars);
   bool checkConditionsForShort(ExpertVars &vars);      
};

bool ContinuationRule::checkConditionsForLong(ExpertVars &vars)
{
   if(!apply) {
      return false;
   }
   
   bool signal = false;
   IBaseline* baseline = vars.baseline;
   
   if(baseline.entryLong()) trend.EnteredInLong = Time[1];
   
   if(trend.EnteredInLong > trend.EnteredInShort &&
      trend.EnteredInLong > Time[7])
   {
      signal = checkContinuationConditionsForLong(vars);
   }   
   
   return signal;
}

bool ContinuationRule::checkConditionsForShort(ExpertVars &vars)
{
   if(!apply) {
      return false;
   }
   
   bool signal = false;
   IBaseline* baseline = vars.baseline;
   
   if(baseline.entryShort()) trend.EnteredInShort = Time[1];
   
   if(trend.EnteredInShort > trend.EnteredInLong &&
      trend.EnteredInShort > Time[7])
   {
      signal = checkContinuationConditionsForShort(vars);
   }
   
   return signal;
}

bool ContinuationRule::checkContinuationConditionsForLong(ExpertVars &vars)
{
   return vars.baseline.baselineDirection() > 0.0 && vars.c1.confirmationLong() && vars.c2.confirmationLong();
}

bool ContinuationRule::checkContinuationConditionsForShort(ExpertVars &vars)
{

   return vars.baseline.baselineDirection() < 0.0 && vars.c1.confirmationShort() && vars.c2.confirmationShort();
}


/*
 * class for OneCandle Rule
 */
 
class OneCandleRule
{
private:
   bool        oneCandle_forLong;
   bool        oneCandle_forShort;
   bool        apply;
   
public:
   OneCandleRule(bool apply){
   oneCandle_forLong = false;
   oneCandle_forShort = false;
   this.apply = apply;
   }
   ~OneCandleRule(){}
   
   bool checkConditionsForLong(ExpertVars &vars);
   bool checkConditionsForShort(ExpertVars &vars);
   bool isLong(){ return oneCandle_forLong;}
   bool isShort(){ return oneCandle_forShort;}
};


bool OneCandleRule::checkConditionsForLong(ExpertVars &vars)
{
   if(!apply) {
      return false;
   }
   
   if(!vars.LongSignal && !oneCandle_forLong){
      oneCandle_forLong = true;
   }else if(oneCandle_forLong){
      oneCandle_forLong = false;
   } 
   
   return true; //unused signal
}

bool OneCandleRule::checkConditionsForShort(ExpertVars &vars)
{
   if(!apply) {
      return false;
   }
   
   if(!vars.ShortSignal && !oneCandle_forShort){
      oneCandle_forShort = true;
   }else if(oneCandle_forLong){
      oneCandle_forShort = false;
   }    
   
   return true; //unused signal
}