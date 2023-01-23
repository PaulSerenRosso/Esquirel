using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
    public class ActiveAttackSlowAreaCapacityCollider : ActiveAttackCapacityCollider
    {
        private PassiveSpeedSO passiveSpeedSo;

        [SerializeField] private SphereCollider sphereCollider;
        
        public override void InitCapacityCollider(ActiveCapacity activeCapacity)
        {
            base.InitCapacityCollider(activeCapacity);
           
            ActiveAttackWithColliderSlowAreaCapacity activeAttackWithColliderSlowAreaCapacity = (ActiveAttackWithColliderSlowAreaCapacity)activeCapacity;
            ActiveAttackWithColliderSlowAreaCapacitySO activeAttackWithColliderSlowAreaCapacitySo =
                (ActiveAttackWithColliderSlowAreaCapacitySO)activeAttackWithColliderSlowAreaCapacity.so;
            passiveSpeedSo = activeAttackWithColliderSlowAreaCapacitySo.passiveSpeed;
            sphereCollider.radius = activeAttackWithColliderSlowAreaCapacitySo.radiusArea/2;
        }

        public override void CollideWithEntity(Entity entityCollided)
        {
            if (entityCollided.team != team)
            {
                Debug.Log("bonsoir je test la collision");
            entityCollided.RequestAddPassiveCapacity(passiveSpeedSo.indexInCollection);
            }
            base.CollideWithEntity(entityCollided);
        }
    }
}