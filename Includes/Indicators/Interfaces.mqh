//+------------------------------------------------------------------+
//|                                                   Interfaces.mqh |
//|                        Copyright 2020, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2020, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

interface IBaseline
{
   void Refresh();
   void Refresh(int shift);
   void InitIndicator(string symbol,int timeframe);
   
   double baselineDirection();
   bool entryLong();
   bool entryShort();
   bool confirmationLong();
   bool confirmationShort();
};

interface IConfirmation
{
   void Refresh();
   void Refresh(int shift);
   void InitIndicator(string symbol,int timeframe);
   
   bool entryLong();
   bool entryShort();
   bool confirmationLong();
   bool confirmationShort();
};

interface IExit
{
   void Refresh();
   void Refresh(int shift);
   void InitIndicator(string symbol,int timeframe);
   
   bool exitLong();
   bool exitShort();
};

interface IVolume
{
   void Refresh();
   void Refresh(int shift);
   void InitIndicator(string symbol,int timeframe);
   
   bool confirmationLong();
   bool confirmationShort();
};

interface IMoney
{
   void     Refresh();
   void     OpenLong();
   void     OpenShort();
   void     CloseLongPosition();
   void     CloseShortPosition();
   
   bool     isShortPosition();
   bool     isLongPosition();
   bool     isOpenedPosition();
   void     InitTSParams();
};