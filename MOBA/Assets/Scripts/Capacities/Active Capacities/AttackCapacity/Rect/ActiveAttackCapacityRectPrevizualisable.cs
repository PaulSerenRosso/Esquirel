using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

public class ActiveAttackCapacityRectPrevizualisable : ActiveAttackCapacityPrevizualisable
{
   public override void UpdatePrevisualisation(ActiveAttackWithPrevisualisableCapacity activeAttackCapacity) 
   {
      ActiveAttackRectCapacitySO activeAttackRectCapacitySo =(ActiveAttackRectCapacitySO) activeAttackCapacity.so;
   //   ActiveAttackre activeAttackCapacity
      transform.position += activeAttackCapacity.champion.rotateParent.forward*activeAttackCapacity.so.offsetAttack;
      previsualisation.transform.SetGlobalScale(new Coordinate[]
         { new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.height), new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.width) });
   }

  
}
