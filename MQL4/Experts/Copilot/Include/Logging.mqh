//+------------------------------------------------------------------+
//|                                                   FX/Logging.mqh |
//|                                       Copyright 2018, Sean Estey |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Sean Estey"
#property strict

#import "kernel32.dll"
   void OutputDebugStringW(string msg);
#import

#define EXT_LOGGING  true   // Toggle logger between external DebugView or MT4
#define DEBUG        true  // Toggle for muting debuglog()


//*****************************************************************************/
//+******************************* LOGGING ************************************+
//*****************************************************************************/

//+-----------------------------------------------------------------------------+
//+ Log to DebugView app if EXT_LOGGING global is true, MT4 logger otherwise
//+-----------------------------------------------------------------------------+
void log(string s1, string s2="",string s3="",string s4="",string s5="",
   string s6="",string s7="",string s8="")
{
   string left = WindowExpertName() + " ["+Symbol() +", "+(string)TimeCurrent()+"]: ";
   string msg = s1+" "+s2+" "+s3+" "+s4+" "+s5+" "+s6+" "+s7+" "+s8;
   if(EXT_LOGGING==true)   
      OutputDebugStringW(StringTrimRight(StringConcatenate(left,msg)));
   else
      Print(StringTrimRight(StringConcatenate(left,msg)));
}

//+-----------------------------------------------------------------------------+
//+ Log to DebugView app if EXT_LOGGING global is true, MT4 logger otherwise
//+-----------------------------------------------------------------------------+
void debuglog(string s1) {
   if(DEBUG==true)
      log(s1);
}

//+---------------------------------------------------------------------------+
//+---------------------------------------------------------------------------+
string deinit_reason(const int reason) {
   string msg="Deinit() called. Reason:";
   switch(reason) {
      case REASON_PROGRAM:
         return msg+"Expert Advisor terminated its operation by calling the "+
         " ExpertRemove() function";
      case REASON_REMOVE:
         return msg+"Program has been deleted from the chart";
      case REASON_RECOMPILE:
         return msg+"Program has been recompiled";
      case REASON_CHARTCHANGE:
         return msg+"Symbol or chart period has been changed";
      case REASON_CHARTCLOSE:
         return msg+"Chart has been closed";
      case REASON_PARAMETERS:
         return msg+"Input parameters have been changed by a user";
      case REASON_ACCOUNT:
         return msg+"Another account has been activated or reconnection to the trade "+
               "server has occurred due to changes in the account settings";
      case REASON_TEMPLATE:
         return msg+"A new template has been applied";
      case REASON_INITFAILED:
         return msg+"This value means that OnInit() handler has returned a nonzero value";
      case REASON_CLOSE:
         return msg+"Terminal has been closed";
      default:
         return msg+"Unknown reason for deinit";
   }
}

