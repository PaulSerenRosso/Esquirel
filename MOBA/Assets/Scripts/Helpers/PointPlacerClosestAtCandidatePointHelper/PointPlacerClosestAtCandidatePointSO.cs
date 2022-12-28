using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PointPlacerClosestAtCandidatePointHelper
{
[CreateAssetMenu(menuName = "PointPlacerClosestAtCandidatePointHelper", fileName = "PointPlacerClosestAtCandidatePointSO")]
    public class PointPlacerClosestAtCandidatePointSO : ScriptableObject
    {
        public List<PointPlacerClosestAtCandidatePointCircularDetector> circularDetectors;
        public LayerMask layerMaskColliderAvoider;

   
    }
}