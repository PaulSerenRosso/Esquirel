using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities{
public class CatapultCapacity : CurveMovementCapacity
{
   public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
   {
      return base.TryCast(targetsEntityIndexes, targetPositions);
   }
   
}

}
