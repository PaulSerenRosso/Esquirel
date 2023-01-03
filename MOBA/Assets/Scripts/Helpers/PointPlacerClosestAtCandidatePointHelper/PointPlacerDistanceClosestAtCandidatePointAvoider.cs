using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PointPlacerClosestAtCandidatePointHelper
{
    [Serializable]
    public class PointPlacerDistanceClosestAtCandidatePointAvoider
    {
        public float SetAvoidanceDistance
        {
            set =>
                avoidanceDistance = value;
        }

        public Vector3 SetAvoiderPosition
        {
            set { avoiderPosition = value; }
        }

        private float avoidanceDistance;

        public Vector3 avoiderPosition;

        public bool IsInAvoidanceRange(Vector3 candidatePoint, float minRadiusForAvoiderNeededToPlacePoint)
        {
            Debug.Log(candidatePoint + "dir" + (candidatePoint - avoiderPosition) + "testdistance" +
                      Vector3.Distance(candidatePoint, avoiderPosition) + "distance" + avoidanceDistance +
                      " ce qui est donnée  " + minRadiusForAvoiderNeededToPlacePoint);
            if (Vector3.Distance(candidatePoint, avoiderPosition) <=
               avoidanceDistance + minRadiusForAvoiderNeededToPlacePoint)
                return true;
            return false;
        }

        public void AddToPointPlacerClosestAtCandidatePointLauncher(PointPlacerClosestAtCandidatePointLauncher launcher)
            => launcher.AddPointPlacerClosestAtCandidatePointDistanceAvoider(this);

        public void RemoveToPointPlacerClosestAtCandidatePointLauncher(
            PointPlacerClosestAtCandidatePointLauncher launcher)
            => launcher.AddPointPlacerClosestAtCandidatePointDistanceAvoider(this);
    }
}