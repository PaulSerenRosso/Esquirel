using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PointPlacerClosestAtCandidatePointHelper
{
    [Serializable]
    public class PointPlacerClosestAtCandidatePointLauncher
    {
   
        public PointPlacerClosestAtCandidatePoint placer;


        void SetUpGameObjectPlacer() => placer = new PointPlacerClosestAtCandidatePoint(distanceAvoiders);


        public PointPlacerClosestAtCandidatePointLauncher()
        {
            SetUpGameObjectPlacer();
        }

        [SerializeField] private List<PointPlacerDistanceClosestAtCandidatePointAvoider> distanceAvoiders =
            new List<PointPlacerDistanceClosestAtCandidatePointAvoider>();

        public void AddPointPlacerClosestAtCandidatePointDistanceAvoider(
            PointPlacerDistanceClosestAtCandidatePointAvoider pointPlacerDistanceClosestAtCandidatePointAvoider)
        {
            distanceAvoiders.Add(pointPlacerDistanceClosestAtCandidatePointAvoider);
        }

        public void RemovePointPlacerClosestAtCandidatePointDistanceAvoider(
            PointPlacerDistanceClosestAtCandidatePointAvoider pointPlacerDistanceClosestAtCandidatePointAvoider)
        {
            distanceAvoiders.Remove(pointPlacerDistanceClosestAtCandidatePointAvoider);
        }


        public (Vector3 point, bool isValided) LaunchPlacePointClosestAtCandidatePointWithoutDistanceAvoider(Vector3 referencePoint,
             float minRadiusWithNoCollisionNeededToPlacePoint, PointPlacerClosestAtCandidatePointSO so) => placer.PlacePointWithoutDistanceAvoider(
            referencePoint, minRadiusWithNoCollisionNeededToPlacePoint, so);
        
        public (Vector3 point, bool isValided) LaunchPlacePointClosestAtCandidatePointWithDistanceAvoider(Vector3 referencePoint,
            float minRadiusWithNoAvoiderNeededToPlacePoint, float minRadiusWithNoCollisionNeededToPlacePoint, PointPlacerClosestAtCandidatePointSO so,
            PointPlacerDistanceClosestAtCandidatePointAvoider currentAvoider = null) => placer.PlacePointWithDistanceAvoider(
            referencePoint, minRadiusWithNoAvoiderNeededToPlacePoint, minRadiusWithNoCollisionNeededToPlacePoint, so,
            currentAvoider);
    }
}