using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/Sword Attack", fileName = "Sword Attack")]
public class SwordAttackSO : ActiveAttackRectCapacitySO
{
    public override Type AssociatedType()
    {
        return typeof(SwordAttack);
    }
}
}
