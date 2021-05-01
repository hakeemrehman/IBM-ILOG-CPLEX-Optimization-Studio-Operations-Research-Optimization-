/*********************************************
 * OPL 12.10.0.0 Model
 * Author: Hakeem-Ur-Rehman
 * Creation Date: Aug 26, 2020 at 3:23:51 PM
 *********************************************/
 
 // Linear Programming (LP) Relaxation -- Convert IP/MIP to LP
 /************************************************************/
 
 // To implement Flow Control include a "main block"
 ///////////////////////////////////////////////////
 /*
 1. A .mod file can contain at most only one main block
 2. Main block will be first executed regardless of where it is placed in the .mod file
 */
  main{  
   //'thisOplModel' is a Script variable referring to the current model instance
   thisOplModel.convertAllIntVars(); 
   
   // generate() is a method used to generate the model instance
   thisOplModel.generate(); 
   
   /*
   1. cplex is a Script variable available by default, that refers to the CPLEX Optimizer instance
   2. solve() calls one of CPLEX Optimizer’s MP algorithms to solve the model
   */
   cplex.solve(); 
   
   writeln("Relaxed Model Answer");
   
   // getObjValue() is a method to access the value of the objective function
   writeln("The Value of the Objective Function (Total Cost): ",cplex.getObjValue());
 }

// Define Indecies 
{string} Products = ...;
{string} Resources = ...;
{string} Machines = ...;

// Define Parameters and Data
float MaxProduction = ...;
tuple typeProductData {
  float demand;
  float incost;
  float outcost;
  float use[Resources];
  string machine;
}
typeProductData Product[Products] = ...;
float Capacity[Resources] = ...;
float RentCost[Machines] = ...;

// Decision Variables
dvar boolean Rent[Machines];
dvar float+ Inside[Products];
dvar float+ Outside[Products];

// Objective Function - Total Cost
minimize
  sum( p in Products ) ( Product[p].incost * Inside[p] + Product[p].outcost * Outside[p] ) +  
  sum( m in Machines ) RentCost[m] * Rent[m];

// Constraints   
subject to {
  forall( r in Resources )
    ctCapacity:
      sum( p in Products ) Product[p].use[r] * Inside[p] <= Capacity[r]; 

  forall( p in Products )
    ctDemand: 
      Inside[p] + Outside[p] >= Product[p].demand;

  forall( p in Products )
    ctMaxProd:
      Inside[p] <= MaxProduction * Rent[Product[p].machine];
}
 