//+---------------------------------------------------------------------------+
// Returns error message text for a given MQL4 error number
// Usage:   string s=err_msg(146) returns s="Error 0146:  Trade context is busy."
//+---------------------------------------------------------------------------+
string err_msg() {
  int e = GetLastError();
  switch (e)   {
    case 0:     return("Error 0000:  No error returned.");
    case 1:     return("Error 0001:  No error returned, but the result is unknown.");
    case 2:     return("Error 0002:  Common error.");
    case 3:     return("Error 0003:  Invalid trade parameters.");
    case 4:     return("Error 0004:  Trade server is busy.");
    case 5:     return("Error 0005:  Old version of the client terminal.");
    case 6:     return("Error 0006:  No connection with trade server.");
    case 7:     return("Error 0007:  Not enough rights.");
    case 8:     return("Error 0008:  Too frequent requests.");
    case 9:     return("Error 0009:  Malfunctional trade operation.");
    case 64:    return("Error 0064:  Account disabled.");
    case 65:    return("Error 0065:  Invalid account.");
    case 128:   return("Error 0128:  Trade timeout.");
    case 129:   return("Error 0129:  Invalid price.");
    case 130:   return("Error 0130:  Invalid stops.");
    case 131:   return("Error 0131:  Invalid trade volume.");
    case 132:   return("Error 0132:  Market is closed.");
    case 133:   return("Error 0133:  Trade is disabled.");
    case 134:   return("Error 0134:  Not enough money.");
    case 135:   return("Error 0135:  Price changed.");
    case 136:   return("Error 0136:  Off quotes.");
    case 137:   return("Error 0137:  Broker is busy.");
    case 138:   return("Error 0138:  Requote.");
    case 139:   return("Error 0139:  Order is locked.");
    case 140:   return("Error 0140:  Long positions only allowed.");
    case 141:   return("Error 0141:  Too many requests.");
    case 145:   return("Error 0145:  Modification denied because order too close to market.");
    case 146:   return("Error 0146:  Trade context is busy.");
    case 147:   return("Error 0147:  Expirations are denied by broker.");
    case 148:   return("Error 0148:  The amount of open and pending orders has reached the limit set by the broker.");
    case 149:   return("Error 0149:  An attempt to open a position opposite to the existing one when hedging is disabled.");
    case 150:   return("Error 0150:  An attempt to close a position contravening the FIFO rule.");
    case 4000:  return("Error 4000:  No error.");
    case 4001:  return("Error 4001:  Wrong function pointer.");
    case 4002:  return("Error 4002:  Array index is out of range.");
    case 4003:  return("Error 4003:  No memory for function call stack.");
    case 4004:  return("Error 4004:  Recursive stack overflow.");
    case 4005:  return("Error 4005:  Not enough stack for parameter.");
    case 4006:  return("Error 4006:  No memory for parameter string.");
    case 4007:  return("Error 4007:  No memory for temp string.");
    case 4008:  return("Error 4008:  Not initialized string.");
    case 4009:  return("Error 4009:  Not initialized string in array.");
    case 4010:  return("Error 4010:  No memory for array string.");
    case 4011:  return("Error 4011:  Too long string.");
    case 4012:  return("Error 4012:  Remainder from zero divide.");
    case 4013:  return("Error 4013:  Zero divide.");
    case 4014:  return("Error 4014:  Unknown command.");
    case 4015:  return("Error 4015:  Wrong jump (never generated error).");
    case 4016:  return("Error 4016:  Not initialized array.");
    case 4017:  return("Error 4017:  DLL calls are not allowed.");
    case 4018:  return("Error 4018:  Cannot load library.");
    case 4019:  return("Error 4019:  Cannot call function.");
    case 4020:  return("Error 4020:  Expert function calls are not allowed.");
    case 4021:  return("Error 4021:  Not enough memory for temp string returned from function.");
    case 4022:  return("Error 4022:  System is busy (never generated error).");
    case 4024:  return("Error 4024:  Internal Error. WTF DID YOU DO??");
    case 4050:  return("Error 4050:  Invalid function parameters count.");
    case 4051:  return("Error 4051:  Invalid function parameter value.");
    case 4052:  return("Error 4052:  String function internal error.");
    case 4053:  return("Error 4053:  Some array error.");
    case 4054:  return("Error 4054:  Incorrect series array using.");
    case 4055:  return("Error 4055:  Custom indicator error.");
    case 4056:  return("Error 4056:  Arrays are incompatible.");
    case 4057:  return("Error 4057:  Global variables processing error.");
    case 4058:  return("Error 4058:  Global variable not found.");
    case 4059:  return("Error 4059:  Function is not allowed in testing mode.");
    case 4060:  return("Error 4060:  Function is not confirmed.");
    case 4061:  return("Error 4061:  Send mail error.");
    case 4062:  return("Error 4062:  String parameter expected.");
    case 4063:  return("Error 4063:  Integer parameter expected.");
    case 4064:  return("Error 4064:  Double parameter expected.");
    case 4065:  return("Error 4065:  Array as parameter expected.");
    case 4066:  return("Error 4066:  Requested history data in updating state.");
    case 4067:  return("Error 4067:  Some error in trading function.");
    case 4099:  return("Error 4099:  End of file.");
    case 4100:  return("Error 4100:  Some file error.");
    case 4101:  return("Error 4101:  Wrong file name.");
    case 4102:  return("Error 4102:  Too many opened files.");
    case 4103:  return("Error 4103:  Cannot open file.");
    case 4104:  return("Error 4104:  Incompatible access to a file.");
    case 4105:  return("Error 4105:  No order selected.");
    case 4106:  return("Error 4106:  Unknown symbol.");
    case 4107:  return("Error 4107:  Invalid price.");
    case 4108:  return("Error 4108:  Invalid ticket.");
    case 4109:  return("Error 4109:  Trade is not allowed. Enable checkbox 'Allow live trading' in the expert properties.");
    case 4110:  return("Error 4110:  Longs are not allowed. Check the expert properties.");
    case 4111:  return("Error 4111:  Shorts are not allowed. Check the expert properties.");
    case 4200:  return("Error 4200:  Object exists already.");
    case 4201:  return("Error 4201:  Unknown object property.");
    case 4202:  return("Error 4202:  Object does not exist.");
    case 4203:  return("Error 4203:  Unknown object type.");
    case 4204:  return("Error 4204:  No object name.");
    case 4205:  return("Error 4205:  Object coordinates error.");
    case 4206:  return("Error 4206:  No specified subwindow.");
    case 4207:  return("Error 4207:  Some error in object function.");
    case 5004:   return("Error 5004:  Cannot open file.");
    case 5005:  return("Error 5005: Text file buffer allocation error.");
    case 5007:  return("Error 5007: Invalid file handle.");
    case 5008:  return("Error 5008: Wrong file handle (handle index out of handle table.");
    case 5015:  return("Error 5015: File read error.");
    case 5016:  return("Error 5016: File write error.");
    case 5020:  return("Error 5020: File does not exist.");
    default:    return("Error " + (string)e + ": ??? Unknown error.");
    
  }   
  return((string)0);   
}