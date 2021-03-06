//+------------------------------------------------------------------+
//|                                                      Objects.mqh |
//+------------------------------------------------------------------+
#property strict

string ObjectTypeString[40]={
   "Vertical Line","Horizontal Line","Trendline","3","4",
   "5","6","7","8","9",
   "10","11","12","13","14",
   "15","16","17","Rectangle","19",
   "20","Text","22","Label","24",
   "25","26","27","Rectangle Label","29",
   "30","31","32","33","34",
   "35","36","37","38","39"
};

ENUM_OBJECT_PROPERTY_STRING ObjStrProp[7]={
   OBJPROP_NAME,
   OBJPROP_TEXT,
   OBJPROP_TOOLTIP,
   OBJPROP_LEVELTEXT,
   OBJPROP_FONT,
   OBJPROP_BMPFILE,
   OBJPROP_SYMBOL
};

string ObjStrPropString[7]={
   "NAME",
   "TEXT",
   "TOOLTIP",
   "LEVELTEXT",
   "FONT",
   "BMPFILE",
   "SYMBOL"
};

ENUM_OBJECT_PROPERTY_DOUBLE ObjDoubleProp[5]={
   OBJPROP_PRICE,
   OBJPROP_LEVELVALUE,
   OBJPROP_SCALE,
   OBJPROP_ANGLE,
   OBJPROP_DEVIATION
};

string ObjDoublePropString[5]={
   "PRICE",
   "LEVELVALUE",
   "SCALE",
   "ANGLE",
   "DEVIATION"
};

ENUM_OBJECT_PROPERTY_INTEGER ObjIntProp[29]={
   OBJPROP_COLOR,
   OBJPROP_STYLE ,          // ENUM_LINE_STYLE
   OBJPROP_WIDTH,
   OBJPROP_BACK,
   OBJPROP_ZORDER,
   OBJPROP_HIDDEN,
   OBJPROP_SELECTED,
   OBJPROP_TYPE,            // ENUM_OBJECT
   OBJPROP_TIME,
   OBJPROP_SELECTABLE,
   OBJPROP_CREATETIME,
   OBJPROP_LEVELS,          // Line
   OBJPROP_LEVELCOLOR,      // Line
   OBJPROP_LEVELSTYLE,     // Line
   OBJPROP_LEVELWIDTH,      // Line
   OBJPROP_ALIGN,           // Edit obj
   OBJPROP_FONTSIZE,
   OBJPROP_RAY_RIGHT,
   OBJPROP_TIMEFRAMES,      // Visibility at timeframes (uses flags)
   OBJPROP_ANCHOR,
   OBJPROP_XDISTANCE,       // From binding corner
   OBJPROP_YDISTANCE,       // From binding corner
   OBJPROP_STATE,           // For buttons
   OBJPROP_XSIZE,           // Labels,Buttons,Bitmaps,Edit,RectangleLabels objs
   OBJPROP_YSIZE,
   //OBJPROP_XOFFSET       // Bitmap property
   //OBJPROP_YOFFSET       // Bitmap property
   OBJPROP_BGCOLOR,         // Edit,Button,RectangleLabel
   OBJPROP_CORNER,
   OBJPROP_BORDER_TYPE,     // RectangleLabel
   OBJPROP_BORDER_COLOR    // Edit,Button objs
};

string ObjIntPropString[29]={
   "COLOR",
   "STYLE" ,          // ENUM_LINE_STYLE
   "WIDTH",
   "BACK",
   "ZORDER",
   "HIDDEN",
   "SELECTED",
   "TYPE",            // ENUM_OBJECT
   "TIME",
   "SELECTABLE",
   "CREATETIME",
   "LEVELS",          // Line
   "LEVELCOLOR",      // Line
   "LEVELSTYLE",     // Line
   "LEVELWIDTH",      // Line
   "ALIGN",           // Edit obj
   "FONTSIZE",
   "RAY_RIGHT",
   "TIMEFRAMES",      // Visibility at timeframes (uses flags)
   "ANCHOR",
   "XDISTANCE",       // From binding corner
   "YDISTANCE",       // From binding corner
   "STATE",           // For buttons
   "XSIZE",           // Labels,Buttons,Bitmaps,Edit,RectangleLabels objs
   "YSIZE",
   //OBJPROP_XOFFSET       // Bitmap property
   //OBJPROP_YOFFSET       // Bitmap property
   "BGCOLOR",         // Edit,Button,RectangleLabel
   "CORNER",
   "BORDER_TYPE",     // RectangleLabel
   "BORDER_COLOR"    // Edit,Button objs
};


//+---------------------------------------------------------------------------+
//|
//+---------------------------------------------------------------------------+
void PrintObject(string name) {
   string msg="\n-------------------------\n";
   msg+="OBJECT_TYPE:" +ObjectTypeString[ObjectType(name)]+"\n";
   
   for(int i=0; i<ArraySize(ObjStrProp); i++){
      int prop=ObjStrProp[i];
      string r=ObjectGetString(0,name,prop);
      if(StringLen(r)>0)
         msg+=ObjStrPropString[i]+": \""+r+"\"\n";
   }
   for(int i=0; i<ArraySize(ObjIntProp); i++){
      int prop=ObjIntProp[i];
      int r=(int)ObjectGetInteger(0,name,prop);
      if(r>0)
         msg+=ObjIntPropString[i]+": "+(string)r+"\n";
   }
   for(int i=0; i<ArraySize(ObjDoubleProp); i++){
      int prop=ObjDoubleProp[i];
      double r=ObjectGetDouble(0,name,prop);
      if(r>0)
         msg+=ObjDoublePropString[i]+": "+DoubleToStr(r)+"\n";
   }
   msg+="-------------------------";
   log(msg);
}

//+---------------------------------------------------------------------------+
//|
//+---------------------------------------------------------------------------+
void PrintAllObjects(){
   log("------------------------------------------");
   log((string)ObjectsTotal()+" total objects.");  
   
   for(int i=100; i>=0; i--){
      string obj_name=ObjectName(i);
      PrintObject(obj_name);   
   }
   log("------------------------------------------");
}