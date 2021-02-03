//+------------------------------------------------------------------+
//|                                                      NiMoney.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\Indicators\interfaces.mqh>

class NiMoney : public IMoney
{
private:

   double   m_lots;
   double   m_tp_beta;
   double   m_sl_alpha;
   int      m_magic;
   int      m_dev;
   int      atr_period;
   
   bool     long_trade;
   bool     short_trade;
   int      ticket;
public:
            NiMoney(){}
            NiMoney(double lots,double SLalpha,double TPbeta,int magic, int deviation);
            ~NiMoney(){}
   void     Refresh(void);                         
   
   void     setLots(double lots)                   { m_lots=lots; }
   void     setTakeProfit(double tp)                  { m_tp_beta = tp;}
   void     setStopLoss(double sl)                    { m_sl_alpha = sl;}
   
   void     OpenLong();
   void     OpenShort();
   void     CloseLongPosition();
   void     CloseShortPosition();
   
   bool     isShortPosition()  { return short_trade;}
   bool     isLongPosition()   {return long_trade;}
   bool     isOpenedPosition() {return short_trade || long_trade;}
   void     InitTSParams();

};


NiMoney::NiMoney(double lots,double SLalpha,double TPbeta,int magic, int deviation)
{
   m_lots = lots;
   m_tp_beta = TPbeta;
   m_sl_alpha = SLalpha;
   m_magic = magic;
   m_dev = deviation;
   long_trade = false;
   short_trade = false;
   atr_period = 14;
   
   ticket = -1; // initial state
}

void NiMoney::InitTSParams(void)
{
   long_trade = false;
   short_trade = false;
   
   ticket = -1;
}

void NiMoney::Refresh(void)
{
   RefreshRates();
   //Print("ticket " + ticket);
      
   if(ticket > 0){

      bool selected = OrderSelect(ticket,SELECT_BY_TICKET);
      //Print("Ticket selected: " + selected);
      
      
      if(OrderCloseTime() > 0) /*order closed, so the entire trade is closed*/
      {
         ticket = -1;
   
      }  
   }
   


}

void NiMoney::OpenLong(void)
{  
   double m_atr = iATR(_Symbol,_Period,atr_period,1);
   ticket = OrderSend(_Symbol,OP_BUY,m_lots,Ask,m_dev,0,0,NULL,m_magic,0,clrGreen);
   
   if(ticket > 0)
   {
      bool selected = OrderSelect(ticket,SELECT_BY_TICKET);
      double OpenPrice = OrderOpenPrice();
      
      double tp = NormalizeDouble( OpenPrice +(m_tp_beta *m_atr),_Digits);
      double sl = NormalizeDouble( OpenPrice - (m_sl_alpha * m_atr),_Digits);
      
      bool ticketMod = OrderModify(ticket,OrderOpenPrice(),sl,tp,0);
   }else{
      Print(GetLastError());
   }
   
   
}

void NiMoney::OpenShort(void)
{
   double m_atr = iATR(_Symbol,_Period,atr_period,1);
   ticket = OrderSend(_Symbol,OP_SELL,m_lots,Bid,m_dev,0,0,NULL,m_magic,0,clrRed);
   
   if(ticket > 0)
   {
      bool selected = OrderSelect(ticket,SELECT_BY_TICKET);
      double OpenPrice = OrderOpenPrice();
      
      double tp = NormalizeDouble( OpenPrice - (m_tp_beta * m_atr),_Digits);
      double sl = NormalizeDouble( OpenPrice + (m_sl_alpha * m_atr),_Digits);
      
      bool ticketMod = OrderModify(ticket,OrderOpenPrice(),sl,tp,0);
   }else{
      Print(GetLastError());
   }
}

void NiMoney::CloseLongPosition(void)
{
   if(ticket > 0){
      bool selected = OrderSelect(ticket,SELECT_BY_TICKET);
      if( OrderCloseTime() == 0)
      {
         double CloseLots = OrderLots();
         
         bool closed = OrderClose(ticket,CloseLots,Bid,m_dev,clrRed);

      }
   }
   
   ticket = -1;
}  

void NiMoney::CloseShortPosition(void)
{
   if(ticket > 0){
      bool selected = OrderSelect(ticket,SELECT_BY_TICKET);
      if( OrderCloseTime() == 0)
      {
         double CloseLots = OrderLots();
         
         bool closed = OrderClose(ticket,CloseLots,Ask,m_dev,clrGreen);

      }
   }
   
   ticket = -1;   
}