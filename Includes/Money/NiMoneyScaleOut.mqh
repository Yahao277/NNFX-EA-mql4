//+------------------------------------------------------------------+
//|                                              NiMoneyScaleOut.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\Money\NiMoney.mqh>
#include <NNFX\Indicators\interfaces.mqh>

class NiMoneyScaleOut : public IMoney
{
private:
   double   m_lots;
   int      m_magic;
   double   m_alpha;
   double   m_beta;
   int      m_dev;
   int      atr_period;
   
   double   m_atr;
   
   bool     startTrailing;
   bool     long_trade;
   bool     short_trade;
   double   ts_lowprice;
   double   ts_highprice;
   
   int      first_ticket;
   int      second_ticket;
public:
            NiMoneyScaleOut();
            NiMoneyScaleOut(double lots,int magic,int deviation);
            NiMoneyScaleOut(double lotsPercent,double SLalpha,double TPbeta,int ATRperiod,int magic,int deviation);
            ~NiMoneyScaleOut(){}
   void     Refresh(void);                         
   
   bool     isLongPosition() {return long_trade;}
   bool     isShortPosition() {return short_trade;}
   bool     isOpenedPosition() {return long_trade || short_trade;}
   
   void     OpenLong();
   void     OpenShort();
   void     CloseLongPosition();
   void     CloseShortPosition();
   
   /*Trailing stop rules*/
   void     InitTSParams();
   void     Breakeven();
   void     StartTSRules();
   void     checkTSRules();
   void     checkTSRulesForLong();
   void     checkTSRulesforShort();

};
NiMoneyScaleOut::NiMoneyScaleOut()
{
   first_ticket = -1;
   second_ticket = -1;
   long_trade = false;
   short_trade = false;
   startTrailing = false;
   ts_lowprice = 0.0;
   ts_highprice = 0.0;
}

NiMoneyScaleOut::NiMoneyScaleOut(double lots,int magic, int deviation)
{
   m_lots = lots;
   m_alpha = 1.5; // for sl
   m_beta = 1; // for tp
   m_magic = magic;
   m_dev = deviation;
   atr_period = 14;
   
   first_ticket = -1;
   second_ticket = -1;
   long_trade = false;
   short_trade = false;
   startTrailing = false;
   ts_lowprice = 0.0;
   ts_highprice = 0.0;

}

NiMoneyScaleOut::NiMoneyScaleOut(double lotsPercent,double SLalpha,double TPbeta,int ATRperiod,int magic,int deviation)
{
   m_lots = lotsPercent; //TODO: calculate percentage
   m_alpha = SLalpha; // for sl
   m_beta = TPbeta; // for tp
   atr_period = ATRperiod;
   m_magic = magic;
   m_dev = deviation;
   
   first_ticket = -1;
   second_ticket = -1;
   long_trade = false;
   short_trade = false;
   startTrailing = false;
   ts_lowprice = 0.0;
   ts_highprice = 0.0;
}

void NiMoneyScaleOut::InitTSParams()
{
         first_ticket = -1;
         second_ticket = -1;
         long_trade = false;
         short_trade = false;
         startTrailing = false;
         ts_lowprice = 0.0;
         ts_highprice = 0.0;
}

void  NiMoneyScaleOut::Refresh(void)
{
   RefreshRates();

   /*TODO: check m_magic and ticket number*/

   if(second_ticket > 0){
      OrderSelect(second_ticket,SELECT_BY_TICKET);
      
      if(OrderCloseTime() > 0) /*second order closed, so the entire trade is closed*/
      {
         /*Init parameters when close trade*/
         InitTSParams();
         
      }else{
         bool selected = OrderSelect(first_ticket,SELECT_BY_TICKET);
      
         if(OrderCloseTime()>0 && selected && !startTrailing) /*first order closed, so second order -> Breakeven */
         {
            Breakeven();
            startTrailing=true;
         }else if(OrderCloseTime()>0 && startTrailing) /* if started trailing*/
         {
               //Print("Checking TS rules...");
               //Print("ts price: "+ ts_lowprice + ", " + ts_highprice);
               checkTSRules();
         }
         
      }
   }
   
   

   
}

