//+----------------------------------------------------------------------------+
//|                                                         FX/SwingPoints.mqh |
//|                                                 Copyright 2018, Sean Estey |
//+----------------------------------------------------------------------------+
#property copyright "Copyright 2018, Sean Estey"
#property strict

#include <FX/Graph.mqh>
#include <FX/Chart.mqh>
#include <FX/Draw.mqh>

//---SwingPoint enums
enum SwingLength {THREE_BAR,FIVE_BAR};
enum SwingType {LOW,HIGH};
enum SwingLevel {SHORT,MEDIUM,LONG};
enum SwingLinkType {NEIGHBOR,IMPULSE};
enum SwingLinkDescription {LOWER_HIGH, HIGHER_HIGH, LOWER_LOW, HIGHER_LOW};

//--Config
SwingLength SwingBars             =THREE_BAR;
const int PointSize               =22;
const color PointColors[3]        ={clrMagenta, C'59,103,186', clrRed};
const string PointLblFonts[3]     ={"Arial", "Arial", "Arial Bold"};
const int PointLblSizes[3]        ={5, 9, 9};
const color PointLblColors[3]     ={clrBlack, C'59,103,186', clrRed};
const int LinkLblColor            =clrBlack;
const color LinkLineColor         =clrBlack;



//-----------------------------------------------------------------------------+
//| Return SwingType enum for valid swing points, -1 otherwise.
//-----------------------------------------------------------------------------+
SwingType GetSwingType(int bar){
   int min= SwingBars==THREE_BAR? 1: 2;
   int max= SwingBars==THREE_BAR? Bars-2: Bars-3;
   int n_checks= SwingBars==THREE_BAR? 1: 2;
      
   if(bar<min || bar>max)  // Bounds check
      return -1;
   
   // Loop 1: check nodes[i-1] to nodes[i+1]
   // Loop 2: check nodes[i-2] to nodes[i+2]
   for(int i=1; i<n_checks+1; i++) {            
      // Swing High test
      if(iHigh(NULL,0,bar)>iHigh(NULL,0,bar-i) && iHigh(NULL,0,bar)>iHigh(NULL,0,bar+i))
         return HIGH;
      // Swing Low test
      else if(iLow(NULL,0,bar)<iLow(NULL,0,bar-i) && iLow(NULL,0,bar)<iLow(NULL,0,bar+i))
         return LOW;
   }
   return -1;
}

//---------------------------------------------------------------------------------+
//|****************************** SwingPoint Class *********************************
//---------------------------------------------------------------------------------+
class SwingPoint: public Node{
   public:
      int TF;
      datetime DT;
      double O,C,H,L;
      SwingLevel Level;
      SwingType Type;
   public:
       SwingPoint(int tf, int shift):Node(shift) {
         this.Level=SHORT;
         this.Type=GetSwingType(shift);
         this.TF=tf;
         this.DT=Time[shift];
         this.O=Open[shift];
         this.C=Close[shift];
         this.H=High[shift];
         this.L=Low[shift];
         CreateText(this.LabelId,this.ToString(),this.Shift,this.Type==HIGH? ANCHOR_LOWER: ANCHOR_UPPER,0,0,0,0,PointLblFonts[this.Level],PointLblSizes[this.Level],PointLblColors[this.Level]);
         // Vertex drawn as text Wingdings Char(159) (empty string to hide)
         CreateText(this.PointId,"",this.Shift,-1,this.Type==HIGH?this.H:this.L,this.DT,0,0,"Wingdings",PointSize,PointColors[this.Level],0,true,false,true);
      }
      // Upgraded to intermediate/long-term swingpoint. Adjust fonts + draw Point.
      int RaiseLevel(SwingLevel lvl) {
         if(lvl>1)
            return -1;
         this.Level=lvl+1;
         ObjectSetText(this.LabelId,this.ToString(),
            PointLblSizes[this.Level],PointLblFonts[this.Level],PointLblColors[this.Level]);
         ObjectSetText(this.PointId,CharToStr(159),22,"Wingdings",PointColors[this.Level]);
         return 0;
      }
      void ShowLabel(bool toggle){
         ObjectSetText(this.LabelId,toggle? this.ToString(): "");
      }
      string ToString(){
         string prefix= this.Level==SHORT? "ST": this.Level==MEDIUM? "IT": this.Level==LONG? "LT": "";
         string sufix= this.Type==LOW? "L": this.Type==HIGH? "H" : "";
         return prefix+sufix; 
      }
};

