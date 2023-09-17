/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Dr. Hakeem-Ur-Rehman
 * Creation Date: 30-May-2023 at 3:52:18 pm
 *********************************************/
execute Timelimit{
  			cplex.tilim=3600;
				 }
main{
	// Generating & Solving initial model
	thisOplModel.generate(); // Generating the current model instance
		if (cplex.solve()) 
		{
		var ofile = new IloOplOutputFile("E:/1. University Teaching Data/2. PU-SC&PMC/1. Production Planning & Inventory Management/6. Master Production Schedule (MPS)/Multi-item Single level Capacitied LotSizing Using OPL Cplex/MSCLSP_Solution.txt");
  		ofile.writeln(thisOplModel.printSolution());
  		ofile.writeln("Solving CPU Elapsed Time  in (Seconds): ", cplex.getCplexTime());
  		ofile.writeln("Total Production Cost=",thisOplModel.TotalProductionCost);
		ofile.writeln("Total Holding Cost=",thisOplModel.TotalHoldingCost);	
		ofile.writeln("Total Setup Cost=",thisOplModel.TotalSetupCost);
  		ofile.close();
		var obj = cplex.getObjValue();
		writeln("The Value of the Objective Function Value is (Total Cost): ", obj);
		writeln("Solving CPU Elapsed Time  in (Seconds): ", cplex.getCplexTime()); 
		thisOplModel.postProcess(); 
		}
	else {
			writeln("No Solution");	
		 } 
	}

// Indices
	int J=...; 		range Products=1..J; 			
	//int K=...; 		range Resources=1..K;	
	int T=...; 		range Periods=1..T;

// Parameters and Data
	float Unit_Production_Cost = ...;
	float Setup_Cost[Products] = ...;
	float holding_Cost[Products] = ...;
	float Demand[Products][Periods] = ...;
	int production_time[Products]=...; // production time per unit
	int setuptime[Products]=...;	// Products Changeover Time 
	//int production_time[Resources][Products]=...; // production time per unit on particular resource
	//int setuptime[Resources][Products]=...;	// Products Changeover Time on particular resource
	float Capacity[Periods]=...;
	//float Capacity[Resources][Periods]=...;
	int BigM = ...;
	
// Defining Decision Variables	
	// Total Production Quality of the products in 't'				 
		dvar float+ productionquantity[Products][Periods]; 
	// Inventory Level of jth Product in Tth macroperiod
		dvar float+ inventory[Products][0..T]; 		
	// Product Setup/Changeover in Period 't'
		dvar boolean Psetup[Products][Periods];

// Computing the objective function value
	dexpr float TotalProductionCost = sum(j in Products, t in Periods) 
												Unit_Production_Cost*productionquantity[j][t]; 
	dexpr float TotalHoldingCost = sum(j in Products, t in Periods) 
												holding_Cost[j]*inventory[j][t];
	dexpr float TotalSetupCost = sum(j in Products, t in Periods) 
												Setup_Cost[j]*Psetup[j][t]; 
	
	// Total Value of the Objective Function
	dexpr float TOTAL_COST = TotalProductionCost + TotalHoldingCost + TotalSetupCost; 		

// The Model
minimize TOTAL_COST;
subject to {
	
	forall(j in Products) 
	  ctinitalInventory:
		inventory[j][0] == 100;
		
	forall(j in Products, t in Periods)
	  ctDemand:
		inventory[j][t-1] + productionquantity[j][t] == Demand[j][t] + inventory[j][t];

	forall(j in Products, t in Periods)
	  ctProduct_Quantity:
		productionquantity[j][t] <= BigM*Psetup[j][t];
	
	//Capacity Constraints
	 forall(t in Periods)
	    Production_Capacity: {
	     	sum(j in Products) production_time[j]*
	     	productionquantity[j][t] + sum(j in Products) setuptime[j]*Psetup[j][t] <= Capacity[t];
	
//	//Capacity Constraints
//	 forall(j in Products, t in Periods, k in Resources)
//	    Production_Capacity: {
//	     	sum(j in Products) production_time[k][j]*productionquantity[j][t] + 
//	     								sum(j in Products) setuptime[k][j]*Psetup[j][t] <= Capacity[k][t];     
	     }	
	
	}

execute { 
		writeln("Total Production Cost=",TotalProductionCost);
		writeln("Total Holding Cost=",TotalHoldingCost);	
		writeln("Total Setup Cost=",TotalSetupCost);
		}		

	























