/*********************************************
 * OPL 12.8.0.0 Model
 * Author: Hakeem-ur-Rehman
 * Creation Date: 02-Dec-2019 at 2:15:03 pm
 *********************************************/
// Define "dvar = Decision Variables""
dvar float+ x; // "float+" means real number for continuous case
dvar float+ y;

// Define Expersion "objective function"
dexpr float cost = 0.12*x+0.15*y; //"dexpr = Define expersion"

// Model
minimize cost;
subject to {

	Cons01:
	60*x+60*y>=300;
	
	Cons02:
	12*x+6*y>=36;
	
	Cons03:
	10*x+30*y>=90;
}

// Post Processing
execute {
  	if(cplex.getCplexStatus()==1){ // Calling the function "getCplexStatus()" equal "1" means  
                                         // if problem have optimum solution
	writeln("Reduced cost of 'x'=",x.reducedCost);
	writeln("Reduced cost of 'y'=",y.reducedCost);
	writeln("Dual of Constrain-1 is = ",Cons01.dual);
	writeln("Dual of Constrain-2 is = ",Cons02.dual);
	writeln("Dual of Constrain-3 is = ",Cons03.dual);	
	}else{
	writeln("Error: Solution not found");	
	}
}

 