//---------------------------------------------------------------------------------+
//|******************************* SwingLink Class *********************************
//---------------------------------------------------------------------------------+
class SwingLink: public Link {
   public:
      SwingLinkType Type;
      SwingLinkDescription Desc;
   public:
      SwingLink(SwingPoint* sp1, SwingPoint* sp2, SwingLinkType type): Link(sp1,sp2){  
         this.Type=type;
         double p1=sp1.Type==HIGH? sp1.H: sp1.L;
         double p2=sp2.Type==HIGH? sp2.H: sp2.L;
         
         
         
         int midpoint=(int)sp1.Shift-(int)MathFloor((sp1.Shift-sp2.Shift)/2);
         double delta_p=MathAbs(p1-p2);
         int delta_t=MathAbs(sp1.Shift-sp2.Shift);
         string label="";
         
         // Label swing/time/price relationship (e.g "HL,100,25")
         if(this.Type==NEIGHBOR){
            if(p1-p2<0)
               if(sp1.Type==HIGH) {
                  this.Desc=LOWER_HIGH;
                  label="LH"+","+ToPipsStr(p1-p2,0)+","+(string)delta_t;
               }
               else {
                  this.Desc=LOWER_LOW;
                  label="LL"+","+ToPipsStr(p1-p2,0)+","+(string)delta_t;
               }
            else if(p1-p2>0)
               if(sp1.Type==HIGH){
                  this.Desc=HIGHER_HIGH;
                  label="HH"+","+ToPipsStr(p1-p2,0)+","+(string)delta_t;
               }
               else {
                  this.Desc=HIGHER_LOW;
                  label="HL"+","+ToPipsStr(p1-p2,0)+","+(string)delta_t;
               }
               
            CreateTrendline(this.LineId,sp1.DT,p1,sp2.DT,p2,0,LinkLineColor,0,1,true,false);
            CreateText(this.LabelId,label,midpoint,sp1.Type==HIGH? ANCHOR_LOWER : ANCHOR_UPPER,
               p1<p2? p1+(delta_p/2): p2+(delta_p/2),0,0,0,"Arial",7,LinkLblColor);
         }
         else if(this.Type==IMPULSE) {
            CreateTrendline(this.LineId,sp1.DT,p1,sp2.DT,p2,0,clrRed,0,3,true,false,false);
            label="IMPULSE!";
            CreateText(this.LabelId,label,midpoint,sp1.Type==HIGH? ANCHOR_LOWER : ANCHOR_UPPER,
               p1<p2? p1+(delta_p/2): p2+(delta_p/2),0,0,0,"Arial",7,clrRed);
         }
         
         
      }
      
      //----------------------------------------------------------------------------
      string ToString() {
         if(this.Type==NEIGHBOR) {
            if(this.Desc==HIGHER_HIGH)
               return "Higher High";
            else if(this.Desc==LOWER_HIGH)
               return "Lower High";
            else if(this.Desc==HIGHER_LOW)
               return "Higher Low";
            else if(this.Desc==LOWER_LOW)
               return "Lower Low";
         }
         
         return "Uknown";
         /*string text=ObjectGetString(0,results[i],OBJPROP_TEXT)+", ";

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
         log(text+", u_sep:"+(string)u_sep+", parts.size:"+(string)ArraySize(parts));
         msg+=", "+(string)parts[1]+" pips, "+(string)parts[2]+" bars.";*/
      }
   
};

//---------------------------------------------------------------------------------+
//|****************************** SwingGraph Class *********************************
//---------------------------------------------------------------------------------+
class SwingGraph: public Graph {   
   public:
      SwingGraph(): Graph(){}
   
