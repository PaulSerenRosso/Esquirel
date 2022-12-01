using System;
using Entities.Capacities;
using UnityEngine;

[CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/Auto Attack", fileName = "new Auto Attack")]
public class ActiveAutoAttackSO : ActiveCapacitySO
{
    public float maxRange;
    public float delayWithinAttack;
    public Color color;
    public float damage;

    
    public override Type AssociatedType()
    {
        return typeof(ActiveAutoAttack);
    }
}
