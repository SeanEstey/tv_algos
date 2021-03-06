//+------------------------------------------------------------------+
//|                                                      PAUtils.mqh |
//+------------------------------------------------------------------+
#property strict


//-----------------------------------------------------------------------------+
//+********************************* Price Action *****************************+
//-----------------------------------------------------------------------------+

bool UpCandle(int bar) {return iClose(Symbol(),0,bar)>iOpen(Symbol(),0,bar) ? true : false;}
bool DownCandle(int bar) {return iClose(Symbol(),0,bar)<iOpen(Symbol(),0,bar) ? true : false;}
bool InRange(double p, double r, double spread) {return p>=(r-spread) && p<=(r+spread)? true: false;}


//-----------------------------------------------------------------------------+
//+********************************** UNITS ***********************************+
//-----------------------------------------------------------------------------+

double ToPips(double price) {
   double dig=MarketInfo(Symbol(),MODE_DIGITS);
   double pts=MarketInfo(Symbol(),MODE_POINT);
   return price/pts;
}  

string ToPipsStr(double price, int decimals=0) {
   double dig=MarketInfo(Symbol(),MODE_DIGITS);
   double pts=MarketInfo(Symbol(),MODE_POINT);
   return DoubleToStr(price/pts,decimals);
}

