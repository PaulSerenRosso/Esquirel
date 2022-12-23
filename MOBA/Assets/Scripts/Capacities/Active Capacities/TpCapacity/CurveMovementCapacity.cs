using System.Collections;
using System.Collections.Generic;
using GameStates;
using Photon.Pun;
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
        public float toleranceDetection;
        public Vector3 startPosition;
        public Vector3 endPosition;
        public CurveMovement curveObject;
        protected ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;
        public Champion.Champion championOfPlayerWhoMakesSecondDetection;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            activeCapacityAnimationLauncher.InitiateAnimationTimer();
            return true;
        }

        protected void SearchEndPositionAvailable()
        {
            if(championOfPlayerWhoMakesSecondDetection != GameStateMachine.Instance.GetPlayerChampion()) return;
            NavMeshHit navMeshHit;
            if (NavMesh.SamplePosition(endPosition, out navMeshHit, toleranceDetection, 1))
            {
                endPosition = navMeshHit.position;
                curveObject.RequestStartCurveMovementRPC(endPosition);
            }
            else
            {
                NavMesh.Raycast(champion.transform.position, endPosition, out navMeshHit, 1);
                endPosition = navMeshHit.position;
            }
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions, params object[] customParameters)
        {
            endPosition = (Vector3)customParameters[0];
            SearchEndPositionAvailable();
            base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
        }

        public override object[] GetCustomSyncParameters()
        {
            return new object[] { endPosition };
        }

        public override void CancelCapacity()
        {
            activeCapacityAnimationLauncher.CancelAnimationTimer();
        }

        public override void InitiateCooldown()
        {
            base.InitiateCooldown();
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, true);
        }

        public override void EndCooldown()
        {
            champion.RequestToSetOnCooldownCapacity(indexOfSOInCollection, false);
            base.EndCooldown();
        }


        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            champion = (Champion.Champion)caster;
            if (PhotonNetwork.IsMasterClient)
                championOfPlayerWhoMakesSecondDetection = GameStateMachine.Instance.GetOtherPlayerChampion(champion);
            curveMovementCapacitySo =
                (CurveMovementCapacitySO)CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            range = curveMovementCapacitySo.referenceRange;
            activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
            activeCapacityAnimationLauncher.Setup(curveMovementCapacitySo.activeCapacityAnimationLauncherInfo,
                champion);
           toleranceDetection =curveMovementCapacitySo.toleranceFirstDetection;
        }
    }
}