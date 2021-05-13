
 class DebacleAI extends AIInfo
 {
   function GetAuthor()      { return "Zoltán Baranyai"; }
   function GetName()        { return "DebacleAI"; }
   function GetDescription() { return "A simple AI transporting passengers between cities on a direct line."; }
   function GetVersion()     { return 1; }
   function GetDate()        { return "2020-02-09"; }
   function CreateInstance() { return "DebacleAI"; }
   function GetShortName()   { return "DBCL"; }
 }

 RegisterAI(DebacleAI());