
// P-Median Probelm
main{
	// Generating & Solving initial model
	thisOplModel.generate(); // Generating the current model instance
		if (cplex.solve())
		{
		var ofile = new IloOplOutputFile("E:/4. MS-Industrial Engineering & Management/1. Advanced Operations Research (Session 2019-2021)/AOR (Lab)/3. P-Median-Problem/Answer.txt");
  		ofile.writeln(thisOplModel.printSolution());
  		ofile.writeln("Solving CPU Elapsed Time  in (Seconds): ", cplex.getCplexTime());
  		ofile.close();
		var obj = cplex.getObjValue();
		writeln("The Value of the Objective Function Value is (Total Weighted Distance): ", obj);
		writeln("Solving CPU Elapsed Time  in (Seconds): ", cplex.getCplexTime()); 
		thisOplModel.postProcess(); 
		}
	else {
			writeln("No Solution");	
		 } 
	}
	
// indicies
{string} Warehouses =...;  
{string} Customers =...;  

// Parameters and Data
int MaxWarehousesP =...;  
float Demand[Customers] =...;  
float Distance[Warehouses][Customers]=...;  

// Decision Variables
dvar boolean Open[Warehouses];  
dvar boolean Assign[Warehouses][Customers];  

// Model 

// Total demand weighted distance
minimize  sum(w in Warehouses, c in Customers) Distance[w][c]*Demand[c]*Assign[w][c]; 
    
subject to{

  forall ( c in Customers) 
    EachCustomersDemandMustBeMet:
    	sum( w in Warehouses ) Assign[w][c]==1;	
  
    UseMaximum_P_Warehouses:
  	sum(w in Warehouses) Open[w]==MaxWarehousesP;
  
    forall (w in Warehouses, c in Customers)
    CannotAssignCustomertoWH_UnlessItIsOpen:
      Assign[w][c] <= Open[w];
}