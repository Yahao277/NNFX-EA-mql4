
//+------------------------------------------------------------------+
//|                                                          SSL.mq4 |
//|                                                          Kalenzo |
//|                                      bartlomiej.gorski@gmail.com |
//+------------------------------------------------------------------+
#property copyright "Kalenzo"
#property link      "bartlomiej.gorski@gmail.com"
//----
#property indicator_buffers 1
#property indicator_color1 Blue
extern int Lb=10;
double ssl[],Hld,Hlv;
#property indicator_chart_window
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexBuffer(0,ssl);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,2);
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
//----
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
//----
   for(int i=Bars-Lb;i>=0;i--)
     {
      if(Close[i]>iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1))
         Hld=1;
      else
        {
         if(Close[i]<iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW,i+1))
            Hld=-1;
         else
            Hld=0;
        }
      if(Hld!=0)
         Hlv=Hld;
      if(Hlv==-1)
         ssl[i]=iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_HIGH,i+1);
      else
         ssl[i]=iMA(Symbol(),0,Lb,0,MODE_SMA,PRICE_LOW,i+1);
     }
//----
   return(0);
  }
//+------------------------------------------------------------------+