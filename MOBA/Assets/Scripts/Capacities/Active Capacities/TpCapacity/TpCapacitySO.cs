using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/TpCapacity", fileName = "TpCapacitySO")]
    public class TpCapacitySO : CurveMovementWithPrevisualisableCapacitySO
    {
        public Entity tpObjectPrefab;
        public float smokeDuration;
        public Entity smokePrefab;

        public override Type AssociatedType()
        {
            return typeof(TpCapacity);
        }
    }
}
