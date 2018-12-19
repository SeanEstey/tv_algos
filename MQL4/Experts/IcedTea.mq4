//+------------------------------------------------------------------+
//|                                                      IcedTea.mq4 |
//|                                       Copyright 2018, Sean Estey |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, Sean Estey"
#property description "IcedTea Robot"
#define VERSION   "0.01"
#property version VERSION
#property strict

#include <FX/Logging.mqh>
#include <FX/Utility.mqh>
#include <FX/Chart.mqh>
#include <FX/Graph.mqh>
#include <FX/SwingPoints.mqh>
#include <FX/Draw.mqh>
#include <FX/Hud.mqh>

//--- Keyboard inputs
#define KEY_L           76
#define KEY_S           83
#define EMA1_BUF_NAME   "EMA_FAST"
#define EMA2_BUF_NAME   "EMA_SLOW"

//---- Inputs
sinput int EMA1_Period           =9;
sinput int EMA2_Period           =18;
sinput double MinImpulseStdDevs  =3;

//--- Globals
HUD* Hud                   = NULL;
SwingGraph* Swings         = NULL;
bool ShowLevels            = false;
bool ShowSwings            = true;

long currentChart=ChartFirst();

//+------------------------------------------------------------------+
//|                                  |
//+------------------------------------------------------------------+
int OnInit() {
   ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE,true);
   
   
   //AttachedChartID=ChartOpen("XAUUSD.pro",0);
   //bool applied=ChartApplyTemplate(currentChart,"ICT.tpl");  
   //log("CurrentChartID:"+(string)currentChart+", AppliedTemplate:"+(string)applied);
   //log(err_msg());
   //ChartRedraw(currentChart);
 
   
   log("********** IcedTea Initializing **********");
   Hud = new HUD("IcedTea v"+VERSION);
   Hud.AddItem("hud_hover_bar","Hover Bar","");
   Hud.AddItem("hud_window_bars","Bars","");
   Hud.AddItem("hud_highest_high","Highest High","");
   Hud.AddItem("hud_lowest_low", "Lowest Low", "");
   Hud.AddItem("hud_trend", "Swing Trend", "");
   Hud.AddItem("hud_nodes", "Swing Nodes", "");
   Hud.AddItem("hud_node_links", "Node Links", "");
   Hud.SetDialogMsg("Hud created.");
   
   Hud.DisplayInfoOnChart();
   
   Swings = new SwingGraph();
   Swings.DiscoverNodes(NULL,0,Bars-1,1);
   Swings.UpdateNodeLevels(0);
   Swings.FindNeighborLinks();
   Swings.FindImpulseLinks();
   
  //   PrintAllObjects();      
   
   log("********** All systems check. **********");
   Hud.SetDialogMsg("All systems check.");
 
   return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//|                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {
   log(deinit_reason(reason));
   delete Hud;
   delete Swings;
   ObjectDelete(0,V_CROSSHAIR);
   ObjectDelete(0,H_CROSSHAIR); 
   int n=ObjectsDeleteAll();
   log("********** IcedTea Deinit. Deleted "+(string)n+" objects. **********");
   return;
}

//+------------------------------------------------------------------+
//|                                              |
//+------------------------------------------------------------------+
void OnTick() {
   if(!NewBar())
      return;
 
   //UpdateSwingPoints(Symbol(), 0, pos, 1, clrBlack, low, high, Lows, Highs, ChartObjs);
   //UpdateSwingTrends(Symbol(),0,Highs,ChartObjs);
   //UpdateSwingTrends(Symbol(),0,Lows,ChartObjs);
}

//+------------------------------------------------------------------+
//| Tester function                                                  |
//+------------------------------------------------------------------+
double OnTester() {
   double ret=0.0;
   return(ret);
}

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam) {
   switch(id) {
      case CHARTEVENT_CHART_CHANGE:
         OnChartChange(lparam,dparam,sparam);
         break;
      case CHARTEVENT_KEYDOWN:
         OnKeyPress(lparam,dparam,sparam);
         break;
      case CHARTEVENT_MOUSE_MOVE:
     
         OnMouseMove(lparam,dparam,sparam);
         break;
      case CHARTEVENT_CLICK:
         break;
      case CHARTEVENT_OBJECT_CLICK:
         break;
      default:
         break;
   }
}

