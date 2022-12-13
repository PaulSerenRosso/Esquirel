using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/Tail Attack", fileName = "Tail Attack")]
    public class TailAttackSO : ActiveAttackRectCapacitySO
{
    public override Type AssociatedType()
    {
        return typeof(TailAttack);
    }
}
}
