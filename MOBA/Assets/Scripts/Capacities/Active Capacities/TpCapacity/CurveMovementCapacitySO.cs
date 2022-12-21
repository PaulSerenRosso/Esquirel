using System;
using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;
using UnityEngine.Serialization;

namespace Entities.Capacities
{
    public abstract class CurveMovementCapacitySO : ActiveCapacitySO
    {
        public AnimationCurve curve;
        public float curveMovementMaxYPosition;
        public float curveMovementTime;
        public float referenceRange;
        public ActiveCapacityAnimationLauncherInfo activeCapacityAnimationLauncherInfo;
    }
}