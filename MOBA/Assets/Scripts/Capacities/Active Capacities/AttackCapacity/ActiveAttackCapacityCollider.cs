using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
    public class ActiveAttackCapacityCollider : ActiveCapacityCollider
    {
        public float damage;
        private ActiveAttackWithColliderCapacity activeAttackWithColliderCapacity;

        public override void CollideWithEntity(Entity entityCollided)
        {
          if(entityCollided == activeAttackWithColliderCapacity.champion) return;
          
            IActiveLifeable lifeable = (IActiveLifeable)entityCollided;
            if (lifeable != null)
            {
                if (entityCollided.team != team)
                    lifeable.DecreaseCurrentHpRPC(damage);
            }
            activeAttackWithColliderCapacity.impactFxTimerInfo.fxPos =
                entityCollided.entityCapacityCollider.GetCollider.ClosestPoint(transform.position);
            activeAttackWithColliderCapacity.impactFxTimerInfo.fxRotation = Quaternion.LookRotation(
                activeAttackWithColliderCapacity.impactFxTimerInfo.fxPos - transform.position, Vector3.up);
            activeAttackWithColliderCapacity.impactFxTimer.InitiateTimer();
        }

        public override void InitCapacityCollider(ActiveCapacity activeCapacity)
        {
            ActiveAttackWithColliderCapacitySO so = (ActiveAttackWithColliderCapacitySO)
                CapacitySOCollectionManager.GetActiveCapacitySOByIndex(activeCapacity.indexOfSOInCollection);
            activeAttackWithColliderCapacity = (ActiveAttackWithColliderCapacity)activeCapacity;
            damage = so.damage;
            team = activeCapacity.caster.team;
            transform.position +=
                activeAttackWithColliderCapacity.directionAttack *
                activeAttackWithColliderCapacity.so.offsetAttack + Vector3.up;
        }
    }
}