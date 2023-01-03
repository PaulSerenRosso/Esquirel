using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using PointPlacerClosestAtCandidatePointHelper;
using UnityEngine;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
    public abstract class CurveMovementCapacitySO : ActiveCapacitySO
    {
        public AnimationCurve heightJumpCurve;
        public AnimationCurve widthJumpCurve;
        public float curveMovementMaxYPosition;
        public float curveMovementTime;
        public float referenceRange;
        public ActiveCapacityAnimationLauncherInfo activeCapacityAnimationLauncherInfo;
        public PointPlacerClosestAtCandidatePointSO firstDetectionSo;
        public PointPlacerClosestAtCandidatePointSO secondDetectionSo;
        public LayerMask firstDetectionLayerMask;
    }
}