//+----------------------------------------------------------------------------+
//|                                                               FX/Graph.mqh |
//|                                                 Copyright 2018, Sean Estey |
//+----------------------------------------------------------------------------+
#property copyright "Copyright 2018, Sean Estey"
#property strict

#include "Logging.mqh"


//---------------------------------------------------------------------------------+
//|********************************* Node Class ************************************
//---------------------------------------------------------------------------------+
class Node {
   public:
      string Id, PointId, LabelId;
      int Shift;
   public:
      Node(int shift) {
         this.Shift=shift;
         this.Id=(string)(long)iTime(NULL,0,this.Shift);
         this.PointId=this.Id+"_point";
         this.LabelId=this.Id+"_label";
      }
      ~Node() {
         ObjectDelete(this.PointId);
         ObjectDelete(this.LabelId);
      }
      bool operator<(const Node *n) const {return this.Shift<n.Shift;}
      bool operator>(const Node *n) const {return this.Shift>n.Shift;}
      Node* LeftMost(Node *n) {return this.Shift>n.Shift? GetPointer(this): n;}
      Node* RightMost(Node *n) {return this.Shift<n.Shift? GetPointer(this): n;}
      string ToString() {return "";}
};
//---------------------------------------------------------------------------------+
//|********************************* Relationship Class ************************************
//---------------------------------------------------------------------------------+
class Relationship {
   public:
      string Id, LineId, LabelId;
      Node *Left,*Right;
   public:
      Relationship(Node* left, Node* right) {
         this.Id=this.CreateKey(left,right);
         this.LineId="link_line_"+this.Id;
         this.LabelId="link_text_"+this.Id;
         this.Left=left;
         this.Right=right;
      }
      ~Relationship() {
         ObjectDelete(this.LineId);
         ObjectDelete(this.LabelId);
      }
      
      string CreateKey(Node *node1, Node *node2){
         return (string)MathMax((long)node1.Id,(long)node2.Id)+
            (string)MathMin((long)node1.Id,(long)node2.Id);
      }
};
//---------------------------------------------------------------------------------+
//|****************************** SwingGraph Class *********************************
//---------------------------------------------------------------------------------+
class Graph {
   protected:
      Node *Nodes[];
      Relationship *Links[];
   public:
      Graph(){}
      ~Graph(void);
      void AddNode(Node *n);
      Node *GetNode(int idx);
      bool HasNode(string key);
      bool HasNode(Node* n);
      int NodeCount() {return ArraySize(this.Nodes);}
      void AddRelationship(Relationship *link);
      void RmvRelationship(Relationship *link);
      bool HasRelationship(Node* n1, Node* n2);
      Relationship* GetRelationship(Node *n1, Node *n2);
      Relationship* GetRelationshipByIndex(int idx);
      int RelationshipCount() {return ArraySize(this.Links);}
      string ToString();
};
//----------------------------------------------------------------------------
Graph::~Graph(void){
   int n_nodes=ArraySize(this.Nodes);
   int n_links=ArraySize(this.Links);
   
   for(int i=0; i<ArraySize(this.Nodes); i++)
      delete this.Nodes[i];
   for(int i=0; i<ArraySize(this.Links); i++)
      delete this.Links[i];
   
   log("~Graph(): deleted "+(string)n_nodes+" nodes, "+(string)n_links+" edges.");
}
//----------------------------------------------------------------------------
Node* Graph::GetNode(int idx){
   return this.Nodes[idx];
}
//----------------------------------------------------------------------------
bool Graph::HasNode(string key) {
   for(int i=0; i<ArraySize(this.Nodes); i++){
      if(this.Nodes[i].Id==key)
         return true;
   }
   return false;
}
//----------------------------------------------------------------------------
bool Graph::HasNode(Node *n) {
   for(int i=0; i<ArraySize(this.Nodes); i++){
      if(this.Nodes[i].Id==n.Id)
         return true;
   }
   return false;
}
//----------------------------------------------------------------------------
void Graph::AddNode(Node* n) {
   ArrayResize(this.Nodes,ArraySize(this.Nodes)+1);
   this.Nodes[ArraySize(this.Nodes)-1]=n;
}
//----------------------------------------------------------------------------
void Graph::AddRelationship(Relationship* link) {
   ArrayResize(this.Links,ArraySize(this.Links)+1);
   this.Links[ArraySize(this.Links)-1]=link;
}
//----------------------------------------------------------------------------
bool Graph::HasRelationship(Node* n1, Node* n2) {
   string key=(string)MathMax((long)n1.Id,(long)n2.Id)+
      (string)MathMin((long)n1.Id,(long)n2.Id);
      
   for(int i=0; i<ArraySize(this.Links); i++){
      if(this.Links[i].Id==key)
         return true;
   }
   return false;
}
//----------------------------------------------------------------------------
Relationship* Graph::GetRelationship(Node *n1, Node *n2){
   string key=(string)MathMax((long)n1.Id,(long)n2.Id)+
      (string)MathMin((long)n1.Id,(long)n2.Id);
      
   for(int i=0; i<ArraySize(this.Links); i++){
      if(this.Links[i].Id==key)
         return this.Links[i];
   }
   return NULL;
}
//----------------------------------------------------------------------------
Relationship* Graph::GetRelationshipByIndex(int idx){
   if(idx>=ArraySize(this.Links))
      return NULL;
   return this.Links[idx];
}
//----------------------------------------------------------------------------
string Graph::ToString(){
   return "Graph has "+(string)ArraySize(this.Nodes)+
      " nodes, "+(string)ArraySize(this.Links)+" edges.";
}    