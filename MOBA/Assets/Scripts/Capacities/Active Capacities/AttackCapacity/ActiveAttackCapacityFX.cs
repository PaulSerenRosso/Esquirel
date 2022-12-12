using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
public class ActiveAttackCapacityFX : ActiveCapacityFX
{
  protected Champion.Champion champion;
  public override void InitCapacityFX(int entityIndex, byte capacityIndex)
  {
    champion =(Champion.Champion) EntityCollectionManager.GetEntityByIndex(entityIndex);
    base.InitCapacityFX(entityIndex, capacityIndex);
    ActiveAttackCapacity activeAttackCapacity = (ActiveAttackCapacity) champion.activeCapacities[capacityIndex];
    transform.position += activeAttackCapacity.champion.rotateParent.forward*activeAttackCapacity.so.offsetAttack;
  }
  
  
}
}
