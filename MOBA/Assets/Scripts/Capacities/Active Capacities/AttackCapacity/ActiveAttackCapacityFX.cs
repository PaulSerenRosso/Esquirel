using System.Collections;
using System.Collections.Generic;
using Entities.Capacities;
using UnityEngine;

namespace Entities.Capacities
{
public class ActiveAttackCapacityFX : ActiveCapacityFX
{
  protected Champion.Champion champion;
  protected  ActiveAttackCapacity activeAttackCapacity;
  public override void InitCapacityFX(int entityIndex, byte capacityIndex)
  {
    base.InitCapacityFX(entityIndex, capacityIndex);
    champion =(Champion.Champion) EntityCollectionManager.GetEntityByIndex(entityIndex);
    if (capacityIndex == 255)
      activeAttackCapacity = (ActiveAttackCapacity) champion.attackBase;
      else
    {
      
    activeAttackCapacity = (ActiveAttackCapacity) champion.activeCapacities[capacityIndex];
    }
    transform.position += activeAttackCapacity.champion.rotateParent.forward*activeAttackCapacity.so.offsetAttack+Vector3.up;
    
    for (int i = 0; i < allParticleSystems.Length; i++)
    {
      var mainModule = allParticleSystems[i].main;
      mainModule.simulationSpeed = 1/activeAttackCapacity.so.fxTime;
    }
  }
  
  
}
}
