using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    public  class ActiveAttackRectCapacitySO : ActiveAttackWithPrevisualisableSO
{
    public float height;
    public float width;
    public override Type AssociatedType()
    {
        return typeof(ActiveAttackRectCapacity);
    }
}
}
