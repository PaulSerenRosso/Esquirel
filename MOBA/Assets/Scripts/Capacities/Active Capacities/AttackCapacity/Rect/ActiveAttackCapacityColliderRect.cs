using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
public class ActiveAttackCapacityColliderRect : ActiveAttackCapacityCollider
{
    public override void InitCapacityCollider(ActiveCapacity activeCapacity)
    {
        base.InitCapacityCollider(activeCapacity);
        ActiveAttackRectCapacitySO activeAttackRectCapacitySo = (ActiveAttackRectCapacitySO) CapacitySOCollectionManager.GetActiveCapacitySOByIndex(activeCapacity.indexOfSOInCollection);
       transform.SetGlobalScale(new Coordinate[]
            { new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.width), new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.height)});
    }
}
}
