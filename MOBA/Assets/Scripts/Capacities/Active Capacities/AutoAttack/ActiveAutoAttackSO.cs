using System;
using Entities.Capacities;
using UnityEngine;

[CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/Auto Attack", fileName = "AutoAttackSO")]
public class ActiveAutoAttackSO : ActiveAttackCapacitySO
{
    public float maxRange;
    public override Type AssociatedType()
    {
        return typeof(ActiveAutoAttack);
    }
}