      //----------------------------------------------------------------------------
      void DiscoverNodes(string symbol, ENUM_TIMEFRAMES tf, int shift1, int shift2){
         int n_nodes=ArraySize(this.Nodes);
         if(n_nodes==0)
            log("Building SwingGraph...");
         else
            log("Building SwingGraph from Bars "+(string)shift1+"-"+(string)shift2+
               ". Nodes:"+(string)ArraySize(this.Nodes)+", Links:"+(string)ArraySize(this.Links));
         
         // Scan price data for any valid nodes to add to graph.
         for(int bar=shift1; bar>=shift2; bar--) {
            if(GetSwingType(bar)>-1) {
               string key=(string)(long)iTime(NULL,0,bar);
               if(!this.HasNode(key))
                  this.AddNode(new SwingPoint(tf,bar));
            }
         }
         log("Discovered "+(string)(ArraySize(this.Nodes)-n_nodes)+" Nodes.");
      }
      //----------------------------------------------------------------------------
      int UpdateNodeLevels(int level){
         if(level>=2)
            return 1;
         
         // Traverse nodes within SwingLevel.
         for(int i=0; i<ArraySize(this.Nodes); i++){
            SwingPoint *sp=this.Nodes[i];
            if(sp.Level!=level)
               continue;
               
            bool left=false,right=false;
            // Find left neighbor
            int j=i-1;
            while(j>=0){
               if(((SwingPoint*)this.Nodes[j]).Level>=sp.Level && sp.Type==((SwingPoint*)this.Nodes[j]).Type){
                  left=true;
                  break;
               }
               j--;
            }
            // Find right neighbor
            int k=i+1;
            while(k<ArraySize(this.Nodes)){
               if(((SwingPoint*)this.Nodes[k]).Level>=sp.Level && sp.Type==((SwingPoint*)this.Nodes[k]).Type){
                  right=true;
                  break;
               }
               k++;
            }
            // Increase node level if Lowest/Highest of its 2 neighbors.
            if(left && right){
               if(sp.Type==LOW && iLow(NULL,0,sp.Shift)<MathMin(iLow(NULL,0,this.Nodes[j].Shift),iLow(NULL,0,this.Nodes[k].Shift)))
                  sp.RaiseLevel(sp.Level);
               else if(sp.Type==HIGH && iHigh(NULL,0,sp.Shift)>MathMax(iHigh(NULL,0,this.Nodes[j].Shift),iHigh(NULL,0,this.Nodes[k].Shift)))
                  sp.RaiseLevel(sp.Level);
            }
         } 
         log("SwingPoint Levels "+(string)level+" updated.");
         this.UpdateNodeLevels(level+1);
         return 1;
      }
      //----------------------------------------------------------------------------
      int FindNeighborLinks(){
         // Connect Lvl1 Nodes-->Lvl1+ Nodes of same Type (to the right)
         // Connect Lvl2 Nodes-->Lvl2 Nodes of same Type (to the right)
         int n_traversals=0;
         int n_edges=ArraySize(this.Links);
         
         log("Finding adjacent SwingPoint edges...");
         if(ArraySize(this.Nodes)<=1)
            return -1;
         
         for(int i=0; i<ArraySize(this.Nodes); i++){
            SwingPoint *sp=this.Nodes[i];
            if(sp.Level<1)
               continue;
            
            SwingPoint *sp2=this.Nodes[i+1];
            
            for(int j=i+1; j<ArraySize(this.Nodes); j++) {
               sp2=this.Nodes[j];
               if(sp2.Type==sp.Type && sp2.Level>0)
                  break;
            }
            
            if(sp2.Level>0 && !this.HasLink(sp,sp2)){
               this.AddLink(new SwingLink(sp2,sp,NEIGHBOR));
            }
               n_traversals++;
         }
         log("Done. Traversed "+(string)n_traversals+" nodes, found "+(string)(ArraySize(this.Links)-n_edges)+" edges.");
         log(this.ToString());
         
         return 1;
      }
      //----------------------------------------------------------------------------
      //| Impulse definition:
      //| 1. SwingLink between SwingPointA (SPA) and SwingPointB (SPB)
      //| 2. SPA and SPB must be of opposite Types (HIGH/LOW)
      //| 3. SPB must be identified within existing SwingLink of Type NEIGHBOR 
      //|    with Desc==LOWER_LOW or HIGHER_HIGH (break of market structure)
      int FindImpulseLinks() {
         // Iterate through all SwingLinks with Desc HIGHER_HIGH or LOWER_LOW
         for(int i=0; i<ArraySize(this.Links); i++){
            SwingLink *link=(SwingLink*)this.Links[i];
            
            if(link.Desc==HIGHER_LOW || link.Desc==LOWER_HIGH)
               continue;
      
            SwingPoint *spb=NULL;
            // Take SwingPointB (SPB)
            if(link.Desc==HIGHER_HIGH)
               spb=((SwingPoint*)link.n1).C>((SwingPoint*)link.n2).C? link.n1: link.n2;
            else if(link.Desc==LOWER_LOW)
               spb=((SwingPoint*)link.n1).C<((SwingPoint*)link.n2).C? link.n1: link.n2;
            else
               log("Invalid SwingLink.Desc:"+(string)link.Desc);
            
            // Iterate SwingPoint nodes right-to-left from SPB.Shift to find SPA
            int j=this.NodeCount()-1;
            SwingPoint *spa=this.Nodes[j];
            while(spa.Shift<spb.Shift ) {
            
               j--;
               spa=this.Nodes[j];
            }
            log("Found prior SP (Nodes["+(string)j+"] as possible Impulse pair with SPB (Nodes["+(string)i+"]). NodeCount:"+(string)this.NodeCount());
            
            
            for(int j=this.NodeCount()-1; j>=0; j--){
               if(((SwingPoint*)this.Nodes[j]).Level>0 && this.Nodes[j].Shift<spb.Shift && ((SwingPoint*)this.Nodes[j]).Type!=spb.Type)
                  spa=this.Nodes[j];
            }
            
            if(spa && spb) {
               if(MathAbs(spa.Shift-spb.Shift) > 100)
                  continue;
               log("Found impulse link between SwingPoints at Shift "+(string)spa.Shift+" and "+(string)spb.Shift);
               this.AddLink(new SwingLink(spb,spa,IMPULSE));
            }
         }
         return 1;
      }
};
