//+----------------------------------------------------------------------------+
//|                                                               FX/Graph.mqh |
//|                                                 Copyright 2018, Sean Estey |
//+----------------------------------------------------------------------------+
#property copyright "Copyright 2018, Sean Estey"
#property strict

#include <Generic/HashMap.mqh>
#include <FX/Logging.mqh>


//---------------------------------------------------------------------------------+
//|********************************* Node Class ************************************
//---------------------------------------------------------------------------------+
class Node {
   public:
      string Id, PointId, LabelId;
      int Shift;
      Node *Prev, *Next;                    
   public:
      Node(int shift) {
         this.Prev=NULL;
         this.Next=NULL;
         this.Shift=shift;
         this.Id=(string)(long)iTime(NULL,0,this.Shift);
         this.PointId=this.Id+"_point";
         this.LabelId=this.Id+"_label";
      }
      ~Node() {
         ObjectDelete(this.PointId);
         ObjectDelete(this.LabelId);
      }
      string ToString() {return "";}
};
//---------------------------------------------------------------------------------+
//|********************************* Link Class ************************************
//---------------------------------------------------------------------------------+
class Link {
   public:
      string Id, LineId, LabelId;
      Node *n1,*n2;
      string Description;
   public:
      Link(Node* node1, Node* node2, string description) {
         this.Id=this.CreateKey(node1,node2);
         this.LineId=this.Id+"_line";
         this.LabelId=this.Id+"_label";
         this.n1=node1;
         this.n2=node2;
         this.Description=description;
      }
      ~Link() {
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
   private:
      Link* LinkPtrs[];            // Pointer index for memory management
   public:
      CHashMap<string,Node*> nodes;
      Node *FirstNode,*LastNode;
      CHashMap<string,Link*> links;
   public:
      Graph(){log(this.ToString());}
      ~Graph(void);
      bool HasNode(Node* n) {return this.nodes.ContainsValue(n)? true: false;}
      bool HasNode(string key) {return this.nodes.ContainsKey(key)? true: false;}
      bool HasLink(Node* n1, Node* n2);
      void AddNode(Node *n);
      void AddLink(Link *link);
      void RmvLink(Link* link);
      string ToString();
};

//----------------------------------------------------------------------------
Graph::~Graph(void){
   // Seems no way to iterate through list of HashMaps natively, so
   // traverse the linked list of nodes, deleting the pointers along the way.
   // LinkPtrs array exists solely to keep a list of pointers requiring
   // deletion here (no linked list between Link objects).
   int nodes_rmv=0,links_rmv=0;
   
   // Delete Node pointers
   Node *n=this.FirstNode;
   while(n!=this.LastNode){
      Node *tmp=n;
      n=n.Next;
      delete tmp;
      nodes_rmv++;
   }
   delete this.LastNode;
   // Delete Link pointers
   for(int i=0; i<ArraySize(this.LinkPtrs);i++){
      delete this.LinkPtrs[i];
      links_rmv++;
   }
   this.nodes.Clear();
   this.links.Clear();  
   log("~Graph(): deleted "+(string)nodes_rmv+" nodes, "
      +(string)links_rmv+" edges.");
}

//----------------------------------------------------------------------------
void Graph::AddNode(Node* n) {
   // Maintain a linked list of Nodes on top of the hashmap structure for
   // easy traversal.
   if(this.nodes.Add(n.Id,n)) {
      if(this.nodes.Count()==1){
         n.Prev=NULL;
         n.Next=NULL;
         this.FirstNode=n;
         this.LastNode=n;
      }
      else {
         n.Prev=this.LastNode;
         n.Next=NULL;
         this.LastNode.Next=n;
         this.LastNode=n;
      }
   }
}

//----------------------------------------------------------------------------
bool Graph::HasLink(Node* n1, Node* n2) {
   string key=(string)MathMax((long)n1.Id,(long)n2.Id)+
      (string)MathMin((long)n1.Id,(long)n2.Id);
   return this.links.ContainsKey(key)? true: false;
}

//----------------------------------------------------------------------------
void Graph::AddLink(Link* link) {
   bool r=this.links.Add(link.Id,link);
   if(r){
      ArrayResize(this.LinkPtrs,ArraySize(this.LinkPtrs)+1);
      this.LinkPtrs[ArraySize(this.LinkPtrs)-1]=link;
   }
   else
      log("Link not added. Desc:"+err_msg());
}

//----------------------------------------------------------------------------
void Graph::RmvLink(Link* link){
   string key=link.n1.Id+link.n2.Id;
   int s1=this.links.Count();
   this.links.Remove(key);
}

//----------------------------------------------------------------------------
string Graph::ToString(){
   return "Graph has "+(string)this.nodes.Count()+
      " nodes, "+(string)this.links.Count()+" edges.";
}    