using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace  Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/BoostSpeed", fileName = "BoostSpeed")]
public class ActiveBoostSpeedSO : ActiveCapacitySO
{
    public PassiveSpeedSO passiveSpeedSo;
    public override Type AssociatedType()
    {
        return typeof(ActiveBoostSpeed);
    }
}
}

