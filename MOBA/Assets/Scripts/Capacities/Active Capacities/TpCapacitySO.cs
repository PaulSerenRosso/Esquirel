using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
    [CreateAssetMenu(menuName = "Capacity/ActiveCapacitySO/TpCapacity", fileName = "TpCapacitySO")]
    public class TpCapacitySO : ActiveCapacitySO
    {
        public GameObject previsualisableTPPrefab;
        public AnimationCurve tpObjectCurve;
        public float tpObjectCurveYPosition;
        public float tpObjectCurveTime;
        public GameObject tpObjectPrefab; 
        public float referenceRange;
        public override Type AssociatedType()
        {
            return typeof(TpCapacity);
        }
    }
}