void NiMoneyScaleOut::OpenLong(void)
{  
   m_atr = iATR(_Symbol,_Period,atr_period,1);
   double mid_lot = NormalizeDouble(m_lots/2,2);
   first_ticket = OrderSend(_Symbol,OP_BUY,m_lots,Ask,m_dev,0,0,NULL,m_magic,0,clrGreen);
   second_ticket = OrderSend(_Symbol,OP_BUY,m_lots,Ask,m_dev,0,0,NULL,m_magic,0,clrGreen);
   
   long_trade = true;
   short_trade = false;
   
   if(first_ticket > 0 && second_ticket > 0)
   {
      /*Modify sl, tp first order:
         SL = 1 * ATR
         TP = 1.5 * ATR
      */
      bool selected_first = OrderSelect(first_ticket,SELECT_BY_TICKET);
      double OpenPrice = OrderOpenPrice();
      
      double tp = NormalizeDouble( OpenPrice +( m_atr * m_beta),_Digits);
      double sl = NormalizeDouble( OpenPrice - (NormalizeDouble(m_atr * m_alpha,_Digits)),_Digits);
      
      if(!OrderModify(first_ticket,OrderOpenPrice(),sl,tp,0))  Print(GetLastError());
      
      /*Modify sl, tp second order: 
         SL = 1 * ATR
         TP = (don't set)
      */
      bool selected_second = OrderSelect(second_ticket,SELECT_BY_TICKET);
      OpenPrice = OrderOpenPrice();
      
      tp = 0;
      sl = NormalizeDouble( OpenPrice - (NormalizeDouble(m_atr * m_alpha,_Digits)),_Digits);
      
      if(!OrderModify(second_ticket,OrderOpenPrice(),sl,tp,0)) Print(GetLastError());
   }else{
      Print(GetLastError());
   }

   
   
}

void NiMoneyScaleOut::OpenShort(void)
{
   m_atr = iATR(_Symbol,_Period,atr_period,1);
   first_ticket = OrderSend(_Symbol,OP_SELL,m_lots,Bid,m_dev,0,0,NULL,m_magic,0,clrRed);
   second_ticket = OrderSend(_Symbol,OP_SELL,m_lots,Bid,m_dev,0,0,NULL,m_magic,0,clrRed);
   
   long_trade = false;
   short_trade = true;
   
   if(first_ticket > 0 && second_ticket > 0)
   {
      /*Modify sl, tp first order:
         SL = (m_alpha) 1 * ATR
         TP = (m_beta) 1.5 * ATR
      */
      bool selected = OrderSelect(first_ticket,SELECT_BY_TICKET);
      double OpenPrice = OrderOpenPrice();
      
      double tp = NormalizeDouble( OpenPrice - ( m_atr * m_beta),_Digits);
      double sl = NormalizeDouble( OpenPrice + NormalizeDouble(m_atr * m_alpha,_Digits),_Digits);
      
      if(!OrderModify(first_ticket,OrderOpenPrice(),sl,tp,0))  Print(GetLastError());
      
      /*Modify sl, tp second order: 
         SL = 1 * ATR
         TP = (don't set)
      */
      selected = OrderSelect(second_ticket,SELECT_BY_TICKET);
      OpenPrice = OrderOpenPrice();
      
      tp = 0;
      sl = NormalizeDouble( OpenPrice + NormalizeDouble(m_atr * m_alpha,_Digits),_Digits);
      
      if(!OrderModify(second_ticket,OrderOpenPrice(),sl,tp,0)) Print(GetLastError());
   }else{
      Print(GetLastError());
   }
}

void NiMoneyScaleOut::CloseLongPosition(void)
{
   if(second_ticket > 0){
      bool selected = OrderSelect(second_ticket,SELECT_BY_TICKET);
      if( OrderCloseTime() == 0)
      {
         double CloseLots = OrderLots();
         
         bool closed = OrderClose(second_ticket,CloseLots,Bid,m_dev,clrRed);

      }
   }
   
   InitTSParams();
}  

