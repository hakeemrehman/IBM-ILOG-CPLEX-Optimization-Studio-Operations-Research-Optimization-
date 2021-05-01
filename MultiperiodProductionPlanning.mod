/*********************************************
 * OPL 12.10.0.0 Model
 * Author: Hakeem-Ur-Rehman
 * Creation Date: Aug 28, 2020 at 12:06:46 PM
 *********************************************/

// Multi-Period Production Planning Problem
/*******************************************/

//// Iterative Solve
//main {
//   var status = 0;
//   thisOplModel.generate(); // Using the current model instance
// 
//   var produce = thisOplModel;
//   var capFlour = produce.Capacity["flour"]; // Obtain the starting Flour Capacity
// 
//   var best;
//   var curr = Infinity;
//   var basis = new IloOplCplexBasis();
//   var ofile = new IloOplOutputFile("mulprod_main.txt");
//   
//   while ( 1 ) {
//     best = curr;
//     writeln("Solve with capFlour = ",capFlour);
//     if ( cplex.solve() ) {
//       curr = cplex.getObjValue();
//       writeln();
//       writeln("OBJECTIVE: ",curr);
//       ofile.writeln("Objective with capFlour = ", capFlour, " is ", curr);        
//     } 
//     else {
//       writeln("No solution!");
//       break;
//     }
//     if ( best==curr ) break; // Stopping criteria
// 
//     if ( !basis.getBasis(cplex) ) {
//       writeln("warm start preparation failed: ",basis.status);
//       break;
//     }
// 
//     // Prepare Next Iteration
//     var def = produce.modelDefinition; // Create new model definition
//     var data = produce.dataElements; // Reference new data elements
//       
//     if ( produce!=thisOplModel ) {
//       produce.end(); // End the previous OPL model instance
//     }
// 
//     produce = new IloOplModel(def,cplex); // Create new OPL model instance
//     capFlour++;
//     data.Capacity["flour"] = capFlour; // Change data (new flour capacity)
//     produce.addDataSource(data); // Add new data to OPL model instance
//     produce.generate(); // Generate the new OPL model instance
// 
//     if ( !basis.setBasis(cplex) ) {
//       writeln("warm start ",basis.Nrows,"x",basis.Ncols," failed: ",basis.status);
//       break;
//     }
//   }
//   basis.end();
//   ofile.close();
//   if (Math.abs(cplex.getObjValue() - 393.5)>=0.01) {
//       status = -1;
//   }
//   if (best != Infinity) {
//     writeln("plan = ",produce.Plan);
//   }
//   
//   if ( produce!=thisOplModel ) {
//     produce.end();
//   }
//   status;
// }

// Indices
{string} Products = ...;
{string} Resources = ...;
int NbPeriods = ...; range Periods = 1..NbPeriods;

// Parameters and Data
float Consumption[Resources][Products] = ...;
float Capacity[Resources] = ...;
float Demand[Products][Periods] = ...;
float InsideCost[Products] = ...;
float OutsideCost[Products] = ...;
float Inventory[Products] = ...;
float InvCost[Products] = ...;

// Decision Variables
dvar float+ Inside[Products][Periods];
dvar float+ Outside[Products][Periods];
dvar float+ Inv[Products][0..NbPeriods];

// Objective Function
minimize sum(p in Products, t in Periods) (InsideCost[p]*Inside[p][t] + OutsideCost[p]*Outside[p][t] + InvCost[p]*Inv[p][t]);

subject to {
	forall(r in Resources, t in Periods)
	ctCapacity:
		sum(p in Products) Consumption[r][p] * Inside[p][t] <= Capacity[r];

	forall(p in Products , t in Periods)
	ctDemand:
		Inv[p][t-1] + Inside[p][t] + Outside[p][t] == Demand[p][t] + Inv[p][t];

	forall(p in Products)
	ctInventory:
		Inv[p][0] == Inventory[p];
	}

// Use Postprocessing execute blocks to display the output data
tuple plan {
	float inside;
	float outside;
	float inv;
}
plan Plan[p in Products][t in Periods] = <Inside[p,t],Outside[p,t],Inv[p,t]>;

execute{
	writeln("Current Plan = ",Plan);
}
