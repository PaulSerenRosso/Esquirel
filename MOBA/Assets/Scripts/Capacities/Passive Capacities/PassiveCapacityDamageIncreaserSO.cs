using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/PassiveCapacitySO/DamageIncreaserSO", fileName = "DamageIncreaserSO")]
public class PassiveCapacityDamageIncreaserSO : PassiveCapacityAuraSO
{
    public ActiveAttackCapacitySO[] attackCapacitySoToIncreaseDamage;
    public List<float> rankedDamageFactors;
    public override Type AssociatedType()
    {
        return typeof(PassiveCapacityDamageIncreaser);
    }

    private void OnValidate()
    {
        maxCount = rankedDamageFactors.Count;
    }
}
    
}
