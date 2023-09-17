/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Dr. Hakeem-Ur-Rehman
 * Creation Date: 08-Aug-2023 at 3:12:17 pm
 *********************************************/
main {
	//Create model
		var source = new IloOplModelSource("SCLSP.mod");
		var def = new IloOplModelDefinition(source);
		var opl = new IloOplModel(def, cplex);

	//Add data source
		var data = new IloOplDataSource("SCLSP.dat");
		opl.addDataSource(data);

	//Generate model
		opl.generate();

		if (cplex.solve()) {
		  	var ofile = new IloOplOutputFile("E:/1. University Teaching Data/2. PU-SC&PMC/1. Production Planning & Inventory Management/6. Master Production Schedule (MPS)/Single-item Capacitied LotSizing Using OPL Cplex/SCLSP_Solution.txt");
  			ofile.writeln(opl.printSolution());
  			ofile.writeln("Days of Production: ", opl.setup.solutionValue);
  			ofile.writeln("Inventories: ", opl.inventory.solutionValue);
			ofile.writeln("Lot sizes: ", opl.Pquantity.solutionValue);
			ofile.writeln("Total cost: ", cplex.getObjValue());
  			ofile.close();
  		
			writeln("Optimal solution");
			writeln();
			writeln("Days of Production: ", opl.setup.solutionValue);
			writeln("Inventories: ", opl.inventory.solutionValue);
			writeln("Lot sizes: ", opl.Pquantity.solutionValue);
			writeln("Total cost: ", cplex.getObjValue());			
		}
else {
  		writeln("No solution found!");
		}
	}

//Indices
int NPeriods = ...; 
range Periods = 1..NPeriods;

//Input parameters
int SC[Periods] = ...;
int HC[Periods] = ...;
int PC[Periods] = ...;
int Demand[Periods] = ...;
int Capacity[Periods] = ...;

//Decision variables
dvar boolean setup[Periods];
dvar float+ inventory[0..NPeriods];
dvar float+ Pquantity[Periods];

//Objective function: cost minimization
minimize sum(t in Periods) (SC[t]*setup[t] + HC[t]*inventory[t] + PC[t]*Pquantity[t]);

//Constraints
subject to {
	ctinitialinventory:
	inventory[0] == 0;
	
	forall(t in Periods)
	  ctinventoryBalancing:
		inventory[t] == inventory[t-1] + Pquantity[t] - Demand[t];

	forall(t in Periods)
	  ctCapacity:
 		Pquantity[t] <= Capacity[t]*setup[t];
}