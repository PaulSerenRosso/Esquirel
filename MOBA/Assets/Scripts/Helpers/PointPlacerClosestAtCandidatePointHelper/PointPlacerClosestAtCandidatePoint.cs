using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

namespace PointPlacerClosestAtCandidatePointHelper
{
    [Serializable]
    public class PointPlacerClosestAtCandidatePoint
    {
        private List<PointPlacerDistanceClosestAtCandidatePointAvoider> distanceAvoiders;
        

        public PointPlacerClosestAtCandidatePoint(
            List<PointPlacerDistanceClosestAtCandidatePointAvoider> distanceAvoiders
            )
        {
            this.distanceAvoiders = distanceAvoiders;
        }

        public List<Vector3> candidatesPoint = new List<Vector3>();

        private float minRadiusBetweenTwoIteration;
        private Vector3 referencePoint;
        private float minRadiusWithNoAvoiderNeededToPlacePoint;
        private float minRadiusWithNoCollisionNeededToPlacePoint;
        int currentCircularDetectorCount;
        float minRadiusNeededToPlacePointDouble;
        float minRadiusNeededToPlacePointDoubleSquared;
        private PointPlacerDistanceClosestAtCandidatePointAvoider currentAvoider = null;
        private PointPlacerClosestAtCandidatePointSO so;
        private GlobalDelegates.OneParameterWithBoolReturnDelegate<Vector3> isValidedCondition;

        public (Vector3 point, bool isValided) PlacePointWithDistanceAvoider(Vector3 referencePoint,
            float minRadiusWithNoAvoiderNeededToPlacePoint,
            float minRadiusWithNoCollisionNeededToPlacePoint, PointPlacerClosestAtCandidatePointSO so,
            PointPlacerDistanceClosestAtCandidatePointAvoider currentAvoider = null)
        {
            this.isValidedCondition = IsValidedWithDistanceAvoider;
            return PlacePoint(referencePoint, minRadiusWithNoAvoiderNeededToPlacePoint,
                minRadiusWithNoCollisionNeededToPlacePoint,so,  currentAvoider);
        }
        
        public (Vector3 point, bool isValided) PlacePointWithoutDistanceAvoider(Vector3 referencePoint,
            float minRadiusWithNoCollisionNeededToPlacePoint, PointPlacerClosestAtCandidatePointSO so)
        {
            this.isValidedCondition = IsValidedWithoutAvoider;
            return PlacePoint(referencePoint, minRadiusWithNoAvoiderNeededToPlacePoint,
                minRadiusWithNoCollisionNeededToPlacePoint,so);
        }

        private (Vector3 point, bool isValided) PlacePoint(Vector3 referencePoint,
            float minRadiusWithNoAvoiderNeededToPlacePoint, float minRadiusWithNoCollisionNeededToPlacePoint,PointPlacerClosestAtCandidatePointSO so,
            PointPlacerDistanceClosestAtCandidatePointAvoider currentAvoider = null)
        {
            SetUp(referencePoint, minRadiusWithNoAvoiderNeededToPlacePoint, minRadiusWithNoCollisionNeededToPlacePoint, so,
                currentAvoider);

            if (CheckReferencePointIsValided())
            {
                Debug.Log("reference Point");
                return (referencePoint, true);
            }

            SetUpCandidatePointIteration();

            return FindCandidatePointValided();
        }


        private void SetUpCandidatePointIteration()
        {
            currentCircularDetectorCount = 0;
            minRadiusNeededToPlacePointDouble = minRadiusBetweenTwoIteration * 2;
            minRadiusNeededToPlacePointDoubleSquared =
                minRadiusNeededToPlacePointDouble * minRadiusNeededToPlacePointDouble;
        }

        private void SetUp(Vector3 referencePoint, float minRadiusWithNoAvoiderNeededToPlacePoint,
            float minRadiusWithNoCollisionNeededToPlacePoint,PointPlacerClosestAtCandidatePointSO so,
            PointPlacerDistanceClosestAtCandidatePointAvoider currentAvoider)
        {
            this.referencePoint = referencePoint;
            this.minRadiusWithNoAvoiderNeededToPlacePoint = minRadiusWithNoAvoiderNeededToPlacePoint;
            this.minRadiusWithNoCollisionNeededToPlacePoint = minRadiusWithNoCollisionNeededToPlacePoint;
            this.so = so;
            this.currentAvoider = currentAvoider;
            candidatesPoint.Clear();

            minRadiusBetweenTwoIteration = Mathf.Min(minRadiusWithNoAvoiderNeededToPlacePoint,
                minRadiusWithNoCollisionNeededToPlacePoint);
        }

