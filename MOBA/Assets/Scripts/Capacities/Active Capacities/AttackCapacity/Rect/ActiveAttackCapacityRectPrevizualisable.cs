using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

public class ActiveAttackCapacityRectPrevizualisable : ActiveAttackCapacityPrevizualisable
{
   public override void UpdatePrevisualisation(ActiveAttackWithPrevisualisableCapacity activeAttackCapacity) 
   {
      ActiveAttackRectCapacitySO activeAttackRectCapacitySo =(ActiveAttackRectCapacitySO) activeAttackCapacity.so;
      ActiveAttackRectCapacity attackRectCapacity = (ActiveAttackRectCapacity)activeAttackCapacity;
      previsualisation.transform.SetGlobalScale(new Coordinate[]
         { new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.width), new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.height) });
   }
   
   

  
}
