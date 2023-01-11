using System;
using System.Collections;
using System.Collections.Generic;

using UnityEngine;

namespace Entities.Capacities
{
public class PassiveCapacityDamageIncreaserSO : PassiveCapacityAuraSO
{
    public ActiveAttackCapacitySO attackCapacitySoToIncreaseDamage;
    public List<float> rankedDamageFactors;
    public override Type AssociatedType()
    {
        return typeof(PassiveCapacityDamageIncreaser);
    }
}
    
}
