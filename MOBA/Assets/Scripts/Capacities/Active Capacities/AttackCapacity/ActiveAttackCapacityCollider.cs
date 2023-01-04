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
            Debug.Log(team + "  " +entityCollided.team);
            if(entityCollided.team != team)
                lifeable.DecreaseCurrentHpRPC(damage);
        }
    }
    public override void InitCapacityCollider(ActiveCapacity activeCapacity)
    {
        ActiveAttackWithColliderCapacitySO so =(ActiveAttackWithColliderCapacitySO)
            CapacitySOCollectionManager.GetActiveCapacitySOByIndex(activeCapacity.indexOfSOInCollection);
        ActiveAttackWithColliderCapacity activeAttackWithColliderCapacity = (ActiveAttackWithColliderCapacity)activeCapacity;
        damage = so.damage;
        team = activeCapacity.caster.team;
        transform.position += activeAttackWithColliderCapacity.champion.rotateParent.forward*activeAttackWithColliderCapacity.so.offsetAttack+Vector3.up;
        
    }
}
}
