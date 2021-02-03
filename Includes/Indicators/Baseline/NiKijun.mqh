//+------------------------------------------------------------------+
//|                                                      NiKijun.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\Indicators\Interfaces.mqh>

class NiKijun : public IBaseline
{
private:
   double   m_kijun;
   double   m_kijun_prev;
   int      kijun_index;
   
   string   m_name;
   int      m_periods;
   
   string   m_symbol;
   int      m_tf;
public:

               NiKijun();
               NiKijun(int periods);
              ~NiKijun(){}
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

NiKijun::NiKijun()
{
   m_name = "NNFX\\Baseline\\KijunSen.ex4";
   
   kijun_index = 1;
   
   //--- default parameters
   m_periods = 26;
}

NiKijun::NiKijun(int periods)
{
   m_name = "NNFX\\Baseline\\KijunSen.ex4";
   
   kijun_index = 1;
   
   m_periods = periods;
}


void NiKijun::Refresh(void)
{
   m_kijun = iCustom(m_symbol,m_tf,m_name,m_periods,kijun_index,1);
   m_kijun_prev = iCustom(m_symbol,m_tf,m_name,m_periods,kijun_index,2);
   RefreshRates();
   
}

void NiKijun::Refresh(int shift)
{
   m_kijun = iCustom(m_symbol,m_tf,m_name,m_periods,kijun_index,shift);
   m_kijun_prev = iCustom(m_symbol,m_tf,m_name,m_periods,kijun_index,shift + 1);
   RefreshRates();
}

bool NiKijun::entryLong(void)
{  
   bool signal = false;
   
   double ClosePrice = iClose(m_symbol,m_tf,1);
   double ClosePrice_prev = iClose(m_symbol,m_tf,2);
   
   if(m_kijun < ClosePrice && m_kijun > ClosePrice_prev)
   {
      //Print("Baseline entry long");
      signal = true;
   }
   return signal;
}

bool NiKijun::entryShort(void)
{
   bool signal = false;
   
   double ClosePrice = iClose(m_symbol,m_tf,1);
   double ClosePrice_prev = iClose(m_symbol,m_tf,2);
   

   if(m_kijun > ClosePrice && m_kijun < ClosePrice_prev)
   {
      signal = true;
   }
   return signal;
}

double NiKijun::baselineDirection(void)
{
   double diff = NormalizeDouble(iClose(m_symbol,m_tf,1) - m_kijun,_Digits);
   
   return diff;
}

bool NiKijun::confirmationLong(void)
{
   bool signal = false;
   
   double ClosePrice = iClose(m_symbol,m_tf,1);
   
   if(m_kijun < ClosePrice )
   {
      signal = true;
   }
   
   return signal;
}

bool NiKijun::confirmationShort(void)
{
   bool signal = false;
   
   double ClosePrice = iClose(m_symbol,m_tf,1);
   
   if(m_kijun > ClosePrice)
   {
      signal = true;
   }
      
   return signal;
}