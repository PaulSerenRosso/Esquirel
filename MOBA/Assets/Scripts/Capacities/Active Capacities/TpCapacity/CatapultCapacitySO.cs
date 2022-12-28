using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
public class CatapultCapacitySO : CurveMovementCapacitySO
{
    public override Type AssociatedType()
    {
        return typeof(CatapultCapacity);
    }
}
}
