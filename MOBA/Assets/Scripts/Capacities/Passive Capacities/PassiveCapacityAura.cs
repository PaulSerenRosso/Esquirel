using System.Collections;
using System.Collections.Generic;
using Entities;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
public abstract class PassiveCapacityAura : PassiveCapacity
{
    protected Champion.Champion champion;
    public override PassiveCapacitySO AssociatedPassiveCapacitySO()
    {
        return CapacitySOCollectionManager.Instance.GetPassiveCapacitySOByIndex(indexOfSo);
    }
  
    protected override void OnAddedEffects(Entity target)
    {
        champion = (Champion.Champion)target;
    }

    public override void SyncOnAdded(Entity target)
    {
        champion = (Champion.Champion)target;
        base.SyncOnAdded(target);
    }

    protected override void OnRemovedEffects(Entity target)
    {
        
        throw new System.NotImplementedException();
    }
}
    
}
