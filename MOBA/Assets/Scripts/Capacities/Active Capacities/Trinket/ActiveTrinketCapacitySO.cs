using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/TrinketSO", fileName = "ActiveTrinketSO")]
public class ActiveTrinketCapacitySO : ActiveCapacitySO
{
    public Trinket trinketPrefab;
    public float trinketDuration;
    public float trinketViewRadius;
    public float trinketViewAngle;
    public float trinketDetectionDistance;
    public LayerMask trinketDetectionMask;
    public override Type AssociatedType()
    {
        return typeof(ActiveTrinketCapacity);
    }
}
    
}
