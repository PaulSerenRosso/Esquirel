using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
public class ChampionCapacityCurveMovement : CurveMovement
{
 
   public override void SetUp(byte capacityIndex, int championIndex)
   {
      champion = (Champion.Champion)EntityCollectionManager.GetEntityByIndex(championIndex);
      this.curveMovementCapacity = (CurveMovementCapacity)champion.activeCapacities[capacityIndex];
      this.curveCapacitySo = curveMovementCapacity.curveMovementCapacitySo;
      base.SetUp(capacityIndex, championIndex);
      
   }
}
    
}
