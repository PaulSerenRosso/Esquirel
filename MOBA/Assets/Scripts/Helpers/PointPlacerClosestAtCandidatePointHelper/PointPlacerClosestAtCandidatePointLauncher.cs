using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace PointPlacerClosestAtCandidatePointHelper
{
    [Serializable]
    public class PointPlacerClosestAtCandidatePointLauncher
    {
        private PointPlacerClosestAtCandidatePointSO so;
        public PointPlacerClosestAtCandidatePoint placer;


        void SetUpGameObjectPlacer() => placer = new PointPlacerClosestAtCandidatePoint(distanceAvoiders, so);


        public PointPlacerClosestAtCandidatePointLauncher(PointPlacerClosestAtCandidatePointSO so)
        {
            this.so = so;
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
            float minRadiusWithNoAvoiderNeededToPlacePoint, float minRadiusWithNoCollisionNeededToPlacePoint) => placer.PlacePointWithDistanceAvoider(
            referencePoint, minRadiusWithNoAvoiderNeededToPlacePoint, minRadiusWithNoCollisionNeededToPlacePoint);
        
        public (Vector3 point, bool isValided) LaunchPlacePointClosestAtCandidatePointWithDistanceAvoider(Vector3 referencePoint,
            float minRadiusWithNoAvoiderNeededToPlacePoint, float minRadiusWithNoCollisionNeededToPlacePoint,
            PointPlacerDistanceClosestAtCandidatePointAvoider currentAvoider = null) => placer.PlacePointWithDistanceAvoider(
            referencePoint, minRadiusWithNoAvoiderNeededToPlacePoint, minRadiusWithNoCollisionNeededToPlacePoint,
            currentAvoider);
    }
}