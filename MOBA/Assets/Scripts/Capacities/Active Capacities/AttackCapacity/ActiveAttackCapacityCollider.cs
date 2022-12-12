using System.Collections;
using System.Collections.Generic;
using UnityEngine;

namespace Entities.Capacities
{
    
public class ActiveAttackCapacityCollider :ActiveCapacityCollider
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
        ActiveAttackCapacitySO so =(ActiveAttackCapacitySO)
            CapacitySOCollectionManager.GetActiveCapacitySOByIndex(activeCapacity.indexOfSOInCollection);
        ActiveAttackCapacity activeAttackCapacity = (ActiveAttackCapacity)activeCapacity;
        damage = so.damage;
        team = activeCapacity.caster.team;
        transform.position += activeAttackCapacity.champion.rotateParent.forward*activeAttackCapacity.so.offsetAttack+Vector3.up*2;
        
    }
}
}
