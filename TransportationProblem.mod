/*********************************************
 * OPL 12.10.0.0 Model
 * Author: Hakeem-Ur-Rehman
 * Creation Date: Aug 30, 2020 at 5:07:12 PM
 *********************************************/
//INDEX
{int} branches ={1,2,3,4};
{int} warehouses= {1,2,3,4};

//DATA
int demand[warehouses]= [70,30,75,55];
int supply[branches]= [35,50,80,65];
int tcost[branches][warehouses]= [[10,7,6,4],[8,8,5,7],[4,3,6,9],[7,5,4,3]];

//DECISION VARIBALES
dvar float+ amounttransp[branches][warehouses];

//OBJ.F
dexpr float transpcost= sum(i in branches, j in warehouses) amounttransp[i][j]*tcost[i][j];

//MODEL
minimize transpcost;

subject to{
SUPPLYCONS:
forall(i in warehouses)
  sum(j in branches) amounttransp[i][j]== supply[i];

  DEMANDCONS:
  forall(j in branches)
    sum(i in warehouses) amounttransp[i][j]== demand[j];   
}
 