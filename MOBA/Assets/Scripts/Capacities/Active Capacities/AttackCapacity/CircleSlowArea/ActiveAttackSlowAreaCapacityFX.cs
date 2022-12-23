using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
    public class ActiveAttackSlowAreaCapacityFX : ActiveAttackCapacityFX
    {
        [SerializeField] protected GameObject fxObject;
        [SerializeField] private SphereCollider fogCollider;

        public override void InitCapacityFX(int entityIndex, byte capacityIndex)
        {
            base.InitCapacityFX(entityIndex, capacityIndex);
            ActiveAttackSlowAreaCapacity activeAttackSlowAreaCapacity =
                (ActiveAttackSlowAreaCapacity)activeAttackCapacity;
            ActiveAttackSlowAreaCapacitySO activeAttackSlowAreaCapacitySo =
                (ActiveAttackSlowAreaCapacitySO)activeAttackSlowAreaCapacity.so;
            fxObject.transform.SetGlobalScale(new Vector3(1, 0, 1) * activeAttackSlowAreaCapacitySo.radiusArea +
                                              Vector3.up * transform.lossyScale.y);
            fogCollider.radius = activeAttackSlowAreaCapacitySo.radiusArea/2;
        }
    }
}