//+---------------------------------------------------------------------------+
//| 
//+---------------------------------------------------------------------------+
int GetTrend(){

   SwingLink* link1=Swings.GetLinkByIndex(Swings.LinkCount()-1);
   SwingLink* link2=Swings.GetLinkByIndex(Swings.LinkCount()-2);
   
   SwingLinkDescription d1=link1.Desc;
   SwingLinkDescription d2=link2.Desc;
   
   if(d1==HIGHER_HIGH || d1==HIGHER_LOW){
      if(d2==HIGHER_HIGH || d2==HIGHER_LOW)
         Hud.SetItemValue("hud_trend", "Bullish");
      else
         Hud.SetItemValue("hud_trend", "Neutral");
   }
   else if(d1==LOWER_HIGH || d1==LOWER_LOW) {
      if(d2==LOWER_HIGH || d2==LOWER_LOW)
         Hud.SetItemValue("hud_trend", "Bearish");
      else
         Hud.SetItemValue("hud_trend", "Neutral");
   }
 
   //log("Last 2 SwingLink Descriptions:"+
   //   link1.ToString()+" (Lvl-"+(string)((SwingPoint*)link1.n2).Level+"), "+
   //   link2.ToString()+" (Lvl-"+(string)((SwingPoint*)link2.n2).Level+")");
   return 0;
}

//+---------------------------------------------------------------------------+-
//| OnCalculate() has been called already, and indicator destructor/constructor
//| on change of TF.
//+---------------------------------------------------------------------------+
void OnChartChange(long lparam, double dparam, string sparam) {
   log("Current Chart Id:"+(string)ChartID());

   // Update HUD
   int first = WindowFirstVisibleBar();
   int last = first-WindowBarsPerChart();
   Hud.SetItemValue("hud_window_bars",(string)(last+2)+"-"+(string)(first+2));
   int hh_shift=iHighest(Symbol(),0,MODE_HIGH,first-last,last);
   int ll_shift=iLowest(Symbol(),0,MODE_LOW,first-last,last);   
   double hh=iHigh(Symbol(),0,hh_shift);
   datetime hh_time=iTime(Symbol(),0,hh_shift);
   double ll=iLow(Symbol(),0,ll_shift);
   datetime ll_time=iTime(Symbol(),0,ll_shift);
   Hud.SetItemValue("hud_lowest_low", DoubleToStr(ll,3)+" [Bar "+(string)(ll_shift+2)+"]"); 
   Hud.SetItemValue("hud_highest_high", DoubleToStr(hh,3)+" [Bar "+(string)(hh_shift+2)+"]");
   Hud.SetItemValue("hud_nodes", Swings.NodeCount());
   Hud.SetItemValue("hud_node_links", Swings.LinkCount());
   GetTrend();
}

//+---------------------------------------------------------------------------+-
//| Respond to custom keyboard shortcuts
//+---------------------------------------------------------------------------+
void OnKeyPress(long lparam, double dparam, string sparam){
   // TODO: add KEY_L, to toggle labels on/off
   // TODO: add KEY_D, to toggle drawings on/off
   // TODO: add KEY_H, to toggle labels+drawings on/off
   
   switch(lparam){
      case KEY_S: 
         // Toggle Swing Candle labels
         /*ShowSwings = ShowSwings ? false : true;
         for(int i=0; i<ArraySize(Highs); i++) {
            //Highs[i].Annotate(ShowSwings);
         }
         for(int i=0; i<ArraySize(Lows); i++) {
            //Lows[i].Annotate(ShowSwings);
         }
         log("ShowSwings:"+(string)ShowSwings);*/
         break;
      case KEY_L: 
         // Toggle horizontal level lines
         /*
         if(ShowLevels==true) {
            // TODO: writeme   
            ShowLevels=false;
         }
         else {
            //DrawFixedRanges(Symbol(), PERIOD_D1, 0, 100, clrRed);
            //DrawFixedRanges(Symbol(), PERIOD_W1, 0, 10, clrBlue);
            //DrawFixedRanges(Symbol(), PERIOD_MN1, 0, 6, clrGreen);
            ShowLevels=true;
         }
         log("ShowLevels:"+(string)ShowLevels);*/
         break;
      default:
         //debuglog("Unmapped key:"+(string)lparam); 
         break;
   } 
   ChartRedraw(); 
}

