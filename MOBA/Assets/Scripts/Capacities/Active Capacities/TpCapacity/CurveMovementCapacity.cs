using System.Collections;
using System.Collections.Generic;
using Entities.Champion;
using GameStates;
using Photon.Pun;
using PointPlacerClosestAtCandidatePointHelper;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.InputSystem;

namespace Entities.Capacities
{
    public class CurveMovementCapacity : ActiveCapacity
    {
        public CurveMovementCapacitySO curveMovementCapacitySo;
        public Champion.Champion champion;
        public float range;
        public Vector3 startPosition;
        public Vector3 endPosition;
        public CurveMovement curveObject;
        protected ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;


        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            return true;
        }

        protected void SearchEndPositionAvailable()
        {
            var pointPlacerResult =
                ChampionPlacerManager.instance.GetLauncher
                    .LaunchPlacePointClosestAtCandidatePointWithoutDistanceAvoider(endPosition, champion.agent.radius,
                        curveMovementCapacitySo.firstDetectionSo);
            if (pointPlacerResult.isValided)
            {
                endPosition = pointPlacerResult.point;
            }
            else
            {
                RaycastHit hit;
                Vector3 dir = endPosition - startPosition;
                if (Physics.Raycast(startPosition, dir.normalized, out hit, dir.magnitude,
                        curveMovementCapacitySo.firstDetectionLayerMask))
                {
                 endPosition=  ChampionPlacerManager.instance.GetLauncher
                        .LaunchPlacePointClosestAtCandidatePointWithDistanceAvoider(hit.point,
                            champion.pointPlacerDistanceAvoidance, champion.agent.radius, 
                            curveMovementCapacitySo.firstDetectionSo, champion.championPlacerDistanceAvoider.pointAvoider).point;
                }
            }
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] customParameters)
        {
            endPosition = (Vector3)customParameters[1];
            startPosition = (Vector3)customParameters[0];
            curveObject.LaunchStartCurveMovementRPC(startPosition, endPosition);
            base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
        }

        public override object[] GetCustomSyncParameters()
        {
            return new object[] { startPosition, endPosition };
        }

        public override void CancelCapacity()
        {
            activeCapacityAnimationLauncher.CancelAnimationTimer();
        }

      

        public override void EndCooldown()
        {
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
            base.EndCooldown();
        }


        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            curveMovementCapacitySo =
                (CurveMovementCapacitySO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            range = curveMovementCapacitySo.referenceRange;
        }
    }
}