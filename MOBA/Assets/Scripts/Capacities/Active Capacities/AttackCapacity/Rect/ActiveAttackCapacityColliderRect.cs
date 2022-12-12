using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
public class ActiveAttackCapacityColliderRect : ActiveAttackCapacityCollider
{
    [SerializeField] private BoxCollider boxCollider;
    public override void InitCapacityCollider(ActiveCapacity activeCapacity)
    {
        base.InitCapacityCollider(activeCapacity);
        ActiveAttackRectCapacity activeAttackRectCapacity =(ActiveAttackRectCapacity) activeCapacity;
        ActiveAttackRectCapacitySO activeAttackRectCapacitySo = (ActiveAttackRectCapacitySO) activeAttackRectCapacity.so;
       transform.SetGlobalScale(new Coordinate[]
            { new Coordinate(CoordinateType.X, activeAttackRectCapacitySo.width), new Coordinate(CoordinateType.Z, activeAttackRectCapacitySo.height)});
       var boxColliderCenter = boxCollider.center;
       boxColliderCenter.z = activeAttackRectCapacitySo.height / 2;
       boxCollider.center = boxColliderCenter;
    }
}
}