//+---------------------------------------------------------------------------+-
//| Draw crosshair, update HUD with relevent info.
//+---------------------------------------------------------------------------+
void OnMouseMove(long lparam, double dparam, string sparam){

   DrawCrosshair(lparam, (long)dparam);
   int m_bar=CoordsToBar((int)lparam, (int)dparam);
   Hud.SetItemValue("hud_hover_bar",(string)m_bar);
   Hud.SetDialogMsg("Mouse move. Coords:["+(string)lparam+","+(string)dparam+"]");
   
   datetime m_dt;
   double m_price;
   int window=0;
   ChartXYToTimePrice(0,(int)lparam,(int)dparam,window,m_dt,m_price);
 
   string results[];
   FindObjectsAtTimePrice(m_dt,m_price,results);
   if(ArraySize(results)>0){
      string msg="";
      for(int i=0; i<ArraySize(results); i++){
         if(results[i]=="V_CROSSHAIR" || results[i]=="H_CROSSHAIR")
            continue;
         // Found a SwingPoint connection label. Write out the label text in full.
         /*if(ObjectType(results[i])==OBJ_TEXT && StringFind(results[i],"link_text")>-1){
            string text=ObjectGetString(0,results[i],OBJPROP_TEXT)+", ";
            
            if(StringFind(text,"HH")>-1)
               msg+="Higher High";
            else if(StringFind(text,"HL")>-1)
               msg+="Higher Low";
            else if(StringFind(text,"LL")>-1)
               msg+="Lower Low";
            else if(StringFind(text,"LH")>-1)
               msg+="Lower High";
               
            string parts[];
            ushort u_sep=StringGetCharacter(",",0); 
            StringSplit(text,u_sep,parts);
           // log(text+", u_sep:"+(string)u_sep+", parts.size:"+(string)ArraySize(parts));
            msg+=", "+(string)parts[1]+" pips, "+(string)parts[2]+" bars.";
         }
         else
            msg+=results[i]+", ";
            */
      }
      Hud.SetDialogMsg(msg);
   }
}

//+---------------------------------------------------------------------------+-
//| Identify any objects crosshair is hovering over
//+---------------------------------------------------------------------------+
bool FindObjectsAtTimePrice(datetime dt, double p, string &results[]) {
   // Label Properties: X/Y, Width/Height
   // Text Properties: Date/Price
   // Rectangle Label Properties: X/Y, Width/Height
   
   for(int i=ObjectsTotal(); i>=0; i--){
      string obj_name=ObjectName(i);
      datetime obj_dt=(datetime)ObjectGetInteger(0,obj_name,OBJPROP_TIME);
      double obj_price=ObjectGetDouble(0,obj_name,OBJPROP_PRICE);
      
      if(obj_dt+PeriodSeconds()>=dt && obj_dt-PeriodSeconds()<=dt){
         int pips=ToPips(p);
         int obj_pips=ToPips(obj_price);
         
         if(obj_pips>0 && pips+100>obj_pips && pips-100<obj_pips){
            ArrayResize(results,ArraySize(results)+1);
            results[ArraySize(results)-1]=obj_name;
            //log("Mouse Price:"+DoubleToStr(p)+", Pips:"+(string)pips+", Obj Price:"+DoubleToStr(obj_price)+", Pips:"+(string)obj_pips);
         }
      }
   }
   if(ArraySize(results)>0) {
      //log("Found "+(string)ArraySize(results)+" objects near "+(string)dt);
   }
   return ArraySize(results)>0? true: false;
}

