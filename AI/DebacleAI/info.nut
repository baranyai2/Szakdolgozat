 
 class DebacleAI extends AIInfo 
 {
   function GetAuthor()      { return "Xpleed"; }
   function GetName()        { return "DebacleAI"; }
   function GetDescription() { return "I don't know how it works but I will figure it out."; }
   function GetVersion()     { return 1; }
   function GetDate()        { return "2020-02-09"; }
   function CreateInstance() { return "DebacleAI"; }
   function GetShortName()   { return "DBCL"; }
 }
 
 RegisterAI(DebacleAI());