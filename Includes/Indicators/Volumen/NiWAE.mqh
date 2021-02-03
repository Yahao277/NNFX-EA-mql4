//+------------------------------------------------------------------+
//|                                                        NiWAE.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

#include <NNFX\Indicators\Interfaces.mqh>

/* Volume/Volatility indicator*/
class NiWAE : public IVolume
{
private:
   
   double   ExplosionLine;
   double   ExplosionLine_prev;
   double   BullTrendLine;
   double   BullTrendLine_prev;
   double   BearTrendLine;
   double   BearTrendLine_prev;
   
   int      BullTrend_index;
   int      BearTrend_index;
   int      Explosion_index;
   
   int      InpSensetive;
   int      InpDeadZonePip;
   int      InpExplosionPower;
   int      InpTrendPower;
   
   string   m_name;
   string   m_symbol;
   int      m_tf;  
      
public:
               NiWAE();
               NiWAE(int Sensetive,int DeadZonePip,int  ExplosionPower,int  TrendPower);
              ~NiWAE(){}
           
   void        InitIndicator(string symbol,int timeframe);
   void        Refresh(); 
   void        Refresh(int shift);
    
   //--- Condition rules   
   bool        confirmationLong();
   bool        confirmationShort();
   //bool        confirmationOpenPosition();
   void        showVars();
               

};

NiWAE::NiWAE()
{
   m_name = "NNFX\\Volumen\\WAE.ex4";

   BullTrend_index = 0;
   BearTrend_index = 1;
   Explosion_index = 2;
   
   //--- default parameters
   InpSensetive = 150;
   InpDeadZonePip = 30;
   InpExplosionPower = 15;
   InpTrendPower = 15;

}

NiWAE::NiWAE(int Sensetive,int DeadZonePip,int ExplosionPower,int TrendPower)
{
   m_name = "NNFX\\Volumen\\WAE.ex4";

   BullTrend_index = 0;
   BearTrend_index = 1;
   Explosion_index = 2;
   
   InpSensetive = Sensetive;
   InpDeadZonePip = DeadZonePip;
   InpExplosionPower = ExplosionPower;
   InpTrendPower = TrendPower;
}

void NiWAE::InitIndicator(string symbol,int timeframe)
{
   m_symbol = symbol;
   m_tf = timeframe;
}


void NiWAE::Refresh()
{
   ExplosionLine = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,Explosion_index,1);
   //ExplosionLine_prev = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,Explosion_index,2);
   BullTrendLine = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,BullTrend_index,1);
   //BullTrendLine_prev = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,BullTrend_index,2);
   BearTrendLine = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,BearTrend_index,1);
   //BearTrendLine_prev = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,BearTrend_index,2);
}

void NiWAE::Refresh(int shift)
{
   ExplosionLine = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,Explosion_index,shift);

   BullTrendLine = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,BullTrend_index,shift);

   BearTrendLine = iCustom(m_symbol,m_tf,m_name,InpSensetive,InpDeadZonePip,InpExplosionPower,InpTrendPower,BearTrend_index,shift);

}

void NiWAE::showVars(void)
{
   Print(BullTrendLine + " " + ExplosionLine + " " + BearTrendLine);
}

bool NiWAE::confirmationLong(void)
{
   bool signal = false;

   if(BullTrendLine > ExplosionLine)
   {
      signal = true;
   }
   
   return signal;
}

bool NiWAE::confirmationShort(void)
{
   bool signal = false;

   if(BearTrendLine > ExplosionLine)
   {
      signal = true;
   }
   
   return signal;
}