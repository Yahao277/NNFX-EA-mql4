//+------------------------------------------------------------------+
//|                                                        NiRex.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\Indicators\Interfaces.mqh>

/*Exit indicator*/
class NiRex : public IExit
{
private:
   double   m_rex;
   double   m_rex_prev;
   double   m_signal;
   double   m_signal_prev;
   
   int      rex_index;
   int      signal_index;
   
   int      InpRexLength;
   int      InpRexMethod;
   int      InpSignalLength;
   int      InpSignalMethod;
   
   string   m_name;
   string   m_symbol;
   int      m_tf;
public:

               NiRex();
               NiRex(int smoothing_length,int smoothing_method,int signal_length,int signal_method);
              ~NiRex(){}
   void        InitIndicator(string symbol, const int timeframe);
   void        Refresh();
   void        Refresh(int shift);
   
   //--- Condition rules
   bool        exitLong();
   bool        exitShort(); 
   /*          
   bool        entryLong();
   bool        entryShort();
   double      baselineDirection();
   bool        confirmationLong();
   bool        confirmationShort();
   */
};

NiRex::NiRex()
{
   m_name = "NNFX\\Exit\\Rex.ex4";
   
   rex_index = 0;
   signal_index = 1;
   
   /*Default parameters*/
   InpRexLength = 14;
   InpRexMethod = 0;
   InpSignalLength = 14;
   InpSignalMethod = 0;
}

NiRex::NiRex(int smoothing_length,
                          int smoothing_method,
                          int signal_length,
                          int signal_method)
{
   m_name = "NNFX\\Exit\\Rex.ex4";
   
   
   rex_index = 0;
   signal_index = 1;
   
   InpRexLength = smoothing_length;
   InpRexMethod = smoothing_method;
   InpSignalLength = signal_length;
   InpSignalMethod = signal_method;
}

void NiRex::InitIndicator(const string symbol,const int timeframe)
{
   m_symbol = symbol;
   m_tf = timeframe; 
}


void NiRex::Refresh(void)
{
   m_rex = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,rex_index,1);
   m_rex_prev = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,rex_index,2);
   
   m_signal = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,signal_index,1);
   m_signal_prev = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,signal_index,2);
   
   RefreshRates();
}

void NiRex::Refresh(int shift)
{
   m_rex = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,rex_index,shift);
   m_rex_prev = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,rex_index,shift + 1);
   
   m_signal = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,signal_index,shift);
   m_signal_prev = iCustom(m_symbol,m_tf,m_name,InpRexLength,InpRexMethod,InpSignalLength,InpSignalMethod,signal_index,shift +1);
   
   RefreshRates();
}

bool NiRex::exitLong(void)
{  
   bool signal = false;
   
   if(m_rex_prev > m_signal_prev && m_rex < m_signal)
   {
      signal = true;
   }
   
   return signal;
}

bool NiRex::exitShort(void)
{
   bool signal = false;
   
   if(m_rex_prev < m_signal_prev && m_rex > m_signal)
   {
      signal = true;
   }
   
   return signal;
}
