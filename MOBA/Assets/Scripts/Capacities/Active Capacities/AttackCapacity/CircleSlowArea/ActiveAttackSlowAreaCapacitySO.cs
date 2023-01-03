using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/ActiveAttackSlowArea", fileName = "ActiveAttackSlowAreaCapacitySO")]  
public class ActiveAttackSlowAreaCapacitySO : ActiveAttackCapacitySO
{
    public PassiveSpeedSO passiveSpeed;
    public float radiusArea;
    public override Type AssociatedType()
    {
        return typeof(ActiveAttackSlowAreaCapacity);
    }
}

}
