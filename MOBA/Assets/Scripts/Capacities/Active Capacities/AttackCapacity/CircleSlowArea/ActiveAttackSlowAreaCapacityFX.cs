using System.Collections;
using System.Collections.Generic;
using Entities.FogOfWar;
using UnityEngine;

namespace Entities.Capacities
{
    public class ActiveAttackSlowAreaCapacityFX : ActiveAttackCapacityFX
    {
        [SerializeField] protected GameObject fxObject;
        [SerializeField] private EntityFogOfWarColliderLinker fogCollider;

        public override void InitCapacityFX(int entityIndex, byte capacityIndex, Vector3 direction)
        {
            base.InitCapacityFX(entityIndex, capacityIndex, direction);
            ActiveAttackWithColliderSlowAreaCapacity activeAttackWithColliderSlowAreaCapacity =
                (ActiveAttackWithColliderSlowAreaCapacity)ActiveAttackCapacity;
            ActiveAttackWithColliderSlowAreaCapacitySo activeAttackWithColliderSlowAreaCapacitySo =
                (ActiveAttackWithColliderSlowAreaCapacitySo)activeAttackWithColliderSlowAreaCapacity.so;
            fxObject.transform.SetGlobalScale(new Vector3(1, 0, 1) * activeAttackWithColliderSlowAreaCapacitySo.radiusArea +
                                              Vector3.up * transform.lossyScale.y);
            fogCollider.transform.SetGlobalScale(Vector3.one*activeAttackWithColliderSlowAreaCapacitySo.radiusArea);
        }
    }
}