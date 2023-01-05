using System.Collections;
using System.Collections.Generic;
using Entities;
using UnityEngine;

namespace Entities.Capacities
{
    public class AutoAttackCollider : ActiveCapacityCollider
    {
        public float damage;
        public override void CollideWithEntity(Entity entityCollided)
        {
            IActiveLifeable lifeable = (IActiveLifeable)entityCollided;
            if (lifeable != null)
            {
                if(entityCollided.team != team)
                    lifeable.DecreaseCurrentHpRPC(damage);
            }
        }

        public override void InitCapacityCollider(ActiveCapacity activeCapacity)
        {
            ActiveAutoAttackSO activeAutoAttack =(ActiveAutoAttackSO)
                CapacitySOCollectionManager.GetActiveCapacitySOByIndex(activeCapacity.indexOfSOInCollection);
            damage = activeAutoAttack.damage;
            team = activeCapacity.caster.team;
        }
        
       
        
    }
}