void NiMoneyScaleOut::CloseShortPosition(void)
{
   if(second_ticket > 0){
      bool selected = OrderSelect(second_ticket,SELECT_BY_TICKET);
      if( OrderCloseTime() == 0)
      {
         double CloseLots = OrderLots();
         
         bool closed = OrderClose(second_ticket,CloseLots,Ask,m_dev,clrGreen);

      }
   }
   InitTSParams();
}

void NiMoneyScaleOut::Breakeven()
{
   bool selected = OrderSelect(second_ticket,SELECT_BY_TICKET);
   double OpenPrice = OrderOpenPrice();
   double spread = NormalizeDouble(MathAbs(Bid - Ask),_Digits);
   
   if(OrderType() == OP_BUY || long_trade)
   {
      Print("Breakeven Long...");
      if(!OrderModify(second_ticket,OrderOpenPrice(),OpenPrice + spread,0,0))      Print(GetLastError());
      ts_lowprice = Close[0];
      ts_highprice = Close[0];
   }
   
   if(OrderType() == OP_SELL || short_trade)
   {
      Print("Breakeven Short...");
      if(!OrderModify(second_ticket,OrderOpenPrice(),OpenPrice - spread,0,0))      Print(GetLastError());
      ts_lowprice = Close[0];
      ts_highprice = Close[0];
   }
   
   /* TO DELETE
      //In short 
   if(Close[0] < OpenPrice - 2 * m_atr)
   {
      ts_lowprice = Close[0];
   }
   
   //In Long
   if(Close[0] > OpenPrice + 2 * m_atr)
   {
      ts_highprice = Close[0];
   }
   */
   
   //Print("ts price: "+ ts_lowprice + ", " + ts_highprice);
   
}


void NiMoneyScaleOut::checkTSRules()
{
   if(long_trade)
   {
      checkTSRulesForLong();
   }else if(short_trade)
   {
      checkTSRulesforShort();
   } 
}

void NiMoneyScaleOut::checkTSRulesForLong()
{
   
   if(!OrderSelect(second_ticket,SELECT_BY_TICKET))   Print("Error OrderSelect: " + GetLastError());
   double OpenPrice = OrderOpenPrice();
   
   /*In Long*/
   if(startTrailing && Close[0] > ts_highprice && Close[0] > OpenPrice + 2 * m_atr)
   {
      ts_highprice = Close[0];
      double  sl = ts_highprice - NormalizeDouble(1.5 * m_atr,_Digits);
      Print("Trailing stop...");
      if(!OrderModify(second_ticket,OrderOpenPrice(),sl,0,0))
      {
         Print(GetLastError());
      }
   }
}
void NiMoneyScaleOut::checkTSRulesforShort()
{
   if(!OrderSelect(second_ticket,SELECT_BY_TICKET)) Print("Error OrderSelect : " + GetLastError());
   double OpenPrice = OrderOpenPrice();
   /*In Short*/
   if(startTrailing && Close[0] < ts_lowprice && Close[0] < OpenPrice - 2 * m_atr)
   {
      ts_lowprice = Close[0];
      double  sl = ts_lowprice + NormalizeDouble(1.5 * m_atr,_Digits);
      Print("Trailing stop...");
      if(!OrderModify(second_ticket,OrderOpenPrice(),sl,0,0))
      {
         Print(GetLastError());
      }
   }
}

// NOT USED
void NiMoneyScaleOut::StartTSRules()
{
   bool   startTrailing = false;
   double low_price,high_price;
   
   bool selected = OrderSelect(second_ticket,SELECT_BY_TICKET);
   double OpenPrice = OrderOpenPrice();
   
   /*In short*/   
   if(Close[0] < OpenPrice - 2 * m_atr)
   {
      startTrailing = true;
      low_price = Close[0];
   }
   
   /*In Long*/
   if(Close[0] > OpenPrice + 2 * m_atr)
   {
      startTrailing = true;
      high_price = Close[0];
   }
}