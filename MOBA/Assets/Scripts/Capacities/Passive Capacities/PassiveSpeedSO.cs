using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/PassiveCapacitySO/PassiveSpeed", fileName = "PassiveSpeed")]
public class PassiveSpeedSO : PassiveCapacitySO
{
    public float speedFactor;
    public float time;
    public override bool TryAdded(Entity target)
    {
        if (target is IMoveable)
            return true;
        return false;
    }

    public override Type AssociatedType()
    {
        return typeof(PassiveSpeed);
    }
}
    
}