        private PointPlacerClosestAtCandidatePointCircularDetector currentCircularDetector;
        private int circularDetectorIterationFinalCount;
        private float angleBetweenTwoCandidatePos;
        private List<Vector3> allDirections = new List<Vector3>();

        private (Vector3 candidatePoint, bool isFoundPoint) FindCandidatePointValided()
        {
            while (true)
            {
                GetAngleBetwwenTwoCandidatePosition();
                SetAllDirections();

                if (CheckCandidatePointsAreValided(out var findCandidatePointValided))
                    return (findCandidatePointValided, true);
                ;

                currentCircularDetectorCount++;
                if (currentCircularDetectorCount == so.circularDetectors.Count)
                {
                
                    Debug.Log("false detection");
                    return (Vector3.zero, false);
                }
            }
        }

        private bool CheckCandidatePointsAreValided(out Vector3 findCandidatePointValided)
        {
            for (int i = 0; i < circularDetectorIterationFinalCount; i++)
            {
                int randomDirectionIndex = Random.Range(0, allDirections.Count);
                Vector3 candidatePoint = referencePoint +
                                         allDirections[randomDirectionIndex] * currentCircularDetectorRadius;
                candidatesPoint.Add(candidatePoint);
                if (isValidedCondition(candidatePoint))
                {
                    {
                        findCandidatePointValided = candidatePoint;
                        return true;
                    }
                }

                allDirections.Remove(allDirections[randomDirectionIndex]);
            }

            findCandidatePointValided = Vector3.zero;
            return false;
        }

        private void SetAllDirections()
        {
            allDirections.Clear();
            for (var (i, currentAngle) = (0, (float)0);
                 i < circularDetectorIterationFinalCount;
                 i++, currentAngle += angleBetweenTwoCandidatePos)
            {
                allDirections.Add(new Vector3(Mathf.Cos(currentAngle), referencePoint.y, Mathf.Sin(currentAngle))
                    .normalized);
            }
        }

        private float currentCircularDetectorRadius;

        private void GetAngleBetwwenTwoCandidatePosition()
        {
            currentCircularDetector =
                so.circularDetectors[currentCircularDetectorCount];
            currentCircularDetectorRadius =
                minRadiusBetweenTwoIteration * currentCircularDetector.factorRadius;
            float currentCircularDetectorRadiusSquared =
                currentCircularDetectorRadius * currentCircularDetectorRadius;
            float referenceMinAngleBetweenTwoCandidatePos =
                Mathf.Acos((minRadiusNeededToPlacePointDoubleSquared - 2 * currentCircularDetectorRadiusSquared) /
                           (-2 * currentCircularDetectorRadiusSquared));
            int circularDetectorIterationReferenceCount =
                (int)(2 * Mathf.PI / referenceMinAngleBetweenTwoCandidatePos);
            circularDetectorIterationFinalCount = (int)(circularDetectorIterationReferenceCount *
                                                        currentCircularDetector.precisionCircleDetector);
            angleBetweenTwoCandidatePos = referenceMinAngleBetweenTwoCandidatePos /
                                          currentCircularDetector.precisionCircleDetector;
        }

        private bool CheckReferencePointIsValided()
        {
            candidatesPoint.Add(referencePoint);
            if (isValidedCondition(referencePoint))
            {
                return true;
            }

            return false;
        }

        bool IsValidedWithDistanceAvoider(Vector3 point)
        {
            if (IsNotCollide(point))
            {
                if (!IsOutOfAvoidersRange(point)) return false;
                return true;
            }

            return false;
        }

        bool IsValidedWithoutAvoider(Vector3 point)
        {
            if (IsNotCollide(point))
            {
                return true;
            }

            return false;
        }

        private bool IsOutOfAvoidersRange(Vector3 point)
        {
            for (int i = 0; i < distanceAvoiders.Count; i++)
            {
                if (distanceAvoiders[i] == currentAvoider)
                {
                    Debug.Log("je suis lu");
                    continue;
                }

               
                if (distanceAvoiders[i].IsInAvoidanceRange(point, minRadiusWithNoAvoiderNeededToPlacePoint))
                    return false;
            }

            return true;
        }

        bool IsNotCollide(Vector3 point)
        {
            if (!Physics.CheckSphere(point, minRadiusWithNoCollisionNeededToPlacePoint, so.layerMaskColliderAvoider,
                    QueryTriggerInteraction.Ignore))
            {
                return true;
            }

            return false;
        }
    }
}