using System.Collections;
using System.Collections.Generic;
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
        public Vector3 startPosition;
        public Vector3 endPosition;
        protected CurveMovement curveObject;
        protected ActiveCapacityAnimationLauncher activeCapacityAnimationLauncher;
        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (onCooldown) return false;
            activeCapacityAnimationLauncher.InitiateAnimationTimer();
            return true;
        }

        protected void SearchEndPositionAvailable()
        {
            NavMeshHit navMeshHit;
            if (NavMesh.SamplePosition(endPosition, out navMeshHit, range, 1))
            {
                endPosition = navMeshHit.position;
                curveObject.RequestSetupRPC((byte)champion.activeCapacities.IndexOf(this), caster.entityIndex, endPosition);
            }
            else
            {
                Debug.LogError("don't find endPosition");
            }
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
            curveMovementCapacitySo = (CurveMovementCapacitySO) CapacitySOCollectionManager.GetActiveCapacitySOByIndex(soIndex);
            champion = (Champion.Champion) caster;
            range = curveMovementCapacitySo.referenceRange;
            
                activeCapacityAnimationLauncher = new ActiveCapacityAnimationLauncher();
                activeCapacityAnimationLauncher.Setup(curveMovementCapacitySo.activeCapacityAnimationLauncherInfo,champion);
        }

}
    
}
