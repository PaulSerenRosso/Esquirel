using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveTrinketSO/Active Trinket", fileName = "ActiveTrinketSO")]
public class ActiveTrinketCapacitySO : ActiveCapacitySO
{
    public float toleranceNavmeshDetection;
    public Trinket trinketPrefab;
    public override Type AssociatedType()
    {
        return typeof(ActiveTrinketCapacity);
    }
}
    
}
