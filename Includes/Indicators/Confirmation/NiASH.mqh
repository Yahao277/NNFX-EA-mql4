//+------------------------------------------------------------------+
//|                                                        NiASH.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\Indicators\Interfaces.mqh>

class NiASH : public IConfirmation
{
private:

   double   m_as; // absolute strength line
   double   m_as_prev;
   double   m_signal;
   double   m_signal_prev;
   
   int      as_index;
   int      signal_index;
   
   string   InpModeStr;
   int      InpMode;
   int      InpLength;
   int      InpSmoothLength;
   int      InpPrice;
   int      InpMethod;
   
   string   m_name;
   string   m_symbol;
   int      m_tf;   
public:
               NiASH();
               NiASH(string ModeStr,
                          int Mode,
                          int Length,
                          int SmoothLength,
                          int Price,
                          int Method);
              ~NiASH(){}
   void        InitIndicator(string symbol,int timeframe);
   void        Refresh();
   void        Refresh(int shift);
   
   //--- Condition rules           
   bool        entryLong();
   bool        entryShort();
   //double      baselineDirection();
   bool        confirmationLong();
   bool        confirmationShort();
   
};

NiASH::NiASH()
{
   m_name = "NNFX\\Confirmation\\ASH.ex4";
   
   as_index = 0;
   signal_index = 1;

   //--- default parameters
   InpModeStr = "Mode: 0 - RSI, 1 - Stoch";
   InpMode = 0;
   InpLength = 9;
   InpSmoothLength = 2;
   InpPrice = 0;
   InpMethod = 0;
}

NiASH::NiASH(string ModeStr,
                          int Mode,
                          int Length,
                          int SmoothLength,
                          int Price,
                          int Method)
{
   m_name = "NNFX\\Confirmation\\ASH.ex4";
   
   as_index = 0;
   signal_index = 1;
   
   InpModeStr = ModeStr;
   InpMode = Mode;
   InpLength = Length;
   InpSmoothLength = SmoothLength;
   InpPrice = Price;
   InpMethod = Method;
}

void NiASH::InitIndicator(string symbol,int timeframe)
{
   m_symbol = symbol;
   m_tf = timeframe;
}

void NiASH::Refresh()
{
    m_as = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,as_index,1);
    m_as_prev = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,as_index,2);
    
    m_signal = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,signal_index,1);
    m_signal_prev = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,signal_index,2);
    
}

void NiASH::Refresh(int shift)
{
    m_as = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,as_index,shift);
    m_as_prev = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,as_index,shift + 1);
    
    m_signal = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,signal_index,shift);
    m_signal_prev = iCustom(m_symbol,m_tf,m_name,InpModeStr,InpMode,InpLength,InpSmoothLength,InpPrice,InpMethod,signal_index,shift + 1);
}

bool NiASH::entryLong()
{
   bool signal = false;

   if(m_as > m_signal && m_as_prev < m_signal_prev)
   {
      signal = true;
   }
   
   return signal;
}

bool NiASH::entryShort()
{
   bool signal = false;

   if(m_as < m_signal && m_as_prev > m_signal_prev)
   {
      signal = true;
   }
   
   return signal;
}

bool NiASH::confirmationLong()
{
   bool signal = false;

   if(m_as > m_signal)
   {
      signal = true;
   }
   
   return signal;
}

bool NiASH::confirmationShort()
{
   bool signal = false;

   if(m_as < m_signal)
   {
      signal = true;
   }
   
   return signal;
}