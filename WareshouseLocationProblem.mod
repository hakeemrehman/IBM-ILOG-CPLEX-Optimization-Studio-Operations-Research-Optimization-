/*********************************************
 * OPL 12.10.0.0 Model
 * Author: Hakeem-Ur-Rehman
 * Creation Date: Aug 27, 2020 at 12:17:52 PM
 *********************************************/
 // Linear Programming (LP) Relaxation -- Convert IP/MIP to LP
 /************************************************************/
 
 // To implement Flow Control include a "main block"
 ///////////////////////////////////////////////////
  main{  
   //'thisOplModel' is a Script variable referring to the current model instance
   thisOplModel.convertAllIntVars(); 
      
   // generate() is a method used to generate the model instance
   thisOplModel.generate(); 
   cplex.solve(); 
   
  writeln("Relaxed Model Answer");
   
   // getObjValue() is a method to access the value of the objective function
   writeln("The Value of the Objective Function (Total Cost): ",cplex.getObjValue());
   writeln(thisOplModel.printSolution());
   writeln("Solving CPU Elapsed Time  in (Seconds): ", cplex.getCplexTime()); 
 }

// Warehouse Location Problem - Integer Programming Model 
{string} Warehouses = ...;
int NbStores = ...; range Stores = 0..NbStores-1;

int FixedCost = ...; // fixed cost for opening a warehouse
int Capacity[Warehouses] = ...; // maximum number stores assigned to each warehouse
int SupplyCost[Stores][Warehouses] = ...; // supply cost between each store and each warehouse


// Decision variables 
dvar boolean Open[Warehouses]; // 1 if warehouse is open, 0 otherwise
dvar boolean Supply[Stores][Warehouses]; // 1 if store supplied by warehouse, 0 otherwise

// Objective Function
minimize sum( w in Warehouses ) FixedCost * Open[w] + 
		sum( w in Warehouses , s in Stores ) SupplyCost[s][w] * Supply[s][w];

// Constraints
subject to{

forall( s in Stores )
	ctEachStoreHasOneWarehouse: sum( w in Warehouses ) Supply[s][w] == 1;
	
forall( w in Warehouses, s in Stores )
	ctUseOpenWarehouses: Supply[s][w] <= Open[w];
	
forall( w in Warehouses )
	ctMaxUseOfWarehouse: sum( s in Stores ) Supply[s][w] <= Capacity[w];
}

// this script is only for clearer output in the Console and serves no computational purpose
//{int} storesof[w in Warehouses] = { s | s in Stores : Supply[s][w] == 1 };
//execute {
//writeln("Open=",Open);
//writeln("storesof=",storesof);
//}

















