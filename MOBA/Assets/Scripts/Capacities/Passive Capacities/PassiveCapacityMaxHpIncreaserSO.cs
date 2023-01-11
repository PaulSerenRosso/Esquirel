using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
public class PassiveCapacityMaxHpIncreaserSO : PassiveCapacityAuraSO
{
    public List<float> rankedMaxHpFactors;
    public override Type AssociatedType()
    {
        return typeof(PassiveCapacityMaxHpIncreaser);
    }
}
}
