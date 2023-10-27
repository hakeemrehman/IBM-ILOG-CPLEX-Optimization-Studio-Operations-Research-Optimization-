/*********************************************
 * OPL 12.6.0.0 Model
 * Author: Hakeem-ur-Rehman
 * Creation Date: Jan 4, 2017 at 11:14:06 AM
 *********************************************/
// execute Timelimit{
//		cplex.tilim=3600;
//				 }
				 
 main{
	// Generating & Solving initial model
	thisOplModel.generate(); // Generating the current model instance
		if (cplex.solve())
		{
		var ofile = new IloOplOutputFile("E:/4. MS-Industrial Engineering & Management/1. Advanced Operations Research (Session 2019-2021)/AOR (Lab)/2. Blending Problem/BP_Example2/Answer.txt");
  		ofile.writeln(thisOplModel.printSolution());
  		ofile.writeln("Solving CPU Elapsed Time  in (Seconds): ", cplex.getCplexTime());
  		ofile.writeln("Total Price=",thisOplModel.TotalPrice);
		ofile.writeln("Total Cost=",thisOplModel.TotalCost);	
  		ofile.close();
		var obj = cplex.getObjValue();
		writeln("The Value of the Objective Function Value is (Total Profit): ", obj);
		writeln("Solving CPU Elapsed Time  in (Seconds): ", cplex.getCplexTime()); 
		thisOplModel.postProcess(); 
		}
	else {
			writeln("No Solution");	
		 } 
	}
 
// indicies
int Raw_material = ...; range RM= 1..Raw_material;
int Final_products = ...; range FP= 1..Final_products;

// Parameters
int price[FP]=...;
float cost[RM]=...;
int supply[RM]=...;
int demand[FP]=...;
float minprop[RM][FP]=...;
float maxprop[RM][FP]=...;

//Decision Variable
dvar float+ P_Quantity[RM][FP];

//Objective Function
dexpr float TotalPrice = sum(j in FP) (price[j] *sum(i in RM)P_Quantity[i][j]);
dexpr float TotalCost = sum(i in RM) (cost[i] *sum(j in FP)P_Quantity[i][j]);

dexpr float profit = TotalPrice - TotalCost; 

//The Model
maximize profit;
subject to {
	Supply_Const:
	forall(i in RM)
	  sum(j in FP) P_Quantity[i][j] <= supply[i];
	
	Demand_Const:
	forall(j in FP)
	  sum(i in RM) P_Quantity[i][j] == demand[j];
	
	Minimum_Prop:
	forall (i in RM)
	  forall (j in FP)
	    P_Quantity[i][j] >= minprop[i][j] * sum(k in RM)  P_Quantity[k][j]; 
	
	Maximum_Prop:    
	forall (i in RM)
	  forall (j in FP)
	    P_Quantity[i][j] <= maxprop[i][j] * sum(k in RM)  P_Quantity[k][j]; 
}

execute { 
		writeln("Total Price=",TotalPrice);
		writeln("Total Cost=",TotalCost);	
}
 