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
           
            ActiveAttackSlowAreaCapacity activeAttackSlowAreaCapacity = (ActiveAttackSlowAreaCapacity)activeCapacity;
            ActiveAttackSlowAreaCapacitySO activeAttackSlowAreaCapacitySo =
                (ActiveAttackSlowAreaCapacitySO)activeAttackSlowAreaCapacity.so;
            passiveSpeedSo = activeAttackSlowAreaCapacitySo.passiveSpeed;
            sphereCollider.radius = activeAttackSlowAreaCapacitySo.radiusArea/2;
        }

        public override void CollideWithEntity(Entity entityCollided)
        {
            base.CollideWithEntity(entityCollided);
            if (entityCollided.team != team)
            {
            entityCollided.RequestAddPassiveCapacity(passiveSpeedSo.indexInCollection);
            }
        }
    }
}