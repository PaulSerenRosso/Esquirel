using System.Collections;
using System.Collections.Generic;
using Controllers.Inputs;
using Photon.Pun;
using Unity.Mathematics;
using UnityEngine;

namespace Entities.Capacities
{
    public class JumpWithSlowCapacity : CurveMovementWithPrevisualisableCapacity
    {
        private JumpMovement _jumpMovement;

        public ActiveAttackWithColliderSlowAreaCapacity ActiveAttackWithColliderSlowAreaCapacity;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (base.TryCast(targetsEntityIndexes, targetPositions) )
            {
                return true;
            }

            return false;
        }

      

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            curveObject = champion.gameObject.AddComponent<JumpWithSlowCapacityMovement>();
            curveObject.renderer = champion.rotateParent;
            _jumpMovement = (JumpWithSlowCapacityMovement)curveObject;
            _jumpMovement.UIRoot = champion.uiTransform;
            JumpWithSlowCapacityCapacitySO jumpSO =(JumpWithSlowCapacityCapacitySO) curveMovementCapacitySo;
            _jumpMovement.trail = Object.Instantiate(jumpSO.jumpTrail.gameObject, champion.rotateParent).GetComponent<TrailRenderer>();
            champion.meshRenderersToShow.Add(_jumpMovement.trail);
            champion.meshRenderersToShowAlpha.Add(1);
            curveObject.endCurveEvent += InitiateCooldown;
            for (int i = 0; i < champion.activeCapacities.Count; i++)
            {
                if (champion.activeCapacities[i] is ActiveAttackWithColliderSlowAreaCapacity)
                {
                    ActiveAttackWithColliderSlowAreaCapacity = (ActiveAttackWithColliderSlowAreaCapacity)champion.activeCapacities[i];
                    break;
                }
            }
//            Debug.Log( (byte)champion.activeCapacities.IndexOf(this)+ "casterindex" + caster.entityIndex + "caster " + caster);
            curveObject.LaunchSetUpRPC((byte)champion.activeCapacities.IndexOf(this), caster.entityIndex);
        }
      
    }
}