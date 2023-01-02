using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/CatapultThrowingSO", fileName = "CatapultThrowingCapacitySO")]
public class CatapultThrowingCapacitySO : CurveMovementCapacitySO
{
    public override Type AssociatedType()
    {
       return typeof(CatapultThrowingCapacity);
    }
}

}
