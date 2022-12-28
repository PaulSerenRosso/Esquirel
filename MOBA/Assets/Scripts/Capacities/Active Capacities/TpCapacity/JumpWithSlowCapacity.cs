using System.Collections;
using System.Collections.Generic;
using Controllers.Inputs;
using Photon.Pun;
using UnityEngine;

namespace Entities.Capacities
{
    public class JumpWithSlowCapacity : CurveMovementWithPrevisualisableCapacity
    {
        private JumpMovement _jumpMovement;

        public ActiveAttackSlowAreaCapacity activeAttackSlowAreaCapacity;

        public override bool TryCast(int[] targetsEntityIndexes, Vector3[] targetPositions)
        {
            if (base.TryCast(targetsEntityIndexes, targetPositions))
            {
                return true;
            }

            return false;
        }

        public override void SyncCapacity(int[] targetsEntityIndexes, Vector3[] targetPositions,
            params object[] customParameters)
        {
            base.SyncCapacity(targetsEntityIndexes, targetPositions, customParameters);
        }

        public override void SetUpActiveCapacity(byte soIndex, Entity caster)
        {
            base.SetUpActiveCapacity(soIndex, caster);
            curveObject = champion.gameObject.AddComponent<JumpWithSlowCapacityMovement>();
            curveObject.renderer = champion.rotateParent;
            _jumpMovement = (JumpWithSlowCapacityMovement)curveObject;
            _jumpMovement.UIRoot = champion.uiTransform;
            curveObject.endCurveEvent += InitiateCooldown;
            for (int i = 0; i < champion.activeCapacities.Count; i++)
            {
                if (champion.activeCapacities[i] is ActiveAttackSlowAreaCapacity)
                {
                    activeAttackSlowAreaCapacity = (ActiveAttackSlowAreaCapacity)champion.activeCapacities[i];

                    break;
                }
            }

            curveObject.LaunchSetUpRPC((byte)champion.activeCapacities.IndexOf(this), caster.entityIndex);
        }
    }
}