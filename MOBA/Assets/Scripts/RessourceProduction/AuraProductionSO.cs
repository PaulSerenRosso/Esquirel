using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace RessourceProduction
{
  [CreateAssetMenu(menuName = "RessourceProduction/AuraProductionSO", fileName = "AuraProductionSO")]
public class AuraProductionSO : RessourceProductionSO<int>
{
  public PassiveCapacityAuraSO[] passiveCapacitySo;
  
  
}
}
