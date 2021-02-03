//+------------------------------------------------------------------+
//|                                               NiSSLActivator.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\Indicators\Interfaces.mqh>

class NiSSLActivator : public IConfirmation
{
private:
   double m_ssl;
   double m_ssl_prev;
   
   double m_direction;
   double m_direction_prev;
   
   // line position of the indicator's buffer
   int   ssl_index; 
   int   direction_index;
   
   string m_name;
   string m_symbol;
   int    m_tf;
   
   int    m_periods;
   ENUM_MA_METHOD m_method;
   
public:
               NiSSLActivator();
               NiSSLActivator(int periods,ENUM_MA_METHOD method);
              ~NiSSLActivator(){}
   void        InitIndicator(string symbol,int timeframe);
   void        Refresh();
   void        Refresh(int shift);
   
   //--- Condition rules           
   bool        entryLong();
   bool        entryShort();
   double      baselineDirection();
   bool        confirmationLong();
   bool        confirmationShort();
   
};
NiSSLActivator::NiSSLActivator()
{
   m_name = "Sinergia\\SSLActivator.ex4";
      
   //--- initialize variables
   ssl_index = 0;
   direction_index = 3;
   
   m_ssl_prev = 0.0;
   m_ssl = 0.0;
   m_direction_prev = 0.0;
   m_direction = 0.0;
   
   //--- default parameters
   m_periods = 14;
   m_method = MODE_SMA;
}

NiSSLActivator::NiSSLActivator(int periods,ENUM_MA_METHOD method)
{
   m_name = "Sinergia\\SSLActivator.ex4";
   
   m_periods = periods;
   m_method = method;
   
   //--- initialize variables
   ssl_index = 0;
   direction_index = 3;
   
   m_ssl_prev = 0.0;
   m_ssl = 0.0;
   m_direction_prev = 0.0;
   m_direction = 0.0;
}


void NiSSLActivator::InitIndicator(string symbol,int timeframe)
{
   m_symbol =symbol;
   m_tf = timeframe; 
}


void NiSSLActivator::Refresh()
{

   m_ssl_prev = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,ssl_index,2);
   m_ssl = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,ssl_index,1);
   
   m_direction_prev = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,direction_index,2);
   m_direction = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,direction_index,1);

   //Print("direction: " + m_direction + ", prev direction: " +m_direction_prev);
   //Print("ssl: " + m_ssl+ ", prev ssl: " +m_ssl_prev);
}

void NiSSLActivator::Refresh(int shift)
{
   m_ssl_prev = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,ssl_index,shift+1);
   m_ssl = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,ssl_index,shift);
   
   m_direction_prev = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,direction_index,shift + 1);
   m_direction = iCustom(m_symbol,m_tf,m_name,m_periods,m_method,direction_index,shift);
}

bool NiSSLActivator::entryLong(void)
{  
   bool signal = false;

   if(m_direction == 1 && m_direction_prev == 0)
   {
      signal = true;
   }
   
   return signal;
}

bool NiSSLActivator::entryShort(void)
{
   bool signal = false;
   
   if(m_direction == 0 && m_direction_prev == 1)
   {
      signal = true;
   }

   return signal;
}

double NiSSLActivator::baselineDirection(void)
{
   double diff = NormalizeDouble(Close[1] - m_ssl,_Digits);
   return diff;
}

bool NiSSLActivator::confirmationLong(void)
{
   bool signal = false;
   
   if(m_direction == 1){
      signal = true;
   }
   
   return signal;
}

bool NiSSLActivator::confirmationShort(void)
{
   bool signal = false;
   
   if(m_direction == 0){
      signal = true;
   }
   
   return signal;
}