//+------------------------------------------------------------------+
//|                                                         NiMA.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict


#include <NNFX\Indicators\Interfaces.mqh>

class NiMA : public IBaseline
{
private:
   double   m_ma;
   double   m_ma_prev;
   
   string   m_name;
   int      m_periods;
   int      m_ma_shift;
   ENUM_MA_METHOD       m_ma_method;
   ENUM_APPLIED_PRICE   m_applied_price;
   
   string   m_symbol;
   int      m_tf;
public:
               NiMA();
               NiMA(int periods,int ma_shift,ENUM_MA_METHOD ma_method,ENUM_APPLIED_PRICE applied_price);
              ~NiMA(){}
   void        InitIndicator(string symbol,int timeframe)       {   m_symbol =symbol; m_tf = timeframe; }
   void        Refresh();
   void        Refresh(int shift);
   
   //--- Condition rules           
   bool        entryLong();
   bool        entryShort();
   double      baselineDirection();
   bool        confirmationLong();
   bool        confirmationShort();
};

NiMA::NiMA()
{
   m_name = "Moving average";
   
   //--- default parameters
   m_periods = 14;
   m_ma_shift = 0;
   m_ma_method = MODE_SMA;
   m_applied_price = PRICE_CLOSE;
}

NiMA::NiMA(int periods,int ma_shift,ENUM_MA_METHOD ma_method,ENUM_APPLIED_PRICE applied_price)
{
   m_name = "Moving average";
   
   m_periods = periods;
   m_ma_shift = ma_shift;
   m_ma_method = ma_method;
   m_applied_price = applied_price;
}


void NiMA::Refresh(void)
{
   m_ma = iMA(m_symbol,m_tf,m_periods,m_ma_shift,m_ma_method,m_applied_price,1);
   m_ma_prev = iMA(m_symbol,m_tf,m_periods,m_ma_shift,m_ma_method,m_applied_price,2);
   RefreshRates();
   
}

void NiMA::Refresh(int shift)
{
   m_ma = iMA(m_symbol,m_tf,m_periods,m_ma_shift,m_ma_method,m_applied_price,shift);
   m_ma_prev = iMA(m_symbol,m_tf,m_periods,m_ma_shift,m_ma_method,m_applied_price,shift+1);
   RefreshRates();
}

bool NiMA::entryLong()
{
   bool signal = false;
   
   double ClosePrice = iClose(m_symbol,m_tf,1);
   double ClosePrice_prev = iClose(m_symbol,m_tf,2);
   
   if(m_ma < ClosePrice && m_ma > ClosePrice_prev)
   {
      signal = true;
   }
   return signal;
}
bool NiMA::entryShort()
{
   bool signal = false;
   
   double ClosePrice = iClose(m_symbol,m_tf,1);
   double ClosePrice_prev = iClose(m_symbol,m_tf,2);
   

   if(m_ma > ClosePrice && m_ma < ClosePrice_prev)
   {
      signal = true;
   }
   return signal;
}
double NiMA::baselineDirection()
{
   double diff = NormalizeDouble(iClose(m_symbol,m_tf,1) - m_ma,_Digits);
   
   return diff;
}
bool NiMA::confirmationLong()
{  
   double ClosePrice = iClose(m_symbol,m_tf,1);
   return m_ma > ClosePrice;
}
bool NiMA::confirmationShort()
{   
   double ClosePrice = iClose(m_symbol,m_tf,1);
   return m_ma < ClosePrice;
}
