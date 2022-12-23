using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/JumpCapacity", fileName = "JumpCapacitySO")]   
public class JumpCapacitySO : CurveMovementWithPrevisualisableCapacitySO
{
    public override Type AssociatedType()
    {
        return typeof(JumpCapacity);
    }
}
}
