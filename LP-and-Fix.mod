/*********************************************
 * OPL 20.1.0.0 Model
 * Author: Dr. Hakeem-Ur-Rehman
 * Creation Date: 08-Aug-2023 at 4:55:44 pm
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
				if (opl.setup[t].solutionValue==0 || opl.setup[t].solutionValue==1) 
					{
						opl2.setup[t].LB = opl.setup[t].solutionValue;
						opl2.setup[t].UB = opl.setup[t].solutionValue;
					}
				}
	
		//Solve the second model instance
		if (cplex2.solve()) 
			{
			writeln("LP-and-Fix-Heuristic");
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
 