using System;
using Entities.Capacities;
using UnityEngine;

[CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/Auto Attack", fileName = "AutoAttackSO")]
public class ActiveAutoAttackSO : ActiveAttackRectCapacitySO
{
    public float maxRange;
    public float rangeForDamage;
    public override Type AssociatedType()
    {
        return typeof(ActiveAutoAttack);
    }
}
