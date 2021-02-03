//+------------------------------------------------------------------+
//|                                                    functions.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict



struct OrderState
{
   bool LongPosition;
   bool ShortPosition;
   bool OrderStatus; // true: have open position / false: no open position
};

//--- For seven candle rule
struct EnterTime
{
   datetime c1EnteredTime;
   datetime c2EnteredTime;
};

//--- For Continuation trade rule
struct TrendStatus
{
   datetime EnteredInLong;
   datetime EnteredInShort;
};