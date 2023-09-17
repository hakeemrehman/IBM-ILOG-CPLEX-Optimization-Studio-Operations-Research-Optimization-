/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Dr. Hakeem-Ur-Rehman
 * Creation Date: 08-Aug-2023 at 5:39:27 pm
 *********************************************/
main {
	//Create model
		var source = new IloOplModelSource("SCLSP.mod");
		var def = new IloOplModelDefinition(source);
		var opl = new IloOplModel(def, cplex);

	//Add data source
		var data = new IloOplDataSource("SCLSP.dat");
		opl.addDataSource(data);
	
	//Relax the integrality constraints
		opl.convertAllIntVars();
	
	//Generate model
		opl.generate(); 
	
	// Drive-and-Fix Heuristic
	// Step 1: Solve the LP relaxation of the mixed-integer optimization problem
		if (cplex.solve()) 
		{
 		// Temporarily store the solution
 		var setupRelax = new Array();
		for (var i = 1; i <= opl.dataElements.NPeriods; i++) 
		{
			setupRelax[i] = opl.setup[i].solutionValue;
		}
		writeln("Dive-and-Fix Heuristic");
		writeln();
		writeln("Setup = ", opl.setup.solutionValue);
	
	/* Step 2: Fix all of the variables with a binary value in the LP relaxation’s solution. If all the 
			   original binary variables have been fixed, then stop.	
	   Step 3: Of the remaining variables, choose the one with the smallest distance to the nearest integer 
	   		   (here 0 or 1). Fix this variable to 0 if it is smaller than 0.5 and otherwise to 1.			   
	   Step 4: Solve the LP relaxation again. Go back to step 2 if the solution of the LP relaxation is feasible. */
		var abort = false;
		// Loop (from step 2 to step 4)
		while (!abort) 
		{
		var nBinary = 0;
		opl.end();
		opl = new IloOplModel(def, cplex);
		var data = new IloOplDataSource("SCLSP.dat");
		opl.addDataSource(data);
			
		opl.convertAllIntVars();
		opl.generate();
		
	// Step 2: Fix all of the variables with a binary value in the LP relaxation’s solution 
		for (var t = 1; t <= opl.dataElements.NPeriods; t++) 
		{
			if (setupRelax[t]==0 || setupRelax[t]==1) 
			{
				opl.setup[t].LB = setupRelax[t];
				opl.setup[t].UB = setupRelax[t];
				nBinary++;
			}
		}
		// All values are binary --> abort heuristic (Step 2)
			if (nBinary == opl.dataElements.NPeriods) 
			{
				writeln("All variables are binary!");
				if (cplex.solve()) 
				{
					writeln();
					writeln("Days of Production: " + opl.setup.solutionValue);
					writeln("Inventories: " + opl.inventory.solutionValue);
					writeln("Lot sizes: " + opl.Pquantity.solutionValue);
					writeln("Total cost: " + cplex.getObjValue());
				}
		abort = true;
		continue;
				}
				
	// Step 3-A: Determine a non-binary valued variable with the smallest distance to the next binary value 
			var minDistance = 1;
			var minIndex = 0;
			for (var t = 1; t <= opl.dataElements.NPeriods; t++) 
			{
				if (setupRelax[t]!=0 && setupRelax[t]<=0.5 && setupRelax[t]<minDistance) 
				{
					minDistance = setupRelax[t];
					minIndex = t;
				} 
				else if (setupRelax[t]!=1 && setupRelax[t]>0.5 && (1-setupRelax[t])<minDistance) 
				{
					minDistance = 1 - setupRelax[t];
					minIndex = t;
				}
			}
	// Step 3-B: Fix the determined variable with the smallest distance to the closest binary value 
				if (setupRelax[minIndex] < 0.5) 
				{
					opl.setup[minIndex].LB = 0;
					opl.setup[minIndex].UB = 0;
					writeln("setup[" , minIndex , "] fixed to 0.");
				} 
				else 
				{
					opl.setup[minIndex].LB = 1;
					opl.setup[minIndex].UB = 1;
					writeln("setup[" , minIndex , "] fixed to 1.");
				}
				writeln();
		
	// Step 4: Solve the LP relaxation again 
			if (cplex.solve()) 
			{
				writeln("setup = " + opl.setup.solutionValue);

				for (var i = 1; i <= opl.dataElements.NPeriods; i++) 
				{
					setupRelax[i] = opl.setup[i].solutionValue;
				}
			}

	// Solution of the relaxed model is infeasible 
				else 
				{
				writeln("Heuristic solution is infeasible!");
				abort = true;
				}
		}
	}
}