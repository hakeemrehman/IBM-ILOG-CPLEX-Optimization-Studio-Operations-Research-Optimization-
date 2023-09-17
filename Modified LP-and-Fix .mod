/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Dr. Hakeem-Ur-Rehman
 * Creation Date: 08-Aug-2023 at 5:22:38 pm
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

		if (cplex.solve()) // Relaxed model is now solved
		{
		  	// Create second model instance with its own CPLEX engine for fixing the binary variable values
		  	var cplex2 = new IloCplex();
		  	var opl2 = new IloOplModel(def, cplex2);
		  	opl2.addDataSource(data);
		  	opl2.generate();
		  	
		  	//Fix the binary variable values
			for (var t = 1; t <= opl.dataElements.NPeriods; t++) 
				{
				if (opl.setup[t].solutionValue==0) 
					{
						opl2.setup[t].LB = 0;
						opl2.setup[t].UB = 0;
					}
				else if (opl.setup[t].solutionValue > 0.5) 
					{
				  		opl2.setup[t].LB = 1;
						opl2.setup[t].UB = 1;
					}	
				}
	
		//Solve the second model instance
		if (cplex2.solve()) 
			{
			writeln("Modified LP-and-Fix-Heuristic");
			writeln();
			writeln("Days of Production: " , opl2.setup.solutionValue);
			writeln("Inventories: " , opl2.inventory.solutionValue);
			writeln("Lot sizes: " , opl2.Pquantity.solutionValue);
			writeln("Total cost: " , cplex2.getObjValue());
 			}
}
else {
  		writeln("No solution found!");
	 }
}
 