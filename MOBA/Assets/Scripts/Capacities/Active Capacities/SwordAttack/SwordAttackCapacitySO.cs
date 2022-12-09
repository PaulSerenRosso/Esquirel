using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
public class SwordAttackCapacitySO : ActiveCapacitySO
{
    public override Type AssociatedType()
    {
        return typeof(AttackCapacity);
    }
}
}
